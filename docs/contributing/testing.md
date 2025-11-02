# 🧪 Testing Strategy

Learn how EmojiTools ensures quality through comprehensive testing.

---

## Test Framework

EmojiTools uses **Pester 5.x** for all automated testing.

```powershell
# Install Pester
Install-Module -Name Pester -MinimumVersion 5.0 -Force

# Run all tests
Invoke-Pester .\tests\
```

---

## Test Structure

### Test Files

Each module function has a corresponding test file:

```
tests/
├── Test-Search.Tests.ps1         # Search-Emoji tests
├── Test-Collections.Tests.ps1    # Collection functions
├── Test-Aliases.Tests.ps1        # Alias functions
├── Test-AutoUpdate.Tests.ps1     # Auto-update features
└── Run-AllTests.ps1              # Test runner
```

---

## Running Tests

### All Tests

```powershell
# Run entire test suite
.\tests\Run-AllTests.ps1

# Or use Pester directly
Invoke-Pester .\tests\ -Output Detailed
```

### Specific Tests

```powershell
# Run single test file
Invoke-Pester .\tests\Test-Search.Tests.ps1

# Run specific test
Invoke-Pester .\tests\Test-Search.Tests.ps1 -Tag "Search"
```

### With Code Coverage

```powershell
# Generate coverage report
Invoke-Pester .\tests\ -CodeCoverage .\src\functions\*.ps1

# View coverage
$result = Invoke-Pester .\tests\ -CodeCoverage .\src\functions\*.ps1 -PassThru
$result.CodeCoverage | Format-List
```

---

## Writing Tests

### Basic Test Structure

```powershell
Describe "Function-Name" {
    BeforeAll {
        # Setup (runs once before all tests)
        Import-Module .\src\EmojiTools.psd1 -Force
    }

    BeforeEach {
        # Setup (runs before each test)
    }

    AfterEach {
        # Cleanup (runs after each test)
    }

    AfterAll {
        # Cleanup (runs once after all tests)
    }

    Context "When condition A" {
        It "Should do X" {
            # Test logic
            $result = Function-Name -Parameter "value"
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context "When condition B" {
        It "Should do Y" {
            # Test logic
        }
    }
}
```

### Common Assertions

```powershell
# Value checks
$result | Should -Be "expected"
$result | Should -Not -Be "unexpected"
$result | Should -BeNullOrEmpty
$result | Should -Not -BeNullOrEmpty

# Type checks
$result | Should -BeOfType [string]
$result | Should -BeOfType [System.Collections.ArrayList]

# Collection checks
$array.Count | Should -Be 5
$array | Should -Contain "item"
$array | Should -HaveCount 10

# Error checks
{ Function-Name -Bad "param" } | Should -Throw
{ Function-Name -Bad "param" } | Should -Throw "*specific error*"

# Match checks
$result | Should -Match "pattern"
$result | Should -MatchExactly "Pattern"
```

---

## Test Categories

### Unit Tests

Test individual functions in isolation:

```powershell
Describe "Search-Emoji Unit Tests" {
    It "Should return results for valid query" {
        $results = Search-Emoji "rocket"
        $results | Should -Not -BeNullOrEmpty
        $results[0].emoji | Should -Be "🚀"
    }

    It "Should throw error for empty query" {
        { Search-Emoji "" } | Should -Throw
    }
}
```

### Integration Tests

Test functions working together:

```powershell
Describe "Collection and Export Integration" {
    It "Should create collection and export to file" {
        New-EmojiCollection -Name "TestColl" -Emojis @("🚀","🔥")
        Export-Emoji -Format JSON -Collection "TestColl" -OutputPath ".\test.json"

        Test-Path ".\test.json" | Should -Be $true
        $content = Get-Content ".\test.json" | ConvertFrom-Json
        $content.Count | Should -Be 2
    }
}
```

### End-to-End Tests

Test complete workflows:

```powershell
Describe "Complete User Workflow" {
    It "Should search, create collection, and export" {
        # Search
        $results = Search-Emoji "status"

        # Create collection
        New-EmojiCollection -Name "Status" -Emojis $results[0..2].emoji

        # Export
        Export-Emoji -Format HTML -Collection "Status" -OutputPath ".\status.html"

        # Verify
        Test-Path ".\status.html" | Should -Be $true
    }
}
```

---

## Mock External Dependencies

### Mocking HTTP Calls

```powershell
Describe "Update-EmojiDataset" {
    BeforeAll {
        Mock Invoke-RestMethod {
            return @(
                @{ emoji = "🚀"; name = "rocket" }
                @{ emoji = "🔥"; name = "fire" }
            )
        }
    }

    It "Should download dataset" {
        Update-EmojiDataset -Source Unicode

        Should -Invoke Invoke-RestMethod -Times 1
    }
}
```

### Mocking File Operations

```powershell
Describe "Save-EmojiCollection" {
    BeforeAll {
        Mock Set-Content { }
        Mock Get-Content { return '{}' | ConvertFrom-Json }
    }

    It "Should save collection to file" {
        New-EmojiCollection -Name "Test" -Emojis @("🚀")

        Should -Invoke Set-Content -Times 1
    }
}
```

---

## Test Data

### Using Test Fixtures

```powershell
Describe "Collection Tests" {
    BeforeAll {
        # Create test data
        $script:testEmojis = @(
            [PSCustomObject]@{ emoji = "🚀"; name = "rocket" }
            [PSCustomObject]@{ emoji = "🔥"; name = "fire" }
            [PSCustomObject]@{ emoji = "✅"; name = "check" }
        )
    }

    It "Should filter test data" {
        $filtered = $testEmojis | Where-Object { $_.name -match "rocket" }
        $filtered.Count | Should -Be 1
    }
}
```

---

## Continuous Integration

### GitHub Actions

Tests run automatically on:
- Pull requests
- Pushes to main branch
- Scheduled daily runs

### CI Configuration

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Pester tests
        shell: pwsh
        run: |
          Install-Module -Name Pester -Force
          Invoke-Pester ./tests/ -CI
```

---

## Test Best Practices

### Do's

✅ Test one thing per test
✅ Use descriptive test names
✅ Setup/teardown properly
✅ Mock external dependencies
✅ Test error cases
✅ Keep tests fast
✅ Make tests repeatable

### Don'ts

❌ Test implementation details
❌ Depend on test order
❌ Use hardcoded paths
❌ Skip cleanup
❌ Make network calls
❌ Test multiple things together

---

## Coverage Goals

Target coverage levels:
- **Core functions:** 90%+
- **Utility functions:** 80%+
- **Overall:** 85%+

```powershell
# Check current coverage
$coverage = Invoke-Pester .\tests\ -CodeCoverage .\src\functions\*.ps1 -PassThru
$coverage.CodeCoverage.CoveragePercent
```

---

## Performance Tests

### Benchmark Tests

```powershell
Describe "Search Performance" {
    It "Should search within 100ms" {
        $time = Measure-Command {
            Search-Emoji "rocket"
        }

        $time.TotalMilliseconds | Should -BeLessThan 100
    }
}
```

---

## Debugging Tests

### Run Single Test

```powershell
# Add -Output Detailed for verbose output
Invoke-Pester .\tests\Test-Search.Tests.ps1 -Output Detailed
```

### Debug in VS Code

1. Set breakpoint in test file
2. Open test file
3. Press F5 (Run Pester Tests)
4. Debugger stops at breakpoint

---

## Resources

- [Pester Documentation](https://pester.dev/docs/quick-start)
- [PowerShell Testing Best Practices](https://github.com/pester/Pester/wiki/PowerShell-Testing-Best-Practices)
- [EmojiTools Test Files](https://github.com/Tsabo/EmojiTools/tree/master/tests)

---

<div align="center" markdown>

**Related:** [Development Setup](setup.md) | [Contributing Guide](https://github.com/Tsabo/EmojiTools/blob/master/CONTRIBUTING.md)

</div>
