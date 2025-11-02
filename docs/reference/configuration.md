# ⚙️ Configuration

Configure EmojiTools to match your preferences and workflow.

---

## Configuration File

EmojiTools stores configuration in the module's data directory:

```powershell
# View config location
$configPath = Join-Path (Split-Path $Profile) "Modules\EmojiTools\data\config.json"
```

---

## Configuration Options

### Auto-Update Settings

```powershell
# Enable auto-updates
Enable-EmojiAutoUpdate -Interval 7

# Disable auto-updates
Disable-EmojiAutoUpdate
```

**Options:**
- `AutoUpdateCheck`: Enable/disable automatic checks (boolean)
- `UpdateInterval`: Days between checks (integer)
- `UpdateSource`: Default source (Unicode or GitHub)

---

### History Tracking

```powershell
# Enable tracking
Enable-EmojiHistoryTracking

# Disable tracking
Disable-EmojiHistoryTracking
```

**Options:**
- `EnableHistory`: Track usage (boolean)
- `HistoryLimit`: Max entries to keep (integer)

---

### Search Settings

**Options:**
- `DefaultLimit`: Default search result limit (integer)
- `FuzzySearchThreshold`: Match sensitivity (0.0-1.0)
- `CacheEnabled`: Enable search caching (boolean)

---

### Display Preferences

**Options:**
- `DefaultTheme`: Picker theme (Light, Dark, Auto)
- `ShowMetadata`: Show extra info in results (boolean)
- `CompactDisplay`: Use compact output format (boolean)

---

## Module Preferences

### PowerShell Profile

Add EmojiTools settings to your profile for automatic loading:

```powershell
# Edit profile
notepad $PROFILE

# Add to profile:
Import-Module EmojiTools
Enable-EmojiAutoUpdate -Interval 7
```

---

### Environment Variables

Set environment variables for configuration:

```powershell
# Set default source
$env:EMOJITOOLS_DEFAULT_SOURCE = "Unicode"

# Set cache directory
$env:EMOJITOOLS_CACHE_DIR = "C:\MyCache"
```

---

## Data Locations

### Dataset Files

```powershell
# Default location
$dataPath = Join-Path $PSScriptRoot "..\data"

# Files:
# - emoji.csv           (main dataset)
# - metadata.json       (dataset info)
# - collections.json    (your collections)
# - aliases.json        (your aliases)
# - history.json        (usage history)
# - stats.json          (usage statistics)
```

---

## Backup & Restore

### Backup Configuration

```powershell
# Backup entire data folder
$source = Join-Path $PSScriptRoot "..\data"
$backup = "C:\Backups\EmojiTools-$(Get-Date -Format 'yyyyMMdd').zip"
Compress-Archive -Path $source -DestinationPath $backup
```

### Restore Configuration

```powershell
# Restore from backup
$backup = "C:\Backups\EmojiTools-20241102.zip"
$destination = Join-Path $PSScriptRoot "..\data"
Expand-Archive -Path $backup -DestinationPath $destination -Force
```

---

## Reset to Defaults

```powershell
# Reset all settings (requires confirmation)
Reset-EmojiTools

# Force reset without confirmation
Reset-EmojiTools -Force
```

!!! warning "Data Loss"
    Resetting removes all collections, aliases, and history. Backup first!

---

<div align="center" markdown>

**See Also:** [Commands](commands.md) | [Troubleshooting](troubleshooting.md)

</div>
