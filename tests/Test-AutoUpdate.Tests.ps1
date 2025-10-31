#Requires -Modules Pester

<#
.SYNOPSIS
    Pester test suite for Auto-Update functionality

.DESCRIPTION
    Tests Enable/Disable auto-update, scheduled task management, and update intervals
#>

BeforeAll {
    $modulePath = Join-Path $PSScriptRoot "..\src\EmojiTools.psd1"
    Import-Module $modulePath -Force
}

Describe "EmojiTools Auto-Update" -Tag 'AutoUpdate' {

    Context "Module and Function Availability" {

        It "Should load the EmojiTools module" {
            $module = Get-Module EmojiTools
            $module | Should -Not -BeNullOrEmpty
            $module.Version | Should -Not -BeNullOrEmpty
        }

        It "Should export auto-update functions" {
            $exportedCommands = (Get-Module EmojiTools).ExportedCommands.Keys
            $exportedCommands | Should -Contain 'Enable-EmojiAutoUpdate'
            $exportedCommands | Should -Contain 'Disable-EmojiAutoUpdate'
        }
    }

    Context "Disable Auto-Update" {

        It "Should disable auto-update without error" {
            { Disable-EmojiAutoUpdate 2>&1 | Out-Null } | Should -Not -Throw
        }
    }

    Context "Enable Auto-Update with Different Intervals" {

        It "Should enable auto-update with 7 day interval" {
            { Enable-EmojiAutoUpdate -Interval 7 2>&1 | Out-Null } | Should -Not -Throw
        }

        It "Should enable auto-update with 30 day interval" {
            { Enable-EmojiAutoUpdate -Interval 30 2>&1 | Out-Null } | Should -Not -Throw
        }

        It "Should enable auto-update with 1 day interval" {
            { Enable-EmojiAutoUpdate -Interval 1 2>&1 | Out-Null } | Should -Not -Throw
        }
    }

    Context "Disable After Enable" {

        It "Should disable after enabling" {
            Enable-EmojiAutoUpdate -Interval 7 2>&1 | Out-Null
            { Disable-EmojiAutoUpdate 2>&1 | Out-Null } | Should -Not -Throw
        }
    }
}
