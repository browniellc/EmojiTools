function Save-EmojiUpdateHistory {
    <#
    .SYNOPSIS
        Saves emoji update history after a dataset update.

    .DESCRIPTION
        Internal function that compares the previous and new emoji datasets,
        calculates the differences, and saves the update history.

    .PARAMETER PreviousData
        The emoji dataset before the update

    .PARAMETER NewData
        The emoji dataset after the update

    .PARAMETER Source
        The source of the update (Unicode, GitHub, Custom, File)

    .PARAMETER Version
        Optional version information (e.g., CLDR version)

    .EXAMPLE
        Save-EmojiUpdateHistory -PreviousData $oldData -NewData $newData -Source "Unicode" -Version "CLDR 46"
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Internal function called by Update-EmojiDataset which has ShouldProcess')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [array]$PreviousData = @(),

        [Parameter(Mandatory = $true)]
        [array]$NewData,

        [Parameter(Mandatory = $true)]
        [string]$Source,

        [Parameter(Mandatory = $false)]
        [string]$Version = $null
    )

    $historyPath = Join-Path $PSScriptRoot "..\data\history.json"

    # Load existing history or create new
    $history = @{ updates = @() }
    if (Test-Path $historyPath) {
        try {
            $history = Get-Content $historyPath -Encoding UTF8 | ConvertFrom-Json -AsHashtable
        }
        catch {
            Write-Warning "Could not load history file, creating new: $_"
            $history = @{ updates = @() }
        }
    }

    # Calculate differences
    $previousEmojis = @{}
    foreach ($emoji in $PreviousData) {
        $key = $emoji.emoji
        $previousEmojis[$key] = $emoji
    }

    $newEmojis = @{}
    foreach ($emoji in $NewData) {
        $key = $emoji.emoji
        $newEmojis[$key] = $emoji
    }

    # Find added emojis
    $added = @()
    foreach ($key in $newEmojis.Keys) {
        if (-not $previousEmojis.ContainsKey($key)) {
            $added += @{
                emoji = $newEmojis[$key].emoji
                name = $newEmojis[$key].name
                category = $newEmojis[$key].category
            }
        }
    }

    # Find removed emojis
    $removed = @()
    foreach ($key in $previousEmojis.Keys) {
        if (-not $newEmojis.ContainsKey($key)) {
            $removed += @{
                emoji = $previousEmojis[$key].emoji
                name = $previousEmojis[$key].name
                category = $previousEmojis[$key].category
            }
        }
    }

    # Find modified emojis (name or category changed)
    $modified = @()
    foreach ($key in $newEmojis.Keys) {
        if ($previousEmojis.ContainsKey($key)) {
            $old = $previousEmojis[$key]
            $new = $newEmojis[$key]

            if ($old.name -ne $new.name -or $old.category -ne $new.category) {
                $modified += @{
                    emoji = $new.emoji
                    oldName = $old.name
                    newName = $new.name
                    oldCategory = $old.category
                    newCategory = $new.category
                }
            }
        }
    }

    # Create update record
    $updateRecord = @{
        date = (Get-Date).ToString("o")  # ISO 8601 format
        source = $Source
        version = $Version
        previousCount = $PreviousData.Count
        newCount = $NewData.Count
        added = $added
        removed = $removed
        modified = $modified
    }

    # Add to history (newest first)
    $history.updates = @($updateRecord) + $history.updates

    # Save history
    try {
        $history | ConvertTo-Json -Depth 10 | Set-Content $historyPath -Encoding UTF8

        # Show summary if there are changes
        if ($added.Count -gt 0 -or $removed.Count -gt 0 -or $modified.Count -gt 0) {
            Write-Host "`n📊 Dataset Changes:" -ForegroundColor Cyan
            if ($added.Count -gt 0) {
                Write-Host "   +$($added.Count) emojis added" -ForegroundColor Green
            }
            if ($removed.Count -gt 0) {
                Write-Host "   -$($removed.Count) emojis removed" -ForegroundColor Yellow
            }
            if ($modified.Count -gt 0) {
                Write-Host "   ~$($modified.Count) emojis modified" -ForegroundColor Cyan
            }
            Write-Host "   💡 Run 'Get-NewEmojis' to see what's new!`n" -ForegroundColor Gray
        }
    }
    catch {
        Write-Warning "Failed to save update history: $_"
    }
}

function Get-EmojiUpdateHistory {
    <#
    .SYNOPSIS
        Retrieves emoji update history.

    .DESCRIPTION
        Shows the history of emoji dataset updates including what was added,
        removed, or modified in each update.

    .PARAMETER Latest
        Show only the most recent update

    .PARAMETER Last
        Show the last N updates (default: all)

    .PARAMETER Since
        Show updates since a specific date

    .PARAMETER Source
        Filter by source (Unicode, GitHub, Custom, File)

    .EXAMPLE
        Get-EmojiUpdateHistory
        Shows all update history

    .EXAMPLE
        Get-EmojiUpdateHistory -Latest
        Shows only the most recent update

    .EXAMPLE
        Get-EmojiUpdateHistory -Last 5
        Shows the last 5 updates

    .EXAMPLE
        Get-EmojiUpdateHistory -Since "2025-01-01"
        Shows updates since January 1st, 2025

    .EXAMPLE
        Get-EmojiUpdateHistory -Source Unicode
        Shows only Unicode CLDR updates
    #>
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param(
        [Parameter(ParameterSetName = 'Latest')]
        [switch]$Latest,

        [Parameter(ParameterSetName = 'Last')]
        [int]$Last,

        [Parameter(ParameterSetName = 'Since')]
        [datetime]$Since,

        [Parameter()]
        [ValidateSet('Unicode', 'GitHub', 'Custom', 'File')]
        [string]$Source
    )

    $historyPath = Join-Path $PSScriptRoot "..\data\history.json"

    if (-not (Test-Path $historyPath)) {
        Write-Host "📊 No update history available yet." -ForegroundColor Yellow
        Write-Host "   History tracking begins after your first dataset update." -ForegroundColor Gray
        return
    }

    try {
        $history = Get-Content $historyPath -Encoding UTF8 | ConvertFrom-Json -AsHashtable
        $updates = $history.updates

        # Filter by source
        if ($Source) {
            $updates = $updates | Where-Object { $_.source -eq $Source }
        }

        # Filter by date
        if ($Since) {
            $updates = $updates | Where-Object { [datetime]$_.date -ge $Since }
        }

        # Limit results
        if ($Latest) {
            $updates = $updates | Select-Object -First 1
        }
        elseif ($Last) {
            $updates = $updates | Select-Object -First $Last
        }

        if ($updates.Count -eq 0) {
            Write-Host "📊 No updates found matching your criteria." -ForegroundColor Yellow
            return
        }

        # Display updates
        Write-Host "`n📊 Emoji Update History" -ForegroundColor Cyan
        Write-Host ("=" * 80) -ForegroundColor Cyan

        foreach ($update in $updates) {
            $date = [datetime]$update.date
            $daysAgo = (New-TimeSpan -Start $date -End (Get-Date)).Days

            Write-Host "`n📅 $($date.ToString('yyyy-MM-dd HH:mm'))" -ForegroundColor White -NoNewline
            Write-Host " ($daysAgo days ago)" -ForegroundColor Gray
            Write-Host "   Source: $($update.source)" -ForegroundColor Cyan -NoNewline
            if ($update.version) {
                Write-Host " | Version: $($update.version)" -ForegroundColor Cyan
            }
            else {
                Write-Host ""
            }

            Write-Host "   Total: $($update.previousCount) → $($update.newCount) emojis" -ForegroundColor White

            if ($update.added.Count -gt 0) {
                Write-Host "   ✅ Added: $($update.added.Count) emojis" -ForegroundColor Green
            }
            if ($update.removed.Count -gt 0) {
                Write-Host "   ❌ Removed: $($update.removed.Count) emojis" -ForegroundColor Yellow
            }
            if ($update.modified.Count -gt 0) {
                Write-Host "   🔄 Modified: $($update.modified.Count) emojis" -ForegroundColor Cyan
            }

            if ($update.added.Count -eq 0 -and $update.removed.Count -eq 0 -and $update.modified.Count -eq 0) {
                Write-Host "   ℹ️  No changes" -ForegroundColor Gray
            }
        }

        Write-Host ""
    }
    catch {
        Write-Error "Failed to read update history: $_"
    }
}

function Get-NewEmojis {
    <#
    .SYNOPSIS
        Shows recently added emojis.

    .DESCRIPTION
        Displays emojis that were added in recent dataset updates.

    .PARAMETER Last
        Number of recent updates to check (default: 1)

    .PARAMETER Since
        Show emojis added since a specific date

    .PARAMETER Category
        Filter by emoji category

    .EXAMPLE
        Get-NewEmojis
        Shows emojis added in the most recent update

    .EXAMPLE
        Get-NewEmojis -Last 3
        Shows emojis added in the last 3 updates

    .EXAMPLE
        Get-NewEmojis -Since "2025-01-01"
        Shows all emojis added since January 1st, 2025

    .EXAMPLE
        Get-NewEmojis -Category "Smileys & Emotion"
        Shows new emojis in the Smileys & Emotion category
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Function returns multiple emojis, plural is semantically correct')]
    [CmdletBinding(DefaultParameterSetName = 'Last')]
    param(
        [Parameter(ParameterSetName = 'Last')]
        [int]$Last = 1,

        [Parameter(ParameterSetName = 'Since')]
        [datetime]$Since,

        [Parameter()]
        [string]$Category
    )

    $historyPath = Join-Path $PSScriptRoot "..\data\history.json"

    if (-not (Test-Path $historyPath)) {
        Write-Host "📊 No update history available yet." -ForegroundColor Yellow
        return
    }

    try {
        $history = Get-Content $historyPath -Encoding UTF8 | ConvertFrom-Json -AsHashtable
        $updates = $history.updates

        # Filter by date
        if ($Since) {
            $updates = $updates | Where-Object { [datetime]$_.date -ge $Since }
        }
        else {
            $updates = $updates | Select-Object -First $Last
        }

        # Collect all added emojis
        $allAdded = @()
        foreach ($update in $updates) {
            foreach ($emoji in $update.added) {
                $emojiObj = [PSCustomObject]@{
                    Emoji = $emoji.emoji
                    Name = $emoji.name
                    Category = $emoji.category
                    Date = [datetime]$update.date
                    Source = $update.source
                }
                $allAdded += $emojiObj
            }
        }

        # Filter by category
        if ($Category) {
            $allAdded = $allAdded | Where-Object { $_.Category -eq $Category }
        }

        if ($allAdded.Count -eq 0) {
            Write-Host "📊 No new emojis found." -ForegroundColor Yellow
            return
        }

        # Display results
        Write-Host "`n✨ New Emojis ($($allAdded.Count) total)" -ForegroundColor Green
        Write-Host ("=" * 80) -ForegroundColor Green

        # Group by category
        $grouped = $allAdded | Group-Object -Property Category | Sort-Object Name

        foreach ($group in $grouped) {
            Write-Host "`n📁 $($group.Name)" -ForegroundColor Cyan
            foreach ($emoji in ($group.Group | Sort-Object Name)) {
                $daysAgo = (New-TimeSpan -Start $emoji.Date -End (Get-Date)).Days
                Write-Host "   $($emoji.Emoji)  $($emoji.Name)" -NoNewline
                Write-Host " ($daysAgo days ago)" -ForegroundColor Gray
            }
        }

        Write-Host ""
    }
    catch {
        Write-Error "Failed to retrieve new emojis: $_"
    }
}

function Get-RemovedEmojis {
    <#
    .SYNOPSIS
        Shows recently removed emojis.

    .DESCRIPTION
        Displays emojis that were removed in recent dataset updates.

    .PARAMETER Last
        Number of recent updates to check (default: 1)

    .PARAMETER Since
        Show emojis removed since a specific date

    .PARAMETER Category
        Filter by emoji category

    .EXAMPLE
        Get-RemovedEmojis
        Shows emojis removed in the most recent update

    .EXAMPLE
        Get-RemovedEmojis -Last 3
        Shows emojis removed in the last 3 updates

    .EXAMPLE
        Get-RemovedEmojis -Since "2025-01-01"
        Shows all emojis removed since January 1st, 2025
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Function returns multiple emojis, plural is semantically correct')]
    [CmdletBinding(DefaultParameterSetName = 'Last')]
    param(
        [Parameter(ParameterSetName = 'Last')]
        [int]$Last = 1,

        [Parameter(ParameterSetName = 'Since')]
        [datetime]$Since,

        [Parameter()]
        [string]$Category
    )

    $historyPath = Join-Path $PSScriptRoot "..\data\history.json"

    if (-not (Test-Path $historyPath)) {
        Write-Host "📊 No update history available yet." -ForegroundColor Yellow
        return
    }

    try {
        $history = Get-Content $historyPath -Encoding UTF8 | ConvertFrom-Json -AsHashtable
        $updates = $history.updates

        # Filter by date
        if ($Since) {
            $updates = $updates | Where-Object { [datetime]$_.date -ge $Since }
        }
        else {
            $updates = $updates | Select-Object -First $Last
        }

        # Collect all removed emojis
        $allRemoved = @()
        foreach ($update in $updates) {
            foreach ($emoji in $update.removed) {
                $emojiObj = [PSCustomObject]@{
                    Emoji = $emoji.emoji
                    Name = $emoji.name
                    Category = $emoji.category
                    Date = [datetime]$update.date
                    Source = $update.source
                }
                $allRemoved += $emojiObj
            }
        }

        # Filter by category
        if ($Category) {
            $allRemoved = $allRemoved | Where-Object { $_.Category -eq $Category }
        }

        if ($allRemoved.Count -eq 0) {
            Write-Host "📊 No removed emojis found." -ForegroundColor Green
            return
        }

        # Display results
        Write-Host "`n⚠️  Removed Emojis ($($allRemoved.Count) total)" -ForegroundColor Yellow
        Write-Host ("=" * 80) -ForegroundColor Yellow

        # Group by category
        $grouped = $allRemoved | Group-Object -Property Category | Sort-Object Name

        foreach ($group in $grouped) {
            Write-Host "`n📁 $($group.Name)" -ForegroundColor Cyan
            foreach ($emoji in ($group.Group | Sort-Object Name)) {
                $daysAgo = (New-TimeSpan -Start $emoji.Date -End (Get-Date)).Days
                Write-Host "   $($emoji.Emoji)  $($emoji.Name)" -NoNewline
                Write-Host " ($daysAgo days ago)" -ForegroundColor Gray
            }
        }

        Write-Host ""
    }
    catch {
        Write-Error "Failed to retrieve removed emojis: $_"
    }
}

function Export-EmojiHistory {
    <#
    .SYNOPSIS
        Exports emoji update history to a file.

    .DESCRIPTION
        Exports the emoji update history to JSON, CSV, HTML, or Markdown format.

    .PARAMETER Path
        Output file path

    .PARAMETER Format
        Export format: JSON, CSV, HTML, Markdown

    .PARAMETER IncludeDetails
        Include full details of added/removed/modified emojis (default: summary only)

    .EXAMPLE
        Export-EmojiHistory -Path "history.json"
        Exports full history to JSON

    .EXAMPLE
        Export-EmojiHistory -Path "history.csv" -Format CSV
        Exports update summary to CSV

    .EXAMPLE
        Export-EmojiHistory -Path "CHANGES.md" -Format Markdown -IncludeDetails
        Exports detailed changelog in Markdown format

    .EXAMPLE
        Export-EmojiHistory -Path "report.html" -Format HTML -IncludeDetails
        Exports detailed HTML report
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter()]
        [ValidateSet('JSON', 'CSV', 'HTML', 'Markdown')]
        [string]$Format,

        [Parameter()]
        [switch]$IncludeDetails
    )

    $historyPath = Join-Path $PSScriptRoot "..\data\history.json"

    if (-not (Test-Path $historyPath)) {
        Write-Error "No update history available to export."
        return
    }

    # Auto-detect format from extension if not specified
    if (-not $Format) {
        $extension = [System.IO.Path]::GetExtension($Path).TrimStart('.')
        $Format = switch ($extension) {
            'json' { 'JSON' }
            'csv' { 'CSV' }
            'html' { 'HTML' }
            'md' { 'Markdown' }
            default { 'JSON' }
        }
    }

    try {
        $history = Get-Content $historyPath -Encoding UTF8 | ConvertFrom-Json -AsHashtable

        switch ($Format) {
            'JSON' {
                # Export raw JSON
                $history | ConvertTo-Json -Depth 10 | Set-Content $Path -Encoding UTF8
            }

            'CSV' {
                # Export summary as CSV
                $csvData = @()
                foreach ($update in $history.updates) {
                    $csvData += [PSCustomObject]@{
                        Date = $update.date
                        Source = $update.source
                        Version = $update.version
                        PreviousCount = $update.previousCount
                        NewCount = $update.newCount
                        Added = $update.added.Count
                        Removed = $update.removed.Count
                        Modified = $update.modified.Count
                    }
                }
                $csvData | Export-Csv $Path -NoTypeInformation -Encoding UTF8
            }

            'HTML' {
                # Generate HTML report
                $html = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Emoji Update History</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background: #f5f5f5; }
        h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }
        h2 { color: #34495e; margin-top: 30px; }
        .update { background: white; padding: 20px; margin: 15px 0; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .date { font-size: 1.2em; color: #2c3e50; font-weight: bold; }
        .meta { color: #7f8c8d; margin: 5px 0; }
        .stats { margin: 10px 0; }
        .added { color: #27ae60; }
        .removed { color: #e74c3c; }
        .modified { color: #3498db; }
        .emoji-list { margin: 10px 0; padding: 10px; background: #ecf0f1; border-radius: 4px; }
        .emoji-item { margin: 5px 0; }
        table { border-collapse: collapse; width: 100%; margin: 10px 0; }
        th, td { padding: 8px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #3498db; color: white; }
    </style>
</head>
<body>
    <h1>📊 Emoji Update History</h1>
    <p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
"@

                foreach ($update in $history.updates) {
                    $date = [datetime]$update.date
                    $html += @"
    <div class="update">
        <div class="date">📅 $($date.ToString('yyyy-MM-dd HH:mm'))</div>
        <div class="meta">Source: $($update.source) $(if ($update.version) { "| Version: $($update.version)" })</div>
        <div class="stats">
            Total: $($update.previousCount) → $($update.newCount) emojis
            $(if ($update.added.Count -gt 0) { " | <span class='added'>+$($update.added.Count) added</span>" })
            $(if ($update.removed.Count -gt 0) { " | <span class='removed'>-$($update.removed.Count) removed</span>" })
            $(if ($update.modified.Count -gt 0) { " | <span class='modified'>~$($update.modified.Count) modified</span>" })
        </div>
"@

                    if ($IncludeDetails) {
                        if ($update.added.Count -gt 0) {
                            $html += "        <h3>✅ Added Emojis</h3>`n        <div class='emoji-list'>`n"
                            foreach ($emoji in $update.added) {
                                $html += "            <div class='emoji-item'>$($emoji.emoji) $($emoji.name) <em>($($emoji.category))</em></div>`n"
                            }
                            $html += "        </div>`n"
                        }

                        if ($update.removed.Count -gt 0) {
                            $html += "        <h3>❌ Removed Emojis</h3>`n        <div class='emoji-list'>`n"
                            foreach ($emoji in $update.removed) {
                                $html += "            <div class='emoji-item'>$($emoji.emoji) $($emoji.name) <em>($($emoji.category))</em></div>`n"
                            }
                            $html += "        </div>`n"
                        }
                    }

                    $html += "    </div>`n"
                }

                $html += "</body>`n</html>"
                $html | Set-Content $Path -Encoding UTF8
            }

            'Markdown' {
                # Generate Markdown changelog
                $md = "# 📊 Emoji Update History`n`n"
                $md += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n`n"
                $md += "---`n`n"

                foreach ($update in $history.updates) {
                    $date = [datetime]$update.date
                    $md += "## 📅 $($date.ToString('yyyy-MM-dd HH:mm'))`n`n"
                    $md += "**Source:** $($update.source)"
                    if ($update.version) {
                        $md += " | **Version:** $($update.version)"
                    }
                    $md += "`n"
                    $md += "**Total:** $($update.previousCount) → $($update.newCount) emojis`n`n"

                    if ($update.added.Count -gt 0 -or $update.removed.Count -gt 0 -or $update.modified.Count -gt 0) {
                        $md += "### Changes`n`n"
                        if ($update.added.Count -gt 0) {
                            $md += "- ✅ **Added:** $($update.added.Count) emojis`n"
                        }
                        if ($update.removed.Count -gt 0) {
                            $md += "- ❌ **Removed:** $($update.removed.Count) emojis`n"
                        }
                        if ($update.modified.Count -gt 0) {
                            $md += "- 🔄 **Modified:** $($update.modified.Count) emojis`n"
                        }
                        $md += "`n"
                    }

                    if ($IncludeDetails) {
                        if ($update.added.Count -gt 0) {
                            $md += "#### ✅ Added Emojis`n`n"
                            foreach ($emoji in $update.added) {
                                $md += "- $($emoji.emoji) **$($emoji.name)** *($($emoji.category))*`n"
                            }
                            $md += "`n"
                        }

                        if ($update.removed.Count -gt 0) {
                            $md += "#### ❌ Removed Emojis`n`n"
                            foreach ($emoji in $update.removed) {
                                $md += "- $($emoji.emoji) **$($emoji.name)** *($($emoji.category))*`n"
                            }
                            $md += "`n"
                        }

                        if ($update.modified.Count -gt 0) {
                            $md += "#### 🔄 Modified Emojis`n`n"
                            foreach ($emoji in $update.modified) {
                                $md += "- $($emoji.emoji) **$($emoji.oldName)** → **$($emoji.newName)**"
                                if ($emoji.oldCategory -ne $emoji.newCategory) {
                                    $md += " *($($emoji.oldCategory) → $($emoji.newCategory))*"
                                }
                                $md += "`n"
                            }
                            $md += "`n"
                        }
                    }

                    $md += "---`n`n"
                }

                $md | Set-Content $Path -Encoding UTF8
            }
        }

        Write-Host "✅ Exported history to: $Path" -ForegroundColor Green
        Write-Host "   Format: $Format" -ForegroundColor Gray
    }
    catch {
        Write-Error "Failed to export history: $_"
    }
}

function Clear-EmojiHistory {
    <#
    .SYNOPSIS
        Clears emoji update history.

    .DESCRIPTION
        Removes all or part of the emoji update history.

    .PARAMETER Before
        Remove history entries before a specific date

    .PARAMETER KeepLast
        Keep only the last N updates

    .EXAMPLE
        Clear-EmojiHistory -KeepLast 10
        Keeps only the 10 most recent updates

    .EXAMPLE
        Clear-EmojiHistory -Before "2024-01-01"
        Removes all history before January 1st, 2024

    .EXAMPLE
        Clear-EmojiHistory -Confirm:$false
        Clears all history without confirmation
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter()]
        [datetime]$Before,

        [Parameter()]
        [int]$KeepLast
    )

    $historyPath = Join-Path $PSScriptRoot "..\data\history.json"

    if (-not (Test-Path $historyPath)) {
        Write-Host "📊 No history file to clear." -ForegroundColor Yellow
        return
    }

    try {
        $history = Get-Content $historyPath -Encoding UTF8 | ConvertFrom-Json -AsHashtable
        $originalCount = $history.updates.Count

        if ($Before) {
            # Remove entries before date
            $history.updates = $history.updates | Where-Object { [datetime]$_.date -ge $Before }
            $action = "Remove history before $($Before.ToString('yyyy-MM-dd'))"
        }
        elseif ($KeepLast) {
            # Keep only last N
            $history.updates = $history.updates | Select-Object -First $KeepLast
            $action = "Keep only last $KeepLast updates"
        }
        else {
            # Clear all
            $history.updates = @()
            $action = "Clear all update history"
        }

        $newCount = $history.updates.Count
        $removed = $originalCount - $newCount

        if ($removed -eq 0) {
            Write-Host "📊 No history entries to remove." -ForegroundColor Yellow
            return
        }

        # Confirm action
        if (-not $PSCmdlet.ShouldProcess("$removed update record(s)", $action)) {
            return
        }

        # Save updated history
        $history | ConvertTo-Json -Depth 10 | Set-Content $historyPath -Encoding UTF8

        Write-Host "✅ Removed $removed update record(s)" -ForegroundColor Green
        Write-Host "   Remaining: $newCount record(s)" -ForegroundColor Gray
    }
    catch {
        Write-Error "Failed to clear history: $_"
    }
}
