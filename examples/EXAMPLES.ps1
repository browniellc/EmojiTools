# EmojiTools Usage Examples

# Import the module
# Note: From the project root, use the src/ path
Import-Module .\src\EmojiTools.psd1

# Note: On first import, EmojiTools automatically initializes default
# collections and aliases. You'll see a welcome message with setup progress.

## Example 1: Module Setup & Information
# View module information and status
Get-EmojiToolsInfo

# Manually re-initialize (if needed)
Initialize-EmojiTools -Force

# Initialize only specific components
Initialize-EmojiTools -SkipCollections  # Only aliases
Initialize-EmojiTools -SkipAliases      # Only collections

# Reset module to defaults (removes customizations)
Reset-EmojiTools

# Reset everything including statistics
Reset-EmojiTools -IncludeStats -Force

## Example 2: Getting Started
# List first 10 emojis
Get-Emoji -Limit 10

## Example 3: Search by keyword
# Find all smiley emojis
Search-Emoji -Query "smile"

# Find house emojis
Search-Emoji -Query "house"

# Find car emojis
Search-Emoji -Query "car" -Limit 5

## Example 3: Category filtering
# Get emojis from specific categories
Get-Emoji -Category "Animals & Nature" -Limit 10
Get-Emoji -Category "Food & Drink" -Limit 10
Get-Emoji -Category "Smileys & Emotion" -Limit 10

## Example 4: Using the safe Emoji dispatcher
# These are safer alternatives with built-in validation

# Search for emojis
Emoji Search "love"
Emoji Search "happy"

# Get emojis with category
Emoji Get -Category "Travel" -Limit 5

# List all (same as Get)
Emoji List -Limit 10

## Example 5: Update the dataset
# Download latest emoji data from GitHub (default, fastest)
Update-EmojiDataset

# Or from Unicode CLDR (most comprehensive)
Update-EmojiDataset -Source Unicode

# Force re-download
Update-EmojiDataset -Force

## Example 6: Exact matching
# Use exact matching instead of fuzzy search
Search-Emoji -Query "heart" -Exact

## Example 7: Combining operations
# Find all food emojis containing "egg"
Search-Emoji -Query "egg"

# Get all sports emojis
Get-Emoji -Category "Activities" | Where-Object { $_.keywords -like "*sports*" }

## Example 8: Clipboard Integration
# Copy emoji directly to clipboard
Copy-Emoji -Query "rocket"         # Copies 🚀 to clipboard
Copy-Emoji -Query "heart" -All     # Copies all heart emojis
Copy-Emoji "🎉"                     # Copy specific emoji directly
Emoji Copy "smile"                  # Using safe dispatcher

# Silent mode (no confirmation message)
Copy-Emoji -Query "tada" -Silent

## Example 9: Skin Tone Support
# Apply skin tones to emojis
Get-EmojiWithSkinTone -Emoji "👍" -SkinTone Light       # 👍🏻
Get-EmojiWithSkinTone -Emoji "👋" -SkinTone Dark        # 👋🏿
Get-EmojiWithSkinTone -Emoji "🤝" -SkinTone Medium      # 🤝🏽

# Show all skin tone variants
Get-EmojiWithSkinTone -Emoji "👍" -SkinTone All
Get-EmojiWithSkinTone -Emoji "🙋" -ShowAll

# Combine with search and clipboard
$thumbsUp = Get-EmojiWithSkinTone -Emoji "👍" -SkinTone MediumDark
Copy-Emoji $thumbsUp

## Example 10: Export to Different Formats
# Export all emojis to JSON
Export-Emoji -Format JSON -OutputPath "all-emojis.json"

# Export with metadata
Export-Emoji -Format JSON -OutputPath "emojis-with-info.json" -IncludeMetadata

# Export search results to HTML with dark theme
Export-Emoji -Format HTML -Query "heart" -Title "Heart Emojis" -StyleTheme Dark -OutputPath "hearts.html"

# Export category to Markdown
Export-Emoji -Format Markdown -Category "Animals & Nature" -Title "Animals" -IncludeMetadata

# Export to CSV (filtered)
Export-Emoji -Format CSV -Query "smile" -Limit 20 -OutputPath "smiles.csv"

# Export with PassThru (don't write file, return content)
$jsonContent = Export-Emoji -Format JSON -Limit 10 -PassThru
Write-Host "Exported $($jsonContent.Length) characters of JSON"

# Pipeline export: Search then export
Search-Emoji "food" | Export-Emoji -Format HTML -Title "Food Emojis" -StyleTheme Colorful

## Example 11: Exporting with Advanced Options
# Create interactive HTML catalog
Export-Emoji -Format HTML -Title "My Emoji Collection" -StyleTheme Light -IncludeMetadata -OutputPath "catalog.html"

# Export current search results
$results = Search-Emoji "animal"
$results | Export-Emoji -Format Markdown -Title "Animal Emojis" -OutputPath "animals.md"

# Export a collection (simple approach - NEW in v1.15.0)
Export-Emoji -Collection "Favorites" -Format HTML -StyleTheme Colorful -OutputPath "favorites.html"

# Export collection via pipeline
Get-EmojiCollection -Name "Developer" | Export-Emoji -Format JSON -OutputPath "developer-emojis.json"

# Export multiple collections to separate files
Get-EmojiCollection | ForEach-Object {
    $name = $_.Name
    Export-Emoji -Collection $name -Format HTML -OutputPath "$name.html"
}

## Example 12: Security demonstration
# These will be rejected by the Emoji dispatcher:
# Emoji Search "test; Remove-Item"  # ❌ Blocked - contains semicolon
# Emoji Search "test | Get-Process" # ❌ Blocked - contains pipe
# Emoji Search "test & whoami"      # ❌ Blocked - contains ampersand

## Example 13: Interactive Emoji Picker
# Open the interactive emoji picker (HTML browser-based)
Show-EmojiPicker

# Open picker with a specific category pre-selected
Show-EmojiPicker -Category "Smileys & Emotion"

# Open with dark theme
Show-EmojiPicker -Theme Dark

# Return selected emoji to variable (no clipboard)
$emoji = Show-EmojiPicker -ReturnEmoji
Write-Host "You selected: $emoji"

# Use custom port if default is in use
Show-EmojiPicker -Port 9000

# Quick access via Emoji dispatcher
Emoji Pick

## Example 14: Emoji Composition (ZWJ sequences)
# Combine emojis using Zero Width Joiner

# Create a family emoji
Join-Emoji -Emojis "👨", "👩", "👧"

# Create rainbow flag
Join-Emoji -Emojis "🏳️", "🌈" -ShowComponents

# Create profession emojis (man technologist)
Join-Emoji -Emojis "👨", "💻" -AsString

# Join by name
Join-Emoji -Emojis "man", "laptop" -ShowComponents

# Use with dispatcher
Emoji Join -Emojis "👁️", "🗨️"

# Multiple combinations
"👨", "🔬" | Join-Emoji  # Man scientist
"👩", "🚀" | Join-Emoji  # Woman astronaut
"👨", "🍳" | Join-Emoji  # Man cook

## Example 15: Custom Emoji Collections
# Create and manage custom collections

# Initialize default collections
Initialize-EmojiCollections

# View all collections
Get-EmojiCollection

# View specific collection
Get-EmojiCollection -Name "Developer"

# Create custom collection
New-EmojiCollection -Name "MyTeam" -Description "Team communication emojis"

# Add emojis to collection
Add-EmojiToCollection -Collection "MyTeam" -Emojis "👍", "✅", "🚀", "💯"

# Add more emojis
"🎉", "🎯" | Add-EmojiToCollection -Collection "MyTeam"

# Remove emoji from collection
Remove-EmojiFromCollection -Collection "MyTeam" -Emojis "🎯"

# Use collection in searches
Get-Emoji -Collection "Developer"
Search-Emoji -Query "bug" -Collection "Developer"
Show-EmojiPicker -Collection "MyTeam"

# Export collection to share
Export-EmojiCollection -Name "MyTeam" -Path "team-emojis.json"

# Import collection from file
Import-EmojiCollection -Path "team-emojis.json"

# Merge with existing
Import-EmojiCollection -Path "team-emojis.json" -Merge

# Remove collection
Remove-EmojiCollection -Name "MyTeam" -Force

## Example 16: Statistics & Analytics
# View emoji usage statistics
Get-EmojiStats

# Show only top 5 most used emojis
Get-EmojiStats -Type Usage -Top 5

# Show search query stats
Get-EmojiStats -Type Search -Top 10

# Show category distribution
Get-EmojiStats -Type Categories

# Show collection usage
Get-EmojiStats -Type Collections

# Filter stats from last 7 days
Get-EmojiStats -Since (Get-Date).AddDays(-7)

# Export statistics to HTML report
Export-EmojiStats -Path "stats.html" -Format HTML

# Export to JSON
Export-EmojiStats -Path "stats.json" -Format JSON

# Export to CSV
Export-EmojiStats -Path "stats.csv" -Format CSV

# Clear old statistics (keeps last 30 days)
Clear-EmojiStats -Type Usage -Force
Clear-EmojiStats -Type Search -Force

# Clear all statistics
Clear-EmojiStats -Type All -Force

## Example 17: Emoji Aliases & Shortcuts
# Initialize default aliases (70+ common shortcuts)
Initialize-DefaultEmojiAliases

# View all available aliases
Get-EmojiAlias -List

# Get emoji by alias
Get-EmojiAlias -Alias "fire"          # Returns 🔥
Get-EmojiAlias -Alias "rocket"        # Returns 🚀
Get-EmojiAlias -Alias "thumbsup"      # Returns 👍

# Get and copy in one command
Get-EmojiAlias -Alias "heart" -Copy   # Copies ❤️ to clipboard

# Create custom aliases
New-EmojiAlias -Alias "boom" -Emoji "💥"
New-EmojiAlias -Alias "yes" -Emoji "✅"
New-EmojiAlias -Alias "no" -Emoji "❌"

# Update existing alias
Set-EmojiAlias -Alias "fire" -Emoji "🔥"

# Remove an alias
Remove-EmojiAlias -Alias "boom"

# Export aliases for backup/sharing
Export-EmojiAliases -Path "my-aliases.json"

# Import aliases
Import-EmojiAliases -Path "my-aliases.json"

# Merge imported aliases with existing
Import-EmojiAliases -Path "my-aliases.json" -Merge

## Example 18: Working with the data
# Count emojis by category
Get-Emoji | Group-Object -Property category | Select-Object Name, Count

# Find emojis with specific keywords
Search-Emoji -Query "love"

# Get random emoji
Get-Emoji | Get-Random | Select-Object emoji, name

## Example 18: Custom Emoji Datasets
# View current dataset information
Get-CustomEmojiDatasetInfo

# Import custom emojis (merges with existing)
Import-CustomEmojiDataset -Path "company-emojis.csv"

# Replace entire dataset with custom one
Import-CustomEmojiDataset -Path "extended-unicode.json" -Replace

# Validate emoji characters during import
Import-CustomEmojiDataset -Path "untrusted.csv" -Validate

# Import and set as default dataset
Import-CustomEmojiDataset -Path "my-dataset.csv" -SetAsDefault

# Export entire dataset to CSV
Export-CustomEmojiDataset -Path "backup.csv" -Format CSV

# Export only specific category
Export-CustomEmojiDataset -Path "animals.json" -Format JSON -Category "Animals & Nature"

# Export filtered emojis
Export-CustomEmojiDataset -Path "hearts.csv" -Query "heart"

# Create a new custom dataset interactively
New-CustomEmojiDataset -Path "team-emojis.csv"

# Create custom dataset programmatically
$customEmojis = @(
    [PSCustomObject]@{ emoji = '🏢'; name = 'office'; category = 'Work'; keywords = 'building corporate business' }
    [PSCustomObject]@{ emoji = '💼'; name = 'briefcase'; category = 'Work'; keywords = 'business professional' }
    [PSCustomObject]@{ emoji = '📊'; name = 'chart'; category = 'Work'; keywords = 'data analytics graph' }
)
$customEmojis | Export-Csv "work-emojis.csv" -NoTypeInformation -Encoding UTF8
Import-CustomEmojiDataset -Path "work-emojis.csv"

# Reset to default Unicode CLDR dataset
Reset-EmojiDataset

# Reset without confirmation
Reset-EmojiDataset -Force

## Example 19: Advanced Custom Dataset Workflows
# Backup current dataset with version
$version = Get-Date -Format "yyyyMMdd"
Export-CustomEmojiDataset -Path "emoji-dataset-$version.csv"

# Create themed collections
Export-CustomEmojiDataset -Path "tech.csv" -Query "computer phone laptop"
Export-CustomEmojiDataset -Path "weather.csv" -Query "sun rain cloud snow"

# Combine multiple custom datasets
Import-CustomEmojiDataset -Path "set1.csv"
Import-CustomEmojiDataset -Path "set2.csv"  # Merges automatically
Import-CustomEmojiDataset -Path "set3.csv"

# Export subset for specific project
$projectEmojis = @('✅', '❌', '⚠️', '💡', '📝', '🚀')
Get-Emoji | Where-Object { $_.emoji -in $projectEmojis } |
    Export-Csv "project-emojis.csv" -NoTypeInformation -Encoding UTF8
