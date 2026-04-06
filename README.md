<div align="center">

# LLM Wiki

**A persistent, compounding knowledge base built and maintained by LLMs.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

</div>

Inspired by [Andrej Karpathy's LLM Wiki pattern](https://github.com/karpathy/llm-wiki). Instead of re-deriving knowledge from scratch on every query (like RAG), the LLM incrementally builds a structured, interlinked wiki — summarizing sources, cross-referencing entities, and maintaining consistency over time.

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
# Clone
git clone https://github.com/ingeun92/ing-wiki.git ~/wiki

# Create the global rule for your LLM agent
# For Claude Code: copy wiki.md to ~/.claude/rules/
# This enables wiki access from any project
```

Then open `~/wiki/` as an Obsidian vault for browsing.

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

```bash
# This is a git repo — sync across devices
git pull
git add -A && git commit -m "wiki updates" && git push
```

> `raw/` is `.gitignored` by default to protect sensitive source documents. Only wiki-generated pages are synced.

## License

[MIT](LICENSE)
