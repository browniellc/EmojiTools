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
        [ValidateNotNullOrEmpty()]
        [string]$Category,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Collection,

        [Parameter(Mandatory = $false)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$Limit = 0
    )

    # Validate emoji data is loaded
    [void](Test-EmojiDataLoaded -ThrowOnError)

    $results = $Script:EmojiData

    # Filter by collection if specified
    if ($Collection) {
        $collections = Get-CollectionData -CollectionName $Collection -ThrowOnNotFound
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
    Format-EmojiOutput -Emojis $results -IncludeKeywords
}
