# 📚 Command Reference

Complete reference for all EmojiTools commands.

---

## Search & Discovery

### `Search-Emoji`

Search for emojis by name, keywords, or category.

```powershell
Search-Emoji "rocket"
Search-Emoji "heart" -Category "Smileys & Emotion"
Search-Emoji "animal" -Limit 10
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `Query` | String | Search term (required) |
| `-Category` | String | Filter by category |
| `-Limit` | Int | Max results to return |
| `-Exact` | Switch | Exact match only |

---

### `Get-Emoji`

Get emoji by exact name.

```powershell
Get-Emoji -Name "rocket"
Get-Emoji -Name "red heart"
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Name` | String | Exact emoji name (required) |

---

### `Show-EmojiPicker`

Open interactive emoji picker.

```powershell
Show-EmojiPicker
Show-EmojiPicker -Category "Smileys & Emotion" -Theme Dark
$emoji = Show-EmojiPicker -ReturnEmoji
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Category` | String | Pre-filter to category |
| `-Collection` | String | Show collection only |
| `-Theme` | String | Light, Dark, or Auto |
| `-ReturnEmoji` | Switch | Return emoji to pipeline |
| `-Port` | Int | HTTP server port |
| `-Standalone` | Switch | Open as standalone page |

---

## Collections

### `New-EmojiCollection`

Create a new emoji collection.

```powershell
New-EmojiCollection -Name "Favorites" -Emojis @("🚀","🔥","✅")
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Name` | String | Collection name (required) |
| `-Emojis` | Array | Emoji characters (required) |
| `-Description` | String | Collection description |
| `-Force` | Switch | Overwrite if exists |

---

### `Get-EmojiCollection`

Retrieve emoji collections.

```powershell
Get-EmojiCollection
Get-EmojiCollection -Name "Favorites"
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Name` | String | Specific collection name |

---

### `Add-EmojiToCollection`

Add emojis to existing collection.

```powershell
Add-EmojiToCollection -Name "Favorites" -Emoji "💡"
```

---

### `Remove-EmojiCollection`

Delete a collection.

```powershell
Remove-EmojiCollection -Name "OldCollection"
```

---

## Export & Import

### `Export-Emoji`

Export emojis to various formats.

```powershell
Export-Emoji -Format HTML -Collection "Favorites" -OutputPath "favs.html"
Export-Emoji -Format JSON -Query "heart" -OutputPath "hearts.json"
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Format` | String | JSON, HTML, Markdown, CSV (required) |
| `-OutputPath` | String | Output file path |
| `-Collection` | String/Object | Export collection |
| `-Category` | String | Filter by category |
| `-Query` | String | Search filter |
| `-Limit` | Int | Max emojis |
| `-Title` | String | Title for HTML/Markdown |
| `-IncludeMetadata` | Switch | Add metadata |
| `-StyleTheme` | String | HTML theme: Light, Dark, Colorful |
| `-PassThru` | Switch | Return to pipeline |

---

### `Copy-Emoji`

Copy emoji to clipboard.

```powershell
Copy-Emoji "🚀"
"❤️" | Copy-Emoji
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `Emoji` | String | Emoji character (pipeline supported) |

---

## Aliases

### `New-EmojiAlias`

Create emoji alias/shortcut.

```powershell
New-EmojiAlias -Alias "fire" -Emoji "🔥"
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Alias` | String | Alias name (required) |
| `-Emoji` | String | Emoji character (required) |
| `-Force` | Switch | Overwrite if exists |

---

### `Get-EmojiAlias`

Get emoji by alias.

```powershell
Get-EmojiAlias -Alias "fire"
Get-EmojiAlias -List
Get-EmojiAlias -Alias "rocket" -Copy
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Alias` | String | Alias name |
| `-List` | Switch | Show all aliases |
| `-Copy` | Switch | Copy to clipboard |

---

### `Initialize-DefaultEmojiAliases`

Create default alias set.

```powershell
Initialize-DefaultEmojiAliases
Initialize-DefaultEmojiAliases -Force
```

---

## Dataset Management

### `Update-EmojiDataset`

Update emoji dataset.

```powershell
Update-EmojiDataset -Source Unicode
Update-EmojiDataset -Source GitHub -Silent
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Source` | String | Unicode or GitHub |
| `-Silent` | Switch | Suppress output |
| `-Force` | Switch | Force update |

---

### `Get-EmojiDatasetInfo`

View dataset information.

```powershell
Get-EmojiDatasetInfo
```

No parameters. Returns comprehensive dataset info.

---

## Automation

### `Enable-EmojiAutoUpdate`

Enable automatic updates.

```powershell
Enable-EmojiAutoUpdate -Interval 7
Enable-EmojiAutoUpdate -Interval 14 -CreateScheduledTask
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Interval` | Int | Days between checks |
| `-CreateScheduledTask` | Switch | Create scheduled task |

---

### `Disable-EmojiAutoUpdate`

Disable automatic updates.

```powershell
Disable-EmojiAutoUpdate
Disable-EmojiAutoUpdate -RemoveScheduledTask
```

---

### `New-EmojiScheduledTask`

Create scheduled task.

```powershell
New-EmojiScheduledTask -Interval 7
```

---

### `Remove-EmojiScheduledTask`

Remove scheduled task.

```powershell
Remove-EmojiScheduledTask
```

---

## History & Analytics

### `Enable-EmojiHistoryTracking`

Enable usage tracking.

```powershell
Enable-EmojiHistoryTracking
```

---

### `Get-EmojiHistory`

View usage history.

```powershell
Get-EmojiHistory -Limit 20
Get-EmojiHistory -MostUsed -Limit 10
Get-EmojiHistory -Days 30
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Limit` | Int | Max entries |
| `-Days` | Int | Last N days |
| `-MostUsed` | Switch | Show most used |

---

### `Get-EmojiStats`

View usage statistics.

```powershell
Get-EmojiStats
Get-EmojiStats -ByCategory
Get-EmojiStats -Days 30
```

---

## Advanced

### `Register-EmojiSource`

Register custom data source.

```powershell
Register-EmojiSource -Name "MySource" -Url "https://api.com/emojis" -Type Json
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Name` | String | Source name (required) |
| `-Url` | String | Source URL |
| `-Path` | String | Local file path |
| `-Type` | String | Json or Csv |
| `-Force` | Switch | Overwrite if exists |

---

### `Get-EmojiSource`

List registered sources.

```powershell
Get-EmojiSource
Get-EmojiSource -Name "MySource"
```

---

## Skin Tones

### `Get-EmojiWithSkinTone`

Get emoji with skin tone variant.

```powershell
Get-EmojiWithSkinTone -Emoji "👍" -Tone Medium
Get-EmojiWithSkinTone -Emoji "👋" -Tone Dark
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Emoji` | String | Base emoji (required) |
| `-Tone` | String | Light, MediumLight, Medium, MediumDark, Dark |

---

### `Join-Emoji`

Join emojis with zero-width joiner.

```powershell
Join-Emoji -Emojis @("👨","💻")
```

---

## Utility

### `Initialize-EmojiTools`

Initialize module setup.

```powershell
Initialize-EmojiTools
```

---

### `Reset-EmojiTools`

Reset all data to defaults.

```powershell
Reset-EmojiTools -Confirm
```

---

### `Get-EmojiToolsInfo`

Display module information.

```powershell
Get-EmojiToolsInfo
```

---

### `Clear-EmojiCache`

Clear search cache.

```powershell
Clear-EmojiCache
```

---

<div align="center" markdown>

**See Also:** [Configuration](configuration.md) | [Troubleshooting](troubleshooting.md)

</div>
