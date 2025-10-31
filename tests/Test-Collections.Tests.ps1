#Requires -Modules Pester

<#
.SYNOPSIS
    Pester test suite for emoji collections feature

.DESCRIPTION
    Tests all aspects of the emoji collections system:
    - Creating new collections
    - Adding/removing emojis
    - Retrieving collections
    - Exporting/importing collections
    - Initializing default collections
#>

BeforeAll {
    $modulePath = Join-Path $PSScriptRoot "..\src\EmojiTools.psd1"
    Import-Module $modulePath -Force

    # Clean up test collections
    $testCollectionNames = @('TestCollection1', 'TestCollection2', 'TestImport', 'TestFavorites', 'TestSpecial')
    foreach ($name in $testCollectionNames) {
        Remove-EmojiCollection -Name $name -Confirm:$false -ErrorAction SilentlyContinue
    }
}

Describe "EmojiTools Collections" -Tag 'Collections' {

    Context "Module and Function Availability" {

        It "Should load the EmojiTools module" {
            $module = Get-Module EmojiTools
            $module | Should -Not -BeNullOrEmpty
            $module.Version | Should -Not -BeNullOrEmpty
        }

        It "Should export all required collection functions" {
            $requiredFunctions = @(
                'New-EmojiCollection',
                'Add-EmojiToCollection',
                'Remove-EmojiFromCollection',
                'Get-EmojiCollection',
                'Remove-EmojiCollection',
                'Export-EmojiCollection',
                'Import-EmojiCollection',
                'Initialize-EmojiCollections'
            )

            foreach ($func in $requiredFunctions) {
                Get-Command $func -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty -Because "$func should be exported"
            }
        }
    }

    Context "New-EmojiCollection" {

        AfterEach {
            Remove-EmojiCollection -Name 'TestCollection1' -Confirm:$false -ErrorAction SilentlyContinue
        }

        It "Should create a new collection" {
            { New-EmojiCollection -Name 'TestCollection1' -Description 'Test Collection' } | Should -Not -Throw
            $collection = Get-EmojiCollection -Name 'TestCollection1' 2>&1 | Out-String
            $collection | Should -Match 'TestCollection1'
        }
    }

    Context "Add-EmojiToCollection" {

        BeforeAll {
            Remove-EmojiCollection -Name 'TestAdd' -Confirm:$false -ErrorAction SilentlyContinue
            New-EmojiCollection -Name 'TestAdd' -Description 'Test Add'
        }

        It "Should add emojis to a collection" {
            $testEmojis = @('🚀', '🔥', '💯')
            foreach ($emoji in $testEmojis) {
                { Add-EmojiToCollection -Name 'TestAdd' -Emoji $emoji } | Should -Not -Throw
            }
        }

        AfterAll {
            Remove-EmojiCollection -Name 'TestAdd' -Confirm:$false -ErrorAction SilentlyContinue
        }
    }

    Context "Get-EmojiCollection" {

        BeforeAll {
            Remove-EmojiCollection -Name 'TestGet' -Confirm:$false -ErrorAction SilentlyContinue
            New-EmojiCollection -Name 'TestGet' -Description 'Test Get'
            Add-EmojiToCollection -Name 'TestGet' -Emoji '✅'
        }

        It "Should retrieve a specific collection" {
            $result = Get-EmojiCollection -Name 'TestGet' 2>&1 | Out-String
            $result | Should -Match 'TestGet'
        }

        It "Should list all collections" {
            { Get-EmojiCollection } | Should -Not -Throw
        }

        AfterAll {
            Remove-EmojiCollection -Name 'TestGet' -Confirm:$false -ErrorAction SilentlyContinue
        }
    }

    Context "Remove-EmojiFromCollection" {

        BeforeAll {
            Remove-EmojiCollection -Name 'TestRemove' -Confirm:$false -ErrorAction SilentlyContinue
            New-EmojiCollection -Name 'TestRemove' -Description 'Test Remove'
            Add-EmojiToCollection -Name 'TestRemove' -Emoji '🎯'
        }

        It "Should remove an emoji from collection" {
            { Remove-EmojiFromCollection -Name 'TestRemove' -Emoji '🎯' } | Should -Not -Throw
        }

        AfterAll {
            Remove-EmojiCollection -Name 'TestRemove' -Confirm:$false -ErrorAction SilentlyContinue
        }
    }

    Context "Export-EmojiCollection" {

        It "Should export a collection to JSON" {
            Remove-EmojiCollection -Name 'TestExport' -Confirm:$false -ErrorAction SilentlyContinue
            New-EmojiCollection -Name 'TestExport' -Description 'Test Export'
            Add-EmojiToCollection -Name 'TestExport' -Emoji '📦'
            $exportPath = Join-Path $TestDrive "test_collection_export.json"

            Export-EmojiCollection -Name 'TestExport' -Path $exportPath
            $exportPath | Should -Exist
            $content = Get-Content $exportPath -Raw | ConvertFrom-Json
            $content.Name | Should -Be 'TestExport'

            # Cleanup
            Remove-EmojiCollection -Name 'TestExport' -Confirm:$false -ErrorAction SilentlyContinue
            if (Test-Path $exportPath) {
                Remove-Item $exportPath -Force
            }
        }
    }

    Context "Import-EmojiCollection" {

        BeforeAll {
            $importPath = Join-Path $TestDrive "test_collection_import.json"
            $testCollection = @{
                Name = 'TestImport'
                Description = 'Imported Collection'
                Emojis = @('⭐', '🌟', '✨')
            }
            $testCollection | ConvertTo-Json | Set-Content $importPath
            Remove-EmojiCollection -Name 'TestImport' -Confirm:$false -ErrorAction SilentlyContinue
        }

        It "Should import a collection from JSON" {
            { Import-EmojiCollection -Path $importPath } | Should -Not -Throw
            $result = Get-EmojiCollection -Name 'TestImport' 2>&1 | Out-String
            $result | Should -Match 'TestImport'
        }

        AfterAll {
            Remove-EmojiCollection -Name 'TestImport' -Confirm:$false -ErrorAction SilentlyContinue
            if (Test-Path $importPath) {
                Remove-Item $importPath -Force
            }
        }
    }

    Context "Initialize-EmojiCollections" {

        It "Should initialize default collections" {
            { Initialize-EmojiCollections 2>&1 | Out-Null } | Should -Not -Throw
        }
    }

    Context "Remove-EmojiCollection" {

        BeforeEach {
            Remove-EmojiCollection -Name 'TestDelete' -Confirm:$false -ErrorAction SilentlyContinue
            New-EmojiCollection -Name 'TestDelete' -Description 'Test Delete'
        }

        It "Should remove a collection" {
            { Remove-EmojiCollection -Name 'TestDelete' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context "Duplicate Prevention" {

        BeforeAll {
            Remove-EmojiCollection -Name 'TestDup' -Confirm:$false -ErrorAction SilentlyContinue
        }

        It "Should prevent duplicate collection creation" {
            New-EmojiCollection -Name 'TestDup' -Description 'First'
            { New-EmojiCollection -Name 'TestDup' -Description 'Second' -ErrorAction Stop } | Should -Throw
        }

        AfterAll {
            Remove-EmojiCollection -Name 'TestDup' -Confirm:$false -ErrorAction SilentlyContinue
        }
    }

    Context "Collection Persistence" {

        It "Should persist collections across module reload" {
            $modulePath = Join-Path $PSScriptRoot "..\src\EmojiTools.psd1"
            Remove-EmojiCollection -Name 'TestPersist' -Confirm:$false -ErrorAction SilentlyContinue
            New-EmojiCollection -Name 'TestPersist' -Description 'Persist Test'
            Add-EmojiToCollection -Name 'TestPersist' -Emoji '💾'

            Remove-Module EmojiTools -Force
            Import-Module $modulePath -Force

            $result = Get-EmojiCollection -Name 'TestPersist' 2>&1 | Out-String
            $result | Should -Match 'TestPersist'

            # Cleanup
            Remove-EmojiCollection -Name 'TestPersist' -Confirm:$false -ErrorAction SilentlyContinue
        }
    }

    Context "Error Handling" {

        It "Should handle non-existent collection gracefully" {
            { Get-EmojiCollection -Name 'NonExistent999' -ErrorAction Stop } | Should -Throw
        }
    }

    Context "Special Characters in Collection Names" {

        BeforeEach {
            Remove-EmojiCollection -Name 'Test_Collection_2024' -Confirm:$false -ErrorAction SilentlyContinue
        }

        It "Should support special characters in collection names" {
            { New-EmojiCollection -Name 'Test_Collection_2024' -Description 'Special Chars' } | Should -Not -Throw
        }

        AfterEach {
            Remove-EmojiCollection -Name 'Test_Collection_2024' -Confirm:$false -ErrorAction SilentlyContinue
        }
    }
}

AfterAll {
    # Final cleanup
    $testCollectionNames = @('TestCollection1', 'TestCollection2', 'TestImport', 'TestFavorites', 'TestSpecial', 'TestAdd', 'TestGet', 'TestRemove', 'TestExport', 'TestDelete', 'TestDup', 'TestPersist', 'Test_Collection_2024')
    foreach ($name in $testCollectionNames) {
        Remove-EmojiCollection -Name $name -Confirm:$false -ErrorAction SilentlyContinue
    }
}
