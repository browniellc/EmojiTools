#Requires -Modules Pester

<#
.SYNOPSIS
    Pester test suite for emoji aliases feature

.DESCRIPTION
    This script tests all aspects of the emoji aliases system:
    - Creating new aliases
    - Retrieving aliases
    - Updating aliases
    - Removing aliases
    - Importing/exporting aliases
    - Initializing default aliases
#>

BeforeAll {
    $modulePath = Join-Path $PSScriptRoot "..\src\EmojiTools.psd1"
    Import-Module $modulePath -Force
}

Describe "EmojiTools Aliases" -Tag 'Aliases' {

    Context "Module and Function Availability" {

        It "Should load the EmojiTools module" {
            $module = Get-Module EmojiTools
            $module | Should -Not -BeNullOrEmpty
            $module.Version | Should -Not -BeNullOrEmpty
        }

        It "Should export all required alias functions" {
            $requiredFunctions = @(
                'Get-EmojiAlias',
                'New-EmojiAlias',
                'Remove-EmojiAlias',
                'Set-EmojiAlias',
                'Initialize-DefaultEmojiAliases',
                'Import-EmojiAliases',
                'Export-EmojiAliases'
            )

            foreach ($func in $requiredFunctions) {
                Get-Command $func -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty -Because "$func should be exported"
            }
        }
    }

    Context "New-EmojiAlias" {

        BeforeEach {
            Remove-EmojiAlias -Alias "rocket" -Confirm:$false -ErrorAction SilentlyContinue
        }

        It "Should create a new alias successfully" {
            New-EmojiAlias -Alias "rocket" -Emoji "🚀" 2>&1 | Out-Null
            $result = Get-EmojiAlias -Alias "rocket" 2>&1 | Out-String
            $result | Should -Match "🚀"
        }

        AfterEach {
            Remove-EmojiAlias -Alias "rocket" -Confirm:$false -ErrorAction SilentlyContinue
        }
    }

    Context "Get-EmojiAlias" {

        BeforeAll {
            Remove-EmojiAlias -Alias "testget" -Confirm:$false -ErrorAction SilentlyContinue
            New-EmojiAlias -Alias "testget" -Emoji "🎯" 2>&1 | Out-Null
        }

        It "Should retrieve a specific alias" {
            $result = Get-EmojiAlias -Alias "testget" 2>&1 | Out-String
            $result | Should -Match "🎯"
        }

        AfterAll {
            Remove-EmojiAlias -Alias "testget" -Confirm:$false -ErrorAction SilentlyContinue
        }
    }

    Context "Set-EmojiAlias" {

        BeforeAll {
            Remove-EmojiAlias -Alias "testupdate" -Confirm:$false -ErrorAction SilentlyContinue
            New-EmojiAlias -Alias "testupdate" -Emoji "🚀" 2>&1 | Out-Null
        }

        It "Should update an existing alias" {
            Set-EmojiAlias -Alias "testupdate" -Emoji "🛸"
            $updated = Get-EmojiAlias -Alias "testupdate" 2>&1 | Out-String
            $updated | Should -Match "🛸"
        }

        AfterAll {
            Remove-EmojiAlias -Alias "testupdate" -Confirm:$false -ErrorAction SilentlyContinue
        }
    }

    Context "Remove-EmojiAlias" {

        BeforeEach {
            Remove-EmojiAlias -Alias "testremove" -Confirm:$false -ErrorAction SilentlyContinue
            New-EmojiAlias -Alias "testremove" -Emoji "🔥" 2>&1 | Out-Null
        }

        It "Should remove an alias successfully" {
            Remove-EmojiAlias -Alias "testremove" -Confirm:$false 2>&1 | Out-Null
            $checkResult = Get-EmojiAlias -Alias "testremove" -ErrorAction SilentlyContinue 2>&1 | Out-String
            $checkResult | Should -Not -Match "🔥"
        }
    }

    Context "Export-EmojiAliases" {

        It "Should export aliases to a JSON file" {
            $exportPath = Join-Path $TestDrive "test_aliases_export.json"

            Export-EmojiAliases -Path $exportPath
            $exportPath | Should -Exist
            $exportContent = Get-Content $exportPath -Raw | ConvertFrom-Json
            $exportContent.PSObject.Properties.Count | Should -BeGreaterThan 0

            # Cleanup
            if (Test-Path $exportPath) {
                Remove-Item $exportPath -Force
            }
        }
    }

    Context "Import-EmojiAliases" {

        BeforeAll {
            $importPath = Join-Path $TestDrive "test_aliases_import.json"
            $testAliases = @{
                "thumbsup" = "👍"
                "check" = "✅"
                "star" = "⭐"
            }
            $testAliases | ConvertTo-Json | Set-Content $importPath
        }

        It "Should import aliases from a JSON file" {
            Import-EmojiAliases -Path $importPath
            $imported = Get-EmojiAlias -Alias "thumbsup" 2>&1 | Out-String
            $imported | Should -Match "👍"
        }

        AfterAll {
            Remove-EmojiAlias -Alias "thumbsup" -Confirm:$false -ErrorAction SilentlyContinue
            Remove-EmojiAlias -Alias "check" -Confirm:$false -ErrorAction SilentlyContinue
            Remove-EmojiAlias -Alias "star" -Confirm:$false -ErrorAction SilentlyContinue
            if (Test-Path $importPath) {
                Remove-Item $importPath -Force
            }
        }
    }

    Context "Initialize-DefaultEmojiAliases" {

        It "Should initialize default aliases" {
            Initialize-DefaultEmojiAliases 2>&1 | Out-Null

            $rocket = Get-EmojiAlias -Alias "rocket" -ErrorAction SilentlyContinue 2>&1 | Out-String
            $heart = Get-EmojiAlias -Alias "heart" -ErrorAction SilentlyContinue 2>&1 | Out-String
            $smile = Get-EmojiAlias -Alias "smile" -ErrorAction SilentlyContinue 2>&1 | Out-String

            $foundCount = 0
            if ($rocket -match "rocket") { $foundCount++ }
            if ($heart -match "heart") { $foundCount++ }
            if ($smile -match "smile") { $foundCount++ }

            $foundCount | Should -BeGreaterOrEqual 2 -Because "at least 2 of 3 default aliases should exist"
        }
    }

    Context "Alias Persistence" {

        It "Should persist aliases across module reload" {
            $modulePath = Join-Path $PSScriptRoot "..\src\EmojiTools.psd1"

            Remove-EmojiAlias -Alias "testpersist" -Confirm:$false -ErrorAction SilentlyContinue
            New-EmojiAlias -Alias "testpersist" -Emoji "🎯" 2>&1 | Out-Null

            Remove-Module EmojiTools -Force
            Import-Module $modulePath -Force

            $persisted = Get-EmojiAlias -Alias "testpersist" 2>&1 | Out-String
            $persisted | Should -Match "🎯"
        }

        AfterAll {
            Remove-EmojiAlias -Alias "testpersist" -Confirm:$false -ErrorAction SilentlyContinue
        }
    }

    Context "Case Insensitivity" {

        BeforeAll {
            Remove-EmojiAlias -Alias "TestCase" -Confirm:$false -ErrorAction SilentlyContinue
            New-EmojiAlias -Alias "TestCase" -Emoji "🔤" 2>&1 | Out-Null
        }

        It "Should handle case-insensitive alias lookup" {
            $lower = Get-EmojiAlias -Alias "testcase" 2>&1 | Out-String
            $upper = Get-EmojiAlias -Alias "TESTCASE" 2>&1 | Out-String

            $lower | Should -Match "🔤"
            $upper | Should -Match "🔤"
        }

        AfterAll {
            Remove-EmojiAlias -Alias "TestCase" -Confirm:$false -ErrorAction SilentlyContinue
        }
    }

    Context "Duplicate Prevention" {

        BeforeEach {
            Remove-EmojiAlias -Alias "duplicate" -Confirm:$false -ErrorAction SilentlyContinue
        }

        It "Should prevent or handle duplicate aliases" {
            New-EmojiAlias -Alias "duplicate" -Emoji "😀" 2>&1 | Out-Null

            $dupError = $false
            try {
                New-EmojiAlias -Alias "duplicate" -Emoji "😃" -ErrorAction Stop 2>&1 | Out-Null
            }
            catch {
                $dupError = $true
            }

            $result = Get-EmojiAlias -Alias "duplicate" 2>&1 | Out-String
            ($dupError -or ($result -match "😀")) | Should -BeTrue
        }

        AfterEach {
            Remove-EmojiAlias -Alias "duplicate" -Confirm:$false -ErrorAction SilentlyContinue
        }
    }

    Context "Multiple Aliases for Same Emoji" {

        BeforeAll {
            Remove-EmojiAlias -Alias "smile1" -Confirm:$false -ErrorAction SilentlyContinue
            Remove-EmojiAlias -Alias "smile2" -Confirm:$false -ErrorAction SilentlyContinue
            New-EmojiAlias -Alias "smile1" -Emoji "😀" 2>&1 | Out-Null
            New-EmojiAlias -Alias "smile2" -Emoji "😀" 2>&1 | Out-Null
        }

        It "Should support multiple aliases for the same emoji" {
            $emoji1 = Get-EmojiAlias -Alias "smile1" 2>&1 | Out-String
            $emoji2 = Get-EmojiAlias -Alias "smile2" 2>&1 | Out-String

            $emoji1 | Should -Match "😀"
            $emoji2 | Should -Match "😀"
        }

        AfterAll {
            Remove-EmojiAlias -Alias "smile1" -Confirm:$false -ErrorAction SilentlyContinue
            Remove-EmojiAlias -Alias "smile2" -Confirm:$false -ErrorAction SilentlyContinue
        }
    }

    Context "Special Characters in Alias Names" {

        BeforeEach {
            Remove-EmojiAlias -Alias "test_alias_2024" -Confirm:$false -ErrorAction SilentlyContinue
        }

        It "Should support underscores in alias names" {
            New-EmojiAlias -Alias "test_alias_2024" -Emoji "🎨" 2>&1 | Out-Null
            $special = Get-EmojiAlias -Alias "test_alias_2024" 2>&1 | Out-String
            $special | Should -Match "🎨"
        }

        AfterEach {
            Remove-EmojiAlias -Alias "test_alias_2024" -Confirm:$false -ErrorAction SilentlyContinue
        }
    }
}
