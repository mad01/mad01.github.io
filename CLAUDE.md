# qone.io — Engineering Blog

Static site built with [Hugo](https://gohugo.io/), deployed to GitHub Pages via GitHub Actions.

## Quick Start

```bash
# Run locally
hugo server -D

# Build for production
hugo --gc --minify
```

## Creating a New Post

```bash
hugo new posts/my-post-title.md
```

Or create manually in `content/posts/`:

```markdown
---
title: post title here
date: 2026-04-02T00:00:00+00:00
tags: ["go", "docker", "kubernetes"]
draft: false
---

Post content in markdown. Use fenced code blocks:

\```python
print("hello")
\```
```

## Project Structure

```
content/posts/       — blog posts (markdown)
content/about.md     — about page
layouts/             — Hugo templates
  _default/          — baseof.html, list.html, single.html
  page/              — page layout (about)
  partials/          — head.html, nav.html, footer.html
static/css/style.css — stylesheet
static/imgs/         — blog post images
config.toml          — Hugo site configuration
.github/workflows/   — GitHub Actions deployment
```

## Deployment

Push to `master` branch. GitHub Actions builds with Hugo and deploys to GitHub Pages.

Custom domain: `qone.io` (configured via CNAME + Cloudflare DNS proxy).

## Design System

**Fonts**: JetBrains Mono (headings/code), Source Serif 4 (body)

**Colors** (dark theme):
- Background: `#0f0f0f`
- Surface: `#1a1a1a`
- Border: `#2a2a2a`
- Accent: `#60a5fa` (blue)
- Text: `#999` (body), `#e0e0e0` (headings), `#fff` (emphasis)

## Syntax Highlighting

Hugo uses Chroma with the `dracula` theme. Code blocks use fenced markdown syntax with language identifiers.
