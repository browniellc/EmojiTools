# Pull Request

## Description
Please include a summary of the changes and which issue is fixed. Include relevant motivation and context.

Fixes # (issue)

## Type of Change
Please delete options that are not relevant:

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Code refactoring
- [ ] Tests addition/update

## Changes Made
List the specific changes made in this PR:

- [ ] Added/modified function: `Function-Name`
- [ ] Updated documentation
- [ ] Added tests
- [ ] Updated CHANGELOG.md
- [ ] Other: [describe]

## Testing Performed
Describe the tests you ran to verify your changes:

**Test Environment**:
- PowerShell Version: [e.g. 7.4.1]
- OS: [e.g. Windows 11]

**Test Cases**:
```powershell
# Example test commands run
Import-Module .\EmojiTools.psd1
Get-Emoji -Name "test"
```

**Results**:
- [ ] All existing tests pass
- [ ] New tests added and passing
- [ ] Manual testing completed

## Impact Analysis
- [ ] This change requires a documentation update (if yes, which files?)
- [ ] This change affects existing functions (list them)
- [ ] This change affects data files (emoji.csv, metadata.json)
- [ ] This change affects module manifest (version bump needed?)

## Breaking Changes
If this is a breaking change, describe:
1. What breaks?
2. Migration path for users
3. Version number change (following SemVer)

## Documentation Updates
- [ ] Updated README.md
- [ ] Updated/created guide in docs/
- [ ] Updated EXAMPLES.ps1
- [ ] Updated function help (Get-Help compatible)
- [ ] Updated CHANGELOG.md with version/changes

## Checklist
Before submitting, please ensure:

- [ ] My code follows the PowerShell style guide in CONTRIBUTING.md
- [ ] I have used approved PowerShell verbs (Get-Verb)
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have tested on PowerShell 5.1 and/or PowerShell 7+
- [ ] Function parameters follow the module's naming conventions
- [ ] I have updated the module version if needed
- [ ] I have added/updated examples

## Screenshots (if applicable)
Add screenshots to help explain your changes.

## Additional Notes
Any additional information that reviewers should know.
