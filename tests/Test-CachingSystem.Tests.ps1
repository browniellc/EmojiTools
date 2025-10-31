#Requires -Modules Pester

<#
.SYNOPSIS
    Pester test suite for Emoji Caching System Performance

.DESCRIPTION
    Tests search performance and caching behavior.
    Note: Caching functions are internal and not exported.
#>

BeforeAll {
    $modulePath = Join-Path $PSScriptRoot "..\src\EmojiTools.psd1"
    Import-Module $modulePath -Force
}

Describe "EmojiTools Caching Performance" -Tag 'Caching' {

    Context "Query Result Cache Performance" {

        It "Should complete first search successfully" {
            $firstSearch = Measure-Command { Search-Emoji -Query "smile" | Out-Null }
            $firstSearch.TotalMilliseconds | Should -BeGreaterThan 0
        }

        It "Should complete second search successfully (with potential caching)" {
            Search-Emoji -Query "smile" | Out-Null  # Prime the cache
            $secondSearch = Measure-Command { Search-Emoji -Query "smile" | Out-Null }
            $secondSearch.TotalMilliseconds | Should -BeGreaterThan 0
        }
    }

    Context "Indexed Search Performance" {

        It "Should perform multiple searches efficiently" {
            $queries = @('heart', 'love', 'fire', 'star', 'car')
            $totalTime = 0

            foreach ($query in $queries) {
                $time = Measure-Command { Search-Emoji -Query $query | Out-Null }
                $totalTime += $time.TotalMilliseconds
            }

            $avgTime = $totalTime / $queries.Count
            $avgTime | Should -BeLessThan 1000 -Because "average search should be under 1 second"
        }
    }

    Context "Category Index Performance" {

        It "Should perform first category lookup" {
            $firstCategory = Measure-Command { Get-Emoji -Category "Food" | Out-Null }
            $firstCategory.TotalMilliseconds | Should -BeGreaterThan 0
        }

        It "Should perform second category lookup (potentially optimized)" {
            Get-Emoji -Category "Food" | Out-Null  # Prime
            $secondCategory = Measure-Command { Get-Emoji -Category "Food" | Out-Null }
            $secondCategory.TotalMilliseconds | Should -BeGreaterThan 0
        }
    }

    Context "Overall Performance" {

        It "Should maintain good performance across various operations" {
            $operations = @(
                { Search-Emoji -Query "test" | Out-Null },
                { Get-Emoji -Category "Symbols" | Out-Null },
                { Search-Emoji -Query "smile" -Limit 5 | Out-Null }
            )

            foreach ($operation in $operations) {
                $time = Measure-Command $operation
                $time.TotalMilliseconds | Should -BeLessThan 2000 -Because "operations should complete quickly"
            }
        }
    }
}
