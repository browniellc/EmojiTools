function Get-EmojiWithSkinTone {
    <#
    .SYNOPSIS
        Applies skin tone modifiers to emojis that support them.
    
    .DESCRIPTION
        The Get-EmojiWithSkinTone function applies Fitzpatrick skin tone modifiers to emojis
        that support them (primarily people and body part emojis). Skin tones range from
        light to dark following the Fitzpatrick scale.
        
        Skin tone modifiers:
        - Light: 🏻 (U+1F3FB)
        - Medium-Light: 🏼 (U+1F3FC)
        - Medium: 🏽 (U+1F3FD)
        - Medium-Dark: 🏾 (U+1F3FE)
        - Dark: 🏿 (U+1F3FF)
    
    .PARAMETER Emoji
        The base emoji to apply skin tone to. Accepts pipeline input.
    
    .PARAMETER SkinTone
        The skin tone to apply. Options: Light, MediumLight, Medium, MediumDark, Dark, or All.
        Use 'All' to return all skin tone variants.
    
    .PARAMETER ShowAll
        Returns all skin tone variants including the default (yellow) emoji.
    
    .EXAMPLE
        Get-EmojiWithSkinTone -Emoji "👍" -SkinTone Light
        Returns: 👍🏻 (thumbs up with light skin tone)
    
    .EXAMPLE
        Get-EmojiWithSkinTone -Emoji "👋" -SkinTone Dark
        Returns: 👋🏿 (waving hand with dark skin tone)
    
    .EXAMPLE
        Get-EmojiWithSkinTone -Emoji "🤝" -ShowAll
        Returns all skin tone variants of the handshake emoji.
    
    .EXAMPLE
        Search-Emoji -Query "thumbs up" | Get-EmojiWithSkinTone -SkinTone Medium
        Searches for thumbs up and applies medium skin tone.
    
    .EXAMPLE
        Get-EmojiWithSkinTone -Emoji "👨" -SkinTone All
        Returns all skin tone variants of the man emoji.
    
    .NOTES
        Not all emojis support skin tones. Only human-related emojis (people, body parts,
        hand gestures, etc.) can have skin tone modifiers applied.
    #>
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0
        )]
        [string]$Emoji,
        
        [Parameter(Position = 1)]
        [ValidateSet('Light', 'MediumLight', 'Medium', 'MediumDark', 'Dark', 'All')]
        [string]$SkinTone = 'Light',
        
        [Parameter()]
        [switch]$ShowAll
    )
    
    begin {
        # Fitzpatrick skin tone modifiers (as Unicode strings)
        $skinToneModifiers = @{
            'Light' = [System.Char]::ConvertFromUtf32(0x1F3FB)  # 🏻
            'MediumLight' = [System.Char]::ConvertFromUtf32(0x1F3FC)  # 🏼
            'Medium' = [System.Char]::ConvertFromUtf32(0x1F3FD)  # 🏽
            'MediumDark' = [System.Char]::ConvertFromUtf32(0x1F3FE)  # 🏾
            'Dark' = [System.Char]::ConvertFromUtf32(0x1F3FF)  # 🏿
        }
        
        # Emojis that support skin tone modifiers (Unicode categories)
        # This is a comprehensive list of base emojis that accept skin tones
        $supportsSkinTone = @(
            # Hand gestures
            '👋', '🤚', '🖐', '✋', '🖖', '👌', '🤌', '🤏', '✌', '🤞', '🫰',
            '🤟', '🤘', '🤙', '👈', '👉', '👆', '🖕', '👇', '☝', '🫵', '👍',
            '👎', '✊', '👊', '🤛', '🤜', '👏', '🙌', '🫶', '👐', '🤲', '🤝',
            '🙏', '✍', '💅', '🤳', '💪', '🦵', '🦶', '👂', '🦻', '👃',
            
            # People
            '👶', '👧', '🧒', '👦', '👩', '🧑', '👨', '👩‍🦱', '🧑‍🦱', '👨‍🦱',
            '👩‍🦰', '🧑‍🦰', '👨‍🦰', '👱‍♀️', '👱', '👱‍♂️', '👩‍🦳', '🧑‍🦳', '👨‍🦳',
            '👩‍🦲', '🧑‍🦲', '👨‍🦲', '🧔‍♀️', '🧔', '🧔‍♂️', '👵', '🧓', '👴',
            '👲', '👳‍♀️', '👳', '👳‍♂️', '🧕', '👮‍♀️', '👮', '👮‍♂️', '👷‍♀️', '👷',
            '👷‍♂️', '💂‍♀️', '💂', '💂‍♂️', '🕵‍♀️', '🕵', '🕵‍♂️', '👩‍⚕️', '🧑‍⚕️',
            '👨‍⚕️', '👩‍🌾', '🧑‍🌾', '👨‍🌾', '👩‍🍳', '🧑‍🍳', '👨‍🍳', '👩‍🎓', '🧑‍🎓',
            '👨‍🎓', '👩‍🎤', '🧑‍🎤', '👨‍🎤', '👩‍🏫', '🧑‍🏫', '👨‍🏫', '👩‍🏭', '🧑‍🏭',
            '👨‍🏭', '👩‍💻', '🧑‍💻', '👨‍💻', '👩‍💼', '🧑‍💼', '👨‍💼', '👩‍🔧', '🧑‍🔧',
            '👨‍🔧', '👩‍🔬', '🧑‍🔬', '👨‍🔬', '👩‍🎨', '🧑‍🎨', '👨‍🎨', '👩‍🚒', '🧑‍🚒',
            '👨‍🚒', '👩‍✈️', '🧑‍✈️', '👨‍✈️', '👩‍🚀', '🧑‍🚀', '👨‍🚀', '👩‍⚖️', '🧑‍⚖️',
            '👨‍⚖️', '👰‍♀️', '👰', '👰‍♂️', '🤵‍♀️', '🤵', '🤵‍♂️', '👸', '🤴',
            '🥷', '🦸‍♀️', '🦸', '🦸‍♂️', '🦹‍♀️', '🦹', '🦹‍♂️', '🤶', '🧑‍🎄', '🎅',
            '🧙‍♀️', '🧙', '🧙‍♂️', '🧝‍♀️', '🧝', '🧝‍♂️', '🧛‍♀️', '🧛', '🧛‍♂️',
            '🧜‍♀️', '🧜', '🧜‍♂️', '🧚‍♀️', '🧚', '🧚‍♂️', '👼', '🤰', '🫃', '🫄',
            '🤱', '👩‍🍼', '🧑‍🍼', '👨‍🍼', '🙇‍♀️', '🙇', '🙇‍♂️', '💁‍♀️', '💁', '💁‍♂️',
            '🙅‍♀️', '🙅', '🙅‍♂️', '🙆‍♀️', '🙆', '🙆‍♂️', '🙋‍♀️', '🙋', '🙋‍♂️',
            '🧏‍♀️', '🧏', '🧏‍♂️', '🤦‍♀️', '🤦', '🤦‍♂️', '🤷‍♀️', '🤷', '🤷‍♂️',
            '🙎‍♀️', '🙎', '🙎‍♂️', '🙍‍♀️', '🙍', '🙍‍♂️', '💇‍♀️', '💇', '💇‍♂️',
            '💆‍♀️', '💆', '💆‍♂️', '🧖‍♀️', '🧖', '🧖‍♂️', '💅', '🤳', '💃', '🕺',
            '👯‍♀️', '👯', '👯‍♂️', '🕴', '👩‍🦽', '🧑‍🦽', '👨‍🦽', '👩‍🦼', '🧑‍🦼',
            '👨‍🦼', '🚶‍♀️', '🚶', '🚶‍♂️', '👩‍🦯', '🧑‍🦯', '👨‍🦯', '🧎‍♀️', '🧎',
            '🧎‍♂️', '🏃‍♀️', '🏃', '🏃‍♂️', '🧍‍♀️', '🧍', '🧍‍♂️', '👫', '👭', '👬',
            '👩‍❤️‍👨', '👩‍❤️‍👩', '👨‍❤️‍👨', '👩‍❤️‍💋‍👨', '👩‍❤️‍💋‍👩', '👨‍❤️‍💋‍👨',
            
            # Sports & Activities
            '🧗‍♀️', '🧗', '🧗‍♂️', '🏇', '⛷', '🏂', '🏌‍♀️', '🏌', '🏌‍♂️', '🏄‍♀️',
            '🏄', '🏄‍♂️', '🚣‍♀️', '🚣', '🚣‍♂️', '🏊‍♀️', '🏊', '🏊‍♂️', '⛹‍♀️', '⛹',
            '⛹‍♂️', '🏋‍♀️', '🏋', '🏋‍♂️', '🚴‍♀️', '🚴', '🚴‍♂️', '🚵‍♀️', '🚵', '🚵‍♂️',
            '🤸‍♀️', '🤸', '🤸‍♂️', '🤽‍♀️', '🤽', '🤽‍♂️', '🤾‍♀️', '🤾', '🤾‍♂️',
            '🤹‍♀️', '🤹', '🤹‍♂️', '🧘‍♀️', '🧘', '🧘‍♂️', '🛀', '🛌'
        )
        
        $results = @()
    }
    
    process {
        # Remove any existing skin tone modifiers
        $baseEmoji = $Emoji
        foreach ($modifier in $skinToneModifiers.Values) {
            $baseEmoji = $baseEmoji.Replace($modifier, '')
        }
        
        # Check if this emoji supports skin tones
        $supportsModifier = $false
        foreach ($supportedEmoji in $supportsSkinTone) {
            if ($baseEmoji -like "*$supportedEmoji*") {
                $supportsModifier = $true
                break
            }
        }
        
        if (-not $supportsModifier) {
            Write-Warning "Emoji '$Emoji' does not support skin tone modifiers."
            if ($ShowAll) {
                $results += [PSCustomObject]@{
                    Emoji = $baseEmoji
                    SkinTone = 'Default'
                    Name = 'Default (Yellow)'
                }
            }
            else {
                return $baseEmoji
            }
            return
        }
        
        # Generate requested skin tone variant(s)
        if ($SkinTone -eq 'All' -or $ShowAll) {
            # Add default emoji if ShowAll
            if ($ShowAll) {
                $results += [PSCustomObject]@{
                    Emoji = $baseEmoji
                    SkinTone = 'Default'
                    Name = 'Default (Yellow)'
                }
            }
            
            # Add all skin tone variants
            foreach ($tone in @('Light', 'MediumLight', 'Medium', 'MediumDark', 'Dark')) {
                $modifier = $skinToneModifiers[$tone]
                $displayName = switch ($tone) {
                    'Light' { 'Light' }
                    'MediumLight' { 'Medium-Light' }
                    'Medium' { 'Medium' }
                    'MediumDark' { 'Medium-Dark' }
                    'Dark' { 'Dark' }
                }
                $results += [PSCustomObject]@{
                    Emoji = "$baseEmoji$modifier"
                    SkinTone = $tone
                    Name = $displayName
                }
            }
        }
        else {
            # Return single skin tone variant
            $modifier = $skinToneModifiers[$SkinTone]
            return "$baseEmoji$modifier"
        }
    }
    
    end {
        if ($results.Count -gt 0) {
            $results | Format-Table -AutoSize
        }
    }
}

