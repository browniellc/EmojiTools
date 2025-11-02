# 📈 Analytics

Track and analyze your emoji usage patterns with built-in analytics features.

---

## Quick Start

```powershell
# View usage statistics
Get-EmojiStats

# Most used by category
Get-EmojiStats -ByCategory

# Export stats
Export-EmojiStats -OutputPath "stats.json"
```

---

## Features

<div class="grid cards" markdown>

- **📊 Usage Metrics** - Track which emojis you use most
- **📁 Category Breakdown** - See usage by category
- **📅 Time Analysis** - Usage trends over time
- **📤 Export** - Share stats with team

</div>

---

## Viewing Statistics

### Overall Stats

```powershell
# General statistics
Get-EmojiStats
```

Shows:
- Total emojis used
- Most used emoji
- Category distribution
- Usage frequency

### By Category

```powershell
# Category breakdown
Get-EmojiStats -ByCategory
```

### By Time Period

```powershell
# Last 30 days
Get-EmojiStats -Days 30

# Last week
Get-EmojiStats -Days 7
```

---

## Exporting Analytics

```powershell
# Export to JSON
Export-EmojiStats -OutputPath "emoji-stats.json"

# Export with date range
Export-EmojiStats -Days 30 -OutputPath "monthly-stats.json"
```

---

## 📋 Reference

### `Get-EmojiStats`

| Parameter | Description |
|-----------|-------------|
| `-ByCategory` | Group by emoji category |
| `-Days` | Filter to last N days |
| `-Limit` | Number of results |

### `Export-EmojiStats`

| Parameter | Description |
|-----------|-------------|
| `-OutputPath` | Export file path |
| `-Days` | Filter to last N days |
| `-Format` | Export format (JSON, CSV) |

---

<div align="center" markdown>

**Related:** [History Tracking](../automation/history.md) | [Collections](../user-guide/collections.md)

</div>
