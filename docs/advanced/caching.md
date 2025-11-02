# ⚡ Caching System

EmojiTools uses intelligent caching to deliver lightning-fast search results. Understand how it works and how to manage it.

---

## How Caching Works

The caching system automatically stores search results and frequently accessed data to speed up subsequent operations:

- **First Search** - Builds cache (may take a moment)
- **Subsequent Searches** - Uses cache (10-100x faster!)
- **Auto-Refresh** - Cache updates when dataset changes

---

## Cache Management

### Clear Cache

```powershell
# Clear all cached data
Clear-EmojiCache

# Cache rebuilds automatically on next search
Search-Emoji "rocket"
```

### Check Cache Status

```powershell
# View cache information
Get-EmojiCacheStatus
```

Shows:
- Cache size
- Last updated
- Hit/miss ratio
- Cached items count

---

## Performance Impact

**Without Cache:**
```powershell
# First search (builds cache)
Measure-Command { Search-Emoji "heart" }
# ~200-500ms
```

**With Cache:**
```powershell
# Subsequent search (uses cache)
Measure-Command { Search-Emoji "heart" }
# ~10-50ms (10x faster!)
```

---

## When Cache Clears

Cache automatically clears when:
- Dataset is updated
- Custom dataset is loaded
- Module is reimported

---

## 📋 Reference

### `Clear-EmojiCache`

Clears all cached data. No parameters.

### `Get-EmojiCacheStatus`

Returns cache statistics and information. No parameters.

---

<div align="center" markdown>

**Related:** [Searching](../user-guide/searching.md) | [Commands Reference](../reference/commands.md)

</div>
