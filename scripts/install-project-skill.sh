#!/usr/bin/env bash
# Install project feishu-cursor-integration skill into ~/.cursor/skills for global use.
set -euo pipefail

CURSOR_FEISHU_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_SRC="$CURSOR_FEISHU_ROOT/.cursor/skills/feishu-cursor-integration"
SKILL_DST="$HOME/.cursor/skills/feishu-cursor-integration"

if [[ ! -f "$SKILL_SRC/SKILL.md" ]]; then
  echo "Missing $SKILL_SRC/SKILL.md" >&2
  exit 1
fi

mkdir -p "$HOME/.cursor/skills"
rm -rf "$SKILL_DST"
cp -R "$SKILL_SRC" "$SKILL_DST"

# Inject GitHub repo URL if .git remote exists
REMOTE="$(git -C "$CURSOR_FEISHU_ROOT" remote get-url origin 2>/dev/null || true)"
if [[ -n "$REMOTE" ]]; then
  if [[ "$REMOTE" =~ ^git@github.com:(.+)\.git$ ]]; then
    URL="https://github.com/${BASH_REMATCH[1]}"
  elif [[ "$REMOTE" =~ ^https://github.com/(.+)\.git$ ]]; then
    URL="https://github.com/${BASH_REMATCH[1]}"
  else
    URL="$REMOTE"
  fi
  sed -i '' "s|<GITHUB_REPO_URL>|$URL|g" "$SKILL_DST/SKILL.md" 2>/dev/null || \
    sed -i "s|<GITHUB_REPO_URL>|$URL|g" "$SKILL_DST/SKILL.md"
  # Also update SOP if present
  if [[ -f "$CURSOR_FEISHU_ROOT/SOP.md" ]]; then
    sed -i '' "s|<GITHUB_REPO_URL>|$URL|g" "$CURSOR_FEISHU_ROOT/SOP.md" 2>/dev/null || \
      sed -i "s|<GITHUB_REPO_URL>|$URL|g" "$CURSOR_FEISHU_ROOT/SOP.md"
  fi
  echo "Skill installed with repo URL: $URL"
else
  echo "Skill installed (set GitHub URL in SKILL.md manually if needed)"
fi

echo "Done. Restart Cursor to load feishu-cursor-integration skill."
