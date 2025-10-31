# Quick script to test PSScriptAnalyzer locally
# This helps verify fixes before pushing to GitHub

Write-Host "`n🔍 Running PSScriptAnalyzer..." -ForegroundColor Cyan

# Check if PSScriptAnalyzer is installed
if (-not (Get-Module -ListAvailable PSScriptAnalyzer)) {
    Write-Host "Installing PSScriptAnalyzer..." -ForegroundColor Yellow
    Install-Module -Name PSScriptAnalyzer -Force -SkipPublisherCheck -Scope CurrentUser
}

Import-Module PSScriptAnalyzer

# Run analyzer
$results = Invoke-ScriptAnalyzer -Path . -Recurse -Settings ./PSScriptAnalyzerSettings.psd1

if ($results) {
    Write-Host "`n❌ Found $($results.Count) issue(s):`n" -ForegroundColor Red

    # Group by file
    $results | Group-Object ScriptName | ForEach-Object {
        Write-Host "`n$($_.Name):" -ForegroundColor Yellow
        $_.Group | Format-Table RuleName, Severity, Line, Message -AutoSize
    }

    # Summary by rule
    Write-Host "`n📊 Summary by Rule:" -ForegroundColor Cyan
    $results | Group-Object RuleName | Sort-Object Count -Descending |
        Format-Table @{L = 'Rule'; E = { $_.Name } }, Count, @{L = 'Severity'; E = { $_.Group[0].Severity } } -AutoSize

    exit 1
} else {
    Write-Host "`n✅ No issues found! All clear!" -ForegroundColor Green
    exit 0
}
