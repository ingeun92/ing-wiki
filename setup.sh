#!/usr/bin/env bash
set -euo pipefail

WIKI_DIR="$(cd "$(dirname "$0")" && pwd)"

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

# --- 2. Install global rules for LLM agents ---

echo "[2/2] Installing agent rules..."

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
        echo "  · $name rule already exists at $dir/wiki.md"
        read -p "    Overwrite? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 0
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
