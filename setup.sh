#!/usr/bin/env bash
# One-time setup for Feishu + Cursor MCP integration.
set -euo pipefail

CURSOR_FEISHU_ROOT="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$CURSOR_FEISHU_ROOT/.." && pwd)"
NODE_DIR="$CURSOR_FEISHU_ROOT/.node"
LARK_MCP_DIR="$CURSOR_FEISHU_ROOT/vendor/lark-mcp"
LEGACY_LARK_MCP="$HOME/lark-mcp"

echo "==> Feishu + Cursor MCP setup"
echo "    Root: $CURSOR_FEISHU_ROOT"
echo

# 1. Portable Node.js
if [[ ! -x "$NODE_DIR/bin/node" ]]; then
  if [[ -x "$LEGACY_LARK_MCP/.node/bin/node" ]]; then
    echo "Linking existing portable Node from ~/lark-mcp/.node ..."
    ln -sf "$LEGACY_LARK_MCP/.node" "$NODE_DIR"
  else
    echo "Installing portable Node.js to $NODE_DIR ..."
    mkdir -p "$NODE_DIR"
    ARCH="$(uname -m)"
    NODE_VERSION="v22.14.0"
    if [[ "$ARCH" == "arm64" ]]; then
      NODE_PKG="node-${NODE_VERSION}-darwin-arm64.tar.gz"
    else
      NODE_PKG="node-${NODE_VERSION}-darwin-x64.tar.gz"
    fi
    curl -fsSL "https://nodejs.org/dist/${NODE_VERSION}/${NODE_PKG}" -o "/tmp/${NODE_PKG}"
    tar -xzf "/tmp/${NODE_PKG}" -C "$NODE_DIR" --strip-components=1
    rm "/tmp/${NODE_PKG}"
  fi
fi
export PATH="$NODE_DIR/bin:$PATH"
echo "Node: $(node -v) | npm: $(npm -v)"

# 2. lovelts/lark-mcp under cursor-feishu/vendor
mkdir -p "$CURSOR_FEISHU_ROOT/vendor"
if [[ ! -d "$LARK_MCP_DIR/.git" ]]; then
  if [[ -d "$LEGACY_LARK_MCP/.git" ]]; then
    echo "Linking existing lovelts/lark-mcp from ~/lark-mcp ..."
    ln -sf "$LEGACY_LARK_MCP" "$LARK_MCP_DIR"
  else
    echo "Cloning lovelts/lark-mcp ..."
    git clone https://github.com/lovelts/lark-mcp.git "$LARK_MCP_DIR"
  fi
fi
if [[ ! -d "$LARK_MCP_DIR/node_modules" ]]; then
  echo "Installing lark-mcp dependencies ..."
  printf 'registry=https://registry.npmjs.org/\n' > "$LARK_MCP_DIR/.npmrc"
  (cd "$LARK_MCP_DIR" && HOME=/tmp/npm-isolated-home NPM_CONFIG_CACHE="$LARK_MCP_DIR/.npm-cache-clean" npm install --registry=https://registry.npmjs.org/)
fi

# 3. Official lark-mcp (local in cursor-feishu)
if [[ ! -d "$CURSOR_FEISHU_ROOT/node_modules/@larksuiteoapi/lark-mcp" ]]; then
  echo "Installing @larksuiteoapi/lark-mcp ..."
  printf 'registry=https://registry.npmjs.org/\n' > "$CURSOR_FEISHU_ROOT/.npmrc"
  (cd "$CURSOR_FEISHU_ROOT" && HOME=/tmp/npm-isolated-home NPM_CONFIG_CACHE="$CURSOR_FEISHU_ROOT/.npm-cache-clean" npm install @larksuiteoapi/lark-mcp --registry=https://registry.npmjs.org/)
fi

# 4. Lark CLI (official, for block-level doc edits + calendar/im/etc.)
if [[ ! -x "$CURSOR_FEISHU_ROOT/node_modules/.bin/lark-cli" ]]; then
  echo "Installing @larksuite/cli ..."
  (cd "$CURSOR_FEISHU_ROOT" && PATH="$NODE_DIR/bin:$PATH" npm install @larksuite/cli --save-dev --registry=https://registry.npmjs.org/)
fi

# 5. .env
if [[ ! -f "$CURSOR_FEISHU_ROOT/.env" ]]; then
  if [[ -f "$CURSOR_FEISHU_ROOT/feishu-integration/.env" ]]; then
    cp "$CURSOR_FEISHU_ROOT/feishu-integration/.env" "$CURSOR_FEISHU_ROOT/.env"
  else
    cp "$CURSOR_FEISHU_ROOT/.env.example" "$CURSOR_FEISHU_ROOT/.env"
  fi
  echo
  echo "Created $CURSOR_FEISHU_ROOT/.env — please fill LARK_APP_ID and LARK_APP_SECRET before OAuth."
fi

# 6. MCP config
chmod +x "$CURSOR_FEISHU_ROOT"/scripts/*.sh
"$CURSOR_FEISHU_ROOT/scripts/generate-mcp-config.sh"

# 7. Sync dirs
mkdir -p "$CURSOR_FEISHU_ROOT/feishu-sync" "$PROJECT_ROOT/CV_Helper/docs"

echo
echo "Next steps:"
echo "  1. Complete Feishu app setup: see FEISHU_APP_CHECKLIST.md"
echo "  2. Edit cursor-feishu/.env with App ID and Secret"
echo "  3. Run: ./scripts/login-official.sh   (official MCP OAuth)"
echo "  4. Run: ./scripts/configure-lark-cli.sh && ./scripts/login-lark-cli.sh"
echo "  5. Run: ./scripts/install-lark-cli-skills.sh  (Agent block-edit skills)"
echo "  6. Restart Cursor; lark-doc OAuth happens on first tool call"
echo "  7. Test with prompts in TEST_PROMPTS.md"
