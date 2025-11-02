# 🔧 Troubleshooting

Common issues and solutions for EmojiTools.

---

## Installation Issues

### Module Not Found

**Problem:** `Import-Module: The specified module 'EmojiTools' was not loaded`

**Solutions:**

```powershell
# Verify installation
Get-Module -ListAvailable -Name EmojiTools

# If not listed, reinstall
Install-Module -Name EmojiTools -Force

# Check module path
$env:PSModulePath -split ';'
```

### Permission Errors

**Problem:** "Access denied" during installation

**Solutions:**

```powershell
# Install for current user only
Install-Module -Name EmojiTools -Scope CurrentUser

# Or run PowerShell as Administrator
# Right-click → Run as Administrator
Install-Module -Name EmojiTools
```

---

## Dataset Issues

### Dataset Not Found

**Problem:** "Emoji dataset not found" error

**Solution:**

```powershell
# Download the dataset
Update-EmojiDataset -Source Unicode

# Verify dataset exists
Get-EmojiDatasetInfo
```

### Update Fails

**Problem:** Dataset update fails or times out

**Solutions:**

```powershell
# Check internet connection
Test-Connection google.com

# Try alternate source
Update-EmojiDataset -Source GitHub

# Force update
Update-EmojiDataset -Source Unicode -Force

# Check proxy settings
$PSDefaultParameterValues = @{
    '*:Proxy' = 'http://proxy.company.com:8080'
}
```

---

## Search Issues

### No Results Found

**Problem:** Search returns no results

**Solutions:**

```powershell
# Try broader search
Search-Emoji "smile"  # instead of "smiling face"

# Check dataset is loaded
Get-EmojiDatasetInfo

# Clear cache and retry
Clear-EmojiCache
Search-Emoji "rocket"
```

### Slow Searches

**Problem:** Searches take too long

**Solutions:**

```powershell
# Clear and rebuild cache
Clear-EmojiCache

# Limit results
Search-Emoji "heart" -Limit 10

# Check dataset size
Get-EmojiDatasetInfo
```

---

## Picker Issues

### Picker Won't Open

**Problem:** Emoji picker doesn't launch

**Solutions:**

```powershell
# Try different port
Show-EmojiPicker -Port 9000

# Use standalone mode
Show-EmojiPicker -Standalone

# Check default browser
Start-Process "http://localhost:8321"
```

### Copy Not Working

**Problem:** Clicking emojis doesn't copy to clipboard

**Solutions:**

```powershell
# Use standalone mode
Show-EmojiPicker -Standalone

# Test clipboard manually
Copy-Emoji "🚀"
Get-Clipboard

# Check clipboard permissions
```

---

## Collection Issues

### Collection Not Found

**Problem:** "Collection not found" error

**Solutions:**

```powershell
# List all collections
Get-EmojiCollection

# Create if missing
New-EmojiCollection -Name "MyCollection" -Emojis @("🚀","🔥")

# Check exact name (case-sensitive)
Get-EmojiCollection | Select-Object -ExpandProperty Name
```

### Can't Save Collection

**Problem:** "Access denied" saving collection

**Solutions:**

```powershell
# Check data folder permissions
$dataPath = Join-Path $PSScriptRoot "..\data"
Test-Path $dataPath -PathType Container

# Recreate data folder
Initialize-EmojiTools
```

---

## Alias Issues

### Alias Already Exists

**Problem:** "Alias already exists" error

**Solution:**

```powershell
# Overwrite with -Force
New-EmojiAlias -Alias "fire" -Emoji "🔥" -Force

# Or remove first
Remove-EmojiAlias -Alias "fire"
New-EmojiAlias -Alias "fire" -Emoji "🔥"
```

### Invalid Alias Name

**Problem:** "Invalid alias name" error

**Solution:**

```powershell
# Use only alphanumeric and underscores
New-EmojiAlias -Alias "my_emoji" -Emoji "🚀"  # ✅ Valid
New-EmojiAlias -Alias "my-emoji" -Emoji "🚀"  # ❌ Invalid
New-EmojiAlias -Alias "my emoji" -Emoji "🚀"  # ❌ Invalid
```

---

## Automation Issues

### Auto-Update Not Working

**Problem:** Dataset not updating automatically

**Solutions:**

```powershell
# Check if enabled
Get-EmojiDatasetInfo

# Re-enable
Enable-EmojiAutoUpdate -Interval 7

# Force manual update
Update-EmojiDataset -Source Unicode -Force
```

### Scheduled Task Not Running

**Problem:** Scheduled task exists but doesn't run

**Solutions:**

**Windows:**
```powershell
# Check task status
Get-ScheduledTask -TaskName "EmojiTools-AutoUpdate"

# View task info
Get-ScheduledTaskInfo -TaskName "EmojiTools-AutoUpdate"

# Run manually to test
Start-ScheduledTask -TaskName "EmojiTools-AutoUpdate"

# Check task history in Task Scheduler
taskschd.msc
```

**Linux:**
```bash
# Check cron jobs
crontab -l | grep EmojiTools

# View cron logs
grep CRON /var/log/syslog

# Edit cron jobs
crontab -e
```

**macOS:**
```bash
# Check launch agent
launchctl list | grep emojitools

# View agent status
launchctl print gui/$(id -u)/com.emojitools.autoupdate

# Reload agent
launchctl unload ~/Library/LaunchAgents/com.emojitools.autoupdate.plist
launchctl load ~/Library/LaunchAgents/com.emojitools.autoupdate.plist
```

---

## Export Issues

### Export Failed

**Problem:** Export command fails

**Solutions:**

```powershell
# Check output path permissions
Test-Path "C:\Exports" -PathType Container

# Try current directory
Export-Emoji -Format HTML -Collection "Favorites" -OutputPath ".\favs.html"

# Use PassThru to test
$content = Export-Emoji -Format JSON -Collection "Favorites" -PassThru
$content.Length  # Should show content size
```

---

## Performance Issues

### Module Loads Slowly

**Problem:** Module takes long to import

**Solutions:**

```powershell
# Disable auto-update check on load
Disable-EmojiAutoUpdate

# Manually check for updates periodically
Update-EmojiDataset -Source Unicode
```

### High Memory Usage

**Problem:** PowerShell using too much memory

**Solutions:**

```powershell
# Clear cache
Clear-EmojiCache

# Limit search results
Search-Emoji "emoji" -Limit 10

# Use smaller custom dataset
New-EmojiCustomDataset -Name "Small" -Collection "Favorites"
Set-ActiveEmojiDataset -Name "Small"
```

---

## Display Issues

### Emojis Show as Boxes

**Problem:** Emojis display as □ or �

**Solutions:**

1. **Update Windows:**
   - Settings → Update & Security → Windows Update
   - Install latest updates (includes emoji fonts)

2. **Install Emoji Font:**
   - Windows: Segoe UI Emoji (usually included)
   - macOS: Apple Color Emoji (built-in)
   - Linux: Install `fonts-noto-color-emoji`

3. **Terminal Support:**
   ```powershell
   # Use Windows Terminal (better emoji support)
   # Download from Microsoft Store

   # Or use VS Code integrated terminal
   ```

---

## Getting More Help

### Check Version

```powershell
Get-Module -Name EmojiTools | Select-Object Version

# Or
Get-EmojiToolsInfo
```

### Enable Verbose Output

```powershell
# Get detailed operation info
Search-Emoji "rocket" -Verbose
Update-EmojiDataset -Source Unicode -Verbose
```

### Report Issues

If you're still stuck:

1. **Check existing issues:** [GitHub Issues](https://github.com/Tsabo/EmojiTools/issues)
2. **Create new issue:** Include:
   - EmojiTools version
   - PowerShell version (`$PSVersionTable`)
   - Operating system
   - Error message (full text)
   - Steps to reproduce

```powershell
# Gather diagnostic info
@{
    EmojiToolsVersion = (Get-Module EmojiTools).Version
    PowerShellVersion = $PSVersionTable.PSVersion
    OS = $PSVersionTable.OS
    DatasetInfo = Get-EmojiDatasetInfo
} | ConvertTo-Json
```

---

## Common Error Messages

### "The term 'Search-Emoji' is not recognized"

**Cause:** Module not imported

**Fix:**
```powershell
Import-Module EmojiTools
```

### "Cannot bind argument to parameter 'Emoji'"

**Cause:** Invalid emoji character

**Fix:**
```powershell
# Ensure you're passing actual emoji, not text
Copy-Emoji "🚀"  # ✅ Correct
Copy-Emoji "rocket"  # ❌ Wrong
```

### "Access to the path is denied"

**Cause:** Insufficient permissions

**Fix:**
```powershell
# Run as Administrator or use -Scope CurrentUser
Install-Module EmojiTools -Scope CurrentUser
```

---

<div align="center" markdown>

**Still having issues?** Check [GitHub Issues](https://github.com/Tsabo/EmojiTools/issues) or [Command Reference](commands.md)

</div>
