function Get-EmojiStats {
    <#
    .SYNOPSIS
        Get usage statistics for emojis.

    .DESCRIPTION
        Displays statistics about emoji usage, searches, and patterns.
        Tracks most used emojis, popular searches, category distribution, etc.

    .PARAMETER Type
        Type of statistics to display: Usage, Search, Categories, All

    .PARAMETER Top
        Number of top results to show (default: 10)

    .PARAMETER Since
        Show statistics since a specific date (default: all time)

    .EXAMPLE
        Get-EmojiStats
        Shows all statistics

    .EXAMPLE
        Get-EmojiStats -Type Usage -Top 5
        Shows top 5 most used emojis

    .EXAMPLE
        Get-EmojiStats -Type Search -Since "2025-10-01"
        Shows search statistics since October 1st
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Function retrieves multiple statistics, plural is semantically correct')]

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('Usage', 'Search', 'Categories', 'Collections', 'All')]
        [string]$Type = 'All',

        [Parameter(Mandatory = $false)]
        [int]$Top = 10,

        [Parameter(Mandatory = $false)]
        [datetime]$Since
    )

    $statsPath = Join-Path $PSScriptRoot "..\data\stats.json"

    if (-not (Test-Path $statsPath)) {
        Write-Information "📊 No statistics available yet." -InformationAction Continue
        Write-Information "   Statistics will be collected as you use emoji functions." -InformationAction Continue
        return
    }

    $stats = Get-Content $statsPath -Encoding UTF8 | ConvertFrom-Json

    # Filter by date if specified
    if ($Since) {
        if ($stats.emojiUsage) {
            $stats.emojiUsage = $stats.emojiUsage | Where-Object {
                [datetime]$_.lastUsed -ge $Since
            }
        }
        if ($stats.searches) {
            $stats.searches = $stats.searches | Where-Object {
                [datetime]$_.timestamp -ge $Since
            }
        }
    }

    # Display formatted statistics (Write-Host is appropriate here for formatted console output)
    Write-Host "`n📊 Emoji Statistics" -ForegroundColor Cyan
    Write-Host "=" * 60 -ForegroundColor Gray

    if ($Type -eq 'All' -or $Type -eq 'Usage') {
        Write-Host "`n🏆 Most Used Emojis" -ForegroundColor Yellow
        if ($stats.emojiUsage -and $stats.emojiUsage.Count -gt 0) {
            $topEmojis = $stats.emojiUsage |
                Sort-Object -Property count -Descending |
                Select-Object -First $Top

            $i = 1
            foreach ($item in $topEmojis) {
                Write-Host ("  {0,2}. {1} - {2} ({3} times)" -f $i, $item.emoji, $item.name, $item.count) -ForegroundColor White
                $i++
            }
        }
        else {
            Write-Host "  No usage data yet" -ForegroundColor Gray
        }
    }

    if ($Type -eq 'All' -or $Type -eq 'Search') {
        Write-Host "`n🔍 Popular Searches" -ForegroundColor Yellow
        if ($stats.searches -and $stats.searches.Count -gt 0) {
            $searchGroups = $stats.searches |
                Group-Object -Property query |
                Sort-Object -Property Count -Descending |
                Select-Object -First $Top

            $i = 1
            foreach ($group in $searchGroups) {
                Write-Host ("  {0,2}. '{1}' ({2} times)" -f $i, $group.Name, $group.Count) -ForegroundColor White
                $i++
            }
        }
        else {
            Write-Host "  No search data yet" -ForegroundColor Gray
        }
    }

    if ($Type -eq 'All' -or $Type -eq 'Categories') {
        Write-Host "`n📁 Category Usage" -ForegroundColor Yellow
        if ($stats.emojiUsage -and $stats.emojiUsage.Count -gt 0) {
            $categoryStats = $stats.emojiUsage |
                Group-Object -Property category |
                Sort-Object -Property Count -Descending

            foreach ($cat in $categoryStats) {
                $totalUses = ($cat.Group | Measure-Object -Property count -Sum).Sum
                $categoryName = if ([string]::IsNullOrWhiteSpace($cat.Name)) { "(Unknown)" } else { $cat.Name }
                Write-Host ("  {0,-30} {1,4} emojis, {2,6} uses" -f $categoryName, $cat.Count, $totalUses) -ForegroundColor White
            }
        }
        else {
            Write-Host "  No category data yet" -ForegroundColor Gray
        }
    }

    if ($Type -eq 'All' -or $Type -eq 'Collections') {
        Write-Host "`n📚 Collection Usage" -ForegroundColor Yellow
        if ($stats.collectionUsage -and $stats.collectionUsage.PSObject.Properties.Count -gt 0) {
            $collectionStats = $stats.collectionUsage.PSObject.Properties |
                Sort-Object -Property Value -Descending

            foreach ($coll in $collectionStats) {
                Write-Host ("  {0,-20} {1,4} times" -f $coll.Name, $coll.Value) -ForegroundColor White
            }
        }
        else {
            Write-Host "  No collection data yet" -ForegroundColor Gray
        }
    }

    if ($Type -eq 'All') {
        Write-Host "`n📈 Summary" -ForegroundColor Yellow
        $totalSearches = if ($stats.searches) { $stats.searches.Count } else { 0 }
        $totalEmojiUses = if ($stats.emojiUsage) { ($stats.emojiUsage | Measure-Object -Property count -Sum).Sum } else { 0 }
        $uniqueEmojis = if ($stats.emojiUsage) { $stats.emojiUsage.Count } else { 0 }

        Write-Host "  Total searches: $totalSearches" -ForegroundColor White
        Write-Host "  Total emoji uses: $totalEmojiUses" -ForegroundColor White
        Write-Host "  Unique emojis used: $uniqueEmojis" -ForegroundColor White

        if ($stats.emojiUsage -and $stats.emojiUsage.Count -gt 0) {
            $avgUses = [math]::Round($totalEmojiUses / $uniqueEmojis, 2)
            Write-Host "  Average uses per emoji: $avgUses" -ForegroundColor White
        }
    }

    Write-Host "`n" -NoNewline
}

function Clear-EmojiStats {
    <#
    .SYNOPSIS
        Clears emoji usage statistics.

    .DESCRIPTION
        Removes all or specific types of statistics data.

    .PARAMETER Type
        Type of statistics to clear: Usage, Search, All

    .PARAMETER Force
        Skip confirmation prompt

    .EXAMPLE
        Clear-EmojiStats -Type Search
        Clears search statistics

    .EXAMPLE
        Clear-EmojiStats -Type All -Force
        Clears all statistics without confirmation
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Function clears multiple statistics, plural is semantically correct')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('Usage', 'Search', 'Collections', 'All')]
        [string]$Type = 'All',

        [Parameter(Mandatory = $false)]
        [switch]$Force
    )

    $statsPath = Join-Path $PSScriptRoot "..\data\stats.json"

    if (-not (Test-Path $statsPath)) {
        Write-Host "No statistics to clear." -ForegroundColor Yellow
        return
    }

    if (-not $Force) {
        $confirm = Read-Host "Clear $Type statistics? (y/N)"
        if ($confirm -ne 'y') {
            Write-Host "Cancelled." -ForegroundColor Yellow
            return
        }
    }

    $stats = Get-Content $statsPath -Encoding UTF8 | ConvertFrom-Json -AsHashtable

    switch ($Type) {
        'Usage' { $stats.emojiUsage = @() }
        'Search' { $stats.searches = @() }
        'Collections' { $stats.collectionUsage = @{} }
        'All' {
            $stats = @{
                emojiUsage = @()
                searches = @()
                collectionUsage = @{}
            }
        }
    }

    $stats | ConvertTo-Json -Depth 10 | Set-Content $statsPath -Encoding UTF8

    Write-Host "✅ Cleared $Type statistics" -ForegroundColor Green
}

function Export-EmojiStats {
    <#
    .SYNOPSIS
        Exports statistics to a file.

    .DESCRIPTION
        Exports emoji usage statistics to JSON, CSV, or HTML format.

    .PARAMETER Path
        Output file path

    .PARAMETER Format
        Export format: JSON, CSV, HTML

    .EXAMPLE
        Export-EmojiStats -Path "stats.json"
        Exports statistics to JSON

    .EXAMPLE
        Export-EmojiStats -Path "stats.html" -Format HTML
        Exports statistics to HTML report
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Function exports multiple statistics, plural is semantically correct')]

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [ValidateSet('JSON', 'CSV', 'HTML')]
        [string]$Format = 'JSON'
    )

    $statsPath = Join-Path $PSScriptRoot "..\data\stats.json"

    if (-not (Test-Path $statsPath)) {
        Write-Error "No statistics available to export."
        return
    }

    $stats = Get-Content $statsPath -Encoding UTF8 | ConvertFrom-Json

    switch ($Format) {
        'JSON' {
            $stats | ConvertTo-Json -Depth 10 | Set-Content $Path -Encoding UTF8
        }
        'CSV' {
            # Export usage as CSV
            if ($stats.emojiUsage) {
                $stats.emojiUsage | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8
            }
        }
        'HTML' {
            $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Emoji Statistics Report</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 40px; background: #f5f5f5; }
        h1 { color: #333; }
        h2 { color: #666; margin-top: 30px; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; background: white; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #4CAF50; color: white; }
        tr:hover { background-color: #f5f5f5; }
        .emoji { font-size: 24px; }
        .summary { background: white; padding: 20px; border-radius: 5px; margin: 20px 0; }
        .stat { display: inline-block; margin: 10px 20px; }
        .stat-value { font-size: 32px; font-weight: bold; color: #4CAF50; }
        .stat-label { color: #666; }
    </style>
</head>
<body>
    <h1>📊 Emoji Statistics Report</h1>
    <p>Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>

    <div class="summary">
        <h2>Summary</h2>
        <div class="stat">
            <div class="stat-value">$($stats.searches.Count)</div>
            <div class="stat-label">Total Searches</div>
        </div>
        <div class="stat">
            <div class="stat-value">$(($stats.emojiUsage | Measure-Object -Property count -Sum).Sum)</div>
            <div class="stat-label">Total Uses</div>
        </div>
        <div class="stat">
            <div class="stat-value">$($stats.emojiUsage.Count)</div>
            <div class="stat-label">Unique Emojis</div>
        </div>
    </div>

    <h2>🏆 Most Used Emojis</h2>
    <table>
        <tr><th>Rank</th><th>Emoji</th><th>Name</th><th>Uses</th><th>Last Used</th></tr>
"@
            $rank = 1
            $topEmojis = $stats.emojiUsage | Sort-Object -Property count -Descending | Select-Object -First 20
            foreach ($emoji in $topEmojis) {
                $html += @"
        <tr>
            <td>$rank</td>
            <td class="emoji">$($emoji.emoji)</td>
            <td>$($emoji.name)</td>
            <td>$($emoji.count)</td>
            <td>$($emoji.lastUsed)</td>
        </tr>
"@
                $rank++
            }

            $html += @"
    </table>

    <h2>🔍 Popular Searches</h2>
    <table>
        <tr><th>Rank</th><th>Query</th><th>Count</th></tr>
"@
            $rank = 1
            $searchGroups = $stats.searches | Group-Object -Property query | Sort-Object -Property Count -Descending | Select-Object -First 20
            foreach ($group in $searchGroups) {
                $html += @"
        <tr>
            <td>$rank</td>
            <td>$($group.Name)</td>
            <td>$($group.Count)</td>
        </tr>
"@
                $rank++
            }

            $html += @"
    </table>
</body>
</html>
"@
            $html | Set-Content $Path -Encoding UTF8
        }
    }

    Write-Host "✅ Exported statistics to $Path" -ForegroundColor Green
}

function Write-EmojiUsage {
    <#
    .SYNOPSIS
        Writes emoji usage to statistics log.

    .DESCRIPTION
        Internal function to track emoji usage statistics.

    .PARAMETER Emoji
        The emoji that was used

    .PARAMETER Name
        Name of the emoji

    .PARAMETER Category
        Category of the emoji
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Emoji,

        [Parameter(Mandatory = $false)]
        [string]$Name = "",

        [Parameter(Mandatory = $false)]
        [string]$Category = ""
    )

    $statsPath = Join-Path $PSScriptRoot "..\data\stats.json"

    # Load or create stats
    $stats = @{
        emojiUsage = @()
        searches = @()
        collectionUsage = @{}
    }

    if (Test-Path $statsPath) {
        $stats = Get-Content $statsPath -Encoding UTF8 | ConvertFrom-Json -AsHashtable
    }

    # Find existing entry
    $existing = $stats.emojiUsage | Where-Object { $_.emoji -eq $Emoji }

    if ($existing) {
        $existing.count++
        $existing.lastUsed = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    }
    else {
        $stats.emojiUsage += @{
            emoji = $Emoji
            name = $Name
            category = $Category
            count = 1
            lastUsed = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        }
    }

    # Save
    $stats | ConvertTo-Json -Depth 10 | Set-Content $statsPath -Encoding UTF8
}

function Write-EmojiSearch {
    <#
    .SYNOPSIS
        Writes search query to statistics log.

    .DESCRIPTION
        Internal function to track search statistics.

    .PARAMETER Query
        The search query

    .PARAMETER ResultCount
        Number of results returned
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Query,

        [Parameter(Mandatory = $false)]
        [int]$ResultCount = 0
    )

    $statsPath = Join-Path $PSScriptRoot "..\data\stats.json"

    # Load or create stats
    $stats = @{
        emojiUsage = @()
        searches = @()
        collectionUsage = @{}
    }

    if (Test-Path $statsPath) {
        $stats = Get-Content $statsPath -Encoding UTF8 | ConvertFrom-Json -AsHashtable
    }

    # Add search
    $stats.searches += @{
        query = $Query
        resultCount = $ResultCount
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    }

    # Save
    $stats | ConvertTo-Json -Depth 10 | Set-Content $statsPath -Encoding UTF8
}

function Write-CollectionUsage {
    <#
    .SYNOPSIS
        Writes collection usage to statistics log.

    .DESCRIPTION
        Internal function to track collection statistics.

    .PARAMETER CollectionName
        Name of the collection used
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$CollectionName
    )

    $statsPath = Join-Path $PSScriptRoot "..\data\stats.json"

    # Load or create stats
    $stats = @{
        emojiUsage = @()
        searches = @()
        collectionUsage = @{}
    }

    if (Test-Path $statsPath) {
        $stats = Get-Content $statsPath -Encoding UTF8 | ConvertFrom-Json -AsHashtable
    }

    # Initialize collectionUsage if needed
    if (-not $stats.collectionUsage) {
        $stats.collectionUsage = @{}
    }

    # Increment count
    if ($stats.collectionUsage.ContainsKey($CollectionName)) {
        $stats.collectionUsage[$CollectionName]++
    }
    else {
        $stats.collectionUsage[$CollectionName] = 1
    }

    # Save
    $stats | ConvertTo-Json -Depth 10 | Set-Content $statsPath -Encoding UTF8
}
