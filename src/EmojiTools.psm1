# EmojiTools Module
# Main module file that loads the emoji dataset and functions

$ModulePath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Configuration (Script-scoped - accessible to all functions in the module)
$Script:EmojiToolsConfig = @{
    AutoUpdateCheck = $true  # Set to $false to disable auto-update checks
    UpdateInterval = 7       # Days between update checks
    # AutoInitialize features: 'Collections', 'Aliases', 'All', or empty array to disable
    # Remove items from array to skip specific features
    AutoInitialize = @('Collections', 'Aliases')  # Set to @() to disable auto-initialization
    DataPath = Join-Path $ModulePath "data\emoji.csv"
    MetadataPath = Join-Path $ModulePath "data\metadata.json"
    SetupCompletePath = Join-Path $ModulePath "data\.setup-complete"
    # Multi-language support
    CurrentLanguage = 'en'    # Default language (English)
    InstalledLanguages = @('en') # List of installed language packs
    LanguagesPath = Join-Path $ModulePath "data\languages"
}

# Load emoji dataset (Script-scoped)
$Script:EmojiDataPath = $Script:EmojiToolsConfig.DataPath

if (Test-Path $Script:EmojiDataPath) {
    try {
        $Script:EmojiData = Import-Csv $Script:EmojiDataPath -Encoding UTF8
        Write-Verbose "Loaded $($Script:EmojiData.Count) emojis from dataset"

        # Check dataset age and suggest update if needed
        $datasetAge = (Get-Date) - (Get-Item $Script:EmojiDataPath).LastWriteTime
        if ($Script:EmojiToolsConfig.AutoUpdateCheck -and $datasetAge.TotalDays -gt $Script:EmojiToolsConfig.UpdateInterval) {
            Write-Host "ℹ️  Your emoji dataset is $([math]::Round($datasetAge.TotalDays)) days old." -ForegroundColor Yellow
            Write-Host "   Run 'Update-EmojiDataset' to get the latest emojis from Unicode CLDR." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Warning "Failed to load emoji dataset: $_"
        $Script:EmojiData = @()
    }
}
else {
    Write-Warning "Emoji dataset not found at: $Script:EmojiDataPath"
    Write-Host "🔄 Downloading initial emoji dataset from Unicode CLDR..." -ForegroundColor Cyan
    # Auto-download on first load
    if (Get-Command Update-EmojiDataset -ErrorAction SilentlyContinue) {
        Update-EmojiDataset -Source Unicode -Silent
    }
    else {
        Write-Warning "Run Update-EmojiDataset to download the emoji data after module loads."
    }
    $Script:EmojiData = @()
}

# Check for new emojis (Option C notification)
$historyPath = Join-Path $ModulePath "data\history.json"
if (Test-Path $historyPath) {
    $history = Get-Content $historyPath -Encoding UTF8 -ErrorAction SilentlyContinue | ConvertFrom-Json -ErrorAction SilentlyContinue
    if ($history.updates -and $history.updates.Count -gt 0) {
        $latestUpdate = $history.updates[0]
        $updateDate = [datetime]$latestUpdate.date
        $daysAgo = (New-TimeSpan -Start $updateDate -End (Get-Date)).Days
        # Only notify if the latest update is within 7 days and has new emojis
        if ($daysAgo -le 7 -and $latestUpdate.added.Count -gt 0) {
            $totalAdded = $latestUpdate.added.Count
            Write-Host "ℹ️  $totalAdded new emojis available in recent updates (Run Get-NewEmojis to see them)" -ForegroundColor Cyan
        }
    }
}

# Import all function files from the functions directory
Get-ChildItem "$ModulePath\functions" -Filter *.ps1 -ErrorAction SilentlyContinue | ForEach-Object {
    try {
        . $_.FullName
        Write-Verbose "Loaded function: $($_.BaseName)"
    }
    catch {
        Write-Warning "Failed to load function $($_.Name): $_"
    }
}

# Initialize caching system (Phase 1 & 2)
if (Get-Command Initialize-EmojiIndices -ErrorAction SilentlyContinue) {
    Write-Verbose "Initializing emoji search indices..."
    Initialize-EmojiIndices
}

# Warmup cache with popular queries (Phase 3)
if (Get-Command Start-EmojiCacheWarmup -ErrorAction SilentlyContinue) {
    # Run warmup in background to avoid slowing module load
    Start-Job -ScriptBlock {
        param($ModulePath)
        Import-Module (Join-Path $ModulePath "EmojiTools.psd1")
        Start-EmojiCacheWarmup
    } -ArgumentList $ModulePath | Out-Null
}

# First-run setup
if ($Script:EmojiToolsConfig.AutoInitialize.Count -gt 0 -and -not (Test-Path $Script:EmojiToolsConfig.SetupCompletePath)) {
    Write-Host "`n🎉 Welcome to EmojiTools! Running first-time setup..." -ForegroundColor Cyan

    $shouldInitCollections = $Script:EmojiToolsConfig.AutoInitialize -contains 'Collections' -or $Script:EmojiToolsConfig.AutoInitialize -contains 'All'
    $shouldInitAliases = $Script:EmojiToolsConfig.AutoInitialize -contains 'Aliases' -or $Script:EmojiToolsConfig.AutoInitialize -contains 'All'

    try {
        # Initialize default collections
        if ($shouldInitCollections -and (Get-Command Initialize-EmojiCollections -ErrorAction SilentlyContinue)) {
            Write-Host "   📁 Creating default emoji collections..." -ForegroundColor Gray
            Initialize-EmojiCollections -ErrorAction SilentlyContinue | Out-Null
        }

        # Initialize default aliases
        if ($shouldInitAliases -and (Get-Command Initialize-DefaultEmojiAliases -ErrorAction SilentlyContinue)) {
            Write-Host "   🔖 Setting up emoji aliases..." -ForegroundColor Gray
            Initialize-DefaultEmojiAliases -ErrorAction SilentlyContinue | Out-Null
        }

        # Mark setup as complete
        New-Item -ItemType File -Path $Script:EmojiToolsConfig.SetupCompletePath -Force | Out-Null

        Write-Host "`n✅ Setup complete! EmojiTools is ready to use." -ForegroundColor Green
        Write-Host "   Try: Get-EmojiAlias -List" -ForegroundColor Cyan
        Write-Host "   Try: Get-EmojiCollection" -ForegroundColor Cyan
        Write-Host "   Try: Show-EmojiPicker`n" -ForegroundColor Cyan
    }
    catch {
        Write-Warning "First-time setup encountered an error: $_"
        Write-Host "You can manually run: Initialize-EmojiCollections and Initialize-DefaultEmojiAliases" -ForegroundColor Yellow
    }
}

# Export module members
Export-ModuleMember -Function Get-Emoji, Search-Emoji, Update-EmojiDataset, Copy-Emoji, Get-EmojiWithSkinTone, Export-Emoji, Show-EmojiPicker, Join-Emoji, New-EmojiCollection, Add-EmojiToCollection, Remove-EmojiFromCollection, Get-EmojiCollection, Remove-EmojiCollection, Export-EmojiCollection, Import-EmojiCollection, Initialize-EmojiCollections, Get-EmojiStats, Clear-EmojiStats, Export-EmojiStats, Get-EmojiAlias, New-EmojiAlias, Remove-EmojiAlias, Set-EmojiAlias, Initialize-DefaultEmojiAliases, Import-EmojiAliases, Export-EmojiAliases, Initialize-EmojiTools, Reset-EmojiTools, Get-EmojiToolsInfo, Import-CustomEmojiDataset, Export-CustomEmojiDataset, New-CustomEmojiDataset, Get-CustomEmojiDatasetInfo, Reset-EmojiDataset, Emoji, Get-EmojiDatasetInfo, Enable-EmojiAutoUpdate, Disable-EmojiAutoUpdate, Clear-EmojiCache, Get-EmojiCacheStats, Set-EmojiCacheConfig, Get-EmojiCacheConfig, Start-EmojiCacheWarmup, Get-EmojiUpdateHistory, Get-NewEmojis, Get-RemovedEmojis, Export-EmojiHistory, Clear-EmojiHistory, Register-EmojiSource, Unregister-EmojiSource, Get-EmojiSource, Get-EmojiLanguage, Set-EmojiLanguage, Install-EmojiLanguage, Uninstall-EmojiLanguage, New-EmojiScheduledTask, Remove-EmojiScheduledTask, Test-EmojiScheduledTask, Get-EmojiPlatform

# Export variables for testing purposes (allows tests to verify internal state)
Export-ModuleMember -Variable EmojiToolsConfig, EmojiData, EmojiDataPath
