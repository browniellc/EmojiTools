#Requires -Modules Pester

<#
.SYNOPSIS
    Pester test suite for Custom Emoji Sources

.DESCRIPTION
    Tests Register/Unregister-EmojiSource, Get-EmojiSource, and Update-EmojiDataset with custom sources
#>

BeforeAll {
    $modulePath = Join-Path $PSScriptRoot "..\src\EmojiTools.psd1"
    Import-Module $modulePath -Force

    # Backup existing sources if present
    $sourcesPath = Join-Path $PSScriptRoot "..\src\data\sources.json"
    $backupPath = "$sourcesPath.backup"
    if (Test-Path $sourcesPath) {
        Copy-Item $sourcesPath $backupPath -Force
    }
}

Describe "EmojiTools Custom Sources" -Tag 'CustomSources' {

    Context "Module and Function Availability" {

        It "Should load the EmojiTools module" {
            $module = Get-Module EmojiTools
            $module | Should -Not -BeNullOrEmpty
            $module.Version | Should -Not -BeNullOrEmpty
        }

        It "Should export custom source functions" {
            $functions = Get-Command -Module EmojiTools -Name Register-EmojiSource, Unregister-EmojiSource, Get-EmojiSource -ErrorAction SilentlyContinue
            $functions.Count | Should -Be 3
        }
    }

    Context "Get-EmojiSource" {

        It "Should list built-in sources" {
            $sources = Get-EmojiSource
            $builtIn = $sources | Where-Object { $_.Type -eq 'Built-in' }
            $builtIn.Count | Should -BeGreaterOrEqual 1
        }
    }

    Context "Register-EmojiSource" {

        AfterEach {
            Unregister-EmojiSource -Name "TestCSV" -Confirm:$false -ErrorAction SilentlyContinue
            Unregister-EmojiSource -Name "TestJSON" -Confirm:$false -ErrorAction SilentlyContinue
            Unregister-EmojiSource -Name "AutoCSV" -Confirm:$false -ErrorAction SilentlyContinue
        }

        It "Should register a valid CSV source" {
            Register-EmojiSource -Name "TestCSV" -Url "https://example.com/emojis.csv" -Format CSV -Description "Test CSV source" -ErrorAction SilentlyContinue
            $source = Get-EmojiSource -Name "TestCSV"
            $source | Should -Not -BeNullOrEmpty
            $source.Name | Should -Be "TestCSV"
            $source.Format | Should -Be "CSV"
        }

        It "Should register a valid JSON source" {
            Register-EmojiSource -Name "TestJSON" -Url "https://example.com/emojis.json" -Format JSON -Description "Test JSON source" -ErrorAction SilentlyContinue
            $source = Get-EmojiSource -Name "TestJSON"
            $source | Should -Not -BeNullOrEmpty
            $source.Name | Should -Be "TestJSON"
            $source.Format | Should -Be "JSON"
        }

        It "Should auto-detect CSV format from URL" {
            Register-EmojiSource -Name "AutoCSV" -Url "https://example.com/data.csv" -ErrorAction SilentlyContinue
            $source = Get-EmojiSource -Name "AutoCSV"
            $source | Should -Not -BeNullOrEmpty
            $source.Format | Should -Be "CSV"
        }
    }

    Context "Unregister-EmojiSource" {

        BeforeEach {
            Register-EmojiSource -Name "TestRemove" -Url "https://example.com/test.csv" -Format CSV -ErrorAction SilentlyContinue
        }

        It "Should unregister a custom source" {
            { Unregister-EmojiSource -Name "TestRemove" -Confirm:$false } | Should -Not -Throw
            $source = Get-EmojiSource -Name "TestRemove" -ErrorAction SilentlyContinue
            $source | Should -BeNullOrEmpty
        }
    }

    Context "Source Validation" {

        AfterEach {
            Unregister-EmojiSource -Name "TestValidate" -Confirm:$false -ErrorAction SilentlyContinue
        }

        It "Should validate source URL format" {
            { Register-EmojiSource -Name "TestValidate" -Url "https://example.com/emojis.csv" -Format CSV -ErrorAction Stop } | Should -Not -Throw
        }
    }

    Context "Duplicate Prevention" {

        AfterAll {
            Unregister-EmojiSource -Name "TestDuplicate" -Confirm:$false -ErrorAction SilentlyContinue
        }

        It "Should prevent duplicate source names" {
            Register-EmojiSource -Name "TestDuplicate" -Url "https://example.com/test1.csv" -Format CSV -ErrorAction SilentlyContinue
            { Register-EmojiSource -Name "TestDuplicate" -Url "https://example.com/test2.csv" -Format CSV -ErrorAction Stop } | Should -Throw
        }
    }

    Context "Source Persistence" {

        It "Should persist sources across module reload" {
            $modulePath = Join-Path $PSScriptRoot "..\src\EmojiTools.psd1"
            Register-EmojiSource -Name "TestPersist" -Url "https://example.com/persist.csv" -Format CSV -ErrorAction SilentlyContinue

            Remove-Module EmojiTools -Force
            Import-Module $modulePath -Force

            $source = Get-EmojiSource -Name "TestPersist"
            $source | Should -Not -BeNullOrEmpty

            # Cleanup
            Unregister-EmojiSource -Name "TestPersist" -Confirm:$false -ErrorAction SilentlyContinue
        }
    }

    AfterAll {
        Unregister-EmojiSource -Name "TestPersist" -Confirm:$false -ErrorAction SilentlyContinue
    }
}

AfterAll {
    # Restore backed up sources
    $sourcesPath = Join-Path $PSScriptRoot "..\src\data\sources.json"
    $backupPath = "$sourcesPath.backup"
    if (Test-Path $backupPath) {
        Move-Item $backupPath $sourcesPath -Force
    }

    # Clean up any test sources
    @('TestCSV', 'TestJSON', 'AutoCSV', 'TestRemove', 'TestValidate', 'TestDuplicate', 'TestPersist') | ForEach-Object {
        Unregister-EmojiSource -Name $_ -Confirm:$false -ErrorAction SilentlyContinue
    }
}
