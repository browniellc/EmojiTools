# Multi-Language Support Functions for EmojiTools

function Get-EmojiLanguage {
    <#
    .SYNOPSIS
        Gets available and installed emoji languages.

    .DESCRIPTION
        Lists all available languages from Unicode CLDR or shows currently installed
        language packs. Displays current language setting.

    .PARAMETER Available
        Show all available languages from Unicode CLDR (requires internet)

    .PARAMETER Installed
        Show only installed language packs

    .PARAMETER Current
        Show only the currently active language

    .EXAMPLE
        Get-EmojiLanguage
        Shows current language and installed packs

    .EXAMPLE
        Get-EmojiLanguage -Available
        Lists all 166+ available languages from Unicode CLDR

    .EXAMPLE
        Get-EmojiLanguage -Installed
        Shows only languages that have been downloaded
    #>

    [CmdletBinding(DefaultParameterSetName = 'Summary')]
    param(
        [Parameter(ParameterSetName = 'Available')]
        [switch]$Available,

        [Parameter(ParameterSetName = 'Installed')]
        [switch]$Installed,

        [Parameter(ParameterSetName = 'Current')]
        [switch]$Current
    )

    $ModulePath = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
    $languagesPath = Join-Path $ModulePath "data\languages"

    if ($Current) {
        # Show current language only
        $currentLang = $Script:EmojiToolsConfig.CurrentLanguage
        Write-Host "Current Language: " -NoNewline -ForegroundColor Cyan
        Write-Host $currentLang -ForegroundColor Green
        return [PSCustomObject]@{
            Code = $currentLang
            IsCurrent = $true
            IsInstalled = Test-Path (Join-Path $languagesPath $currentLang)
        }
    }

    if ($Available) {
        # Fetch available languages from Unicode CLDR
        Write-Host "📥 Fetching available languages from Unicode CLDR..." -ForegroundColor Yellow

        try {
            $url = "https://api.github.com/repos/unicode-org/cldr-json/contents/cldr-json/cldr-annotations-full/annotations"
            $response = Invoke-RestMethod -Uri $url -Method Get -ErrorAction Stop

            $languages = $response | Where-Object { $_.type -eq 'dir' } | ForEach-Object {
                [PSCustomObject]@{
                    Code = $_.name
                    IsInstalled = Test-Path (Join-Path $languagesPath $_.name)
                    IsCurrent = ($_.name -eq $Script:EmojiToolsConfig.CurrentLanguage)
                }
            } | Sort-Object Code

            Write-Host "✅ Found $($languages.Count) available languages" -ForegroundColor Green
            return $languages
        }
        catch {
            Write-Error "Failed to fetch available languages: $_"
            return
        }
    }

    if ($Installed) {
        # Show installed languages only
        # Return a simple list of installed language codes (strings) so callers/tests
        # can easily assert membership (e.g. -Contain 'en'). Avoid using
        # Format-Table because it emits formatting objects into the pipeline when
        # the function is captured.
        # Always include built-in English ('en') as an installed language
        $installedLangs = @('en')
        if (Test-Path $languagesPath) {
            $installedLangs += (Get-ChildItem $languagesPath -Directory | ForEach-Object { $_.Name })
            $installedLangs = $installedLangs | Sort-Object -Unique
        }

        Write-Host "`n📚 Installed Language Packs:" -ForegroundColor Cyan
        foreach ($l in $installedLangs) {
            $marker = if ($l -eq $Script:EmojiToolsConfig.CurrentLanguage) { '✓' } else { ' ' }
            Write-Host " $marker  $l"
        }

        return $installedLangs
    }

    # Default: Summary view - return an object as well as printing to host so tests can assert on returned value
    $currentLanguage = $Script:EmojiToolsConfig.CurrentLanguage
    $installedCount = if (Test-Path $languagesPath) { (Get-ChildItem $languagesPath -Directory).Count } else { 0 }

    Write-Host "`n🌍 EmojiTools Language Configuration" -ForegroundColor Cyan
    Write-Host "=" * 50 -ForegroundColor Gray

    Write-Host "`nCurrent Language: " -NoNewline
    Write-Host $currentLanguage -ForegroundColor Green

    Write-Host "Installed Languages: " -NoNewline
    Write-Host $installedCount -ForegroundColor Yellow

    Write-Host "`n💡 Commands:" -ForegroundColor Cyan
    Write-Host "  Get-EmojiLanguage -Available    # List all 166+ available languages"
    Write-Host "  Get-EmojiLanguage -Installed    # Show installed language packs"
    Write-Host "  Install-EmojiLanguage -Language fr    # Install French"
    Write-Host "  Set-EmojiLanguage -Language fr         # Switch to French"
    Write-Host ""

    return [PSCustomObject]@{
        CurrentLanguage = $currentLanguage
        InstalledCount = $installedCount
    }
}


function Set-EmojiLanguage {
    <#
    .SYNOPSIS
        Sets the active emoji language.

    .DESCRIPTION
        Changes the current language used for emoji names and keywords.
        Language must be installed first using Install-EmojiLanguage.

    .PARAMETER Language
        Language code (e.g., 'fr', 'es', 'de', 'ja', 'zh')

    .PARAMETER Force
        Force reload of emoji data even if already using this language

    .EXAMPLE
        Set-EmojiLanguage -Language fr
        Switches to French language pack

    .EXAMPLE
        Set-EmojiLanguage -Language es -Force
        Forces reload of Spanish language data
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Language,

        [Parameter()]
        [switch]$Force
    )

    $ModulePath = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
    $languagesPath = Join-Path $ModulePath "data\languages"
    $languagePath = Join-Path $languagesPath $Language
    $languageDataPath = Join-Path $languagePath "emoji.csv"

    # Check if language is English (built-in)
    if ($Language -eq 'en') {
        $defaultDataPath = Join-Path $ModulePath "data\emoji.csv"

        if (-not $Force -and $Script:EmojiToolsConfig.CurrentLanguage -eq 'en') {
            Write-Host "Already using English. Use -Force to reload." -ForegroundColor Yellow
            return
        }

        if (-not $PSCmdlet.ShouldProcess("English (en)", "Set emoji language")) {
            return
        }

        $Script:EmojiToolsConfig.CurrentLanguage = 'en'
        $Script:EmojiData = Import-Csv $defaultDataPath -Encoding UTF8

        Write-Host "✅ Language set to: " -NoNewline -ForegroundColor Green
        Write-Host "English (en)" -ForegroundColor Cyan
        Write-Host "   Loaded $($Script:EmojiData.Count) emojis" -ForegroundColor Gray
        return
    }

    # Check if language pack is installed
    if (-not (Test-Path $languageDataPath)) {
        Write-Error "Language pack '$Language' is not installed."
        Write-Host "`nInstall it first:" -ForegroundColor Yellow
        Write-Host "  Install-EmojiLanguage -Language $Language" -ForegroundColor Cyan
        Write-Host "`nOr see available languages:" -ForegroundColor Yellow
        Write-Host "  Get-EmojiLanguage -Available" -ForegroundColor Cyan
        return
    }

    # Check if already using this language
    if (-not $Force -and $Script:EmojiToolsConfig.CurrentLanguage -eq $Language) {
        Write-Host "Already using language '$Language'. Use -Force to reload." -ForegroundColor Yellow
        return
    }

    if (-not $PSCmdlet.ShouldProcess($Language, "Set emoji language")) {
        return
    }

    # Load language data
    try {
        $Script:EmojiData = Import-Csv $languageDataPath -Encoding UTF8
        $Script:EmojiToolsConfig.CurrentLanguage = $Language

        # Read metadata if available
        $metadataPath = Join-Path $languagePath "metadata.json"
        $languageName = $Language
        if (Test-Path $metadataPath) {
            $metadata = Get-Content $metadataPath -Encoding UTF8 | ConvertFrom-Json
            $languageName = if ($metadata.LanguageName) { "$($metadata.LanguageName) ($Language)" } else { $Language }
        }

        Write-Host "✅ Language set to: " -NoNewline -ForegroundColor Green
        Write-Host $languageName -ForegroundColor Cyan
        Write-Host "   Loaded $($Script:EmojiData.Count) emojis" -ForegroundColor Gray

        # Invalidate caches
        if (Get-Command Invoke-CacheInvalidation -ErrorAction SilentlyContinue) {
            Write-Verbose "Invalidating search caches for new language..."
            Invoke-CacheInvalidation
        }
    }
    catch {
        Write-Error "Failed to load language data: $_"
    }
}


function Install-EmojiLanguage {
    <#
    .SYNOPSIS
        Downloads and installs an emoji language pack.

    .DESCRIPTION
        Downloads emoji names and keywords in the specified language from
        Unicode CLDR. The language pack is saved locally for offline use.

    .PARAMETER Language
        Language code(s) to install (e.g., 'fr', 'es', 'de', 'ja')
        Can be a single language or comma-separated list

    .PARAMETER Force
        Force re-download even if language is already installed

    .PARAMETER SetAsDefault
        Set this language as the current language after installation

    .EXAMPLE
        Install-EmojiLanguage -Language fr
        Installs French language pack

    .EXAMPLE
        Install-EmojiLanguage -Language "es,de,ja" -Force
        Installs Spanish, German, and Japanese (re-downloading if needed)

    .EXAMPLE
        Install-EmojiLanguage -Language fr -SetAsDefault
        Installs French and switches to it immediately
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Language,

        [Parameter()]
        [switch]$Force,

        [Parameter()]
        [switch]$SetAsDefault
    )

    $ModulePath = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
    $languagesPath = Join-Path $ModulePath "data\languages"

    # Support comma-separated language list
    $languages = $Language -split ',' | ForEach-Object { $_.Trim() }

    foreach ($lang in $languages) {
        # Skip English (built-in)
        if ($lang -eq 'en') {
            Write-Host "ℹ️  English is built-in, no installation needed" -ForegroundColor Cyan
            if ($SetAsDefault) {
                Set-EmojiLanguage -Language en
            }
            continue
        }

        $langPath = Join-Path $languagesPath $lang
        $langDataPath = Join-Path $langPath "emoji.csv"

        # Check if already installed
        if ((Test-Path $langDataPath) -and -not $Force) {
            Write-Host "ℹ️  Language '$lang' is already installed. Use -Force to re-download." -ForegroundColor Yellow

            if ($SetAsDefault) {
                Set-EmojiLanguage -Language $lang
            }
            continue
        }

        if (-not $PSCmdlet.ShouldProcess($lang, "Download emoji language pack")) {
            continue
        }

        Write-Host "`n📥 Installing language pack: $lang" -ForegroundColor Cyan

        try {
            # Use Update-EmojiDataset to download the language pack
            Update-EmojiDataset -Source Unicode -Language $lang -Silent

            Write-Host "✅ Successfully installed language pack: $lang" -ForegroundColor Green

            if (Test-Path $langDataPath) {
                $sizeKB = [math]::Round((Get-Item $langDataPath).Length / 1KB, 2)
                Write-Host "   Size: $sizeKB KB" -ForegroundColor Gray

                # Count emojis
                $emojiCount = (Import-Csv $langDataPath -Encoding UTF8).Count
                Write-Host "   Emojis: $emojiCount" -ForegroundColor Gray
            }

            # Add to installed languages list
            if ($lang -notin $Script:EmojiToolsConfig.InstalledLanguages) {
                $Script:EmojiToolsConfig.InstalledLanguages += $lang
            }

            # Set as default if requested
            if ($SetAsDefault) {
                Write-Host ""
                Set-EmojiLanguage -Language $lang
            }
        }
        catch {
            Write-Error "Failed to install language pack '$lang': $_"
            Write-Host "   Verify the language code is valid. Use:" -ForegroundColor Yellow
            Write-Host "   Get-EmojiLanguage -Available" -ForegroundColor Cyan
        }
    }

    Write-Host ""
}


function Uninstall-EmojiLanguage {
    <#
    .SYNOPSIS
        Removes an installed emoji language pack.

    .DESCRIPTION
        Deletes a language pack from local storage to free up disk space.
        Cannot remove English (built-in).

    .PARAMETER Language
        Language code to remove (e.g., 'fr', 'es', 'de')

    .PARAMETER Force
        Skip confirmation prompt

    .EXAMPLE
        Uninstall-EmojiLanguage -Language fr
        Removes French language pack with confirmation

    .EXAMPLE
        Uninstall-EmojiLanguage -Language "es,de" -Force
        Removes Spanish and German without confirmation
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Language,

        [Parameter()]
        [switch]$Force
    )

    $ModulePath = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
    $languagesPath = Join-Path $ModulePath "data\languages"

    # Support comma-separated list
    $languages = $Language -split ',' | ForEach-Object { $_.Trim() }

    foreach ($lang in $languages) {
        # Prevent removing English
        if ($lang -eq 'en') {
            # Tests expect an exception when attempting to uninstall English
            throw "Cannot uninstall English (built-in language)"
        }

        $langPath = Join-Path $languagesPath $lang

        if (-not (Test-Path $langPath)) {
            Write-Warning "Language pack '$lang' is not installed"
            continue
        }

        # Check if this is the current language
        if ($Script:EmojiToolsConfig.CurrentLanguage -eq $lang) {
            Write-Warning "Cannot uninstall '$lang' - it is currently active"
            Write-Host "Switch to another language first:" -ForegroundColor Yellow
            Write-Host "  Set-EmojiLanguage -Language en" -ForegroundColor Cyan
            continue
        }

        if (-not $Force -and -not $PSCmdlet.ShouldProcess($lang, "Remove language pack")) {
            continue
        }

        try {
            Remove-Item $langPath -Recurse -Force

            # Remove from installed list
            $Script:EmojiToolsConfig.InstalledLanguages = @(
                $Script:EmojiToolsConfig.InstalledLanguages | Where-Object { $_ -ne $lang }
            )

            Write-Host "✅ Removed language pack: $lang" -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to remove language pack '$lang': $_"
        }
    }
}
