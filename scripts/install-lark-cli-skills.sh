#!/usr/bin/env bash
# Install Lark CLI Agent Skills for Cursor / Claude Code / Codex.
set -euo pipefail

CURSOR_FEISHU_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NODE_BIN="$CURSOR_FEISHU_ROOT/.node/bin"

export PATH="$NODE_BIN:$PATH"

echo "==> Installing Lark CLI Skills (global)"
echo "Skills teach Agent how to use lark-cli for docs/block edits, bitable, calendar, etc."
echo

# Official repo ships skills for docs (+fetch/+update block ops), base, wiki, im, ...
npx -y skills add larksuite/cli -y -g

echo
echo "Done. Restart Cursor so Agent loads the new skills."
