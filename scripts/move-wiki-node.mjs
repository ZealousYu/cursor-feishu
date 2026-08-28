#!/usr/bin/env node
/**
 * Move a Feishu wiki node under another parent node (user OAuth token).
 * Usage: node scripts/move-wiki-node.mjs <node_token> <target_parent_token> [space_id]
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';
import * as lark from '@larksuiteoapi/node-sdk';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(__dirname, '..');
const envFile = path.join(root, '.env');

if (fs.existsSync(envFile)) {
  dotenv.config({ path: envFile });
}

const { authStore } = await import('@larksuiteoapi/lark-mcp/dist/auth/store.js');
const { isTokenValid } = await import('@larksuiteoapi/lark-mcp/dist/auth/utils/is-token-valid.js');
const { LarkOAuth2OAuthServerProvider } = await import(
  '@larksuiteoapi/lark-mcp/dist/auth/provider/oauth.js'
);

const appId = process.env.LARK_APP_ID;
const appSecret = process.env.LARK_APP_SECRET;
const domain = process.env.LARK_OPEN_DOMAIN || 'https://open.feishu.cn';

const [nodeToken, targetParentToken, spaceIdArg] = process.argv.slice(2);
if (!appId || !appSecret) {
  console.error('Missing LARK_APP_ID or LARK_APP_SECRET in .env');
  process.exit(1);
}
if (!nodeToken || !targetParentToken) {
  console.error('Usage: node scripts/move-wiki-node.mjs <node_token> <target_parent_token> [space_id]');
  process.exit(1);
}

async function getUserAccessToken() {
  await authStore.initialize();
  const tokenKey = await authStore.getLocalAccessToken(appId);
  if (!tokenKey) {
    throw new Error('No user OAuth token. Run: ./scripts/login-official.sh');
  }
  const tokenInfo = await authStore.getToken(tokenKey);
  if (!tokenInfo?.token) {
    throw new Error('Stored OAuth token is missing. Re-run ./scripts/login-official.sh');
  }

  const { valid, isExpired } = await isTokenValid(tokenInfo.token);
  if (valid) {
    return tokenInfo.token;
  }

  const refreshToken = tokenInfo.extra?.refreshToken;
  if (isExpired && refreshToken) {
    const provider = new LarkOAuth2OAuthServerProvider({
      appId,
      appSecret,
      domain,
      callbackUrl: 'http://localhost:3000/callback',
    });
    const refreshed = await provider.refreshToken(refreshToken);
    if (refreshed?.access_token) {
      await authStore.storeLocalAccessToken(refreshed.access_token, appId);
      return refreshed.access_token;
    }
  }

  throw new Error('OAuth token expired. Re-run: ./scripts/login-official.sh');
}

const spaceId = spaceIdArg || '7654523122116316134';
const userAccessToken = await getUserAccessToken();

const client = new lark.Client({
  appId,
  appSecret,
  domain,
  disableTokenCache: true,
});

const response = await client.wiki.v2.spaceNode.move(
  {
    path: {
      space_id: spaceId,
      node_token: nodeToken,
    },
    data: {
      target_parent_token: targetParentToken,
      target_space_id: spaceId,
    },
  },
  lark.withUserAccessToken(userAccessToken),
);

if (response.code !== 0) {
  console.error(JSON.stringify(response, null, 2));
  process.exit(1);
}

console.log(JSON.stringify({ ok: true, node_token: nodeToken, target_parent_token: targetParentToken, space_id: spaceId }, null, 2));
