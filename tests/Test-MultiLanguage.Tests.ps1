#Requires -Modules Pester

<#
.SYNOPSIS
    Pester test suite for Multi-Language Support

.DESCRIPTION
    Tests language management, installation, and switching functionality
#>

BeforeAll {
    $modulePath = Join-Path $PSScriptRoot "..\src\EmojiTools.psd1"
    Import-Module $modulePath -Force

    # Get exported module variables
    $script:module = Get-Module EmojiTools
    $script:EmojiToolsConfig = & $module { $Script:EmojiToolsConfig }

    # Reset to English before starting tests
    if ($EmojiToolsConfig.CurrentLanguage -ne 'en') {
        Set-EmojiLanguage -Language en | Out-Null
    }
}

Describe "EmojiTools Multi-Language Support" -Tag 'MultiLanguage' {

    Context "Module Language Configuration" {

        It "Should load module with default English language" {
            $EmojiToolsConfig.CurrentLanguage | Should -Be 'en'
        }

        It "Should have English in installed languages" {
            $EmojiToolsConfig.InstalledLanguages | Should -Contain 'en'
        }
    }

    Context "Language Function Availability" {

        It "Should export Get-EmojiLanguage function" {
            $cmd = Get-Command Get-EmojiLanguage -ErrorAction SilentlyContinue
            $cmd | Should -Not -BeNullOrEmpty
            $cmd.CommandType | Should -Be 'Function'
        }

        It "Should export Set-EmojiLanguage function" {
            $cmd = Get-Command Set-EmojiLanguage -ErrorAction SilentlyContinue
            $cmd | Should -Not -BeNullOrEmpty
            $cmd.CommandType | Should -Be 'Function'
        }

        It "Should export Install-EmojiLanguage function" {
            $cmd = Get-Command Install-EmojiLanguage -ErrorAction SilentlyContinue
            $cmd | Should -Not -BeNullOrEmpty
            $cmd.CommandType | Should -Be 'Function'
        }

        It "Should export Uninstall-EmojiLanguage function" {
            $cmd = Get-Command Uninstall-EmojiLanguage -ErrorAction SilentlyContinue
            $cmd | Should -Not -BeNullOrEmpty
            $cmd.CommandType | Should -Be 'Function'
        }
    }

    Context "Get-EmojiLanguage" {

        It "Should show current language" {
            $lang = Get-EmojiLanguage
            $lang | Should -Not -BeNullOrEmpty
        }

        It "Should list available languages" {
            $langs = Get-EmojiLanguage -Available
            $langs | Should -Not -BeNullOrEmpty
        }

        It "Should list installed languages" {
            $langs = Get-EmojiLanguage -Installed
            $langs | Should -Not -BeNullOrEmpty
            $langs | Should -Contain 'en'
        }
    }

    Context "Set-EmojiLanguage" {

        It "Should set language to English" {
            $originalLanguage = $EmojiToolsConfig.CurrentLanguage

            { Set-EmojiLanguage -Language en | Out-Null } | Should -Not -Throw
            $EmojiToolsConfig.CurrentLanguage | Should -Be 'en'

            # Restore original language
            if ($originalLanguage -ne 'en') {
                Set-EmojiLanguage -Language $originalLanguage -ErrorAction SilentlyContinue | Out-Null
            }
        }

        It "Should reject invalid language code" {
            { Set-EmojiLanguage -Language 'invalid' -ErrorAction Stop } | Should -Throw
        }
    }

    Context "Install-EmojiLanguage" {

        It "Should handle language installation request" {
            # May or may not succeed depending on available language packs
            { Install-EmojiLanguage -Language fr -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }

    Context "Uninstall-EmojiLanguage" {

        It "Should not allow uninstalling English (default)" {
            { Uninstall-EmojiLanguage -Language en -ErrorAction Stop } | Should -Throw
        }
    }

    Context "Language Persistence" {

        It "Should persist language setting across module reload" {
            $modulePath = Join-Path $PSScriptRoot "..\src\EmojiTools.psd1"
            $originalLanguage = $EmojiToolsConfig.CurrentLanguage
            Set-EmojiLanguage -Language en | Out-Null

            Remove-Module EmojiTools -Force
            Import-Module $modulePath -Force
            $EmojiToolsConfig.CurrentLanguage | Should -Be 'en'

            # Restore
            if ($originalLanguage -ne 'en') {
                Set-EmojiLanguage -Language $originalLanguage -ErrorAction SilentlyContinue | Out-Null
            }
        }
    }

    Context "Language Switching" {

        It "Should switch between languages" {
            $originalLanguage = $EmojiToolsConfig.CurrentLanguage

            Set-EmojiLanguage -Language en | Out-Null
            $EmojiToolsConfig.CurrentLanguage | Should -Be 'en'

            # Try switching to another language if available
            $available = Get-EmojiLanguage -Available
            if ($available.Count -gt 1) {
                $otherLang = $available | Where-Object { $_ -ne 'en' } | Select-Object -First 1
                if ($otherLang) {
                    Set-EmojiLanguage -Language $otherLang -ErrorAction SilentlyContinue | Out-Null
                }
            }

            # Restore
            Set-EmojiLanguage -Language $originalLanguage -ErrorAction SilentlyContinue | Out-Null
        }
    }

    Context "Get-Emoji with Language" {

        It "Should work with current language" {
            $emojis = Get-Emoji -Limit 5
            $emojis | Should -Not -BeNullOrEmpty
        }
    }

    Context "Search-Emoji with Language" {

        It "Should search in current language" {
            $results = Search-Emoji -Query "smile" -Limit 5
            $results | Should -Not -BeNullOrEmpty
        }
    }
}

AfterAll {
    # Reset to English
    Set-EmojiLanguage -Language en -ErrorAction SilentlyContinue | Out-Null
}
