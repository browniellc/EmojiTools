# 🔄 Auto-Updates

Keep your emoji dataset fresh automatically! EmojiTools can check for and download the latest emoji data from Unicode CLDR without you lifting a finger.

---

## Quick Start

```powershell
# Enable automatic updates (checks every 7 days)
Enable-EmojiAutoUpdate

# Enable with scheduled task for background updates
Enable-EmojiAutoUpdate -CreateScheduledTask
```

That's it! Your emoji dataset will stay current automatically.

---

## ✨ Why Auto-Updates?

<div class="grid cards" markdown>

- **📅 Stay Current** - Get new emojis as Unicode releases them
- **🔄 Set & Forget** - Configure once, update forever
- **⚡ Non-Intrusive** - Silent background updates don't interrupt work
- **🎯 Official Source** - Updates from Unicode CLDR (the authoritative source)

</div>

---

## 🎯 How It Works

### Automatic Checks

When enabled, EmojiTools checks your dataset age each time the module loads:

1. **Module loads** → Checks last update date
2. **If outdated** → Downloads latest from Unicode CLDR
3. **Updates silently** → No interruption to your work
4. **You're current** → Always have the latest emojis

### Dataset Sources

**Unicode CLDR (Default & Recommended)**
- 🏆 Official source from Unicode Consortium
- 1,900+ emojis with official names
- Updated with each Unicode release
- Highest quality and accuracy

**GitHub (Alternative)**
- 🐙 Community-maintained gemoji project
- ~1,800 emojis
- GitHub-specific aliases included
- Fast and reliable

---

## 🔧 Configuration

### Enable Auto-Updates

```powershell
# Default: check every 7 days
Enable-EmojiAutoUpdate

# Custom interval: check every 14 days
Enable-EmojiAutoUpdate -Interval 14

# With scheduled task (runs at 3 AM daily)
Enable-EmojiAutoUpdate -Interval 7 -CreateScheduledTask
```

### Check Current Status

See your dataset information and update status:

```powershell
Get-EmojiDatasetInfo
```

**Output includes:**
- 📁 Dataset file path and size
- 📊 Emoji count and category breakdown
- 🏷️ Data source and version
- ⏰ Last update timestamp
- ⚙️ Auto-update configuration
- 💡 Update recommendations

### Disable Auto-Updates

```powershell
# Disable automatic checks
Disable-EmojiAutoUpdate

# Disable and remove scheduled task
Disable-EmojiAutoUpdate -RemoveScheduledTask
```

---

## ⏰ Scheduled Tasks (Windows)

Scheduled tasks run updates in the background at specific times, perfect for keeping datasets current without manual intervention.

### Create Scheduled Task

```powershell
# Creates a task that runs at 3:00 AM
Enable-EmojiAutoUpdate -CreateScheduledTask -Interval 7
```

**Task Details:**
- Runs daily at 3:00 AM
- Checks every N days (based on interval)
- Runs even if on battery power
- Requires network connection
- Runs silently in background

### View Scheduled Task

```powershell
# Check if task exists
Get-ScheduledTask -TaskName "EmojiTools-AutoUpdate"

# View task details
Get-ScheduledTask -TaskName "EmojiTools-AutoUpdate" | Format-List *
```

### Remove Scheduled Task

```powershell
# Remove the task
Disable-EmojiAutoUpdate -RemoveScheduledTask

# Or manually
Unregister-ScheduledTask -TaskName "EmojiTools-AutoUpdate" -Confirm:$false
```

!!! note "Windows Only"
    Scheduled tasks are only available on Windows. Mac and Linux users should use cron jobs or similar schedulers.

---

## 🔄 Manual Updates

Prefer manual control? Update whenever you want:

### Update from Unicode CLDR

```powershell
# Standard update
Update-EmojiDataset -Source Unicode

# Silent update (no output)
Update-EmojiDataset -Source Unicode -Silent

# Force update (even if recent)
Update-EmojiDataset -Source Unicode -Force
```

### Update from GitHub

```powershell
# Use GitHub's gemoji data
Update-EmojiDataset -Source GitHub

# Silent GitHub update
Update-EmojiDataset -Source GitHub -Silent
```

### Check Before Updating

```powershell
# Check current dataset status
Get-EmojiDatasetInfo

# If update recommended, run update
Update-EmojiDataset -Source Unicode
```

---

## 💡 Best Practices

!!! tip "Recommended Settings"
    ```powershell
    # Ideal setup for most users
    Enable-EmojiAutoUpdate -Interval 7 -CreateScheduledTask
    ```
    This checks weekly and runs updates at 3 AM when you're likely not working.

!!! tip "Verify After Update"
    After enabling auto-updates, verify the configuration:
    ```powershell
    Get-EmojiDatasetInfo
    ```
    Check that "Auto-Update" shows as "Enabled" and the interval is correct.

!!! tip "Keep Task Names Unique"
    If you use EmojiTools on multiple machines, scheduled tasks won't conflict—they're local to each system.

!!! tip "Network Required"
    Updates require internet access. The scheduled task is configured to only run when network is available.

---

## 📋 Complete Parameter Reference

### `Enable-EmojiAutoUpdate`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Interval` | Int | No | Days between update checks (default: 7) |
| `-CreateScheduledTask` | Switch | No | Create Windows scheduled task for background updates |

### `Disable-EmojiAutoUpdate`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-RemoveScheduledTask` | Switch | No | Also remove the scheduled task if it exists |

### `Update-EmojiDataset`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Source` | String | No | Data source: `Unicode` (default) or `GitHub` |
| `-Silent` | Switch | No | Suppress output messages |
| `-Force` | Switch | No | Force update even if dataset is recent |

### `Get-EmojiDatasetInfo`

No parameters. Returns comprehensive dataset information.

---

## 🔧 Troubleshooting

### Auto-Updates Not Working

**Problem:** Dataset not updating automatically.

**Solution:** Check if auto-update is enabled:
```powershell
Get-EmojiDatasetInfo
# Look for "Auto-Update: Enabled"

# If disabled, enable it
Enable-EmojiAutoUpdate
```

### Scheduled Task Not Running

**Problem:** Background updates not occurring.

**Solution:** Verify the task exists and is enabled:
```powershell
Get-ScheduledTask -TaskName "EmojiTools-AutoUpdate"

# Check last run time and result
Get-ScheduledTaskInfo -TaskName "EmojiTools-AutoUpdate"

# Run manually to test
Start-ScheduledTask -TaskName "EmojiTools-AutoUpdate"
```

### Update Failed

**Problem:** "Update failed" or network error.

**Solution:**
1. Check internet connection
2. Try manual update: `Update-EmojiDataset -Source Unicode`
3. If persistent, try alternate source: `Update-EmojiDataset -Source GitHub`

### Permission Denied

**Problem:** "Access denied" when creating scheduled task.

**Solution:** Run PowerShell as Administrator:
```powershell
# Right-click PowerShell → "Run as Administrator"
Enable-EmojiAutoUpdate -CreateScheduledTask
```

---

## 🎬 Common Scenarios

### First-Time Setup

```powershell
# Install and configure
Install-Module -Name EmojiTools
Import-Module EmojiTools

# Download initial dataset
Update-EmojiDataset -Source Unicode

# Enable auto-updates with scheduled task
Enable-EmojiAutoUpdate -Interval 7 -CreateScheduledTask

# Verify setup
Get-EmojiDatasetInfo
```

### Check for Updates Before Important Work

```powershell
# Check dataset age
Get-EmojiDatasetInfo

# If outdated, update before starting work
Update-EmojiDataset -Source Unicode

# Now search with latest data
Search-Emoji "party"
```

### Disable for Offline Work

```powershell
# Temporarily disable auto-updates
Disable-EmojiAutoUpdate

# Work offline...

# Re-enable when back online
Enable-EmojiAutoUpdate
```

---

## 🔗 Related Topics

- [Scheduled Tasks](scheduled-tasks.md) - Advanced scheduling options
- [History Tracking](history.md) - Track emoji usage over time
- [Custom Datasets](../advanced/custom-datasets.md) - Create your own emoji datasets

---

<div align="center" markdown>

**Next Steps:** Learn about [scheduled task management](scheduled-tasks.md) or explore [history tracking](history.md)

</div>
