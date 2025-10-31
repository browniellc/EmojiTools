# Cross-Platform Scheduled Task Support for EmojiTools

function Get-EmojiPlatform {
    <#
    .SYNOPSIS
        Detects the current operating system platform.

    .DESCRIPTION
        Returns 'Windows', 'Linux', or 'macOS' based on the current platform.
        Used internally for cross-platform scheduled task support.

    .OUTPUTS
        String - Platform name

    .EXAMPLE
        Get-EmojiPlatform
        Returns: Windows
    #>

    if ($PSVersionTable.PSVersion.Major -ge 6) {
        # PowerShell Core 6+ has $IsWindows, $IsLinux, $IsMacOS
        if ($IsWindows) { return 'Windows' }
        if ($IsLinux) { return 'Linux' }
        if ($IsMacOS) { return 'macOS' }
    }
    else {
        # PowerShell 5.1 and earlier are Windows-only
        return 'Windows'
    }

    # Fallback
    if ($env:OS -match 'Windows') { return 'Windows' }
    if (Test-Path '/proc/version') { return 'Linux' }
    if (Test-Path '/System/Library/CoreServices/SystemVersion.plist') { return 'macOS' }

    return 'Unknown'
}


function Get-PowerShellPath {
    <#
    .SYNOPSIS
        Gets the full path to the PowerShell executable.

    .DESCRIPTION
        Returns the path to pwsh or powershell.exe based on the current environment.
        Handles different installation locations across platforms.

    .OUTPUTS
        String - Full path to PowerShell executable
    #>

    # Try to get current PowerShell executable
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        # PowerShell Core - try to find pwsh
        $pwshPath = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
        if ($pwshPath) { return $pwshPath }

        # Common locations
        $commonPaths = @(
            '/usr/bin/pwsh'
            '/usr/local/bin/pwsh'
            'C:\Program Files\PowerShell\7\pwsh.exe'
            "$env:ProgramFiles\PowerShell\7\pwsh.exe"
        )

        foreach ($path in $commonPaths) {
            if (Test-Path $path) { return $path }
        }
    }
    else {
        # PowerShell 5.1 - Windows only
        return 'PowerShell.exe'
    }

    # Last resort - use what launched us
    return $PSHOME + [IO.Path]::DirectorySeparatorChar + 'pwsh'
}


function New-EmojiScheduledTask {
    <#
    .SYNOPSIS
        Creates a cross-platform scheduled task for automatic emoji updates.

    .DESCRIPTION
        Creates a platform-specific scheduled task that runs Update-EmojiDataset
        at the specified interval. Supports Windows Task Scheduler, Linux cron,
        and macOS launchd.

    .PARAMETER Interval
        Update interval in days (default: 7)

    .PARAMETER Silent
        Suppress output messages

    .OUTPUTS
        Boolean - True if task was created successfully

    .EXAMPLE
        New-EmojiScheduledTask -Interval 7
        Creates a task to update emojis every 7 days

    .EXAMPLE
        New-EmojiScheduledTask -Interval 14
        Creates a task to update emojis every 14 days
    #>

    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 365)]
        [int]$Interval = 7,

        [Parameter(Mandatory = $false)]
        [switch]$Silent
    )

    $platform = Get-EmojiPlatform

    if (-not $Silent) {
        Write-Verbose "Platform detected: $platform"
    }

    try {
        switch ($platform) {
            'Windows' {
                return New-WindowsScheduledTask -Interval $Interval -Silent:$Silent
            }
            'Linux' {
                return New-LinuxCronJob -Interval $Interval -Silent:$Silent
            }
            'macOS' {
                return New-MacOSLaunchAgent -Interval $Interval -Silent:$Silent
            }
            default {
                Write-Error "Unsupported platform: $platform"
                return $false
            }
        }
    }
    catch {
        Write-Error "Failed to create scheduled task: $_"
        return $false
    }
}


function Remove-EmojiScheduledTask {
    <#
    .SYNOPSIS
        Removes the emoji auto-update scheduled task.

    .DESCRIPTION
        Removes the platform-specific scheduled task created by New-EmojiScheduledTask.
        Supports Windows Task Scheduler, Linux cron, and macOS launchd.

    .PARAMETER Silent
        Suppress output messages

    .OUTPUTS
        Boolean - True if task was removed successfully or didn't exist

    .EXAMPLE
        Remove-EmojiScheduledTask
        Removes the scheduled task for the current platform
    #>

    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$Silent
    )

    $platform = Get-EmojiPlatform

    try {
        switch ($platform) {
            'Windows' {
                return Remove-WindowsScheduledTask -Silent:$Silent
            }
            'Linux' {
                return Remove-LinuxCronJob -Silent:$Silent
            }
            'macOS' {
                return Remove-MacOSLaunchAgent -Silent:$Silent
            }
            default {
                Write-Error "Unsupported platform: $platform"
                return $false
            }
        }
    }
    catch {
        Write-Error "Failed to remove scheduled task: $_"
        return $false
    }
}


function Test-EmojiScheduledTask {
    <#
    .SYNOPSIS
        Checks if an emoji auto-update scheduled task exists.

    .DESCRIPTION
        Verifies whether a scheduled task for emoji updates is currently configured
        on the system. Platform-aware.

    .OUTPUTS
        Boolean - True if task exists

    .EXAMPLE
        Test-EmojiScheduledTask
        Returns True if a task is configured
    #>

    [CmdletBinding()]
    [OutputType([bool])]
    param()

    $platform = Get-EmojiPlatform

    try {
        switch ($platform) {
            'Windows' {
                return Test-WindowsScheduledTask
            }
            'Linux' {
                return Test-LinuxCronJob
            }
            'macOS' {
                return Test-MacOSLaunchAgent
            }
            default {
                return $false
            }
        }
    }
    catch {
        return $false
    }
}


#region Windows Implementation

function New-WindowsScheduledTask {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [int]$Interval = 7,
        [switch]$Silent
    )

    $taskName = "EmojiTools-AutoUpdate"
    $taskDescription = "Automatically updates emoji dataset from Unicode CLDR every $Interval days"

    if (-not $PSCmdlet.ShouldProcess($taskName, "Create scheduled task")) {
        return $false
    }

    try {
        $pwshPath = Get-PowerShellPath

        $action = New-ScheduledTaskAction -Execute $pwshPath -Argument `
            "-NoProfile -WindowStyle Hidden -Command `"Import-Module EmojiTools; Update-EmojiDataset -Source Unicode -Silent`""

        $trigger = New-ScheduledTaskTrigger -Daily -At "03:00AM" -DaysInterval $Interval

        $settings = New-ScheduledTaskSettingsSet `
            -AllowStartIfOnBatteries `
            -DontStopIfGoingOnBatteries `
            -StartWhenAvailable `
            -RunOnlyIfNetworkAvailable

        Register-ScheduledTask -TaskName $taskName `
            -Description $taskDescription `
            -Action $action `
            -Trigger $trigger `
            -Settings $settings `
            -Force | Out-Null

        if (-not $Silent) {
            Write-Host "✅ Scheduled task created: $taskName" -ForegroundColor Green
            Write-Host "   Runs daily at 3:00 AM (every $Interval days)" -ForegroundColor White
            Write-Host "   View with: Get-ScheduledTask -TaskName '$taskName'" -ForegroundColor Cyan
        }

        return $true
    }
    catch {
        if (-not $Silent) {
            Write-Warning "Failed to create Windows scheduled task: $_"
        }
        return $false
    }
}


function Remove-WindowsScheduledTask {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param([switch]$Silent)

    $taskName = "EmojiTools-AutoUpdate"

    if (-not $PSCmdlet.ShouldProcess($taskName, "Remove scheduled task")) {
        return $false
    }

    try {
        $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if ($task) {
            Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
            if (-not $Silent) {
                Write-Host "✅ Removed scheduled task: $taskName" -ForegroundColor Green
            }
            return $true
        }
        else {
            if (-not $Silent) {
                Write-Host "ℹ️  No scheduled task found" -ForegroundColor Yellow
            }
            return $true
        }
    }
    catch {
        if (-not $Silent) {
            Write-Warning "Failed to remove Windows scheduled task: $_"
        }
        return $false
    }
}


function Test-WindowsScheduledTask {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    try {
        $task = Get-ScheduledTask -TaskName "EmojiTools-AutoUpdate" -ErrorAction SilentlyContinue
        return ($null -ne $task)
    }
    catch {
        return $false
    }
}

#endregion


#region Linux Implementation

function New-LinuxCronJob {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [int]$Interval = 7,
        [switch]$Silent
    )

    if (-not $PSCmdlet.ShouldProcess("crontab", "Add EmojiTools auto-update job")) {
        return $false
    }

    try {
        $pwshPath = Get-PowerShellPath

        # Build cron schedule expression
        # For daily at 3 AM: 0 3 */N * *
        # N = interval in days
        $cronSchedule = "0 3 */$Interval * *"

        # Command to run
        $command = "$pwshPath -NoProfile -Command 'Import-Module EmojiTools; Update-EmojiDataset -Source Unicode -Silent'"

        # Full cron entry with comment for identification
        $cronEntry = "$cronSchedule $command # EmojiTools-AutoUpdate"

        # Get current crontab (may be empty)
        $currentCrontab = & crontab -l 2>$null

        # Check if our job already exists
        if ($currentCrontab -match 'EmojiTools-AutoUpdate') {
            # Remove existing entry
            $currentCrontab = $currentCrontab | Where-Object { $_ -notmatch 'EmojiTools-AutoUpdate' }
        }

        # Add our new entry
        $newCrontab = if ($currentCrontab) {
            @($currentCrontab) + $cronEntry
        }
        else {
            @($cronEntry)
        }

        # Write to crontab
        $newCrontab | & crontab -

        if (-not $Silent) {
            Write-Host "✅ Cron job created: EmojiTools-AutoUpdate" -ForegroundColor Green
            Write-Host "   Schedule: Daily at 3:00 AM (every $Interval days)" -ForegroundColor White
            Write-Host "   View with: crontab -l | grep EmojiTools" -ForegroundColor Cyan
        }

        return $true
    }
    catch {
        if (-not $Silent) {
            Write-Warning "Failed to create Linux cron job: $_"
            Write-Host "   You may need to install cron or have proper permissions" -ForegroundColor Yellow
        }
        return $false
    }
}


function Remove-LinuxCronJob {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param([switch]$Silent)

    if (-not $PSCmdlet.ShouldProcess("crontab", "Remove EmojiTools auto-update job")) {
        return $false
    }

    try {
        # Get current crontab
        $currentCrontab = & crontab -l 2>$null

        if ($currentCrontab -match 'EmojiTools-AutoUpdate') {
            # Remove our entry
            $newCrontab = $currentCrontab | Where-Object { $_ -notmatch 'EmojiTools-AutoUpdate' }

            if ($newCrontab) {
                $newCrontab | & crontab -
            }
            else {
                # Empty crontab - remove it entirely
                & crontab -r 2>$null
            }

            if (-not $Silent) {
                Write-Host "✅ Removed cron job: EmojiTools-AutoUpdate" -ForegroundColor Green
            }
            return $true
        }
        else {
            if (-not $Silent) {
                Write-Host "ℹ️  No cron job found" -ForegroundColor Yellow
            }
            return $true
        }
    }
    catch {
        if (-not $Silent) {
            Write-Warning "Failed to remove Linux cron job: $_"
        }
        return $false
    }
}


function Test-LinuxCronJob {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    try {
        $currentCrontab = & crontab -l 2>$null
        if ($null -eq $currentCrontab) {
            return $false
        }
        return ($currentCrontab -match 'EmojiTools-AutoUpdate')
    }
    catch {
        return $false
    }
}

#endregion


#region macOS Implementation

function New-MacOSLaunchAgent {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [int]$Interval = 7,
        [switch]$Silent
    )

    $agentName = "com.emojitools.autoupdate"
    $agentPath = "$env:HOME/Library/LaunchAgents/$agentName.plist"

    if (-not $PSCmdlet.ShouldProcess($agentPath, "Create LaunchAgent")) {
        return $false
    }

    try {
        # Ensure LaunchAgents directory exists
        $agentDir = "$env:HOME/Library/LaunchAgents"
        if (-not (Test-Path $agentDir)) {
            New-Item -ItemType Directory -Path $agentDir -Force | Out-Null
        }

        $pwshPath = Get-PowerShellPath
        $intervalSeconds = $Interval * 86400  # Convert days to seconds

        # Generate plist XML
        $plistContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$agentName</string>
    <key>ProgramArguments</key>
    <array>
        <string>$pwshPath</string>
        <string>-NoProfile</string>
        <string>-Command</string>
        <string>Import-Module EmojiTools; Update-EmojiDataset -Source Unicode -Silent</string>
    </array>
    <key>StartInterval</key>
    <integer>$intervalSeconds</integer>
    <key>RunAtLoad</key>
    <false/>
    <key>StandardOutPath</key>
    <string>$env:HOME/Library/Logs/EmojiTools-AutoUpdate.log</string>
    <key>StandardErrorPath</key>
    <string>$env:HOME/Library/Logs/EmojiTools-AutoUpdate.error.log</string>
</dict>
</plist>
"@

        # Write plist file
        $plistContent | Out-File -FilePath $agentPath -Encoding UTF8

        # Load the agent
        & launchctl load $agentPath 2>$null

        if (-not $Silent) {
            Write-Host "✅ LaunchAgent created: $agentName" -ForegroundColor Green
            Write-Host "   Runs every $Interval days" -ForegroundColor White
            Write-Host "   Config: $agentPath" -ForegroundColor Cyan
            Write-Host "   Logs: ~/Library/Logs/EmojiTools-AutoUpdate.log" -ForegroundColor Cyan
        }

        return $true
    }
    catch {
        if (-not $Silent) {
            Write-Warning "Failed to create macOS LaunchAgent: $_"
        }
        return $false
    }
}


function Remove-MacOSLaunchAgent {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param([switch]$Silent)

    $agentName = "com.emojitools.autoupdate"
    $agentPath = "$env:HOME/Library/LaunchAgents/$agentName.plist"

    if (-not $PSCmdlet.ShouldProcess($agentPath, "Remove LaunchAgent")) {
        return $false
    }

    try {
        if (Test-Path $agentPath) {
            # Unload the agent
            & launchctl unload $agentPath 2>$null

            # Remove the plist file
            Remove-Item $agentPath -Force

            if (-not $Silent) {
                Write-Host "✅ Removed LaunchAgent: $agentName" -ForegroundColor Green
            }
            return $true
        }
        else {
            if (-not $Silent) {
                Write-Host "ℹ️  No LaunchAgent found" -ForegroundColor Yellow
            }
            return $true
        }
    }
    catch {
        if (-not $Silent) {
            Write-Warning "Failed to remove macOS LaunchAgent: $_"
        }
        return $false
    }
}


function Test-MacOSLaunchAgent {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    $agentPath = "$env:HOME/Library/LaunchAgents/com.emojitools.autoupdate.plist"
    return (Test-Path $agentPath)
}

#endregion
