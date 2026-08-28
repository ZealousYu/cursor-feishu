#!/usr/bin/env bash
# Wrapper: run lark-cli with portable Node from cursor-feishu/.node
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="$ROOT/.node/bin:$PATH"
exec "$ROOT/node_modules/.bin/lark-cli" "$@"
