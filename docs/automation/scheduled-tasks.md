# ⏰ Scheduled Tasks

Automate emoji dataset updates across Windows, Linux, and macOS with platform-specific scheduled tasks.

---

## Quick Start

```powershell
# Create a scheduled task (auto-detects your platform)
New-EmojiScheduledTask -Interval 7

# Remove a scheduled task
Remove-EmojiScheduledTask
```

---

## ✨ Platform Support

<div class="grid cards" markdown>

- **🪟 Windows** - Uses Task Scheduler for native scheduling
- **🐧 Linux** - Uses cron jobs for reliable scheduling
- **🍎 macOS** - Uses launchd for system-level scheduling

</div>

---

## 🪟 Windows Task Scheduler

### Create Task

```powershell
# Create task that runs every 7 days at 3 AM
New-EmojiScheduledTask -Interval 7

# Create with silent mode
New-EmojiScheduledTask -Interval 14 -Silent
```

**Task Properties:**
- Name: `EmojiTools-AutoUpdate`
- Runs: Daily at 3:00 AM
- Frequency: Every N days (based on interval)
- Conditions: Runs on battery, requires network
- Action: `Update-EmojiDataset -Source Unicode -Silent`

### View Task

```powershell
# Check if task exists
Get-ScheduledTask -TaskName "EmojiTools-AutoUpdate"

# View task info
Get-ScheduledTaskInfo -TaskName "EmojiTools-AutoUpdate"

# Run task immediately
Start-ScheduledTask -TaskName "EmojiTools-AutoUpdate"
```

### Remove Task

```powershell
# Remove via EmojiTools
Remove-EmojiScheduledTask

# Or remove manually
Unregister-ScheduledTask -TaskName "EmojiTools-AutoUpdate" -Confirm:$false
```

---

## 🐧 Linux Cron Jobs

### Create Cron Job

```powershell
# Creates cron job for current user
New-EmojiScheduledTask -Interval 7
```

**Cron Entry:**
```bash
# EmojiTools Auto-Update (Every 7 days at 3 AM)
0 3 */7 * * /usr/bin/pwsh -NoProfile -Command "Import-Module EmojiTools; Update-EmojiDataset -Source Unicode -Silent"
```

### View Cron Jobs

```bash
# List all cron jobs
crontab -l | grep EmojiTools

# Edit cron jobs manually
crontab -e
```

### Remove Cron Job

```powershell
# Remove via EmojiTools
Remove-EmojiScheduledTask
```

Or manually edit:
```bash
crontab -e
# Delete the EmojiTools line
```

---

## 🍎 macOS LaunchAgent

### Create Launch Agent

```powershell
# Creates launchd agent
New-EmojiScheduledTask -Interval 7
```

**Agent File:** `~/Library/LaunchAgents/com.emojitools.autoupdate.plist`

### View Agent

```bash
# List loaded agents
launchctl list | grep emojitools

# View agent status
launchctl print gui/$(id -u)/com.emojitools.autoupdate
```

### Remove Agent

```powershell
# Remove via EmojiTools
Remove-EmojiScheduledTask
```

Or manually:
```bash
# Unload agent
launchctl unload ~/Library/LaunchAgents/com.emojitools.autoupdate.plist

# Remove file
rm ~/Library/LaunchAgents/com.emojitools.autoupdate.plist
```

---

## 📋 Complete Parameter Reference

### `New-EmojiScheduledTask`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Interval` | Int | No | Days between updates (1-365, default: 7) |
| `-Silent` | Switch | No | Suppress output messages |

**Returns:** `Boolean` - True if task created successfully

### `Remove-EmojiScheduledTask`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Silent` | Switch | No | Suppress output messages |

**Returns:** `Boolean` - True if task removed successfully

### `Get-EmojiScheduledTaskStatus`

No parameters. Returns information about the scheduled task status.

---

## 💡 Pro Tips

!!! tip "Admin Rights on Windows"
    Creating scheduled tasks on Windows requires administrator privileges:
    ```powershell
    # Right-click PowerShell → Run as Administrator
    New-EmojiScheduledTask -Interval 7
    ```

!!! tip "Check Task Status"
    Verify your task is working correctly:
    ```powershell
    # Check status
    Get-EmojiScheduledTaskStatus

    # Manually trigger to test
    # Windows:
    Start-ScheduledTask -TaskName "EmojiTools-AutoUpdate"
    ```

!!! tip "Adjust Timing"
    Change when the task runs by recreating with a different interval:
    ```powershell
    Remove-EmojiScheduledTask
    New-EmojiScheduledTask -Interval 14  # Every 2 weeks
    ```

!!! tip "Logs and Troubleshooting"
    Check logs if updates aren't running:
    ```powershell
    # Windows: Check Task Scheduler history
    # Linux: Check syslog - grep "EmojiTools" /var/log/syslog
    # macOS: Check system.log - log show --predicate 'process == "pwsh"'
    ```

---

## 🔧 Troubleshooting

### Task Not Created (Windows)

**Problem:** "Access denied" or permission error.

**Solution:** Run PowerShell as Administrator:
```powershell
# Right-click → Run as Administrator
New-EmojiScheduledTask -Interval 7
```

### Cron Job Not Running (Linux)

**Problem:** Cron job exists but doesn't execute.

**Solution:** Verify cron service and paths:
```bash
# Check cron service
systemctl status cron

# Verify PowerShell path
which pwsh

# Test command manually
/usr/bin/pwsh -NoProfile -Command "Import-Module EmojiTools; Update-EmojiDataset"
```

### LaunchAgent Not Loading (macOS)

**Problem:** Agent file exists but isn't loaded.

**Solution:** Load it manually:
```bash
launchctl load ~/Library/LaunchAgents/com.emojitools.autoupdate.plist
launchctl start com.emojitools.autoupdate
```

### Updates Not Happening

**Problem:** Task runs but dataset not updating.

**Solution:** Check network and permissions:
```powershell
# Test manual update
Update-EmojiDataset -Source Unicode

# Check dataset info
Get-EmojiDatasetInfo

# Verify write permissions to data folder
```

---

## 🔗 Related Topics

- [Auto-Updates](auto-updates.md) - Configure automatic update checks
- [History Tracking](history.md) - Track when updates occur
- [Custom Datasets](../advanced/custom-datasets.md) - Schedule custom dataset updates

---

<div align="center" markdown>

**Next Steps:** Learn about [history tracking](history.md) or configure [auto-updates](auto-updates.md)

</div>
