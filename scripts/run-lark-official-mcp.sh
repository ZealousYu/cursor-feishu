#!/usr/bin/env bash
# Start official @larksuiteoapi/lark-mcp for Bitable + doc search (user OAuth).
set -euo pipefail

CURSOR_FEISHU_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$CURSOR_FEISHU_ROOT/.env"
NODE_BIN="$CURSOR_FEISHU_ROOT/.node/bin"
OFFICIAL_MCP="$CURSOR_FEISHU_ROOT/node_modules/.bin/lark-mcp"

# shellcheck source=lib/resolve-open-domain.sh
source "$CURSOR_FEISHU_ROOT/scripts/lib/resolve-open-domain.sh"

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

OPEN_DOMAIN="$(resolve_lark_open_domain)"
# Default: bitable + doc search + wiki move + docx block read/write (embedded tables)
TOOLS="${LARK_OFFICIAL_TOOLS:-preset.base.default,preset.doc.default,wiki.v2.spaceNode.move,wiki.v2.spaceNode.list,docx.v1.documentBlock.list,docx.v1.documentBlock.get,docx.v1.documentBlockChildren.create,docx.v1.documentBlock.patch,docx.v1.documentBlockChildren.batchDelete}"

exec "$OFFICIAL_MCP" mcp \
  -a "$LARK_APP_ID" \
  -s "$LARK_APP_SECRET" \
  -d "$OPEN_DOMAIN" \
  --oauth \
  --token-mode user_access_token \
  -t "$TOOLS"
