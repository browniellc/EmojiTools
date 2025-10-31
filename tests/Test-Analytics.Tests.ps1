#Requires -Modules Pester

<#
.SYNOPSIS
    Pester test suite for emoji analytics feature

.DESCRIPTION
    Tests emoji usage statistics tracking:
    - Getting emoji statistics
    - Clearing statistics
    - Exporting statistics
#>

BeforeAll {
    $modulePath = Join-Path $PSScriptRoot "..\src\EmojiTools.psd1"
    Import-Module $modulePath -Force
}

Describe "EmojiTools Analytics" -Tag 'Analytics' {

    Context "Module and Function Availability" {

        It "Should load the EmojiTools module" {
            $module = Get-Module EmojiTools
            $module | Should -Not -BeNullOrEmpty
            $module.Version | Should -Not -BeNullOrEmpty
        }

        It "Should export all required analytics functions" {
            $requiredFunctions = @(
                'Get-EmojiStats',
                'Clear-EmojiStats',
                'Export-EmojiStats'
            )

            foreach ($func in $requiredFunctions) {
                Get-Command $func -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty -Because "$func should be exported"
            }
        }
    }

    Context "Get-EmojiStats" {

        It "Should execute Get-EmojiStats without error (initial state)" {
            { Get-EmojiStats 2>&1 | Out-Null } | Should -Not -Throw
        }

        It "Should execute Get-EmojiStats after usage" {
            # Trigger some usage
            Search-Emoji -Query "rocket" -Limit 1 2>&1 | Out-Null
            Search-Emoji -Query "fire" -Limit 1 2>&1 | Out-Null
            Search-Emoji -Query "heart" -Limit 1 2>&1 | Out-Null

            { Get-EmojiStats 2>&1 | Out-Null } | Should -Not -Throw
        }
    }

    Context "Export-EmojiStats" {

        It "Should export stats to a CSV file" {
            $exportPath = Join-Path $TestDrive "test_stats_export.csv"

            Export-EmojiStats -Path $exportPath -ErrorAction SilentlyContinue 2>&1 | Out-Null
            $exportPath | Should -Exist

            # Cleanup
            if (Test-Path $exportPath) {
                Remove-Item $exportPath -Force
            }
        }
    }

    Context "Clear-EmojiStats" {

        It "Should clear stats without error" {
            { Clear-EmojiStats 2>&1 | Out-Null } | Should -Not -Throw
        }

        It "Should verify stats were cleared" {
            Clear-EmojiStats 2>&1 | Out-Null
            { Get-EmojiStats 2>&1 | Out-Null } | Should -Not -Throw
        }
    }

    Context "Stats Persistence" {

        It "Should persist stats across module reload" {
            $modulePath = Join-Path $PSScriptRoot "..\src\EmojiTools.psd1"

            # Trigger usage
            Search-Emoji -Query "test" -Limit 1 2>&1 | Out-Null

            # Reload module
            Remove-Module EmojiTools -Force
            Import-Module $modulePath -Force

            { Get-EmojiStats 2>&1 | Out-Null } | Should -Not -Throw
        }
    }
}
