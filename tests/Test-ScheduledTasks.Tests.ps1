#Requires -Modules Pester

<#
.SYNOPSIS
    Pester test suite for Cross-Platform Scheduled Task functionality

.DESCRIPTION
    Tests scheduled task management across Windows, Linux, and macOS platforms
#>

BeforeAll {
    $modulePath = Join-Path $PSScriptRoot "..\src\EmojiTools.psd1"
    Import-Module $modulePath -Force

    # Store original platform variables for cleanup
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        $script:OriginalIsWindows = $IsWindows
        $script:OriginalIsLinux = $IsLinux
        $script:OriginalIsMacOS = $IsMacOS
    }

    # Store actual platform for conditional testing
    $script:ActualPlatform = if ($PSVersionTable.PSVersion.Major -ge 6) {
        if ($IsWindows) { 'Windows' }
        elseif ($IsLinux) { 'Linux' }
        elseif ($IsMacOS) { 'macOS' }
        else { 'Unknown' }
    }
    else { 'Windows' }
}

Describe "EmojiTools Scheduled Tasks" -Tag 'ScheduledTasks' {

    Context "Platform Detection" {

        It "Should detect valid platform" {
            $platform = Get-EmojiPlatform
            $platform | Should -BeIn @('Windows', 'Linux', 'macOS')
        }

        It "Should return Windows on PS 5.1" -Skip:($PSVersionTable.PSVersion.Major -ge 6) {
            $platform = Get-EmojiPlatform
            $platform | Should -Be 'Windows'
        }
    }

    Context "Function Availability" {

        It "Should export scheduled task functions" {
            $functions = @(
                'New-EmojiScheduledTask',
                'Test-EmojiScheduledTask',
                'Remove-EmojiScheduledTask',
                'Get-EmojiPlatform'
            )

            foreach ($func in $functions) {
                Get-Command $func -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context "Windows Scheduled Task" {

        It "Should support WhatIf parameter" -Skip:($script:ActualPlatform -ne 'Windows') {
            { New-EmojiScheduledTask -Interval 7 -WhatIf } | Should -Not -Throw
        }

        It "Should create Windows scheduled task" -Skip:($script:ActualPlatform -ne 'Windows') {
            $result = New-EmojiScheduledTask -Interval 7
            $result | Should -Be $true

            # Cleanup
            if ($result) {
                Remove-EmojiScheduledTask | Out-Null
            }
        }

        It "Should test for scheduled task existence" -Skip:($script:ActualPlatform -ne 'Windows') {
            New-EmojiScheduledTask -Interval 7 | Out-Null
            $exists = Test-EmojiScheduledTask
            $exists | Should -Be $true

            # Cleanup
            Remove-EmojiScheduledTask | Out-Null
        }

        It "Should remove Windows scheduled task" -Skip:($script:ActualPlatform -ne 'Windows') {
            New-EmojiScheduledTask -Interval 7 | Out-Null
            { Remove-EmojiScheduledTask } | Should -Not -Throw
            $exists = Test-EmojiScheduledTask
            $exists | Should -Be $false
        }
    }

    Context "Linux Cron Task" {

        It "Should support WhatIf for Linux" -Skip:($script:ActualPlatform -ne 'Linux') {
            { New-EmojiScheduledTask -Interval 7 -WhatIf } | Should -Not -Throw
        }

        It "Should create Linux cron task" -Skip:($script:ActualPlatform -ne 'Linux') {
            $result = New-EmojiScheduledTask -Interval 7
            $result | Should -Be $true

            # Cleanup
            if ($result) {
                Remove-EmojiScheduledTask | Out-Null
            }
        }

        It "Should test for cron task existence" -Skip:($script:ActualPlatform -ne 'Linux') {
            New-EmojiScheduledTask -Interval 7 | Out-Null
            $exists = Test-EmojiScheduledTask
            $exists | Should -Be $true

            # Cleanup
            Remove-EmojiScheduledTask | Out-Null
        }

        It "Should remove Linux cron task" -Skip:($script:ActualPlatform -ne 'Linux') {
            New-EmojiScheduledTask -Interval 7 | Out-Null
            { Remove-EmojiScheduledTask } | Should -Not -Throw
            $exists = Test-EmojiScheduledTask
            $exists | Should -Be $false
        }
    }

    Context "macOS Launch Agent" {

        It "Should support WhatIf for macOS" -Skip:($script:ActualPlatform -ne 'macOS') {
            { New-EmojiScheduledTask -Interval 7 -WhatIf } | Should -Not -Throw
        }

        It "Should create macOS launch agent" -Skip:($script:ActualPlatform -ne 'macOS') {
            $result = New-EmojiScheduledTask -Interval 7
            $result | Should -Be $true

            # Cleanup
            if ($result) {
                Remove-EmojiScheduledTask | Out-Null
            }
        }

        It "Should test for launch agent existence" -Skip:($script:ActualPlatform -ne 'macOS') {
            New-EmojiScheduledTask -Interval 7 | Out-Null
            $exists = Test-EmojiScheduledTask
            $exists | Should -Be $true

            # Cleanup
            Remove-EmojiScheduledTask | Out-Null
        }

        It "Should remove macOS launch agent" -Skip:($script:ActualPlatform -ne 'macOS') {
            New-EmojiScheduledTask -Interval 7 | Out-Null
            { Remove-EmojiScheduledTask } | Should -Not -Throw
            $exists = Test-EmojiScheduledTask
            $exists | Should -Be $false
        }
    }

    Context "Interval Validation" {

        It "Should accept valid intervals (1, 7, 14, 30)" -Skip:($script:ActualPlatform -eq 'Unknown') {
            @(1, 7, 14, 30) | ForEach-Object {
                { New-EmojiScheduledTask -Interval $_ -WhatIf } | Should -Not -Throw
            }
        }

        It "Should reject invalid intervals" -Skip:($script:ActualPlatform -eq 'Unknown') {
            { New-EmojiScheduledTask -Interval 0 -ErrorAction Stop } | Should -Throw
        }
    }

    Context "Error Handling" {

        It "Should handle missing task gracefully on Test" -Skip:($script:ActualPlatform -eq 'Unknown') {
            Remove-EmojiScheduledTask -ErrorAction SilentlyContinue | Out-Null
            $exists = Test-EmojiScheduledTask
            $exists | Should -Be $false
        }

        It "Should handle missing task gracefully on Remove" -Skip:($script:ActualPlatform -eq 'Unknown') {
            Remove-EmojiScheduledTask -ErrorAction SilentlyContinue | Out-Null
            { Remove-EmojiScheduledTask -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }
}

AfterAll {
    # Restore platform variables
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        Set-Variable -Name IsWindows -Value $script:OriginalIsWindows -Scope Global -Force
        Set-Variable -Name IsLinux -Value $script:OriginalIsLinux -Scope Global -Force
        Set-Variable -Name IsMacOS -Value $script:OriginalIsMacOS -Scope Global -Force
    }

    # Ensure cleanup
    Remove-EmojiScheduledTask -ErrorAction SilentlyContinue | Out-Null
}
