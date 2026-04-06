# Wiki Schema

This wiki is a personal knowledge base incrementally built and maintained by an LLM.
The user provides sources and asks questions; the LLM handles summarizing, cross-referencing, and organizing.

## Structure

```
wiki/
├── raw/              # Immutable source documents — LLM never modifies these
│   └── assets/       # Images, PDFs, attachments
├── entities/         # People, organizations, tools, projects
├── concepts/         # Ideas, techniques, patterns, methodologies
├── sources/          # Source summaries (papers, articles, videos, etc.)
├── synthesis/        # Comparisons, analyses, research notes
├── index.md          # Content catalog
└── log.md            # Chronological operations log
```

## Page Conventions

### Frontmatter (required)

Every wiki page must include YAML frontmatter:

```yaml
---
title: Page Title
type: concept          # entity | concept | source | synthesis
tags: [tag1, tag2]
sources: ["[[sources/source-name]]"]
created: 2026-04-06
updated: 2026-04-06
---
```

**Additional fields by type:**
- `entity`: `aliases`, `url`, `related`
- `source`: `author`, `date`, `url`, `format` (article|paper|video|book|podcast)
- `synthesis`: `scope`, `status` (draft|review|final)

### Linking

- **Internal links**: Use `[[wikilinks]]` format (Obsidian-compatible)
- **With path**: `[[concepts/react-server-components]]` or `[[entities/andrej-karpathy|Karpathy]]`
- **Tags**: Frontmatter `tags` array + inline `#tag` both allowed
- **Images**: `![[raw/assets/image.png]]` format

### File Naming

- Lowercase kebab-case: `react-server-components.md`
- Names should reflect the core concept concisely
- Non-English titles go in frontmatter `title` field

## Operations

### 1. Ingest

When the user provides a new source:

1. **Read**: Read the source fully and identify key information
2. **Discuss**: Share key takeaways with the user
3. **Create source summary**: Write a summary page in `sources/`
4. **Update wiki**: Create or update related entity/concept pages
   - Enrich existing pages with new information
   - Flag contradictions explicitly with `> [!warning] Contradiction`
   - Create new pages for previously unseen concepts/entities
5. **Cross-reference**: Add `[[wikilinks]]` between related pages
6. **Update index.md**: Add entries for new pages
7. **Log**: Append `## [YYYY-MM-DD] ingest | Source Title` to log.md

### 2. Query

When the user asks a question about the wiki:

1. **Read index.md**: Find relevant pages
2. **Read pages**: Read related pages and synthesize information
3. **Answer**: Respond with `[[wikilinks]]` citations
4. **Save (optional)**: If the analysis is valuable, save to `synthesis/`
5. **Log**: Append `## [YYYY-MM-DD] query | Question summary` to log.md

### 3. Lint

Periodic wiki health checks:

- **Contradictions**: Conflicting claims across pages
- **Stale**: Old information superseded by newer sources
- **Orphans**: Pages with no inbound links
- **Missing pages**: Frequently mentioned concepts without dedicated pages
- **Missing cross-refs**: Highly related pages without links between them
- **Data gaps**: Information holes fillable via web search
- **Log**: Append `## [YYYY-MM-DD] lint | Summary of findings` to log.md

## Project Wiki

Individual projects can have their own independent wiki.

### Bootstrap

When the user says "create a wiki for this project":

1. Create `wiki/` directory at the project root
2. Write a project-specific CLAUDE.md based on this schema template
3. Create `index.md`, `log.md`, and category directories
4. Note wiki existence in the project's CLAUDE.md

### Cross-Wiki Operations

**Promote** (project → global):
- "Promote this to the global wiki"
- Copy/adapt project wiki page to the appropriate category in `~/wiki/`
- Note the source project; update both index files

**Import** (global → project):
- "Import X from the global wiki"
- Search `~/wiki/index.md` → read relevant pages → adapt to project context
- Include reference links to global wiki paths

**Query** (global search):
- "Search the global wiki for X"
- Run Query workflow against `~/wiki/`

## Obsidian Tips

- **Graph View**: Visualize wiki connection structure
- **Backlinks**: See reverse links on each page
- **Dataview**: Dynamic queries on frontmatter (e.g., list recently added sources)
- **Web Clipper**: Convert browser articles to markdown → save to `raw/`
- **Marp**: Convert wiki content to slide decks

## Rules

- Never modify files in `raw/`
- Every wiki page must have frontmatter
- Always update `updated` date when creating or modifying a page
- Keep index.md in sync at all times
- Add cross-references bidirectionally (A→B means B→A too)
- Never delete contradictions — flag them with `> [!warning]` callout
- Recommend git commit before large-scale updates
