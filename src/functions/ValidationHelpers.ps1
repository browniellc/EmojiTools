# Validation Helpers for EmojiTools Module

<#
.SYNOPSIS
    Centralized validation and common operation helpers for EmojiTools.

.DESCRIPTION
    Provides reusable validation functions and common patterns to reduce code
    duplication and improve consistency across the module.
#>

function Test-EmojiDataLoaded {
    <#
    .SYNOPSIS
        Validates that emoji data is loaded and available.

    .DESCRIPTION
        Checks if the Script:EmojiData variable is populated. Throws a
        DataNotFoundException if data is not available.

    .PARAMETER ThrowOnError
        If true, throws an exception. If false, returns a boolean.

    .OUTPUTS
        [bool] Returns true if data is loaded, false otherwise (when ThrowOnError is false)

    .EXAMPLE
        Test-EmojiDataLoaded -ThrowOnError
        Throws an exception if data is not loaded

    .EXAMPLE
        if (Test-EmojiDataLoaded) { # Data is loaded }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$ThrowOnError
    )

    $isLoaded = ($null -ne $Script:EmojiData -and $Script:EmojiData.Count -gt 0)

    if (-not $isLoaded -and $ThrowOnError) {
        $exception = [DataNotFoundException]::new(
            "No emoji data loaded. Run Update-EmojiDataset to download the emoji data."
        )
        Write-EmojiError -Exception $exception -Category ResourceUnavailable
        throw $exception
    }

    return $isLoaded
}

function Get-CollectionsFilePath {
    <#
    .SYNOPSIS
        Returns the standardized path to the collections.json file.

    .DESCRIPTION
        Provides a centralized function to get the collections file path,
        reducing path construction duplication across functions.

    .OUTPUTS
        [string] The full path to collections.json

    .EXAMPLE
        $path = Get-CollectionsFilePath
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    return Join-Path $PSScriptRoot "..\data\collections.json"
}

function Get-CollectionData {
    <#
    .SYNOPSIS
        Loads collection data with caching support and validation.

    .DESCRIPTION
        Centralized function to load collection data from disk or cache.
        Handles file existence checks and error handling consistently.

    .PARAMETER CollectionName
        Optional. If provided, validates that the specified collection exists.

    .PARAMETER ThrowOnNotFound
        If true, throws an exception when collections file or specific collection is not found.

    .OUTPUTS
        [hashtable] The collections data, or $null if not found and ThrowOnNotFound is false

    .EXAMPLE
        $collections = Get-CollectionData -ThrowOnNotFound

    .EXAMPLE
        $collections = Get-CollectionData -CollectionName "Work" -ThrowOnNotFound
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $false)]
        [string]$CollectionName,

        [Parameter(Mandatory = $false)]
        [switch]$ThrowOnNotFound
    )

    # Try to use cached collections first
    if (Get-Command Get-CachedCollections -ErrorAction SilentlyContinue) {
        $collections = Get-CachedCollections
    }
    else {
        $collectionsPath = Get-CollectionsFilePath

        if (-not (Test-Path $collectionsPath)) {
            if ($ThrowOnNotFound) {
                $exception = [DataNotFoundException]::new(
                    "No collections found. Run Initialize-EmojiCollections to create default collections."
                )
                Write-EmojiError -Exception $exception -Category ObjectNotFound
                throw $exception
            }
            return $null
        }

        $collections = Get-Content $collectionsPath -Encoding UTF8 | ConvertFrom-Json -AsHashtable
    }

    # Validate specific collection if requested
    if ($CollectionName -and -not $collections.ContainsKey($CollectionName)) {
        if ($ThrowOnNotFound) {
            $exception = [CollectionNotFoundException]::new($CollectionName)
            Write-EmojiError -Exception $exception -Category ObjectNotFound
            throw $exception
        }
        return $null
    }

    return $collections
}

function Save-CollectionData {
    <#
    .SYNOPSIS
        Saves collection data to disk with proper encoding and error handling.

    .DESCRIPTION
        Centralized function to save collection data, ensuring consistent
        encoding and depth settings.

    .PARAMETER Collections
        The hashtable of collections to save.

    .PARAMETER UpdateTimestamp
        If provided with a collection name, updates that collection's modified timestamp.

    .EXAMPLE
        Save-CollectionData -Collections $collections

    .EXAMPLE
        Save-CollectionData -Collections $collections -UpdateTimestamp "Work"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Collections,

        [Parameter(Mandatory = $false)]
        [string]$UpdateTimestamp
    )

    # Update timestamp if requested
    if ($UpdateTimestamp -and $Collections.ContainsKey($UpdateTimestamp)) {
        $Collections[$UpdateTimestamp].modified = (Get-Date).ToString("yyyy-MM-dd")
    }

    # Save to file
    $collectionsPath = Get-CollectionsFilePath
    $Collections | ConvertTo-Json -Depth 10 | Set-Content $collectionsPath -Encoding UTF8
}

function Get-DataFilePath {
    <#
    .SYNOPSIS
        Returns standardized paths to data files.

    .DESCRIPTION
        Provides centralized path construction for various data files used by the module.

    .PARAMETER FileName
        The name of the data file (without path).

    .OUTPUTS
        [string] The full path to the specified data file

    .EXAMPLE
        $historyPath = Get-DataFilePath -FileName "history.json"

    .EXAMPLE
        $statsPath = Get-DataFilePath -FileName "stats.json"
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FileName
    )

    return Join-Path $PSScriptRoot "..\data\$FileName"
}

function Test-ValidCollectionName {
    <#
    .SYNOPSIS
        Validates a collection name format.

    .DESCRIPTION
        Ensures collection names follow allowed patterns (alphanumeric, spaces, hyphens, underscores).

    .PARAMETER Name
        The collection name to validate.

    .PARAMETER ThrowOnError
        If true, throws a DataValidationException on invalid names.

    .OUTPUTS
        [bool] True if valid, false otherwise (when ThrowOnError is false)

    .EXAMPLE
        Test-ValidCollectionName -Name "My Work" -ThrowOnError
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [switch]$ThrowOnError
    )

    # Validate not empty
    if ([string]::IsNullOrWhiteSpace($Name)) {
        if ($ThrowOnError) {
            $exception = [DataValidationException]::new(
                "Collection name cannot be empty or whitespace.",
                @{ Name = $Name }
            )
            Write-EmojiError -Exception $exception -Category InvalidArgument
            throw $exception
        }
        return $false
    }

    # Validate length (1-50 characters)
    if ($Name.Length -gt 50) {
        if ($ThrowOnError) {
            $exception = [DataValidationException]::new(
                "Collection name must be 50 characters or less. Provided: $($Name.Length) characters.",
                @{ Name = $Name; Length = $Name.Length }
            )
            Write-EmojiError -Exception $exception -Category InvalidArgument
            throw $exception
        }
        return $false
    }

    # Validate allowed characters (alphanumeric, spaces, hyphens, underscores)
    if ($Name -notmatch '^[\w\s\-]+$') {
        if ($ThrowOnError) {
            $exception = [DataValidationException]::new(
                "Collection name contains invalid characters. Only alphanumeric, spaces, hyphens, and underscores are allowed.",
                @{ Name = $Name }
            )
            Write-EmojiError -Exception $exception -Category InvalidArgument
            throw $exception
        }
        return $false
    }

    return $true
}

function Invoke-WithRetry {
    <#
    .SYNOPSIS
        Executes a script block with retry logic.

    .DESCRIPTION
        Generic retry wrapper for operations that may fail transiently.
        Provides exponential backoff between retries.

    .PARAMETER ScriptBlock
        The script block to execute.

    .PARAMETER MaxAttempts
        Maximum number of retry attempts (default: 3).

    .PARAMETER InitialDelaySeconds
        Initial delay in seconds before first retry (default: 1).

    .PARAMETER ExponentialBackoff
        If true, doubles delay after each retry.

    .EXAMPLE
        Invoke-WithRetry -ScriptBlock { Get-Content $path } -MaxAttempts 5
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 10)]
        [int]$MaxAttempts = 3,

        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 60)]
        [int]$InitialDelaySeconds = 1,

        [Parameter(Mandatory = $false)]
        [switch]$ExponentialBackoff
    )

    $attempt = 1
    $delay = $InitialDelaySeconds
    $lastException = $null

    while ($attempt -le $MaxAttempts) {
        try {
            Write-Verbose "Attempt $attempt of $MaxAttempts"
            return & $ScriptBlock
        }
        catch {
            $lastException = $_
            Write-Verbose "Attempt $attempt failed: $($_.Exception.Message)"

            if ($attempt -lt $MaxAttempts) {
                Write-Verbose "Waiting $delay seconds before retry..."
                Start-Sleep -Seconds $delay

                if ($ExponentialBackoff) {
                    $delay *= 2
                }
            }

            $attempt++
        }
    }

    # All retries failed
    throw $lastException
}

function Format-EmojiOutput {
    <#
    .SYNOPSIS
        Formats emoji results consistently across commands.

    .DESCRIPTION
        Provides standardized formatting for emoji output with proper spacing
        and column selection.

    .PARAMETER Emojis
        Array of emoji objects to format.

    .PARAMETER IncludeKeywords
        If true, includes the keywords column.

    .OUTPUTS
        Formatted table output

    .EXAMPLE
        Format-EmojiOutput -Emojis $results

    .EXAMPLE
        Format-EmojiOutput -Emojis $results -IncludeKeywords
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowEmptyCollection()]
        [array]$Emojis,

        [Parameter(Mandatory = $false)]
        [switch]$IncludeKeywords
    )

    process {
        if ($null -eq $Emojis -or $Emojis.Count -eq 0) {
            return
        }

        $selectProps = @(
            @{Name = 'Emoji'; Expression = { "$($_.emoji)   " } }
            @{Name = 'Name'; Expression = { $_.name.Trim() } }
            @{Name = 'Category'; Expression = { $_.category } }
        )

        if ($IncludeKeywords) {
            $selectProps += @{Name = 'Keywords'; Expression = { $_.keywords } }
        }

        $Emojis | Select-Object $selectProps | Format-Table -AutoSize
    }
}
