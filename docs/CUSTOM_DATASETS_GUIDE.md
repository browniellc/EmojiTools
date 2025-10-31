# 📦 Custom Emoji Datasets Guide

The EmojiTools module supports custom emoji datasets, allowing you to:
- Import specialized emoji collections
- Create company-specific emoji sets
- Use extended Unicode emoji data
- Share emoji datasets across teams
- Build domain-specific emoji libraries

---

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [Importing Custom Datasets](#importing-custom-datasets)
3. [Creating Custom Datasets](#creating-custom-datasets)
4. [Exporting Datasets](#exporting-datasets)
5. [Dataset Formats](#dataset-formats)
6. [Dataset Management](#dataset-management)
7. [Examples & Use Cases](#examples--use-cases)

---

## 🚀 Quick Start

```powershell
# Import custom emojis (merges with existing)
Import-CustomEmojiDataset -Path "my-emojis.csv"

# Replace entire dataset with custom one
Import-CustomEmojiDataset -Path "company-emojis.json" -Replace

# Export filtered emojis
Export-CustomEmojiDataset -Path "animals.csv" -Category "Animals & Nature"

# Create a new dataset interactively
New-CustomEmojiDataset -Path "my-dataset.csv"

# View dataset information
Get-CustomEmojiDatasetInfo

# Reset to default Unicode dataset
Reset-EmojiDataset
```

---

## 📥 Importing Custom Datasets

### Basic Import (Merge Mode)

```powershell
# Import and merge with existing emojis
Import-CustomEmojiDataset -Path "custom-emojis.csv"

# Result: Adds new emojis, skips duplicates
# ✅ Imported 25 new emojis (skipped 5 duplicates)
# Total dataset size: 125 emojis
```

### Replace Entire Dataset

```powershell
# Replace all emojis with custom dataset
Import-CustomEmojiDataset -Path "complete-set.csv" -Replace

# Result: Replaces entire dataset
# ✅ Replaced dataset with 500 custom emojis
```

### Validate Emoji Characters

```powershell
# Validate emoji characters during import
Import-CustomEmojiDataset -Path "untrusted.csv" -Validate

# Result: Shows validation stats
# 🔍 Validating emoji characters...
#    Valid: 95, Invalid: 5
# ✅ Imported 95 new emojis
```

### Set as Default Dataset

```powershell
# Import and save as the default dataset
Import-CustomEmojiDataset -Path "extended-unicode.csv" -SetAsDefault

# Result: Imports and saves to data/emoji.csv
# 📦 Backed up original dataset to: emoji-backup-20251030-143022.csv
# 💾 Saved as default dataset
```

---

## 🎨 Creating Custom Datasets

### Interactive Creation

```powershell
# Create dataset interactively
New-CustomEmojiDataset -Path "team-emojis.csv"

# Prompts for each emoji:
# Emoji #1
#   Emoji character: 🚀
#   Name: rocket
#   Category (optional): Transportation
#   Keywords (comma-separated, optional): space, launch, fast
#   ✅ Added: 🚀 - rocket
```

### Manual CSV Creation

Create a CSV file with these columns:

```csv
emoji,name,category,keywords
🏢,office building,Buildings,work office company building
💼,briefcase,Objects,business work professional
☕,hot beverage,Food & Drink,coffee tea drink morning
🎯,direct hit,Activities,target goal achievement
💡,light bulb,Objects,idea innovation bright
```

### Manual JSON Creation

Create a JSON file with this structure:

```json
[
  {
    "emoji": "🏢",
    "name": "office building",
    "category": "Buildings",
    "keywords": "work office company building"
  },
  {
    "emoji": "💼",
    "name": "briefcase",
    "category": "Objects",
    "keywords": "business work professional"
  }
]
```

---

## 💾 Exporting Datasets

### Export Entire Dataset

```powershell
# Export all emojis to CSV
Export-CustomEmojiDataset -Path "backup.csv" -Format CSV

# Export all emojis to JSON
Export-CustomEmojiDataset -Path "backup.json" -Format JSON
```

### Export by Category

```powershell
# Export only food emojis
Export-CustomEmojiDataset -Path "food.csv" -Category "Food & Drink"

# Export only animals
Export-CustomEmojiDataset -Path "animals.json" -Format JSON -Category "Animals & Nature"
```

### Export Filtered Results

```powershell
# Export all heart emojis
Export-CustomEmojiDataset -Path "hearts.csv" -Query "heart"

# Export all face emojis
Export-CustomEmojiDataset -Path "faces.json" -Format JSON -Query "face"
```

### Export with All Fields

```powershell
# Include all metadata fields
Export-CustomEmojiDataset -Path "complete.csv" -IncludeAll
```

---

## 📐 Dataset Formats

### Required Fields

Both CSV and JSON formats require these fields:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `emoji` | string | ✅ Yes | The emoji character(s) |
| `name` | string | ✅ Yes | Display name of emoji |
| `category` | string | ⚠️ Optional | Category (defaults to "Custom") |
| `keywords` | string | ⚠️ Optional | Search keywords (defaults to name) |

### CSV Format Example

```csv
emoji,name,category,keywords
😀,grinning face,Smileys & Emotion,smile happy cheerful
😃,grinning face with big eyes,Smileys & Emotion,smile happy excited
🎉,party popper,Activities,celebration party confetti
🎊,confetti ball,Activities,celebration party
🍕,pizza,Food & Drink,food italian slice
```

**Important CSV Notes:**
- Use UTF-8 encoding
- First row must contain column headers
- Required columns: `emoji`, `name`
- Optional columns: `category`, `keywords`

### JSON Format Example

```json
[
  {
    "emoji": "😀",
    "name": "grinning face",
    "category": "Smileys & Emotion",
    "keywords": "smile happy cheerful"
  },
  {
    "emoji": "😃",
    "name": "grinning face with big eyes",
    "category": "Smileys & Emotion",
    "keywords": "smile happy excited"
  }
]
```

**Important JSON Notes:**
- Must be an array of objects
- Use UTF-8 encoding
- Required properties: `emoji`, `name`
- Optional properties: `category`, `keywords`

---

## 🔧 Dataset Management

### View Dataset Information

```powershell
Get-CustomEmojiDatasetInfo

# Output:
# 📊 Emoji Dataset Information
# ============================================================
# 
# Dataset Statistics:
#   Total Emojis:      150
#   Categories:        12
# 
# Top Categories:
#   Smileys & Emotion              35 emojis
#   Food & Drink                   28 emojis
#   Animals & Nature               22 emojis
#   ...
# 
# Dataset Source:
#   Path:              C:\...\data\emoji.csv
#   Size:              45.23 KB
#   Last Modified:     10/30/2025 2:15:43 PM
#   Age:               0.2 days
```

### Reset to Default Dataset

```powershell
# Reset to Unicode CLDR dataset (with confirmation)
Reset-EmojiDataset

# Skip confirmation
Reset-EmojiDataset -Force

# Reset without keeping backup
Reset-EmojiDataset -Force -KeepBackup:$false
```

### Backup Current Dataset

```powershell
# Export current dataset as backup
Export-CustomEmojiDataset -Path "backup-$(Get-Date -Format 'yyyyMMdd').csv"
```

---

## 💡 Examples & Use Cases

### Use Case 1: Company-Specific Emojis

Create a custom set for your organization:

```powershell
# Create company emoji dataset
$companyEmojis = @(
    [PSCustomObject]@{ emoji = '🏢'; name = 'HQ'; category = 'Company'; keywords = 'headquarters office main' }
    [PSCustomObject]@{ emoji = '💼'; name = 'Sales'; category = 'Company'; keywords = 'sales business deal' }
    [PSCustomObject]@{ emoji = '🔧'; name = 'Engineering'; category = 'Company'; keywords = 'dev engineering tech' }
)

# Export to CSV
$companyEmojis | Export-Csv "company-emojis.csv" -NoTypeInformation -Encoding UTF8

# Import into EmojiTools
Import-CustomEmojiDataset -Path "company-emojis.csv"

# Use them
Search-Emoji -Query "HQ"  # 🏢
```

### Use Case 2: Extended Unicode Dataset

Import a comprehensive Unicode emoji set:

```powershell
# Download extended Unicode dataset (example)
# https://unicode.org/Public/emoji/latest/emoji-test.txt

# Convert to CSV format (manual or scripted conversion)
# Then import
Import-CustomEmojiDataset -Path "unicode-extended.csv" -Replace -SetAsDefault
```

### Use Case 3: Themed Emoji Collections

Create themed datasets:

```powershell
# Weather emojis
Export-CustomEmojiDataset -Path "weather.csv" -Query "sun rain cloud snow"

# Tech emojis
Export-CustomEmojiDataset -Path "tech.csv" -Query "computer phone laptop"

# Share with team
# Team members can import:
Import-CustomEmojiDataset -Path "weather.csv"
```

### Use Case 4: Emoji Subset for Specific Project

```powershell
# Export only emojis needed for documentation
$projectEmojis = @('✅', '❌', '⚠️', '💡', '📝', '🚀')

# Filter and export
$Global:EmojiData | Where-Object { $_.emoji -in $projectEmojis } |
    Export-Csv "project-emojis.csv" -NoTypeInformation -Encoding UTF8

# Distribute to team
Import-CustomEmojiDataset -Path "project-emojis.csv"
```

### Use Case 5: Multilingual Emoji Names

Create datasets with localized names:

```csv
emoji,name,category,keywords
😀,cara sonriente,Emociones,sonrisa feliz alegría
🎉,festejo,Actividades,celebración fiesta confeti
🍕,pizza,Comida y Bebida,comida italiana rebanada
```

```powershell
Import-CustomEmojiDataset -Path "emojis-es.csv" -Replace
Search-Emoji -Query "feliz"  # 😀
```

### Use Case 6: Dataset Version Control

```powershell
# Export current dataset with version
$version = "v1.0.0"
Export-CustomEmojiDataset -Path "emoji-dataset-$version.csv"

# Commit to git
git add "emoji-dataset-$version.csv"
git commit -m "Add emoji dataset $version"

# Team members can pull and import
git pull
Import-CustomEmojiDataset -Path "emoji-dataset-$version.csv" -SetAsDefault
```

---

## 🎯 Best Practices

### 1. **Always Validate Unknown Datasets**
```powershell
Import-CustomEmojiDataset -Path "untrusted.csv" -Validate
```

### 2. **Use Merge Mode by Default**
```powershell
# Preserve existing emojis while adding new ones
Import-CustomEmojiDataset -Path "custom.csv"  # Default: merge mode
```

### 3. **Backup Before Replacing**
```powershell
# Automatic backup when using -SetAsDefault
Import-CustomEmojiDataset -Path "new.csv" -SetAsDefault
# Creates: emoji-backup-20251030-143022.csv
```

### 4. **Use Descriptive Keywords**
```csv
emoji,name,category,keywords
🚀,rocket,Transportation,space launch fast speed spacecraft nasa
```

### 5. **Organize by Categories**
```csv
emoji,name,category,keywords
🏢,office,Work,building office corporate business
💼,briefcase,Work,business professional job career
📊,chart,Work,data analytics statistics graph
```

### 6. **Test Before Committing**
```powershell
# Test in merge mode first
Import-CustomEmojiDataset -Path "new.csv"
Search-Emoji -Query "test"

# If good, set as default
Import-CustomEmojiDataset -Path "new.csv" -SetAsDefault
```

---

## 🔍 Troubleshooting

### Issue: "Dataset missing required field"

**Problem:** CSV/JSON missing `emoji` or `name` field

**Solution:** Ensure your dataset has required columns:
```csv
emoji,name,category,keywords
😀,smile,Emotion,happy
```

### Issue: Invalid emoji characters

**Problem:** Dataset contains non-emoji text

**Solution:** Use `-Validate` to identify issues:
```powershell
Import-CustomEmojiDataset -Path "data.csv" -Validate
# Review invalid entries and fix them
```

### Issue: Duplicate emojis

**Problem:** Importing adds duplicates

**Solution:** Use merge mode (default) which skips duplicates:
```powershell
Import-CustomEmojiDataset -Path "custom.csv"
# ✅ Imported 10 new emojis (skipped 5 duplicates)
```

### Issue: Lost original dataset

**Problem:** Accidentally replaced dataset

**Solution:** Check for automatic backups:
```powershell
# Look for backup files
Get-ChildItem "data\emoji-backup-*.csv" | Sort-Object LastWriteTime -Descending

# Restore from backup
Import-CustomEmojiDataset -Path "data\emoji-backup-20251030.csv" -SetAsDefault
```

---

## 📚 Related Documentation

- [QUICKSTART.md](QUICKSTART.md) - Getting started with EmojiTools
- [ALIASES_GUIDE.md](ALIASES_GUIDE.md) - Emoji aliases/shortcuts
- [COLLECTIONS_GUIDE.md](COLLECTIONS_GUIDE.md) - Emoji collections
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Setup and configuration

---

## 🤝 Contributing Datasets

Want to share your custom emoji dataset?

1. **Export your dataset:**
   ```powershell
   Export-CustomEmojiDataset -Path "my-awesome-emojis.csv"
   ```

2. **Document it:** Add README explaining the dataset
3. **Share:** Distribute via Git, file sharing, or package registry
4. **Credit:** Include author and license information

---

## 📝 Summary

The custom dataset features allow you to:

✅ Import custom emoji datasets (CSV or JSON)  
✅ Create specialized emoji collections  
✅ Export and share emoji datasets  
✅ Merge or replace existing datasets  
✅ Validate emoji characters  
✅ Reset to default Unicode data  
✅ View comprehensive dataset information  

**Quick Commands:**
```powershell
Import-CustomEmojiDataset -Path "file.csv"       # Import
Export-CustomEmojiDataset -Path "file.csv"       # Export
New-CustomEmojiDataset -Path "file.csv"          # Create
Get-CustomEmojiDatasetInfo                       # Info
Reset-EmojiDataset                               # Reset
```

Happy emoji customizing! 🎨✨
