#!/usr/bin/env bash
# OAuth login for official @larksuiteoapi/lark-mcp (required before lark-official MCP works).
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
  echo "Missing LARK_APP_ID or LARK_APP_SECRET in $ENV_FILE" >&2
  exit 1
fi

export PATH="$NODE_BIN:$PATH"

OPEN_DOMAIN="$(resolve_lark_open_domain)"

# OAuth2 scopes (use OAuth2 flow; required for docx/bitable user token)
SCOPES="${LARK_OAUTH_SCOPES:-offline_access docx:document bitable:app drive:drive wiki:wiki wiki:wiki:readonly search:docs:read}"

REDIRECT_EXACT="http://localhost:3000/callback?redirect_uri=http://localhost:3000/callback"

echo "==> Feishu OAuth login (official MCP)"
echo "App ID: $LARK_APP_ID"
echo "Open API domain: $OPEN_DOMAIN"
echo
echo "IMPORTANT — configure these redirect URLs in Feishu developer console:"
echo "  1) http://localhost:3000/callback"
echo "  2) $REDIRECT_EXACT"
echo
echo "Open: ${OPEN_DOMAIN}/app/${LARK_APP_ID}/safe"
echo
echo "Note: The terminal shows client_id=client_id_for_local_auth — that is the LOCAL"
echo "proxy step and is normal. Your browser will redirect to Feishu with your real App ID."
echo
echo "Keep this terminal open until you see 'Successfully logged in' (60s timeout)."
echo

exec "$OFFICIAL_MCP" login \
  -a "$LARK_APP_ID" \
  -s "$LARK_APP_SECRET" \
  -d "$OPEN_DOMAIN" \
  --scope "$SCOPES"
