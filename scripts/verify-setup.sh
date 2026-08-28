#!/usr/bin/env bash
# Verify Feishu + Cursor MCP integration readiness.
set -euo pipefail

CURSOR_FEISHU_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_ROOT="$(cd "$CURSOR_FEISHU_ROOT/.." && pwd)"
ENV_FILE="$CURSOR_FEISHU_ROOT/.env"
MCP_JSON="$HOME/.cursor/mcp.json"
NODE_BIN="$CURSOR_FEISHU_ROOT/.node/bin"
LARK_MCP_DIR="$CURSOR_FEISHU_ROOT/vendor/lark-mcp"
PASS=0
WARN=0
FAIL=0

ok() { echo "  [OK] $*"; PASS=$((PASS + 1)); }
warn() { echo "  [WARN] $*"; WARN=$((WARN + 1)); }
fail() { echo "  [FAIL] $*"; FAIL=$((FAIL + 1)); }

echo "==> Feishu + Cursor integration verify"
echo "    Root: $CURSOR_FEISHU_ROOT"
echo

if [[ -x "$NODE_BIN/node" ]]; then
  ok "Portable Node.js: $("$NODE_BIN/node" -v)"
else
  fail "Portable Node.js missing at $NODE_BIN — run ./setup.sh"
fi

if [[ -f "$LARK_MCP_DIR/index.mjs" && -d "$LARK_MCP_DIR/node_modules" ]]; then
  ok "lovelts/lark-mcp installed at $LARK_MCP_DIR"
else
  fail "lovelts/lark-mcp missing — run ./setup.sh"
fi

if [[ -x "$CURSOR_FEISHU_ROOT/node_modules/.bin/lark-mcp" ]]; then
  ok "Official @larksuiteoapi/lark-mcp installed"
else
  fail "Official lark-mcp missing — run ./setup.sh"
fi

if [[ -x "$CURSOR_FEISHU_ROOT/node_modules/.bin/lark-cli" ]]; then
  ok "Official @larksuite/cli (lark-cli) installed"
else
  fail "lark-cli missing — run ./setup.sh"
fi

if [[ -f "$MCP_JSON" ]]; then
  if python3 - <<PY
import json, sys
from pathlib import Path
mcp = json.loads(Path("$MCP_JSON").read_text())
servers = mcp.get("mcpServers", {})
doc = servers.get("lark-doc", {}).get("command", "")
official = servers.get("lark-official", {}).get("command", "")
root = "$CURSOR_FEISHU_ROOT"
if "lark-doc" not in servers or "lark-official" not in servers:
    sys.exit(1)
if root not in doc or root not in official:
    print("MCP paths do not point to cursor-feishu — run ./scripts/generate-mcp-config.sh")
    sys.exit(2)
sys.exit(0)
PY
  then
    ok "~/.cursor/mcp.json has lark-doc and lark-official under cursor-feishu"
  else
    code=$?
    if [[ $code -eq 2 ]]; then
      fail "~/.cursor/mcp.json points to old paths — run ./scripts/generate-mcp-config.sh"
    else
      fail "~/.cursor/mcp.json missing lark-doc or lark-official"
    fi
  fi
else
  fail "~/.cursor/mcp.json missing — run ./setup.sh"
fi

for s in run-lark-doc-mcp.sh run-lark-official-mcp.sh login-official.sh configure-lark-cli.sh login-lark-cli.sh install-lark-cli-skills.sh; do
  if [[ -x "$CURSOR_FEISHU_ROOT/scripts/$s" ]]; then
    ok "Script executable: scripts/$s"
  else
    fail "Script not executable: scripts/$s"
  fi
done

for d in "$CURSOR_FEISHU_ROOT/feishu-sync" "$PROJECT_ROOT/CV_Helper/docs"; do
  if [[ -d "$d" ]]; then ok "Directory exists: $d"; else fail "Missing: $d"; fi
done

if [[ ! -f "$ENV_FILE" ]]; then
  fail ".env missing — run ./setup.sh"
else
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  if [[ "${LARK_APP_ID:-}" == cli_xxxxxxxx || -z "${LARK_APP_ID:-}" ]]; then
    warn ".env still has placeholder LARK_APP_ID — fill real credentials from Feishu developer console"
    warn "See FEISHU_APP_CHECKLIST.md"
  else
    ok ".env has LARK_APP_ID configured"
  fi
  if [[ "${LARK_APP_SECRET:-}" == xxxxxxxxxxxxxxxxxxxxxxxx || -z "${LARK_APP_SECRET:-}" ]]; then
    warn ".env still has placeholder LARK_APP_SECRET"
  else
    ok ".env has LARK_APP_SECRET configured"
  fi
fi

OFFICIAL_TOKEN_DIR="${HOME}/.lark-mcp"
if [[ -d "$OFFICIAL_TOKEN_DIR" ]]; then
  ok "Official OAuth storage dir exists ($OFFICIAL_TOKEN_DIR)"
else
  warn "Official MCP OAuth not done — run ./scripts/login-official.sh"
fi

if "$CURSOR_FEISHU_ROOT/node_modules/.bin/lark-cli" config show >/dev/null 2>&1; then
  ok "lark-cli configured (config show OK)"
else
  warn "lark-cli not configured — run ./scripts/configure-lark-cli.sh"
fi

LARK_CLI_AUTH="$("$CURSOR_FEISHU_ROOT/node_modules/.bin/lark-cli" auth status 2>/dev/null || true)"
if echo "$LARK_CLI_AUTH" | python3 -c "import json,sys; d=json.load(sys.stdin); sys.exit(0 if d.get('identities',{}).get('user',{}).get('available') else 1)" 2>/dev/null; then
  ok "lark-cli user OAuth OK"
else
  warn "lark-cli user not logged in — run ./scripts/login-lark-cli.sh"
fi

echo
echo "Summary: $PASS passed, $WARN warnings, $FAIL failures"
echo

if [[ $FAIL -gt 0 ]]; then
  echo "Fix failures above, then re-run: ./scripts/verify-setup.sh"
  exit 1
fi

if [[ $WARN -gt 0 ]]; then
  echo "Next steps:"
  echo "  1. Complete FEISHU_APP_CHECKLIST.md (Feishu developer console)"
  echo "  2. Edit cursor-feishu/.env with App ID and Secret"
  echo "  3. ./scripts/login-official.sh"
  echo "  4. Restart Cursor → Settings → MCP (both servers green)"
  echo "  5. Test with TEST_PROMPTS.md"
  exit 2
fi

echo "All checks passed. Restart Cursor and test with TEST_PROMPTS.md"
exit 0
