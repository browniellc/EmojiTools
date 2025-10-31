function Join-Emoji {
    <#
    .SYNOPSIS
        Combines multiple emojis into a single composed emoji using Zero Width Joiner.
    
    .DESCRIPTION
        Joins emojis together using the Unicode Zero Width Joiner (ZWJ) character (U+200D).
        This creates composed emojis like family members, professions, or combined symbols.
        
        Note: Not all emoji combinations are valid or supported by all systems.
        The result depends on font and platform support for the specific ZWJ sequence.
    
    .PARAMETER Emojis
        Array of emojis to combine. Can be emoji characters or names.
    
    .PARAMETER AsString
        Return the composed emoji as a string instead of an object
    
    .PARAMETER ShowComponents
        Display the individual components being combined
    
    .EXAMPLE
        Join-Emoji -Emojis "👨", "👩", "👧"
        Creates a family emoji (man-woman-girl)
    
    .EXAMPLE
        Join-Emoji -Emojis "🏳️", "🌈"
        Creates a rainbow flag
    
    .EXAMPLE
        "👁️", "🗨️" | Join-Emoji -AsString
        Creates an eye in speech bubble emoji and returns as string
    
    .EXAMPLE
        Join-Emoji -Emojis "man", "laptop" -ShowComponents
        Joins man + laptop emojis with component display
    
    .NOTES
        Common ZWJ sequences:
        - Family compositions: Person + Person + Child
        - Profession: Person + Object (👨‍💻 = man + laptop)
        - Flags: Flag + Symbol (🏳️‍🌈 = white flag + rainbow)
        - Skin tones: Use Get-EmojiWithSkinTone for those
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [string[]]$Emojis,
        
        [Parameter(Mandatory = $false)]
        [switch]$AsString,
        
        [Parameter(Mandatory = $false)]
        [switch]$ShowComponents
    )
    
    begin {
        $datasetPath = Join-Path $PSScriptRoot "..\data\emoji.csv"
        
        if (-not (Test-Path $datasetPath)) {
            Write-Error "Emoji dataset not found at $datasetPath"
            return
        }
        
        $allEmojis = Import-Csv -Path $datasetPath -Encoding UTF8
        $components = @()
    }
    
    process {
        foreach ($emoji in $Emojis) {
            # Check if it's already an emoji character
            # Emojis can be 1-10+ chars due to modifiers and ZWJ sequences
            if ($emoji.Length -le 20) {
                # Assume short strings might be emojis - try using directly first
                $isEmoji = $false
                foreach ($char in $emoji.ToCharArray()) {
                    $cat = [System.Char]::GetUnicodeCategory($char)
                    if ($cat -eq [System.Globalization.UnicodeCategory]::OtherSymbol -or
                        $cat -eq [System.Globalization.UnicodeCategory]::Surrogate -or
                        [int]$char -ge 0x1F000) {
                        $isEmoji = $true
                        break
                    }
                }
                
                if ($isEmoji) {
                    $components += $emoji
                    if ($ShowComponents) {
                        Write-Host "  $emoji - (emoji character)" -ForegroundColor Cyan
                    }
                    continue
                }
            }
            
            # Try to find by name
            $found = $allEmojis | Where-Object { 
                $_.name -like "*$emoji*" 
            } | Select-Object -First 1
            
            if ($found) {
                $components += $found.emoji
                if ($ShowComponents) {
                    Write-Host "  $($found.emoji) - $($found.name)" -ForegroundColor Cyan
                }
            }
            else {
                Write-Warning "Could not find emoji matching '$emoji'"
            }
        }
    }
    
    end {
        if ($components.Count -lt 2) {
            Write-Error "Need at least 2 emojis to join. Found: $($components.Count)"
            return
        }
        
        # Zero Width Joiner
        $zwj = [char]0x200D
        
        # Join emojis with ZWJ
        $composed = $components -join $zwj
        
        if ($ShowComponents) {
            Write-Host "`nComponents:" -ForegroundColor Yellow
            foreach ($comp in $components) {
                Write-Host "  $comp" -ForegroundColor White
            }
            Write-Host "`nZWJ Sequence:" -ForegroundColor Yellow
            Write-Host "  $composed" -ForegroundColor Green -NoNewline
            Write-Host " (U+" -NoNewline -ForegroundColor Gray
            foreach ($char in $composed.ToCharArray()) {
                Write-Host ([int][char]$char).ToString("X4") -NoNewline -ForegroundColor Gray
                Write-Host " " -NoNewline
            }
            Write-Host ")" -ForegroundColor Gray
        }
        
        if ($AsString) {
            return $composed
        }
        else {
            # Try to find if this is a known composed emoji
            $name = "Composed: " + ($components -join " + ")
            
            [PSCustomObject]@{
                Emoji = $composed
                Name = $name
                Components = $components
                CodePoints = ($composed.ToCharArray() | ForEach-Object { "U+{0:X4}" -f [int][char]$_ }) -join " "
                IsSupported = "Unknown (depends on system font support)"
            }
        }
    }
}

