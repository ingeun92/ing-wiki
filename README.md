<div align="center">

# LLM Wiki

**A persistent, compounding knowledge base built and maintained by LLMs.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

</div>

Inspired by [Andrej Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f). Instead of re-deriving knowledge from scratch on every query (like RAG), the LLM incrementally builds a structured, interlinked wiki — summarizing sources, cross-referencing entities, and maintaining consistency over time.

## Features

- **Incremental knowledge building** — each source enriches the entire wiki, not just one page
- **Obsidian-compatible** — `[[wikilinks]]`, YAML frontmatter, graph view, backlinks
- **Three core operations** — Ingest (add sources), Query (ask questions), Lint (health check)
- **Global + project wikis** — personal knowledge base with per-project extensions
- **Cross-platform** — works with Claude Code (`CLAUDE.md`), Codex, Gemini CLI (`AGENTS.md`)
- **Git-managed** — full version history, branching, multi-device sync

## Architecture

```
wiki/
├── CLAUDE.md / AGENTS.md   # Wiki schema (LLM instructions)
├── index.md                # Content catalog
├── log.md                  # Chronological operations log
├── raw/                    # Immutable source documents (.gitignored)
│   └── assets/             # Images, PDFs
├── entities/               # People, organizations, tools
├── concepts/               # Ideas, techniques, patterns
├── sources/                # Source summaries
└── synthesis/              # Comparisons, analyses
```

## Quick Start

### Global Wiki Setup

```bash
# Clone the template
git clone https://github.com/ingeun92/ing-wiki.git ~/wiki
cd ~/wiki

# Initialize your local wiki data from templates
cp index.template.md index.md
cp log.template.md log.md

# Create the global rule for your LLM agent
# For Claude Code: copy wiki.md to ~/.claude/rules/
# This enables wiki access from any project
```

Then open `~/wiki/` as an Obsidian vault for browsing.

### Pulling Template Updates

Your wiki content (`entities/`, `concepts/`, `sources/`, `synthesis/`, `index.md`, `log.md`) is gitignored — it stays local and is never pushed to the remote. When the template gets updates:

```bash
git pull origin main
# Your local wiki data is untouched — only template files update
```

### Usage (Global)

Tell your LLM agent:

```
"Ingest this article into the wiki"        → creates source summary + updates related pages
"What does the wiki say about X?"           → searches index, reads pages, synthesizes answer
"Run a wiki lint"                           → checks for contradictions, orphans, stale content
```

### Project Wiki Setup

From any project directory, tell your LLM agent:

```
"Create a wiki for this project"
```

This scaffolds a `wiki/` directory inside your project:

```
my-project/
├── CLAUDE.md          ← wiki reference added here
├── AGENTS.md          ← same content (cross-platform)
└── wiki/
    ├── CLAUDE.md      ← project wiki schema
    ├── AGENTS.md      ← symlink → CLAUDE.md
    ├── index.md
    ├── log.md
    ├── raw/
    ├── entities/
    ├── concepts/
    ├── sources/
    └── synthesis/
```

### Usage (Project)

```
"Add this to the wiki"                      → saves to project wiki (default when it exists)
"Add this to the global wiki"               → saves to ~/wiki/ explicitly
"Promote this to the global wiki"           → copies project wiki page → global wiki
"Import X from the global wiki"             → brings global knowledge into project context
```

### Cross-Wiki Operations

| Operation | Direction | Description |
|-----------|-----------|-------------|
| **Promote** | Project → Global | Elevate project-specific knowledge to the global wiki |
| **Import** | Global → Project | Bring global knowledge into project context |
| **Query** | Either | Search and synthesize from either wiki |

## Page Format

Every wiki page uses YAML frontmatter + Obsidian-compatible markdown:

```markdown
---
title: React Server Components
type: concept
tags: [react, frontend, architecture]
sources: ["[[sources/dan-abramov-rsc-talk]]"]
created: 2026-04-06
updated: 2026-04-06
---

# React Server Components

Content with [[wikilinks]] to related pages...
```

**Page types**: `entity`, `concept`, `source`, `synthesis`

## Obsidian Integration

Open `~/wiki/` (or `project/wiki/`) as an Obsidian vault:

- **Graph View** — visualize connections between pages
- **Backlinks** — see which pages link to the current page
- **Dataview** — dynamic queries on frontmatter metadata
- **Web Clipper** — save browser articles as markdown sources

## Multi-Device Sync

This repo is a **template** — wiki content is gitignored and stays local. To sync your wiki data across devices, use a separate mechanism:

- **Obsidian Sync** — built-in Obsidian syncing
- **Syncthing / rsync** — sync the content directories directly
- **Separate private repo** — track your data in a private repo alongside the template

## License

[MIT](LICENSE)
