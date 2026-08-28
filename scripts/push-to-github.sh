#!/usr/bin/env bash
# First-time push to GitHub (run after creating empty repo on github.com)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

GITHUB_USER="${1:-}"
REPO_NAME="${2:-cursor-feishu}"

if [[ -z "$GITHUB_USER" ]]; then
  echo "Usage: ./scripts/push-to-github.sh <github_username> [repo_name]"
  echo
  echo "Before running:"
  echo "  1. Create empty repo at https://github.com/new?name=$REPO_NAME"
  echo "  2. Do NOT initialize with README (we push existing code)"
  exit 1
fi

REMOTE="https://github.com/${GITHUB_USER}/${REPO_NAME}.git"

if git rev-parse HEAD >/dev/null 2>&1; then
  echo "Repository already has commits."
else
  git add -A
  git status
  git commit -m "$(cat <<'EOF'
Add Feishu + Cursor integration (MCP + Lark CLI).

Dual MCP for docs/bitable, Lark CLI for block/sheet edits, SOP and routing skill.
EOF
)"
fi

if git remote get-url origin >/dev/null 2>&1; then
  echo "Remote origin already set: $(git remote get-url origin)"
else
  git remote add origin "$REMOTE"
fi

git branch -M main
git push -u origin main

echo
echo "Done: https://github.com/${GITHUB_USER}/${REPO_NAME}"
echo "Update SOP.md and Skill with this URL if placeholders differ."
