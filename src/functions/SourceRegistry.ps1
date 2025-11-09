# Custom Emoji Source Registry Functions

function Register-EmojiSource {
    <#
    .SYNOPSIS
        Registers a custom emoji source for use with Update-EmojiDataset.

    .DESCRIPTION
        Adds a custom remote emoji source to the registry, allowing you to download
        datasets from your own URLs using Update-EmojiDataset -Source <Name>.

    .PARAMETER Name
        Unique name for the source (alphanumeric, hyphens, underscores only)

    .PARAMETER Url
        URL to the emoji dataset (must be HTTP or HTTPS)

    .PARAMETER Format
        Dataset format: CSV or JSON (auto-detected from URL if not specified)

    .PARAMETER Description
        Optional description of the source

    .EXAMPLE
        Register-EmojiSource -Name "CompanyEmojis" -Url "https://company.com/emojis.csv"
        Registers a custom source with automatic format detection

    .EXAMPLE
        Register-EmojiSource -Name "TeamData" -Url "https://internal.local/emojis.json" -Format JSON -Description "Team emoji collection"
        Registers a source with explicit format and description
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[a-zA-Z0-9_-]+$')]
        [ValidateLength(1, 50)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [ValidateScript( {
                if ($_ -notmatch '^https?://') {
                    throw "URL must be HTTP or HTTPS"
                }
                # Check for path traversal and malicious patterns
                $suspiciousPatterns = @('..', '%00', '<', '>', 'javascript:', 'data:', 'file:', 'vbscript:')
                foreach ($pattern in $suspiciousPatterns) {
                    if ($_ -like "*$pattern*") {
                        throw "Invalid or insecure URL: $_. URL contains suspicious patterns."
                    }
                }
                $true
            })]
        [string]$Url,

        [Parameter(Mandatory = $false)]
        [ValidateSet('CSV', 'JSON')]
        [string]$Format,

        [Parameter(Mandatory = $false)]
        [string]$Description
    )

    # Warn if HTTP is used (moved here so -WarningVariable can capture it)
    if ($Url -match '^http://') {
        Write-Warning "Using insecure HTTP URL. Consider using HTTPS for security."
    }

    # Get module data path
    $ModulePath = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
    $sourcesPath = Join-Path $ModulePath "data\sources.json"

    # Check for built-in source name conflicts
    $builtInSources = @('Kaggle', 'Unicode', 'GitHub')
    if ($builtInSources -contains $Name) {
        $exception = [DataValidationException]::new("Source name '$Name' conflicts with built-in source. Please choose a different name.", @{ Name = $Name })
        Write-EmojiError -Exception $exception -Category InvalidArgument
        return
    }

    # Auto-detect format from URL if not specified
    if (-not $Format) {
        if ($Url -match '\.csv($|\?)') {
            $Format = 'CSV'
            Write-Verbose "Auto-detected format: CSV"
        }
        elseif ($Url -match '\.json($|\?)') {
            $Format = 'JSON'
            Write-Verbose "Auto-detected format: JSON"
        }
        else {
            Write-Warning "Could not auto-detect format from URL. Defaulting to CSV."
            $Format = 'CSV'
        }
    }

    # Load existing sources or create new registry
    $registry = @{
        version = "1.0"
        custom_sources = @()
    }

    if (Test-Path $sourcesPath) {
        try {
            $registry = Get-Content $sourcesPath -Raw | ConvertFrom-Json -AsHashtable
        }
        catch {
            Write-EmojiWarning -Message "Could not load existing sources registry. Creating new one." -WarningCode "REGISTRY_LOAD_FAILED"
        }
    }

    # Check if source already exists
    $existingSource = $registry.custom_sources | Where-Object { $_.name -eq $Name }
    if ($existingSource) {
        # Duplicate registration is considered an error in tests; throw to allow callers to catch
        $exception = [DataValidationException]::new(
            "Source '$Name' already exists. Use Unregister-EmojiSource first to replace it.",
            @{ Name = $Name; ExistingUrl = $existingSource.url }
        )
        throw $exception
    }

    # Create new source entry
    $newSource = @{
        name = $Name
        url = $Url
        format = $Format
        description = $Description
        added = (Get-Date).ToUniversalTime().ToString("o")
        last_used = $null
        update_count = 0
    }

    # Add to registry
    $registry.custom_sources += $newSource

    # Save registry with WhatIf support
    if ($PSCmdlet.ShouldProcess("Source '$Name'", "Register emoji source")) {
        try {
            $registry | ConvertTo-Json -Depth 10 | Set-Content $sourcesPath -Encoding UTF8
            Write-Host "✅ Successfully registered emoji source '$Name'" -ForegroundColor Green
            Write-Host "   URL: $Url" -ForegroundColor Cyan
            Write-Host "   Format: $Format" -ForegroundColor Cyan
            if ($Description) {
                Write-Host "   Description: $Description" -ForegroundColor Cyan
            }
            Write-Host "`nUse: Update-EmojiDataset -Source '$Name'" -ForegroundColor Yellow
        }
        catch {
            Write-Error "Failed to save source registry: $_"
        }
    }
}


function Unregister-EmojiSource {
    <#
    .SYNOPSIS
        Removes a custom emoji source from the registry.

    .DESCRIPTION
        Unregisters a previously registered custom emoji source. Built-in sources
        (Kaggle, Unicode, GitHub) cannot be removed.

    .PARAMETER Name
        Name of the source to remove

    .PARAMETER All
        Remove all custom sources

    .PARAMETER Force
        Skip confirmation prompt

    .EXAMPLE
        Unregister-EmojiSource -Name "CompanyEmojis"
        Removes the specified source with confirmation

    .EXAMPLE
        Unregister-EmojiSource -Name "CompanyEmojis" -Force
        Removes the source without confirmation

    .EXAMPLE
        Unregister-EmojiSource -All -Force
        Removes all custom sources without confirmation
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = 'Single')]
        [string]$Name,

        [Parameter(Mandatory = $false, ParameterSetName = 'All')]
        [switch]$All,

        [Parameter(Mandatory = $false)]
        [switch]$Force
    )

    # Get module data path
    $ModulePath = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
    $sourcesPath = Join-Path $ModulePath "data\sources.json"

    if (-not (Test-Path $sourcesPath)) {
        if ($All) {
            Write-Warning "No custom sources registered."
            return
        }
        else {
            Write-Warning "Source '$Name' not found. No custom sources registered."
            return
        }
    }

    # Load registry
    try {
        $registry = Get-Content $sourcesPath -Raw | ConvertFrom-Json -AsHashtable
    }
    catch {
        Write-Error "Failed to load source registry: $_"
        return
    }

    if ($All) {
        # Remove all custom sources
        $count = $registry.custom_sources.Count
        if ($count -eq 0) {
            Write-Host "No custom sources to remove." -ForegroundColor Yellow
            return
        }

        if (-not $Force -and -not $PSCmdlet.ShouldProcess("$count custom source(s)", "Remove all")) {
            return
        }

        $registry.custom_sources = @()
        $registry | ConvertTo-Json -Depth 10 | Set-Content $sourcesPath -Encoding UTF8
        Write-Host "✅ Removed $count custom source(s)" -ForegroundColor Green
    }
    else {
        # Remove specific source
        if (-not $Name) {
            Write-Error "Please specify -Name or use -All to remove all sources"
            return
        }

        $source = $registry.custom_sources | Where-Object { $_.name -eq $Name }
        if (-not $source) {
            Write-Warning "Source '$Name' not found in registry."
            Write-Host "`nAvailable sources:" -ForegroundColor Yellow
            Get-EmojiSource -CustomOnly
            return
        }

        if (-not $Force -and -not $PSCmdlet.ShouldProcess($Name, "Remove emoji source")) {
            return
        }

        $registry.custom_sources = @($registry.custom_sources | Where-Object { $_.name -ne $Name })
        $registry | ConvertTo-Json -Depth 10 | Set-Content $sourcesPath -Encoding UTF8

        Write-Host "✅ Removed emoji source '$Name'" -ForegroundColor Green
        Write-Host "   URL: $($source.url)" -ForegroundColor Cyan
    }
}


function Get-EmojiSource {
    <#
    .SYNOPSIS
        Lists available emoji sources (built-in and custom).

    .DESCRIPTION
        Displays all emoji sources available for use with Update-EmojiDataset,
        including built-in sources (Kaggle, Unicode, GitHub) and custom registered sources.

    .PARAMETER Name
        Get details for a specific source

    .PARAMETER CustomOnly
        Show only custom registered sources

    .EXAMPLE
        Get-EmojiSource
        Lists all available sources

    .EXAMPLE
        Get-EmojiSource -Name "CompanyEmojis"
        Shows details for a specific source

    .EXAMPLE
        Get-EmojiSource -CustomOnly
        Lists only custom registered sources
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [switch]$CustomOnly
    )

    # Get module data path
    $ModulePath = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
    $sourcesPath = Join-Path $ModulePath "data\sources.json"

    # Built-in sources
    $builtInSources = @(
        [PSCustomObject]@{
            Name = 'Unicode'
            Type = 'Built-in'
            Format = 'JSON'
            Url = 'https://unicode.org/Public/emoji/latest/emoji-test.txt (+ CLDR annotations)'
            Description = 'Official Unicode CLDR emoji data (recommended)'
        },
        [PSCustomObject]@{
            Name = 'Kaggle'
            Type = 'Built-in'
            Format = 'CSV'
            Url = '(Requires Kaggle authentication)'
            Description = 'Kaggle emoji dataset'
        },
        [PSCustomObject]@{
            Name = 'GitHub'
            Type = 'Built-in'
            Format = 'JSON'
            Url = 'https://raw.githubusercontent.com/github/gemoji/master/db/emoji.json'
            Description = 'GitHub gemoji collection'
        }
    )

    # Load custom sources
    $customSources = @()
    if (Test-Path $sourcesPath) {
        try {
            $registry = Get-Content $sourcesPath -Raw | ConvertFrom-Json
            $customSources = $registry.custom_sources | ForEach-Object {
                [PSCustomObject]@{
                    Name = $_.name
                    Type = 'Custom'
                    Format = $_.format
                    Url = $_.url
                    Description = $_.description
                    Added = $_.added
                    LastUsed = $_.last_used
                    UpdateCount = $_.update_count
                }
            }
        }
        catch {
            Write-Warning "Could not load custom sources: $_"
        }
    }

    # Filter by name if specified
    if ($Name) {
        $source = $builtInSources | Where-Object { $_.Name -eq $Name }
        if (-not $source) {
            $source = $customSources | Where-Object { $_.Name -eq $Name }
        }

        if ($source) {
            return $source
        }
        else {
            Write-Warning "Source '$Name' not found."
            return
        }
    }

    # Return results
    if ($CustomOnly) {
        if ($customSources.Count -eq 0) {
            Write-Host "No custom sources registered." -ForegroundColor Yellow
            Write-Host "Use Register-EmojiSource to add custom sources." -ForegroundColor Cyan
        }
        return $customSources
    }
    else {
        $allSources = $builtInSources + $customSources
        return $allSources
    }
}


function Get-CustomEmojiSourceRegistry {
    <#
    .SYNOPSIS
        Internal helper function to load custom source registry.

    .DESCRIPTION
        Loads the custom emoji source registry from sources.json.
        Returns $null if no registry exists.
    #>

    [CmdletBinding()]
    param()

    $ModulePath = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
    $sourcesPath = Join-Path $ModulePath "data\sources.json"

    if (-not (Test-Path $sourcesPath)) {
        return $null
    }

    try {
        $registry = Get-Content $sourcesPath -Raw | ConvertFrom-Json -AsHashtable
        return $registry
    }
    catch {
        Write-Warning "Failed to load source registry: $_"
        return $null
    }
}


function Update-CustomEmojiSourceUsage {
    <#
    .SYNOPSIS
        Internal helper function to update source usage statistics.

    .DESCRIPTION
        Updates the last_used timestamp and update_count for a custom source.
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceName
    )

    $ModulePath = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
    $sourcesPath = Join-Path $ModulePath "data\sources.json"

    if (-not (Test-Path $sourcesPath)) {
        return
    }

    try {
        $registry = Get-Content $sourcesPath -Raw | ConvertFrom-Json -AsHashtable

        $source = $registry.custom_sources | Where-Object { $_.name -eq $SourceName }
        if ($source) {
            $source.last_used = (Get-Date).ToUniversalTime().ToString("o")
            $source.update_count += 1

            $registry | ConvertTo-Json -Depth 10 | Set-Content $sourcesPath -Encoding UTF8
            Write-Verbose "Updated usage stats for source '$SourceName'"
        }
    }
    catch {
        Write-Verbose "Failed to update source usage: $_"
    }
}
