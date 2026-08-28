#!/usr/bin/env bash
# OAuth login for lark-cli (user identity, persistent keychain storage).
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

export PATH="$NODE_BIN:$PATH"

if ! "$LARK_CLI" config show >/dev/null 2>&1; then
  echo "lark-cli not configured. Run: ./scripts/configure-lark-cli.sh" >&2
  exit 1
fi

DOMAINS="${LARK_CLI_AUTH_DOMAINS:-docs,wiki,base,drive,calendar,im}"

echo "==> lark-cli OAuth login"
echo "Domains: $DOMAINS"
echo
echo "A browser window will open. Complete authorization in Feishu."
echo "Token is stored in your system keychain — usually no re-login for a long time."
echo

exec "$LARK_CLI" auth login --recommend --domain "$DOMAINS"
