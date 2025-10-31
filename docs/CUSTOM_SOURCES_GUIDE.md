# 🌐 Custom Emoji Sources Guide

The EmojiTools module supports **custom remote emoji sources**, allowing you to download emoji datasets from any URL or register your own sources for automatic updates.

---

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [Dataset Format Requirements](#dataset-format-requirements)
3. [Registering Custom Sources](#registering-custom-sources)
4. [Using Custom Sources](#using-custom-sources)
5. [Managing Sources](#managing-sources)
6. [Examples & Use Cases](#examples--use-cases)
7. [Best Practices](#best-practices)

---

## 🚀 Quick Start

```powershell
# One-time download from a URL
Update-EmojiDataset -Url "https://mycompany.com/emojis.csv"

# Register a custom source for reuse
Register-EmojiSource -Name "MyCompany" -Url "https://mycompany.com/emojis.json" -Format JSON

# List all available sources
Get-EmojiSource

# Update from registered custom source
Update-EmojiDataset -Source "MyCompany"

# Remove custom source
Unregister-EmojiSource -Name "MyCompany"
```

---

## 📄 Dataset Format Requirements

Custom emoji datasets must follow specific formats to be compatible with EmojiTools.

### CSV Format

**Required Columns:**
- `Emoji` - The actual emoji character(s)
- `Name` - Official or descriptive name
- `Category` - Emoji category (e.g., "Smileys & Emotion", "Animals & Nature")
- `Keywords` - Comma-separated search keywords

**Optional Columns:**
- `Subcategory` - Subcategory within main category
- `UnicodeVersion` - Unicode version introduced
- `Status` - Status (e.g., "fully-qualified", "component")

**Example CSV:**
```csv
Emoji,Name,Category,Keywords,Subcategory,UnicodeVersion,Status
😀,grinning face,Smileys & Emotion,"face,smile,happy,grin",face-smiling,1.0,fully-qualified
🐶,dog face,Animals & Nature,"dog,pet,animal,puppy",animal-mammal,0.6,fully-qualified
🍕,pizza,Food & Drink,"food,pizza,slice,italian",food-prepared,0.6,fully-qualified
⚽,soccer ball,Activities,"ball,soccer,football,sport",sport,0.6,fully-qualified
🌍,globe showing Europe-Africa,Travel & Places,"earth,globe,world,planet",place-map,0.7,fully-qualified
```

**Minimal CSV (Required Columns Only):**
```csv
Emoji,Name,Category,Keywords
😀,grinning face,Smileys & Emotion,"face,smile,happy"
🐶,dog face,Animals & Nature,"dog,pet,animal"
🍕,pizza,Food & Drink,"food,pizza,slice"
```

### JSON Format

**Structure:**
```json
{
  "annotations": {
    "tts": [
      {
        "emoji": "😀",
        "name": "grinning face",
        "keywords": ["face", "smile", "happy", "grin"]
      },
      {
        "emoji": "🐶",
        "name": "dog face",
        "keywords": ["dog", "pet", "animal", "puppy"]
      }
    ]
  }
}
```

**Alternative Flat Array Format:**
```json
[
  {
    "emoji": "😀",
    "name": "grinning face",
    "category": "Smileys & Emotion",
    "keywords": ["face", "smile", "happy"],
    "subcategory": "face-smiling",
    "unicode_version": "1.0"
  },
  {
    "emoji": "🐶",
    "name": "dog face",
    "category": "Animals & Nature",
    "keywords": ["dog", "pet", "animal"],
    "subcategory": "animal-mammal"
  }
]
```

### GitHub Format (emoji.json)

Compatible with GitHub's gemoji format:
```json
[
  {
    "emoji": "😀",
    "description": "grinning face",
    "category": "Smileys & Emotion",
    "aliases": ["grinning"],
    "tags": ["face", "smile", "happy"]
  }
]
```

**Field Mapping:**
- `description` → `Name`
- `tags` → `Keywords`
- `aliases` → Additional keywords

---

## 🔧 Registering Custom Sources

### Register a Source

```powershell
# Register with format auto-detection
Register-EmojiSource -Name "CompanyEmojis" -Url "https://company.com/emojis.csv"

# Explicitly specify format
Register-EmojiSource -Name "TeamEmojis" -Url "https://internal.local/emojis.json" -Format JSON

# Add description for documentation
Register-EmojiSource `
    -Name "ExtendedUnicode" `
    -Url "https://cdn.example.com/unicode-extended.csv" `
    -Format CSV `
    -Description "Extended Unicode set with additional annotations"
```

### Source Name Requirements

- Must be alphanumeric (can include hyphens and underscores)
- Cannot conflict with built-in sources: `Kaggle`, `Unicode`, `GitHub`
- Case-insensitive (stored as provided)
- Maximum 50 characters

### URL Requirements

- Must be valid HTTP or HTTPS URL
- Must be publicly accessible (or accessible from your network)
- Should return CSV or JSON content type
- File extension helps with auto-detection: `.csv`, `.json`

---

## 🔄 Using Custom Sources

### Update from Registered Source

```powershell
# Update using registered source name
Update-EmojiDataset -Source "CompanyEmojis"

# Force update even if recent
Update-EmojiDataset -Source "CompanyEmojis" -Force

# Silent mode (no output)
Update-EmojiDataset -Source "CompanyEmojis" -Silent
```

### One-Time URL Update

```powershell
# Download from URL without registration
Update-EmojiDataset -Url "https://example.com/special-emojis.csv"

# Specify format explicitly
Update-EmojiDataset -Url "https://example.com/data.txt" -Format CSV

# Force download
Update-EmojiDataset -Url "https://example.com/emojis.json" -Force
```

### Auto-Update with Custom Sources

```powershell
# Register source first
Register-EmojiSource -Name "MySource" -Url "https://mysite.com/emojis.csv"

# Enable auto-updates with custom source
Enable-EmojiAutoUpdate -DefaultSource "MySource" -Interval 7

# Now automatic updates will use your custom source
```

---

## 📊 Managing Sources

### List All Sources

```powershell
Get-EmojiSource

# Output:
# Name           Type      Format Url
# ----           ----      ------ ---
# Unicode        Built-in  JSON   https://unicode.org/Public/emoji/...
# Kaggle         Built-in  CSV    (Requires authentication)
# GitHub         Built-in  JSON   https://raw.githubusercontent.com/...
# CompanyEmojis  Custom    CSV    https://company.com/emojis.csv
# TeamData       Custom    JSON   https://internal.local/team.json
```

### List Only Custom Sources

```powershell
Get-EmojiSource -CustomOnly

# Output shows only your registered sources
```

### View Source Details

```powershell
Get-EmojiSource -Name "CompanyEmojis"

# Output:
# Name          : CompanyEmojis
# Type          : Custom
# Format        : CSV
# Url           : https://company.com/emojis.csv
# Description   : Company internal emoji set
# Added         : 2025-10-30T14:25:00Z
# LastUsed      : 2025-10-30T15:10:00Z
# UpdateCount   : 3
```

### Remove Custom Source

```powershell
# Remove with confirmation prompt
Unregister-EmojiSource -Name "CompanyEmojis"

# Force removal without confirmation
Unregister-EmojiSource -Name "CompanyEmojis" -Force

# Remove all custom sources
Unregister-EmojiSource -All -Force
```

---

## 💡 Examples & Use Cases

### Enterprise Internal Emoji Set

```powershell
# Company hosts internal emoji dataset with custom emojis
Register-EmojiSource `
    -Name "Contoso" `
    -Url "https://cdn.contoso.com/emojis/company-set.csv" `
    -Description "Contoso corporate emoji collection"

# Enable auto-updates to keep internal set current
Enable-EmojiAutoUpdate -DefaultSource "Contoso" -Interval 1
```

### Community Emoji Collections

```powershell
# Register community-maintained extended sets
Register-EmojiSource `
    -Name "EmojiExtended" `
    -Url "https://emoji.community/datasets/extended-v2.json" `
    -Format JSON `
    -Description "Community extended emoji set"

# Update when needed
Update-EmojiDataset -Source "EmojiExtended"
```

### Multiple Regional Sources

```powershell
# Register different regional emoji sets
Register-EmojiSource -Name "APAC" -Url "https://cdn.example.com/apac-emojis.csv"
Register-EmojiSource -Name "EMEA" -Url "https://cdn.example.com/emea-emojis.csv"
Register-EmojiSource -Name "Americas" -Url "https://cdn.example.com/americas-emojis.csv"

# Switch between sources as needed
Update-EmojiDataset -Source "APAC"
```

### Testing New Dataset Formats

```powershell
# Test a dataset before registering
Update-EmojiDataset -Url "https://test.example.com/new-format.csv"

# Verify it works
Get-Emoji -Name "test"

# If good, register it
Register-EmojiSource -Name "NewFormat" -Url "https://test.example.com/new-format.csv"
```

### Backup and Restore

```powershell
# Export current sources for backup
$sources = Get-EmojiSource -CustomOnly
$sources | Export-Clixml "emoji-sources-backup.xml"

# Restore on another machine
$sources = Import-Clixml "emoji-sources-backup.xml"
foreach ($source in $sources) {
    Register-EmojiSource -Name $source.Name -Url $source.Url -Format $source.Format
}
```

---

## ✅ Best Practices

### 1. **Use HTTPS URLs**
```powershell
# ✅ Good - Secure
Register-EmojiSource -Name "Secure" -Url "https://example.com/emojis.csv"

# ⚠️ Warning - Insecure (will show warning)
Register-EmojiSource -Name "Insecure" -Url "http://example.com/emojis.csv"
```

### 2. **Include Descriptions**
```powershell
# ✅ Good - Documented
Register-EmojiSource `
    -Name "CompanySet" `
    -Url "https://company.com/emojis.csv" `
    -Description "Q4 2025 company emoji collection - updated quarterly"

# ❌ Bad - No context
Register-EmojiSource -Name "CompanySet" -Url "https://company.com/emojis.csv"
```

### 3. **Validate Format**
```powershell
# ✅ Good - Explicit format
Register-EmojiSource -Name "Data" -Url "https://api.example.com/emojis" -Format JSON

# ⚠️ Relies on auto-detection
Register-EmojiSource -Name "Data" -Url "https://api.example.com/emojis"
```

### 4. **Test Before Registering**
```powershell
# ✅ Good - Test first
Update-EmojiDataset -Url "https://new-source.com/emojis.csv"
# Verify it works...
Register-EmojiSource -Name "NewSource" -Url "https://new-source.com/emojis.csv"

# ❌ Bad - Register untested
Register-EmojiSource -Name "NewSource" -Url "https://untested.com/emojis.csv"
```

### 5. **Use Versioned URLs**
```powershell
# ✅ Good - Versioned URL (stable)
Register-EmojiSource `
    -Name "CompanyV2" `
    -Url "https://cdn.company.com/emojis/v2/dataset.csv"

# ⚠️ Risk - Unversioned URL (may change unexpectedly)
Register-EmojiSource `
    -Name "Company" `
    -Url "https://cdn.company.com/emojis/latest.csv"
```

### 6. **Regular Updates**
```powershell
# ✅ Good - Scheduled updates
Enable-EmojiAutoUpdate -DefaultSource "CompanyEmojis" -Interval 7 -CreateScheduledTask

# Document update schedule in description
Register-EmojiSource `
    -Name "CompanyEmojis" `
    -Url "https://company.com/emojis.csv" `
    -Description "Updates every Monday at 3 AM via scheduled task"
```

---

## 🔍 Validation & Error Handling

### Format Validation

The module automatically validates:
- ✅ Required CSV columns present
- ✅ JSON structure matches expected format
- ✅ Emoji characters are valid Unicode
- ✅ URLs are accessible
- ✅ Content-Type headers match format

### Common Errors

**Error: Invalid URL**
```powershell
Register-EmojiSource -Name "Bad" -Url "not-a-url"
# Error: Invalid URL format. Must be HTTP or HTTPS.
```

**Error: Name Conflict**
```powershell
Register-EmojiSource -Name "Unicode" -Url "https://example.com/data.csv"
# Error: Source name 'Unicode' conflicts with built-in source.
```

**Error: Missing Required Columns**
```powershell
Update-EmojiDataset -Url "https://example.com/incomplete.csv"
# Error: CSV missing required columns: Emoji, Name, Category, Keywords
```

**Error: Invalid JSON Structure**
```powershell
Update-EmojiDataset -Url "https://example.com/bad.json"
# Error: JSON does not match expected format (missing 'annotations' or array structure)
```

---

## 🎯 Advanced Usage

### Dynamic Source Selection

```powershell
# Select source based on environment
$source = if ($env:REGION -eq "APAC") { "APAC-Emojis" } else { "Default-Emojis" }
Update-EmojiDataset -Source $source
```

### Automated Dataset Rotation

```powershell
# Rotate through multiple sources
$sources = @("Source1", "Source2", "Source3")
foreach ($source in $sources) {
    Write-Host "Testing $source..."
    Update-EmojiDataset -Source $source -Silent
    # Run tests...
}
```

### Custom Source with Authentication

```powershell
# For sources requiring authentication, download manually then import
$headers = @{ Authorization = "Bearer $token" }
Invoke-RestMethod -Uri "https://private.example.com/emojis.csv" -Headers $headers -OutFile "temp.csv"
Import-CustomEmojiDataset -Path "temp.csv" -SetAsDefault
Remove-Item "temp.csv"
```

---

## 📦 Source Registry Storage

Custom sources are stored in:
```
src/data/sources.json
```

**Example content:**
```json
{
  "version": "1.0",
  "custom_sources": [
    {
      "name": "CompanyEmojis",
      "url": "https://company.com/emojis.csv",
      "format": "CSV",
      "description": "Company internal emoji set",
      "added": "2025-10-30T14:25:00Z",
      "last_used": "2025-10-30T15:10:00Z",
      "update_count": 3
    },
    {
      "name": "TeamData",
      "url": "https://internal.local/team.json",
      "format": "JSON",
      "description": "Team-specific emojis",
      "added": "2025-10-30T14:30:00Z",
      "last_used": null,
      "update_count": 0
    }
  ]
}
```

---

## 🆘 Troubleshooting

### Source Not Found
```powershell
# Check registered sources
Get-EmojiSource

# Verify source name (case-insensitive)
Get-EmojiSource -Name "CompanyEmojis"
```

### Download Fails
```powershell
# Test URL accessibility
Invoke-RestMethod -Uri "https://company.com/emojis.csv" -Method Head

# Check format
Update-EmojiDataset -Url "https://company.com/emojis.csv" -Verbose
```

### Invalid Format
```powershell
# Download and inspect manually
$data = Invoke-RestMethod -Uri "https://company.com/emojis.csv"
$data | Select-Object -First 5
```

---

## 📚 Related Documentation

- [Custom Datasets Guide](CUSTOM_DATASETS_GUIDE.md) - Local file import/export
- [Auto-Update Guide](AUTO_UPDATE_GUIDE.md) - Scheduled updates
- [Quick Start](QUICKSTART.md) - Getting started

---

**Last Updated:** October 30, 2025
---

**Module Version:** 1.14.0
**Last Updated:** October 30, 2025
