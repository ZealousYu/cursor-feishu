#!/usr/bin/env bash
# Start lovelts/lark-mcp for Feishu document Markdown CRUD (user OAuth).
set -euo pipefail

CURSOR_FEISHU_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$CURSOR_FEISHU_ROOT/.env"
NODE_BIN="$CURSOR_FEISHU_ROOT/.node/bin"
LARK_MCP_DIR="$CURSOR_FEISHU_ROOT/vendor/lark-mcp"

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

if [[ -z "${LARK_APP_ID:-}" || -z "${LARK_APP_SECRET:-}" ]]; then
  echo "Missing LARK_APP_ID or LARK_APP_SECRET. Copy .env.example to .env and fill credentials." >&2
  exit 1
fi

export PATH="$NODE_BIN:$PATH"
export LARK_APP_ID LARK_APP_SECRET
export FEISHU_DOMAIN="${FEISHU_DOMAIN:-feishu.cn}"
export OAUTH_PORT="${OAUTH_PORT:-9997}"

exec node "$LARK_MCP_DIR/index.mjs"
