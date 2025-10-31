function Import-CustomEmojiDataset {
    <#
    .SYNOPSIS
        Imports a custom emoji dataset from a CSV or JSON file.

    .DESCRIPTION
        Loads emojis from a custom dataset file, allowing you to use specialized
        emoji collections, company-specific emojis, or extended Unicode sets.

        The dataset can be in CSV or JSON format and will be validated before import.

    .PARAMETER Path
        Path to the custom dataset file (CSV or JSON)

    .PARAMETER Replace
        Replace the entire dataset (default is to merge with existing)

    .PARAMETER Validate
        Validate emoji characters before importing

    .PARAMETER SetAsDefault
        Set this dataset as the default data source for future sessions

    .EXAMPLE
        Import-CustomEmojiDataset -Path "company-emojis.csv"
        Imports and merges company emojis with existing dataset

    .EXAMPLE
        Import-CustomEmojiDataset -Path "custom.json" -Replace
        Replaces entire dataset with custom emojis

    .EXAMPLE
        Import-CustomEmojiDataset -Path "extended.csv" -SetAsDefault
        Imports dataset and sets it as default for future sessions
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path $_ })]
        [string]$Path,

        [Parameter()]
        [switch]$Replace,

        [Parameter()]
        [switch]$Validate,

        [Parameter()]
        [switch]$SetAsDefault,

        # Added for compatibility with tests and non-interactive callers
        [Parameter()]
        [switch]$Force
    )

    if (-not (Test-Path $Path)) {
        Write-Error "File not found: $Path"
        return
    }

    $extension = [System.IO.Path]::GetExtension($Path).ToLower()

    try {
        # Load custom dataset based on format
        switch ($extension) {
            '.csv' {
                $customData = Import-Csv $Path -Encoding UTF8
            }
            '.json' {
                $jsonContent = Get-Content $Path -Raw -Encoding UTF8
                $customData = $jsonContent | ConvertFrom-Json
            }
            default {
                Write-Error "Unsupported file format: $extension. Use .csv or .json"
                return
            }
        }

        # Validate required columns/properties
        $requiredFields = @('emoji', 'name')
        $sampleItem = $customData | Select-Object -First 1

        foreach ($field in $requiredFields) {
            if (-not ($sampleItem.PSObject.Properties.Name -contains $field)) {
                Write-Error "Dataset missing required field: '$field'. Required fields: emoji, name, category (optional), keywords (optional)"
                return
            }
        }

        # Optionally validate emoji characters
        if ($Validate) {
            Write-Host "🔍 Validating emoji characters..." -ForegroundColor Cyan
            $validCount = 0
            $invalidCount = 0

            foreach ($item in $customData) {
                # Simple validation: check if it contains emoji-like characters
                if ($item.emoji -match '[\u{1F000}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]') {
                    $validCount++
                }
                else {
                    $invalidCount++
                    Write-Verbose "Invalid or non-emoji character: $($item.emoji) - $($item.name)"
                }
            }

            Write-Host "   Valid: $validCount, Invalid: $invalidCount" -ForegroundColor Gray
        }

        # Normalize data structure (add missing optional fields)
        $normalizedData = $customData | ForEach-Object {
            [PSCustomObject]@{
                emoji = $_.emoji
                name = $_.name
                category = if ($_.category) { $_.category } else { "Custom" }
                keywords = if ($_.keywords) { $_.keywords } else { $_.name }
            }
        }

        # Import the data
        if ($Replace) {
            $Script:EmojiData = $normalizedData
            Write-Host "✅ Replaced dataset with $($normalizedData.Count) custom emojis" -ForegroundColor Green
        }
        else {
            # Merge: Add custom emojis, skip duplicates
            $existingEmojis = $Script:EmojiData.emoji
            $newEmojis = $normalizedData | Where-Object { $existingEmojis -notcontains $_.emoji }

            $Script:EmojiData = @($Script:EmojiData) + @($newEmojis)

            Write-Host "✅ Imported $($newEmojis.Count) new emojis (skipped $($normalizedData.Count - $newEmojis.Count) duplicates)" -ForegroundColor Green
            Write-Host "   Total dataset size: $($Script:EmojiData.Count) emojis" -ForegroundColor Gray
        }

        # Optionally save as default dataset
        if ($SetAsDefault) {
            $targetPath = $Script:EmojiToolsConfig.DataPath

            # Backup existing dataset
            if (Test-Path $targetPath) {
                $backupPath = $targetPath -replace '\.csv$', "-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
                Copy-Item $targetPath $backupPath
                Write-Host "   📦 Backed up original dataset to: $backupPath" -ForegroundColor Gray
            }

            # Save new dataset
            $Script:EmojiData | Export-Csv $targetPath -NoTypeInformation -Encoding UTF8
            Write-Host "   💾 Saved as default dataset" -ForegroundColor Green
        }

    }
    catch {
        Write-Error "Failed to import custom dataset: $_"
    }
}

function Export-CustomEmojiDataset {
    <#
    .SYNOPSIS
        Exports the current emoji dataset to a custom format.

    .DESCRIPTION
        Saves the current emoji dataset (or a filtered subset) to CSV or JSON format.
        Useful for creating custom datasets, backups, or sharing collections.

    .PARAMETER Path
        Output file path

    .PARAMETER Format
        Output format: CSV or JSON

    .PARAMETER Category
        Export only emojis from specific category

    .PARAMETER Query
        Export only emojis matching search query

    .PARAMETER IncludeAll
        Include all fields (default exports only: emoji, name, category, keywords)

    .EXAMPLE
        Export-CustomEmojiDataset -Path "my-emojis.csv" -Format CSV
        Exports entire dataset to CSV

    .EXAMPLE
        Export-CustomEmojiDataset -Path "animals.json" -Format JSON -Category "Animals & Nature"
        Exports only animal emojis to JSON

    .EXAMPLE
        Export-CustomEmojiDataset -Path "hearts.csv" -Query "heart"
        Exports heart emojis to CSV
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter()]
        [ValidateSet('CSV', 'JSON')]
        [string]$Format = 'CSV',

        [Parameter()]
        [string]$Category,

        [Parameter()]
        [string]$Query,

        [Parameter()]
        [switch]$IncludeAll
    )

    $dataToExport = $Script:EmojiData

    # Apply filters
    if ($Category) {
        $dataToExport = $dataToExport | Where-Object { $_.category -eq $Category }
    }

    if ($Query) {
        $dataToExport = $dataToExport | Where-Object {
            $_.name -like "*$Query*" -or $_.keywords -like "*$Query*"
        }
    }

    if (-not $IncludeAll) {
        # Export only essential fields
        $dataToExport = $dataToExport | Select-Object emoji, name, category, keywords
    }

    try {
        switch ($Format) {
            'CSV' {
                $dataToExport | Export-Csv $Path -NoTypeInformation -Encoding UTF8
            }
            'JSON' {
                $dataToExport | ConvertTo-Json -Depth 10 | Set-Content $Path -Encoding UTF8
            }
        }

        Write-Host "✅ Exported $($dataToExport.Count) emojis to $Path" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to export dataset: $_"
    }
}

function New-CustomEmojiDataset {
    <#
    .SYNOPSIS
        Creates a new custom emoji dataset from scratch.

    .DESCRIPTION
        Interactive wizard to create a custom emoji dataset. You can add emojis
        one by one or import from clipboard.

    .PARAMETER Path
        Output file path for the new dataset

    .PARAMETER Format
        Output format: CSV or JSON (default: CSV)

    .EXAMPLE
        New-CustomEmojiDataset -Path "my-dataset.csv"
        Creates a new dataset interactively
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Path,

        [Parameter()]
        [ValidateSet('CSV', 'JSON')]
        [string]$Format = 'CSV',

        # Allow non-interactive creation from provided data (used by tests)
        [Parameter()]
        [array]$Data,

        [Parameter()]
        [switch]$Force
    )

    # If data is provided programmatically, use it (non-interactive path)
    if ($Data) {
        try {
            $normalizedData = $Data | ForEach-Object {
                [PSCustomObject]@{
                    emoji = $_.Emoji -or $_.emoji
                    name = $_.Name -or $_.name
                    category = if ($_.Category -or $_.category) { ($_.Category -or $_.category) } else { 'Custom' }
                    keywords = if ($_.Keywords -or $_.keywords) { ($_.Keywords -or $_.keywords) } else { ($_.Name -or $_.name) }
                }
            }

            # Merge into current dataset (skip duplicates)
            if (-not $Script:EmojiData) { $Script:EmojiData = @() }
            $existingEmojis = $Script:EmojiData.emoji
            $newEmojis = $normalizedData | Where-Object { $existingEmojis -notcontains $_.emoji }
            $Script:EmojiData = @($Script:EmojiData) + @($newEmojis)

            Write-Host "✅ Created/merged $($newEmojis.Count) emoji(s) from provided data" -ForegroundColor Green
            return
        }
        catch {
            Write-Error "Failed to create dataset from provided data: $_"
            return
        }
    }

    Write-Host "`n📝 Custom Emoji Dataset Creator" -ForegroundColor Cyan
    Write-Host ("=" * 60) -ForegroundColor Cyan

    $emojis = @()

    Write-Host "`nAdd emojis to your dataset (press Ctrl+C to finish):" -ForegroundColor Yellow
    Write-Host "You'll be prompted for: emoji, name, category, keywords`n" -ForegroundColor Gray

    $continue = $true
    $count = 0

    while ($continue) {
        try {
            $count++
            Write-Host "Emoji #$count" -ForegroundColor Cyan

            $emoji = Read-Host "  Emoji character"
            if ([string]::IsNullOrWhiteSpace($emoji)) {
                Write-Host "Skipping empty emoji. Finishing..." -ForegroundColor Yellow
                break
            }

            $name = Read-Host "  Name"
            if ([string]::IsNullOrWhiteSpace($name)) {
                $name = "Unnamed"
            }

            $category = Read-Host "  Category (optional)"
            if ([string]::IsNullOrWhiteSpace($category)) {
                $category = "Custom"
            }

            $keywords = Read-Host "  Keywords (comma-separated, optional)"
            if ([string]::IsNullOrWhiteSpace($keywords)) {
                $keywords = $name
            }

            $emojis += [PSCustomObject]@{
                emoji = $emoji
                name = $name
                category = $category
                keywords = $keywords
            }

            Write-Host "  ✅ Added: $emoji - $name`n" -ForegroundColor Green
        }
        catch {
            Write-Host "`nFinished adding emojis." -ForegroundColor Cyan
            $continue = $false
        }
    }

    if ($emojis.Count -eq 0) {
        Write-Host "No emojis added. Exiting." -ForegroundColor Yellow
        return
    }

    # ShouldProcess check
    if (-not $PSCmdlet.ShouldProcess($Path, "Create custom dataset with $($emojis.Count) emoji(s)")) {
        return
    }

    # Save dataset
    try {
        switch ($Format) {
            'CSV' {
                $emojis | Export-Csv $Path -NoTypeInformation -Encoding UTF8
            }
            'JSON' {
                $emojis | ConvertTo-Json -Depth 10 | Set-Content $Path -Encoding UTF8
            }
        }

        Write-Host "`n✅ Created custom dataset with $($emojis.Count) emojis" -ForegroundColor Green
        Write-Host "   Saved to: $Path" -ForegroundColor Gray
        Write-Host "`nTo use this dataset:" -ForegroundColor Cyan
        Write-Host "   Import-CustomEmojiDataset -Path '$Path'" -ForegroundColor White
    }
    catch {
        Write-Error "Failed to create dataset: $_"
    }
}

function Get-CustomEmojiDatasetInfo {
    <#
    .SYNOPSIS
        Displays information about the current emoji dataset.

    .DESCRIPTION
        Shows statistics about the loaded emoji dataset including total count,
        categories, source information, and custom datasets.

    .EXAMPLE
        Get-CustomEmojiDatasetInfo
        Displays dataset information
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n📊 Emoji Dataset Information" -ForegroundColor Cyan
    Write-Host ("=" * 60) -ForegroundColor Cyan

    Write-Host "`nDataset Statistics:" -ForegroundColor Yellow
    Write-Host ("  Total Emojis:      {0}" -f $Script:EmojiData.Count) -ForegroundColor White

    # Category breakdown
    $categories = $Script:EmojiData | Group-Object -Property category | Sort-Object Count -Descending
    Write-Host ("  Categories:        {0}" -f $categories.Count) -ForegroundColor White

    Write-Host "`nTop Categories:" -ForegroundColor Yellow
    $categories | Select-Object -First 10 | ForEach-Object {
        Write-Host ("  {0,-30} {1,4} emojis" -f $_.Name, $_.Count) -ForegroundColor White
    }

    # Source information
    $dataPath = $Script:EmojiToolsConfig.DataPath
    Write-Host "`nDataset Source:" -ForegroundColor Yellow
    Write-Host ("  Path:              {0}" -f $dataPath) -ForegroundColor White

    if (Test-Path $dataPath) {
        $fileInfo = Get-Item $dataPath
        Write-Host ("  Size:              {0:N2} KB" -f ($fileInfo.Length / 1KB)) -ForegroundColor White
        Write-Host ("  Last Modified:     {0}" -f $fileInfo.LastWriteTime) -ForegroundColor White

        $age = (Get-Date) - $fileInfo.LastWriteTime
        Write-Host ("  Age:               {0} days" -f [math]::Round($age.TotalDays, 1)) -ForegroundColor White
    }

    # Check for custom datasets
    $customCount = ($Script:EmojiData | Where-Object { $_.category -eq "Custom" }).Count
    if ($customCount -gt 0) {
        Write-Host "`nCustom Emojis:" -ForegroundColor Yellow
        Write-Host ("  Count:             {0}" -f $customCount) -ForegroundColor White
    }

    Write-Host "`n💡 Dataset Commands:" -ForegroundColor Cyan
    Write-Host "  Import-CustomEmojiDataset      # Load custom dataset" -ForegroundColor Gray
    Write-Host "  Export-CustomEmojiDataset      # Save dataset" -ForegroundColor Gray
    Write-Host "  New-CustomEmojiDataset         # Create new dataset" -ForegroundColor Gray
    Write-Host "`n"
}

function Reset-EmojiDataset {
    <#
    .SYNOPSIS
        Resets the emoji dataset to the default Unicode CLDR data.

    .DESCRIPTION
        Downloads and replaces the current dataset with fresh data from Unicode CLDR.
        Creates a backup of the current dataset before resetting.

    .PARAMETER Force
        Skip confirmation prompt

    .PARAMETER KeepBackup
        Keep backup of current dataset (default: backups are created unless this is explicitly set to false)

    .PARAMETER NoBackup
        Skip creating a backup of the current dataset

    .EXAMPLE
        Reset-EmojiDataset
        Resets dataset with confirmation and creates a backup

    .EXAMPLE
        Reset-EmojiDataset -Force
        Resets without confirmation
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter()]
        [switch]$Force,

        [Parameter()]
        [switch]$NoBackup
    )

    if (-not $Force -and -not $PSCmdlet.ShouldProcess("Emoji dataset", "Reset to Unicode CLDR defaults")) {
        return
    }

    Write-Host "`n🔄 Resetting emoji dataset..." -ForegroundColor Yellow

    $dataPath = $Script:EmojiToolsConfig.DataPath

    # Backup current dataset (default behavior unless explicitly disabled with -NoBackup)
    if (-not $NoBackup -and (Test-Path $dataPath)) {
        $backupPath = $dataPath -replace '\.csv$', "-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
        try {
            Copy-Item $dataPath $backupPath
            Write-Host "   📦 Backed up current dataset to: $backupPath" -ForegroundColor Gray
        }
        catch {
            Write-Warning "Failed to create backup: $_"
        }
    }

    # Download fresh dataset
    Write-Host "   📥 Downloading Unicode CLDR dataset..." -ForegroundColor Gray

    if (Get-Command Update-EmojiDataset -ErrorAction SilentlyContinue) {
        Update-EmojiDataset -Source Unicode -Force

        # Reload the dataset
        $Script:EmojiData = Import-Csv $dataPath -Encoding UTF8

        Write-Host "`n✅ Dataset reset complete!" -ForegroundColor Green
        Write-Host ("   Loaded {0} emojis from Unicode CLDR" -f $Script:EmojiData.Count) -ForegroundColor Gray
    }
    else {
        Write-Error "Update-EmojiDataset function not available."
    }
}
