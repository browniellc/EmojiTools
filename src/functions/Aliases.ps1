function Get-EmojiAlias {
    <#
    .SYNOPSIS
        Gets an emoji by its alias/shortcut.

    .DESCRIPTION
        Retrieves an emoji using a predefined alias or shortcut name. Aliases provide
        quick access to commonly used emojis without needing to search.

    .PARAMETER Alias
        The alias/shortcut name for the emoji (e.g., "thumbsup", "fire", "rocket")

    .PARAMETER List
        Lists all available aliases

    .PARAMETER Copy
        Copy the emoji to clipboard after retrieving

    .EXAMPLE
        Get-EmojiAlias -Alias "fire"
        Returns: 🔥

    .EXAMPLE
        Get-EmojiAlias -Alias "thumbsup" -Copy
        Returns the 👍 emoji and copies it to clipboard

    .EXAMPLE
        Get-EmojiAlias -List
        Shows all available emoji aliases
    #>

    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string]$Alias,

        [Parameter()]
        [switch]$List,

        [Parameter()]
        [switch]$Copy
    )

    # Load aliases
    $aliasPath = Join-Path $PSScriptRoot "..\data\aliases.json"

    if ($List) {
        if (-not (Test-Path $aliasPath)) {
            Write-Warning "No aliases defined yet. Use New-EmojiAlias to create aliases."
            return
        }

        $aliases = Get-Content $aliasPath -Encoding UTF8 | ConvertFrom-Json

        Write-Host "`n🔖 Available Emoji Aliases" -ForegroundColor Cyan
        Write-Host ("=" * 60) -ForegroundColor Cyan

        $aliases.PSObject.Properties | Sort-Object Name | ForEach-Object {
            $emojiData = $Script:EmojiData | Where-Object { $_.emoji -eq $_.Value } | Select-Object -First 1
            if ($emojiData) {
                Write-Host ("{0,-15} {1}  {2}" -f $_.Name, $_.Value, $emojiData.name) -ForegroundColor White
            }
            else {
                Write-Host ("{0,-15} {1}" -f $_.Name, $_.Value) -ForegroundColor White
            }
        }
        Write-Host "`n"
        return
    }

    if (-not $Alias) {
        Write-Error "Please provide an alias name or use -List to see all aliases."
        return
    }

    if (-not (Test-Path $aliasPath)) {
        Write-Error "No aliases defined. Use New-EmojiAlias to create your first alias."
        return
    }

    $aliases = Get-Content $aliasPath -Encoding UTF8 | ConvertFrom-Json
    $emoji = $aliases.$Alias

    if (-not $emoji) {
        Write-Error "Alias '$Alias' not found. Use Get-EmojiAlias -List to see available aliases."
        return
    }

    if ($Copy) {
        $emoji | Copy-Emoji
    }
    else {
        # Return emoji with details
        $emojiData = $Script:EmojiData | Where-Object { $_.emoji -eq $emoji } | Select-Object -First 1
        if ($emojiData) {
            $emojiData | Format-Table emoji, name, category, keywords -AutoSize
        }
        else {
            Write-Output $emoji
        }
    }
}

function New-EmojiAlias {
    <#
    .SYNOPSIS
        Creates a new emoji alias/shortcut.

    .DESCRIPTION
        Defines a custom alias (shortcut name) for an emoji to enable quick access.

    .PARAMETER Alias
        The alias/shortcut name to create (e.g., "fire", "rocket", "ok")

    .PARAMETER Emoji
        The emoji character to associate with the alias

    .PARAMETER Force
        Overwrite existing alias if it already exists

    .EXAMPLE
        New-EmojiAlias -Alias "fire" -Emoji "🔥"
        Creates an alias "fire" for 🔥

    .EXAMPLE
        New-EmojiAlias -Alias "ok" -Emoji "👍"
        Creates an alias "ok" for 👍

    .EXAMPLE
        "🚀","💻","🔥" | New-EmojiAlias -Alias "rocket","computer","fire"
        Creates multiple aliases at once
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Alias,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
        [string]$Emoji,

        [Parameter()]
        [switch]$Force
    )

    $aliasPath = Join-Path $PSScriptRoot "..\data\aliases.json"

    # Validate alias name (alphanumeric and underscores only)
    if ($Alias -notmatch '^[a-zA-Z0-9_]+$') {
        Write-Error "Alias name must contain only letters, numbers, and underscores."
        return
    }

    # Load or create aliases
    $aliases = @{}
    if (Test-Path $aliasPath) {
        $aliases = Get-Content $aliasPath -Encoding UTF8 | ConvertFrom-Json -AsHashtable
    }

    # Check if alias exists
    if ($aliases.ContainsKey($Alias) -and -not $Force) {
        Write-Error "Alias '$Alias' already exists. Use -Force to overwrite."
        return
    }

    # ShouldProcess check
    $operation = if ($aliases.ContainsKey($Alias)) { "Update" } else { "Create" }
    if (-not $PSCmdlet.ShouldProcess("alias '$Alias' for emoji $Emoji", $operation)) {
        return
    }

    # Add alias
    $aliases[$Alias] = $Emoji

    # Save
    $aliases | ConvertTo-Json | Set-Content $aliasPath -Encoding UTF8

    Write-Host "✅ Created alias '$Alias' for $Emoji" -ForegroundColor Green
}

function Remove-EmojiAlias {
    <#
    .SYNOPSIS
        Removes an emoji alias/shortcut.

    .DESCRIPTION
        Deletes a previously defined emoji alias.

    .PARAMETER Alias
        The alias name to remove

    .PARAMETER Force
        Skip confirmation prompt

    .EXAMPLE
        Remove-EmojiAlias -Alias "fire"
        Removes the "fire" alias

    .EXAMPLE
        Remove-EmojiAlias -Alias "rocket" -Force
        Removes the alias without confirmation
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Alias,

        [Parameter()]
        [switch]$Force
    )

    $aliasPath = Join-Path $PSScriptRoot "..\data\aliases.json"

    if (-not (Test-Path $aliasPath)) {
        Write-Error "No aliases defined."
        return
    }

    $aliases = Get-Content $aliasPath -Encoding UTF8 | ConvertFrom-Json -AsHashtable

    if (-not $aliases.ContainsKey($Alias)) {
        Write-Error "Alias '$Alias' not found."
        return
    }

    $emoji = $aliases[$Alias]

    if (-not $Force -and -not $PSCmdlet.ShouldProcess($Alias, "Remove alias for $emoji")) {
        return
    }

    $aliases.Remove($Alias)

    # Save
    $aliases | ConvertTo-Json | Set-Content $aliasPath -Encoding UTF8

    Write-Host "✅ Removed alias '$Alias'" -ForegroundColor Green
}

function Set-EmojiAlias {
    <#
    .SYNOPSIS
        Updates an existing emoji alias.

    .DESCRIPTION
        Changes the emoji associated with an existing alias.

    .PARAMETER Alias
        The alias name to update

    .PARAMETER Emoji
        The new emoji character

    .EXAMPLE
        Set-EmojiAlias -Alias "fire" -Emoji "🔥"
        Updates the "fire" alias
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Alias,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]$Emoji
    )

    if ($PSCmdlet.ShouldProcess("alias '$Alias'", "Update")) {
        New-EmojiAlias -Alias $Alias -Emoji $Emoji -Force -Confirm:$false
        Write-Host "✅ Updated alias '$Alias' to $Emoji" -ForegroundColor Green
    }
}

function Initialize-DefaultEmojiAliases {
    <#
    .SYNOPSIS
        Creates a set of default emoji aliases.

    .DESCRIPTION
        Initializes commonly used emoji aliases for quick access.

    .PARAMETER Force
        Overwrite existing aliases

    .EXAMPLE
        Initialize-DefaultEmojiAliases
        Creates default emoji aliases
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Function creates multiple aliases, plural is semantically correct')]
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Force
    )

    $defaultAliases = @{
        # Expressions
        "smile" = "😊"
        "grin" = "😁"
        "laugh" = "😂"
        "wink" = "😉"
        "heart" = "❤️"
        "love" = "😍"
        "kiss" = "😘"
        "cool" = "😎"
        "thinking" = "🤔"
        "shrug" = "🤷"

        # Reactions
        "thumbsup" = "👍"
        "thumbsdown" = "👎"
        "ok" = "👌"
        "clap" = "👏"
        "pray" = "🙏"
        "muscle" = "💪"
        "fire" = "🔥"
        "boom" = "💥"
        "star" = "⭐"
        "sparkles" = "✨"

        # Symbols
        "check" = "✅"
        "x" = "❌"
        "warning" = "⚠️"
        "question" = "❓"
        "info" = "ℹ️"
        "idea" = "💡"
        "rocket" = "🚀"
        "trophy" = "🏆"
        "target" = "🎯"
        "flag" = "🚩"

        # Tech
        "computer" = "💻"
        "laptop" = "💻"
        "phone" = "📱"
        "email" = "📧"
        "folder" = "📁"
        "file" = "📄"
        "chart" = "📊"
        "calendar" = "📅"
        "clock" = "🕐"
        "bug" = "🐛"

        # Nature
        "sun" = "☀️"
        "moon" = "🌙"
        "cloud" = "☁️"
        "rain" = "🌧️"
        "snow" = "❄️"
        "tree" = "🌲"
        "flower" = "🌸"
        "leaf" = "🍃"

        # Food
        "pizza" = "🍕"
        "burger" = "🍔"
        "coffee" = "☕"
        "beer" = "🍺"
        "cake" = "🎂"
        "apple" = "🍎"

        # Activities
        "game" = "🎮"
        "music" = "🎵"
        "movie" = "🎬"
        "book" = "📚"
        "party" = "🎉"
        "gift" = "🎁"

        # Transport
        "car" = "🚗"
        "plane" = "✈️"
        "train" = "🚆"
        "bike" = "🚲"

        # Time
        "hourglass" = "⏳"
        "alarm" = "⏰"
        "timer" = "⏱️"

        # Money
        "money" = "💰"
        "dollar" = "💵"
        "chart_up" = "📈"
        "chart_down" = "📉"
    }

    $aliasPath = Join-Path $PSScriptRoot "..\data\aliases.json"

    # Load existing aliases
    $aliases = @{}
    if (Test-Path $aliasPath) {
        $aliases = Get-Content $aliasPath -Encoding UTF8 | ConvertFrom-Json -AsHashtable
    }

    $added = 0
    $skipped = 0

    foreach ($alias in $defaultAliases.GetEnumerator()) {
        if ($aliases.ContainsKey($alias.Key) -and -not $Force) {
            $skipped++
            continue
        }

        $aliases[$alias.Key] = $alias.Value
        $added++
    }

    # Save
    $aliases | ConvertTo-Json | Set-Content $aliasPath -Encoding UTF8

    Write-Host "✅ Initialized default emoji aliases" -ForegroundColor Green
    Write-Host "   Added: $added aliases" -ForegroundColor White
    if ($skipped -gt 0) {
        Write-Host "   Skipped: $skipped existing aliases (use -Force to overwrite)" -ForegroundColor Yellow
    }
    Write-Host "`nUse 'Get-EmojiAlias -List' to see all aliases" -ForegroundColor Cyan
}

function Import-EmojiAliases {
    <#
    .SYNOPSIS
        Imports emoji aliases from a JSON file.

    .DESCRIPTION
        Loads emoji aliases from an exported JSON file.

    .PARAMETER Path
        Path to the JSON file containing aliases

    .PARAMETER Merge
        Merge with existing aliases instead of replacing

    .EXAMPLE
        Import-EmojiAliases -Path "my-aliases.json"
        Imports aliases from file

    .EXAMPLE
        Import-EmojiAliases -Path "my-aliases.json" -Merge
        Merges imported aliases with existing ones
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Function imports multiple aliases, plural is semantically correct')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter()]
        [switch]$Merge
    )

    if (-not (Test-Path $Path)) {
        Write-Error "File not found: $Path"
        return
    }

    $importedAliases = Get-Content $Path -Encoding UTF8 | ConvertFrom-Json -AsHashtable

    $aliasPath = Join-Path $PSScriptRoot "..\data\aliases.json"

    if ($Merge -and (Test-Path $aliasPath)) {
        $existingAliases = Get-Content $aliasPath -Encoding UTF8 | ConvertFrom-Json -AsHashtable

        foreach ($alias in $importedAliases.GetEnumerator()) {
            $existingAliases[$alias.Key] = $alias.Value
        }

        $existingAliases | ConvertTo-Json | Set-Content $aliasPath -Encoding UTF8
    }
    else {
        $importedAliases | ConvertTo-Json | Set-Content $aliasPath -Encoding UTF8
    }

    Write-Host "✅ Imported $($importedAliases.Count) emoji aliases from $Path" -ForegroundColor Green
}

function Export-EmojiAliases {
    <#
    .SYNOPSIS
        Exports emoji aliases to a JSON file.

    .DESCRIPTION
        Saves all defined emoji aliases to a JSON file for backup or sharing.

    .PARAMETER Path
        Path where the JSON file will be saved

    .EXAMPLE
        Export-EmojiAliases -Path "my-aliases.json"
        Exports all aliases to file
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Function exports multiple aliases, plural is semantically correct')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $aliasPath = Join-Path $PSScriptRoot "..\data\aliases.json"

    if (-not (Test-Path $aliasPath)) {
        Write-Error "No aliases to export."
        return
    }

    Copy-Item $aliasPath $Path -Force

    $aliases = Get-Content $aliasPath -Encoding UTF8 | ConvertFrom-Json
    $count = ($aliases.PSObject.Properties | Measure-Object).Count

    Write-Host "✅ Exported $count emoji aliases to $Path" -ForegroundColor Green
}

