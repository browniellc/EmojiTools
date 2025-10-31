# Emoji Picker Guide

## Overview

The `Show-EmojiPicker` function provides an interactive, browser-based emoji picker with real-time search, category filtering, and clipboard integration.

## Features

- 🎨 **Modern UI** - Clean, responsive interface with light/dark themes
- 🔍 **Real-time Search** - Fuzzy search as you type
- 📂 **Category Filtering** - Browse by emoji categories
- 🎯 **Skin Tone Support** - Select different skin tones for applicable emojis
- 📋 **Auto-Clipboard** - Selected emojis automatically copied
- 🌓 **Theme Support** - Light, Dark, or Auto (system preference)
- 🔌 **Standalone Mode** - Works without PowerShell server

## Basic Usage

### Quick Start

```powershell
# Open emoji picker
Show-EmojiPicker
```

This opens an interactive browser window where you can:
1. Search for emojis by name
2. Filter by category
3. Click an emoji to copy it to clipboard
4. Close the picker when done

### With Category Filter

```powershell
# Pre-filter to a specific category
Show-EmojiPicker -Category "Smileys & Emotion"
```

### With Collection Filter

```powershell
# Show only emojis from a collection
Show-EmojiPicker -Collection "Favorites"
```

### Return to Variable

```powershell
# Return selected emoji to a variable
$emoji = Show-EmojiPicker -ReturnEmoji
Write-Host "You selected: $emoji"
```

## Theme Options

### Auto (Default)
Detects your system's theme preference:
```powershell
Show-EmojiPicker -Theme Auto
```

### Light Theme
```powershell
Show-EmojiPicker -Theme Light
```

### Dark Theme
```powershell
Show-EmojiPicker -Theme Dark
```

## Standalone Mode

Standalone mode opens the picker as a static HTML page without requiring a PowerShell HTTP server.

### When to Use Standalone Mode

Use `-Standalone` when:
- You want to keep the picker open while continuing PowerShell work
- You don't need to return the emoji to PowerShell
- You're running in a restricted environment
- You want a persistent emoji reference

### Usage

```powershell
Show-EmojiPicker -Standalone
```

**Important Notes:**
- ✅ Emojis are still copied to clipboard when clicked
- ❌ Cannot use `-ReturnEmoji` with `-Standalone`
- 📌 You must manually close the browser window
- 🔒 No HTTP server required

### Difference: Server vs Standalone

| Feature | Server Mode (Default) | Standalone Mode |
|---------|----------------------|-----------------|
| Clipboard Copy | ✅ Yes | ✅ Yes |
| Return to PowerShell | ✅ Yes (with `-ReturnEmoji`) | ❌ No |
| Auto-Close | ✅ Yes | ❌ Manual close required |
| HTTP Server | Required | Not required |
| Keep Open | No | ✅ Yes |

## Advanced Options

### Custom Port

If port 8321 is already in use:
```powershell
Show-EmojiPicker -Port 8080
```

### Combined Options

```powershell
# Dark theme + specific category + custom port
Show-EmojiPicker -Theme Dark -Category "Food & Drink" -Port 9000

# Standalone + dark theme
Show-EmojiPicker -Standalone -Theme Dark
```

## Keyboard Shortcuts

While the picker is open:

- **Type to search** - Real-time fuzzy search
- **Escape** - Close picker (server mode only)
- **Click emoji** - Copy to clipboard and close (or just copy in standalone mode)

## Screenshots

To capture screenshots of the emoji picker:

### Method 1: Using Windows Snipping Tool (Windows)

```powershell
# Open the picker
Show-EmojiPicker -Theme Light

# Then press: Win + Shift + S
# Select the area to capture
```

### Method 2: Using PowerShell + Browser DevTools

```powershell
# Open picker in standalone mode
Show-EmojiPicker -Standalone -Theme Dark

# In browser:
# Press F12 -> Console -> Run:
# await new Promise(r => setTimeout(r, 500)); 
# Then use browser's built-in screenshot (F12 -> Device toolbar -> Screenshot)
```

### Method 3: macOS Screenshot

```powershell
# Open the picker
Show-EmojiPicker -Theme Auto

# Press: Cmd + Shift + 4
# Drag to select area
```

### Method 4: Automated with Selenium (Advanced)

For automated screenshot generation:

```powershell
# Install Selenium module
Install-Module Selenium -Scope CurrentUser

# Generate screenshot
$driver = Start-SeChrome -Headless
$driver.Navigate().GoToUrl("http://localhost:8321")
Start-Sleep -Seconds 2
$driver.GetScreenshot().SaveAsFile("emoji-picker.png")
$driver.Quit()
```

## Troubleshooting

### Port Already in Use

```
Error: Unable to start HTTP listener on port 8321
```

**Solution:** Use a different port:
```powershell
Show-EmojiPicker -Port 8080
```

### Picker Doesn't Open

**Check browser:** Ensure you have a default browser set

**Firewall:** Windows may prompt to allow PowerShell network access

### Emojis Not Displaying

**Font support:** Ensure your browser has emoji font support (modern browsers do by default)

### Can't Close Picker in Standalone Mode

**Expected behavior:** In standalone mode, you must manually close the browser tab/window

## Examples

### Example 1: Quick Emoji Selection

```powershell
# Open picker, select emoji, it's auto-copied
Show-EmojiPicker
# Click 🎉
# Paste anywhere: 🎉
```

### Example 2: Build Emoji String

```powershell
# Select multiple emojis
$emojis = @()
$emojis += Show-EmojiPicker -ReturnEmoji
$emojis += Show-EmojiPicker -ReturnEmoji
$emojis += Show-EmojiPicker -ReturnEmoji

$message = "Status: $($emojis -join ' ')"
Write-Host $message
# Output: Status: ✅ 🎉 🚀
```

### Example 3: Category Browsing

```powershell
# Browse different categories
Show-EmojiPicker -Category "Animals & Nature"
Show-EmojiPicker -Category "Food & Drink"
Show-EmojiPicker -Category "Travel & Places"
```

### Example 4: Persistent Reference

```powershell
# Keep picker open as reference while working
Show-EmojiPicker -Standalone -Theme Dark

# Continue working in PowerShell
# Picker stays open in browser for easy emoji copying
```

## Technical Details

### How It Works

**Server Mode:**
1. Starts HTTP listener on specified port (default: 8321)
2. Generates HTML/CSS/JavaScript emoji picker
3. Opens browser to `http://localhost:8321`
4. Browser communicates selection back to PowerShell
5. Emoji copied to clipboard and/or returned
6. Server automatically shuts down

**Standalone Mode:**
1. Generates complete HTML file with embedded data
2. Saves to temp location
3. Opens file in browser
4. No server communication needed
5. Manual browser close required

### Data Source

The picker uses the same emoji dataset as other EmojiTools functions:
- Located at: `src/data/emoji.csv`
- Includes: Official names, categories, Unicode codepoints
- Updated via: `Update-EmojiDataset -Source Unicode`

## See Also

- [QUICKSTART.md](QUICKSTART.md) - Module quick start guide
- [COLLECTIONS_GUIDE.md](COLLECTIONS_GUIDE.md) - Creating emoji collections
- [Search-Emoji](../src/functions/Search-Emoji.ps1) - Command-line emoji search
- [Get-Emoji](../src/functions/Get-Emoji.ps1) - List all emojis
