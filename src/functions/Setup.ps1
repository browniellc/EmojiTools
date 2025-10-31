function Initialize-EmojiTools {
    <#
    .SYNOPSIS
        Runs the EmojiTools first-time setup.

    .DESCRIPTION
        Initializes default emoji collections and aliases. This runs automatically on
        first module import, but can be run manually to reset or re-initialize.

    .PARAMETER Force
        Force re-initialization even if setup was already completed

    .PARAMETER SkipCollections
        Skip initializing default collections

    .PARAMETER SkipAliases
        Skip initializing default aliases

    .EXAMPLE
        Initialize-EmojiTools
        Runs the setup process

    .EXAMPLE
        Initialize-EmojiTools -Force
        Re-runs setup and overwrites existing data

    .EXAMPLE
        Initialize-EmojiTools -SkipCollections
        Only initializes aliases, skips collections
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Function initializes the entire module with multiple components, plural is semantically correct')]

    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Force,

        [Parameter()]
        [switch]$SkipCollections,

        [Parameter()]
        [switch]$SkipAliases
    )

    $setupPath = $Script:EmojiToolsConfig.SetupCompletePath

    if ((Test-Path $setupPath) -and -not $Force) {
        Write-Host "✅ EmojiTools is already initialized." -ForegroundColor Green
        Write-Host "   Use -Force to re-initialize and overwrite existing data." -ForegroundColor Yellow
        return
    }

    Write-Host "`n🎉 Initializing EmojiTools..." -ForegroundColor Cyan

    $initialized = @()

    try {
        # Initialize default collections
        if (-not $SkipCollections) {
            if (Get-Command Initialize-EmojiCollections -ErrorAction SilentlyContinue) {
                Write-Host "   📁 Creating default emoji collections..." -ForegroundColor Gray
                Initialize-EmojiCollections -ErrorAction SilentlyContinue
                $initialized += "Collections"
            }
        }
        else {
            Write-Host "   ⏭️  Skipping collections (as requested)" -ForegroundColor Gray
        }

        # Initialize default aliases
        if (-not $SkipAliases) {
            if (Get-Command Initialize-DefaultEmojiAliases -ErrorAction SilentlyContinue) {
                Write-Host "   🔖 Setting up emoji aliases..." -ForegroundColor Gray
                if ($Force) {
                    Initialize-DefaultEmojiAliases -Force -ErrorAction SilentlyContinue
                }
                else {
                    Initialize-DefaultEmojiAliases -ErrorAction SilentlyContinue
                }
                $initialized += "Aliases"
            }
        }
        else {
            Write-Host "   ⏭️  Skipping aliases (as requested)" -ForegroundColor Gray
        }

        # Mark setup as complete
        New-Item -ItemType File -Path $setupPath -Force | Out-Null

        Write-Host "`n✅ Initialization complete!" -ForegroundColor Green
        if ($initialized.Count -gt 0) {
            Write-Host "   Initialized: $($initialized -join ', ')" -ForegroundColor White
        }

        Write-Host "`n💡 Quick Start:" -ForegroundColor Cyan
        Write-Host "   Get-EmojiAlias -List              # View all shortcuts" -ForegroundColor White
        Write-Host "   Get-EmojiAlias -Alias 'fire'      # Get emoji by alias" -ForegroundColor White
        Write-Host "   Get-EmojiCollection                # View collections" -ForegroundColor White
        Write-Host "   Show-EmojiPicker                   # Open interactive picker`n" -ForegroundColor White
    }
    catch {
        Write-Error "Initialization failed: $_"
        Write-Host "`nYou can manually run:" -ForegroundColor Yellow
        Write-Host "   Initialize-EmojiCollections" -ForegroundColor White
        Write-Host "   Initialize-DefaultEmojiAliases" -ForegroundColor White
    }
}

function Reset-EmojiTools {
    <#
    .SYNOPSIS
        Resets EmojiTools to default state.

    .DESCRIPTION
        Removes all custom data (aliases, collections, statistics) and re-initializes
        with defaults. Use with caution as this will delete your customizations.

    .PARAMETER IncludeStats
        Also clear statistics data

    .PARAMETER Force
        Skip confirmation prompt

    .EXAMPLE
        Reset-EmojiTools
        Resets collections and aliases with confirmation

    .EXAMPLE
        Reset-EmojiTools -IncludeStats -Force
        Resets everything including stats without confirmation
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Function resets the entire module with multiple components, plural is semantically correct')]

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter()]
        [switch]$IncludeStats,

        [Parameter()]
        [switch]$Force
    )

    $dataPath = Join-Path $PSScriptRoot "..\data"

    $itemsToRemove = @(
        @{ Path = Join-Path $dataPath "collections.json"; Name = "Collections" }
        @{ Path = Join-Path $dataPath "aliases.json"; Name = "Aliases" }
        @{ Path = $Script:EmojiToolsConfig.SetupCompletePath; Name = "Setup marker" }
    )

    if ($IncludeStats) {
        $itemsToRemove += @{ Path = Join-Path $dataPath "stats.json"; Name = "Statistics" }
    }

    if (-not $Force -and -not $PSCmdlet.ShouldProcess("EmojiTools data", "Reset to defaults")) {
        return
    }

    Write-Host "`n🔄 Resetting EmojiTools..." -ForegroundColor Yellow

    foreach ($item in $itemsToRemove) {
        if (Test-Path $item.Path) {
            try {
                Remove-Item $item.Path -Force
                Write-Host "   ✅ Removed $($item.Name)" -ForegroundColor Gray
            }
            catch {
                Write-Warning "Failed to remove $($item.Name): $_"
            }
        }
    }

    Write-Host "`n🎉 Re-initializing with defaults..." -ForegroundColor Cyan
    Initialize-EmojiTools -Force
}

function Get-EmojiToolsInfo {
    <#
    .SYNOPSIS
        Displays information about the EmojiTools module.

    .DESCRIPTION
        Shows module version, statistics, and status information.

    .EXAMPLE
        Get-EmojiToolsInfo
        Displays module information
    #>

    [CmdletBinding()]
    param()

    $dataPath = Join-Path $PSScriptRoot "..\data"

    # Count data
    $aliasCount = 0
    $aliasPath = Join-Path $dataPath "aliases.json"
    if (Test-Path $aliasPath) {
        $aliases = Get-Content $aliasPath -Encoding UTF8 | ConvertFrom-Json
        $aliasCount = ($aliases.PSObject.Properties | Measure-Object).Count
    }

    $collectionCount = 0
    $collectionPath = Join-Path $dataPath "collections.json"
    if (Test-Path $collectionPath) {
        $collections = Get-Content $collectionPath -Encoding UTF8 | ConvertFrom-Json
        $collectionCount = ($collections.PSObject.Properties | Measure-Object).Count
    }

    $statsExist = Test-Path (Join-Path $dataPath "stats.json")
    $setupComplete = Test-Path $Script:EmojiToolsConfig.SetupCompletePath

    # Get module info
    $module = Get-Module EmojiTools

    Write-Host "`n📊 EmojiTools Module Information" -ForegroundColor Cyan
    Write-Host ("=" * 60) -ForegroundColor Cyan

    Write-Host "`nModule Details:" -ForegroundColor Yellow
    Write-Host ("  Version:           {0}" -f $module.Version) -ForegroundColor White
    Write-Host ("  Exported Functions: {0}" -f $module.ExportedFunctions.Count) -ForegroundColor White
    Write-Host ("  Module Path:       {0}" -f $module.ModuleBase) -ForegroundColor White

    Write-Host "`nData Status:" -ForegroundColor Yellow
    Write-Host ("  Setup Complete:    {0}" -f $(if ($setupComplete) { "✅ Yes" } else { "❌ No" })) -ForegroundColor White
    Write-Host ("  Emojis Loaded:     {0}" -f $Script:EmojiData.Count) -ForegroundColor White
    Write-Host ("  Aliases Defined:   {0}" -f $aliasCount) -ForegroundColor White
    Write-Host ("  Collections:       {0}" -f $collectionCount) -ForegroundColor White
    Write-Host ("  Statistics:        {0}" -f $(if ($statsExist) { "✅ Available" } else { "❌ None" })) -ForegroundColor White

    Write-Host "`nConfiguration:" -ForegroundColor Yellow
    Write-Host ("  Auto-Update Check: {0}" -f $Script:EmojiToolsConfig.AutoUpdateCheck) -ForegroundColor White

    # Display AutoInitialize features
    $autoInitDisplay = if ($Script:EmojiToolsConfig.AutoInitialize.Count -eq 0) {
        "Disabled"
    }
    elseif ($Script:EmojiToolsConfig.AutoInitialize -contains 'All') {
        "All features"
    }
    else {
        $Script:EmojiToolsConfig.AutoInitialize -join ', '
    }
    Write-Host ("  Auto-Initialize:   {0}" -f $autoInitDisplay) -ForegroundColor White
    Write-Host ("  Update Interval:   {0} days" -f $Script:EmojiToolsConfig.UpdateInterval) -ForegroundColor White

    if (Test-Path $Script:EmojiDataPath) {
        $dataAge = (Get-Date) - (Get-Item $Script:EmojiDataPath).LastWriteTime
        Write-Host ("  Dataset Age:       {0} days" -f [math]::Round($dataAge.TotalDays, 1)) -ForegroundColor White
    }

    Write-Host "`n💡 Quick Commands:" -ForegroundColor Cyan
    Write-Host "  Get-EmojiAlias -List         # View all aliases" -ForegroundColor Gray
    Write-Host "  Get-EmojiCollection          # View collections" -ForegroundColor Gray
    Write-Host "  Get-EmojiStats               # View usage stats" -ForegroundColor Gray
    Write-Host "  Show-EmojiPicker             # Open picker" -ForegroundColor Gray
    Write-Host "  Initialize-EmojiTools -Force # Re-initialize" -ForegroundColor Gray
    Write-Host "`n"
}

