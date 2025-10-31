function Get-Emoji {
    <#
    .SYNOPSIS
        Retrieves all emojis from the emoji dataset.

    .DESCRIPTION
        Returns all emojis from the loaded emoji dataset with their names,
        keywords, and other metadata. Can filter by category or custom collection.

    .PARAMETER Category
        Filter emojis by category (e.g., "Smileys & Emotion", "Animals & Nature")

    .PARAMETER Collection
        Filter emojis by custom collection (e.g., "Work", "Gaming")

    .PARAMETER Limit
        Limit the number of results returned

    .EXAMPLE
        Get-Emoji
        Returns all emojis in the dataset

    .EXAMPLE
        Get-Emoji -Category "Smileys & Emotion" -Limit 10
        Returns the first 10 emojis from the Smileys & Emotion category

    .EXAMPLE
        Get-Emoji -Collection "Work"
        Returns all emojis from your Work collection
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Category,

        [Parameter(Mandatory = $false)]
        [string]$Collection,

        [Parameter(Mandatory = $false)]
        [int]$Limit = 0
    )

    if ($null -eq $Script:EmojiData -or $Script:EmojiData.Count -eq 0) {
        Write-Warning "No emoji data loaded. Run Update-EmojiDataset to download the emoji data."
        return
    }

    $results = $Script:EmojiData

    # Filter by collection if specified (using cached collections - Phase 1)
    if ($Collection) {
        # Use cached collections
        if (Get-Command Get-CachedCollections -ErrorAction SilentlyContinue) {
            $collections = Get-CachedCollections
        }
        else {
            $collectionsPath = Join-Path $PSScriptRoot "..\data\collections.json"
            if (-not (Test-Path $collectionsPath)) {
                Write-Error "No collections found. Run Initialize-EmojiCollections to create default collections."
                return
            }
            $collections = Get-Content $collectionsPath -Encoding UTF8 | ConvertFrom-Json -AsHashtable
        }

        if (-not $collections.ContainsKey($Collection)) {
            Write-Error "Collection '$Collection' not found. Run Get-EmojiCollection to see available collections."
            return
        }

        $collectionEmojis = $collections[$Collection].emojis
        $results = $results | Where-Object { $collectionEmojis -contains $_.emoji }
    }

    # Filter by category if specified (using indexed lookup - Phase 2)
    if ($Category) {
        # Try using category index for faster lookup
        if (Get-Command Get-EmojiByCategory -ErrorAction SilentlyContinue) {
            Write-Verbose "Using category index for filtering"
            $categoryResults = Get-EmojiByCategory -Category $Category

            # If collection was also specified, intersect the results
            if ($Collection) {
                $results = $results | Where-Object { $categoryResults -contains $_ }
            }
            else {
                $results = $categoryResults
            }
        }
        else {
            # Fallback to linear search
            Write-Verbose "Using linear category search (index not available)"
            $results = $results | Where-Object {
                $_.category -like "*$Category*" -or $_.group -like "*$Category*"
            }
        }
    }

    # Apply limit if specified
    if ($Limit -gt 0) {
        $results = $results | Select-Object -First $Limit
    }

    # Return formatted results
    # Add extra spacing after emoji to compensate for display width variance
    $results | Select-Object `
    @{Name = 'Emoji'; Expression = { "$($_.emoji)   " } }, `
    @{Name = 'Name'; Expression = { $_.name.Trim() } }, `
    @{Name = 'Category'; Expression = { $_.category } }, `
    @{Name = 'Keywords'; Expression = { $_.keywords } } |
        Format-Table -AutoSize
}
