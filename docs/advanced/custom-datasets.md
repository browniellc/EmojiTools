# 🎨 Custom Datasets

Create and manage your own custom emoji datasets for specialized projects, teams, or use cases.

---

## Quick Start

```powershell
# Create from collection
New-EmojiCustomDataset -Name "TeamEmojis" -Collection "WorkFavorites"

# Create from search
Search-Emoji "developer" | New-EmojiCustomDataset -Name "DevEmojis"

# Load custom dataset
Set-ActiveEmojiDataset -Name "TeamEmojis"
```

---

## Why Custom Datasets?

<div class="grid cards" markdown>

- **🎯 Focused** - Only emojis relevant to your project
- **⚡ Faster** - Smaller datasets = faster searches
- **👥 Team Sharing** - Share curated sets with teammates
- **🔒 Controlled** - Lock in specific emoji versions

</div>

---

## Creating Datasets

### From Collections

```powershell
# Create dataset from existing collection
New-EmojiCustomDataset -Name "MyProject" -Collection "ProjectEmojis"
```

### From Search Results

```powershell
# Create dataset from search
Search-Emoji "status" | New-EmojiCustomDataset -Name "StatusIcons"
```

### From File

```powershell
# Import from CSV
New-EmojiCustomDataset -Name "Imported" -FromFile "emojis.csv"

# Import from JSON
New-EmojiCustomDataset -Name "External" -FromFile "data.json"
```

---

## Using Custom Datasets

### Switch Datasets

```powershell
# Use custom dataset
Set-ActiveEmojiDataset -Name "TeamEmojis"

# Return to default
Set-ActiveEmojiDataset -Name "Default"

# Check active dataset
Get-ActiveEmojiDataset
```

### List Datasets

```powershell
# See all available datasets
Get-EmojiCustomDataset

# Get specific dataset info
Get-EmojiCustomDataset -Name "TeamEmojis"
```

---

## Sharing Datasets

### Export for Sharing

```powershell
# Export dataset
Export-EmojiCustomDataset -Name "TeamEmojis" -OutputPath "team-emojis.json"

# Share with team
Copy-Item "team-emojis.json" "\\teamshare\emojis\"
```

### Import Shared Dataset

```powershell
# Import from teammate
New-EmojiCustomDataset -Name "FromAlice" -FromFile "\\teamshare\alice-emojis.json"
```

---

## 📋 Complete Reference

### `New-EmojiCustomDataset`

| Parameter | Description |
|-----------|-------------|
| `-Name` | Dataset name (required) |
| `-Collection` | Create from collection |
| `-FromFile` | Import from file path |
| `-Force` | Overwrite existing |

**Pipeline Input:** Accepts emoji objects

### `Set-ActiveEmojiDataset`

| Parameter | Description |
|-----------|-------------|
| `-Name` | Dataset to activate |

### `Get-EmojiCustomDataset`

| Parameter | Description |
|-----------|-------------|
| `-Name` | Specific dataset name |

### `Remove-EmojiCustomDataset`

| Parameter | Description |
|-----------|-------------|
| `-Name` | Dataset to remove |
| `-Force` | Skip confirmation |

---

<div align="center" markdown>

**Related:** [Custom Sources](custom-sources.md) | [Collections](../user-guide/collections.md)

</div>
