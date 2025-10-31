# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.14.0] - 2025-10-30

**Note:** Version 1.15.0 features are in development. Module is currently at version 1.14.0.

### Added - 🌍 Cross-Platform Scheduled Task Support
- **Cross-Platform Task Scheduling** - Automatic emoji updates on Windows, Linux, and macOS
  - `New-EmojiScheduledTask` - Create platform-specific scheduled tasks
  - `Remove-EmojiScheduledTask` - Remove scheduled tasks on any platform
  - `Test-EmojiScheduledTask` - Check if scheduled task exists
  - `Get-EmojiPlatform` - Detect current operating system
  - **Windows**: Task Scheduler integration (daily at 3 AM with configurable interval)
  - **Linux**: cron job creation with marker-based identification
  - **macOS**: LaunchAgent plist generation with logging support
  - Interval validation (1-365 days) with `ValidateRange` attribute
  - `-Silent` parameter for scripted operations
  - `-WhatIf` support via `SupportsShouldProcess`
  - Automatic cleanup when recreating tasks

- **Enhanced Auto-Update Functions**
  - Updated `Enable-EmojiAutoUpdate` - Now supports Windows, Linux, and macOS
  - Updated `Disable-EmojiAutoUpdate` - Cross-platform task removal
  - Added `-WhatIf` support to both functions
  - Platform detection and status display

- **Comprehensive Testing**
  - **54 Pester 5.x tests** (87% cross-platform coverage)
  - **47 tests** run on ALL platforms (mocked cross-platform tests)
  - **7 tests** Windows-only (real Task Scheduler integration)
  - **Hybrid Testing Strategy**: Mocked + Integration tests
    - Cross-platform mocked tests (13 tests) - Test Windows/Linux/macOS logic on ANY platform
    - Windows integration tests (7 tests) - Real Task Scheduler cmdlets (Windows only)
    - Linux validation tests (4 tests) - Cron expression format (all platforms)
    - macOS validation tests (5 tests) - Plist structure & interval math (all platforms)
  - Platform detection tests (5 tests)
  - Abstraction layer tests (12 tests, `-WhatIf` based)
  - Integration tests (6 tests, `Enable/Disable-EmojiAutoUpdate`)
  - Error handling tests (5 tests)
  - **Philosophy**: "Every contributor should be able to test every feature, regardless of their OS"

### Changed
- **Breaking**: Upgraded to Pester 5.7.1 (from Pester 3.4.0)
  - New test syntax using `Describe`, `Context`, `It`, `Should`
  - Better CI/CD integration (Azure Pipelines, GitHub Actions)
  - Industry-standard testing framework
  - Future-proof for open-source contributions
- Updated `Enable-EmojiAutoUpdate` to use cross-platform abstraction
- Updated `Disable-EmojiAutoUpdate` to use cross-platform abstraction
- Removed Windows-only scheduled task code from `Cache.ps1` (~70 lines)
- Updated module version to 1.15.0
- Updated function count from 48 to 52 functions

### Documentation
- Added comprehensive `SCHEDULED_TASKS_GUIDE.md` (467 lines)
  - Platform-specific setup instructions
  - Manual management commands for each platform
  - Troubleshooting guides
  - Security considerations
  - Best practices and examples
  - FAQ section
- Added `TESTING_STRATEGY.md` (comprehensive testing philosophy)
  - Hybrid testing approach explained (mocked + integration)
  - Test coverage breakdown by platform
  - Manual testing guides for macOS/Linux contributors
  - CI/CD pipeline recommendations
  - Future improvement suggestions
- Updated `Run-AllTests.ps1` to include scheduled task tests
- Expected test count: 165+ tests (was 143)

### Technical Details
- **ScheduledTask.ps1**: 613 lines of cross-platform scheduling logic
  - Platform detection (PS 5.1 and PS 7+ compatible)
  - PowerShell path detection (`pwsh` or `powershell.exe`)
  - Windows: `Register-ScheduledTask` with proper settings
  - Linux: Safe crontab manipulation with `# EmojiTools-AutoUpdate` marker
  - macOS: Plist generation with `StartInterval`, logging paths
- **Test Coverage**: 44 tests across 10 contexts
  - Platform detection tests (5 tests)
  - Windows Task Scheduler tests (6 tests)
  - Linux cron tests (4 tests)
  - macOS LaunchAgent tests (5 tests)
  - Abstraction layer tests (15 tests)
  - Integration tests (6 tests)
  - Error handling tests (3 tests)
- PSScriptAnalyzer compliant (0 critical warnings)
- Follows PowerShell best practices (`SupportsShouldProcess`, `ValidateRange`, `OutputType`)

### Migration Notes
- **Pester Users**: If you have Pester 3.x installed, upgrade to Pester 5.x:
  ```powershell
  Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser
  ```
- **Existing Scheduled Tasks**: Windows tasks created before v1.15.0 will continue to work but won't have cross-platform features. Recreate them with `New-EmojiScheduledTask` for full support.

---

## [1.12.0] - 2025-10-30

### Added - 📊 Universal Update History Tracking
- **New History Tracking System** - Track emoji dataset changes across all update sources
  - `Get-EmojiUpdateHistory` - View complete update history with filters
  - `Get-NewEmojis` - Display recently added emojis by category
  - `Get-RemovedEmojis` - Display recently removed emojis
  - `Export-EmojiHistory` - Export history to JSON, CSV, HTML, or Markdown
  - `Clear-EmojiHistory` - Manage old history entries with ShouldProcess support
  - Automatic diff calculation (added/removed/modified emojis)
  - Character-based change detection for emoji modifications
  - Universal source tracking (Unicode, GitHub, Custom, File)
  - Version tracking when available from dataset metadata

- **Smart Notifications (Option C)**
  - Subtle one-line notification on module load for updates in last 7 days
  - Detailed change summary in `Get-EmojiDatasetInfo`
  - Non-intrusive, informative design

- **Enhanced Dataset Info**
  - Added "Recent Changes (Last 7 Days)" section to `Get-EmojiDatasetInfo`
  - Shows last 3 updates with emoji counts
  - Displays added/removed/modified counts per update

### Changed
- Updated `Update-EmojiDataset` to automatically track update history
- Enhanced `Get-EmojiDatasetInfo` with recent changes section
- Modified module initialization to show subtle notifications
- Updated module version to 1.12.0
- Updated `EmojiTools.psm1` to export 5 new history functions

### Documentation
- Added comprehensive `HISTORY_GUIDE.md` with examples and use cases
- Updated `README.md` with history tracking section
- Updated `INDEX.md` with history function references
- Updated function count from 43 to 48 functions

### Technical Details
- History stored in `data/history.json` (~10KB per update, ~5MB per 10 years)
- PSScriptAnalyzer compliant (0 critical warnings)
- Added suppressions for `Get-NewEmojis` and `Get-RemovedEmojis` (PSUseSingularNouns - plural is semantically correct)

## [1.11.0] - 2025-10-30

### Added - 🚀 High-Performance Caching System (All 3 Phases Complete!)
- **Phase 1: Query Result Cache & Collection Cache**
  - `Get-CachedSearchResult` - Retrieve cached search results
  - `Set-CachedSearchResult` - Store search results with LRU eviction
  - `Get-CachedCollections` - Cache collection JSON with auto-invalidation
  - Query result cache with configurable TTL (default: 30 minutes)
  - LRU (Least Recently Used) eviction algorithm
  - Collection cache with automatic file change detection

- **Phase 2: Search Indices**
  - `Initialize-EmojiIndices` - Build search indices on module load
  - `Search-IndexedEmoji` - O(1) indexed search
  - `Get-EmojiByCategory` - Fast category lookup
  - Name Index: 2,990+ word entries
  - Keyword Index: 3,965+ keyword entries
  - Category Index: 10 category entries
  - Emoji Index: 1,948+ emoji character mappings
  - Automatic index rebuild on dataset updates

- **Phase 3: Configuration & Management**
  - `Clear-EmojiCache` - Clear all caches with optional index rebuild
  - `Get-EmojiCacheStats` - Comprehensive cache statistics
  - `Set-EmojiCacheConfig` - Configure cache behavior
  - `Get-EmojiCacheConfig` - View current configuration
  - `Start-EmojiCacheWarmup` - Pre-populate cache with popular queries
  - `Invoke-CacheInvalidation` - Internal cache invalidation
  - Configurable cache sizes and TTL
  - Cache warmup with 10 popular default queries
  - Real-time cache hit/miss statistics

### Changed
- Updated `Search-Emoji` to use query cache and indexed search
- Updated `Get-Emoji` to use category index and collection cache
- Updated `Update-EmojiDataset` to invalidate caches on data refresh
- Modified module initialization to build indices on load
- Enhanced module with automatic cache warmup (background job)
- Updated module version to 1.11.0

### Performance
- **10-100x faster searches** for cached queries ⚡
- **15x faster** collection-based searches
- **20x faster** category filtering
- **50x faster** exact word matches
- O(1) lookup performance vs O(n) linear scans

### Documentation
- Added CACHING_GUIDE.md (300+ lines)
  - Complete caching architecture overview
  - Performance benchmarks and statistics
  - Configuration examples and best practices
  - Troubleshooting guide
- Added Test-CachingSystem.ps1 (250+ lines)
  - 10 comprehensive test scenarios
  - Real-world performance benchmarks
  - Automated validation suite

### Technical Details
- Cache storage: Module-scoped hashtables
- Index structure: Inverted indices for O(1) lookups
- Memory usage: ~2-5MB for typical datasets
- Thread safety: Not needed (PowerShell single-threaded)
- Automatic invalidation on dataset changes

## [1.10.0] - 2025-10-30

### Added
- Custom emoji dataset support
  - `Import-CustomEmojiDataset` - Import custom datasets from CSV/JSON
  - `Export-CustomEmojiDataset` - Export datasets with filtering
  - `New-CustomEmojiDataset` - Interactive dataset creator
  - `Get-CustomEmojiDatasetInfo` - Dataset statistics and information
  - `Reset-EmojiDataset` - Reset to Unicode CLDR defaults
- CUSTOM_DATASETS_GUIDE.md - Comprehensive guide (400+ lines)
- COLLECTIONS_GUIDE.md - Complete collections guide (600+ lines)
- Documentation index (INDEX.md) with comprehensive function reference

### Changed
- Updated module version to 1.10.0
- Enhanced documentation structure
- Total functions: 38

## [1.9.0] - 2025-10-29

### Added
- Array-based AutoInitialize configuration
- Enhanced setup system with granular control

### Changed
- Converted AutoInitialize from boolean to array-based configuration
- Improved Get-EmojiToolsInfo display logic
- Updated SETUP_GUIDE.md with array syntax examples

## [1.8.0] - 2025-10-29

### Added
- Emoji aliases and shortcuts system (7 functions)
  - `Get-EmojiAlias` - Retrieve aliases
  - `New-EmojiAlias` - Create custom aliases
  - `Remove-EmojiAlias` - Delete aliases
  - `Set-EmojiAlias` - Update aliases
  - `Initialize-DefaultEmojiAliases` - 71 default aliases
  - `Import-EmojiAliases` - Import from JSON
  - `Export-EmojiAliases` - Export to JSON
- ALIASES_GUIDE.md documentation
- 71 default emoji aliases organized in 10 categories

### Changed
- Updated module to v1.8.0
- Added Example 17 to EXAMPLES.ps1

## [1.7.0] - 2025-10-29

### Added
- Usage statistics tracking (3 functions)
  - `Get-EmojiStats` - View usage statistics
  - `Clear-EmojiStats` - Reset statistics
  - `Export-EmojiStats` - Export to CSV
- Statistics storage in data/stats.json

## [1.6.0] - 2025-10-29

### Added
- Emoji collections system (8 functions)
  - `New-EmojiCollection` - Create collections
  - `Add-EmojiToCollection` - Add emojis
  - `Remove-EmojiFromCollection` - Remove emojis
  - `Get-EmojiCollection` - View collections
  - `Remove-EmojiCollection` - Delete collections
  - `Export-EmojiCollection` - Export to JSON
  - `Import-EmojiCollection` - Import from JSON
  - `Initialize-EmojiCollections` - Create 6 default collections
- ANALYTICS_GUIDE.md documentation

## [1.5.0] - 2025-10-29

### Added
- Clipboard integration functions
  - `Copy-Emoji` - Copy emoji to clipboard
  - `Export-Emoji` - Save emojis to file

## [1.4.0] - 2025-10-29

### Added
- Skin tone modifier support
  - `Get-EmojiWithSkinTone` - Apply skin tone variations
- `Show-EmojiPicker` - Interactive emoji picker
- `Join-Emoji` - Combine multiple emojis

## [1.3.0] - 2025-10-29

### Added
- Auto-update system (4 functions)
  - `Get-EmojiDatasetInfo` - Dataset information
  - `Enable-EmojiAutoUpdate` - Enable auto-updates
  - `Disable-EmojiAutoUpdate` - Disable auto-updates
  - Auto-update checking on module import
- AUTO_UPDATE_GUIDE.md documentation
- Metadata tracking (data/metadata.json)
- Scheduled task support for Windows

### Changed
- Enhanced Update-EmojiDataset with better error handling
- Added dataset age checking

## [1.0.0] - 2025-10-29

### Added
- Initial release
- Core emoji search and retrieval
  - `Get-Emoji` - List and filter emojis
  - `Search-Emoji` - Fuzzy search by keyword
  - `Update-EmojiDataset` - Download emoji data
  - `Emoji` - Safe command dispatcher
- Multi-source dataset support (GitHub, Unicode CLDR, Kaggle)
- Security features (input validation, verb whitelisting)
- Category filtering
- UTF-8 encoding support
- Initial dataset with 1,948+ emojis
- Complete documentation
  - README.md
  - QUICKSTART.md
  - EXAMPLES.ps1
  - PROJECT_SUMMARY.md
  - CHECKLIST.md

---

**Note:** Version comparison links will be added once the project is published to GitHub and releases are tagged.
