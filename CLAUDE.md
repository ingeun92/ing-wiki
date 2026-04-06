# Wiki Schema

LLM-maintained personal knowledge base. User provides sources and questions; LLM handles organizing.

## Structure

`raw/` (immutable sources + `assets/`) | `entities/` `concepts/` `sources/` `synthesis/` | `index.md` (catalog) | `log.md` (chronological)

## Page Format

Required YAML frontmatter → Obsidian-compatible `[[wikilinks]]` → kebab-case filenames.

```yaml
---
title: Page Title
type: entity | concept | source | synthesis
tags: [tag1, tag2]
sources: ["[[sources/source-name]]"]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

Extra fields: entity→`aliases,url,related` | source→`author,date,url,format` | synthesis→`scope,status`

## Operations

**Ingest**: Read source → discuss with user → create `sources/` summary → update related entity/concept pages → flag contradictions with `> [!warning]` → add `[[wikilinks]]` cross-refs → update index.md → append to log.md (`## [YYYY-MM-DD] ingest | Title`)

**Query**: Read index.md → find relevant pages → synthesize answer with `[[citations]]` → optionally save to `synthesis/` → log

**Lint**: Check contradictions, stale content, orphans, missing pages, missing cross-refs, data gaps → log

## Project Wiki

Any project can have its own `wiki/` with the same structure. Bootstrap: copy this schema as `{project}/wiki/CLAUDE.md`, create `AGENTS.md → CLAUDE.md` symlink, add `index.md`, `log.md`, category dirs with `.gitkeep`.

**Routing**: "add to wiki" → project wiki first (if exists), else global (`~/wiki/`). Prefix "global wiki" or "project wiki" to override.

**Cross-wiki**: Promote (project→global) | Import (global→project) — update both index.md files. Guard: check `## Wiki` section exists before appending to project root CLAUDE.md/AGENTS.md to avoid duplicates.

## Rules

- Never modify `raw/` — Cross-refs must be bidirectional — Never delete contradictions, flag them
- Always include frontmatter — Always update `updated` date — Keep index.md in sync
- Recommend git commit before large updates
