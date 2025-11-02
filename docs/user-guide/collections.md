# Collections

Collections are your personal emoji organizers! Group emojis by project, mood, topic—whatever makes sense for you. Think of them as playlists for emojis. 📁✨

---

## 🎯 Why Use Collections?

Collections help you:

- ✅ **Organize by project** - Keep project-specific emojis together
- ✅ **Quick access** - Find your frequently-used emojis instantly
- ✅ **Share** - Export collections to share with your team
- ✅ **Consistency** - Use the same emojis across similar documents

---

## 🆕 Create Your First Collection

Creating a collection is simple:

```powershell
# Create a collection
New-EmojiCollection -Name "DevOps" -Description "Emojis for DevOps tasks"
```

**Response:**
```
✓ Collection 'DevOps' created successfully!
```

### Add Emojis to Your Collection

```powershell
# Add individual emojis
Add-EmojiToCollection -Name "DevOps" -Emoji "🚀"
Add-EmojiToCollection -Name "DevOps" -Emoji "⚙️"

# Or add multiple at once
Add-EmojiToCollection -Name "DevOps" -Emoji "🚀", "⚙️", "🐛", "✅", "🔧"
```

---

## 📋 View Your Collections

### List All Collections

```powershell
Get-EmojiCollection
```

**Output:**
```
Name        Description              Emoji Count
----        -----------              -----------
DevOps      Emojis for DevOps tasks  5
Marketing   Marketing content emojis 8
Personal    My favorite emojis       12
```

### View a Specific Collection

```powershell
Get-EmojiCollection -Name "DevOps"
```

**Output:**
```
Name: DevOps
Description: Emojis for DevOps tasks
Created: 2025-11-02
Last Modified: 2025-11-02
Emoji Count: 5
Emojis: 🚀 ⚙️ 🐛 ✅ 🔧
```

---

## 🎨 Real-World Collection Ideas

### Project-Based Collections

```powershell
# Web development project
New-EmojiCollection -Name "WebDev" -Description "Web development project"
Add-EmojiToCollection -Name "WebDev" -Emoji "💻", "🌐", "🎨", "📱"

# Mobile app project
New-EmojiCollection -Name "MobileApp" -Description "iOS/Android app"
Add-EmojiToCollection -Name "MobileApp" -Emoji "📱", "🍎", "🤖", "⚡"

# Documentation project
New-EmojiCollection -Name "Docs" -Description "Documentation writing"
Add-EmojiToCollection -Name "Docs" -Emoji "📝", "📚", "✍️", "📖", "💡"
```

### Mood-Based Collections

```powershell
# Happy/Positive vibes
New-EmojiCollection -Name "Positive" -Description "Positive emotions"
Add-EmojiToCollection -Name "Positive" -Emoji "😀", "🎉", "❤️", "🌟", "👍"

# Work status indicators
New-EmojiCollection -Name "Status" -Description "Work status emojis"
Add-EmojiToCollection -Name "Status" -Emoji "✅", "⏳", "🔄", "⚠️", "❌"
```

### Industry-Specific Collections

```powershell
# Healthcare
New-EmojiCollection -Name "Healthcare" -Description "Medical industry"
Add-EmojiToCollection -Name "Healthcare" -Emoji "🏥", "💊", "⚕️", "🩺", "❤️"

# Education
New-EmojiCollection -Name "Education" -Description "Teaching and learning"
Add-EmojiToCollection -Name "Education" -Emoji "📚", "🎓", "✏️", "🧑‍🏫", "💡"

# Food & Restaurant
New-EmojiCollection -Name "Restaurant" -Description "Food service"
Add-EmojiToCollection -Name "Restaurant" -Emoji "🍕", "🍔", "☕", "🍰", "🥗"
```

---

## ✏️ Manage Your Collections

### Rename a Collection

```powershell
Rename-EmojiCollection -Name "DevOps" -NewName "CI/CD"
```

### Update Description

```powershell
Update-EmojiCollection -Name "CI/CD" -Description "Continuous Integration and Deployment emojis"
```

### Remove Emojis

```powershell
# Remove a single emoji
Remove-EmojiFromCollection -Name "CI/CD" -Emoji "🐛"

# Remove multiple emojis
Remove-EmojiFromCollection -Name "CI/CD" -Emoji "🐛", "🔧"
```

### Delete a Collection

```powershell
Remove-EmojiCollection -Name "OldProject"
```

---

## 🚀 Using Collections

### Copy All Emojis from a Collection

```powershell
# Get all emojis from a collection
$emojis = Get-EmojiCollection -Name "DevOps" | Select-Object -ExpandProperty Emojis

# Copy them as a string
$emojis -join ' ' | Set-Clipboard
# Now you have: 🚀 ⚙️ 🐛 ✅ 🔧 in your clipboard!
```

### Use in Scripts

```powershell
# Get emojis for notifications
$collection = Get-EmojiCollection -Name "Status"

# Use in your script
Write-Host "$($collection.Emojis[0]) Build started..."
Write-Host "$($collection.Emojis[3]) Tests passing!"
```

### Export a Collection

Export your collection to share with others or use in different formats:

```powershell
# Export to HTML (NEW in v1.15.0!)
Export-Emoji -Collection "DevOps" -Format HTML -OutputPath "devops-emojis.html"

# Export to JSON
Export-Emoji -Collection "Marketing" -Format JSON -OutputPath "marketing.json"

# Export to Markdown
Export-Emoji -Collection "Docs" -Format Markdown -OutputPath "doc-emojis.md"
```

[Learn more about exporting →](export.md)

---

## 🎬 Complete Workflow Example

Let's create a collection for a blog project from start to finish:

```powershell
# Step 1: Create the collection
New-EmojiCollection -Name "Blog" -Description "Blog post emojis"

# Step 2: Find and add relevant emojis
Search-Emoji "write" | Select-Object -First 1 |
    ForEach-Object { Add-EmojiToCollection -Name "Blog" -Emoji $_.emoji }

Search-Emoji "book" | Select-Object -First 1 |
    ForEach-Object { Add-EmojiToCollection -Name "Blog" -Emoji $_.emoji }

# Step 3: Add more manually
Add-EmojiToCollection -Name "Blog" -Emoji "💡", "🎯", "✨"

# Step 4: Review your collection
Get-EmojiCollection -Name "Blog"

# Step 5: Export for easy reference
Export-Emoji -Collection "Blog" -Format HTML -OutputPath "blog-emojis.html" -StyleTheme Colorful
```

---

## 📊 Collection Statistics

### See Your Most Used Collections

```powershell
# Get all collections with emoji counts
Get-EmojiCollection |
    Select-Object Name, EmojiCount |
    Sort-Object EmojiCount -Descending
```

### Find Overlapping Emojis

```powershell
# Which emojis appear in multiple collections?
$collection1 = Get-EmojiCollection -Name "DevOps"
$collection2 = Get-EmojiCollection -Name "Blog"

$overlap = $collection1.Emojis | Where-Object { $collection2.Emojis -contains $_ }
Write-Host "Shared emojis: $($overlap -join ' ')"
```

---

## 💡 Pro Tips

!!! tip "Start Small"
    Begin with 5-10 emojis per collection. You can always add more later!

!!! tip "Use Descriptive Names"
    Name collections based on their purpose: "GitCommits", "Slack-Reactions", "Email-Signatures"

!!! tip "Regular Cleanup"
    Review collections monthly and remove emojis you no longer use.

!!! tip "Theme Collections"
    Create seasonal collections: "Summer2025", "Holiday2025", "Spring-Vibes"

!!! example "Team Collections"
    Create shared collections for team use:
    ```powershell
    # Export for sharing
    Export-Emoji -Collection "TeamEmojis" -Format JSON -OutputPath "team-emojis.json"

    # Team members can import it
    Import-CustomDataset -Path "team-emojis.json" -DatasetName "Team"
    ```

---

## 🔄 Import/Export Collections

### Export a Collection

```powershell
# Export collection data
Export-EmojiCollection -Name "DevOps" -Path "devops-collection.json"
```

### Import a Collection

```powershell
# Import from file
Import-EmojiCollection -Path "devops-collection.json"
```

### Share with Team

```powershell
# Export all your collections
Get-EmojiCollection | ForEach-Object {
    Export-EmojiCollection -Name $_.Name -Path "$($_.Name).json"
}

# Zip them up
Compress-Archive -Path "*.json" -DestinationPath "my-emoji-collections.zip"
```

---

## 🎯 Advanced Collection Techniques

### Dynamic Collections with Scripts

```powershell
# Create a collection based on search results
$searchResults = Search-Emoji "tech"
$techEmojis = $searchResults | Select-Object -First 10 -ExpandProperty emoji

New-EmojiCollection -Name "TopTech" -Description "Top 10 tech emojis"
Add-EmojiToCollection -Name "TopTech" -Emoji $techEmojis
```

### Merge Collections

```powershell
# Combine two collections into a new one
$coll1 = Get-EmojiCollection -Name "Collection1"
$coll2 = Get-EmojiCollection -Name "Collection2"

New-EmojiCollection -Name "Combined" -Description "Merged collection"
Add-EmojiToCollection -Name "Combined" -Emoji ($coll1.Emojis + $coll2.Emojis | Sort-Object -Unique)
```

### Backup All Collections

```powershell
# Create backup
$backupPath = "EmojiCollections-Backup-$(Get-Date -Format 'yyyyMMdd').zip"
Get-EmojiCollection | ForEach-Object {
    Export-EmojiCollection -Name $_.Name -Path "$env:TEMP\$($_.Name).json"
}
Compress-Archive -Path "$env:TEMP\*.json" -DestinationPath $backupPath
Write-Host "✓ Backed up to: $backupPath"
```

---

## 🚀 Next Steps

<div class="grid cards" markdown>

-   :outbox_tray: **Export & Share**

    ---

    Export collections to HTML, JSON, and more

    [:octicons-arrow-right-24: Export Guide](export.md)

-   :bookmark: **Create Aliases**

    ---

    Quick shortcuts for your collections

    [:octicons-arrow-right-24: Alias Guide](aliases.md)

-   :chart_with_upwards_trend: **Track Usage**

    ---

    See which emojis you use most

    [:octicons-arrow-right-24: Analytics](../advanced/analytics.md)

</div>

---

Questions? Check the [Command Reference](../reference/commands.md) for all collection commands!
