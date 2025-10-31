function Update-EmojiDataset {
    <#
    .SYNOPSIS
        Updates the local emoji dataset from online sources.

    .DESCRIPTION
        Downloads and updates the emoji dataset from built-in sources (Kaggle, Unicode, GitHub)
        or custom registered sources. Also supports one-time URLs and multi-language downloads.

    .PARAMETER Source
        The data source to use: 'Kaggle', 'Unicode', 'GitHub', or a custom registered source name

    .PARAMETER Url
        One-time URL to download dataset from (CSV or JSON format)

    .PARAMETER Format
        Format for URL parameter: CSV or JSON (auto-detected if not specified)

    .PARAMETER Language
        Language code for Unicode CLDR translations (e.g., 'fr', 'es', 'de', 'ja')
        Only used with -Source Unicode. Downloads names/keywords in specified language.

    .PARAMETER Force
        Force re-download even if data appears up-to-date

    .PARAMETER KaggleApiKey
        Kaggle API key for authentication (optional, can use environment variable)

    .PARAMETER Silent
        Suppress output messages

    .EXAMPLE
        Update-EmojiDataset
        Downloads emoji data from the default Unicode source

    .EXAMPLE
        Update-EmojiDataset -Source Unicode -Force
        Forces download from Unicode CLDR source

    .EXAMPLE
        Update-EmojiDataset -Source Unicode -Language fr
        Downloads French emoji names and keywords from Unicode CLDR

    .EXAMPLE
        Update-EmojiDataset -Source "MyCompany"
        Downloads from custom registered source named "MyCompany"

    .EXAMPLE
        Update-EmojiDataset -Url "https://example.com/emojis.csv"
        Downloads from a one-time URL
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Source')]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = 'Source')]
        [string]$Source = 'Unicode',

        [Parameter(Mandatory = $true, ParameterSetName = 'Url')]
        [ValidateScript( {
                if ($_ -notmatch '^https?://') {
                    throw "URL must be HTTP or HTTPS"
                }
                $true
            })]
        [string]$Url,

        [Parameter(Mandatory = $false, ParameterSetName = 'Url')]
        [ValidateSet('CSV', 'JSON')]
        [string]$Format,

        [Parameter(Mandatory = $false, ParameterSetName = 'Source')]
        [string]$Language,

        [Parameter(Mandatory = $false)]
        [switch]$Force,

        [Parameter(Mandatory = $false)]
        [string]$KaggleApiKey,

        [Parameter(Mandatory = $false)]
        [switch]$Silent
    )

    $ModulePath = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

    # Determine target paths based on language parameter
    if ($Language -and $Language -ne 'en') {
        # Language-specific paths
        $languagesPath = Join-Path $ModulePath "data\languages"
        $langPath = Join-Path $languagesPath $Language
        $dataPath = Join-Path $langPath "emoji.csv"
        $metadataPath = Join-Path $langPath "metadata.json"

        # Create language directory if needed
        if (-not (Test-Path $langPath)) {
            New-Item -ItemType Directory -Path $langPath -Force | Out-Null
        }
    }
    else {
        # Default English paths
        $dataPath = Join-Path $ModulePath "data\emoji.csv"
        $metadataPath = Join-Path $ModulePath "data\metadata.json"
    }

    # Handle URL parameter set
    if ($PSCmdlet.ParameterSetName -eq 'Url') {
        if (-not $Silent) {
            Write-Host "🔄 Downloading emoji dataset from URL..." -ForegroundColor Cyan
        }

        # Auto-detect format from URL if not specified
        if (-not $Format) {
            if ($Url -match '\.csv($|\?)') {
                $Format = 'CSV'
            }
            elseif ($Url -match '\.json($|\?)') {
                $Format = 'JSON'
            }
            else {
                $Format = 'CSV'  # Default to CSV
                if (-not $Silent) {
                    Write-Warning "Could not detect format from URL. Assuming CSV."
                }
            }
        }

        # Download from URL
        try {
            $response = Invoke-RestMethod -Uri $Url -Method Get -ErrorAction Stop

            # Process based on format
            if ($Format -eq 'JSON') {
                # Handle JSON format (similar to GitHub/Unicode processing)
                $Source = 'CustomURL-JSON'
            }
            else {
                # Handle CSV format
                $tempCsvPath = Join-Path $env:TEMP "emoji-temp-$(Get-Random).csv"
                $response | Out-File -FilePath $tempCsvPath -Encoding UTF8

                # Validate CSV has required columns
                $csvData = Import-Csv $tempCsvPath -Encoding UTF8
                $requiredColumns = @('Emoji', 'Name', 'Category', 'Keywords')
                $csvColumns = $csvData[0].PSObject.Properties.Name
                $missingColumns = $requiredColumns | Where-Object { $_ -notin $csvColumns }

                if ($missingColumns) {
                    Remove-Item $tempCsvPath -ErrorAction SilentlyContinue
                    throw "CSV is missing required columns: $($missingColumns -join ', ')"
                }

                # Copy to dataset path
                Copy-Item $tempCsvPath -Destination $dataPath -Force
                Remove-Item $tempCsvPath -ErrorAction SilentlyContinue

                # Save metadata
                $metadata = @{
                    Source = "Custom URL"
                    Url = $Url
                    LastUpdate = (Get-Date).ToString('o')
                    EmojiCount = $csvData.Count
                    Format = 'CSV'
                }
                $metadata | ConvertTo-Json | Set-Content $metadataPath -Encoding UTF8

                if (-not $Silent) {
                    Write-Host "✅ Successfully downloaded $($csvData.Count) emojis from URL" -ForegroundColor Green
                }

                # Save update history
                Save-EmojiUpdateHistory -PreviousData $previousData -DataPath $dataPath

                # Reload dataset
                $Script:EmojiData = Import-Csv $dataPath -Encoding UTF8
                return
            }
        }
        catch {
            Write-Error "Failed to download from URL: $_"
            return
        }
    }

    # Check if Source is a custom registered source
    $builtInSources = @('Kaggle', 'Unicode', 'GitHub')
    if ($Source -notin $builtInSources) {
        # Try to load from custom source registry
        $registry = Get-CustomEmojiSourceRegistry
        if ($registry) {
            $customSource = $registry.custom_sources | Where-Object { $_.name -eq $Source }
            if ($customSource) {
                if (-not $Silent) {
                    Write-Host "🔄 Updating from custom source '$Source'..." -ForegroundColor Cyan
                }

                # Update usage statistics
                Update-CustomEmojiSourceUsage -SourceName $Source

                # Download using the custom source URL
                Update-EmojiDataset -Url $customSource.url -Format $customSource.format -Force:$Force -Silent:$Silent
                return
            }
            else {
                Write-Error "Source '$Source' not found. Available sources:"
                Get-EmojiSource | Format-Table Name, Type, Format -AutoSize
                return
            }
        }
        else {
            Write-Error "Source '$Source' not found. Use Get-EmojiSource to list available sources or Register-EmojiSource to add custom sources."
            return
        }
    }

    # Capture current dataset for history tracking
    $previousData = @()
    if (Test-Path $dataPath) {
        $previousData = Import-Csv $dataPath -Encoding UTF8
    }

    if (-not $Silent) {
        Write-Host "🔄 Updating emoji dataset from $Source..." -ForegroundColor Cyan
    }

    if (-not $PSCmdlet.ShouldProcess("Emoji dataset", "Update from $Source")) {
        return
    }

    try {
        switch ($Source) {
            'Kaggle' {
                # Kaggle dataset: unicode-emojis
                $kaggleDataset = "rtatman/emoji-dataset"

                # Check for Kaggle CLI or API key
                if (-not $KaggleApiKey) {
                    $KaggleApiKey = $env:KAGGLE_KEY
                }

                if (-not $KaggleApiKey -and -not (Get-Command kaggle -ErrorAction SilentlyContinue)) {
                    Write-Warning "Kaggle API key not found and Kaggle CLI not installed."
                    Write-Host "Please either:" -ForegroundColor Yellow
                    Write-Host "  1. Install Kaggle CLI: pip install kaggle" -ForegroundColor Yellow
                    Write-Host "  2. Provide API key with -KaggleApiKey parameter" -ForegroundColor Yellow
                    Write-Host "  3. Set KAGGLE_KEY environment variable" -ForegroundColor Yellow
                    Write-Host "`nFalling back to GitHub source..." -ForegroundColor Yellow
                    Update-EmojiDataset -Source GitHub -Force:$Force
                    return
                }

                # Download using Kaggle CLI
                $tempDir = Join-Path $env:TEMP "emoji-dataset-$(Get-Random)"
                New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

                Push-Location $tempDir
                kaggle datasets download -d $kaggleDataset

                # Extract and copy
                $zipFile = Get-ChildItem -Path $tempDir -Filter "*.zip" | Select-Object -First 1
                if ($zipFile) {
                    Expand-Archive -Path $zipFile.FullName -DestinationPath $tempDir -Force
                    $csvFile = Get-ChildItem -Path $tempDir -Filter "*.csv" | Select-Object -First 1

                    if ($csvFile) {
                        Copy-Item $csvFile.FullName -Destination $dataPath -Force
                        Write-Host "✓ Successfully updated emoji dataset from Kaggle" -ForegroundColor Green
                    }
                }

                Pop-Location
                Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
            }

            'Unicode' {
                # Unicode CLDR emoji annotations - Official source
                if (-not $Silent) {
                    Write-Host "📥 Downloading from Unicode CLDR (official source)..." -ForegroundColor Yellow
                }

                # Step 1: Download emoji-test.txt for category information
                if (-not $Silent) {
                    Write-Host "📥 Downloading emoji categories from Unicode..." -ForegroundColor Yellow
                }

                $emojiTestUrl = "https://unicode.org/Public/emoji/latest/emoji-test.txt"
                $emojiTestContent = Invoke-RestMethod -Uri $emojiTestUrl -Method Get

                # Parse emoji-test.txt to build category lookup
                $categoryLookup = @{}
                $currentGroup = ""

                foreach ($line in $emojiTestContent -split "`n") {
                    $line = $line.Trim()

                    # Parse group headers
                    if ($line -match '^# group: (.+)$') {
                        $currentGroup = $matches[1].Trim()
                        continue
                    }

                    # Skip subgroup headers (not needed for current implementation)
                    if ($line -match '^# subgroup: (.+)$') {
                        continue
                    }

                    # Parse emoji lines (skip comments and empty lines)
                    if ($line -match '^([0-9A-F\s]+)\s*;.*#\s*(.+?)\s+E\d+') {
                        $codepoints = $matches[1].Trim()
                        $emojiChar = $matches[2].Trim()

                        # Store using the actual emoji character from the file
                        if ($currentGroup -and $emojiChar) {
                            $categoryLookup[$emojiChar] = $currentGroup
                        }

                        # Also try to construct from codepoints as fallback
                        try {
                            $hexValues = $codepoints -split '\s+'
                            $codePointInts = $hexValues | ForEach-Object {
                                [convert]::ToInt32($_, 16)
                            }

                            # Handle supplementary characters (above U+FFFF)
                            $emojiFromCodepoints = ''
                            foreach ($cp in $codePointInts) {
                                if ($cp -gt 0xFFFF) {
                                    # Convert to surrogate pair
                                    $high = [Math]::Floor(($cp - 0x10000) / 0x400) + 0xD800
                                    $low = (($cp - 0x10000) % 0x400) + 0xDC00
                                    $emojiFromCodepoints += [char]$high + [char]$low
                                }
                                else {
                                    $emojiFromCodepoints += [char]$cp
                                }
                            }

                            if ($currentGroup -and $emojiFromCodepoints) {
                                $categoryLookup[$emojiFromCodepoints] = $currentGroup
                            }
                        }
                        catch {
                            Write-Verbose "Failed to parse emoji codepoint: $codepoints"
                        }
                    }
                }

                if (-not $Silent) {
                    Write-Host "   Built category map for $($categoryLookup.Count) emojis" -ForegroundColor Green
                }

                # Step 2: Download Unicode CLDR annotations for names and keywords
                $targetLang = if ($Language) { $Language } else { 'en' }

                if (-not $Silent) {
                    if ($Language) {
                        Write-Host "📥 Downloading $targetLang emoji names and keywords from CLDR..." -ForegroundColor Yellow
                    }
                    else {
                        Write-Host "📥 Downloading emoji names and keywords from CLDR..." -ForegroundColor Yellow
                    }
                }

                # Try multiple Unicode CLDR endpoints for reliability
                $unicodeUrls = @(
                    "https://raw.githubusercontent.com/unicode-org/cldr-json/main/cldr-json/cldr-annotations-full/annotations/$targetLang/annotations.json",
                    "https://raw.githubusercontent.com/unicode-org/cldr/main/common/annotations/$targetLang.xml"
                )

                $response = $null
                foreach ($url in $unicodeUrls) {
                    try {
                        if ($url -like "*.json") {
                            $response = Invoke-RestMethod -Uri $url -Method Get -ErrorAction Stop
                            break
                        }
                    }
                    catch {
                        Write-Verbose "Failed to fetch from $url : $_"
                    }
                }

                if (-not $response) {
                    if ($Language) {
                        throw "Could not fetch Unicode CLDR data for language '$Language'. Verify the language code with: Get-EmojiLanguage -Available"
                    }
                    else {
                        throw "Could not fetch Unicode CLDR data from any source"
                    }
                }

                # Step 3: Combine CLDR data with category information
                $emojiList = @()
                $count = 0
                $categorizedCount = 0

                foreach ($emoji in $response.annotations.annotations.PSObject.Properties) {
                    $count++
                    $emojiChar = $emoji.Name

                    # Look up category from emoji-test.txt data
                    $category = ''
                    if ($categoryLookup.ContainsKey($emojiChar)) {
                        $category = $categoryLookup[$emojiChar]
                        $categorizedCount++
                    }

                    $emojiList += [PSCustomObject]@{
                        emoji = $emojiChar
                        name = if ($emoji.Value.tts) { $emoji.Value.tts -join ' ' } else { "emoji_$count" }
                        keywords = if ($emoji.Value.default) { $emoji.Value.default -join ', ' } else { '' }
                        category = $category
                    }
                }

                $emojiList | Export-Csv -Path $dataPath -NoTypeInformation -Encoding UTF8

                if (-not $Silent) {
                    Write-Host "✅ Successfully updated emoji dataset from Unicode" -ForegroundColor Green
                    Write-Host "   Downloaded $($emojiList.Count) emojis" -ForegroundColor Green
                    Write-Host "   Categorized $categorizedCount emojis" -ForegroundColor Green
                }

                # Save metadata
                $metadata = @{
                    Source = 'Unicode CLDR + emoji-test.txt'
                    LastUpdate = (Get-Date).ToString('o')
                    EmojiCount = $emojiList.Count
                    CategorizedCount = $categorizedCount
                    Version = 'CLDR 45 + Unicode Emoji Latest'
                }
                $metadata | ConvertTo-Json | Out-File -FilePath $metadataPath -Encoding UTF8
            }

            'GitHub' {
                # GitHub emoji list (fallback/simple source)
                if (-not $Silent) {
                    Write-Host "📥 Downloading from GitHub emoji database..." -ForegroundColor Yellow
                }
                $githubUrl = "https://raw.githubusercontent.com/github/gemoji/master/db/emoji.json"

                $response = Invoke-RestMethod -Uri $githubUrl -Method Get

                # Convert JSON to CSV format
                $emojiList = @()
                foreach ($emoji in $response) {
                    $emojiList += [PSCustomObject]@{
                        emoji = $emoji.emoji
                        name = $emoji.description
                        keywords = ($emoji.aliases + $emoji.tags) -join ', '
                        category = $emoji.category
                    }
                }

                $emojiList | Export-Csv -Path $dataPath -NoTypeInformation -Encoding UTF8

                if (-not $Silent) {
                    Write-Host "✅ Successfully updated emoji dataset from GitHub" -ForegroundColor Green
                }

                # Save metadata
                $metadata = @{
                    Source = 'GitHub'
                    LastUpdate = (Get-Date).ToString('o')
                    EmojiCount = $emojiList.Count
                    Version = 'gemoji'
                }
                $metadata | ConvertTo-Json | Out-File -FilePath $metadataPath -Encoding UTF8
            }
        }

        # Reload the data
        $Script:EmojiData = Import-Csv $dataPath -Encoding UTF8
        if (-not $Silent) {
            Write-Host "✅ Loaded $($Script:EmojiData.Count) emojis into memory" -ForegroundColor Green
        }

        # Save update history
        if (Get-Command Save-EmojiUpdateHistory -ErrorAction SilentlyContinue) {
            $versionInfo = $null
            if (Test-Path $metadataPath) {
                try {
                    $meta = Get-Content $metadataPath -Encoding UTF8 | ConvertFrom-Json
                    $versionInfo = $meta.Version
                }
                catch {
                    # Metadata read error - version will be null
                    Write-Verbose "Could not read version from metadata: $_"
                }
            }
            Save-EmojiUpdateHistory -PreviousData $previousData -NewData $Script:EmojiData -Source $Source -Version $versionInfo
        }

        # Invalidate and rebuild caches (Phase 1 & 2 integration)
        if (Get-Command Invoke-CacheInvalidation -ErrorAction SilentlyContinue) {
            if (-not $Silent) {
                Write-Host "🔄 Rebuilding search indices and cache..." -ForegroundColor Cyan
            }
            Invoke-CacheInvalidation
        }

    }
    catch {
        Write-Error "Failed to update emoji dataset: $_"
        if (-not $Silent) {
            Write-Host "You can manually download emoji data and place it in: $dataPath" -ForegroundColor Yellow
        }
    }
}
