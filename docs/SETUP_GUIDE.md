# 🚀 EmojiTools Setup Guide

## 📋 Table of Contents

1. [Automatic Setup (Recommended)](#automatic-setup-recommended)
2. [Manual Setup](#manual-setup)
3. [Module Information](#module-information)
4. [Configuration](#configuration)
5. [Disable Auto-Initialization](#disable-auto-initialization)
6. [First-Time Workflow](#first-time-workflow)
7. [Customization After Setup](#customization-after-setup)
8. [Troubleshooting](#troubleshooting)
9. [Unattended Installation](#unattended-installation)
10. [Advanced: Custom Setup Script](#advanced-custom-setup-script)
11. [Files Created During Setup](#files-created-during-setup)
12. [Next Steps](#next-steps)

---

## Automatic Setup (Recommended)

EmojiTools now features **automatic first-run initialization**! Simply import the module:

```powershell
Import-Module EmojiTools
```

On first import, you'll see:
```
🎉 Welcome to EmojiTools! Running first-time setup...
   📁 Creating default emoji collections...
   🔖 Setting up emoji aliases...

✅ Setup complete! EmojiTools is ready to use.
   Try: Get-EmojiAlias -List
   Try: Get-EmojiCollection
   Try: Show-EmojiPicker
```

### What Gets Initialized?

1. **Default Collections** (6 collections)
   - Developer
   - Reactions
   - Celebrations
   - Status
   - Weather
   - Animals

2. **Default Aliases** (70+ shortcuts)
   - Quick access to common emojis
   - Organized by category
   - Ready to use immediately

## Manual Setup

### Full Initialization

```powershell
Initialize-EmojiTools
```

### Re-initialize (Overwrite)

```powershell
Initialize-EmojiTools -Force
```

### Partial Initialization

```powershell
# Only initialize aliases (skip collections)
Initialize-EmojiTools -SkipCollections

# Only initialize collections (skip aliases)
Initialize-EmojiTools -SkipAliases
```

## Module Information

### Check Status

```powershell
Get-EmojiToolsInfo
```

Output:
```
📊 EmojiTools Module Information
============================================================

Module Details:
  Version:           1.14.0
  Exported Functions: 33
  Module Path:       C:\...\EmojiTools

Data Status:
  Setup Complete:    ✅ Yes
  Emojis Loaded:     1948
  Aliases Defined:   71
  Collections:       6
  Statistics:        ✅ Available

Configuration:
  Auto-Update Check: True
  Auto-Initialize:   Collections, Aliases
  Update Interval:   7 days
  Dataset Age:       0.5 days
```

## Configuration

### Control Auto-Initialization Features

EmojiTools uses a flexible array-based configuration to control which features auto-initialize:

```powershell
# Default: Initialize both collections and aliases
$Global:EmojiToolsConfig.AutoInitialize = @('Collections', 'Aliases')

# Initialize everything (includes future features)
$Global:EmojiToolsConfig.AutoInitialize = @('All')

# Initialize only aliases
$Global:EmojiToolsConfig.AutoInitialize = @('Aliases')

# Initialize only collections
$Global:EmojiToolsConfig.AutoInitialize = @('Collections')

# Disable all auto-initialization
$Global:EmojiToolsConfig.AutoInitialize = @()
```

**Note:** Configuration changes must be made **before** importing the module:

```powershell
# Set configuration
$Global:EmojiToolsConfig = @{
    AutoInitialize = @('Aliases')  # Only aliases, skip collections
}

# Then import
Import-Module EmojiTools
```

Or edit `EmojiTools.psm1` directly (line 11):
```powershell
AutoInitialize = @('Collections', 'Aliases')  # Modify as needed
```

### Future-Proof Design

When new features are added in future versions (e.g., themes, templates), they can be added to the array:

```powershell
# Example in future version 2.0
AutoInitialize = @('Collections', 'Aliases', 'Themes', 'Templates')

# Or use 'All' to get everything
AutoInitialize = @('All')
```

### Reset Collections and Aliases

```powershell
Reset-EmojiTools
```

This will:
1. Remove all custom collections
2. Remove all custom aliases
3. Clear the setup marker
4. Re-run initialization with defaults

### Reset Everything (Including Stats)

```powershell
Reset-EmojiTools -IncludeStats -Force
```

**Warning:** This removes:
- All custom collections
- All custom aliases
- All usage statistics
- Search history
- Collection usage data

## Disable Auto-Initialization

If you prefer manual setup, you can disable all auto-initialization:

```powershell
# Disable before import
$Global:EmojiToolsConfig.AutoInitialize = @()
Import-Module EmojiTools
```

Or edit `EmojiTools.psm1` (line 11) and set:
```powershell
AutoInitialize = @()  # Empty array disables auto-initialization
```

### Disable Auto-Update Checks

```powershell
Disable-EmojiAutoUpdate
```

Or in configuration:
```powershell
$Global:EmojiToolsConfig.AutoUpdateCheck = $false
```

## First-Time Workflow

### Recommended Steps

1. **Import Module**
   ```powershell
   Import-Module EmojiTools
   ```
   *(Auto-initialization happens here)*

2. **Explore Aliases**
   ```powershell
   Get-EmojiAlias -List
   ```

3. **Try Some Shortcuts**
   ```powershell
   Get-EmojiAlias -Alias "rocket" -Copy
   Get-EmojiAlias -Alias "fire" -Copy
   ```

4. **Check Collections**
   ```powershell
   Get-EmojiCollection
   ```

5. **Open Interactive Picker**
   ```powershell
   Show-EmojiPicker
   ```

6. **View Module Info**
   ```powershell
   Get-EmojiToolsInfo
   ```

## Customization After Setup

### Add Your Own Aliases

```powershell
New-EmojiAlias -Alias "done" -Emoji "✅"
New-EmojiAlias -Alias "wip" -Emoji "🚧"
```

### Create Custom Collections

```powershell
New-EmojiCollection -Name "MyProject" -Description "Project emojis"
Add-EmojiToCollection -Collection "MyProject" -Emojis "🚀","💡","🎯"
```

### Export for Backup

```powershell
Export-EmojiAliases -Path "my-setup.json"
Export-EmojiCollection -Name "MyProject" -Path "project-emojis.json"
```

## Troubleshooting

### Setup Not Running?

Check if already initialized:
```powershell
Test-Path "$env:USERPROFILE\Documents\PowerShell\Modules\EmojiTools\data\.setup-complete"
```

Force re-initialization:
```powershell
Initialize-EmojiTools -Force
```

### Missing Aliases or Collections?

Re-run specific initialization:
```powershell
Initialize-DefaultEmojiAliases -Force
Initialize-EmojiCollections
```

### Reset Everything

```powershell
Reset-EmojiTools -IncludeStats -Force
Import-Module EmojiTools -Force
```

## Unattended Installation

For scripts or automated deployment:

```powershell
# Silent import (auto-init runs in background)
Import-Module EmojiTools -Force -ErrorAction SilentlyContinue

# Verify setup
if (Get-Command Get-EmojiToolsInfo -ErrorAction SilentlyContinue) {
    Write-Host "EmojiTools installed successfully"
}
```

## Advanced: Custom Setup Script

```powershell
# Import without auto-init
$Global:EmojiToolsConfig.AutoInitialize = @()  # Disable auto-init
Import-Module EmojiTools

# Custom initialization
Initialize-EmojiTools -SkipCollections
New-EmojiAlias -Alias "custom1" -Emoji "🎯"
New-EmojiAlias -Alias "custom2" -Emoji "💡"

# Create minimal collections
New-EmojiCollection -Name "Work" -Description "Work emojis"
Add-EmojiToCollection -Collection "Work" -Emojis "💼","📧","📅"

# Mark setup complete manually
New-Item -ItemType File -Path $Global:EmojiToolsConfig.SetupCompletePath -Force
```

## Files Created During Setup

Setup creates these files in the `data/` directory:

- `.setup-complete` - Setup completion marker
- `aliases.json` - Emoji alias definitions
- `collections.json` - Collection definitions
- `stats.json` - Usage statistics (created on first tracked action)

## Next Steps

After setup, explore the features:

- **Quick Access**: `Get-EmojiAlias -Alias "fire"`
- **Interactive Picker**: `Show-EmojiPicker`
- **Search**: `Search-Emoji -Query "heart"`
- **Statistics**: `Get-EmojiStats`
- **Collections**: `Get-EmojiCollection`

---

**Version:** 1.14.0
**Last Updated:** October 30, 2025
