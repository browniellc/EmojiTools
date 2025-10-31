# 🔄 EmojiTools Auto-Update Guide

## 📋 Table of Contents

1. [Overview](#overview)
2. [Key Features](#key-features)
3. [Quick Start](#quick-start)
4. [Data Sources Comparison](#data-sources-comparison)
5. [Configuration](#configuration)
6. [Scheduled Tasks (Windows)](#scheduled-tasks-windows)
7. [Update Workflow](#update-workflow)
8. [Best Practices](#best-practices)
9. [Troubleshooting](#troubleshooting)
10. [Examples](#examples)
11. [Metadata Format](#metadata-format)
12. [FAQ](#faq)
13. [Summary](#summary)

---

## Overview

EmojiTools now includes **automatic dataset updates** from Unicode CLDR to keep your emoji collection current with the latest Unicode standards.

## Key Features

### ✅ What's New

1. **Automatic Update Checks** - Module checks dataset age on load
2. **Unicode CLDR Integration** - Downloads official emoji data (1,900+ emojis)
3. **Metadata Tracking** - Tracks source, version, and update times
4. **Scheduled Tasks** - Optional Windows scheduled tasks for background updates
5. **Silent Updates** - Non-intrusive background update capability

## Quick Start

### Enable Auto-Updates (Recommended)

```powershell
# Enable automatic update checks (default: every 7 days)
Enable-EmojiAutoUpdate

# Custom interval (e.g., every 14 days)
Enable-EmojiAutoUpdate -Interval 14

# Enable with scheduled task (runs at 3 AM)
Enable-EmojiAutoUpdate -CreateScheduledTask
```

### Check Dataset Status

```powershell
# View comprehensive dataset information
Get-EmojiDatasetInfo
```

Output includes:
- 📁 Dataset file info (path, size, age)
- 📦 Emoji count and categories
- 🔖 Metadata (source, version, last update)
- 💡 Update recommendations
- ⚙️ Configuration settings

### Manual Update

```powershell
# Update from Unicode CLDR (recommended - official source)
Update-EmojiDataset -Source Unicode

# Update silently (no output)
Update-EmojiDataset -Source Unicode -Silent

# Force update even if recent
Update-EmojiDataset -Source Unicode -Force
```

## Data Sources Comparison

### 🏆 Unicode CLDR (Recommended - Default)
- **Emoji Count:** 1,900+
- **Authority:** Official Unicode Consortium
- **Updates:** Regular with Unicode releases
- **Quality:** Highest - official names and keywords
- **Auth Required:** No
- **Speed:** Fast

```powershell
Update-EmojiDataset -Source Unicode
```

### 🐙 GitHub
- **Emoji Count:** ~1,800
- **Authority:** GitHub's gemoji project
- **Updates:** Community maintained
- **Quality:** Good - GitHub-specific aliases
- **Auth Required:** No
- **Speed:** Very fast

```powershell
Update-EmojiDataset -Source GitHub
```

### 📊 Kaggle
- **Emoji Count:** Varies by dataset
- **Authority:** Community datasets
- **Updates:** Depends on contributor
- **Quality:** Variable
- **Auth Required:** Yes (API key)
- **Speed:** Slower (requires download)

```powershell
Update-EmojiDataset -Source Kaggle -KaggleApiKey "your-key"
```

## Configuration

### Module Configuration

The module stores configuration in `$Global:EmojiToolsConfig`:

```powershell
$Global:EmojiToolsConfig = @{
    AutoUpdateCheck = $true   # Enable/disable auto-check
    UpdateInterval = 7        # Days between checks
    DataPath = "..."          # Dataset CSV path
    MetadataPath = "..."      # Metadata JSON path
}
```

### Customize Settings

```powershell
# Disable auto-update checks
Disable-EmojiAutoUpdate

# Enable with custom interval
Enable-EmojiAutoUpdate -Interval 30  # Monthly

# Disable and remove scheduled task
Disable-EmojiAutoUpdate -RemoveScheduledTask
```

## Scheduled Tasks (Windows)

### Create Scheduled Task

```powershell
Enable-EmojiAutoUpdate -CreateScheduledTask
```

This creates a Windows scheduled task that:
- Runs at 3:00 AM daily
- Checks if update is needed based on interval
- Downloads from Unicode CLDR silently
- Runs only when network is available
- Works on battery power

### Manage Scheduled Task

```powershell
# View the task
Get-ScheduledTask -TaskName "EmojiTools-AutoUpdate"

# Run manually
Start-ScheduledTask -TaskName "EmojiTools-AutoUpdate"

# Remove task
Disable-EmojiAutoUpdate -RemoveScheduledTask
```

## Update Workflow

### Automatic Flow (Default)

1. **Module Import** → Check dataset age
2. **If > 7 days old** → Display reminder message
3. **User runs update** → Downloads from Unicode CLDR
4. **Dataset refreshed** → Metadata saved
5. **Next import** → No reminder (dataset current)

### Scheduled Task Flow

1. **3:00 AM** → Task triggers
2. **Check interval** → Is update needed?
3. **If yes** → Download silently from Unicode CLDR
4. **Save metadata** → Track update time
5. **Next day** → Repeat check

## Best Practices

### ✅ Recommended Configuration

```powershell
# For most users
Enable-EmojiAutoUpdate -Interval 7 -CreateScheduledTask
```

This ensures:
- Weekly update checks
- Automatic background updates
- Always current emoji data
- No manual intervention needed

### 📅 Update Intervals

- **7 days** - Recommended for active users
- **14 days** - Good balance for most users
- **30 days** - Minimal updates, still current

### 🔕 Silent Mode

Use silent mode for:
- Scheduled tasks
- Background scripts
- Non-interactive environments

```powershell
Update-EmojiDataset -Source Unicode -Silent
```

## Troubleshooting

### Dataset Not Updating

```powershell
# Check current status
Get-EmojiDatasetInfo

# Force update
Update-EmojiDataset -Source Unicode -Force

# Check network connectivity
Test-NetConnection raw.githubusercontent.com -Port 443
```

### Scheduled Task Not Running

```powershell
# Check task exists
Get-ScheduledTask -TaskName "EmojiTools-AutoUpdate"

# Check last run result
Get-ScheduledTaskInfo -TaskName "EmojiTools-AutoUpdate"

# Run manually to test
Start-ScheduledTask -TaskName "EmojiTools-AutoUpdate"
```

### Old Dataset Warning on Load

If you see this message:
```
ℹ️  Your emoji dataset is X days old.
   Run 'Update-EmojiDataset' to get the latest emojis from Unicode CLDR.
```

Simply run:
```powershell
Update-EmojiDataset -Source Unicode
```

## Examples

### Example 1: Initial Setup

```powershell
# Import module
Import-Module EmojiTools

# Check current status
Get-EmojiDatasetInfo

# Update to Unicode CLDR
Update-EmojiDataset -Source Unicode

# Enable auto-updates
Enable-EmojiAutoUpdate -CreateScheduledTask
```

### Example 2: Check for New Emojis

```powershell
# See current dataset info
Get-EmojiDatasetInfo

# If outdated, update
Update-EmojiDataset -Source Unicode

# Verify new count
Get-EmojiDatasetInfo
```

### Example 3: Disable Auto-Updates

```powershell
# Turn off auto-check
Disable-EmojiAutoUpdate

# Remove scheduled task
Disable-EmojiAutoUpdate -RemoveScheduledTask

# Verify configuration
Get-EmojiDatasetInfo
```

## Metadata Format

The module saves metadata in JSON format:

```json
{
  "Source": "Unicode CLDR",
  "LastUpdate": "2025-10-29T08:43:40.1234567-05:00",
  "EmojiCount": 1948,
  "Version": "CLDR 45"
}
```

Location: `EmojiTools\data\metadata.json`

## FAQ

### Q: How often should I update?

**A:** Weekly (7 days) is recommended for most users. Unicode releases major updates 1-2 times per year, but minor updates happen more frequently.

### Q: Will auto-update slow down module loading?

**A:** No. The module only checks the file age (instant). Actual downloads only happen when you run `Update-EmojiDataset`.

### Q: Can I use this on Linux/Mac?

**A:** Yes! Auto-update checks work on all platforms. Scheduled tasks are Windows-only, but you can use cron jobs on Linux/Mac.

### Q: What if I'm offline?

**A:** The module works offline with the cached dataset. Updates only occur when you're online.

### Q: How much data does an update download?

**A:** Unicode CLDR download is ~150 KB. Very lightweight!

## Summary

With auto-update enabled, your EmojiTools module will:

✅ Always have the latest emojis
✅ Update automatically in the background
✅ Notify you when updates are recommended
✅ Track data source and version
✅ Work seamlessly without manual intervention

**Recommended setup:**
```powershell
Enable-EmojiAutoUpdate -Interval 7 -CreateScheduledTask
```

That's it! Your emoji dataset will stay current automatically. 🎉
