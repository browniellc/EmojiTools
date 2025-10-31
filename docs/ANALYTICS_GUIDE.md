# 📊 EmojiTools Analytics Guide

## 📋 Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [How It Works](#how-it-works)
4. [Use Cases](#use-cases)
5. [Privacy](#privacy)
6. [Tips](#tips)
7. [Examples](#examples)
8. [Troubleshooting](#troubleshooting)

---

## Overview

EmojiTools v1.7.0 includes comprehensive statistics and analytics tracking to help you understand your emoji usage patterns.

## Features

### 📈 What's Tracked

1. **Emoji Usage** - Every emoji you copy via `Copy-Emoji`
   - Which emojis you use most
   - When they were last used
   - Total usage count per emoji

2. **Search Queries** - Every search performed via `Search-Emoji`
   - What terms you search for
   - How many results each search returned
   - Search frequency

3. **Collection Usage** - Collection filter usage
   - Which collections you access
   - Access frequency

### 🔍 Viewing Statistics

#### Get-EmojiStats

View all your usage statistics:

```powershell
# View all statistics
Get-EmojiStats

# Show only usage stats
Get-EmojiStats -Type Usage

# Show only search queries
Get-EmojiStats -Type Search

# Show category distribution
Get-EmojiStats -Type Categories

# Show collection usage
Get-EmojiStats -Type Collections

# Show top 5 most used emojis
Get-EmojiStats -Type Usage -Top 5

# Filter stats from last week
Get-EmojiStats -Since (Get-Date).AddDays(-7)
```

**Output Example:**
```
📊 Emoji Statistics
============================================================

🏆 Most Used Emojis
   1. 🚀 - rocket (5 times)
   2. 🔥 - fire (3 times)
   3. ❤️ - red heart (2 times)

🔍 Popular Searches
   1. 'rocket' (3 times, avg 4.0 results)
   2. 'heart' (2 times, avg 35.0 results)

📈 Summary
  Total searches: 5
  Total emoji uses: 10
  Unique emojis used: 3
  Average uses per emoji: 3.3
```

### 💾 Exporting Statistics

#### Export-EmojiStats

Export your statistics to various formats:

```powershell
# Export to HTML report (recommended for sharing)
Export-EmojiStats -Path "my-stats.html" -Format HTML

# Export to JSON (for data analysis)
Export-EmojiStats -Path "my-stats.json" -Format JSON

# Export to CSV (for spreadsheets)
Export-EmojiStats -Path "my-stats.csv" -Format CSV
```

**HTML Report Features:**
- Professional styling with CSS
- Summary statistics dashboard
- Sortable tables
- Emoji rendering
- Timestamp tracking
- Ready to share or archive

### 🗑️ Clearing Statistics

#### Clear-EmojiStats

Remove statistics data selectively:

```powershell
# Clear only usage stats (with confirmation)
Clear-EmojiStats -Type Usage

# Clear only search stats (with confirmation)
Clear-EmojiStats -Type Search

# Clear collection stats (with confirmation)
Clear-EmojiStats -Type Collections

# Clear ALL statistics (with confirmation)
Clear-EmojiStats -Type All

# Skip confirmation prompt
Clear-EmojiStats -Type All -Force
```

**Safety Features:**
- Confirmation prompts (unless `-Force` is used)
- Selective clearing (keep what you want)
- Automatic backup before clearing (in `.bak` file)

## How It Works

### Automatic Tracking

Statistics are tracked automatically when you:

1. **Copy emojis** using `Copy-Emoji`:
   ```powershell
   Copy-Emoji -Query "rocket"  # Tracks: rocket search + 🚀 usage
   ```

2. **Search for emojis** using `Search-Emoji`:
   ```powershell
   Search-Emoji -Query "heart"  # Tracks: search query + result count
   ```

3. **Use collection filters**:
   ```powershell
   Search-Emoji -Query "bug" -Collection "Developer"  # Tracks collection usage
   ```

### Data Storage

- **Location**: `data/stats.json`
- **Format**: JSON with structured data
- **Encoding**: UTF-8
- **Automatic**: Created on first use

**Example stats.json:**
```json
{
  "emojiUsage": [
    {
      "emoji": "🚀",
      "name": "rocket",
      "category": "Travel & Places",
      "count": 5,
      "lastUsed": "2025-10-29 14:30:00"
    }
  ],
  "searches": [
    {
      "query": "rocket",
      "resultCount": 4,
      "timestamp": "2025-10-29 14:30:00"
    }
  ],
  "collectionUsage": {
    "Developer": 3,
    "MyFavorites": 1
  }
}
```

## Use Cases

### 📊 Personal Insights
- Track your most-used emojis
- Identify emoji usage patterns
- See what you search for most

### 📈 Team Analytics
- Export team emoji preferences
- Share usage reports
- Identify common needs for collections

### 📝 Documentation
- Include stats in reports
- Visualize emoji adoption
- Track changes over time

## Privacy

- **Local Only**: All statistics are stored locally in `data/stats.json`
- **No Telemetry**: Nothing is sent to external servers
- **User Controlled**: You can view, export, or delete stats at any time
- **Optional**: Statistics can be disabled by not using tracking functions

## Tips

1. **Regular Exports**: Export stats monthly for historical tracking
2. **HTML Reports**: Use HTML format for sharing with non-technical users
3. **Selective Clearing**: Clear old stats periodically to keep data fresh
4. **Top N**: Use `-Top` parameter to focus on most relevant data
5. **Date Filtering**: Use `-Since` to analyze recent behavior

## Examples

### Generate Monthly Report

```powershell
# Get stats from last 30 days
Get-EmojiStats -Since (Get-Date).AddDays(-30)

# Export to HTML
Export-EmojiStats -Path "monthly-report-$(Get-Date -Format 'yyyy-MM').html" -Format HTML
```

### Clean Old Data

```powershell
# Clear usage older than 90 days (manual filtering needed)
# Note: Current version doesn't support date-based clearing
# You can delete stats.json to start fresh
Clear-EmojiStats -Type All -Force
```

### Find Your Favorites

```powershell
# Show top 10 most used emojis
Get-EmojiStats -Type Usage -Top 10
```

## Troubleshooting

**Stats not tracking?**
- Ensure you're using `Copy-Emoji` and `Search-Emoji` (not direct clipboard copy)
- Check that `data/stats.json` exists and is writable
- Reimport the module: `Import-Module .\EmojiTools.psd1 -Force`

**Can't see stats?**
- Run `Get-EmojiStats` to view
- Check `data/stats.json` exists
- Verify you've performed some tracked actions

**Export failed?**
- Check write permissions for the output path
- Ensure path exists (parent directory must exist)
- Try a different file extension

---

**Version:** 1.7.0
**Last Updated:** October 29, 2025
