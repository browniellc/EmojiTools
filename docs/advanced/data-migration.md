# Data Migration Guide

## Overview

Starting with EmojiTools **1.17.0**, user data is stored in a **version-independent location** to preserve your custom data (history, collections, aliases, statistics) across module upgrades.

## Problem with Previous Versions

In versions prior to 1.17.0, data was stored inside the module directory:

```
C:\Users\username\Documents\PowerShell\Modules\EmojiTools\1.16.0\data\
```

When you upgraded to a new version (e.g., 1.17.0), PowerShell would install it alongside:

```
C:\Users\username\Documents\PowerShell\Modules\EmojiTools\1.17.0\data\
```

This caused:
- ❌ Loss of emoji usage history
- ❌ Loss of custom collections
- ❌ Loss of custom aliases
- ❌ Loss of usage statistics
- ❌ Need to re-download emoji dataset

## Solution: Version-Independent Data Directory

### New Data Location

Your data is now stored in a **version-independent location**:

**Windows:**
```
C:\Users\username\AppData\Local\EmojiTools\
```

**macOS/Linux:**
```
/home/username/.emojitools/
```

### Automatic Migration

When you first load EmojiTools 1.17.0+:

1. ✅ **Automatic detection:** Module checks if migration is needed
2. ✅ **Safe migration:** Copies data from old location to new location
3. ✅ **Non-destructive:** Original files remain untouched
4. ✅ **One-time only:** Migration only runs once per data directory

### What Gets Migrated

The following files are automatically migrated:

| File | Description |
|------|-------------|
| `history.json` | Your emoji usage history |
| `collections.json` | Your custom emoji collections |
| `aliases.json` | Your custom emoji aliases |
| `stats.json` | Your usage statistics |
| `emoji.csv` | Cached emoji dataset |
| `metadata.json` | Dataset metadata |
| `languages/*` | Installed language packs |

## Manual Migration

If you need to manually migrate data or use a custom location:

### Option 1: Use Environment Variable

Set a custom data path before importing the module:

```powershell
$env:EMOJITOOLS_DATA_PATH = "D:\MyData\EmojiTools"
Import-Module EmojiTools
```

### Option 2: Manual Migration Function

Migrate data from a specific location:

```powershell
# Import module first
Import-Module EmojiTools

# Migrate from old location
$oldPath = "C:\Users\username\Documents\PowerShell\Modules\EmojiTools\1.16.0\data"
$newPath = Get-EmojiToolsDataPath

Invoke-EmojiDataMigration -SourcePath $oldPath -DestinationPath $newPath -Force
```

### Option 3: Copy Files Manually

Copy these files from old location to new location:

```powershell
# Get the new data path
$dataPath = Get-EmojiToolsDataPath
Write-Host "Copy files to: $dataPath"

# Old location (adjust version number)
$oldPath = "$HOME\Documents\PowerShell\Modules\EmojiTools\1.16.0\data"

# Copy files
Copy-Item "$oldPath\history.json" -Destination $dataPath -Force
Copy-Item "$oldPath\collections.json" -Destination $dataPath -Force
Copy-Item "$oldPath\aliases.json" -Destination $dataPath -Force
Copy-Item "$oldPath\stats.json" -Destination $dataPath -Force
Copy-Item "$oldPath\emoji.csv" -Destination $dataPath -Force
Copy-Item "$oldPath\metadata.json" -Destination $dataPath -Force
Copy-Item "$oldPath\languages" -Destination $dataPath -Recurse -Force
```

## Checking Your Data Location

View your current data directory:

```powershell
Get-EmojiToolsDataPath
```

View detailed module information including data path:

```powershell
Get-EmojiToolsInfo
```

## Benefits of Version-Independent Storage

### 1. **Upgrade Safety**
Your data persists across module upgrades. No need to manually backup and restore.

### 2. **Multiple Versions**
You can have multiple module versions installed without conflicts:
- `1.15.0` (old format)
- `1.16.0` (old format)
- `1.17.0` (new format) ← Uses shared data directory
- `1.18.0` (future) ← Uses same shared data directory

### 3. **Easy Backup**
Backup a single directory instead of searching through module versions:

```powershell
$dataPath = Get-EmojiToolsDataPath
Copy-Item $dataPath -Destination "D:\Backups\EmojiTools-$(Get-Date -Format 'yyyy-MM-dd')" -Recurse
```

### 4. **Portable Configuration**
Export your data directory to move between machines:

```powershell
# Machine 1: Export
$dataPath = Get-EmojiToolsDataPath
Compress-Archive -Path $dataPath -DestinationPath "EmojiTools-data.zip"

# Machine 2: Import
$dataPath = Get-EmojiToolsDataPath
Expand-Archive -Path "EmojiTools-data.zip" -DestinationPath $dataPath -Force
```

## Troubleshooting

### Data Not Migrating

**Symptom:** Upgraded module but old data not available

**Solutions:**

1. Check if migration completed:
   ```powershell
   $dataPath = Get-EmojiToolsDataPath
   Test-Path (Join-Path $dataPath ".migrated")
   ```

2. Manually trigger migration:
   ```powershell
   Initialize-EmojiToolsDataDirectory -Force
   ```

3. Check old location still exists:
   ```powershell
   Get-Module EmojiTools -ListAvailable | Select-Object Version, ModuleBase
   # Look for 1.15.0 folder and check if data\ exists
   ```

### Finding Old Data Location

List all installed EmojiTools versions:

```powershell
Get-Module EmojiTools -ListAvailable | ForEach-Object {
    $dataPath = Join-Path $_.ModuleBase "data"
    [PSCustomObject]@{
        Version = $_.Version
        DataPath = $dataPath
        Exists = Test-Path $dataPath
        Files = if (Test-Path $dataPath) {
            (Get-ChildItem $dataPath -File).Name -join ", "
        } else {
            "N/A"
        }
    }
} | Format-Table -AutoSize
```

### Migration Errors

If migration fails, check:

1. **Permissions:** Ensure you have write access to destination
   ```powershell
   $dataPath = Get-EmojiToolsDataPath
   Test-Path $dataPath -IsValid
   New-Item -ItemType Directory -Path $dataPath -Force # Try creating
   ```

2. **Disk space:** Ensure enough space (data is typically < 5 MB)
   ```powershell
   Get-PSDrive C | Select-Object Free
   ```

3. **File locks:** Ensure no other process has files open
   ```powershell
   # Close all PowerShell sessions using EmojiTools
   Get-Process powershell, pwsh | Where-Object {
       $_.Modules.ModuleName -contains "EmojiTools"
   }
   ```

## Reverting to Old Location (Not Recommended)

If you need to use the module-embedded data location:

```powershell
# Set environment variable to module path
$module = Get-Module EmojiTools
$env:EMOJITOOLS_DATA_PATH = Join-Path $module.ModuleBase "data"

# Reload module
Remove-Module EmojiTools -Force
Import-Module EmojiTools
```

⚠️ **Warning:** This will cause data loss on upgrades!

## Related Commands

| Command | Description |
|---------|-------------|
| `Get-EmojiToolsDataPath` | Get the current data directory path |
| `Initialize-EmojiToolsDataDirectory` | Initialize/migrate data directory |
| `Invoke-EmojiDataMigration` | Manually migrate data from one location to another |
| `Get-EmojiToolsInfo` | View module information including data path |

## See Also

- [Installation Guide](../getting-started/installation.md)
- [Quick Start Guide](../getting-started/quickstart.md)
- [Configuration Reference](../reference/configuration.md)
