#!/usr/bin/env bash
set -euo pipefail

WIKI_DIR="$(cd "$(dirname "$0")" && pwd)"
AUTO_YES=false

for arg in "$@"; do
    case "$arg" in
        -y|--yes) AUTO_YES=true ;;
    esac
done

echo "=== LLM Wiki Setup ==="
echo "Wiki directory: $WIKI_DIR"
echo

# --- 1. Initialize local data files from templates ---

echo "[1/3] Initializing wiki data files..."
for file in index log; do
    if [ ! -f "$WIKI_DIR/$file.md" ]; then
        cp "$WIKI_DIR/$file.template.md" "$WIKI_DIR/$file.md"
        echo "  ✓ Created $file.md"
    else
        echo "  · $file.md already exists, skipping"
    fi
done
echo

# --- 2. Inject wiki reference into project root CLAUDE.md ---

echo "[2/3] Setting up project root CLAUDE.md..."

# Detect if this is a project wiki (has parent with .git) vs global wiki
PROJECT_ROOT="$(dirname "$WIKI_DIR")"

# Detect OMC: check for OMC markers in ~/.claude/CLAUDE.md
HAS_OMC=false
if [ -f "$HOME/.claude/CLAUDE.md" ] && grep -q "OMC:START" "$HOME/.claude/CLAUDE.md"; then
    HAS_OMC=true
fi

inject_wiki_section() {
    local target="$1" section="$2" label="$3"

    if [ ! -f "$target" ]; then
        printf '%s\n' "$section" > "$target"
        echo "  ✓ Created $target with wiki auto-capture reference"
    elif ! grep -q "^## Wiki" "$target"; then
        printf '\n\n%s\n' "$section" >> "$target"
        echo "  ✓ Appended wiki section to $target"
    else
        echo "  · $target already has ## Wiki section, skipping"
    fi
}

if [ -d "$PROJECT_ROOT/.git" ] || [ -f "$PROJECT_ROOT/.git" ]; then
    # --- Project wiki: inject into {project}/CLAUDE.md ---
    echo "  Detected: project wiki"

    PROJECT_SECTION='## Wiki

Project wiki at `wiki/`. Read `wiki/CLAUDE.md` for the full schema.

**Auto-capture**: Suggest "Save to wiki? — [one-line summary]" when detecting architecture decisions, reusable patterns, or non-obvious findings. Only write upon user approval. Skip ephemeral details.

**Auto-reference**: Check the wiki before work when the topic may have prior context from previous sessions.'

    inject_wiki_section "$PROJECT_ROOT/CLAUDE.md" "$PROJECT_SECTION" "project"
else
    # --- Global wiki: inject into ~/.claude/CLAUDE.md ---
    echo "  Detected: global wiki"

    if [ "$HAS_OMC" = true ]; then
        # OMC environment: inject 2-tier wiki section (OMC wiki → global wiki distillation)
        echo "  OMC detected — using 2-tier wiki config"

        OMC_SECTION='## Wiki

2-tier: OMC wiki (`.omc/wiki/`, MCP tools) → global wiki (`~/wiki/`, schema: `~/wiki/CLAUDE.md`).

**Routing**:
- default / "add to wiki" → OMC wiki (`.omc/wiki/`, use MCP tools)
- "global wiki" → `~/wiki/` (direct file I/O, follow `~/wiki/CLAUDE.md` schema)
- "promote" / "distill" → distill from OMC wiki to global wiki
- Exception: when cwd is `~/`, skip OMC wiki and write to `~/wiki/` directly (avoids `~/.omc/wiki/` ambiguity)

**Auto-capture**: Save to OMC wiki without confirmation. Target: architecture decisions, reusable patterns, non-obvious findings. Skip: ephemeral notes, project-specific config, code-evident content.

**Auto-distill** (on session end): If OMC wiki changed during session, promote to `~/wiki/`. Promote: category architecture/decision/pattern, or pages with 2+ cross-refs. Skip: session-log/debugging/environment. Read `~/wiki/CLAUDE.md` for target schema — classify into entity/concept/source/synthesis, add bidirectional `[[wikilinks]]`, update index.md + log.md.

**Auto-reference**: Check `~/wiki/` before work when topic may have prior session context.'

        GLOBAL_CLAUDE="$HOME/.claude/CLAUDE.md"
        if [ ! -d "$HOME/.claude" ]; then
            echo "  · ~/.claude not found, skipping global CLAUDE.md"
        else
            if [ "$AUTO_YES" = true ]; then
                inject_wiki_section "$GLOBAL_CLAUDE" "$OMC_SECTION" "global (OMC)"
            else
                read -p "  Add OMC wiki section to $GLOBAL_CLAUDE? [Y/n] " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                    inject_wiki_section "$GLOBAL_CLAUDE" "$OMC_SECTION" "global (OMC)"
                else
                    echo "  · Skipped global CLAUDE.md"
                fi
            fi
        fi
    else
        # Non-OMC environment: inject standard wiki section
        GLOBAL_SECTION='## Wiki

Global wiki at `~/wiki/`. Read `~/wiki/CLAUDE.md` for the full schema.

**Routing**:
- "add to wiki" → project wiki first (if `{cwd}/wiki/` exists), else global (`~/wiki/`)
- "global wiki" → `~/wiki/` explicitly
- "project wiki" → `{cwd}/wiki/` explicitly

**Auto-capture**: Suggest "Save to wiki? — [one-line summary]" when detecting architecture decisions, reusable patterns, or non-obvious findings. Only write upon user approval. Skip ephemeral details.

**Auto-reference**: Check `~/wiki/` before work when the topic may have prior context from previous sessions.'

        GLOBAL_CLAUDE="$HOME/.claude/CLAUDE.md"
        if [ ! -d "$HOME/.claude" ]; then
            echo "  · ~/.claude not found, skipping global CLAUDE.md"
        else
            if [ "$AUTO_YES" = true ]; then
                inject_wiki_section "$GLOBAL_CLAUDE" "$GLOBAL_SECTION" "global"
            else
                read -p "  Add wiki section to $GLOBAL_CLAUDE? [Y/n] " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                    inject_wiki_section "$GLOBAL_CLAUDE" "$GLOBAL_SECTION" "global"
                else
                    echo "  · Skipped global CLAUDE.md"
                fi
            fi
        fi
    fi
fi
echo

# --- 3. Install global rules for LLM agents ---

echo "[3/3] Installing agent rules..."

install_rule() {
    local name="$1" dir="$2"
    local src="$WIKI_DIR/setup/wiki.md"

    # Only attempt if parent config directory exists
    if [ ! -d "$(dirname "$dir")" ]; then
        echo "  · $name not detected, skipping"
        return 0
    fi

    mkdir -p "$dir"

    if [ -f "$dir/wiki.md" ]; then
        if [ "$AUTO_YES" = true ]; then
            echo "  · Overwriting existing $name rule"
        else
            echo "  · $name rule already exists at $dir/wiki.md"
            read -p "    Overwrite? [y/N] " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                return 0
            fi
        fi
    fi

    cp "$src" "$dir/wiki.md"
    echo "  ✓ $name rule installed → $dir/wiki.md"
}

# Claude Code
install_rule "Claude Code" "$HOME/.claude/rules"

# Codex CLI (if ~/.codex exists)
install_rule "Codex CLI" "$HOME/.codex/rules"

echo
echo "=== Setup complete ==="
echo
echo "Next steps:"
echo "  1. Open $WIKI_DIR as an Obsidian vault"
echo "  2. Start any conversation — wiki auto-capture is now active"
echo "  3. Say 'ingest <source>' to manually add knowledge"
if [ "$HAS_OMC" = true ]; then
    echo
    echo "OMC detected:"
    echo "  · CLAUDE.md Wiki section is managed by OMC (2-tier: OMC wiki → global wiki)"
    echo "  · rules/wiki.md installed as fallback for non-OMC environments"
fi
