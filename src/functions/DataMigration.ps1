function Get-EmojiToolsDataPath {
    <#
    .SYNOPSIS
        Gets the version-independent data directory path for EmojiTools.

    .DESCRIPTION
        Returns the path where EmojiTools stores user data (history, collections, aliases, stats).
        This path is version-independent and persists across module upgrades.

        Priority:
        1. Environment variable: $env:EMOJITOOLS_DATA_PATH
        2. Windows: $env:LOCALAPPDATA\EmojiTools
        3. Cross-platform fallback: $HOME\.emojitools

    .EXAMPLE
        Get-EmojiToolsDataPath
        Returns the data directory path (e.g., C:\Users\username\AppData\Local\EmojiTools)

    .OUTPUTS
        String - The full path to the data directory
    #>
    [CmdletBinding()]
    param()

    # Allow override via environment variable
    if ($env:EMOJITOOLS_DATA_PATH) {
        return $env:EMOJITOOLS_DATA_PATH
    }

    # Windows: Use LocalAppData
    if ($IsWindows -or $env:OS -match 'Windows') {
        if ($env:LOCALAPPDATA) {
            return Join-Path $env:LOCALAPPDATA "EmojiTools"
        }
    }

    # Cross-platform fallback: Use home directory
    return Join-Path $HOME ".emojitools"
}

function Initialize-EmojiToolsDataDirectory {
    <#
    .SYNOPSIS
        Initializes the EmojiTools data directory structure.

    .DESCRIPTION
        Creates the version-independent data directory and required subdirectories.
        Automatically migrates data from module-embedded location if this is a first run.

    .PARAMETER Force
        Force re-initialization even if directory already exists

    .EXAMPLE
        Initialize-EmojiToolsDataDirectory
        Creates the data directory structure

    .OUTPUTS
        String - The path to the initialized data directory
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Force
    )

    $dataPath = Get-EmojiToolsDataPath

    # Create directory if it doesn't exist
    if (-not (Test-Path $dataPath)) {
        Write-Verbose "Creating EmojiTools data directory: $dataPath"
        New-Item -ItemType Directory -Path $dataPath -Force | Out-Null
    }

    # Create subdirectories
    $subdirs = @('languages')
    foreach ($subdir in $subdirs) {
        $subdirPath = Join-Path $dataPath $subdir
        if (-not (Test-Path $subdirPath)) {
            Write-Verbose "Creating subdirectory: $subdirPath"
            New-Item -ItemType Directory -Path $subdirPath -Force | Out-Null
        }
    }

    # Check if migration is needed (first run after upgrade)
    $migrationMarker = Join-Path $dataPath ".migrated"
    $moduleDataPath = Join-Path $PSScriptRoot "..\data"

    if (-not (Test-Path $migrationMarker) -or $Force) {
        Write-Verbose "Checking for data migration from module directory..."
        Invoke-EmojiDataMigration -SourcePath $moduleDataPath -DestinationPath $dataPath -Force:$Force

        # Create migration marker with millisecond precision for Force re-migration detection
        "Migrated from module directory on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')" |
            Set-Content $migrationMarker -Encoding UTF8
    }

    return $dataPath
}

function Invoke-EmojiDataMigration {
    <#
    .SYNOPSIS
        Migrates user data from module directory to version-independent location.

    .DESCRIPTION
        Copies user-specific data files (history, collections, aliases, stats) from the
        module's data directory to the version-independent data directory. This preserves
        user data during module upgrades.

        Files migrated:
        - history.json (usage history)
        - collections.json (custom collections)
        - aliases.json (custom aliases)
        - stats.json (usage statistics)
        - emoji.csv (cached dataset)
        - metadata.json (dataset metadata)
        - languages/* (installed language packs)

    .PARAMETER SourcePath
        Source directory (typically module's data directory)

    .PARAMETER DestinationPath
        Destination directory (version-independent data path)

    .PARAMETER Force
        Overwrite existing files in destination

    .EXAMPLE
        Invoke-EmojiDataMigration -SourcePath "C:\...\Modules\EmojiTools\1.15.0\data" -DestinationPath "C:\Users\...\AppData\Local\EmojiTools"
        Migrates data from old location to new location
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SourcePath,

        [Parameter(Mandatory)]
        [string]$DestinationPath,

        [Parameter()]
        [switch]$Force
    )

    if (-not (Test-Path $SourcePath)) {
        Write-Verbose "Source path does not exist: $SourcePath"
        return
    }

    # Files to migrate (only if they exist in source)
    $filesToMigrate = @(
        'history.json',
        'collections.json',
        'aliases.json',
        'stats.json',
        'emoji.csv',
        'metadata.json',
        '.setup-complete'
    )

    $migratedFiles = @()
    $skippedFiles = @()

    foreach ($file in $filesToMigrate) {
        $sourceFilePath = Join-Path $SourcePath $file
        $destFilePath = Join-Path $DestinationPath $file

        if (Test-Path $sourceFilePath) {
            # Skip if destination exists and Force not specified
            if ((Test-Path $destFilePath) -and -not $Force) {
                Write-Verbose "Skipping $file (already exists in destination)"
                $skippedFiles += $file
                continue
            }

            try {
                Copy-Item -Path $sourceFilePath -Destination $destFilePath -Force
                $migratedFiles += $file
                Write-Verbose "Migrated: $file"
            }
            catch {
                Write-Warning "Failed to migrate ${file}: $_"
            }
        }
    }

    # Migrate language packs
    $sourceLangPath = Join-Path $SourcePath "languages"
    $destLangPath = Join-Path $DestinationPath "languages"

    if (Test-Path $sourceLangPath) {
        if (-not (Test-Path $destLangPath)) {
            New-Item -ItemType Directory -Path $destLangPath -Force | Out-Null
        }

        $langDirs = Get-ChildItem -Path $sourceLangPath -Directory
        foreach ($langDir in $langDirs) {
            $destLangDir = Join-Path $destLangPath $langDir.Name

            if ((Test-Path $destLangDir) -and -not $Force) {
                Write-Verbose "Skipping language pack: $($langDir.Name) (already exists)"
                continue
            }

            try {
                # Remove existing directory if Force is specified
                if ((Test-Path $destLangDir) -and $Force) {
                    Remove-Item -Path $destLangDir -Recurse -Force
                }

                Copy-Item -Path $langDir.FullName -Destination $destLangDir -Recurse -Force
                $migratedFiles += "languages/$($langDir.Name)"
                Write-Verbose "Migrated language pack: $($langDir.Name)"
            }
            catch {
                Write-Warning "Failed to migrate language pack ${langDir.Name}: $_"
            }
        }
    }

    # Report results
    if ($migratedFiles.Count -gt 0) {
        Write-Information "📦 Migrated $($migratedFiles.Count) file(s) to version-independent data directory:"
        Write-Information "   $DestinationPath"
        if ($VerbosePreference -eq 'Continue') {
            $migratedFiles | ForEach-Object { Write-Verbose "   ✓ $_" }
        }
    }

    if ($skippedFiles.Count -gt 0) {
        Write-Verbose "Skipped $($skippedFiles.Count) existing file(s)"
    }
}
