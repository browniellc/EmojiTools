function Copy-Emoji {
    <#
    .SYNOPSIS
        Copies an emoji to the clipboard.

    .DESCRIPTION
        The Copy-Emoji function copies emojis to the system clipboard for easy pasting into
        other applications. It can accept emoji input directly via pipeline, or search for
        emojis using a query string.

        When multiple emojis are found, the function provides options to copy the first result,
        all results (space-separated), or interactively select one using a grid view.

    .PARAMETER Emoji
        The emoji character(s) to copy to clipboard. Accepts pipeline input.

    .PARAMETER Query
        Search query to find emoji(s) before copying. Uses fuzzy search.

    .PARAMETER First
        When multiple emojis are found, copy only the first result. This is the default behavior.

    .PARAMETER All
        When multiple emojis are found, copy all results separated by spaces.

    .PARAMETER Silent
        Suppress the confirmation message after copying.

    .EXAMPLE
        Copy-Emoji -Query "smile"
        Searches for "smile" and copies the first matching emoji to clipboard.

    .EXAMPLE
        Search-Emoji -Query "heart" | Copy-Emoji
        Searches for heart emojis and copies them to clipboard via pipeline.

    .EXAMPLE
        Copy-Emoji -Query "animals" -All
        Copies all animal emojis to clipboard, separated by spaces.

    .EXAMPLE
        Get-Emoji -Category "Smileys" -Limit 1 | Copy-Emoji -Silent
        Gets a smiley emoji and copies it to clipboard without showing a message.

    .EXAMPLE
        Copy-Emoji "🎉"
        Directly copies the provided emoji to clipboard.

    .NOTES
        Clipboard functionality:
        - Windows: Uses native Set-Clipboard cmdlet
        - macOS: Requires pbcopy (usually pre-installed)
        - Linux: Requires xclip or xsel utilities
    #>
    [CmdletBinding(DefaultParameterSetName = 'Direct')]
    param(
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Direct',
            Position = 0
        )]
        [string]$Emoji,

        [Parameter(
            ParameterSetName = 'Search',
            Position = 0
        )]
        [string]$Query,

        [Parameter()]
        [switch]$First,

        [Parameter()]
        [switch]$All,

        [Parameter()]
        [switch]$Silent
    )

    begin {
        $emojiCollection = @()
        $emojiToCopy = $null
    }

    process {
        # If Query is provided, search for emojis
        if ($PSCmdlet.ParameterSetName -eq 'Search' -and $Query) {
            try {
                # Perform the search directly on the emoji data (without Format-Table)
                $normalizedQuery = $Query.Trim().ToLower()
                $pattern = "*$normalizedQuery*"

                $results = $Script:EmojiData | Where-Object {
                    $nameMatch = $_.name -like $pattern
                    $keywordMatch = $_.keywords -like $pattern
                    $words = $_.name -split '\s+'
                    $wordMatch = $words | Where-Object { $_ -like $pattern }
                    $nameMatch -or $keywordMatch -or $wordMatch
                }

                # Sort by relevance
                $results = $results | Sort-Object {
                    if ($_.name -eq $normalizedQuery) { 0 }
                    elseif ($_.name -like $pattern) { 1 }
                    else { 2 }
                }

                if ($null -eq $results -or $results.Count -eq 0) {
                    Write-Error "No emoji found matching '$Query'"
                    return
                }

                # Determine which emoji(s) to copy
                if ($results.Count -eq 1) {
                    # Single result - just copy it
                    $emojiToCopy = $results.emoji
                }
                elseif ($All) {
                    # Copy all results space-separated
                    $emojiToCopy = ($results.emoji -join ' ')
                }
                elseif ($First) {
                    # Copy first result only
                    $emojiToCopy = $results[0].emoji
                }
                else {
                    # Default behavior: copy first result
                    $emojiToCopy = $results[0].emoji
                    if ($results.Count -gt 1 -and -not $Silent) {
                        Write-Warning "Found $($results.Count) emojis. Copying first result '$($results[0].emoji)'. Use -All to copy all."
                    }
                }
            }
            catch {
                Write-Error "Error searching for emoji: $_"
                return
            }
        }

        # Collect emojis from pipeline
        if ($Emoji) {
            $emojiCollection += $Emoji
        }
    }

    end {
        # Determine final emoji to copy
        $finalEmoji = $null

        if ($emojiToCopy) {
            # From query search
            $finalEmoji = $emojiToCopy
        }
        elseif ($emojiCollection.Count -gt 0) {
            # From pipeline
            $finalEmoji = if ($emojiCollection.Count -eq 1) {
                $emojiCollection[0]
            }
            else {
                $emojiCollection -join ' '
            }
        }

        # Validate we have something to copy
        if ([string]::IsNullOrWhiteSpace($finalEmoji)) {
            Write-Error "No emoji to copy. Provide an emoji directly or use -Query to search."
            return
        }

        # Copy to clipboard (cross-platform support)
        try {
            if ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6) {
                # Windows or Windows PowerShell
                Set-Clipboard -Value $finalEmoji
            }
            elseif ($IsMacOS) {
                # macOS
                $finalEmoji | pbcopy
            }
            elseif ($IsLinux) {
                # Linux - try xclip first, then xsel
                if (Get-Command xclip -ErrorAction SilentlyContinue) {
                    $finalEmoji | xclip -selection clipboard
                }
                elseif (Get-Command xsel -ErrorAction SilentlyContinue) {
                    $finalEmoji | xsel --clipboard --input
                }
                else {
                    Write-Error "Clipboard functionality requires 'xclip' or 'xsel' on Linux. Install with: sudo apt-get install xclip"
                    return
                }
            }

            # Success message
            if (-not $Silent) {
                Write-Host "Copied $finalEmoji to clipboard" -ForegroundColor Green
            }

            # Track usage statistics
            if (Get-Command Write-EmojiUsage -ErrorAction SilentlyContinue) {
                # Track each emoji copied
                $emojis = $finalEmoji -split '\s+'
                foreach ($e in $emojis) {
                    if ($e.Trim()) {
                        # Try to look up emoji details from dataset
                        $emojiData = $Script:EmojiData | Where-Object { $_.emoji -eq $e.Trim() } | Select-Object -First 1
                        if ($emojiData) {
                            Write-EmojiUsage -Emoji $e.Trim() -Name $emojiData.name -Category $emojiData.category
                        }
                        else {
                            Write-EmojiUsage -Emoji $e.Trim() -Name "" -Category ""
                        }
                    }
                }
            }
        }
        catch {
            Write-Error "Failed to copy to clipboard: $_"
        }
    }
}
