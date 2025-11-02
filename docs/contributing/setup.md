# 🛠️ Development Setup

Set up your development environment to contribute to EmojiTools.

---

## Prerequisites

- **PowerShell:** 7.0 or higher (PowerShell Core)
- **Git:** For cloning and version control
- **Pester:** Testing framework (v5.0+)
- **Editor:** VS Code recommended

---

## Quick Setup

```powershell
# Clone repository
git clone https://github.com/Tsabo/EmojiTools.git
cd EmojiTools

# Install dependencies
Install-Module -Name Pester -MinimumVersion 5.0 -Force
Install-Module -Name PSScriptAnalyzer -Force

# Import module for development
Import-Module .\src\EmojiTools.psd1 -Force

# Run tests
Invoke-Pester .\tests\
```

---

## Project Structure

```
EmojiTools/
├── src/
│   ├── EmojiTools.psd1          # Module manifest
│   ├── EmojiTools.psm1          # Module entry point
│   ├── data/                    # Emoji datasets and configs
│   └── functions/               # All module functions
├── tests/                       # Pester tests
├── docs/                        # Documentation (this site!)
├── examples/                    # Example scripts
└── README.md
```

---

## Development Workflow

### 1. Create a Branch

```bash
# Create feature branch
git checkout -b feature/my-new-feature

# Or bug fix branch
git checkout -b fix/bug-description
```

### 2. Make Changes

Edit files in `src/functions/`:

```powershell
# Edit existing function
code src/functions/Search-Emoji.ps1

# Or create new function
code src/functions/New-Feature.ps1
```

### 3. Test Changes

```powershell
# Reload module
Import-Module .\src\EmojiTools.psd1 -Force

# Test manually
Search-Emoji "test"

# Run automated tests
Invoke-Pester .\tests\ -Output Detailed
```

### 4. Run Code Analysis

```powershell
# Check code quality
Invoke-ScriptAnalyzer -Path .\src\ -Recurse

# Fix common issues
Invoke-ScriptAnalyzer -Path .\src\ -Recurse -Fix
```

### 5. Commit Changes

```bash
# Stage changes
git add .

# Commit with descriptive message
git commit -m "✨ Add new feature for X"

# Push to your fork
git push origin feature/my-new-feature
```

### 6. Create Pull Request

1. Go to GitHub
2. Click "New Pull Request"
3. Select your branch
4. Describe your changes
5. Submit!

---

## Writing Functions

### Function Template

```powershell
function Verb-EmojiNoun {
    <#
    .SYNOPSIS
        Brief description

    .DESCRIPTION
        Detailed description

    .PARAMETER ParameterName
        Parameter description

    .EXAMPLE
        Verb-EmojiNoun -Parameter "value"
        Description of what this example does

    .NOTES
        Additional info
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ParameterName
    )

    # Function logic here
}
```

### Best Practices

1. **Use approved verbs:** Get, Set, New, Remove, etc.
2. **Include help:** Complete comment-based help
3. **Parameter validation:** Use [Parameter()] attributes
4. **Error handling:** Use try/catch for external calls
5. **Return values:** Return objects, not formatted text
6. **Pipeline support:** Add `ValueFromPipeline` where appropriate

---

## Writing Tests

### Test Template

```powershell
Describe "Verb-EmojiNoun" {
    BeforeAll {
        # Setup
        Import-Module .\src\EmojiTools.psd1 -Force
    }

    Context "When parameter is valid" {
        It "Should return expected result" {
            $result = Verb-EmojiNoun -Parameter "value"
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context "When parameter is invalid" {
        It "Should throw error" {
            { Verb-EmojiNoun -Parameter "" } | Should -Throw
        }
    }
}
```

### Running Tests

```powershell
# Run all tests
Invoke-Pester .\tests\

# Run specific test file
Invoke-Pester .\tests\Test-Search.Tests.ps1

# Run with coverage
Invoke-Pester .\tests\ -CodeCoverage .\src\functions\*.ps1

# Run in CI mode
Invoke-Pester .\tests\ -CI
```

---

## Documentation

### Update Help

When adding/modifying functions, update:

1. **Comment-based help** in the function
2. **Documentation pages** in `docs/`
3. **Examples** in `examples/EXAMPLES.ps1`
4. **README.md** if adding major features

### Build Documentation

```powershell
# Install MkDocs
pip install -r docs-requirements.txt

# Serve locally
python -m mkdocs serve

# Build site
python -m mkdocs build
```

---

## Code Style

### Follow PowerShell Best Practices

- Use PascalCase for functions and parameters
- Use camelCase for variables
- Indent with 4 spaces
- Max line length: 115 characters
- Add comments for complex logic

### Example

```powershell
function Get-EmojiExample {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SearchTerm,

        [Parameter(Mandatory = $false)]
        [int]$Limit = 10
    )

    # Load emoji data
    $dataPath = Join-Path $PSScriptRoot "..\data\emoji.csv"
    $emojis = Import-Csv -Path $dataPath -Encoding UTF8

    # Filter and return
    $emojis | Where-Object { $_.name -match $SearchTerm } |
        Select-Object -First $Limit
}
```

---

## Debugging

### VS Code

1. Install PowerShell extension
2. Open `.vscode/launch.json`:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "PowerShell: Debug Script",
            "type": "PowerShell",
            "request": "launch",
            "script": "${file}"
        }
    ]
}
```

3. Set breakpoints (F9)
4. Press F5 to debug

### PowerShell ISE

```powershell
# Set breakpoint
Set-PSBreakpoint -Script .\src\functions\Search-Emoji.ps1 -Line 50

# Run script
Search-Emoji "test"

# Remove breakpoint
Get-PSBreakpoint | Remove-PSBreakpoint
```

---

## Common Tasks

### Add New Function

```powershell
# 1. Create function file
New-Item -Path .\src\functions\New-MyFunction.ps1

# 2. Add to module (if needed)
# Edit src/EmojiTools.psm1 to dot-source new function

# 3. Create test file
New-Item -Path .\tests\Test-MyFunction.Tests.ps1

# 4. Update docs
# Add to docs/reference/commands.md
```

### Update Dataset Format

If you need to modify the emoji.csv structure:

1. Update parsing in `Update-EmojiDataset.ps1`
2. Update all functions that read emoji.csv
3. Update tests
4. Provide migration script for existing users

---

## Release Process

Maintainers only:

1. Update version in `src/EmojiTools.psd1`
2. Update `CHANGELOG.md`
3. Run all tests
4. Create Git tag
5. Publish to PowerShell Gallery
6. Deploy documentation

---

## Getting Help

- **Questions?** Open a [Discussion](https://github.com/Tsabo/EmojiTools/discussions)
- **Bug?** Open an [Issue](https://github.com/Tsabo/EmojiTools/issues)
- **Want to contribute?** Read [CONTRIBUTING.md](https://github.com/Tsabo/EmojiTools/blob/master/CONTRIBUTING.md)

---

<div align="center" markdown>

**Next:** Check out the [testing strategy](testing.md) | [Back to docs](../index.md)

</div>
