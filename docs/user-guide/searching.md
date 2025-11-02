# Searching for Emojis

The heart of EmojiTools is its powerful search engine. Whether you know exactly what you want or you're just browsing, you'll find the perfect emoji in seconds! 🔍

---

## 🎯 Basic Search

The simplest way to find emojis:

```powershell
Search-Emoji "rocket"
```

**Results:**
```
Emoji  Name              Category         Keywords
-----  ----              --------         --------
🚀     rocket           Travel & Places  launch, rocket, space
🧑‍🚀   astronaut        People & Body    astronaut, rocket, space
👨‍🚀   man astronaut    People & Body    astronaut, man, rocket
```

!!! tip "It's Fuzzy!"
    Search uses fuzzy matching, so typos and partial matches still work:
    ```powershell
    Search-Emoji "roket"   # Still finds 🚀!
    Search-Emoji "rok"     # Yep, still works!
    ```

---

## 🔎 What Gets Searched?

When you search, EmojiTools looks through:

1. **Emoji Names** - The official Unicode name
2. **Keywords** - Tags associated with the emoji
3. **Descriptions** - Alternative descriptions
4. **Categories** - The emoji's category

### Example: The Magic of Keywords

```powershell
Search-Emoji "launch"
# Finds: 🚀 (keyword: "launch")

Search-Emoji "blast off"
# Finds: 🚀 (similar keywords)

Search-Emoji "space"
# Finds: 🚀 🛸 🌌 (all space-related)
```

---

## 🎨 Search by Feeling or Concept

### Emotions

```powershell
Search-Emoji "happy"      # 😀 😊 😁 🥳
Search-Emoji "sad"        # 😢 😭 😔
Search-Emoji "love"       # ❤️ 💕 💖 😍
Search-Emoji "angry"      # 😠 😡 🤬
Search-Emoji "excited"    # 🎉 🥳 😆
```

### Activities

```powershell
Search-Emoji "celebrate"  # 🎉 🎊 🥳 🍾
Search-Emoji "work"       # 💼 💻 🏢
Search-Emoji "relax"      # 😌 🧘 🛀
Search-Emoji "exercise"   # 🏋️ 🏃 🚴
```

### Objects & Things

```powershell
Search-Emoji "tech"       # 💻 📱 ⌨️
Search-Emoji "food"       # 🍕 🍔 🍟
Search-Emoji "drink"      # ☕ 🍺 🥤
Search-Emoji "transport"  # 🚗 ✈️ 🚂
```

---

## 🎯 Advanced Search Techniques

### Filter by Category

Narrow your search to specific categories:

```powershell
# Method 1: Use Get-Emoji with category filter
Get-Emoji -Category "Smileys & Emotion" | Where-Object { $_.description -like "*smile*" }

# Method 2: Search then filter
Search-Emoji "smile" | Where-Object category -eq "Smileys & Emotion"
```

### Limit Results

Don't want to see all 50 matches? Limit the output:

```powershell
# Get first 5 results
Search-Emoji "heart" | Select-Object -First 5

# Get exactly 10
Search-Emoji "animal" | Select-Object -First 10
```

### Random Selection

Need inspiration? Get random emojis:

```powershell
# Random emoji from search
Search-Emoji "food" | Get-Random

# 5 random emojis
Search-Emoji "nature" | Get-Random -Count 5
```

---

## 🔍 Search Patterns & Examples

### Multi-Word Concepts

```powershell
Search-Emoji "thumbs up"     # 👍
Search-Emoji "party hat"     # 🎉
Search-Emoji "red heart"     # ❤️
Search-Emoji "waving hand"   # 👋
```

### By Purpose

```powershell
# For notifications
Search-Emoji "bell"          # 🔔
Search-Emoji "alert"         # ⚠️
Search-Emoji "warning"       # ⚠️

# For status indicators
Search-Emoji "check"         # ✅
Search-Emoji "cross"         # ❌
Search-Emoji "question"      # ❓

# For weather
Search-Emoji "sun"           # ☀️
Search-Emoji "rain"          # 🌧️
Search-Emoji "cloud"         # ☁️
Search-Emoji "lightning"     # ⚡
```

### By Industry/Field

```powershell
# Development
Search-Emoji "bug"           # 🐛
Search-Emoji "gear"          # ⚙️
Search-Emoji "tools"         # 🔧

# Medical
Search-Emoji "medical"       # 🏥 💊
Search-Emoji "health"        # ⚕️ 🩺

# Finance
Search-Emoji "money"         # 💰 💵
Search-Emoji "chart"         # 📊 📈
```

---

## 🎬 Real-World Search Scenarios

### Scenario 1: Writing Documentation

You're creating a README and need icons for sections:

```powershell
# Features section
Search-Emoji "sparkle"       # ✨ Features

# Getting started
Search-Emoji "rocket"        # 🚀 Quick Start

# Installation
Search-Emoji "package"       # 📦 Installation

# Contributing
Search-Emoji "handshake"     # 🤝 Contributing
```

### Scenario 2: Git Commit Messages

Following the [gitmoji](https://gitmoji.dev/) convention:

```powershell
Search-Emoji "sparkle"       # ✨ New feature
Search-Emoji "bug"           # 🐛 Bug fix
Search-Emoji "book"          # 📚 Documentation
Search-Emoji "lipstick"      # 💄 UI/Style
Search-Emoji "rocket"        # 🚀 Performance
Search-Emoji "lock"          # 🔒 Security
```

### Scenario 3: Team Communication

Quick reactions and responses:

```powershell
Search-Emoji "thumbs up"     # 👍 Approved!
Search-Emoji "eyes"          # 👀 Reviewing
Search-Emoji "tada"          # 🎉 Completed!
Search-Emoji "thinking"      # 🤔 Considering
Search-Emoji "muscle"        # 💪 On it!
```

---

## 🧪 Combining Search with PowerShell

### Pipeline Power

```powershell
# Find and count
(Search-Emoji "face").Count

# Find and export
Search-Emoji "heart" | Export-Csv hearts.csv

# Find and filter
Search-Emoji "animal" |
    Where-Object category -eq "Animals & Nature" |
    Select-Object emoji, description
```

### Create Custom Functions

```powershell
# Quick emoji finder function
function Find-Emoji($keyword) {
    $result = Search-Emoji $keyword | Select-Object -First 1
    Copy-Emoji $result.emoji
    Write-Host "✓ Copied $($result.emoji) ($($result.description))"
}

# Use it:
Find-Emoji "rocket"  # Finds and copies 🚀
```

---

## 💡 Search Tips & Tricks

!!! tip "Tip #1: Think About Context"
    Instead of searching for the exact emoji name, think about what it represents:
    ```powershell
    # Instead of searching "confetti ball"
    Search-Emoji "celebrate"   # Finds 🎊 and more!
    ```

!!! tip "Tip #2: Use Synonyms"
    Try different words that mean the same thing:
    ```powershell
    Search-Emoji "happy"       # 😀 😊 😁
    Search-Emoji "joyful"      # Same results!
    Search-Emoji "glad"        # Also works!
    ```

!!! tip "Tip #3: Browse Categories First"
    Not sure what to search for? Browse categories:
    ```powershell
    Get-Emoji -Category "Symbols" | Select-Object -First 20
    ```

!!! tip "Tip #4: Use Wildcards in Filters"
    ```powershell
    Get-Emoji | Where-Object description -like "*music*"
    ```

---

## 🎭 Emoji Skin Tones

Some emojis support skin tone modifiers. Get different variations:

```powershell
# Get default thumbs up
Search-Emoji "thumbs up"     # 👍

# Get with specific skin tone
Get-EmojiWithSkinTone -Emoji "👍" -SkinTone Light
Get-EmojiWithSkinTone -Emoji "👍" -SkinTone Dark
```

**Available skin tones:**

- Light
- MediumLight
- Medium
- MediumDark
- Dark

[Learn more about skin tones →](../reference/commands.md#get-emojiwithskintone)

---

## 📊 See What's Available

### Count Emojis by Category

```powershell
Get-Emoji |
    Group-Object category |
    Select-Object Name, Count |
    Sort-Object Count -Descending
```

### Find All Keywords

```powershell
# What keywords are used most?
Get-Emoji |
    ForEach-Object { $_.keywords -split ',' } |
    Group-Object |
    Sort-Object Count -Descending |
    Select-Object -First 20
```

---

## ⚡ Performance Tips

Searching is already fast, but here's how to make it even faster:

### Use Caching

EmojiTools automatically caches search results:

```powershell
# First search: loads from CSV
Search-Emoji "rocket"  # ~50ms

# Second search: uses cache
Search-Emoji "rocket"  # ~5ms (10x faster!)
```

[Learn about caching →](../advanced/caching.md)

### Limit Results Early

```powershell
# Instead of this:
$results = Search-Emoji "face"
$topResults = $results | Select-Object -First 10

# Do this:
$results = Search-Emoji "face" | Select-Object -First 10
```

---

## 🚀 Next Steps

Now that you're a search expert, explore these related features:

<div class="grid cards" markdown>

-   :art: **Emoji Picker**

    ---

    Use visual search with the browser picker

    [:octicons-arrow-right-24: Open Picker](picker.md)

-   :file_folder: **Collections**

    ---

    Save your favorite searches

    [:octicons-arrow-right-24: Create Collections](collections.md)

-   :bookmark: **Aliases**

    ---

    Create shortcuts for frequent searches

    [:octicons-arrow-right-24: Set Up Aliases](aliases.md)

</div>

---

Need more help? Check the [Command Reference](../reference/commands.md) for all search-related commands!
