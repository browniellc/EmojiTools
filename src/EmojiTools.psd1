@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'EmojiTools.psm1'

    # Version number of this module.
    ModuleVersion = '1.15.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Core')

    # ID used to uniquely identify this module
    GUID = 'e8a4f9c2-3d5b-4e7a-9f1c-2b8d6e3a5c7f'

    # Author of this module
    Author = 'Jeremy Brown'

    # Company or vendor of this module
    CompanyName = 'Brownie, LLC'

    # Copyright statement for this module
    Copyright = '(c) 2025. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'EmojiTools provides powerful emoji search and management capabilities with local dataset caching, fuzzy search, and safe command dispatching.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '7.0'

    # Functions to export from this module
    FunctionsToExport = @(
        'Get-Emoji',
        'Search-Emoji',
        'Update-EmojiDataset',
        'Copy-Emoji',
        'Get-EmojiWithSkinTone',
        'Export-Emoji',
        'Show-EmojiPicker',
        'Join-Emoji',
        'New-EmojiCollection',
        'Add-EmojiToCollection',
        'Remove-EmojiFromCollection',
        'Get-EmojiCollection',
        'Remove-EmojiCollection',
        'Export-EmojiCollection',
        'Import-EmojiCollection',
        'Initialize-EmojiCollections',
        'Get-EmojiStats',
        'Clear-EmojiStats',
        'Export-EmojiStats',
        'Get-EmojiAlias',
        'New-EmojiAlias',
        'Remove-EmojiAlias',
        'Set-EmojiAlias',
        'Initialize-DefaultEmojiAliases',
        'Import-EmojiAliases',
        'Export-EmojiAliases',
        'Initialize-EmojiTools',
        'Reset-EmojiTools',
        'Get-EmojiToolsInfo',
        'Import-CustomEmojiDataset',
        'Export-CustomEmojiDataset',
        'New-CustomEmojiDataset',
        'Get-CustomEmojiDatasetInfo',
        'Reset-EmojiDataset',
        'Emoji',
        'Get-EmojiDatasetInfo',
        'Enable-EmojiAutoUpdate',
        'Disable-EmojiAutoUpdate',
        'Clear-EmojiCache',
        'Get-EmojiCacheStats',
        'Set-EmojiCacheConfig',
        'Get-EmojiCacheConfig',
        'Start-EmojiCacheWarmup',
        'Get-EmojiUpdateHistory',
        'Get-NewEmojis',
        'Get-RemovedEmojis',
        'Export-EmojiHistory',
        'Clear-EmojiHistory',
        'Register-EmojiSource',
        'Unregister-EmojiSource',
        'Get-EmojiSource',
        'Get-EmojiLanguage',
        'Set-EmojiLanguage',
        'Install-EmojiLanguage',
        'Uninstall-EmojiLanguage',
        'New-EmojiScheduledTask',
        'Remove-EmojiScheduledTask',
        'Test-EmojiScheduledTask',
        'Get-EmojiPlatform'
    )

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData = @{
        PSData = @{
            # Tags applied to this module to help with module discovery
            Tags = @('Emoji', 'Unicode', 'Search', 'Text', 'Utility', 'CLDR', 'Cross-Platform', 'PSEdition_Core', 'Clipboard', 'Picker')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/browniellc/EmojiTools/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/browniellc/EmojiTools'

            # A URL to an icon representing this module.
            IconUri = 'https://raw.githubusercontent.com/browniellc/EmojiTools/master/EmojiTools.png'

            # A URL to the help documentation for this module.
            HelpInfoUri = 'https://github.com/browniellc/EmojiTools/blob/master/docs/INDEX.md'

            # ReleaseNotes of this module
            ReleaseNotes = @'
# Version 1.11.0 (2025-10-30)
- 🚀 High-Performance Caching System (Phase 1-3 Complete!)
- ⚡ Query Result Cache with LRU eviction and configurable TTL
- 📊 Search Indices (name, keyword, category) for O(1) lookups
- 💾 Collection Cache with automatic invalidation
- 🎯 Cache warmup with popular queries
- 📈 Configurable cache settings (size, TTL, behavior)
- 📉 Cache statistics and monitoring (Get-EmojiCacheStats)
- 🔧 Clear-EmojiCache, Set-EmojiCacheConfig, Get-EmojiCacheConfig
- ⚡ 10-100x performance improvement for searches
- 🔄 Automatic cache invalidation on dataset updates
- 📚 New Cache.ps1 module with comprehensive caching functions

# Version 1.1.0 (2025-10-29)
- 🎉 Unicode CLDR integration (1,948 emojis!)
- ✅ Auto-update checks on module load
- ✅ Get-EmojiDatasetInfo function
- ✅ Enable-EmojiAutoUpdate function
- ✅ Disable-EmojiAutoUpdate function
- ✅ Scheduled task support (Windows)
- ✅ Silent update mode
- ✅ Metadata tracking
- 📚 Comprehensive documentation

# Version 1.0.0 (2025-10-29)
- Initial release
- Get-Emoji: List all emojis with optional category filtering
- Search-Emoji: Fuzzy search by name or keyword
- Update-EmojiDataset: Download emoji data from Kaggle, Unicode CLDR, or GitHub
- Emoji: Safe dispatcher function with verb whitelisting and input validation
'@
        }
    }
}
