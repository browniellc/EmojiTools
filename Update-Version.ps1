<#
.SYNOPSIS
    Updates version numbers across the EmojiTools project.

.DESCRIPTION
    This script updates version numbers in:
    - Module manifest (src/EmojiTools.psd1)
    - CHANGELOG.md (adds new version section)
    - Creates a git tag for the new version

.PARAMETER NewVersion
    The new semantic version number (e.g., "1.18.0")

.PARAMETER ReleaseDate
    The release date in YYYY-MM-DD format. Defaults to today.

.PARAMETER ChangelogNotes
    Path to a file containing changelog notes, or a multiline string of changes.

.PARAMETER SkipGitTag
    If specified, skips creating a git tag for this version.

.EXAMPLE
    .\Update-Version.ps1 -NewVersion "1.18.0"
    Updates to version 1.18.0 with today's date

.EXAMPLE
    .\Update-Version.ps1 -NewVersion "1.18.0" -ReleaseDate "2025-11-09" -ChangelogNotes @"
    ### Added
    - New security validation features

    ### Fixed
    - PSScriptAnalyzer warnings resolved
    "@
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d+\.\d+\.\d+$')]
    [string]$NewVersion,

    [Parameter(Mandatory = $false)]
    [ValidatePattern('^\d{4}-\d{2}-\d{2}$')]
    [string]$ReleaseDate = (Get-Date -Format 'yyyy-MM-dd'),

    [Parameter(Mandatory = $false)]
    [string]$ChangelogNotes,

    [Parameter(Mandatory = $false)]
    [switch]$SkipGitTag
)

$ErrorActionPreference = 'Stop'

# Resolve paths
$scriptRoot = $PSScriptRoot
$manifestPath = Join-Path $scriptRoot "src\EmojiTools.psd1"
$changelogPath = Join-Path $scriptRoot "CHANGELOG.md"

Write-Host "🔄 Updating EmojiTools to version $NewVersion" -ForegroundColor Cyan
Write-Host ""

# 1. Update module manifest
Write-Host "📝 Updating module manifest..." -ForegroundColor Yellow
if (-not (Test-Path $manifestPath)) {
    throw "Module manifest not found at: $manifestPath"
}

$manifestContent = Get-Content $manifestPath -Raw
$oldVersion = if ($manifestContent -match "ModuleVersion\s*=\s*'([^']+)'") { $Matches[1] } else { "unknown" }

Write-Host "   Current version: $oldVersion" -ForegroundColor Gray
Write-Host "   New version: $NewVersion" -ForegroundColor Green

if ($PSCmdlet.ShouldProcess($manifestPath, "Update ModuleVersion to $NewVersion")) {
    $manifestContent = $manifestContent -replace "(ModuleVersion\s*=\s*)'[^']+'", "`$1'$NewVersion'"
    Set-Content -Path $manifestPath -Value $manifestContent -NoNewline -Encoding UTF8
    Write-Host "   ✅ Module manifest updated" -ForegroundColor Green
}

# 2. Update CHANGELOG.md
Write-Host ""
Write-Host "📋 Updating CHANGELOG.md..." -ForegroundColor Yellow

if (-not (Test-Path $changelogPath)) {
    throw "CHANGELOG.md not found at: $changelogPath"
}

$changelogContent = Get-Content $changelogPath -Raw

# Check if version already exists
if ($changelogContent -match "\[${NewVersion}\]") {
    Write-Warning "Version $NewVersion already exists in CHANGELOG.md"
}
else {
    # Prepare changelog entry
    $changelogEntry = @"
## [$NewVersion] - $ReleaseDate

$ChangelogNotes

"@

    if ($PSCmdlet.ShouldProcess($changelogPath, "Add version $NewVersion entry")) {
        # Insert after ## [Unreleased]
        $changelogContent = $changelogContent -replace '(## \[Unreleased\]\s*\n)', "`$1`n$changelogEntry"
        Set-Content -Path $changelogPath -Value $changelogContent -NoNewline -Encoding UTF8
        Write-Host "   ✅ CHANGELOG.md updated" -ForegroundColor Green
    }
}

# 3. Create git tag
if (-not $SkipGitTag) {
    Write-Host ""
    Write-Host "🏷️  Creating git tag..." -ForegroundColor Yellow

    $tagName = "v$NewVersion"
    $tagMessage = "Release version $NewVersion"

    if ($PSCmdlet.ShouldProcess($tagName, "Create git tag")) {
        try {
            # Check if tag already exists
            $existingTag = git tag -l $tagName 2>$null
            if ($existingTag) {
                Write-Warning "Git tag $tagName already exists"
            }
            else {
                git tag -a $tagName -m $tagMessage
                Write-Host "   ✅ Created git tag: $tagName" -ForegroundColor Green
                Write-Host "   💡 Push with: git push origin $tagName" -ForegroundColor Cyan
            }
        }
        catch {
            Write-Warning "Failed to create git tag: $_"
        }
    }
}

# Summary
Write-Host ""
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "✅ Version update complete!" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  Old Version: $oldVersion" -ForegroundColor Gray
Write-Host "  New Version: $NewVersion" -ForegroundColor Green
Write-Host "  Release Date: $ReleaseDate" -ForegroundColor Gray
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Review changes in git: git diff" -ForegroundColor Cyan
Write-Host "  2. Commit changes: git add -A && git commit -m 'Release v$NewVersion'" -ForegroundColor Cyan
if (-not $SkipGitTag) {
    Write-Host "  3. Push tag: git push origin v$NewVersion" -ForegroundColor Cyan
    Write-Host "  4. Push commits: git push origin master" -ForegroundColor Cyan
}
else {
    Write-Host "  3. Push commits: git push origin master" -ForegroundColor Cyan
}
Write-Host ""
