# 📊 History Tracking

Track your emoji usage over time and see how your emoji habits evolve. Perfect for understanding patterns and discovering your most-used emojis!

---

## Quick Start

```powershell
# Enable history tracking
Enable-EmojiHistoryTracking

# View your history
Get-EmojiHistory

# See your most used emojis
Get-EmojiHistory -MostUsed -Limit 10
```

---

## ✨ What Gets Tracked

- **Copy Events** - When you copy emojis to clipboard
- **Search Queries** - What you search for
- **Timestamp** - When each action occurred
- **Context** - Which command was used

---

## 🎯 Common Uses

### View Recent History

```powershell
# Last 20 emojis used
Get-EmojiHistory -Limit 20

# Emojis from last 7 days
Get-EmojiHistory -Days 7
```

### Most Used Emojis

```powershell
# Top 10 most used
Get-EmojiHistory -MostUsed -Limit 10

# Top 5 this month
Get-EmojiHistory -MostUsed -Days 30 -Limit 5
```

### Export History

```powershell
# Export to JSON
Export-EmojiHistory -OutputPath "my-emoji-history.json"

# Export to CSV for analysis
Export-EmojiHistory -Format CSV -OutputPath "usage.csv"
```

### Clear History

```powershell
# Clear all history
Clear-EmojiHistory

# Clear with confirmation
Clear-EmojiHistory -Confirm
```

---

## 📋 Complete Commands

### `Enable-EmojiHistoryTracking`

Enables automatic tracking of emoji usage.

### `Disable-EmojiHistoryTracking`

Disables tracking (keeps existing history).

### `Get-EmojiHistory`

| Parameter | Description |
|-----------|-------------|
| `-Limit` | Number of entries to return |
| `-Days` | Filter to last N days |
| `-MostUsed` | Show most frequently used |

### `Export-EmojiHistory`

| Parameter | Description |
|-----------|-------------|
| `-OutputPath` | File path for export |
| `-Format` | Export format (JSON or CSV) |

### `Clear-EmojiHistory`

Removes all history entries (use with caution).

---

<div align="center" markdown>

**Related:** [Auto-Updates](auto-updates.md) | [Scheduled Tasks](scheduled-tasks.md)

</div>
