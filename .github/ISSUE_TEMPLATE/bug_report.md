---
name: Bug report
about: Create a report to help us improve EmojiTools
title: '[BUG] '
labels: bug
assignees: ''
---

## Bug Description
A clear and concise description of what the bug is.

## Steps to Reproduce
Steps to reproduce the behavior:
1. Import the module with '...'
2. Run command '...'
3. See error

## Expected Behavior
A clear and concise description of what you expected to happen.

## Actual Behavior
What actually happened instead.

## Error Messages
```powershell
# Paste any error messages here
```

## Environment
- **PowerShell Version**: [e.g. 7.4.1 or 5.1.22621.2506]
  - Run: `$PSVersionTable.PSVersion`
- **OS**: [e.g. Windows 11, macOS 14.2, Ubuntu 22.04]
  - Run: `$PSVersionTable.OS`
- **EmojiTools Version**: [e.g. 1.10.0]
  - Run: `(Get-Module EmojiTools).Version`
- **Terminal**: [e.g. Windows Terminal, VSCode, pwsh]

## Dataset Information
- **Dataset Type**: [Unicode CLDR / Custom]
  - Run: `Get-EmojiDatasetInfo`
- **Dataset Version**: [e.g. Unicode 15.1]
- **Emoji Count**: [e.g. 3790]

## Function Details
**Function Name**: [e.g. Get-Emoji, Search-Emoji]

**Parameters Used**:
```powershell
# Provide the exact command you ran
Get-Emoji -Name "heart" -SkinTone "light"
```

## Additional Context
Add any other context about the problem here (screenshots, related issues, etc.).

## Possible Solution
If you have suggestions on how to fix the bug, please share them here.
