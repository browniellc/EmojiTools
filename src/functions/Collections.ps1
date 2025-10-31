function New-EmojiCollection {
    <#
    .SYNOPSIS
        Creates a new custom emoji collection.

    .DESCRIPTION
        Creates a named collection for organizing emojis. Collections are stored
        in data/collections.json and can be used to filter emoji searches and pickers.

    .PARAMETER Name
        Name of the collection (e.g., "Work", "Gaming", "Favorites")

    .PARAMETER Description
        Optional description of the collection's purpose

    .PARAMETER Emojis
        Optional array of emojis to add immediately

    .EXAMPLE
        New-EmojiCollection -Name "Work" -Description "Professional emojis"

    .EXAMPLE
        New-EmojiCollection -Name "Gaming" -Emojis "🎮","🕹️","🎯"
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [string]$Description = "",

        [Parameter(Mandatory = $false)]
        [string[]]$Emojis = @()
    )

    $collectionsPath = Join-Path $PSScriptRoot "..\data\collections.json"

    # Load existing collections
    $collections = @{}
    if (Test-Path $collectionsPath) {
        $collections = Get-Content $collectionsPath -Encoding UTF8 | ConvertFrom-Json -AsHashtable
    }

    # Check if collection already exists
    if ($collections.ContainsKey($Name)) {
        Write-Error "Collection '$Name' already exists. Use Add-EmojiToCollection to add emojis."
        return
    }

    # ShouldProcess check
    if (-not $PSCmdlet.ShouldProcess("collection '$Name'", "Create")) {
        return
    }

    # Create new collection
    $collections[$Name] = @{
        description = $Description
        emojis = @($Emojis)
        created = (Get-Date).ToString("yyyy-MM-dd")
        modified = (Get-Date).ToString("yyyy-MM-dd")
    }

    # Save collections
    $collections | ConvertTo-Json -Depth 10 | Set-Content $collectionsPath -Encoding UTF8

    Write-Host "✅ Created collection '$Name'" -ForegroundColor Green
    if ($Emojis.Count -gt 0) {
        Write-Host "   Added $($Emojis.Count) emoji(s): $($Emojis -join ' ')" -ForegroundColor Cyan
    }
}

function Add-EmojiToCollection {
    <#
    .SYNOPSIS
        Adds emojis to an existing collection.

    .DESCRIPTION
        Adds one or more emojis to a named collection.

    .PARAMETER Collection
        Name of the collection

    .PARAMETER Emojis
        Array of emojis to add (characters or names)

    .EXAMPLE
        Add-EmojiToCollection -Collection "Work" -Emojis "💼","📊"

    .EXAMPLE
        "🎮","🎯" | Add-EmojiToCollection -Collection "Gaming"
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [Alias('Name')]
        [string]$Collection,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Alias('Emoji')]
        [string[]]$Emojis
    )

    begin {
        $collectionsPath = Join-Path $PSScriptRoot "..\data\collections.json"

        if (-not (Test-Path $collectionsPath)) {
            Write-Error "No collections found. Create one with New-EmojiCollection first."
            return
        }

        $collections = Get-Content $collectionsPath -Encoding UTF8 | ConvertFrom-Json -AsHashtable

        if (-not $collections.ContainsKey($Collection)) {
            Write-Error "Collection '$Collection' not found."
            return
        }

        $added = @()
    }

    process {
        foreach ($emoji in $Emojis) {
            if ($collections[$Collection].emojis -notcontains $emoji) {
                $collections[$Collection].emojis += $emoji
                $added += $emoji
            }
        }
    }

    end {
        if ($added.Count -gt 0) {
            $collections[$Collection].modified = (Get-Date).ToString("yyyy-MM-dd")
            $collections | ConvertTo-Json -Depth 10 | Set-Content $collectionsPath -Encoding UTF8

            Write-Host "✅ Added $($added.Count) emoji(s) to '$Collection': $($added -join ' ')" -ForegroundColor Green
        }
        else {
            Write-Host "ℹ️  No new emojis added (already in collection)" -ForegroundColor Yellow
        }
    }
}

function Remove-EmojiFromCollection {
    <#
    .SYNOPSIS
        Removes emojis from a collection.

    .DESCRIPTION
        Removes one or more emojis from a named collection.

    .PARAMETER Collection
        Name of the collection

    .PARAMETER Emojis
        Array of emojis to remove

    .EXAMPLE
        Remove-EmojiFromCollection -Collection "Work" -Emojis "📊"
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory = $true)]
        [Alias('Name')]
        [string]$Collection,

        [Parameter(Mandatory = $true)]
        [Alias('Emoji')]
        [string[]]$Emojis
    )

    $collectionsPath = Join-Path $PSScriptRoot "..\data\collections.json"

    if (-not (Test-Path $collectionsPath)) {
        Write-Error "No collections found."
        return
    }

    $collections = Get-Content $collectionsPath -Encoding UTF8 | ConvertFrom-Json -AsHashtable

    if (-not $collections.ContainsKey($Collection)) {
        Write-Error "Collection '$Collection' not found."
        return
    }

    # ShouldProcess check
    if (-not $PSCmdlet.ShouldProcess("collection '$Collection'", "Remove emojis: $($Emojis -join ' ')")) {
        return
    }

    $removed = @()
    foreach ($emoji in $Emojis) {
        if ($collections[$Collection].emojis -contains $emoji) {
            $collections[$Collection].emojis = @($collections[$Collection].emojis | Where-Object { $_ -ne $emoji })
            $removed += $emoji
        }
    }

    if ($removed.Count -gt 0) {
        $collections[$Collection].modified = (Get-Date).ToString("yyyy-MM-dd")
        $collections | ConvertTo-Json -Depth 10 | Set-Content $collectionsPath -Encoding UTF8

        Write-Host "✅ Removed $($removed.Count) emoji(s) from '$Collection': $($removed -join ' ')" -ForegroundColor Green
    }
    else {
        Write-Host "ℹ️  No emojis removed (not found in collection)" -ForegroundColor Yellow
    }
}

function Get-EmojiCollection {
    <#
    .SYNOPSIS
        Gets emoji collections.

    .DESCRIPTION
        Lists all collections or shows details of a specific collection.

    .PARAMETER Name
        Name of a specific collection to view

    .PARAMETER ListNames
        Just list collection names

    .EXAMPLE
        Get-EmojiCollection
        Shows all collections

    .EXAMPLE
        Get-EmojiCollection -Name "Work"
        Shows details of the Work collection

    .EXAMPLE
        Get-EmojiCollection -ListNames
        Lists just the collection names
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [switch]$ListNames
    )

    $collectionsPath = Join-Path $PSScriptRoot "..\data\collections.json"

    if (-not (Test-Path $collectionsPath)) {
        Write-Host "No collections found. Create one with New-EmojiCollection." -ForegroundColor Yellow
        return
    }

    $collections = Get-Content $collectionsPath -Encoding UTF8 | ConvertFrom-Json -AsHashtable

    if ($ListNames) {
        return $collections.Keys | Sort-Object
    }

    if ($Name) {
        if (-not $collections.ContainsKey($Name)) {
            Write-Error "Collection '$Name' not found."
            return
        }

        $coll = $collections[$Name]
        Write-Host "📚 Collection: $Name" -ForegroundColor Cyan
        Write-Host "   Description: $($coll.description)" -ForegroundColor Gray
        Write-Host "   Emojis: $($coll.emojis -join ' ')" -ForegroundColor White
        Write-Host "   Count: $($coll.emojis.Count)" -ForegroundColor Gray
        Write-Host "   Created: $($coll.created)" -ForegroundColor Gray
        Write-Host "   Modified: $($coll.modified)" -ForegroundColor Gray

        return [PSCustomObject]@{
            Name = $Name
            Description = $coll.description
            Emojis = $coll.emojis
            Count = $coll.emojis.Count
            Created = $coll.created
            Modified = $coll.modified
        }
    }

    # Show all collections
    Write-Host "📚 Emoji Collections" -ForegroundColor Cyan
    Write-Host ""

    $results = @()
    foreach ($key in ($collections.Keys | Sort-Object)) {
        $coll = $collections[$key]
        Write-Host "  $key" -ForegroundColor Yellow -NoNewline
        Write-Host " ($($coll.emojis.Count) emojis)" -ForegroundColor Gray
        Write-Host "    $($coll.emojis -join ' ')" -ForegroundColor White
        if ($coll.description) {
            Write-Host "    $($coll.description)" -ForegroundColor DarkGray
        }
        Write-Host ""

        $results += [PSCustomObject]@{
            Name = $key
            Description = $coll.description
            Count = $coll.emojis.Count
            Emojis = $coll.emojis -join ' '
        }
    }

    return $results
}

function Remove-EmojiCollection {
    <#
    .SYNOPSIS
        Removes an entire collection.

    .DESCRIPTION
        Deletes a named collection and all its emojis.

    .PARAMETER Name
        Name of the collection to remove

    .PARAMETER Force
        Skip confirmation prompt

    .EXAMPLE
        Remove-EmojiCollection -Name "OldCollection"

    .EXAMPLE
        Remove-EmojiCollection -Name "Test" -Force
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [switch]$Force
    )

    $collectionsPath = Join-Path $PSScriptRoot "..\data\collections.json"

    if (-not (Test-Path $collectionsPath)) {
        Write-Error "No collections found."
        return
    }

    $collections = Get-Content $collectionsPath -Encoding UTF8 | ConvertFrom-Json -AsHashtable

    if (-not $collections.ContainsKey($Name)) {
        Write-Error "Collection '$Name' not found."
        return
    }

    # ShouldProcess check (replaces manual confirmation)
    $emojiCount = $collections[$Name].emojis.Count
    if (-not $PSCmdlet.ShouldProcess("collection '$Name' with $emojiCount emoji(s)", "Remove")) {
        return
    }

    $collections.Remove($Name)
    $collections | ConvertTo-Json -Depth 10 | Set-Content $collectionsPath -Encoding UTF8

    Write-Host "✅ Removed collection '$Name'" -ForegroundColor Green
}

function Export-EmojiCollection {
    <#
    .SYNOPSIS
        Exports a collection to a JSON file.

    .DESCRIPTION
        Exports a collection to a JSON file for sharing or backup.

    .PARAMETER Name
        Name of the collection to export

    .PARAMETER Path
        Output file path

    .EXAMPLE
        Export-EmojiCollection -Name "Work" -Path "work-emojis.json"
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $collectionsPath = Join-Path $PSScriptRoot "..\data\collections.json"

    if (-not (Test-Path $collectionsPath)) {
        Write-Error "No collections found."
        return
    }

    $collections = Get-Content $collectionsPath -Encoding UTF8 | ConvertFrom-Json -AsHashtable

    if (-not $collections.ContainsKey($Name)) {
        Write-Error "Collection '$Name' not found."
        return
    }

    $coll = $collections[$Name]

    # Export as a flat object with expected properties so tests and import
    # consumers can read Name, Description and Emojis directly.
    $export = @{
        Name = $Name
        Description = $coll.description
        Emojis = $coll.emojis
    }

    $export | ConvertTo-Json -Depth 10 | Set-Content $Path -Encoding UTF8

    Write-Host "✅ Exported collection '$Name' to $Path" -ForegroundColor Green
}

function Import-EmojiCollection {
    <#
    .SYNOPSIS
        Imports a collection from a JSON file.

    .DESCRIPTION
        Imports a collection from a JSON file. If a collection with the same
        name exists, you can choose to merge or replace.

    .PARAMETER Path
        Path to the JSON file to import

    .PARAMETER Merge
        Merge with existing collection instead of replacing

    .EXAMPLE
        Import-EmojiCollection -Path "work-emojis.json"

    .EXAMPLE
        Import-EmojiCollection -Path "shared.json" -Merge
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [switch]$Merge
    )

    if (-not (Test-Path $Path)) {
        Write-Error "File not found: $Path"
        return
    }

    $collectionsPath = Join-Path $PSScriptRoot "..\data\collections.json"

    # Load existing collections
    $collections = @{}
    if (Test-Path $collectionsPath) {
        $collections = Get-Content $collectionsPath -Encoding UTF8 | ConvertFrom-Json -AsHashtable
    }

    # Load import file
    $imported = Get-Content $Path -Encoding UTF8 | ConvertFrom-Json -AsHashtable

    # Detect if this is the new export format (flat object with Name property)
    # or the old internal format (nested object keyed by collection name)
    $importData = @{}
    if ($imported.ContainsKey('Name') -and $imported.ContainsKey('Emojis')) {
        # New export format: flat object with Name, Description, Emojis
        $name = $imported.Name
        $importData[$name] = @{
            description = $imported.Description
            emojis = $imported.Emojis
            created = (Get-Date).ToString("yyyy-MM-dd")
            modified = (Get-Date).ToString("yyyy-MM-dd")
        }
    }
    else {
        # Old internal format: nested object keyed by collection name
        $importData = $imported
    }

    foreach ($key in $importData.Keys) {
        # Ensure the imported collection has the required structure
        if (-not $importData[$key].ContainsKey('created')) {
            $importData[$key].created = (Get-Date).ToString("yyyy-MM-dd")
        }
        if (-not $importData[$key].ContainsKey('modified')) {
            $importData[$key].modified = (Get-Date).ToString("yyyy-MM-dd")
        }

        if ($collections.ContainsKey($key)) {
            if ($Merge) {
                # Merge emojis
                $existing = $collections[$key].emojis
                $new = $importData[$key].emojis
                $collections[$key].emojis = @($existing + $new | Select-Object -Unique)
                $collections[$key].modified = (Get-Date).ToString("yyyy-MM-dd")
                Write-Host "✅ Merged collection '$key'" -ForegroundColor Green
            }
            else {
                $confirm = Read-Host "Collection '$key' exists. Replace? (y/N)"
                if ($confirm -eq 'y') {
                    $collections[$key] = $importData[$key]
                    $collections[$key].modified = (Get-Date).ToString("yyyy-MM-dd")
                    Write-Host "✅ Replaced collection '$key'" -ForegroundColor Green
                }
                else {
                    Write-Host "⏭️  Skipped '$key'" -ForegroundColor Yellow
                }
            }
        }
        else {
            $collections[$key] = $importData[$key]
            Write-Host "✅ Imported collection '$key'" -ForegroundColor Green
        }
    }

    # Save collections
    $collections | ConvertTo-Json -Depth 10 | Set-Content $collectionsPath -Encoding UTF8
}

function Initialize-EmojiCollections {
    <#
    .SYNOPSIS
        Creates default emoji collections.

    .DESCRIPTION
        Creates preset collections for common use cases.

    .EXAMPLE
        Initialize-EmojiCollections
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Function creates multiple collections, plural is semantically correct')]
    [CmdletBinding()]
    param()

    Write-Host "🎨 Initializing default collections..." -ForegroundColor Cyan

    # Developer
    if (-not (Get-EmojiCollection -Name "Developer" -ErrorAction SilentlyContinue)) {
        New-EmojiCollection -Name "Developer" -Description "Development & coding" -Emojis @("💻", "🐛", "🔧", "🚀", "📝", "✅", "❌", "⚠️", "💡", "🔥")
    }

    # Social
    if (-not (Get-EmojiCollection -Name "Social" -ErrorAction SilentlyContinue)) {
        New-EmojiCollection -Name "Social" -Description "Social media engagement" -Emojis @("👍", "❤️", "😂", "🎉", "👏", "🔥", "💯", "✨", "🙌", "💪")
    }

    # Status
    if (-not (Get-EmojiCollection -Name "Status" -ErrorAction SilentlyContinue)) {
        New-EmojiCollection -Name "Status" -Description "Status indicators" -Emojis @("✅", "❌", "⚠️", "🔴", "🟡", "🟢", "⏰", "📊", "📈", "📉")
    }

    # Favorites (empty, user fills it)
    if (-not (Get-EmojiCollection -Name "Favorites" -ErrorAction SilentlyContinue)) {
        New-EmojiCollection -Name "Favorites" -Description "Your favorite emojis" -Emojis @()
    }

    Write-Host "✅ Created default collections!" -ForegroundColor Green
    Write-Host "   Run 'Get-EmojiCollection' to see them" -ForegroundColor Gray
}
