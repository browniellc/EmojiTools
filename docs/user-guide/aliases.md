# 🔖 Emoji Aliases

Aliases are shortcuts that let you access your favorite emojis instantly without searching. Think of them as speed-dial for emojis!

---

## Quick Start

```powershell
# Create an alias
New-EmojiAlias -Alias "rocket" -Emoji "🚀"

# Use the alias
Get-EmojiAlias -Alias "rocket"
# Result: 🚀

# Copy to clipboard
Get-EmojiAlias -Alias "rocket" -Copy
```

---

## ✨ Why Use Aliases?

<div class="grid cards" markdown>

- **⚡ Lightning Fast** - No searching required, instant access
- **🧠 Memorable** - Use names you'll remember
- **⌨️ Keyboard Friendly** - Perfect for scripting and automation
- **🎯 Consistent** - Same alias works everywhere, every time

</div>

---

## 🎯 Common Scenarios

### Create Your First Aliases

Set up shortcuts for emojis you use all the time:

```powershell
# Status indicators
New-EmojiAlias -Alias "done" -Emoji "✅"
New-EmojiAlias -Alias "fail" -Emoji "❌"
New-EmojiAlias -Alias "warn" -Emoji "⚠️"

# Reactions
New-EmojiAlias -Alias "nice" -Emoji "👍"
New-EmojiAlias -Alias "fire" -Emoji "🔥"
New-EmojiAlias -Alias "party" -Emoji "🎉"
```

### Use Aliases

Retrieve emojis using your shortcuts:

```powershell
# Get the emoji
Get-EmojiAlias -Alias "fire"
# Result: 🔥

# Copy directly to clipboard
Get-EmojiAlias -Alias "done" -Copy
# Ready to paste!

# Use in strings
$status = Get-EmojiAlias -Alias "done"
Write-Host "$status Task completed!"
# Output: ✅ Task completed!
```

### List All Aliases

See all your defined shortcuts:

```powershell
Get-EmojiAlias -List
```

**Output:**
```
🔖 Available Emoji Aliases
============================================================
done            ✅  check mark button
fail            ❌  cross mark
fire            🔥  fire
nice            👍  thumbs up
party           🎉  party popper
warn            ⚠️  warning
```

---

## 🚀 Quick Setup with Defaults

Initialize a set of commonly used aliases instantly:

```powershell
# Create default aliases for common emojis
Initialize-DefaultEmojiAliases
```

This creates ~40 useful aliases including:

**Expressions:**
- `smile` → 😊
- `laugh` → 😂
- `wink` → 😉
- `heart` → ❤️
- `cool` → 😎

**Reactions:**
- `thumbsup` → 👍
- `thumbsdown` → 👎
- `ok` → 👌
- `clap` → 👏
- `fire` → 🔥

**Symbols:**
- `check` → ✅
- `x` → ❌
- `warning` → ⚠️
- `rocket` → 🚀
- `trophy` → 🏆

**Tech:**
- `computer` → 💻
- `phone` → 📱
- `bug` → 🐛
- `email` → 📧
- `folder` → 📁

---

## 🔧 Managing Aliases

### Update an Alias

Change what an alias points to:

```powershell
# Update existing alias
Set-EmojiAlias -Alias "rocket" -Emoji "🛸"

# Or use New-EmojiAlias with -Force
New-EmojiAlias -Alias "fire" -Emoji "🌶️" -Force
```

### Remove an Alias

Delete aliases you no longer need:

```powershell
# Remove with confirmation
Remove-EmojiAlias -Alias "oldname"

# Remove without confirmation
Remove-EmojiAlias -Alias "oldname" -Force
```

### Overwrite Defaults

Replace default aliases with your preferences:

```powershell
# Initialize defaults
Initialize-DefaultEmojiAliases

# Overwrite specific ones
Initialize-DefaultEmojiAliases -Force
```

---

## 💼 Real-World Workflows

### Git Commit Messages

Create aliases for semantic commit emojis:

```powershell
# Set up commit message aliases
New-EmojiAlias -Alias "feat" -Emoji "✨"
New-EmojiAlias -Alias "fix" -Emoji "🐛"
New-EmojiAlias -Alias "docs" -Emoji "📚"
New-EmojiAlias -Alias "style" -Emoji "💄"
New-EmojiAlias -Alias "refactor" -Emoji "♻️"
New-EmojiAlias -Alias "test" -Emoji "✅"
New-EmojiAlias -Alias "chore" -Emoji "🔧"

# Use in commits
$emoji = Get-EmojiAlias -Alias "feat"
git commit -m "$emoji Add new feature"
```

### Status Reports

Quick status indicators for team updates:

```powershell
# Create status aliases
New-EmojiAlias -Alias "inprogress" -Emoji "🔄"
New-EmojiAlias -Alias "blocked" -Emoji "🚫"
New-EmojiAlias -Alias "complete" -Emoji "✅"
New-EmojiAlias -Alias "urgent" -Emoji "🔥"

# Use in status updates
Get-EmojiAlias -Alias "complete" -Copy
# Paste: ✅ Migration completed
```

### Documentation

Create shortcuts for documentation emojis:

```powershell
# Documentation aliases
New-EmojiAlias -Alias "note" -Emoji "📝"
New-EmojiAlias -Alias "tip" -Emoji "💡"
New-EmojiAlias -Alias "caution" -Emoji "⚠️"
New-EmojiAlias -Alias "info" -Emoji "ℹ️"
New-EmojiAlias -Alias "example" -Emoji "📋"

# Use in markdown
Get-EmojiAlias -Alias "tip" -Copy
# Paste: 💡 **Pro Tip:** Always test first!
```

### Project-Specific Aliases

Different aliases for different projects:

```powershell
# Project A - Financial app
New-EmojiAlias -Alias "money" -Emoji "💰"
New-EmojiAlias -Alias "chart" -Emoji "📈"
New-EmojiAlias -Alias "alert" -Emoji "🚨"

# Project B - Gaming
New-EmojiAlias -Alias "win" -Emoji "🏆"
New-EmojiAlias -Alias "lose" -Emoji "💔"
New-EmojiAlias -Alias "player" -Emoji "🎮"
```

---

## 📋 Complete Parameter Reference

### `Get-EmojiAlias`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Alias` | String | No | The alias name to retrieve |
| `-List` | Switch | No | Show all available aliases |
| `-Copy` | Switch | No | Copy emoji to clipboard after retrieving |

**Pipeline Input:** Accepts alias names as strings

### `New-EmojiAlias`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Alias` | String | **Yes** | The alias name (letters, numbers, underscores only) |
| `-Emoji` | String | **Yes** | The emoji character to associate |
| `-Force` | Switch | No | Overwrite if alias already exists |

**Pipeline Input:** Accepts emoji characters

### `Set-EmojiAlias`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Alias` | String | **Yes** | The alias name to update |
| `-Emoji` | String | **Yes** | The new emoji character |

### `Remove-EmojiAlias`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Alias` | String | **Yes** | The alias name to remove |
| `-Force` | Switch | No | Skip confirmation prompt |

**Pipeline Input:** Accepts alias names as strings

### `Initialize-DefaultEmojiAliases`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Force` | Switch | No | Overwrite existing aliases with defaults |

---

## 💡 Pro Tips

!!! tip "Naming Convention"
    Use consistent naming for easier recall:
    ```powershell
    # Good: descriptive and memorable
    New-EmojiAlias -Alias "success" -Emoji "✅"
    New-EmojiAlias -Alias "error" -Emoji "❌"

    # Avoid: too short or cryptic
    New-EmojiAlias -Alias "s" -Emoji "✅"  # Hard to remember
    ```

!!! tip "Export and Share"
    Share aliases with your team by copying the aliases.json file:
    ```powershell
    # Export location
    $aliasPath = Join-Path $PSScriptRoot "..\data\aliases.json"

    # Copy to team share
    Copy-Item $aliasPath "\\teamshare\emojis\aliases.json"
    ```

!!! tip "Combine with Collections"
    Create aliases for your most-used collections:
    ```powershell
    # Get most used emoji from collection
    $topEmoji = (Get-EmojiCollection -Name "Favorites").emojis[0]
    New-EmojiAlias -Alias "fav1" -Emoji $topEmoji
    ```

!!! tip "Script Integration"
    Use aliases in automated scripts for consistent branding:
    ```powershell
    # Build script with branded emojis
    $start = Get-EmojiAlias -Alias "rocket"
    $done = Get-EmojiAlias -Alias "check"
    $fail = Get-EmojiAlias -Alias "x"

    Write-Host "$start Starting build..."
    # ... build process ...
    Write-Host "$done Build completed!"
    ```

---

## 🔗 Related Topics

- [Searching](searching.md) - Find emojis to create aliases for
- [Collections](collections.md) - Organize groups of aliased emojis
- [Export & Share](export.md) - Export your aliases with collections

---

## 🐛 Troubleshooting

### Alias Already Exists

**Problem:** "Alias already exists" error.

**Solution:** Use `-Force` to overwrite:
```powershell
New-EmojiAlias -Alias "fire" -Emoji "🔥" -Force
```

### Invalid Alias Name

**Problem:** "Alias name must contain only letters, numbers, and underscores."

**Solution:** Use alphanumeric characters and underscores only:
```powershell
# ❌ Invalid
New-EmojiAlias -Alias "my-emoji" -Emoji "🚀"
New-EmojiAlias -Alias "emoji!" -Emoji "🚀"

# ✅ Valid
New-EmojiAlias -Alias "my_emoji" -Emoji "🚀"
New-EmojiAlias -Alias "emoji1" -Emoji "🚀"
```

### Alias Not Found

**Problem:** "Alias not found" error.

**Solution:** List all aliases to see what's available:
```powershell
Get-EmojiAlias -List
```

### No Aliases Defined

**Problem:** "No aliases defined" error.

**Solution:** Initialize defaults or create your first alias:
```powershell
# Option 1: Use defaults
Initialize-DefaultEmojiAliases

# Option 2: Create manually
New-EmojiAlias -Alias "first" -Emoji "🎉"
```

---

<div align="center" markdown>

**Next Steps:** Explore [automation options](../automation/auto-updates.md) or learn about [collections](collections.md)

</div>
