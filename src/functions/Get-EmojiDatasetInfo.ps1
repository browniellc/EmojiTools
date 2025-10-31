function Get-EmojiDatasetInfo {
    <#
    .SYNOPSIS
        Gets information about the current emoji dataset.

    .DESCRIPTION
        Displays metadata about the loaded emoji dataset including source,
        last update time, version, and recommendations for updates.

    .EXAMPLE
        Get-EmojiDatasetInfo
        Shows dataset information and update status
    #>

    [CmdletBinding()]
    param()

    $ModulePath = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
    $dataPath = Join-Path $ModulePath "data\emoji.csv"
    $metadataPath = Join-Path $ModulePath "data\metadata.json"

    Write-Host "`n📊 Emoji Dataset Information" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan

    # Dataset file info
    if (Test-Path $dataPath) {
        $dataFile = Get-Item $dataPath
        $dataAge = (Get-Date) - $dataFile.LastWriteTime

        Write-Host "📁 Dataset File:" -ForegroundColor Yellow
        Write-Host "   Path: $dataPath" -ForegroundColor White
        Write-Host "   Size: $([math]::Round($dataFile.Length / 1KB, 2)) KB" -ForegroundColor White
        Write-Host "   Last Modified: $($dataFile.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor White
        Write-Host "   Age: $([math]::Round($dataAge.TotalDays, 1)) days old" -ForegroundColor White

        # Emoji count
        $emojiCount = $Script:EmojiData.Count
        Write-Host "`n📦 Dataset Content:" -ForegroundColor Yellow
        Write-Host "   Total Emojis: $emojiCount" -ForegroundColor White

        # Category breakdown
        if ($Script:EmojiData) {
            $categories = $Script:EmojiData | Where-Object { $_.category } |
                Group-Object -Property category |
                Select-Object Name, Count |
                Sort-Object Count -Descending

            if ($categories) {
                Write-Host "`n📂 Categories:" -ForegroundColor Yellow
                foreach ($cat in $categories | Select-Object -First 5) {
                    Write-Host "   • $($cat.Name): $($cat.Count) emojis" -ForegroundColor White
                }
                if ($categories.Count -gt 5) {
                    Write-Host "   ... and $($categories.Count - 5) more categories" -ForegroundColor Gray
                }
            }
        }
    }
    else {
        Write-Host "⚠️  No dataset file found!" -ForegroundColor Red
        Write-Host "   Run Update-EmojiDataset to download emoji data." -ForegroundColor Yellow
    }

    # Metadata info
    if (Test-Path $metadataPath) {
        try {
            $metadata = Get-Content $metadataPath -Raw | ConvertFrom-Json
            Write-Host "`n🔖 Metadata:" -ForegroundColor Yellow
            Write-Host "   Source: $($metadata.Source)" -ForegroundColor White
            Write-Host "   Version: $($metadata.Version)" -ForegroundColor White
            Write-Host "   Last Update: $($metadata.LastUpdate)" -ForegroundColor White
            Write-Host "   Emoji Count: $($metadata.EmojiCount)" -ForegroundColor White
        }
        catch {
            Write-Verbose "Could not read metadata: $_"
        }
    }

    # Recent changes (Option C notification)
    $historyPath = Join-Path $ModulePath "data\history.json"
    if (Test-Path $historyPath) {
        try {
            $history = Get-Content $historyPath -Encoding UTF8 | ConvertFrom-Json
            if ($history.updates -and $history.updates.Count -gt 0) {
                $recentUpdates = $history.updates | Where-Object {
                    $updateDate = [datetime]$_.date
                    $daysAgo = (New-TimeSpan -Start $updateDate -End (Get-Date)).Days
                    $daysAgo -le 7
                }

                if ($recentUpdates) {
                    Write-Host "`n📈 Recent Changes (Last 7 Days):" -ForegroundColor Yellow

                    foreach ($update in ($recentUpdates | Select-Object -First 3)) {
                        $updateDate = [datetime]$update.date
                        $daysAgo = (New-TimeSpan -Start $updateDate -End (Get-Date)).Days

                        Write-Host "   📅 $($updateDate.ToString('yyyy-MM-dd')) ($daysAgo days ago) - $($update.source)" -ForegroundColor Cyan

                        if ($update.added.Count -gt 0) {
                            Write-Host "      +$($update.added.Count) emojis added" -ForegroundColor Green
                        }
                        if ($update.removed.Count -gt 0) {
                            Write-Host "      -$($update.removed.Count) emojis removed" -ForegroundColor Yellow
                        }
                        if ($update.modified.Count -gt 0) {
                            Write-Host "      ~$($update.modified.Count) emojis modified" -ForegroundColor Cyan
                        }
                        if ($update.added.Count -eq 0 -and $update.removed.Count -eq 0 -and $update.modified.Count -eq 0) {
                            Write-Host "      No changes" -ForegroundColor Gray
                        }
                    }

                    if ($recentUpdates.Count -gt 3) {
                        Write-Host "   ... and $($recentUpdates.Count - 3) more update(s)" -ForegroundColor Gray
                    }

                    Write-Host "   Run 'Get-NewEmojis' to see details" -ForegroundColor Gray
                }
            }
        }
        catch {
            Write-Verbose "Could not read emoji history: $_"
        }
    }

    # Update recommendations
    Write-Host "`n💡 Recommendations:" -ForegroundColor Yellow
    if (Test-Path $dataPath) {
        $dataFile = Get-Item $dataPath
        $dataAge = (Get-Date) - $dataFile.LastWriteTime

        if ($dataAge.TotalDays -gt 30) {
            Write-Host "   ⚠️  Dataset is over 30 days old - UPDATE RECOMMENDED" -ForegroundColor Red
            Write-Host "   Run: Update-EmojiDataset -Source Unicode" -ForegroundColor Yellow
        }
        elseif ($dataAge.TotalDays -gt 7) {
            Write-Host "   ℹ️  Dataset is over 7 days old - consider updating" -ForegroundColor Yellow
            Write-Host "   Run: Update-EmojiDataset -Source Unicode" -ForegroundColor Cyan
        }
        else {
            Write-Host "   ✅ Dataset is current (less than 7 days old)" -ForegroundColor Green
        }
    }

    # Configuration
    if ($Script:EmojiToolsConfig) {
        Write-Host "`n⚙️  Configuration:" -ForegroundColor Yellow
        Write-Host "   Auto-Update Check: $($Script:EmojiToolsConfig.AutoUpdateCheck)" -ForegroundColor White
        Write-Host "   Update Interval: $($Script:EmojiToolsConfig.UpdateInterval) days" -ForegroundColor White
    }

    Write-Host "`n═══════════════════════════════════════`n" -ForegroundColor Cyan
}
