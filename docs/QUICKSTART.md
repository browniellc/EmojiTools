# 🎉 EmojiTools Quick Start Guide

## Installation & Setup

### Step 1: Import the Module
```powershell
# Navigate to the module directory
cd "$HOME\Documents\PowerShell\EmojiTools"

# Import the module
Import-Module .\src\EmojiTools.psd1
```

### Step 2: Verify Installation
```powershell
# Check available commands
Get-Command -Module EmojiTools

# Should show:
# - Emoji
# - Get-Emoji
# - Search-Emoji
# - Update-EmojiDataset
```

### Step 3: Test Basic Functionality
```powershell
# List first 5 emojis
Get-Emoji -Limit 5

# Search for emojis
Search-Emoji -Query "smile"
```

## Quick Reference

### 🔍 Search for Emojis
```powershell
Search-Emoji -Query "house"    # Find all house emojis
Search-Emoji -Query "car"      # Find all car emojis
Search-Emoji -Query "love"     # Find all love-related emojis
```

### 📋 List Emojis
```powershell
Get-Emoji                           # List all emojis
Get-Emoji -Limit 10                 # First 10 emojis
Get-Emoji -Category "Animals"       # Filter by category
```

### 🎯 Use Safe Dispatcher
```powershell
Emoji Search "happy"               # Search using dispatcher
Emoji Get -Limit 10                # Get using dispatcher
Emoji Update                       # Update dataset
```

### 🔄 Update Dataset
```powershell
Update-EmojiDataset                # Update from GitHub (default)
Update-EmojiDataset -Source Unicode # Update from Unicode CLDR
Update-EmojiDataset -Force         # Force re-download
```

## Common Categories

- `Smileys & Emotion` - All smiley faces and emotion emojis
- `People & Body` - People, hands, body parts
- `Animals & Nature` - Animals, plants, nature
- `Food & Drink` - Food, beverages, utensils
- `Travel & Places` - Vehicles, buildings, places
- `Activities` - Sports, games, activities
- `Objects` - Tools, devices, objects

## Tips & Tricks

### Copy Emoji to Clipboard
```powershell
# Windows
$emoji = (Search-Emoji -Query "rocket" | Select-Object -First 1).emoji
Set-Clipboard $emoji
```

### Get Random Emoji
```powershell
Get-Emoji | Get-Random | Select-Object emoji, name
```

### Count Emojis by Category
```powershell
$Global:EmojiData | Group-Object category |
    Select-Object Name, Count |
    Sort-Object Count -Descending
```

### Export Search Results
```powershell
Search-Emoji -Query "heart" |
    Export-Csv -Path "hearts.csv" -NoTypeInformation
```

### Create Custom Emoji List
```powershell
# Create a favorites list
$favorites = @("smile", "heart", "rocket", "star", "fire")
$favorites | ForEach-Object { Search-Emoji -Query $_ -Limit 1 }
```

## Troubleshooting

### Module Not Found
```powershell
# Make sure you're in the right directory
cd "$HOME\Documents\PowerShell\EmojiTools"
Import-Module .\EmojiTools.psd1 -Force
```

### No Emoji Data
```powershell
# Download the dataset
Update-EmojiDataset
```

### Emojis Not Displaying
```powershell
# Set console encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
```

### Re-import After Changes
```powershell
# Force reload the module
Import-Module .\EmojiTools.psd1 -Force
```

## Next Steps

1. ✅ Try searching for your favorite emojis
2. ✅ Explore different categories
3. ✅ Create custom emoji collections
4. ✅ Update to get the latest emoji data

## Learn More

- Read the full `README.md` for detailed documentation
- Check `EXAMPLES.ps1` for more usage examples
- Explore the `functions\` folder to see how it works

---

**Need Help?** Run `Get-Help <CommandName> -Full` for detailed help on any command:
- `Get-Help Get-Emoji -Full`
- `Get-Help Search-Emoji -Full`
- `Get-Help Update-EmojiDataset -Full`
- `Get-Help Emoji -Full`
