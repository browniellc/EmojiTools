# EmojiTools PowerShell Module

<p align="center">
  <img src="EmojiTools.png" alt="EmojiTools Logo" width="256" height="256">
</p>

<p align="center">
  <a href="https://www.powershellgallery.com/packages/EmojiTools"><img src="https://img.shields.io/powershellgallery/v/EmojiTools" alt="PowerShell Gallery"></a>
  <a href="https://www.powershellgallery.com/packages/EmojiTools"><img src="https://img.shields.io/powershellgallery/dt/EmojiTools" alt="PowerShell Gallery Downloads"></a>
</p>

<p align="center">
A powerful PowerShell module for emoji search, management, and lookup with <strong>automatic Unicode CLDR integration</strong> to keep your emoji dataset always current.
</p>

<p align="center">
  <strong>📖 <a href="https://tsabo.github.io/EmojiTools/">Read the Full Documentation</a></strong>
</p>

![Emoji Picker](docs/assets/screenshots/emoji-picker-light.png)
*Interactive browser-based emoji picker with search and category filtering*

## ✨ Features

- 🔍 **Fuzzy Search**: Find emojis by name or keyword (e.g., "house" → 🏠 🏡)
- 📦 **1,900+ Emojis**: Full Unicode CLDR dataset with official names
- 🔄 **Auto-Update**: Automatic checks and updates from Unicode CLDR (official source)
- 📅 **Dataset Tracking**: Monitor age, source, and version of your emoji data
- 📊 **History Tracking**: Track what's new in each update with detailed change logs
- ⏰ **Scheduled Updates**: Cross-platform scheduled tasks (Windows, Linux, macOS)
- 🎯 **Category Filtering**: Filter emojis by category
- 🎨 **Custom Datasets**: Import, create, and manage custom emoji collections
- 📁 **Multiple Formats**: Support for CSV and JSON dataset formats
- 🚀 **High-Performance Caching**: 10-100x faster with intelligent caching system
- 🔕 **Silent Mode**: Non-intrusive background updates
- 🌐 **Custom Sources**: Register and manage custom remote emoji sources
- 📝 **Aliases & Collections**: Create shortcuts and organize emoji sets
- 📈 **Analytics**: Track usage statistics

## � Installation

### From PowerShell Gallery (Recommended)

```powershell
# Install the module
Install-Module -Name EmojiTools -Scope CurrentUser

# Import the module
Import-Module EmojiTools
```

**PowerShell Gallery:** [https://www.powershellgallery.com/packages/EmojiTools](https://www.powershellgallery.com/packages/EmojiTools)

### From Source

```powershell
# Clone the repository
git clone https://github.com/tsabo/EmojiTools.git
cd EmojiTools

# Import the module
Import-Module .\src\EmojiTools.psd1
```

### Prerequisites
- PowerShell 7.0 or higher (cross-platform support)
- Internet connection (for dataset updates)

## 🚀 Quick Start

### 1. Get Latest Emojis (Recommended First Step)
```powershell
# Download 1,900+ emojis from Unicode CLDR
Update-EmojiDataset -Source Unicode
```

### 2. Enable Auto-Updates (Set It & Forget It!)
```powershell
# Check for updates weekly + create cross-platform scheduled task
Enable-EmojiAutoUpdate -CreateScheduledTask
```

### 3. Search for Emojis
```powershell
# Fuzzy search by name or keyword
Search-Emoji -Query "house"
# Returns: 🏠 house, 🏡 house with garden

Search-Emoji -Query "smile"
# Returns: 😀 grinning face, 😃 grinning face with big eyes, etc.

# Or use the interactive visual picker
Show-EmojiPicker
```

📚 **[View Complete Quick Start Guide →](https://tsabo.github.io/EmojiTools/getting-started/quickstart/)**

## 🔄 Keeping Dataset Current

### Check Dataset Status
```powershell
Get-EmojiDatasetInfo
```

This shows:
- Dataset age and size
- Emoji count (should be 1,900+)
- Source and version
- Update recommendations

### Auto-Update (Recommended)
```powershell
# Enable weekly checks with scheduled task
Enable-EmojiAutoUpdate -Interval 7 -CreateScheduledTask
```

The module will:
- ✅ Check dataset age on module load
- ✅ Notify you when updates are recommended
- ✅ Auto-download in background (if scheduled task enabled)
- ✅ Always use official Unicode CLDR source

### Manual Update
```powershell
# Update anytime
Update-EmojiDataset -Source Unicode
```

📚 **[View Auto-Update Documentation →](https://tsabo.github.io/EmojiTools/automation/auto-updates/)**

## 📊 History Tracking

### View Update History
```powershell
# See all dataset updates
Get-EmojiUpdateHistory

# See last 3 updates
Get-EmojiUpdateHistory -Last 3

# See updates since a date
Get-EmojiUpdateHistory -Since (Get-Date).AddDays(-30)
```

### View New & Removed Emojis
```powershell
# See newly added emojis
Get-NewEmojis

# See recently removed emojis
Get-RemovedEmojis

# Filter by category
Get-NewEmojis -Category "Smileys & Emotion"
```

### Export History
```powershell
# Export to JSON
Export-EmojiHistory -Format JSON -Path "history.json"

# Export to HTML report
Export-EmojiHistory -Format HTML -Path "report.html" -IncludeDetails

# Export to Markdown
Export-EmojiHistory -Format Markdown -Path "changelog.md"
```

📚 **[View History Tracking Documentation →](https://tsabo.github.io/EmojiTools/automation/history/)**

## 📖 Usage

### Get All Emojis
```powershell
# Get all emojis
Get-Emoji

# Get emojis from a specific category
Get-Emoji -Category "Smileys & Emotion"

# Limit results
Get-Emoji -Limit 10
```

### Search for Emojis
```powershell
# Fuzzy search by name or keyword
Search-Emoji -Query "house"
# Returns: 🏠 house, 🏡 house with garden

Search-Emoji -Query "smile"
# Returns: 😀 grinning face, 😃 grinning face with big eyes, etc.

# Exact search
Search-Emoji -Query "heart" -Exact

# Limit search results
Search-Emoji -Query "car" -Limit 5
```

### Update Emoji Dataset
```powershell
# Download from Unicode CLDR (recommended - official source)
Update-EmojiDataset -Source Unicode

# Force re-download
Update-EmojiDataset -Force

# Download from custom URL
Update-EmojiDataset -Url "https://example.com/emojis.csv"
```

### Export Emojis
```powershell
# Export to interactive HTML
Export-Emoji -Format HTML -OutputPath "emojis.html"

# Export to JSON for applications
Export-Emoji -Format JSON -OutputPath "emojis.json"

# Export to Markdown for documentation
Export-Emoji -Format Markdown -OutputPath "emojis.md"

# Export with dark theme and filters
Export-Emoji -Format HTML -StyleTheme Dark -Category "Food & Drink" -OutputPath "food.html"

# Export a saved collection
Export-Emoji -Format HTML -Collection "Favorites" -StyleTheme Colorful -OutputPath "favorites.html"
```

📚 **[View Export Documentation →](https://tsabo.github.io/EmojiTools/user-guide/export/)**

For more examples, see the **[documentation](https://tsabo.github.io/EmojiTools/)** and [examples/EXAMPLES.ps1](examples/EXAMPLES.ps1).

## 📁 Module Structure

```
EmojiTools/
├── src/
│   ├── EmojiTools.psm1        # Main module file
│   ├── EmojiTools.psd1        # Module manifest
│   ├── data/
│   │   ├── emoji.csv          # Emoji dataset (CSV format)
│   │   ├── metadata.json      # Dataset metadata
│   │   ├── history.json       # Update history tracking
│   │   ├── collections.json   # Saved emoji collections
│   │   ├── aliases.json       # Custom emoji aliases
│   │   └── stats.json         # Usage statistics
│   └── functions/
│       ├── Get-Emoji.ps1      # List all emojis
│       ├── Search-Emoji.ps1   # Fuzzy search function
│       ├── Collections.ps1    # Collection management
│       ├── CustomDatasets.ps1 # Custom dataset support
│       ├── EmojiHistory.ps1   # History tracking functions
│       ├── Cache.ps1          # High-performance caching
│       ├── ScheduledTask.ps1  # Cross-platform scheduled tasks
│       └── ...                # Additional functions
├── docs/                      # Comprehensive guides
│   ├── INDEX.md               # Documentation index
│   ├── QUICKSTART.md          # Quick start guide
│   ├── AUTO_UPDATE_GUIDE.md   # Auto-update documentation
│   ├── CACHING_GUIDE.md       # Caching system guide
│   └── ...                    # Feature-specific guides
├── examples/
│   └── EXAMPLES.ps1           # Usage examples
├── tests/                     # Pester test files
├── .github/                   # GitHub templates & workflows
├── CHANGELOG.md               # Version history
├── CONTRIBUTING.md            # Contribution guidelines
└── README.md                  # This file
```

## 📚 Documentation

**📖 [View Full Documentation Website →](https://tsabo.github.io/EmojiTools/)**

### Getting Started
- **[Installation Guide](https://tsabo.github.io/EmojiTools/getting-started/installation/)** - Install and set up EmojiTools
- **[Quick Start](https://tsabo.github.io/EmojiTools/getting-started/quickstart/)** - Get up and running in minutes
- **[First Steps](https://tsabo.github.io/EmojiTools/getting-started/first-steps/)** - Your first tasks with EmojiTools

### User Guide
- **[Searching Emojis](https://tsabo.github.io/EmojiTools/user-guide/searching/)** - Master emoji search techniques
- **[Emoji Picker](https://tsabo.github.io/EmojiTools/user-guide/picker/)** - Interactive visual emoji picker
- **[Collections](https://tsabo.github.io/EmojiTools/user-guide/collections/)** - Organize emojis into collections
- **[Export & Share](https://tsabo.github.io/EmojiTools/user-guide/export/)** - Export to HTML, JSON, Markdown, CSV
- **[Aliases](https://tsabo.github.io/EmojiTools/user-guide/aliases/)** - Create emoji shortcuts

### Automation
- **[Auto-Updates](https://tsabo.github.io/EmojiTools/automation/auto-updates/)** - Automatic dataset updates
- **[Scheduled Tasks](https://tsabo.github.io/EmojiTools/automation/scheduled-tasks/)** - Cross-platform scheduling
- **[History Tracking](https://tsabo.github.io/EmojiTools/automation/history/)** - Track emoji updates

### Advanced
- **[Custom Datasets](https://tsabo.github.io/EmojiTools/advanced/custom-datasets/)** - Create custom emoji data
- **[Custom Sources](https://tsabo.github.io/EmojiTools/advanced/custom-sources/)** - Register remote sources
- **[Analytics](https://tsabo.github.io/EmojiTools/advanced/analytics/)** - Usage statistics
- **[Caching](https://tsabo.github.io/EmojiTools/advanced/caching/)** - High-performance caching

### Reference
- **[Commands](https://tsabo.github.io/EmojiTools/reference/commands/)** - Complete command reference
- **[Configuration](https://tsabo.github.io/EmojiTools/reference/configuration/)** - Configuration options
- **[Troubleshooting](https://tsabo.github.io/EmojiTools/reference/troubleshooting/)** - Common issues and solutions

## 🔧 Key Functions

The module includes comprehensive functions for emoji management:

### Core Functions

- **Get-Emoji** - List and filter emojis by category
- **Search-Emoji** - Fuzzy search for emojis by name or keyword
- **Update-EmojiDataset** - Download and update emoji data
- **Get-EmojiDatasetInfo** - View dataset information and age

### History & Updates

- **Get-EmojiUpdateHistory** - View update history
- **Get-NewEmojis** - See recently added emojis
- **Get-RemovedEmojis** - See recently removed emojis
- **Export-EmojiHistory** - Export history to various formats
- **Enable-EmojiAutoUpdate** / **Disable-EmojiAutoUpdate** - Manage auto-updates

### Collections & Organization

- **New-EmojiCollection** - Create emoji collections
- **Add-EmojiToCollection** / **Remove-EmojiFromCollection** - Manage collections
- **Get-EmojiCollection** - Retrieve collections
- **Import-EmojiCollection** / **Export-EmojiCollection** - Import/export collections

### Aliases & Shortcuts

- **New-EmojiAlias** - Create emoji shortcuts
- **Get-EmojiAlias** - Retrieve aliases
- **Import-EmojiAliases** / **Export-EmojiAliases** - Manage aliases

### Custom Datasets

- **Import-CustomEmojiDataset** - Import custom emoji data
- **Export-CustomEmojiDataset** - Export emoji datasets
- **New-CustomEmojiDataset** - Create new datasets
- **Reset-EmojiDataset** - Reset to default Unicode dataset

### Caching & Performance

- **Clear-EmojiCache** - Clear performance cache
- **Get-EmojiCacheStats** - View cache statistics
- **Set-EmojiCacheConfig** / **Get-EmojiCacheConfig** - Configure caching

### Scheduled Tasks (Cross-Platform)

- **New-EmojiScheduledTask** - Create scheduled update tasks
- **Remove-EmojiScheduledTask** - Remove scheduled tasks
- **Test-EmojiScheduledTask** - Check if task exists

For complete function reference, run `Get-Command -Module EmojiTools` or see the **[Commands Reference](https://tsabo.github.io/EmojiTools/reference/commands/)**.

## 🌐 Data Sources

The module supports official Unicode CLDR as the primary data source:

**Unicode CLDR** (Recommended):
- Official Unicode emoji annotations
- Most comprehensive and up-to-date
- No authentication required
- 1,900+ emojis with full metadata

**Custom Sources**:
- Register custom remote URLs with `Register-EmojiSource`
- Support for CSV and JSON formats
- See **[Custom Sources Guide](https://tsabo.github.io/EmojiTools/advanced/custom-sources/)**

## 🆘 Troubleshooting

### No emoji data found
Run `Update-EmojiDataset -Source Unicode` to download the initial dataset.

### Module not loading
Check PowerShell version (7.0+): `$PSVersionTable.PSVersion`

### Emojis not displaying
Ensure your terminal/console supports UTF-8 encoding:
```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
```

### Need to reset everything
Run `Reset-EmojiTools -IncludeStats -Force`

For more help, see the **[Troubleshooting Guide](https://tsabo.github.io/EmojiTools/reference/troubleshooting/)** or browse the **[full documentation](https://tsabo.github.io/EmojiTools/)**.

## 📄 License

Copyright © 2025. All rights reserved.

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

- Report bugs or request features via [GitHub Issues](https://github.com/tsabo/EmojiTools/issues)
- Submit pull requests for improvements
- See **[Development Setup Guide](https://tsabo.github.io/EmojiTools/contributing/setup/)** for getting started
- See **[Testing Guide](https://tsabo.github.io/EmojiTools/contributing/testing/)** for testing information

## 📊 Version

**Current Version:** 1.15.0
**Last Updated:** October 31, 2025

See [CHANGELOG.md](CHANGELOG.md) for complete version history.
