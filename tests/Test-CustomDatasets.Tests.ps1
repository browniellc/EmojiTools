#Requires -Modules Pester

<#
.SYNOPSIS
    Pester test suite for Custom Dataset functionality

.DESCRIPTION
    Tests Import/Export/New/Get/Reset custom emoji datasets in CSV and JSON formats
#>

BeforeAll {
    $modulePath = Join-Path $PSScriptRoot "..\src\EmojiTools.psd1"
    Import-Module $modulePath -Force
}

Describe "EmojiTools Custom Datasets" -Tag 'CustomDatasets' {

    Context "Module and Function Availability" {

        It "Should load the EmojiTools module" {
            $module = Get-Module EmojiTools
            $module | Should -Not -BeNullOrEmpty
            $module.Version | Should -Not -BeNullOrEmpty
        }

        It "Should export all required dataset functions" {
            $exportedCommands = (Get-Module EmojiTools).ExportedCommands.Keys
            $exportedCommands | Should -Contain 'Import-CustomEmojiDataset'
            $exportedCommands | Should -Contain 'Export-CustomEmojiDataset'
            $exportedCommands | Should -Contain 'New-CustomEmojiDataset'
            $exportedCommands | Should -Contain 'Get-CustomEmojiDatasetInfo'
            $exportedCommands | Should -Contain 'Reset-EmojiDataset'
        }
    }

    Context "Get Dataset Info" {

        It "Should get dataset info without error" {
            { Get-CustomEmojiDatasetInfo 2>&1 | Out-Null } | Should -Not -Throw
        }
    }

    Context "Export Dataset" {

        It "Should export current dataset to CSV" {
            $csvPath = Join-Path $TestDrive "test_dataset_export.csv"
            Export-CustomEmojiDataset -Path $csvPath -Format CSV 2>&1 | Out-Null
            $csvPath | Should -Exist
        }

        It "Should export current dataset to JSON" {
            $jsonPath = Join-Path $TestDrive "test_dataset_export.json"
            Export-CustomEmojiDataset -Path $jsonPath -Format JSON 2>&1 | Out-Null
            $jsonPath | Should -Exist
        }
    }

    Context "Import Dataset" {

        BeforeAll {
            # Create a test CSV dataset
            $csvPath = Join-Path $TestDrive "test_import.csv"
            $testData = @"
Emoji,Name,Category,Subgroup,Keywords,UnicodeVersion
🎯,Direct Hit,Activities,sport,dart;bullseye;target,6.0
🎨,Artist Palette,Objects,art,art;paint;palette,6.0
"@
            $testData | Set-Content $csvPath
        }

        It "Should import dataset from CSV" {
            { Import-CustomEmojiDataset -Path $csvPath -Force 2>&1 | Out-Null } | Should -Not -Throw
        }
    }

    Context "New Custom Dataset" {

        It "Should create new custom dataset from hashtable" {
            $customData = @(
                @{ Emoji = '🚀'; Name = 'Rocket'; Category = 'Transport'; Keywords = 'space;rocket' }
                @{ Emoji = '🔥'; Name = 'Fire'; Category = 'Nature'; Keywords = 'fire;hot' }
            )
            { New-CustomEmojiDataset -Data $customData -Force 2>&1 | Out-Null } | Should -Not -Throw
        }
    }

    Context "Reset Dataset" {

        It "Should reset to default dataset" {
            { Reset-EmojiDataset -Force 2>&1 | Out-Null } | Should -Not -Throw
        }

        It "Should have valid dataset after reset" {
            { Get-Emoji | Select-Object -First 1 } | Should -Not -Throw
        }
    }

    Context "Dataset Validation" {

        It "Should validate imported dataset" {
            $emojis = Get-Emoji
            $emojis | Should -Not -BeNullOrEmpty
            $emojis.Count | Should -BeGreaterThan 0
        }
    }
}

AfterAll {
    # Ensure dataset is reset to default state
    Reset-EmojiDataset -Force -ErrorAction SilentlyContinue 2>&1 | Out-Null
}
