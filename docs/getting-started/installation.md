# Installation

Getting EmojiTools up and running is quick and easy! Choose the installation method that works best for you.

---

## 📦 Install from PowerShell Gallery (Recommended)

The fastest way to get started is installing directly from the PowerShell Gallery:

```powershell
# Install for your user account (no admin required)
Install-Module -Name EmojiTools -Scope CurrentUser

# Or install system-wide (requires admin)
Install-Module -Name EmojiTools -Scope AllUsers
```

!!! success "That's it!"
    You're done! Jump to [Quick Start](quickstart.md) to begin using EmojiTools.

??? tip "Having permission issues?"
    If you see permission errors, use `-Scope CurrentUser` instead of `-Scope AllUsers`. This installs the module for your account only and doesn't require administrator privileges.

---

## 🔧 Install from Source

Want to contribute or use the latest development version? Install from the GitHub repository:

### 1. Clone the Repository

```powershell
# Clone via HTTPS
git clone https://github.com/Tsabo/EmojiTools.git
cd EmojiTools

# Or clone via SSH
git clone git@github.com:Tsabo/EmojiTools.git
cd EmojiTools
```

### 2. Import the Module

```powershell
# Import from the source directory
Import-Module .\src\EmojiTools.psd1
```

!!! info "Development Installation"
    This method is great for testing new features or contributing to the project. You'll always have the latest code!

---

## ✅ Verify Installation

Confirm EmojiTools is installed correctly:

```powershell
# Check the module is available
Get-Module -ListAvailable EmojiTools

# Import the module
Import-Module EmojiTools

# View available commands
Get-Command -Module EmojiTools
```

You should see 20+ commands available! Here are some key ones:

| Command | What It Does |
|---------|-------------|
| `Search-Emoji` | Find emojis by name or keyword |
| `Get-Emoji` | List emojis with filtering |
| `Copy-Emoji` | Copy emoji to clipboard |
| `Show-EmojiPicker` | Open interactive picker |
| `Update-EmojiDataset` | Download latest emojis |

---

## 🔄 Update EmojiTools

Keep your installation current with the latest features:

```powershell
# Update from PowerShell Gallery
Update-Module -Name EmojiTools
```

---

## 🎯 System Requirements

!!! check "Requirements"
    - **PowerShell 7.0 or higher** (cross-platform support)
    - **Internet connection** (for downloading emoji datasets)
    - **Supported Platforms**: Windows, macOS, Linux

### Check Your PowerShell Version

```powershell
$PSVersionTable.PSVersion
```

!!! warning "PowerShell 5.1 Users"
    EmojiTools requires PowerShell 7+. Upgrade to [PowerShell 7](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell) for the best experience and cross-platform support.

---

## 🚀 Next Steps

Now that you've installed EmojiTools, let's get you started:

<div class="grid cards" markdown>

-   :rocket: **Quick Start**

    ---

    Learn the basics in 5 minutes with our hands-on tutorial

    [:octicons-arrow-right-24: Start the tutorial](quickstart.md)

-   :mag: **Searching Emojis**

    ---

    Discover the power of emoji search

    [:octicons-arrow-right-24: Master search](../user-guide/searching.md)

-   :books: **Command Reference**

    ---

    Browse all available commands

    [:octicons-arrow-right-24: View commands](../reference/commands.md)

</div>

---

## 💡 Troubleshooting

### Module Not Found After Installation

If PowerShell can't find the module after installing:

```powershell
# Check module paths
$env:PSModulePath -split ';'

# Force reload module path
Import-Module EmojiTools -Force
```

### Permission Denied

Use `-Scope CurrentUser` to install without admin rights:

```powershell
Install-Module -Name EmojiTools -Scope CurrentUser -Force
```

Need more help? Check our [Troubleshooting Guide](../reference/troubleshooting.md)!
