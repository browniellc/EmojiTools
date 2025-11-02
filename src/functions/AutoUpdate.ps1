function Enable-EmojiAutoUpdate {
    <#
    .SYNOPSIS
        Enables automatic emoji dataset updates.

    .DESCRIPTION
        Configures the module to automatically check for and download
        emoji dataset updates from Unicode CLDR on a scheduled basis.

    .PARAMETER Interval
        Update check interval in days (default: 7)

    .PARAMETER CreateScheduledTask
        Create a Windows scheduled task for automatic updates (requires admin)

    .EXAMPLE
        Enable-EmojiAutoUpdate
        Enables auto-update checks every 7 days

    .EXAMPLE
        Enable-EmojiAutoUpdate -Interval 14 -CreateScheduledTask
        Enables auto-update every 14 days and creates a scheduled task
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [int]$Interval = 7,

        [Parameter(Mandatory = $false)]
        [switch]$CreateScheduledTask
    )

    # Update module configuration
    $Script:EmojiToolsConfig.AutoUpdateCheck = $true
    $Script:EmojiToolsConfig.UpdateInterval = $Interval

    Write-Information "✅ Auto-update enabled" -InformationAction Continue
    Write-Information "   Update checks will occur every $Interval days" -InformationAction Continue
    Write-Information "   Source: Unicode CLDR (official)" -InformationAction Continue    if ($CreateScheduledTask) {
        try {
            # Create scheduled task (Windows only)
            if ($PSVersionTable.PSVersion.Major -ge 5 -and $IsWindows -ne $false) {
                $taskName = "EmojiTools-AutoUpdate"
                $taskDescription = "Automatically updates emoji dataset from Unicode CLDR"

                $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument `
                    "-NoProfile -WindowStyle Hidden -Command `"Import-Module EmojiTools; Update-EmojiDataset -Source Unicode -Silent`""

                $trigger = New-ScheduledTaskTrigger -Daily -At "03:00AM" -DaysInterval $Interval

                $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
                    -StartWhenAvailable -RunOnlyIfNetworkAvailable

                Register-ScheduledTask -TaskName $taskName -Description $taskDescription `
                    -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null

                Write-Information "`n✅ Scheduled task created: $taskName" -InformationAction Continue
                Write-Information "   Runs daily at 3:00 AM (every $Interval days)" -InformationAction Continue
                Write-Information "   View with: Get-ScheduledTask -TaskName '$taskName'" -InformationAction Continue
            }
            else {
                Write-Warning "Scheduled tasks are only supported on Windows"
            }
        }
        catch {
            Write-Warning "Failed to create scheduled task: $_"
            Write-Warning "You can manually run Update-EmojiDataset periodically"
        }
    }
    else {
        Write-Information "`n💡 Tip: Use -CreateScheduledTask to set up automatic background updates" -InformationAction Continue
    }
}

function Disable-EmojiAutoUpdate {
    <#
    .SYNOPSIS
        Disables automatic emoji dataset update checks.

    .DESCRIPTION
        Disables automatic update checks when loading the module.
        Does not remove scheduled tasks if created.

    .PARAMETER RemoveScheduledTask
        Also remove the Windows scheduled task if it exists

    .EXAMPLE
        Disable-EmojiAutoUpdate
        Disables auto-update checks

    .EXAMPLE
        Disable-EmojiAutoUpdate -RemoveScheduledTask
        Disables auto-update and removes scheduled task
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$RemoveScheduledTask
    )

    $Script:EmojiToolsConfig.AutoUpdateCheck = $false

    Write-Information "✅ Auto-update disabled" -InformationAction Continue
    Write-Information "   No automatic update checks will be performed" -InformationAction Continue

    if ($RemoveScheduledTask) {
        try {
            $taskName = "EmojiTools-AutoUpdate"
            if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
                Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
                Write-Information "✅ Removed scheduled task: $taskName" -InformationAction Continue
            }
            else {
                Write-Information "ℹ️  No scheduled task found" -InformationAction Continue
            }
        }
        catch {
            Write-Warning "Could not remove scheduled task: $_"
        }
    }
}
