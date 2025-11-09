function Search-Emoji {
    <#
    .SYNOPSIS
        Search for emojis by name or keyword.

    .DESCRIPTION
        Performs a fuzzy search on the emoji dataset by name or keywords.
        Supports wildcard matching and multiple search terms. Can search within
        a specific custom collection.

    .PARAMETER Query
        The search term(s) to look for in emoji names and keywords

    .PARAMETER Collection
        Limit search to a specific custom collection

    .PARAMETER Exact
        Perform exact matching instead of fuzzy search

    .PARAMETER Limit
        Limit the number of results returned

    .EXAMPLE
        Search-Emoji -Query "house"
        Searches for all emojis matching "house" (🏠 🏡 etc.)

    .EXAMPLE
        Search-Emoji -Query "smile" -Limit 5
        Returns the first 5 emojis matching "smile"

    .EXAMPLE
        Search-Emoji -Query "computer" -Collection "Work"
        Searches for computer emojis only in your Work collection

    .EXAMPLE
        Search-Emoji -Query "heart" -Exact
        Returns emojis with exact "heart" matches
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Query,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Collection,

        [Parameter(Mandatory = $false)]
        [switch]$Exact,

        [Parameter(Mandatory = $false)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$Limit = 0
    )

    # Validate emoji data is loaded
    [void](Test-EmojiDataLoaded -ThrowOnError)

    # Check cache first (Phase 1 optimization)
    if (Get-Command Get-CachedSearchResult -ErrorAction SilentlyContinue) {
        $cachedResults = Get-CachedSearchResult -Query $Query -Collection $Collection -Exact $Exact.IsPresent
        if ($null -ne $cachedResults) {
            Write-Verbose "Using cached results for query: $Query"
            $results = $cachedResults

            # Apply limit if specified
            if ($Limit -gt 0) {
                $results = $results | Select-Object -First $Limit
            }

            # Return formatted results
            $results | Select-Object `
            @{Name = 'Emoji'; Expression = { $_.emoji } }, `
            @{Name = 'Name'; Expression = { $_.name.Trim() } }, `
            @{Name = 'Category'; Expression = { $_.category } }, `
            @{Name = 'Keywords'; Expression = { $_.keywords } } |
                Format-Table -AutoSize -Wrap
            return
        }
    }

    $searchData = $Script:EmojiData

    # Filter by collection if specified
    if ($Collection) {
        $collections = Get-CollectionData -CollectionName $Collection -ThrowOnNotFound
        $collectionEmojis = $collections[$Collection].emojis
        $searchData = $searchData | Where-Object { $collectionEmojis -contains $_.emoji }
    }

    # Normalize query for better matching
    $normalizedQuery = $Query.Trim().ToLower()

    # Try indexed search first (Phase 2 optimization)
    if (Get-Command Search-IndexedEmoji -ErrorAction SilentlyContinue) {
        Write-Verbose "Using indexed search"
        $results = Search-IndexedEmoji -Query $normalizedQuery -Exact $Exact.IsPresent

        # If collection specified, filter the indexed results
        if ($Collection) {
            $results = $results | Where-Object { $searchData -contains $_ }
        }
    }
    else {
        # Fallback to linear search
        Write-Verbose "Using linear search (indices not available)"

        # Build search pattern
        if ($Exact) {
            $pattern = "^$normalizedQuery$"
        }
        else {
            $pattern = "*$normalizedQuery*"
        }

        # Search in name and keywords
        $results = $searchData | Where-Object {
            $nameMatch = $_.name -like $pattern
            $keywordMatch = $_.keywords -like $pattern

            # Also check if query matches individual words in name
            $words = $_.name -split '\s+'
            $wordMatch = [bool]($words | Where-Object { $_ -like $pattern })

            $nameMatch -or $keywordMatch -or $wordMatch
        }
    }


    if ($results.Count -eq 0) {
        Write-EmojiWarning -Message "No emojis found matching '$Query'" -WarningCode "NO_RESULTS"
        # Track search with zero results
        if (Get-Command Write-EmojiSearch -ErrorAction SilentlyContinue) {
            Write-EmojiSearch -Query $normalizedQuery -ResultCount 0
        }
        return
    }

    # Cache the results for future use (Phase 1 optimization)
    if (Get-Command Set-CachedSearchResult -ErrorAction SilentlyContinue) {
        Set-CachedSearchResult -Query $Query -Collection $Collection -Exact $Exact.IsPresent -Results $results
    }

    # Track search statistics
    if (Get-Command Write-EmojiSearch -ErrorAction SilentlyContinue) {
        Write-EmojiSearch -Query $normalizedQuery -ResultCount $results.Count
    }

    # Track collection usage if filtered
    if ($Collection -and (Get-Command Write-CollectionUsage -ErrorAction SilentlyContinue)) {
        Write-CollectionUsage -CollectionName $Collection
    }

    # Apply limit if specified
    if ($Limit -gt 0) {
        $results = $results | Select-Object -First $Limit
    }

    # Return formatted results
    # Add extra spacing after emoji to compensate for display width variance
    $results | Select-Object `
    @{Name = 'Emoji'; Expression = { $_.emoji } }, `
    @{Name = 'Name'; Expression = { $_.name.Trim() } }, `
    @{Name = 'Category'; Expression = { $_.category } }, `
    @{Name = 'Keywords'; Expression = { $_.keywords } } |
        Format-Table -AutoSize -Wrap
}
