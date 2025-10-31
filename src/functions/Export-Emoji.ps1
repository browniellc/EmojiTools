function Export-Emoji {
    <#
    .SYNOPSIS
        Exports emoji data to various formats.

    .DESCRIPTION
        Exports the emoji dataset or search results to different file formats including
        JSON, HTML, Markdown, and CSV. Supports filtering and custom styling.

    .PARAMETER Format
        The export format. Valid values: JSON, HTML, Markdown, CSV

    .PARAMETER OutputPath
        The path where the exported file will be saved. If not specified, outputs to current directory.

    .PARAMETER Category
        Filter emojis by category before exporting

    .PARAMETER Query
        Search query to filter emojis before exporting

    .PARAMETER Limit
        Limit the number of emojis to export

    .PARAMETER Title
        Custom title for HTML and Markdown exports (default: "Emoji Collection")

    .PARAMETER IncludeMetadata
        Include metadata like export date, count, and source information

    .PARAMETER StyleTheme
        HTML style theme. Valid values: Light, Dark, Colorful (default: Light)

    .PARAMETER PassThru
        Return the exported content to the pipeline instead of writing to file

    .EXAMPLE
        Export-Emoji -Format JSON -OutputPath "emojis.json"
        Exports all emojis to JSON format

    .EXAMPLE
        Export-Emoji -Format HTML -Category "Smileys & Emotion" -Title "Smiley Faces"
        Exports smiley emojis to HTML with custom title

    .EXAMPLE
        Export-Emoji -Format Markdown -Query "heart" -IncludeMetadata
        Exports heart-related emojis to Markdown with metadata

    .EXAMPLE
        Search-Emoji "animal" | Export-Emoji -Format HTML -OutputPath "animals.html" -StyleTheme Dark
        Exports search results to HTML with dark theme
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('JSON', 'HTML', 'Markdown', 'CSV')]
        [string]$Format,

        [Parameter(Mandatory = $false)]
        [string]$OutputPath,

        [Parameter(Mandatory = $false)]
        [string]$Category,

        [Parameter(Mandatory = $false)]
        [string]$Query,

        [Parameter(Mandatory = $false)]
        [int]$Limit,

        [Parameter(Mandatory = $false)]
        [string]$Title = "Emoji Collection",

        [Parameter(Mandatory = $false)]
        [switch]$IncludeMetadata,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Light', 'Dark', 'Colorful')]
        [string]$StyleTheme = 'Light',

        [Parameter(Mandatory = $false)]
        [switch]$PassThru,

        [Parameter(ValueFromPipeline = $true)]
        [PSCustomObject[]]$InputObject
    )

    begin {
        $emojis = @()
        $pipelineInput = $false
    }

    process {
        if ($InputObject) {
            $pipelineInput = $true
            $emojis += $InputObject
        }
    }

    end {
        # If no pipeline input, get emojis from dataset
        if (-not $pipelineInput) {
            $datasetPath = Join-Path $PSScriptRoot "..\data\emoji.csv"

            if (-not (Test-Path $datasetPath)) {
                Write-Error "Emoji dataset not found at $datasetPath"
                return
            }

            $emojis = Import-Csv -Path $datasetPath -Encoding UTF8

            # Apply filters
            if ($Category) {
                $emojis = $emojis | Where-Object { $_.category -eq $Category }
            }

            if ($Query) {
                $emojis = $emojis | Where-Object {
                    $_.name -like "*$Query*" -or $_.keywords -like "*$Query*"
                }
            }

            if ($Limit) {
                $emojis = $emojis | Select-Object -First $Limit
            }
        }

        if ($emojis.Count -eq 0) {
            Write-Warning "No emojis to export"
            return
        }

        # Generate output based on format
        $output = switch ($Format) {
            'JSON' { Export-ToJSON -Emojis $emojis -IncludeMetadata:$IncludeMetadata }
            'HTML' { Export-ToHTML -Emojis $emojis -Title $Title -Theme $StyleTheme -IncludeMetadata:$IncludeMetadata }
            'Markdown' { Export-ToMarkdown -Emojis $emojis -Title $Title -IncludeMetadata:$IncludeMetadata }
            'CSV' { Export-ToCSV -Emojis $emojis }
        }

        # Output handling
        if ($PassThru) {
            return $output
        }

        # Determine output path
        if (-not $OutputPath) {
            $extension = switch ($Format) {
                'JSON' { 'json' }
                'HTML' { 'html' }
                'Markdown' { 'md' }
                'CSV' { 'csv' }
            }
            $OutputPath = "emojis-export-$(Get-Date -Format 'yyyyMMdd-HHmmss').$extension"
        }

        # Write to file
        $output | Out-File -FilePath $OutputPath -Encoding UTF8 -Force

        Write-Host "✅ Exported $($emojis.Count) emojis to: $OutputPath" -ForegroundColor Green

        # Return file info
        Get-Item $OutputPath
    }
}

function Export-ToJSON {
    param(
        [PSCustomObject[]]$Emojis,
        [bool]$IncludeMetadata
    )

    $data = if ($IncludeMetadata) {
        @{
            metadata = @{
                exportDate = (Get-Date -Format 'o')
                count = $Emojis.Count
                source = "EmojiTools PowerShell Module"
                version = "1.3.0"
            }
            emojis = $Emojis | ForEach-Object {
                @{
                    emoji = $_.emoji
                    name = $_.name
                    keywords = $_.keywords -split ', '
                    category = $_.category
                }
            }
        }
    } else {
        $Emojis | ForEach-Object {
            @{
                emoji = $_.emoji
                name = $_.name
                keywords = $_.keywords -split ', '
                category = $_.category
            }
        }
    }

    return ($data | ConvertTo-Json -Depth 10)
}

function Export-ToHTML {
    param(
        [PSCustomObject[]]$Emojis,
        [string]$Title,
        [string]$Theme,
        [bool]$IncludeMetadata
    )

    # Theme colors
    $themes = @{
        Light = @{
            bg = '#ffffff'
            text = '#333333'
            headerBg = '#f8f9fa'
            borderColor = '#dee2e6'
            hoverBg = '#f1f3f5'
            cardBg = '#ffffff'
        }
        Dark = @{
            bg = '#1e1e1e'
            text = '#e0e0e0'
            headerBg = '#2d2d2d'
            borderColor = '#404040'
            hoverBg = '#3a3a3a'
            cardBg = '#252525'
        }
        Colorful = @{
            bg = '#f0f8ff'
            text = '#2c3e50'
            headerBg = '#667eea'
            borderColor = '#764ba2'
            hoverBg = '#e8f4f8'
            cardBg = '#ffffff'
        }
    }

    $colors = $themes[$Theme]

    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$Title</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: $($colors.bg);
            color: $($colors.text);
            padding: 20px;
            line-height: 1.6;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
        }

        h1 {
            text-align: center;
            margin-bottom: 10px;
            padding: 30px 20px;
            background: $($colors.headerBg);
            border-radius: 10px;
            font-size: 2.5em;
        }

        .metadata {
            text-align: center;
            margin-bottom: 30px;
            padding: 15px;
            background: $($colors.cardBg);
            border: 1px solid $($colors.borderColor);
            border-radius: 8px;
            font-size: 0.9em;
        }

        .search-box {
            margin: 20px 0;
            text-align: center;
        }

        .search-box input {
            width: 100%;
            max-width: 500px;
            padding: 12px 20px;
            font-size: 16px;
            border: 2px solid $($colors.borderColor);
            border-radius: 25px;
            background: $($colors.bg);
            color: $($colors.text);
        }

        .emoji-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 30px;
        }

        .emoji-card {
            background: $($colors.cardBg);
            border: 1px solid $($colors.borderColor);
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .emoji-card:hover {
            background: $($colors.hoverBg);
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.1);
        }

        .emoji-symbol {
            font-size: 3em;
            margin-bottom: 10px;
            user-select: all;
        }

        .emoji-name {
            font-weight: bold;
            margin-bottom: 5px;
            font-size: 1.1em;
        }

        .emoji-category {
            font-size: 0.85em;
            opacity: 0.7;
            margin-bottom: 8px;
        }

        .emoji-keywords {
            font-size: 0.8em;
            opacity: 0.6;
            line-height: 1.4;
        }

        .stats {
            text-align: center;
            margin: 20px 0;
            font-size: 1.1em;
            opacity: 0.8;
        }

        .footer {
            text-align: center;
            margin-top: 50px;
            padding: 20px;
            opacity: 0.6;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>$Title</h1>
"@

    if ($IncludeMetadata) {
        $html += @"

        <div class="metadata">
            <strong>Export Date:</strong> $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') |
            <strong>Total Emojis:</strong> $($Emojis.Count) |
            <strong>Source:</strong> EmojiTools v1.3.0
        </div>
"@
    }

    $html += @"

        <div class="search-box">
            <input type="text" id="searchInput" placeholder="🔍 Search emojis by name or keywords..." onkeyup="filterEmojis()">
        </div>

        <div class="stats">
            Showing <span id="visibleCount">$($Emojis.Count)</span> of $($Emojis.Count) emojis
        </div>

        <div class="emoji-grid" id="emojiGrid">
"@

    foreach ($emoji in $Emojis) {
        $safeEmoji = [System.Web.HttpUtility]::HtmlEncode($emoji.emoji)
        $safeName = [System.Web.HttpUtility]::HtmlEncode($emoji.name)
        $safeCategory = [System.Web.HttpUtility]::HtmlEncode($emoji.category)
        $safeKeywords = [System.Web.HttpUtility]::HtmlEncode($emoji.keywords)

        $html += @"
            <div class="emoji-card" data-name="$safeName" data-keywords="$safeKeywords" onclick="copyEmoji('$safeEmoji')">
                <div class="emoji-symbol">$safeEmoji</div>
                <div class="emoji-name">$safeName</div>
                <div class="emoji-category">$safeCategory</div>
                <div class="emoji-keywords">$safeKeywords</div>
            </div>
"@
    }

    $html += @"
        </div>

        <div class="footer">
            Generated by EmojiTools PowerShell Module | Click any emoji to copy to clipboard
        </div>
    </div>

    <script>
        function filterEmojis() {
            const input = document.getElementById('searchInput').value.toLowerCase();
            const cards = document.querySelectorAll('.emoji-card');
            let visibleCount = 0;

            cards.forEach(card => {
                const name = card.getAttribute('data-name').toLowerCase();
                const keywords = card.getAttribute('data-keywords').toLowerCase();
                const match = name.includes(input) || keywords.includes(input);

                card.style.display = match ? '' : 'none';
                if (match) visibleCount++;
            });

            document.getElementById('visibleCount').textContent = visibleCount;
        }

        function copyEmoji(emoji) {
            if (navigator.clipboard) {
                navigator.clipboard.writeText(emoji).then(() => {
                    // Visual feedback
                    const notification = document.createElement('div');
                    notification.textContent = 'Copied: ' + emoji;
                    notification.style.cssText = 'position:fixed;top:20px;right:20px;background:#4CAF50;color:white;padding:15px 25px;border-radius:5px;z-index:1000;';
                    document.body.appendChild(notification);
                    setTimeout(() => notification.remove(), 2000);
                });
            }
        }
    </script>
</body>
</html>
"@

    return $html
}

function Export-ToMarkdown {
    param(
        [PSCustomObject[]]$Emojis,
        [string]$Title,
        [bool]$IncludeMetadata
    )

    $md = "# $Title`n`n"

    if ($IncludeMetadata) {
        $md += "**Export Information**`n`n"
        $md += "- **Date:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
        $md += "- **Count:** $($Emojis.Count) emojis`n"
        $md += "- **Source:** EmojiTools PowerShell Module v1.3.0`n"
        $md += "`n---`n`n"
    }

    # Group by category
    $grouped = $Emojis | Group-Object -Property category | Sort-Object Name

    foreach ($group in $grouped) {
        $categoryName = if ($group.Name) { $group.Name } else { "Uncategorized" }
        $md += "## $categoryName`n`n"
        $md += "| Emoji | Name | Keywords |`n"
        $md += "|-------|------|----------|`n"

        foreach ($emoji in $group.Group) {
            $md += "| $($emoji.emoji) | $($emoji.name) | $($emoji.keywords) |`n"
        }

        $md += "`n"
    }

    $md += "---`n`n"
    $md += "*Generated by EmojiTools PowerShell Module*`n"

    return $md
}

function Export-ToCSV {
    param(
        [PSCustomObject[]]$Emojis
    )

    # Convert to CSV format
    return ($Emojis | ConvertTo-Csv -NoTypeInformation | Out-String)
}

# Add HTML encoding support
Add-Type -AssemblyName System.Web
