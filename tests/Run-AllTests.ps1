#Requires -Modules Pester

<#
.SYNOPSIS
    Master Pester test runner for all EmojiTools test suites

.DESCRIPTION
    Executes all Pester test suites and provides a comprehensive summary

.PARAMETER Tag
    Run only tests with specific tags (Aliases, Analytics, Search, etc.)

.PARAMETER ExcludeTag
    Exclude tests with specific tags

.PARAMETER Detailed
    Show detailed test output

.PARAMETER CI
    Run in CI mode with appropriate output formatting

.EXAMPLE
    .\Run-AllTests.ps1
    Runs all test suites and displays summary

.EXAMPLE
    .\Run-AllTests.ps1 -Tag Aliases,Analytics
    Runs only Aliases and Analytics tests

.EXAMPLE
    .\Run-AllTests.ps1 -Detailed
    Runs all tests with detailed output

.EXAMPLE
    .\Run-AllTests.ps1 -CI
    Runs in CI mode for automated testing
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string[]]$Tag,

    [Parameter()]
    [string[]]$ExcludeTag,

    [Parameter()]
    [switch]$Detailed,

    [Parameter()]
    [switch]$CI
)

$ErrorActionPreference = 'Stop'

# Display header
Write-Host "`n" -NoNewline
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "🧪 EMOJITOOLS - PESTER TEST SUITE RUNNER" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan

# Ensure Pester is available
Write-Host "`n📦 Checking Pester availability..." -ForegroundColor Yellow
$pesterModule = Get-Module -Name Pester -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1

if (-not $pesterModule) {
    Write-Host "   ❌ Pester module not found!" -ForegroundColor Red
    Write-Host "   Installing Pester..." -ForegroundColor Yellow
    Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser
    $pesterModule = Get-Module -Name Pester -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
}

Write-Host "   ✅ Pester v$($pesterModule.Version) available" -ForegroundColor Green

# Import Pester
Import-Module Pester -MinimumVersion 5.0 -Force

# Get test directory
$testDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load EmojiTools module
Write-Host "`n📦 Loading EmojiTools module..." -ForegroundColor Yellow

# CRITICAL: Remove ALL instances of EmojiTools to avoid conflicts
# This prevents issues when both installed (PSGallery) and dev versions exist
$existingModules = Get-Module EmojiTools -All
if ($existingModules) {
    Write-Host "   ℹ️  Removing $($existingModules.Count) existing module instance(s)..." -ForegroundColor Yellow
    Remove-Module EmojiTools -Force -ErrorAction SilentlyContinue
}

# Check for installed versions that might auto-load
$installedVersions = Get-Module EmojiTools -ListAvailable
if ($installedVersions.Count -gt 1) {
    Write-Host "   ℹ️  Multiple EmojiTools versions found in PSModulePath:" -ForegroundColor Yellow
    foreach ($ver in $installedVersions) {
        $indicator = if ($ver.Path -like "*_brownie*") { " (DEV)" } else { "" }
        Write-Host "      - v$($ver.Version): $($ver.ModuleBase)$indicator" -ForegroundColor Gray
    }
}

# Import the development version explicitly using full path
# Using -Global scope to ensure single instance across all nested contexts
$modulePath = Resolve-Path (Join-Path (Split-Path $testDir -Parent) "src\EmojiTools.psd1")
Write-Host "   📂 Loading from: $modulePath" -ForegroundColor Gray

try {
    # Import with -Global to ensure it's loaded in global scope and accessible to Pester
    Import-Module $modulePath -Force -Global -DisableNameChecking -ErrorAction Stop

    # Verify only ONE instance is loaded
    $loadedModules = @(Get-Module EmojiTools -All)

    if ($loadedModules.Count -eq 0) {
        throw "Failed to load EmojiTools module"
    }
    elseif ($loadedModules.Count -gt 1) {
        Write-Host "   ⚠️  WARNING: $($loadedModules.Count) module instances loaded!" -ForegroundColor Red
        Write-Host "   This may cause 'EmojiTools EmojiTools' errors in tests." -ForegroundColor Red
        Write-Host "   Paths loaded:" -ForegroundColor Yellow
        foreach ($m in $loadedModules) {
            Write-Host "      - $($m.Path)" -ForegroundColor Gray
        }
        Write-Host "   Attempting to remove non-dev instances..." -ForegroundColor Yellow

        # Keep only the dev version
        foreach ($m in $loadedModules) {
            if ($m.Path -notlike "*_brownie*") {
                Remove-Module $m -Force -ErrorAction SilentlyContinue
                Write-Host "      ✓ Removed: $($m.Path)" -ForegroundColor Gray
            }
        }

        $loadedModules = @(Get-Module EmojiTools -All)
    }

    $module = $loadedModules[0]
    Write-Host "   ✅ EmojiTools v$($module.Version) loaded successfully" -ForegroundColor Green
    Write-Host "      Path: $($module.Path)" -ForegroundColor Gray
    Write-Host "      Module count: $($loadedModules.Count)" -ForegroundColor Gray
    Write-Host ""
}
catch {
    Write-Host "   ❌ Failed to load module: $_" -ForegroundColor Red
    exit 1
}

# Configure Pester
$pesterConfig = New-PesterConfiguration

# Set test path
$pesterConfig.Run.Path = $testDir
$pesterConfig.Run.PassThru = $true

# Configure output
if ($Detailed) {
    $pesterConfig.Output.Verbosity = 'Detailed'
}
elseif ($CI) {
    $pesterConfig.Output.Verbosity = 'Minimal'
    $pesterConfig.Output.CIFormat = 'Auto'
}
else {
    $pesterConfig.Output.Verbosity = 'Normal'
}

# Set code coverage if in CI mode
if ($CI) {
    $pesterConfig.CodeCoverage.Enabled = $true
    $pesterConfig.CodeCoverage.Path = Join-Path (Split-Path $testDir -Parent) "src\functions\*.ps1"
}

# Set test file filter to only run *.Tests.ps1 files
$pesterConfig.Run.TestExtension = '.Tests.ps1'

# Configure tags
if ($Tag) {
    $pesterConfig.Filter.Tag = $Tag
    Write-Host "Running tests with tags: $($Tag -join ', ')" -ForegroundColor Cyan
}

if ($ExcludeTag) {
    $pesterConfig.Filter.ExcludeTag = $ExcludeTag
    Write-Host "Excluding tests with tags: $($ExcludeTag -join ', ')" -ForegroundColor Cyan
}

# Run Pester tests
Write-Host "`n🚀 Running Pester tests...`n" -ForegroundColor Yellow

try {
    $result = Invoke-Pester -Configuration $pesterConfig

    # Display summary
    Write-Host "`n" -NoNewline
    Write-Host "=" * 80 -ForegroundColor Cyan
    Write-Host "📊 TEST SUMMARY" -ForegroundColor Cyan
    Write-Host "=" * 80 -ForegroundColor Cyan

    Write-Host "`nTotal Tests:   " -NoNewline
    Write-Host $result.TotalCount -ForegroundColor Cyan

    Write-Host "Passed:        " -NoNewline
    Write-Host $result.PassedCount -ForegroundColor Green

    Write-Host "Failed:        " -NoNewline
    if ($result.FailedCount -gt 0) {
        Write-Host $result.FailedCount -ForegroundColor Red
    }
    else {
        Write-Host $result.FailedCount -ForegroundColor Green
    }

    Write-Host "Skipped:       " -NoNewline
    Write-Host $result.SkippedCount -ForegroundColor Yellow

    Write-Host "Not Run:       " -NoNewline
    Write-Host $result.NotRunCount -ForegroundColor Gray

    if ($result.TotalCount -gt 0) {
        $passRate = [math]::Round(($result.PassedCount / $result.TotalCount) * 100, 1)
        Write-Host "`nPass Rate:     " -NoNewline
        if ($passRate -eq 100) {
            Write-Host "$passRate%" -ForegroundColor Green
        }
        elseif ($passRate -ge 80) {
            Write-Host "$passRate%" -ForegroundColor Yellow
        }
        else {
            Write-Host "$passRate%" -ForegroundColor Red
        }
    }

    if ($result.Duration) {
        Write-Host "Duration:      " -NoNewline
        Write-Host "$($result.Duration.TotalSeconds.ToString('F2')) seconds" -ForegroundColor Cyan
    }

    # Show failed tests if any
    if ($result.FailedCount -gt 0) {
        Write-Host "`n❌ Failed Tests:" -ForegroundColor Red
        $result.Failed | ForEach-Object {
            Write-Host "   - $($_.ExpandedPath)" -ForegroundColor Red
            if ($_.ErrorRecord) {
                Write-Host "     $($_.ErrorRecord.Exception.Message)" -ForegroundColor Yellow
            }
        }
    }

    Write-Host "`n" -NoNewline
    Write-Host "=" * 80 -ForegroundColor Cyan

    if ($result.FailedCount -eq 0) {
        Write-Host "✅ ALL TESTS PASSED! EmojiTools is fully functional." -ForegroundColor Green
    }
    else {
        Write-Host "⚠️  Some tests failed. Review output above for details." -ForegroundColor Yellow
    }

    Write-Host "=" * 80 -ForegroundColor Cyan
    Write-Host ""

    # Exit with appropriate code
    exit $result.FailedCount

}
catch {
    Write-Host "`n❌ CRITICAL ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
    exit 1
}
