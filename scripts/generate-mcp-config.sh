#!/usr/bin/env bash
# Generate ~/.cursor/mcp.json for Feishu dual MCP setup.
set -euo pipefail

CURSOR_FEISHU_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MCP_JSON="$HOME/.cursor/mcp.json"
DOC_SCRIPT="$CURSOR_FEISHU_ROOT/scripts/run-lark-doc-mcp.sh"
OFFICIAL_SCRIPT="$CURSOR_FEISHU_ROOT/scripts/run-lark-official-mcp.sh"

mkdir -p "$HOME/.cursor"

python3 - <<PY
import json
from pathlib import Path

mcp_path = Path("$MCP_JSON")
existing = {}
if mcp_path.exists():
    existing = json.loads(mcp_path.read_text())

servers = existing.get("mcpServers", {})
servers["lark-doc"] = {"command": "$DOC_SCRIPT"}
servers["lark-official"] = {"command": "$OFFICIAL_SCRIPT"}
existing["mcpServers"] = servers

mcp_path.write_text(json.dumps(existing, indent=2, ensure_ascii=False) + "\n")
print(f"Updated {mcp_path}")
PY

echo "Restart Cursor, then check Settings → MCP for lark-doc and lark-official."
