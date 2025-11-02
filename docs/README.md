# 📚 EmojiTools Documentation

This directory contains the source files for the EmojiTools documentation site, built with [MkDocs](https://www.mkdocs.org/) and [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/).

## 🌐 View Documentation Online

Visit the live documentation at: **[https://Tsabo.github.io/EmojiTools](https://Tsabo.github.io/EmojiTools)** _(coming soon)_

## 🏗️ Build Documentation Locally

### Prerequisites

- Python 3.8 or higher
- pip (Python package manager)

### Setup

1. **Install dependencies:**

```bash
pip install -r docs-requirements.txt
```

2. **Serve documentation locally:**

```bash
mkdocs serve
```

3. **Open in your browser:**

Navigate to `http://127.0.0.1:8000`

### Build Static Site

To build the static HTML files:

```bash
mkdocs build
```

Files will be generated in the `site/` directory.

## 📁 Documentation Structure

```
docs/
├── index.md                    # Homepage
├── getting-started/
│   ├── installation.md         # Installation guide
│   ├── quickstart.md          # Quick start tutorial
│   └── first-steps.md         # First steps guide
├── user-guide/
│   ├── searching.md           # Search guide
│   ├── collections.md         # Collections guide
│   ├── picker.md              # Emoji picker guide
│   ├── export.md              # Export guide
│   └── aliases.md             # Aliases guide
├── automation/
│   ├── auto-updates.md        # Auto-update guide
│   ├── scheduled-tasks.md     # Scheduled tasks
│   └── history.md             # History tracking
├── advanced/
│   ├── custom-datasets.md     # Custom datasets
│   ├── custom-sources.md      # Custom sources
│   ├── analytics.md           # Analytics
│   └── caching.md             # Caching
├── reference/
│   ├── commands.md            # Command reference
│   ├── configuration.md       # Configuration
│   └── troubleshooting.md     # Troubleshooting
├── contributing/
│   ├── setup.md               # Development setup
│   └── testing.md             # Testing strategy
├── assets/                     # Images and assets
└── stylesheets/
    └── extra.css              # Custom CSS
```

## ✍️ Contributing to Documentation

We welcome documentation improvements! Here's how:

### Writing Style Guide

- **Be conversational** - Write like you're talking to a friend
- **Use examples** - Show, don't just tell
- **Add emojis** - Make it fun and engaging! 🎉
- **Be concise** - Get to the point quickly
- **Include code samples** - Runnable examples are best

### Markdown Features

We support extended Markdown features:

- ✅ Admonitions (tips, warnings, info boxes)
- ✅ Code highlighting with line numbers
- ✅ Tabs for different options
- ✅ Emoji support with `:emoji_name:`
- ✅ Tables
- ✅ Task lists

### Example Admonitions

```markdown
!!! tip "Pro Tip"
    This is helpful advice!

!!! warning "Watch Out"
    This could cause issues.

!!! example "Try This"
    Here's a hands-on example.
```

### Adding a New Page

1. Create your `.md` file in the appropriate directory
2. Add it to `mkdocs.yml` under `nav:`
3. Test locally with `mkdocs serve`
4. Submit a pull request

## 🎨 Theme & Styling

We use Material for MkDocs with custom styling:

- **Primary color:** Indigo (#667eea)
- **Accent color:** Pink (#f093fb)
- **Light & Dark modes** supported
- **Custom CSS** in `stylesheets/extra.css`

## 🔍 Search

The documentation includes full-text search powered by MkDocs. All content is indexed automatically.

## 📱 Responsive Design

Documentation is optimized for:

- 💻 Desktop browsers
- 📱 Mobile devices
- 📓 Tablets

## 🚀 Deployment

Documentation is automatically deployed to GitHub Pages when changes are merged to master.

### Manual Deployment

```bash
mkdocs gh-deploy
```

## 📝 Legacy Documentation

Original documentation files (in the root `docs/` directory) are preserved for reference and will be gradually migrated to the new structure.

## ❓ Questions?

- Open an issue on [GitHub](https://github.com/Tsabo/EmojiTools/issues)
- Check the [Contributing Guide](contributing/setup.md)
- Review the [MkDocs Documentation](https://www.mkdocs.org/)

---

**Happy documenting! 📚✨**
