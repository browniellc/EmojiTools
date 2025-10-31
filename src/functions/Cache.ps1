function Enable-EmojiAutoUpdate {
    <#
    .SYNOPSIS
        Enables automatic emoji dataset updates.

    .DESCRIPTION
        Configures the module to automatically check for and download
        emoji dataset updates from Unicode CLDR on a scheduled basis.
        Supports Windows, Linux, and macOS.

    .PARAMETER Interval
        Update check interval in days (default: 7)

    .PARAMETER CreateScheduledTask
        Create a platform-specific scheduled task for automatic updates
        - Windows: Task Scheduler
        - Linux: cron job
        - macOS: LaunchAgent

    .EXAMPLE
        Enable-EmojiAutoUpdate
        Enables auto-update checks every 7 days

    .EXAMPLE
        Enable-EmojiAutoUpdate -Interval 14 -CreateScheduledTask
        Enables auto-update every 14 days and creates a scheduled task
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 365)]
        [int]$Interval = 7,

        [Parameter(Mandatory = $false)]
        [switch]$CreateScheduledTask
    )

    # Update module configuration
    $Script:EmojiToolsConfig.AutoUpdateCheck = $true
    $Script:EmojiToolsConfig.UpdateInterval = $Interval

    Write-Host "✅ Auto-update enabled" -ForegroundColor Green
    Write-Host "   Update checks will occur every $Interval days" -ForegroundColor White
    Write-Host "   Source: Unicode CLDR (official)" -ForegroundColor White

    if ($CreateScheduledTask) {
        $platform = Get-EmojiPlatform
        Write-Host "   Platform: $platform" -ForegroundColor White

        $success = New-EmojiScheduledTask -Interval $Interval

        if (-not $success) {
            Write-Host "`n⚠️  You can manually run Update-EmojiDataset periodically" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "`n💡 Tip: Use -CreateScheduledTask to set up automatic background updates" -ForegroundColor Cyan
    }
}

function Disable-EmojiAutoUpdate {
    <#
    .SYNOPSIS
        Disables automatic emoji dataset update checks.

    .DESCRIPTION
        Disables automatic update checks when loading the module.
        Optionally removes the platform-specific scheduled task.

    .PARAMETER RemoveScheduledTask
        Also remove the scheduled task (Windows Task Scheduler, Linux cron, macOS LaunchAgent)

    .EXAMPLE
        Disable-EmojiAutoUpdate
        Disables auto-update checks

    .EXAMPLE
        Disable-EmojiAutoUpdate -RemoveScheduledTask
        Disables auto-update and removes scheduled task
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$RemoveScheduledTask
    )    $Script:EmojiToolsConfig.AutoUpdateCheck = $false

    Write-Host "✅ Auto-update disabled" -ForegroundColor Green
    Write-Host "   No automatic update checks will be performed" -ForegroundColor White

    if ($RemoveScheduledTask) {
        $success = Remove-EmojiScheduledTask

        if (-not $success) {
            Write-Warning "Could not remove scheduled task"
        }
    }
}
