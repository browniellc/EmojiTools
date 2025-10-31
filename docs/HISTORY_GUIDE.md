# 📜 Emoji History Tracking Guide

## 📋 Table of Contents

1. [Overview](#overview)
2. [Features](#-features)
3. [Quick Start](#-quick-start)
4. [Core Functions](#-core-functions)
   - [Get-EmojiUpdateHistory](#1-get-emojiupdatehistory)
   - [Get-NewEmojis](#2-get-newemojis)
   - [Get-RemovedEmojis](#3-get-removedemojis)
   - [Export-EmojiHistory](#4-export-emojihistory)
   - [Clear-EmojiHistory](#5-clear-emojihistory)
5. [Notifications](#-notifications-option-c)
6. [Use Cases](#-use-cases)
7. [Technical Details](#-technical-details)
8. [Best Practices](#-best-practices)
9. [FAQ](#-faq)
10. [Related Functions](#-related-functions)
11. [Examples](#-examples)
12. [Summary](#-summary)

---

## Overview

EmojiTools now includes **universal history tracking** that automatically records changes whenever you update your emoji dataset. Whether you're using Unicode CLDR, GitHub, custom datasets, or files, every change is tracked and queryable.

---

## 🎯 Features

- ✅ **Automatic Tracking** - Changes recorded on every `Update-EmojiDataset`
- ✅ **Universal Support** - Works with all data sources (Unicode, GitHub, Custom, File)
- ✅ **Detailed Diff** - Tracks added, removed, and modified emojis
- ✅ **Version Tracking** - Records source version when available (e.g., CLDR 45)
- ✅ **Smart Notifications** - Subtle alerts for new emojis (Option C)
- ✅ **Multiple Export Formats** - JSON, CSV, HTML, Markdown
- ✅ **Unlimited Storage** - No artificial limits (history uses ~5MB per 10 years)

---

## 🚀 Quick Start

### Automatic Tracking

History tracking is automatic! Just update your dataset:

```powershell
# Update from Unicode CLDR
Update-EmojiDataset -Source Unicode

# Output includes:
# ✅ Successfully updated emoji dataset from Unicode
# 📊 Dataset Changes:
#    +98 emojis added
#    ~5 emojis modified
#    💡 Run 'Get-NewEmojis' to see what's new!
```

### View Recent Changes

```powershell
# See what's new
Get-NewEmojis

# View full update history
Get-EmojiUpdateHistory

# Check dataset info (includes recent changes)
Get-EmojiDatasetInfo
```

---

## 📊 Core Functions

### 1. Get-EmojiUpdateHistory

View the complete history of dataset updates.

**Basic Usage:**
```powershell
# Show all updates
Get-EmojiUpdateHistory

# Show only the latest update
Get-EmojiUpdateHistory -Latest

# Show last 5 updates
Get-EmojiUpdateHistory -Last 5

# Show updates since a specific date
Get-EmojiUpdateHistory -Since "2025-01-01"

# Filter by source
Get-EmojiUpdateHistory -Source Unicode
```

**Example Output:**
```
📊 Emoji Update History
================================================================================

📅 2025-10-30 14:30 (0 days ago)
   Source: Unicode | Version: CLDR 46
   Total: 1,850 → 1,948 emojis
   ✅ Added: 98 emojis
   🔄 Modified: 5 emojis

📅 2025-09-15 10:00 (45 days ago)
   Source: Unicode | Version: CLDR 45
   Total: 1,800 → 1,850 emojis
   ✅ Added: 50 emojis
```

### 2. Get-NewEmojis

See emojis that were recently added.

**Basic Usage:**
```powershell
# Show emojis from latest update
Get-NewEmojis

# Show emojis from last 3 updates
Get-NewEmojis -Last 3

# Show all emojis added since January
Get-NewEmojis -Since "2025-01-01"

# Filter by category
Get-NewEmojis -Category "Smileys & Emotion"
```

**Example Output:**
```
✨ New Emojis (98 total)
================================================================================

📁 Smileys & Emotion
   🫨  shaking face (0 days ago)
   🫷  leftwards pushing hand (0 days ago)
   🫸  rightwards pushing hand (0 days ago)

📁 People & Body
   🫱  rightwards hand (0 days ago)
   🫲  leftwards hand (0 days ago)
```

### 3. Get-RemovedEmojis

See emojis that were removed (rare, but possible).

**Basic Usage:**
```powershell
# Show removed emojis from latest update
Get-RemovedEmojis

# Show removed emojis from last 3 updates
Get-RemovedEmojis -Last 3

# Show all removed since a date
Get-RemovedEmojis -Since "2025-01-01"
```

### 4. Export-EmojiHistory

Export history to various formats for sharing or archiving.

**JSON Export (Full Detail):**
```powershell
Export-EmojiHistory -Path "history.json"
# or
Export-EmojiHistory -Path "history.json" -Format JSON
```

**CSV Export (Summary Table):**
```powershell
Export-EmojiHistory -Path "history.csv" -Format CSV
```

**HTML Export (Pretty Report):**
```powershell
# Summary only
Export-EmojiHistory -Path "report.html" -Format HTML

# With full details of each emoji
Export-EmojiHistory -Path "report.html" -Format HTML -IncludeDetails
```

**Markdown Export (For Documentation):**
```powershell
# Summary
Export-EmojiHistory -Path "CHANGELOG.md" -Format Markdown

# Detailed changelog
Export-EmojiHistory -Path "CHANGELOG.md" -Format Markdown -IncludeDetails
```

**Example Markdown Output with `-IncludeDetails`:**
```markdown
# 📊 Emoji Update History

## 📅 2025-10-30 14:30

**Source:** Unicode | **Version:** CLDR 46
**Total:** 1,850 → 1,948 emojis

### Changes

- ✅ **Added:** 98 emojis
- 🔄 **Modified:** 5 emojis

#### ✅ Added Emojis

- 🫨 **shaking face** *(Smileys & Emotion)*
- 🫷 **leftwards pushing hand** *(People & Body)*
- 🫸 **rightwards pushing hand** *(People & Body)*
```

### 5. Clear-EmojiHistory

Manage or remove old history entries.

**Keep Only Recent:**
```powershell
# Keep only last 10 updates
Clear-EmojiHistory -KeepLast 10

# Keep only last 5 updates
Clear-EmojiHistory -KeepLast 5
```

**Remove Old Entries:**
```powershell
# Remove history before a specific date
Clear-EmojiHistory -Before "2024-01-01"
```

**Clear All (with confirmation):**
```powershell
# Will prompt for confirmation
Clear-EmojiHistory

# Skip confirmation
Clear-EmojiHistory -Force
```

---

## 🔔 Notifications (Option C)

### Module Load Notification

When you import the module, you'll see a subtle notification if new emojis were added in the last 7 days:

```powershell
Import-Module EmojiTools
# ℹ️  98 new emojis available in recent updates (Run Get-NewEmojis to see them)
```

**Disable Notifications:**
```powershell
$Global:EmojiToolsConfig.AutoUpdateCheck = $false
```

### Dataset Info Integration

`Get-EmojiDatasetInfo` now includes a "Recent Changes" section:

```powershell
Get-EmojiDatasetInfo
```

**Output:**
```
📊 Emoji Dataset Information
═══════════════════════════════════════
📁 Dataset File:
   Path: C:\...\emoji.csv
   Total Emojis: 1,948

📈 Recent Changes (Last 7 Days):
   📅 2025-10-30 (0 days ago) - Unicode
      +98 emojis added
      ~5 emojis modified
   Run 'Get-NewEmojis' to see details

💡 Recommendations:
   ✅ Dataset is current (less than 7 days old)
```

---

## 📚 Use Cases

### 1. Track Unicode Updates

Monitor what's new in each Unicode release:

```powershell
# Update to latest Unicode
Update-EmojiDataset -Source Unicode

# See what changed
Get-NewEmojis

# Export changelog for documentation
Export-EmojiHistory -Path "Unicode_CLDR_46_Changes.md" -Format Markdown -IncludeDetails
```

### 2. Custom Dataset Management

Track changes in your custom emoji datasets:

```powershell
# Import your custom dataset
Import-CustomEmojiDataset -Path "my-emojis.csv"

# Later, update it
Import-CustomEmojiDataset -Path "my-emojis-v2.csv"

# See what changed
Get-NewEmojis
Get-RemovedEmojis
```

### 3. Audit Trail

Maintain an audit trail of all dataset changes:

```powershell
# View complete history
Get-EmojiUpdateHistory

# Export for compliance/archiving
Export-EmojiHistory -Path "emoji-audit-trail.json" -Format JSON

# Create summary report
Export-EmojiHistory -Path "emoji-audit-trail.csv" -Format CSV
```

### 4. Share New Emoji Discoveries

Create shareable reports of new emojis:

```powershell
# Update from Unicode
Update-EmojiDataset -Source Unicode

# Export pretty HTML report
Export-EmojiHistory -Path "new-emojis.html" -Format HTML -IncludeDetails

# Share the HTML file with your team!
```

### 5. Monitor Multiple Sources

Track updates from different sources:

```powershell
# Update from Unicode
Update-EmojiDataset -Source Unicode

# Later, try GitHub
Update-EmojiDataset -Source GitHub

# Compare sources
Get-EmojiUpdateHistory -Source Unicode
Get-EmojiUpdateHistory -Source GitHub
```

---

## 🔧 Technical Details

### History File Structure

History is stored in `data/history.json`:

```json
{
  "updates": [
    {
      "date": "2025-10-30T14:30:00Z",
      "source": "Unicode",
      "version": "CLDR 46",
      "previousCount": 1850,
      "newCount": 1948,
      "added": [
        {
          "emoji": "🫨",
          "name": "shaking face",
          "category": "Smileys & Emotion"
        }
      ],
      "removed": [],
      "modified": [
        {
          "emoji": "😀",
          "oldName": "grinning face",
          "newName": "grinning face",
          "oldCategory": "Smileys",
          "newCategory": "Smileys & Emotion"
        }
      ]
    }
  ]
}
```

### Storage Requirements

**Per Update:** ~10 KB (varies by number of changes)
**Annual (weekly updates):** ~520 KB
**10 Years:** ~5 MB

Storage is negligible - no limits needed!

### Version Tracking

- **Unicode CLDR:** Extracts CLDR version (e.g., "CLDR 46")
- **GitHub:** Uses repository source info
- **Custom/File:** Uses file hash or timestamp

### Diff Algorithm

1. Load previous dataset (if exists)
2. Load new dataset
3. Compare by emoji character
4. Detect:
   - **Added:** Emoji exists in new but not in previous
   - **Removed:** Emoji exists in previous but not in new
   - **Modified:** Same emoji, different name or category

---

## 🎓 Best Practices

### 1. Regular Updates

Keep your dataset current:

```powershell
# Enable auto-update checks
$Global:EmojiToolsConfig.AutoUpdateCheck = $true

# Set update interval (days)
$Global:EmojiToolsConfig.UpdateInterval = 7

# Or use scheduled tasks
Enable-EmojiAutoUpdate -CreateScheduledTask
```

### 2. Review Changes

Always review changes after updating:

```powershell
# After updating
Update-EmojiDataset -Source Unicode

# Review what's new
Get-NewEmojis

# Check for unexpected removals
Get-RemovedEmojis
```

### 3. Export Regularly

Create backups and changelogs:

```powershell
# Monthly export
Export-EmojiHistory -Path "monthly-changelog-$(Get-Date -Format 'yyyy-MM').md" -Format Markdown -IncludeDetails

# Annual backup
Export-EmojiHistory -Path "annual-history-$(Get-Date -Format 'yyyy').json" -Format JSON
```

### 4. Clean Old History (Optional)

If you want to limit history size (though not necessary):

```powershell
# Keep only last 100 updates
Clear-EmojiHistory -KeepLast 100 -Force

# Or remove history older than 1 year
Clear-EmojiHistory -Before (Get-Date).AddYears(-1) -Force
```

---

## ❓ FAQ

### Q: Does history tracking slow down updates?

**A:** No. The diff calculation adds < 100ms to update time, even with 2,000+ emojis.

### Q: Can I disable history tracking?

**A:** History tracking is automatic and always on, but it's lightweight. If you really want to disable it, you can remove the `history.json` file, though it will be recreated on the next update.

### Q: What if I switch between sources?

**A:** Each update is tracked separately with its source. You can filter history by source using `-Source` parameter.

### Q: Can I manually edit history?

**A:** Yes, `history.json` is just JSON. But be careful - malformed JSON will prevent reading the history.

### Q: Will old updates affect performance?

**A:** No. Even with 1,000 update records (~10MB), queries are instant. History is only read when you explicitly query it.

### Q: Can I track changes in my own emoji collections?

**A:** History only tracks dataset updates via `Update-EmojiDataset` or `Import-CustomEmojiDataset`. Collection changes (add/remove emojis to/from collections) are not tracked in history, but you can use `Export-EmojiCollection` to version your collections.

---

## 🔗 Related Functions

- **`Update-EmojiDataset`** - Triggers history tracking
- **`Get-EmojiDatasetInfo`** - Shows recent changes
- **`Import-CustomEmojiDataset`** - Also triggers history tracking
- **`Get-EmojiUpdateHistory`** - View update history
- **`Get-NewEmojis`** - See new emojis
- **`Get-RemovedEmojis`** - See removed emojis
- **`Export-EmojiHistory`** - Export history
- **`Clear-EmojiHistory`** - Manage history

---

## 📝 Examples

### Example 1: Monthly Update Routine

```powershell
# 1. Update dataset
Update-EmojiDataset -Source Unicode

# 2. Review changes
Get-NewEmojis

# 3. Export changelog
$month = Get-Date -Format "yyyy-MM"
Export-EmojiHistory -Path "CHANGELOG-$month.md" -Format Markdown -IncludeDetails -Latest

# 4. Share with team
# Send CHANGELOG-$month.md via email or commit to repo
```

### Example 2: Compare Before/After

```powershell
# Before update
$before = $Global:EmojiData.Count

# Update
Update-EmojiDataset -Source Unicode

# After update
$after = $Global:EmojiData.Count

# Check what's new
Get-NewEmojis
Write-Host "Total change: $($after - $before) emojis"
```

### Example 3: Audit Report

```powershell
# Generate comprehensive audit report
Get-EmojiUpdateHistory | Export-Csv "audit-summary.csv"
Export-EmojiHistory -Path "audit-details.html" -Format HTML -IncludeDetails

# Open in browser
Invoke-Item "audit-details.html"
```

---

## ✅ Summary

Emoji history tracking in EmojiTools provides:

✅ **Automatic change detection** on every update
✅ **Detailed records** of added, removed, and modified emojis
✅ **Multiple export formats** for sharing and archiving
✅ **Subtle notifications** when new emojis are available
✅ **Universal support** for all data sources
✅ **Unlimited storage** (no artificial limits)

**Next Steps:**
- Run `Update-EmojiDataset` to start tracking
- Use `Get-NewEmojis` to see what's new
- Export history with `Export-EmojiHistory`

---

*Last Updated: October 30, 2025*
*Module Version: 1.12.0*
