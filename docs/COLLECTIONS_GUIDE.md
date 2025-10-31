# 📁 Emoji Collections Guide

The EmojiTools module includes a powerful collections feature that lets you organize your favorite emojis into named groups for quick access. Think of collections as playlists for emojis!

---

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [What are Collections?](#what-are-collections)
3. [Default Collections](#default-collections)
4. [Creating Collections](#creating-collections)
5. [Managing Collections](#managing-collections)
6. [Using Collections](#using-collections)
7. [Import & Export](#import--export)
8. [Examples & Use Cases](#examples--use-cases)
9. [Troubleshooting](#troubleshooting)

---

## 🚀 Quick Start

```powershell
# View all collections
Get-EmojiCollection

# Get emojis from a collection
Get-EmojiCollection "favorites"

# Create a new collection
New-EmojiCollection -Name "work" -Description "Work-related emojis"

# Add emoji to collection
Add-EmojiToCollection -Name "work" -Emoji "💼"

# Remove emoji from collection
Remove-EmojiFromCollection -Name "work" -Emoji "💼"

# Delete a collection
Remove-EmojiCollection -Name "work"
```

---

## 💡 What are Collections?

**Collections** are named groups of emojis that you can:
- **Organize** - Group emojis by theme, purpose, or project
- **Access quickly** - Retrieve all emojis in a collection at once
- **Share** - Export and import collections as JSON files
- **Customize** - Add, remove, and modify emojis in collections

### Benefits

✅ **Quick Access** - No need to search repeatedly for the same emojis  
✅ **Organization** - Keep related emojis together  
✅ **Productivity** - Faster emoji selection for common tasks  
✅ **Sharing** - Share collections with team members  
✅ **Consistency** - Use the same set of emojis across projects  

---

## 🎯 Default Collections

EmojiTools comes with 6 default collections that are automatically created on first run:

### 1. **favorites** 
Most commonly used emojis for quick access
```
❤️ ⭐ 🎉 ✅ 🔥 👍 💯 🚀 💡 ✨
```

### 2. **reactions**
Emoji reactions for messages and feedback
```
👍 👎 ❤️ 😂 😮 😢 😡 🎉 🙏 👏
```

### 3. **status**
Status indicators and checkmarks
```
✅ ❌ ⚠️ ℹ️ 🔴 🟢 🟡 ⭐ 📌 🔔
```

### 4. **dev**
Developer and tech-related emojis
```
💻 🖥️ ⌨️ 🖱️ 💾 📁 🔧 🐛 🚀 ✨
```

### 5. **docs**
Documentation and writing emojis
```
📝 📄 📋 📚 📖 ✏️ 🖊️ 📌 💡 ⚠️
```

### 6. **weather**
Weather and nature emojis
```
☀️ ⛅ ☁️ 🌧️ ⛈️ 🌩️ ❄️ 🌈 🌙 ⭐
```

### Initialize Default Collections

If you skipped auto-initialization, you can manually create default collections:

```powershell
Initialize-EmojiCollections
```

---

## 🆕 Creating Collections

### Basic Creation

```powershell
# Create empty collection
New-EmojiCollection -Name "myemojis" -Description "My personal emoji set"
```

### Create and Populate

```powershell
# Create collection
New-EmojiCollection -Name "project-alpha" -Description "Project Alpha emojis"

# Add emojis
Add-EmojiToCollection -Name "project-alpha" -Emoji "🎯"
Add-EmojiToCollection -Name "project-alpha" -Emoji "📊"
Add-EmojiToCollection -Name "project-alpha" -Emoji "✅"
```

### Create from Search Results

```powershell
# Create collection from search
New-EmojiCollection -Name "hearts" -Description "All heart emojis"

# Add all hearts
Search-Emoji -Query "heart" | ForEach-Object {
    Add-EmojiToCollection -Name "hearts" -Emoji $_.emoji
}
```

### Collection Naming Rules

- **Valid characters**: Letters, numbers, hyphens, underscores
- **Case-sensitive**: "Favorites" and "favorites" are different
- **Unique names**: Cannot create duplicate collection names
- **No spaces**: Use hyphens or underscores instead

✅ Good: `project-alpha`, `my_emojis`, `work2024`  
❌ Bad: `my emojis`, `project@alpha`, `#work`

---

## 🔧 Managing Collections

### Add Emojis

```powershell
# Add single emoji
Add-EmojiToCollection -Name "favorites" -Emoji "🎨"

# Add multiple emojis
"🎨", "🖌️", "🎭" | ForEach-Object {
    Add-EmojiToCollection -Name "favorites" -Emoji $_
}

# Add from clipboard
$emoji = Get-Clipboard
Add-EmojiToCollection -Name "favorites" -Emoji $emoji
```

### Remove Emojis

```powershell
# Remove single emoji
Remove-EmojiFromCollection -Name "favorites" -Emoji "🎨"

# Remove multiple emojis
"🎨", "🖌️" | ForEach-Object {
    Remove-EmojiFromCollection -Name "favorites" -Emoji $_
}
```

### Delete Collections

```powershell
# Delete with confirmation
Remove-EmojiCollection -Name "old-project"

# Force delete without confirmation
Remove-EmojiCollection -Name "old-project" -Force
```

---

## 📖 Using Collections

### List All Collections

```powershell
# Show all collections
Get-EmojiCollection

# Output:
# Name        Description                  Count
# ----        -----------                  -----
# favorites   Most used emojis             10
# reactions   Emoji reactions              10
# status      Status indicators            10
# dev         Developer emojis             10
# docs        Documentation emojis         10
# weather     Weather emojis               10
```

### Get Collection Contents

```powershell
# View specific collection
Get-EmojiCollection "favorites"

# Output:
# Collection: favorites
# Description: Most used emojis
# Emojis: ❤️ ⭐ 🎉 ✅ 🔥 👍 💯 🚀 💡 ✨
```

### Use in Scripts

```powershell
# Get emojis from collection
$devEmojis = (Get-EmojiCollection "dev").emojis

# Use in output
Write-Host "$($devEmojis[0]) Starting build process..."

# Pick random emoji from collection
$collection = Get-EmojiCollection "reactions"
$randomEmoji = $collection.emojis | Get-Random
Write-Host "Random reaction: $randomEmoji"
```

### Filter Collections

```powershell
# Get collections with specific emoji
Get-EmojiCollection | Where-Object { $_.emojis -contains "🚀" }

# Get large collections
Get-EmojiCollection | Where-Object { $_.emojis.Count -gt 15 }

# Find collections by name pattern
Get-EmojiCollection | Where-Object { $_.name -like "project-*" }
```

---

## 💾 Import & Export

### Export Collections

```powershell
# Export single collection
Export-EmojiCollection -Name "favorites" -Path "my-favorites.json"

# Export all collections
Get-EmojiCollection | ForEach-Object {
    Export-EmojiCollection -Name $_.name -Path "$($_.name).json"
}

# Export to specific directory
Export-EmojiCollection -Name "dev" -Path "C:\Backups\dev-emojis.json"
```

### Import Collections

```powershell
# Import collection
Import-EmojiCollection -Path "my-favorites.json"

# Import with merge (adds to existing)
Import-EmojiCollection -Path "shared-emojis.json" -Merge

# Import multiple collections
Get-ChildItem "*.json" | ForEach-Object {
    Import-EmojiCollection -Path $_.FullName
}
```

### Share with Team

```powershell
# Export your collection
Export-EmojiCollection -Name "project-standards" -Path "team-emojis.json"

# Team members import it
Import-EmojiCollection -Path "team-emojis.json"

# Now everyone has the same collection!
Get-EmojiCollection "project-standards"
```

---

## 💡 Examples & Use Cases

### Use Case 1: Project-Specific Emojis

```powershell
# Create collection for project
New-EmojiCollection -Name "project-mars" -Description "Mars Mission Project"

# Add project-related emojis
$projectEmojis = @("🚀", "🌍", "🔴", "👨‍🚀", "🛰️", "⭐")
$projectEmojis | ForEach-Object {
    Add-EmojiToCollection -Name "project-mars" -Emoji $_
}

# Use in commit messages
$rocket = (Get-EmojiCollection "project-mars").emojis[0]
git commit -m "$rocket Launch new feature"
```

### Use Case 2: Documentation Standards

```powershell
# Create documentation emoji set
New-EmojiCollection -Name "doc-standards" -Description "Standard doc emojis"

# Define standard markers
$standards = @{
    "📝" = "Note"
    "⚠️" = "Warning"
    "💡" = "Tip"
    "✅" = "Success"
    "❌" = "Error"
    "🔍" = "Example"
}

# Add to collection
$standards.Keys | ForEach-Object {
    Add-EmojiToCollection -Name "doc-standards" -Emoji $_
}

# Export for team
Export-EmojiCollection -Name "doc-standards" -Path "docs\emoji-standards.json"
```

### Use Case 3: Status Updates

```powershell
# Create status collection
New-EmojiCollection -Name "status-updates" -Description "Daily standup emojis"

# Add status emojis
@("🟢", "🟡", "🔴", "✅", "🚧", "🔄", "⏸️", "🎯") | ForEach-Object {
    Add-EmojiToCollection -Name "status-updates" -Emoji $_
}

# Use in status messages
$status = Get-EmojiCollection "status-updates"
Write-Host "$($status.emojis[0]) All systems operational"
Write-Host "$($status.emojis[4]) Feature in progress"
```

### Use Case 4: Git Commit Convention

```powershell
# Conventional commits with emojis
New-EmojiCollection -Name "git-commits" -Description "Commit type emojis"

$commitTypes = @{
    "✨" = "feat: new feature"
    "🐛" = "fix: bug fix"
    "📝" = "docs: documentation"
    "💄" = "style: formatting"
    "♻️" = "refactor: code restructure"
    "⚡" = "perf: performance"
    "✅" = "test: testing"
    "🔧" = "chore: maintenance"
}

$commitTypes.Keys | ForEach-Object {
    Add-EmojiToCollection -Name "git-commits" -Emoji $_
}

# Use in commits
Get-EmojiCollection "git-commits"
# Pick emoji for commit type
git commit -m "✨ feat: Add user authentication"
```

### Use Case 5: Slack/Teams Reactions

```powershell
# Quick reaction set
New-EmojiCollection -Name "slack-reactions" -Description "Common Slack reactions"

# Add reaction emojis
@("👍", "👎", "🎉", "🙏", "🔥", "💯", "👀", "🚀") | ForEach-Object {
    Add-EmojiToCollection -Name "slack-reactions" -Emoji $_
}

# Quick copy for Slack
Get-EmojiCollection "slack-reactions" | Format-Table
# Copy and paste into Slack!
```

### Use Case 6: Presentation Sections

```powershell
# Create presentation markers
New-EmojiCollection -Name "presentation" -Description "Slide section markers"

$sections = @{
    "📊" = "Data/Charts"
    "💡" = "Ideas/Concepts"
    "✅" = "Achievements"
    "🎯" = "Goals/Objectives"
    "⚠️" = "Risks/Issues"
    "🚀" = "Launch/Action"
}

$sections.Keys | ForEach-Object {
    Add-EmojiToCollection -Name "presentation" -Emoji $_
}
```

---

## 🎨 Advanced Techniques

### Dynamic Collections

```powershell
# Create collection from category
New-EmojiCollection -Name "animals" -Description "All animal emojis"

Get-Emoji -Category "Animals & Nature" | ForEach-Object {
    Add-EmojiToCollection -Name "animals" -Emoji $_.emoji
}
```

### Conditional Adding

```powershell
# Add only if emoji exists in dataset
$emoji = "🦄"
if (Search-Emoji -Query "unicorn" -Exact) {
    Add-EmojiToCollection -Name "favorites" -Emoji $emoji
    Write-Host "Added $emoji to favorites"
}
```

### Collection Statistics

```powershell
# Get collection stats
Get-EmojiCollection | Select-Object Name, 
    @{Name="Size"; Expression={$_.emojis.Count}},
    @{Name="FirstEmoji"; Expression={$_.emojis[0]}},
    @{Name="LastEmoji"; Expression={$_.emojis[-1]}} |
    Format-Table -AutoSize
```

### Merge Collections

```powershell
# Merge two collections
$collection1 = Get-EmojiCollection "set1"
$collection2 = Get-EmojiCollection "set2"

New-EmojiCollection -Name "merged" -Description "Combined sets"

($collection1.emojis + $collection2.emojis) | Select-Object -Unique | ForEach-Object {
    Add-EmojiToCollection -Name "merged" -Emoji $_
}
```

---

## 🔍 Troubleshooting

### Issue: "Collection already exists"

**Problem:** Trying to create a collection with a name that already exists

**Solution:**
```powershell
# Check if collection exists first
if (-not (Get-EmojiCollection | Where-Object { $_.name -eq "myname" })) {
    New-EmojiCollection -Name "myname" -Description "My collection"
}

# Or delete the old one first
Remove-EmojiCollection -Name "myname" -Force
New-EmojiCollection -Name "myname" -Description "My collection"
```

### Issue: "Emoji already in collection"

**Problem:** Adding an emoji that's already in the collection

**Solution:**
```powershell
# Check before adding
$collection = Get-EmojiCollection "favorites"
$emoji = "🎉"
if ($collection.emojis -notcontains $emoji) {
    Add-EmojiToCollection -Name "favorites" -Emoji $emoji
}
```

### Issue: "Collection not found"

**Problem:** Trying to use a collection that doesn't exist

**Solution:**
```powershell
# List all collections
Get-EmojiCollection

# Create if missing
if (-not (Get-EmojiCollection | Where-Object { $_.name -eq "needed" })) {
    New-EmojiCollection -Name "needed" -Description "New collection"
}
```

### Issue: Collections not persisting

**Problem:** Collections disappear after closing PowerShell

**Solution:** Collections are automatically saved to `data/collections.json`. If not persisting:
```powershell
# Check if file exists
Test-Path "$HOME\Documents\PowerShell\EmojiTools\data\collections.json"

# Manually verify data directory
Get-ChildItem "$HOME\Documents\PowerShell\EmojiTools\data"

# Re-initialize if needed
Initialize-EmojiCollections -Force
```

---

## 📚 Related Documentation

- [QUICKSTART.md](QUICKSTART.md) - Getting started with EmojiTools
- [ALIASES_GUIDE.md](ALIASES_GUIDE.md) - Emoji shortcuts and aliases
- [ANALYTICS_GUIDE.md](ANALYTICS_GUIDE.md) - Usage statistics and tracking
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Module setup and configuration

---

## 🎯 Best Practices

### 1. **Use Descriptive Names**
```powershell
✅ Good: "project-phoenix-emojis"
❌ Bad: "pe" or "emojis1"
```

### 2. **Add Descriptions**
```powershell
✅ Good: New-EmojiCollection -Name "alerts" -Description "System alert emojis"
❌ Bad: New-EmojiCollection -Name "alerts"
```

### 3. **Keep Collections Focused**
```powershell
✅ Good: 5-15 related emojis per collection
❌ Bad: 100+ random emojis in one collection
```

### 4. **Export Important Collections**
```powershell
# Regular backups
Get-EmojiCollection | ForEach-Object {
    Export-EmojiCollection -Name $_.name -Path "backups\$($_.name).json"
}
```

### 5. **Version Control**
```powershell
# Keep collections in git
Export-EmojiCollection -Name "team-standards" -Path "docs\team-emojis.json"
git add docs\team-emojis.json
git commit -m "Update team emoji standards"
```

---

## 📝 Summary

Emoji collections help you:

✅ **Organize** emojis by theme, project, or purpose  
✅ **Access** frequently-used emojis quickly  
✅ **Share** emoji sets with your team  
✅ **Standardize** emoji usage across projects  
✅ **Customize** your emoji workflow  

**Quick Commands:**
```powershell
Get-EmojiCollection                              # List all
Get-EmojiCollection "name"                       # View collection
New-EmojiCollection -Name "x" -Description "y"   # Create
Add-EmojiToCollection -Name "x" -Emoji "🎉"      # Add
Remove-EmojiFromCollection -Name "x" -Emoji "🎉" # Remove
Export-EmojiCollection -Name "x" -Path "x.json"  # Export
Import-EmojiCollection -Path "x.json"            # Import
Remove-EmojiCollection -Name "x"                 # Delete
```

Happy collecting! 📁✨
