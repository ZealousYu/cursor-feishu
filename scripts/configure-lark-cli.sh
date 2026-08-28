#!/usr/bin/env bash
# Bind existing Feishu app credentials from .env to lark-cli (non-interactive).
set -euo pipefail

CURSOR_FEISHU_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$CURSOR_FEISHU_ROOT/.env"
NODE_BIN="$CURSOR_FEISHU_ROOT/.node/bin"
LARK_CLI="$CURSOR_FEISHU_ROOT/node_modules/.bin/lark-cli"

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

echo "==> Configuring lark-cli with existing Feishu app"
echo "App ID: $LARK_APP_ID"
echo

printf '%s' "$LARK_APP_SECRET" | "$LARK_CLI" config init \
  --app-id "$LARK_APP_ID" \
  --app-secret-stdin \
  --brand feishu

echo
"$LARK_CLI" config show
