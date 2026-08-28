#!/usr/bin/env bash
# Demo local sync workflow (no Feishu API): mirror project doc to feishu-sync/.
set -euo pipefail

CURSOR_FEISHU_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_ROOT="$(cd "$CURSOR_FEISHU_ROOT/.." && pwd)"
SRC="$PROJECT_ROOT/CV_Helper/简历面试助手-产品方案.md"
DEST="$CURSOR_FEISHU_ROOT/feishu-sync/简历面试助手-产品方案.md"
DOCS="$PROJECT_ROOT/CV_Helper/docs/简历面试助手-产品方案.md"

if [[ ! -f "$SRC" ]]; then
  echo "Source not found: $SRC" >&2
  exit 1
fi

mkdir -p "$(dirname "$DEST")" "$(dirname "$DOCS")"
cp "$SRC" "$DEST"
cp "$SRC" "$DOCS"

echo "Local sync demo complete:"
echo "  $DEST"
echo "  $DOCS"
echo
echo "In Cursor Agent (after OAuth), upload with:"
echo "  读取 cursor-feishu/feishu-sync/简历面试助手-产品方案.md，创建一个新的飞书文档并写入全部内容"
