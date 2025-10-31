# 📚 EmojiTools Documentation Index

Welcome to the EmojiTools comprehensive documentation!

**Current Version:** 1.14.0

## 🚀 Getting Started

Start here if you're new to EmojiTools:

- **[README.md](../README.md)** - Module overview, features, and installation
- **[QUICKSTART.md](../QUICKSTART.md)** - Quick start guide to get up and running
- **[EXAMPLES.ps1](../EXAMPLES.ps1)** - 19 practical code examples

## 📖 Feature Guides

Detailed guides for specific features:

### Core Features
- **[AUTO_UPDATE_GUIDE.md](AUTO_UPDATE_GUIDE.md)** - Automatic emoji dataset updates
- **[HISTORY_GUIDE.md](HISTORY_GUIDE.md)** - Update history tracking and change logs
- **[ALIASES_GUIDE.md](ALIASES_GUIDE.md)** - Emoji shortcuts and aliases (71 defaults)
- **[COLLECTIONS_GUIDE.md](COLLECTIONS_GUIDE.md)** - Creating and managing emoji collections
- **[ANALYTICS_GUIDE.md](ANALYTICS_GUIDE.md)** - Usage statistics and analytics
- **[CUSTOM_DATASETS_GUIDE.md](CUSTOM_DATASETS_GUIDE.md)** - Import, export, and create custom datasets
- **[CACHING_GUIDE.md](CACHING_GUIDE.md)** - 🚀 High-performance caching system (10-100x faster!) **NEW in v1.11.0!**

### Setup & Configuration
- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Module setup, initialization, and configuration
- **[SCHEDULED_TASKS_GUIDE.md](SCHEDULED_TASKS_GUIDE.md)** - Cross-platform scheduled task configuration

## 🔍 Quick Find

### By Use Case

**"I want to search for emojis"**
→ Start with [QUICKSTART.md](../QUICKSTART.md), then see [EXAMPLES.ps1](../EXAMPLES.ps1)

**"I want to set up shortcuts for my favorite emojis"**
→ Read [ALIASES_GUIDE.md](../ALIASES_GUIDE.md)

**"I want to organize emojis into groups"**
→ Read [COLLECTIONS_GUIDE.md](COLLECTIONS_GUIDE.md)

**"I want to use my own emoji dataset"**
→ Read [CUSTOM_DATASETS_GUIDE.md](CUSTOM_DATASETS_GUIDE.md)

**"I want to keep my emojis up to date automatically"**
→ Read [AUTO_UPDATE_GUIDE.md](AUTO_UPDATE_GUIDE.md)

**"I want to see what changed in each update"**
→ Read [HISTORY_GUIDE.md](HISTORY_GUIDE.md)

**"I need to configure the module"**
→ Read [SETUP_GUIDE.md](SETUP_GUIDE.md)

## 🎯 Function Reference

### Emoji Search & Retrieval
```powershell
Get-Emoji              # List and filter emojis
Search-Emoji           # Fuzzy search by keyword
Copy-Emoji             # Copy emoji to clipboard
Show-EmojiPicker       # Interactive picker
```
📖 See: [QUICKSTART.md](../QUICKSTART.md), [EXAMPLES.ps1](../EXAMPLES.ps1)

### Emoji Aliases (Shortcuts)
```powershell
Get-EmojiAlias                  # Retrieve aliases
New-EmojiAlias                  # Create custom alias
Remove-EmojiAlias               # Delete alias
Set-EmojiAlias                  # Update alias
Initialize-DefaultEmojiAliases  # Load 71 defaults
Import-EmojiAliases             # Import from file
Export-EmojiAliases             # Export to file
```
📖 See: [ALIASES_GUIDE.md](ALIASES_GUIDE.md)

### Emoji Collections
```powershell
New-EmojiCollection         # Create collection
Add-EmojiToCollection       # Add emoji
Remove-EmojiFromCollection  # Remove emoji
Get-EmojiCollection         # Retrieve collection
Remove-EmojiCollection      # Delete collection
Export-EmojiCollection      # Save to file
Import-EmojiCollection      # Load from file
Initialize-EmojiCollections # Load 6 defaults
```
📖 See: [COLLECTIONS_GUIDE.md](COLLECTIONS_GUIDE.md)

### Custom Datasets
```powershell
Import-CustomEmojiDataset   # Load custom dataset
Export-CustomEmojiDataset   # Save dataset
New-CustomEmojiDataset      # Create new dataset
Get-CustomEmojiDatasetInfo  # View dataset stats
Reset-EmojiDataset          # Reset to Unicode default
```
📖 See: [CUSTOM_DATASETS_GUIDE.md](CUSTOM_DATASETS_GUIDE.md)

### Dataset Updates
```powershell
Update-EmojiDataset        # Manual update
Get-EmojiDatasetInfo       # Dataset information
Enable-EmojiAutoUpdate     # Enable auto-updates
Disable-EmojiAutoUpdate    # Disable auto-updates
```
📖 See: [AUTO_UPDATE_GUIDE.md](AUTO_UPDATE_GUIDE.md)

### Update History Tracking 📊 NEW!
```powershell
Get-EmojiUpdateHistory     # View update history
Get-NewEmojis              # See recently added emojis
Get-RemovedEmojis          # See recently removed emojis
Export-EmojiHistory        # Export history to file
Clear-EmojiHistory         # Manage old history
```
📖 See: [HISTORY_GUIDE.md](HISTORY_GUIDE.md)

### Performance & Caching 🚀 NEW!
```powershell
Clear-EmojiCache           # Clear all caches
Get-EmojiCacheStats        # View cache statistics
Set-EmojiCacheConfig       # Configure caching
Get-EmojiCacheConfig       # View configuration
Start-EmojiCacheWarmup     # Pre-populate cache
```
📖 See: [CACHING_GUIDE.md](CACHING_GUIDE.md)

### Module Setup & Management
```powershell
Initialize-EmojiTools   # Setup/reinitialize
Reset-EmojiTools        # Reset to defaults
Get-EmojiToolsInfo      # Module status
```
📖 See: [SETUP_GUIDE.md](SETUP_GUIDE.md)

### Emoji Modifications
```powershell
Get-EmojiWithSkinTone   # Apply skin tones
Join-Emoji              # Combine emojis
Export-Emoji            # Save to file
```
📖 See: [EXAMPLES.ps1](../EXAMPLES.ps1)

### Statistics & Analytics
```powershell
Get-EmojiStats    # Usage statistics
Clear-EmojiStats  # Reset statistics
Export-EmojiStats # Export stats to CSV
```
📖 See: [EXAMPLES.ps1](../EXAMPLES.ps1)

### Safe Dispatcher
```powershell
Emoji              # Safe command dispatcher
```
📖 See: [README.md](../README.md)

## 📁 Module Structure

### 📚 Core Module Files
- **[EmojiTools.psd1](../EmojiTools.psd1)** - Module manifest (metadata, v1.10.0)
- **[EmojiTools.psm1](../EmojiTools.psm1)** - Main module loader and initialization

### ⚙️ Function Files (../functions/)
- **[Get-Emoji.ps1](../functions/Get-Emoji.ps1)** - List and filter emojis
- **[Search-Emoji.ps1](../functions/Search-Emoji.ps1)** - Fuzzy search functionality
- **[Update-EmojiDataset.ps1](../functions/Update-EmojiDataset.ps1)** - Download/update emoji data
- **[Emoji.ps1](../functions/Emoji.ps1)** - Safe dispatcher with security features
- **[Clipboard.ps1](../functions/Clipboard.ps1)** - Clipboard integration functions
- **[SkinTone.ps1](../functions/SkinTone.ps1)** - Skin tone modifier functions
- **[EmojiPicker.ps1](../functions/EmojiPicker.ps1)** - Interactive emoji picker
- **[Collections.ps1](../functions/Collections.ps1)** - Collection management (8 functions)
- **[Stats.ps1](../functions/Stats.ps1)** - Usage statistics tracking
- **[Aliases.ps1](../functions/Aliases.ps1)** - Alias/shortcut system (7 functions)
- **[Setup.ps1](../functions/Setup.ps1)** - Module setup and management (3 functions)
- **[AutoUpdate.ps1](../functions/AutoUpdate.ps1)** - Auto-update system (4 functions)
- **[CustomDatasets.ps1](../functions/CustomDatasets.ps1)** - Custom dataset support (5 functions)
- **[EmojiHistory.ps1](../functions/EmojiHistory.ps1)** - Update history tracking (5 functions) 📊 **NEW!**

### 📊 Data Files (../data/)
- **[emoji.csv](../data/emoji.csv)** - Emoji dataset (~1,948 emojis from Unicode CLDR)
- **[metadata.json](../data/metadata.json)** - Dataset metadata and version tracking
- **[history.json](../data/history.json)** - Update history and change logs (auto-generated) 📊 **NEW!**
- **[collections.json](../data/collections.json)** - Saved emoji collections (auto-generated)
- **[aliases.json](../data/aliases.json)** - Custom emoji aliases (auto-generated)
- **[stats.json](../data/stats.json)** - Usage statistics (auto-generated)
- **[.setup-complete](../data/.setup-complete)** - Setup completion marker

### 📖 Documentation Files
- **[README.md](../README.md)** - Complete module documentation
- **[QUICKSTART.md](QUICKSTART.md)** - Quick start guide
- **[EXAMPLES.ps1](../examples/EXAMPLES.ps1)** - Practical usage examples
- **[AUTO_UPDATE_GUIDE.md](AUTO_UPDATE_GUIDE.md)** - Auto-update documentation
- **[HISTORY_GUIDE.md](HISTORY_GUIDE.md)** - Update history tracking guide
- **[ALIASES_GUIDE.md](ALIASES_GUIDE.md)** - Alias system guide
- **[COLLECTIONS_GUIDE.md](COLLECTIONS_GUIDE.md)** - Collections management guide
- **[ANALYTICS_GUIDE.md](ANALYTICS_GUIDE.md)** - Usage statistics and analytics
- **[CUSTOM_DATASETS_GUIDE.md](CUSTOM_DATASETS_GUIDE.md)** - Custom datasets guide
- **[CUSTOM_SOURCES_GUIDE.md](CUSTOM_SOURCES_GUIDE.md)** - Custom remote sources guide
- **[CACHING_GUIDE.md](CACHING_GUIDE.md)** - High-performance caching guide
- **[SCHEDULED_TASKS_GUIDE.md](SCHEDULED_TASKS_GUIDE.md)** - Cross-platform scheduled tasks
- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Setup and configuration guide
- **[TESTING_STRATEGY.md](TESTING_STRATEGY.md)** - Testing strategy for contributors

## 🎯 Common Tasks

### First Time Setup
1. Import module: `Import-Module .\EmojiTools.psd1`
2. Update dataset: `Update-EmojiDataset -Source Unicode`
3. Enable auto-updates: `Enable-EmojiAutoUpdate -CreateScheduledTask`

📖 See: [SETUP_GUIDE.md](SETUP_GUIDE.md)

### Daily Usage
```powershell
# Quick search
Search-Emoji -Query "rocket"

# Use aliases
Get-EmojiAlias "fire"     # 🔥
Get-EmojiAlias "rocket"   # 🚀

# Copy to clipboard
Copy-Emoji "🎉"

# Use collections
Get-EmojiCollection "favorites"
```

📖 See: [QUICKSTART.md](QUICKSTART.md), [ALIASES_GUIDE.md](ALIASES_GUIDE.md)

### Advanced Workflows
```powershell
# Create custom dataset
$work = @(
    [PSCustomObject]@{ emoji='🏢'; name='HQ'; category='Work'; keywords='office' }
    [PSCustomObject]@{ emoji='💼'; name='briefcase'; category='Work'; keywords='business' }
)
$work | Export-Csv "work.csv" -NoTypeInformation -Encoding UTF8
Import-CustomEmojiDataset -Path "work.csv"

# Build themed collections
New-EmojiCollection -Name "productivity" -Description "Get things done"
Search-Emoji -Query "check" | ForEach-Object {
    Add-EmojiToCollection -Name "productivity" -Emoji $_.emoji
}

# Create custom aliases
New-EmojiAlias -Alias "done" -Emoji "✅"
New-EmojiAlias -Alias "todo" -Emoji "📝"
```

📖 See: [CUSTOM_DATASETS_GUIDE.md](CUSTOM_DATASETS_GUIDE.md), [COLLECTIONS_GUIDE.md](COLLECTIONS_GUIDE.md), [ALIASES_GUIDE.md](ALIASES_GUIDE.md)

## 📊 Module Information

**Current Version:** 1.14.0

**Data & Features:**
- 1,900+ emojis (Unicode CLDR)
- 71+ default aliases
- 6 default collections
- CSV & JSON dataset support
- Automatic updates with scheduled tasks
- Cross-platform support (Windows, Linux, macOS)
- Usage statistics and analytics
- High-performance caching system

## 🆘 Troubleshooting

### Common Issues

**Problem:** Can't find emojis
**Solution:** Update dataset with `Update-EmojiDataset -Source Unicode`

**Problem:** Module not loading
**Solution:** Check PowerShell version (5.1+): `$PSVersionTable.PSVersion`

**Problem:** Emojis not displaying
**Solution:** Set UTF-8 encoding: `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8`

**Problem:** Need to reset everything
**Solution:** Run `Reset-EmojiTools -IncludeStats -Force`

📖 See: [SETUP_GUIDE.md](SETUP_GUIDE.md), [README.md](../README.md)

## 🎓 Quick Command Reference

### Import Module
```powershell
Import-Module .\EmojiTools.psd1
```

### List Functions
```powershell
Get-Command -Module EmojiTools
```

### Get Help
```powershell
Get-Help Get-Emoji -Full
Get-Help Search-Emoji -Full
Get-Help Update-EmojiDataset -Full
Get-Help Import-CustomEmojiDataset -Full
```

### Basic Usage
```powershell
# Search
Search-Emoji -Query "smile"

# Filter
Get-Emoji -Category "Food" -Limit 5

# Aliases
Get-EmojiAlias "fire"

# Collections
Get-EmojiCollection "favorites"

# Custom datasets
Import-CustomEmojiDataset -Path "custom.csv"

# Update
Update-EmojiDataset -Source Unicode
```

## � Related Resources

- PowerShell Gallery: (Coming soon)
- Unicode CLDR: https://cldr.unicode.org
- Emoji Specification: https://unicode.org/emoji

## 📝 Version History

See [CHANGELOG.md](../CHANGELOG.md) for complete version history.

---

## 🔗 Navigation Tips

1. **New users** → Start with [QUICKSTART.md](QUICKSTART.md)
2. **Looking for examples** → Check [EXAMPLES.ps1](../examples/EXAMPLES.ps1)
3. **Need full reference** → Read [README.md](../README.md)
4. **Want to understand the code** → Browse `../src/functions/` folder
5. **Contributing** → See [CONTRIBUTING.md](../CONTRIBUTING.md)

---

## 🎉 You're Ready!

The EmojiTools module is complete and ready to use. Pick a starting point from above and begin exploring! 🚀

**Recommended path:**
1. Read [QUICKSTART.md](QUICKSTART.md) (5 min)
2. Try examples from [EXAMPLES.ps1](../examples/EXAMPLES.ps1) (10 min)
3. Refer to [README.md](../README.md) and feature guides as needed

**Need Help?** Start with [QUICKSTART.md](QUICKSTART.md) or browse the guides above!

Happy emoji hunting! 🎯✨
