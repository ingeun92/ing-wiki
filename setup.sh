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

echo "[1/2] Initializing wiki data files..."
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

### Auto-capture

During any conversation, proactively identify knowledge worth persisting to the project wiki:

- New concepts, entities, or tools encountered during research/work
- Architectural decisions and their rationale
- Non-obvious findings from debugging or investigation
- Cross-project patterns and reusable insights

When detected, suggest briefly: "Save to wiki? — [one-line summary]"
Only write to wiki upon user approval. Skip ephemeral details — capture only knowledge that compounds.'

    inject_wiki_section "$PROJECT_ROOT/CLAUDE.md" "$PROJECT_SECTION" "project"
else
    # --- Global wiki: inject into ~/.claude/CLAUDE.md ---
    echo "  Detected: global wiki"

    GLOBAL_SECTION='## Wiki

Global wiki at `~/wiki/`. Read `~/wiki/CLAUDE.md` for the full schema.

### Auto-capture

During any conversation, proactively identify knowledge worth persisting:

- New concepts, entities, or tools encountered during research/work
- Architectural decisions and their rationale
- Non-obvious findings from debugging or investigation
- Cross-project patterns and reusable insights

When detected, suggest briefly: "Save to wiki? — [one-line summary]"
Only write to wiki upon user approval. Skip ephemeral details — capture only knowledge that compounds.

### Routing

- "add to wiki" → project wiki first (if `{cwd}/wiki/` exists), else global (`~/wiki/`)
- "global wiki" → `~/wiki/` explicitly
- "project wiki" → `{cwd}/wiki/` explicitly'

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
