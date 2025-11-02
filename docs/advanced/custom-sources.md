# 🔌 Custom Sources

Register and manage custom emoji data sources beyond Unicode CLDR and GitHub.

---

## Quick Start

```powershell
# Register custom URL source
Register-EmojiSource -Name "MySource" -Url "https://myapi.com/emojis.json" -Type Json

# Register local file source
Register-EmojiSource -Name "LocalData" -Path "C:\data\emojis.csv" -Type Csv

# Update from custom source
Update-EmojiDataset -Source "MySource"
```

---

## Why Custom Sources?

<div class="grid cards" markdown>

- **🏢 Corporate Data** - Use company-specific emoji sets
- **🌐 Regional Sets** - Language or region-specific emojis
- **🔧 Custom APIs** - Integrate with internal systems
- **📦 Local Files** - Work offline with custom data

</div>

---

## Registering Sources

### URL Sources

```powershell
# JSON API
Register-EmojiSource -Name "CompanyEmojis" -Url "https://api.company.com/emojis" -Type Json

# CSV endpoint
Register-EmojiSource -Name "ExternalCSV" -Url "https://example.com/emojis.csv" -Type Csv
```

### Local File Sources

```powershell
# Local JSON
Register-EmojiSource -Name "LocalJSON" -Path "D:\emojis\data.json" -Type Json

# Local CSV
Register-EmojiSource -Name "LocalCSV" -Path "C:\data\emojis.csv" -Type Csv
```

---

## Using Custom Sources

### Update from Source

```powershell
# Update from registered source
Update-EmojiDataset -Source "CompanyEmojis"

# Force update
Update-EmojiDataset -Source "CompanyEmojis" -Force
```

### List Sources

```powershell
# View all sources
Get-EmojiSource

# Get specific source
Get-EmojiSource -Name "CompanyEmojis"
```

### Remove Source

```powershell
# Remove source
Unregister-EmojiSource -Name "OldSource"
```

---

## Data Format Requirements

### JSON Format

```json
[
  {
    "emoji": "🚀",
    "name": "rocket",
    "category": "Travel & Places",
    "keywords": "launch, rocket, space"
  }
]
```

### CSV Format

```csv
emoji,name,category,keywords
🚀,rocket,Travel & Places,"launch, rocket, space"
🔥,fire,Activities,"fire, flame, hot"
```

---

## 📋 Complete Reference

### `Register-EmojiSource`

| Parameter | Description |
|-----------|-------------|
| `-Name` | Source name (required) |
| `-Url` | URL for remote source |
| `-Path` | Path for local file |
| `-Type` | Data type: Json or Csv |
| `-Force` | Overwrite existing |

### `Get-EmojiSource`

| Parameter | Description |
|-----------|-------------|
| `-Name` | Specific source name |

### `Unregister-EmojiSource`

| Parameter | Description |
|-----------|-------------|
| `-Name` | Source to remove |
| `-Force` | Skip confirmation |

---

<div align="center" markdown>

**Related:** [Custom Datasets](custom-datasets.md) | [Auto-Updates](../automation/auto-updates.md)

</div>
