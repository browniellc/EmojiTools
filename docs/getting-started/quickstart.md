# Quick Start

Welcome! Let's get you productive with EmojiTools in just a few minutes. By the end of this guide, you'll know how to search, copy, and manage emojis like a pro! 🚀

---

## 🎬 Your First 60 Seconds

### Step 1: Download the Latest Emojis

First, let's grab the complete Unicode emoji dataset (1,900+ emojis):

```powershell
Update-EmojiDataset -Source Unicode
```

!!! success "What Just Happened?"
    You downloaded the official Unicode emoji dataset! This gives you access to every standard emoji, complete with names, categories, and searchable keywords.

### Step 2: Search for Your First Emoji

Let's find some rocket emojis:

```powershell
Search-Emoji "rocket"
```

**You'll see:**

```
Emoji  Name              Category         Keywords
-----  ----              --------         --------
🚀     rocket           Travel & Places  launch, rocket, space
🧑‍🚀   astronaut        People & Body    astronaut, rocket, space
👨‍🚀   man astronaut    People & Body    astronaut, man, rocket
👩‍🚀   woman astronaut  People & Body    astronaut, rocket, woman
```

!!! tip "Pro Tip"
    Notice how it found "astronaut" too? That's because the search looks through keywords and descriptions, not just names!

### Step 3: Copy to Your Clipboard

Found the perfect emoji? Copy it instantly:

```powershell
Copy-Emoji "🚀"
# ✓ Copied 🚀 to clipboard
```

Now paste it anywhere—documents, chats, code! That's it—you're officially emoji-powered! 🎉

---

## 🎨 Explore Different Ways to Search

### Search by Feeling or Activity

```powershell
# Find celebration emojis
Search-Emoji "party"
```

**Results:**
```
Emoji  Name              Category          Keywords
-----  ----              --------          --------
🥳     partying face    Smileys & Emotion  birthday, celebrate, party
🎉     party popper     Activities         celebration, party, tada
🎊     confetti ball    Activities         celebration, confetti
```

### Search by Category

```powershell
# Get all food emojis
Get-Emoji -Category "Food & Drink" | Select-Object -First 10
```

### Browse All Categories

```powershell
# See what categories exist
Get-Emoji | Group-Object category | Select-Object Name, Count
```

**You'll discover:**

- Smileys & Emotion (169 emojis)
- People & Body (325 emojis)
- Animals & Nature (150 emojis)
- Food & Drink (134 emojis)
- Travel & Places (218 emojis)
- ...and more!

---

## 🎯 Real-World Examples

### Example 1: Spice Up Your Git Commits

```powershell
# Find a bug-fix emoji
Search-Emoji "bug"
Copy-Emoji "🐛"

# Now commit: git commit -m "🐛 Fix login validation"
```

### Example 2: Quick Documentation Headers

```powershell
# Build a project README header
Search-Emoji "rocket"
Copy-Emoji "🚀"
# Use: # 🚀 Project Name

Search-Emoji "check"
Copy-Emoji "✅"
# Use: ## ✅ Features
```

### Example 3: Status Updates

```powershell
# Team standup time!
Search-Emoji "working"
Copy-Emoji "💼"

Search-Emoji "done"
Copy-Emoji "✅"

Search-Emoji "problem"
Copy-Emoji "⚠️"
```

---

## 🖼️ Try the Visual Picker

Prefer clicking to typing? Launch the interactive emoji picker:

```powershell
Show-EmojiPicker
```

This opens a beautiful web interface where you can:

- 🔍 Search with instant results
- 📂 Browse by category
- 🎨 Select skin tones
- 👆 Click to copy

!!! info "Standalone Mode"
    Want to keep it open? Use `Show-EmojiPicker -Standalone` to launch it in a separate window!

[Learn more about the Emoji Picker →](../user-guide/picker.md)

---

## 📚 Create Your First Collection

Collections let you organize emojis by project or theme:

```powershell
# Create a collection for your blog posts
New-EmojiCollection -Name "Blog" -Description "My favorite blog emojis"

# Add some emojis
Add-EmojiToCollection -Name "Blog" -Emoji "📝", "✍️", "📖", "💡"

# Use your collection
Get-EmojiCollection -Name "Blog"
```

**Output:**
```
Name: Blog
Description: My favorite blog emojis
Emojis: 📝 ✍️ 📖 💡
```

[Master Collections →](../user-guide/collections.md)

---

## ⚡ Power User Tips

### Fuzzy Matching is Smart

```powershell
# These all work!
Search-Emoji "fire"      # 🔥 fire
Search-Emoji "flames"    # 🔥 fire (from keywords)
Search-Emoji "hot"       # 🔥 fire (from description)
```

### Combine with PowerShell Pipeline

```powershell
# Get all animal emojis and select 5 random ones
Get-Emoji -Category "Animals & Nature" | Get-Random -Count 5
```

### Create Aliases for Favorites

```powershell
# Set up a quick shortcut
New-EmojiAlias -Alias "ship" -Emoji "🚀"

# Now use it
Search-Emoji "ship"  # Shows 🚀
```

[Explore Aliases →](../user-guide/aliases.md)

---

## 🔄 Keep Everything Updated

Never miss new emojis! Set up automatic updates:

```powershell
# Enable auto-updates (checks weekly)
Enable-EmojiAutoUpdate -CreateScheduledTask
```

Now EmojiTools will automatically:

✅ Check for new emojis every week
✅ Download updates in the background
✅ Notify you about what's new
✅ Keep a complete change history

[Learn about Auto-Updates →](../automation/auto-updates.md)

---

## 🎓 What's Next?

You've mastered the basics! Ready to level up?

<div class="grid cards" markdown>

-   :mag_right: **Master Searching**

    ---

    Learn advanced search techniques and filters

    [:octicons-arrow-right-24: Search Guide](../user-guide/searching.md)

-   :file_folder: **Export & Share**

    ---

    Export emojis to HTML, JSON, CSV, or Markdown

    [:octicons-arrow-right-24: Export Guide](../user-guide/export.md)

-   :robot: **Automate Everything**

    ---

    Set up scheduled tasks and history tracking

    [:octicons-arrow-right-24: Automation](../automation/auto-updates.md)

-   :sparkles: **Advanced Features**

    ---

    Custom datasets, analytics, and more

    [:octicons-arrow-right-24: Advanced Topics](../advanced/custom-datasets.md)

</div>

---

## ❓ Quick Reference Card

Save this cheat sheet for quick access:

| Task | Command |
|------|---------|
| Download emojis | `Update-EmojiDataset -Source Unicode` |
| Search by keyword | `Search-Emoji "keyword"` |
| Copy emoji | `Copy-Emoji "😀"` |
| Open picker | `Show-EmojiPicker` |
| List by category | `Get-Emoji -Category "Smileys & Emotion"` |
| Create collection | `New-EmojiCollection -Name "MyEmojis"` |
| Enable auto-update | `Enable-EmojiAutoUpdate -CreateScheduledTask` |
| Check dataset info | `Get-EmojiDatasetInfo` |

---

!!! success "You're Ready!"
    Congratulations! You now know the essentials of EmojiTools. Happy emoji hunting! 🎉

Need help? Check the [Troubleshooting Guide](../reference/troubleshooting.md) or [browse all commands](../reference/commands.md).
