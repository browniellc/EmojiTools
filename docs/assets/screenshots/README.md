# Screenshots Directory

This directory contains screenshots for the EmojiTools documentation.

## Current Screenshots

### Emoji Picker
- `emoji-picker-light.png` - Emoji picker with light theme
- `emoji-picker-dark.png` - Emoji picker with dark theme
- `emoji-picker-search.png` - Emoji picker showing search functionality
- `emoji-picker-categories.png` - Emoji picker showing category filtering

## Screenshot Guidelines

### Recommended Sizes
- **Full window**: 1920x1080 (for high-DPI displays)
- **Cropped/focused**: 1200x800 (for documentation)
- **Thumbnail**: 600x400 (for README previews)

### File Naming Convention
- Use lowercase with hyphens: `feature-name-variant.png`
- Include theme if relevant: `picker-dark.png`, `picker-light.png`
- Include state if relevant: `search-active.png`, `category-filtered.png`

### Capturing Screenshots

#### Windows (Snipping Tool)
```powershell
Show-EmojiPicker -Theme Light
# Press: Win + Shift + S
# Select area and save
```

#### macOS
```powershell
Show-EmojiPicker -Theme Dark
# Press: Cmd + Shift + 4
# Drag to select area
```

#### Browser DevTools (Best Quality)
```powershell
Show-EmojiPicker -Standalone -Theme Light
# F12 -> Toggle device toolbar (Ctrl+Shift+M)
# Set viewport to 1200x800
# Click screenshot button in DevTools
```

### Image Optimization

After capturing, optimize images:
```powershell
# Using ImageMagick (if installed)
magick emoji-picker.png -quality 85 -strip emoji-picker-optimized.png

# Or use online tools:
# - TinyPNG (https://tinypng.com/)
# - Squoosh (https://squoosh.app/)
```

## Usage in Documentation

### In Markdown
```markdown
![Emoji Picker - Light Theme](assets/screenshots/emoji-picker-light.png)
```

### With Alt Text
```markdown
![Interactive emoji picker showing search and category filtering](assets/screenshots/emoji-picker-search.png)
```

### In README (Relative Path from Root)
```markdown
![Emoji Picker](docs/assets/screenshots/emoji-picker-light.png)
```
