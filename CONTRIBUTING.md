# Contributing to EmojiTools

Thank you for your interest in contributing to EmojiTools! 🎉

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code. Please be respectful and constructive in all interactions.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce**
- **Expected vs actual behavior**
- **PowerShell version** (`$PSVersionTable.PSVersion`)
- **Module version** (`(Get-Module EmojiTools).Version`)
- **Operating system**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear and descriptive title**
- **Provide detailed description** of the suggested enhancement
- **Explain why this enhancement would be useful**
- **List examples** of how it would be used

### Pull Requests

1. **Fork the repo** and create your branch from `master`
2. **Follow PowerShell best practices**:
   - Use approved verbs (`Get-`, `New-`, `Set-`, etc.)
   - Include comment-based help
   - Follow proper parameter naming
3. **Add tests** if adding new features
4. **Update documentation**:
   - Update README.md if needed
   - Add examples to EXAMPLES.ps1
   - Update relevant guides in docs/
5. **Update CHANGELOG.md**
6. **Ensure all tests pass**
7. **Submit the pull request**

## Development Setup

### Prerequisites

- PowerShell 5.1 or higher (PowerShell 7+ recommended)
- Git
- Text editor (VS Code recommended)

### Setup

```powershell
# Clone the repository
git clone https://github.com/browniellc/EmojiTools.git
cd EmojiTools

# Import the module for testing
Import-Module .\EmojiTools.psd1 -Force

# Run tests (if Pester is set up)
Invoke-Pester
```

## Style Guide

### PowerShell Code Style

- **Indentation**: 4 spaces (no tabs)
- **Line length**: Keep under 120 characters when possible
- **Naming**:
  - Functions: `Verb-Noun` format
  - Variables: `$camelCase`
  - Parameters: `$PascalCase`
- **Comments**: Use `#` for single-line, `<# #>` for multi-line
- **Braces**: Opening brace on same line

Example:
```powershell
function Get-Example {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    # Your code here
    Write-Output "Hello, $Name"
}
```

### Documentation Style

- Use Markdown for all documentation
- Include code examples with proper syntax highlighting
- Use emojis sparingly for visual organization
- Keep paragraphs concise

## Testing

- Write tests for new functionality
- Ensure existing tests pass
- Test on both Windows PowerShell 5.1 and PowerShell 7+
- Test cross-platform if possible (Windows, macOS, Linux)

## Commit Messages

- Use clear, descriptive commit messages
- Start with a verb in present tense (Add, Fix, Update, Remove)
- Reference issues when applicable (#123)

Examples:
```
Add support for custom emoji datasets
Fix emoji search case sensitivity issue
Update documentation for collections feature
Remove deprecated function parameter
```

## Questions?

Feel free to open an issue with the "question" label!

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
