# Cross-Platform Scheduled Tasks Guide

## 📋 Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [Platform-Specific Details](#platform-specific-details)
   - [Windows (Task Scheduler)](#windows-task-scheduler)
   - [Linux (cron)](#linux-cron)
   - [macOS (LaunchAgent)](#macos-launchagent)
4. [Advanced Usage](#advanced-usage)
5. [Best Practices](#best-practices)
6. [Troubleshooting](#troubleshooting)
7. [Examples](#examples)
8. [FAQ](#faq)
9. [Platform Detection](#platform-detection)
10. [Related Commands](#related-commands)
11. [See Also](#see-also)

---

Automate emoji dataset updates with platform-specific scheduled tasks on Windows, Linux, and macOS.

## Overview

EmojiTools provides cross-platform support for scheduling automatic emoji dataset updates:

- **Windows**: Task Scheduler
- **Linux**: cron jobs
- **macOS**: LaunchAgent (launchd)

The platform-specific implementation is handled automatically based on your operating system.

## Quick Start

### Enable Auto-Update with Scheduled Task

```powershell
# Create a scheduled task that updates emojis every 7 days
Enable-EmojiAutoUpdate -CreateScheduledTask -Interval 7
```

### Check if Task Exists

```powershell
# Returns True if a scheduled task is configured
Test-EmojiScheduledTask
```

### Remove Scheduled Task

```powershell
# Disable auto-update and remove the scheduled task
Disable-EmojiAutoUpdate -RemoveScheduledTask
```

## Platform-Specific Details

### Windows (Task Scheduler)

**How it works:**
- Creates a scheduled task named `EmojiTools-AutoUpdate`
- Runs daily at 3:00 AM
- Repeats every N days based on your interval
- Uses `powershell.exe` or `pwsh.exe` to execute the update

**Requirements:**
- Windows 10 or later
- PowerShell 5.1 or PowerShell 7+
- Administrator privileges (for task creation)

**Manual Management:**

```powershell
# View the task
Get-ScheduledTask -TaskName "EmojiTools-AutoUpdate"

# Manually run the task
Start-ScheduledTask -TaskName "EmojiTools-AutoUpdate"

# Check task history
Get-ScheduledTaskInfo -TaskName "EmojiTools-AutoUpdate"

# Remove manually
Unregister-ScheduledTask -TaskName "EmojiTools-AutoUpdate" -Confirm:$false
```

**Task Configuration:**
- **Trigger**: Daily at 3:00 AM, every N days
- **Action**: `pwsh -NoProfile -Command "Import-Module EmojiTools; Update-EmojiDataset -Source Unicode -Silent"`
- **Settings**:
  - Allow task to run on batteries
  - Start task even if on battery power
  - Wake computer to run task: No
  - Run whether user is logged on or not: Yes

**Troubleshooting:**

1. **"Access Denied" errors**: Run PowerShell as Administrator
2. **Task not running**: Check Task Scheduler → Task Scheduler Library → Look for "EmojiTools-AutoUpdate"
3. **Execution errors**: Check Last Run Result in Task Scheduler (0x0 = Success)

### Linux (cron)

**How it works:**
- Creates a cron job in the user's crontab
- Runs at 3:00 AM on the specified interval
- Marked with `# EmojiTools-AutoUpdate` comment for identification

**Requirements:**
- Linux with cron daemon (cron, cronie, or systemd-timer)
- PowerShell 7+ (`pwsh`)
- User permissions to edit crontab

**Manual Management:**

```bash
# View current crontab
crontab -l

# Edit crontab manually
crontab -e

# Remove EmojiTools entry
crontab -l | grep -v "EmojiTools-AutoUpdate" | crontab -
```

**Cron Schedule Examples:**

```bash
# Every 7 days at 3:00 AM
0 3 */7 * * pwsh -NoProfile -Command 'Import-Module EmojiTools; Update-EmojiDataset -Source Unicode -Silent' # EmojiTools-AutoUpdate

# Every 14 days at 3:00 AM
0 3 */14 * * pwsh -NoProfile -Command 'Import-Module EmojiTools; Update-EmojiDataset -Source Unicode -Silent' # EmojiTools-AutoUpdate

# Every 30 days at 3:00 AM
0 3 */30 * * pwsh -NoProfile -Command 'Import-Module EmojiTools; Update-EmojiDataset -Source Unicode -Silent' # EmojiTools-AutoUpdate
```

**Troubleshooting:**

1. **Cron job not running**: Check cron daemon status
   ```bash
   systemctl status cron  # Debian/Ubuntu
   systemctl status crond # RHEL/CentOS
   ```

2. **PowerShell not found**: Ensure `pwsh` is in PATH
   ```bash
   which pwsh
   # If not found, install PowerShell 7+
   ```

3. **Module not found**: Check module installation path
   ```powershell
   $env:PSModulePath -split ':'
   ```

4. **Check cron logs**:
   ```bash
   # Debian/Ubuntu
   grep CRON /var/log/syslog

   # RHEL/CentOS
   grep CRON /var/log/cron
   ```

5. **Test manually**:
   ```bash
   pwsh -NoProfile -Command 'Import-Module EmojiTools; Update-EmojiDataset -Source Unicode -Silent'
   ```

### macOS (LaunchAgent)

**How it works:**
- Creates a LaunchAgent plist file in `~/Library/LaunchAgents/`
- File name: `com.emojitools.autoupdate.plist`
- Uses `StartInterval` to run every N days (converted to seconds)
- Logs output to `~/Library/Logs/EmojiTools/`

**Requirements:**
- macOS 10.10 or later
- PowerShell 7+ (`pwsh`)
- User permissions to create LaunchAgents

**Manual Management:**

```bash
# Load the agent
launchctl load ~/Library/LaunchAgents/com.emojitools.autoupdate.plist

# Unload the agent
launchctl unload ~/Library/LaunchAgents/com.emojitools.autoupdate.plist

# List loaded agents
launchctl list | grep emojitools

# View the plist file
cat ~/Library/LaunchAgents/com.emojitools.autoupdate.plist

# Remove manually
rm ~/Library/LaunchAgents/com.emojitools.autoupdate.plist
```

**LaunchAgent Configuration:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.emojitools.autoupdate</string>

    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/pwsh</string>
        <string>-NoProfile</string>
        <string>-Command</string>
        <string>Import-Module EmojiTools; Update-EmojiDataset -Source Unicode -Silent</string>
    </array>

    <key>StartInterval</key>
    <integer>604800</integer> <!-- 7 days in seconds -->

    <key>StandardOutPath</key>
    <string>/Users/username/Library/Logs/EmojiTools/autoupdate.log</string>

    <key>StandardErrorPath</key>
    <string>/Users/username/Library/Logs/EmojiTools/autoupdate-error.log</string>
</dict>
</plist>
```

**Interval Conversion:**
- 1 day = 86,400 seconds
- 7 days = 604,800 seconds
- 14 days = 1,209,600 seconds
- 30 days = 2,592,000 seconds

**Troubleshooting:**

1. **Agent not loaded**: Check if plist exists
   ```bash
   ls -la ~/Library/LaunchAgents/com.emojitools.autoupdate.plist
   ```

2. **PowerShell path issues**: Verify `pwsh` location
   ```bash
   which pwsh
   # Common locations:
   # /usr/local/bin/pwsh
   # /opt/homebrew/bin/pwsh (Apple Silicon)
   ```

3. **Check logs**:
   ```bash
   # Standard output
   cat ~/Library/Logs/EmojiTools/autoupdate.log

   # Error output
   cat ~/Library/Logs/EmojiTools/autoupdate-error.log
   ```

4. **Agent status**:
   ```bash
   launchctl list | grep com.emojitools.autoupdate
   ```

5. **Force run immediately** (for testing):
   ```bash
   launchctl start com.emojitools.autoupdate
   ```

6. **Permissions**: Ensure LaunchAgents directory exists
   ```bash
   mkdir -p ~/Library/LaunchAgents
   mkdir -p ~/Library/Logs/EmojiTools
   ```

## Advanced Usage

### Create Task with Custom Interval

```powershell
# Update every 14 days
New-EmojiScheduledTask -Interval 14

# Update every 30 days
New-EmojiScheduledTask -Interval 30

# Update daily
New-EmojiScheduledTask -Interval 1
```

### Silent Task Creation

```powershell
# Create task without output messages
New-EmojiScheduledTask -Interval 7 -Silent
```

### Test Before Creating (-WhatIf)

```powershell
# Preview what will happen without creating the task
New-EmojiScheduledTask -Interval 7 -WhatIf
```

### Verify Task Configuration

```powershell
# Check if task exists
if (Test-EmojiScheduledTask) {
    Write-Host "✅ Scheduled task is configured"
}
else {
    Write-Host "❌ No scheduled task found"
}
```

### Recreate Task with New Interval

```powershell
# Remove old task and create new one
Remove-EmojiScheduledTask
New-EmojiScheduledTask -Interval 14
```

## Best Practices

### Choosing an Update Interval

- **Daily (1 day)**: For critical applications requiring latest emojis
- **Weekly (7 days)**: Recommended for most users - balances freshness with resource usage
- **Bi-weekly (14 days)**: Good for stable environments
- **Monthly (30 days)**: For low-priority systems or bandwidth-constrained environments

### Security Considerations

#### Windows
- Task runs with user credentials
- Requires admin rights to create task
- Consider using Group Policy for enterprise deployment

#### Linux
- Cron job runs as the user who created it
- Ensure `pwsh` has appropriate permissions
- Consider using `/etc/cron.d/` for system-wide deployment (requires root)

#### macOS
- LaunchAgent runs in user context
- No admin rights required
- Logs stored in user directory for privacy

### Performance Tips

1. **Schedule during off-hours**: Default 3:00 AM is ideal
2. **Use `-Silent` flag**: Reduces logging overhead
3. **Monitor resource usage**: Check logs for issues
4. **Test manually first**: Ensure update works before scheduling

```powershell
# Test update manually
Update-EmojiDataset -Source Unicode -Verbose
```

## Troubleshooting

### Common Issues

#### Task Not Running

**Windows:**
```powershell
# Check task exists
Get-ScheduledTask -TaskName "EmojiTools-AutoUpdate"

# Check last run time
(Get-ScheduledTaskInfo -TaskName "EmojiTools-AutoUpdate").LastRunTime

# Check next run time
(Get-ScheduledTaskInfo -TaskName "EmojiTools-AutoUpdate").NextRunTime
```

**Linux:**
```bash
# Check cron service
systemctl status cron

# View cron logs
journalctl -u cron -f

# Test command manually
pwsh -NoProfile -Command 'Import-Module EmojiTools; Update-EmojiDataset -Source Unicode -Verbose'
```

**macOS:**
```bash
# Check if agent is loaded
launchctl list | grep emojitools

# View logs
tail -f ~/Library/Logs/EmojiTools/autoupdate.log
tail -f ~/Library/Logs/EmojiTools/autoupdate-error.log
```

#### Module Not Found

```powershell
# Verify module is installed
Get-Module -ListAvailable EmojiTools

# Check module path
$env:PSModulePath

# Install module if missing
Install-Module EmojiTools -Scope CurrentUser
```

#### Permission Errors

**Windows:**
- Run PowerShell as Administrator
- Check User Account Control (UAC) settings
- Verify user has rights to create scheduled tasks

**Linux:**
- Ensure user can edit crontab: `crontab -e`
- Check cron permissions: `ls -la /var/spool/cron/`
- Verify SELinux/AppArmor settings if applicable

**macOS:**
- Verify LaunchAgents directory permissions
- Check System Preferences → Security & Privacy
- Ensure Full Disk Access for Terminal/PowerShell if needed

### Getting Help

```powershell
# View function help
Get-Help New-EmojiScheduledTask -Full
Get-Help Remove-EmojiScheduledTask -Full
Get-Help Test-EmojiScheduledTask -Full

# Check module version
Get-Module EmojiTools | Select-Object Name, Version

# View all scheduled task functions
Get-Command -Module EmojiTools -Name *ScheduledTask*
```

## Examples

### Scenario 1: Set up automatic weekly updates

```powershell
# Enable auto-update with weekly scheduled task
Enable-EmojiAutoUpdate -CreateScheduledTask -Interval 7

# Verify configuration
Test-EmojiScheduledTask  # Should return True
```

### Scenario 2: Change update frequency

```powershell
# Change from weekly to monthly
Remove-EmojiScheduledTask
New-EmojiScheduledTask -Interval 30
```

### Scenario 3: Temporarily disable auto-update

```powershell
# Disable without removing task
Disable-EmojiAutoUpdate

# Re-enable later
Enable-EmojiAutoUpdate
```

### Scenario 4: Complete cleanup

```powershell
# Remove everything
Disable-EmojiAutoUpdate -RemoveScheduledTask

# Verify removal
Test-EmojiScheduledTask  # Should return False
```

### Scenario 5: Enterprise deployment (Windows)

```powershell
# Create GPO script for domain deployment
$script = @"
Import-Module EmojiTools
New-EmojiScheduledTask -Interval 14 -Silent
"@

# Deploy via Group Policy → Computer Configuration → Scripts → Startup
```

## FAQ

**Q: Why 3:00 AM?**
A: This is a standard maintenance window when system usage is typically low. The task won't wake the computer if it's asleep.

**Q: Can I change the time?**
A: Yes, but you'll need to modify the task manually using platform-specific tools (Task Scheduler, crontab -e, or edit the plist file).

**Q: Will it update if my computer is off?**
A: No. The task runs only when the computer is on. Next run will occur at the next scheduled time.

**Q: Does it require internet?**
A: Yes. The update downloads from Unicode CLDR, which requires an active internet connection.

**Q: Can I run multiple tasks with different intervals?**
A: No. Only one EmojiTools scheduled task can exist at a time. Creating a new task removes the old one.

**Q: How do I update to a specific language?**
A: The scheduled task uses Unicode CLDR (English). For other languages, manually run:
```powershell
Update-EmojiDataset -Source Unicode
Set-EmojiLanguage -Language fr  # Or your preferred language
```

## Platform Detection

EmojiTools automatically detects your platform:

```powershell
# Check detected platform
Get-EmojiPlatform

# Returns: 'Windows', 'Linux', or 'macOS'
```

This ensures the correct implementation is used for scheduled task management.

## Related Commands

- `Enable-EmojiAutoUpdate` - Enable automatic update checks
- `Disable-EmojiAutoUpdate` - Disable automatic update checks
- `Update-EmojiDataset` - Manually update emoji dataset
- `Get-EmojiDatasetInfo` - View current dataset information

## See Also

- [Setup Guide](SETUP_GUIDE.md)
- [Auto-Update Guide](AUTO_UPDATE_GUIDE.md)
- [Quick Start Guide](QUICKSTART.md)
