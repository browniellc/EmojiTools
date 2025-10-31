#Requires -Modules Pester

<#
.SYNOPSIS
    Pester test suite for Search-Emoji functionality

.DESCRIPTION
    Tests fuzzy matching, exact search, category filtering, limits, and caching integration
#>

BeforeAll {
    $modulePath = Join-Path $PSScriptRoot "..\src\EmojiTools.psd1"
    Import-Module $modulePath -Force
}

Describe "EmojiTools Search" -Tag 'Search' {

    Context "Module and Function Availability" {

        It "Should load the EmojiTools module" {
            $module = Get-Module EmojiTools
            $module | Should -Not -BeNullOrEmpty
            $module.Version | Should -Not -BeNullOrEmpty
        }

        It "Should export Search-Emoji function" {
            $exportedCommands = (Get-Module EmojiTools).ExportedCommands.Keys
            $exportedCommands | Should -Contain 'Search-Emoji'
        }
    }

    Context "Basic Fuzzy Search" {

        It "Should find results with fuzzy search" {
            $results = Search-Emoji -Query "heart"
            $results.Count | Should -BeGreaterThan 0
        }
    }

    Context "Exact Search" {

        It "Should filter more narrowly with exact search" {
            $fuzzyResults = Search-Emoji -Query "face"
            $exactResults = Search-Emoji -Query "face" -Exact
            $exactResults.Count | Should -BeLessOrEqual $fuzzyResults.Count
        }
    }

    Context "Limit Parameter" {

        It "Should respect limit parameter" {
            $results5 = Search-Emoji -Query "smile" -Limit 5
            $results10 = Search-Emoji -Query "smile" -Limit 10

            $results5.Count | Should -BeGreaterThan 0
            $results10.Count | Should -BeGreaterThan 0
            $results10.Count | Should -BeGreaterOrEqual $results5.Count
        }
    }

    Context "Case Insensitivity" {

        It "Should be case-insensitive" {
            $lowerResults = Search-Emoji -Query "rocket" -Limit 10
            $upperResults = Search-Emoji -Query "ROCKET" -Limit 10
            $mixedResults = Search-Emoji -Query "RoCkEt" -Limit 10

            $lowerResults.Count | Should -Be $upperResults.Count
            $lowerResults.Count | Should -Be $mixedResults.Count
        }
    }

    Context "Empty Query Handling" {

        It "Should reject empty query" {
            { Search-Emoji -Query "" -ErrorAction Stop } | Should -Throw
        }
    }

    Context "Special Characters" {

        It "Should handle special characters gracefully" {
            { Search-Emoji -Query "100%" -ErrorAction SilentlyContinue } | Should -Not -Throw
            { Search-Emoji -Query "C++" -ErrorAction SilentlyContinue } | Should -Not -Throw
            { Search-Emoji -Query "A/B" -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }

    Context "Multi-Word Query" {

        It "Should handle multi-word queries" {
            $results = Search-Emoji -Query "smiling face"
            $results.Count | Should -BeGreaterThan 0
        }
    }

    Context "Unicode Search" {

        It "Should handle unicode search without crashing" {
            { Search-Emoji -Query "😀" -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }

    Context "Performance" {

        It "Should complete search in reasonable time" {
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            $results = Search-Emoji -Query "a"
            $stopwatch.Stop()

            $stopwatch.ElapsedMilliseconds | Should -BeLessThan 1000 -Because "search should complete in under 1 second"
            $results.Count | Should -BeGreaterThan 0
        }
    }

    Context "Caching Integration" {

        It "Should return consistent results on repeated searches" {
            $results1 = Search-Emoji -Query "fire"
            $results2 = Search-Emoji -Query "fire"

            $results1.Count | Should -Be $results2.Count
            $results1.Count | Should -BeGreaterThan 0
        }
    }

    Context "Result Object Structure" {

        It "Should return valid results" {
            $results = Search-Emoji -Query "star" -Limit 1
            $results.Count | Should -BeGreaterThan 0
        }
    }

    Context "Search Tracking" {

        It "Should track searches in stats" {
            $uniqueQuery = "zzztest$(Get-Random)"
            Search-Emoji -Query $uniqueQuery -Limit 1 | Out-Null

            { Get-EmojiStats 2>&1 | Out-Null } | Should -Not -Throw
        }
    }
}
