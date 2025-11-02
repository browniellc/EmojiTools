# Your First Steps with EmojiTools

Now that you've installed EmojiTools, let's make sure everything is working and get you familiar with the basics!

---

## ✅ Verify Your Installation

Let's confirm EmojiTools is ready to use:

```powershell
# Import the module
Import-Module EmojiTools

# Check it loaded successfully
Get-Module EmojiTools
```

**You should see:**
```
ModuleType Version    Name         ExportedCommands
---------- -------    ----         ----------------
Script     1.15.0     EmojiTools   {Search-Emoji, Get-Emoji, Copy-Emoji...}
```

!!! success "Module Loaded!"
    If you see this output, you're all set! If not, revisit the [Installation Guide](installation.md).

---

## 🎯 Understanding the Basics

### What is an Emoji Dataset?

EmojiTools uses a local database of emojis (called a "dataset") that includes:

- ✅ Every emoji character (🚀, ❤️, 🎉, etc.)
- ✅ Official Unicode names
- ✅ Categories (Smileys, Animals, Travel, etc.)
- ✅ Searchable keywords and tags
- ✅ Aliases for quick access

### Where Do Emojis Come From?

The emojis come from the **Unicode CLDR** (Common Locale Data Repository)—the official source for emoji data used by all major platforms!

---

## 📥 Download Your First Dataset

Before you can search emojis, you need to download the dataset:

```powershell
Update-EmojiDataset -Source Unicode
```

**What happens:**

1. ⬇️ Downloads latest Unicode CLDR emoji data
2. 📦 Extracts 1,900+ emojis with full metadata
3. 💾 Saves to your local EmojiTools data directory
4. ✅ Ready to use instantly!

!!! tip "Only Need to Do This Once"
    The dataset is saved locally, so you don't need to download it every time. Enable [auto-updates](../automation/auto-updates.md) to keep it current automatically!

---

## 🔍 Your First Search

Now let's find some emojis! Try searching for something fun:

```powershell
Search-Emoji "happy"
```

**What you'll see:**

```
Emoji  Name                         Category          Keywords
-----  ----                         --------          --------
😊     smiling face with eyes      Smileys & Emotion  blush, eye, happy, smile
😀     grinning face               Smileys & Emotion  face, grin, happy
😃     grinning face with big eyes Smileys & Emotion  face, grinning, happy
😁     beaming face with eyes      Smileys & Emotion  beaming, eye, happy
```

### Understanding the Results

Each result shows:

- **Emoji**: The actual character you can copy
- **Name**: Official Unicode name
- **Category**: Which category it belongs to
- **Keywords**: Searchable terms that match

---

## 📋 Browsing vs Searching

### Search When You Know What You Want

```powershell
Search-Emoji "rocket"   # Find 🚀
Search-Emoji "heart"    # Find ❤️ 💙 💚
Search-Emoji "food"     # Find 🍕 🍔 🍟
```

### Browse When You're Exploring

```powershell
# See all available categories
Get-Emoji | Group-Object category | Select-Object Name, Count | Sort-Object Count -Descending

# Browse a specific category
Get-Emoji -Category "Animals & Nature"

# Get a random emoji for inspiration
Get-Emoji | Get-Random
```

---

## 💾 Copy to Clipboard

Found the perfect emoji? Copy it with one command:

```powershell
Copy-Emoji "🎉"
```

**Result:**
```
✓ Copied 🎉 to clipboard
```

Now press `Ctrl+V` (or `Cmd+V` on Mac) to paste it anywhere!

### Copy from Search Results

```powershell
# Find and copy in one go
$emoji = Search-Emoji "party" | Select-Object -First 1
Copy-Emoji $emoji.emoji
```

---

## 📊 Check Your Dataset Info

Curious about your emoji dataset? Get the full details:

```powershell
Get-EmojiDatasetInfo
```

**Example output:**

```
📊 Emoji Dataset Information
════════════════════════════

📁 Dataset File:
   Path: C:\Users\...\EmojiTools\src\data\emoji.csv
   Size: 158.83 KB
   Last Modified: 2025-11-02 10:30:00
   Age: 0 days old

📦 Dataset Content:
   Total Emojis: 1948

📂 Categories:
   • People & Body: 325 emojis
   • Objects: 264 emojis
   • Travel & Places: 218 emojis
   ...and 7 more categories

🔖 Metadata:
   Source: Unicode CLDR
   Version: CLDR 45
   Last Update: 11/02/2025
```

---

## 🎨 Explore Categories

Emojis are organized into helpful categories. Here are all of them:

| Category | Examples | Count |
|----------|----------|-------|
| Smileys & Emotion | 😀 😍 😂 | 169 |
| People & Body | 👋 👍 💪 | 325 |
| Animals & Nature | 🐶 🐱 🌺 | 150 |
| Food & Drink | 🍕 🍔 ☕ | 134 |
| Travel & Places | ✈️ 🚗 🏠 | 218 |
| Activities | ⚽ 🎮 🎸 | 89 |
| Objects | 💻 📱 🎁 | 264 |
| Symbols | ❤️ ⭐ ✅ | 211 |
| Flags | 🇺🇸 🇬🇧 🇯🇵 | 270 |
| Component | 👍🏻 👍🏽 👍🏿 | 118 |

### Browse a Category

```powershell
# Get all animal emojis
Get-Emoji -Category "Animals & Nature" | Select-Object -First 20
```

---

## 🎯 Practical Examples to Try

### Example 1: Find Status Emojis

```powershell
# Find emojis for task status
Search-Emoji "check"     # ✅ Done
Search-Emoji "warning"   # ⚠️ Warning
Search-Emoji "error"     # ❌ Error
Search-Emoji "working"   # ⚙️ In Progress
```

### Example 2: Weather Emojis

```powershell
Search-Emoji "sun"       # ☀️
Search-Emoji "cloud"     # ☁️
Search-Emoji "rain"      # 🌧️
Search-Emoji "snow"      # ❄️
```

### Example 3: Tech & Development

```powershell
Search-Emoji "computer"  # 💻
Search-Emoji "bug"       # 🐛
Search-Emoji "rocket"    # 🚀
Search-Emoji "gear"      # ⚙️
```

---

## 🔄 Module Auto-Loading

Want EmojiTools to load automatically every time you open PowerShell?

### Add to Your Profile

```powershell
# Edit your PowerShell profile
notepad $PROFILE

# Add this line and save:
Import-Module EmojiTools
```

Now EmojiTools is ready whenever you open PowerShell! 🎉

---

## 🚀 Ready for More?

You've got the basics down! Here's where to go next:

<div class="grid cards" markdown>

-   :mag_right: **Advanced Search**

    ---

    Master fuzzy search, filters, and search tricks

    [:octicons-arrow-right-24: Search Guide](../user-guide/searching.md)

-   :art: **Visual Emoji Picker**

    ---

    Use the beautiful browser-based picker

    [:octicons-arrow-right-24: Picker Guide](../user-guide/picker.md)

-   :file_folder: **Collections**

    ---

    Organize emojis into custom groups

    [:octicons-arrow-right-24: Collections](../user-guide/collections.md)

-   :robot: **Automation**

    ---

    Set up auto-updates and scheduled tasks

    [:octicons-arrow-right-24: Auto-Updates](../automation/auto-updates.md)

</div>

---

## 💡 Pro Tips

!!! tip "Combine with PowerShell"
    EmojiTools works great with PowerShell pipelines:
    ```powershell
    Search-Emoji "animal" | Where-Object category -eq "Animals & Nature" | Get-Random -Count 5
    ```

!!! tip "Use Tab Completion"
    PowerShell's tab completion works with EmojiTools:
    ```powershell
    Get-Emoji -Category <TAB>  # Cycles through categories
    ```

!!! tip "Get Help Anytime"
    Every command has built-in help:
    ```powershell
    Get-Help Search-Emoji -Full
    Get-Help Copy-Emoji -Examples
    ```

---

Need help? Check the [Troubleshooting Guide](../reference/troubleshooting.md) or explore our [Command Reference](../reference/commands.md)!
