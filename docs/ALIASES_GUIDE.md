# 🔖 EmojiTools Aliases Quick Reference

## 📋 Table of Contents

1. [What are Emoji Aliases?](#what-are-emoji-aliases)
2. [Quick Start](#quick-start)
3. [Default Aliases (70+ included)](#default-aliases-70-included)
4. [Managing Aliases](#managing-aliases)
5. [Sharing & Backup](#sharing--backup)
6. [Usage Examples](#usage-examples)
7. [Tips & Tricks](#tips--tricks)
8. [Alias Rules](#alias-rules)
9. [Common Patterns](#common-patterns)
10. [Storage](#storage)

---

## What are Emoji Aliases?

Aliases are shortcuts that let you quickly access emojis using memorable names instead of searching. Think of them as speed-dial for your favorite emojis!

## Quick Start

```powershell
# Initialize 70+ default aliases
Initialize-DefaultEmojiAliases

# View all aliases
Get-EmojiAlias -List

# Get an emoji by alias
Get-EmojiAlias -Alias "rocket"    # Returns 🚀

# Get and copy to clipboard
Get-EmojiAlias -Alias "fire" -Copy  # Copies 🔥
```

## Default Aliases (70+ included)

### 😊 Expressions
```
smile      😊    grin       😁    laugh      😂
wink       😉    heart      ❤️    love       😍
kiss       😘    cool       😎    thinking   🤔
shrug      🤷
```

### 👍 Reactions
```
thumbsup   👍    thumbsdown 👎    ok         👌
clap       👏    pray       🙏    muscle     💪
fire       🔥    boom       💥    star       ⭐
sparkles   ✨
```

### ✅ Symbols
```
check      ✅    x          ❌    warning    ⚠️
question   ❓    info       ℹ️    idea       💡
rocket     🚀    trophy     🏆    target     🎯
flag       🚩
```

### 💻 Tech & Work
```
computer   💻    laptop     💻    phone      📱
email      📧    folder     📁    file       📄
chart      📊    calendar   📅    clock      🕐
bug        🐛
```

### 🌤️ Nature
```
sun        ☀️    moon       🌙    cloud      ☁️
rain       🌧️    snow       ❄️    tree       🌲
flower     🌸    leaf       🍃
```

### 🍕 Food & Drink
```
pizza      🍕    burger     🍔    coffee     ☕
beer       🍺    cake       🎂    apple      🍎
```

### 🎮 Activities
```
game       🎮    music      🎵    movie      🎬
book       📚    party      🎉    gift       🎁
```

### 🚗 Transport
```
car        🚗    plane      ✈️    train      🚆
bike       🚲
```

### ⏰ Time
```
hourglass  ⏳    alarm      ⏰    timer      ⏱️
```

### 💰 Money
```
money      💰    dollar     💵    chart_up   📈
chart_down 📉
```

## Managing Aliases

### Create Custom Alias
```powershell
New-EmojiAlias -Alias "yes" -Emoji "✅"
New-EmojiAlias -Alias "no" -Emoji "❌"
New-EmojiAlias -Alias "tada" -Emoji "🎉"
```

### Update Existing Alias
```powershell
Set-EmojiAlias -Alias "fire" -Emoji "🔥"
```

### Remove Alias
```powershell
Remove-EmojiAlias -Alias "tada"
Remove-EmojiAlias -Alias "old_alias" -Force  # Skip confirmation
```

### List All Aliases
```powershell
Get-EmojiAlias -List
```

## Sharing & Backup

### Export Aliases
```powershell
# Backup your aliases
Export-EmojiAliases -Path "my-aliases.json"

# Share with team
Export-EmojiAliases -Path "team-emoji-shortcuts.json"
```

### Import Aliases
```powershell
# Replace all aliases
Import-EmojiAliases -Path "my-aliases.json"

# Merge with existing (keeps both, imported overwrites conflicts)
Import-EmojiAliases -Path "team-shortcuts.json" -Merge
```

## Usage Examples

### Quick Copy Workflow
```powershell
# Super fast emoji copying
Get-EmojiAlias -Alias "thumbsup" -Copy    # 👍 copied
Get-EmojiAlias -Alias "rocket" -Copy      # 🚀 copied
Get-EmojiAlias -Alias "fire" -Copy        # 🔥 copied
```

### View Details
```powershell
# See full emoji information
Get-EmojiAlias -Alias "rocket"

# Output:
# emoji name   category        keywords
# ----- ----   --------        --------
# 🚀    rocket Travel & Places launch, rocket, rockets, space, travel
```

### Create Personal Shortcuts
```powershell
# Create shortcuts for your most-used emojis
New-EmojiAlias -Alias "yay" -Emoji "🎉"
New-EmojiAlias -Alias "done" -Emoji "✅"
New-EmojiAlias -Alias "wip" -Emoji "🚧"
New-EmojiAlias -Alias "bug" -Emoji "🐛"
New-EmojiAlias -Alias "idea" -Emoji "💡"
```

### Team Standardization
```powershell
# Create team-wide emoji standards
New-EmojiAlias -Alias "approved" -Emoji "✅"
New-EmojiAlias -Alias "rejected" -Emoji "❌"
New-EmojiAlias -Alias "pending" -Emoji "⏳"
New-EmojiAlias -Alias "urgent" -Emoji "🚨"

# Export for team
Export-EmojiAliases -Path "team-standard.json"
```

## Tips & Tricks

1. **Use Descriptive Names**: Choose alias names that are easy to remember
   ```powershell
   New-EmojiAlias -Alias "celebrate" -Emoji "🎉"  # ✅ Clear
   New-EmojiAlias -Alias "cp" -Emoji "🎉"         # ❌ Not obvious
   ```

2. **Consistent Naming**: Use underscores for multi-word aliases
   ```powershell
   New-EmojiAlias -Alias "chart_up" -Emoji "📈"
   New-EmojiAlias -Alias "red_heart" -Emoji "❤️"
   ```

3. **Personal Favorites**: Create aliases for emojis you use daily
   ```powershell
   # Developer favorites
   New-EmojiAlias -Alias "pr" -Emoji "🔄"
   New-EmojiAlias -Alias "merge" -Emoji "🔀"
   New-EmojiAlias -Alias "deploy" -Emoji "🚀"
   ```

4. **Workflow Integration**: Combine with scripts
   ```powershell
   # Git commit emoji workflow
   function git-commit-fix {
       $emoji = Get-EmojiAlias -Alias "bug" | Select-Object -ExpandProperty emoji
       git commit -m "$emoji Fix: $args"
   }
   ```

5. **Backup Regularly**: Export aliases before making major changes
   ```powershell
   Export-EmojiAliases -Path "aliases-backup-$(Get-Date -Format 'yyyy-MM-dd').json"
   ```

## Alias Rules

- **Names**: Letters, numbers, and underscores only
- **Case-Insensitive**: "fire" and "FIRE" are the same
- **Unique**: Each alias points to one emoji
- **Overwrite Protection**: Use `-Force` to replace existing aliases

## Common Patterns

### Status Indicators
```powershell
New-EmojiAlias -Alias "online" -Emoji "🟢"
New-EmojiAlias -Alias "offline" -Emoji "🔴"
New-EmojiAlias -Alias "away" -Emoji "🟡"
```

### Priority Levels
```powershell
New-EmojiAlias -Alias "p0" -Emoji "🔴"
New-EmojiAlias -Alias "p1" -Emoji "🟠"
New-EmojiAlias -Alias "p2" -Emoji "🟡"
New-EmojiAlias -Alias "p3" -Emoji "🟢"
```

### Project Phases
```powershell
New-EmojiAlias -Alias "planning" -Emoji "📝"
New-EmojiAlias -Alias "development" -Emoji "⚙️"
New-EmojiAlias -Alias "testing" -Emoji "🧪"
New-EmojiAlias -Alias "deployed" -Emoji "🚀"
```

## Storage

Aliases are stored in: `data/aliases.json`

Format:
```json
{
  "fire": "🔥",
  "rocket": "🚀",
  "thumbsup": "👍"
}
```

---

**Version:** 1.8.0
**Last Updated:** October 30, 2025
**Total Default Aliases:** 71
