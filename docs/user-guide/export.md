# 📤 Export & Share

Export your emoji collections, search results, or the entire dataset to various formats for documentation, web pages, sharing with teams, or archiving.

---

## Quick Start

```powershell
# Export all emojis to JSON
Export-Emoji -Format JSON -OutputPath "emojis.json"

# Export search results to HTML
Search-Emoji "heart" | Export-Emoji -Format HTML -OutputPath "hearts.html"

# Export a collection to Markdown
Export-Emoji -Format Markdown -Collection "Favorites" -OutputPath "my-favorites.md"
```

---

## ✨ Supported Formats

<div class="grid cards" markdown>

- **📄 JSON** - Structured data for applications and APIs
- **🌐 HTML** - Beautiful web pages with themes and styling
- **📝 Markdown** - Documentation-friendly format for GitHub, wikis
- **📊 CSV** - Spreadsheet-compatible for Excel, Google Sheets

</div>

---

## 🎯 Common Scenarios

### Export Search Results

Found the perfect emojis? Export them to share with your team:

```powershell
# Search and export to HTML
Search-Emoji "celebration" | Export-Emoji -Format HTML -OutputPath "party-emojis.html"

# Search and export to Markdown
Search-Emoji "developer" | Export-Emoji -Format Markdown -OutputPath "dev-emojis.md"
```

### Export Collections

Share your curated collections with teammates:

```powershell
# Export a collection to JSON
Export-Emoji -Format JSON -Collection "Work" -OutputPath "work-emojis.json"

# Export with colorful HTML theme
Export-Emoji -Format HTML -Collection "Favorites" -StyleTheme Colorful -OutputPath "favs.html"
```

### Export by Category

Extract emojis from specific categories:

```powershell
# Export all smiley emojis to CSV
Export-Emoji -Format CSV -Category "Smileys & Emotion" -OutputPath "smileys.csv"

# Export animals to Markdown with metadata
Export-Emoji -Format Markdown -Category "Animals & Nature" -IncludeMetadata -OutputPath "animals.md"
```

### Create Documentation

Build emoji references for your documentation:

```powershell
# Create an emoji cheat sheet
Export-Emoji -Format HTML -Title "Team Emoji Guide" -IncludeMetadata -OutputPath "emoji-guide.html"

# Export specific emojis for README
Search-Emoji "status" -Limit 10 | Export-Emoji -Format Markdown -Title "Status Indicators" -OutputPath "status-emojis.md"
```

---

## 🌐 HTML Exports

HTML exports create beautiful, self-contained web pages with styling and themes.

### Style Themes

Choose from three gorgeous themes to match your needs:

=== "Light Theme"
    ![HTML Export Light Theme](../assets/screenshots/export-html-light.png)

    ```powershell
    Export-Emoji -Format HTML -Category "Smileys & Emotion" -StyleTheme Light -OutputPath "smileys-light.html"
    ```

    Clean and professional - perfect for documentation and formal presentations.

=== "Dark Theme"
    ![HTML Export Dark Theme](../assets/screenshots/export-html-dark.png)

    ```powershell
    Export-Emoji -Format HTML -Collection "Favorites" -StyleTheme Dark -OutputPath "favs-dark.html"
    ```

    Easy on the eyes - great for presentations or personal use in low-light settings.

=== "Colorful Theme"
    ![HTML Export Colorful Theme](../assets/screenshots/export-html-colorful.png)

    ```powershell
    Export-Emoji -Format HTML -Query "party" -StyleTheme Colorful -OutputPath "party.html"
    ```

    Vibrant and fun - ideal for creative projects and engaging content.

#### Light Theme (Default)

```powershell
Export-Emoji -Format HTML -Category "Smileys & Emotion" -StyleTheme Light -OutputPath "smileys-light.html"
```

Clean and professional, perfect for documentation.

#### Dark Theme

```powershell
Export-Emoji -Format HTML -Collection "Favorites" -StyleTheme Dark -OutputPath "favs-dark.html"
```

Easy on the eyes, great for presentations or personal use.

#### Colorful Theme

```powershell
Export-Emoji -Format HTML -Query "party" -StyleTheme Colorful -OutputPath "party.html"
```

Vibrant and fun, ideal for creative projects.

### Custom Titles

```powershell
# Add a custom title to your HTML export
Export-Emoji -Format HTML -Collection "Work" -Title "Work Emojis - Q4 2024" -OutputPath "work-q4.html"
```

---

## 📝 Markdown Exports

Markdown exports are perfect for README files, GitHub wikis, and documentation sites.

### Basic Markdown Export

```powershell
# Export to Markdown with a table format
Export-Emoji -Format Markdown -Category "Symbols" -OutputPath "symbols.md"
```

**Output Example:**
```markdown
# Emoji Collection

| Emoji | Name | Category | Keywords |
|-------|------|----------|----------|
| ✅ | check mark button | Symbols | button, check, mark |
| ❌ | cross mark | Symbols | cancel, mark, multiplication, x |
```

### With Metadata

```powershell
# Include export date and count information
Export-Emoji -Format Markdown -Query "heart" -IncludeMetadata -OutputPath "hearts.md"
```

**Output Includes:**
- Export date and time
- Total emoji count
- Source information
- Filter criteria used

---

## 📊 JSON & CSV Exports

### JSON for Applications

Perfect for loading into web apps, APIs, or other tools:

```powershell
# Export to structured JSON
Export-Emoji -Format JSON -Collection "Developer" -OutputPath "dev-emojis.json"
```

**JSON Structure:**
```json
[
  {
    "emoji": "🚀",
    "name": "rocket",
    "category": "Travel & Places",
    "keywords": "launch, rocket, space"
  }
]
```

### CSV for Spreadsheets

Import into Excel, Google Sheets, or data analysis tools:

```powershell
# Export to CSV
Export-Emoji -Format CSV -Category "Food & Drink" -OutputPath "food.csv"
```

**CSV Structure:**
```csv
emoji,name,category,keywords
🍕,pizza,Food & Drink,"cheese, pizza, slice"
🍔,hamburger,Food & Drink,"burger, hamburger"
```

---

## 🔄 Pipeline Support

Export directly from search results or collections:

```powershell
# Search → Export
Search-Emoji "animal" | Export-Emoji -Format HTML -OutputPath "animals.html"

# Collection → Export
Get-EmojiCollection -Name "Favorites" | Export-Emoji -Format JSON -OutputPath "favorites.json"

# Multiple filters
Search-Emoji "heart" |
    Where-Object { $_.category -eq "Smileys & Emotion" } |
    Export-Emoji -Format Markdown -OutputPath "heart-emojis.md"
```

---

## 🎨 Filtering Before Export

### By Query

```powershell
# Export emojis matching a search query
Export-Emoji -Format HTML -Query "rocket" -OutputPath "rockets.html"
```

### By Category

```powershell
# Export specific category
Export-Emoji -Format Markdown -Category "Flags" -OutputPath "flags.md"
```

### With Limits

```powershell
# Export only first 20 results
Export-Emoji -Format HTML -Query "face" -Limit 20 -OutputPath "faces.html"
```

### Combination Filters

```powershell
# Combine multiple filters
Export-Emoji -Format HTML -Category "Smileys & Emotion" -Query "happy" -Limit 10 -Title "Happy Faces" -OutputPath "happy.html"
```

---

## 💾 PassThru Mode

Return exported content to the pipeline instead of writing to a file:

```powershell
# Get JSON string without creating a file
$json = Export-Emoji -Format JSON -Collection "Work" -PassThru

# Use in other commands
$json | Out-File "custom-path.json" -Encoding UTF8

# Send to clipboard
Export-Emoji -Format Markdown -Query "star" -PassThru | Set-Clipboard
```

---

## 📋 Complete Parameter Reference

### `Export-Emoji`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Format` | String | **Yes** | Export format: `JSON`, `HTML`, `Markdown`, `CSV` |
| `-OutputPath` | String | No | File path for export (defaults to current directory) |
| `-Collection` | String/Object | No | Export a specific collection by name or object |
| `-Category` | String | No | Filter by category before exporting |
| `-Query` | String | No | Search query to filter emojis |
| `-Limit` | Int | No | Maximum number of emojis to export |
| `-Title` | String | No | Custom title for HTML/Markdown (default: "Emoji Collection") |
| `-IncludeMetadata` | Switch | No | Add export date, count, and source info |
| `-StyleTheme` | String | No | HTML theme: `Light`, `Dark`, `Colorful` (default: Light) |
| `-PassThru` | Switch | No | Return content to pipeline instead of file |

**Pipeline Input:** Accepts emoji objects from `Search-Emoji`, `Get-EmojiCollection`, etc.

---

## 💡 Pro Tips

!!! tip "Combine with Collections"
    Create a collection first, then export it:
    ```powershell
    New-EmojiCollection -Name "StatusIcons" -Emojis @("✅","❌","⚠️","🔥")
    Export-Emoji -Format HTML -Collection "StatusIcons" -StyleTheme Dark
    ```

!!! tip "Quick Documentation"
    Use Markdown exports for instant emoji reference docs:
    ```powershell
    Export-Emoji -Format Markdown -Category "Symbols" -IncludeMetadata -OutputPath "EMOJIS.md"
    ```

!!! tip "Share with Team"
    Export to HTML with a colorful theme for team sharing:
    ```powershell
    Export-Emoji -Format HTML -Collection "TeamEmojis" -StyleTheme Colorful -Title "Our Team Emoji Guide" -IncludeMetadata
    ```

!!! tip "Backup Collections"
    Export your collections to JSON for backup:
    ```powershell
    Get-EmojiCollection | ForEach-Object {
        Export-Emoji -Format JSON -Collection $_.Name -OutputPath "backup-$($_.Name).json"
    }
    ```

---

## 🔗 Related Topics

- [Collections](collections.md) - Organize emojis before exporting
- [Searching](searching.md) - Find specific emojis to export
- [Aliases](aliases.md) - Quick access to exported favorites

---

## 🐛 Troubleshooting

### File Already Exists

**Problem:** Export fails because file exists.

**Solution:** PowerShell will prompt to overwrite. Use `-Force` in your script:
```powershell
Export-Emoji -Format JSON -OutputPath "emojis.json" | Out-File -Force
```

### Collection Not Found

**Problem:** "Collection not found" error.

**Solution:** List available collections:
```powershell
Get-EmojiCollection
Export-Emoji -Format HTML -Collection "ExactCollectionName"
```

### Empty Export

**Problem:** Export file is empty or has no emojis.

**Solution:** Check your filters:
```powershell
# Verify results before exporting
Search-Emoji "yourquery"
# Then export
Search-Emoji "yourquery" | Export-Emoji -Format HTML
```

---

<div align="center" markdown>

**Next Steps:** Learn about [emoji aliases](aliases.md) or explore [collections](collections.md)

</div>
