# 飞书自建应用配置清单

在 [飞书开发者后台](https://open.feishu.cn/app) 完成以下步骤，然后将 App ID / App Secret 填入 [`cursor-feishu/.env`](./.env)。

## 1. 创建应用

- 企业自建应用 → 填写名称（如 `Cursor Agent`）→ 创建
- **凭证与基础信息** 页复制 **App ID**、**App Secret**

## 2. 开通权限

在 **权限管理 → 开通权限**，批量粘贴（**用户身份** 和 **应用身份** 各开一遍）：

```
im:chat:create, im:chat, im:message, wiki:wiki, wiki:wiki:readonly,
docx:document, bitable:app, drive:drive, docs:document:import,
contact:user.id:readonly, search:docs:read
```

| 权限 | 用途 |
|------|------|
| `docx:document` | 云文档读写 |
| `bitable:app` | 多维表格 CRUD |
| `drive:drive` | 云文档搜索 |
| `wiki:wiki` | 知识库节点移动、写入 |
| `wiki:wiki:readonly` | 知识库搜索 |

## 3. OAuth 重定向 URL

**安全设置 → 重定向 URL** 添加（两条都要加）：

| URL | 用于 |
|-----|------|
| `http://localhost:9997/oauth/callback` | lovelts/lark-mcp（文档 CRUD） |
| `http://localhost:3000/callback` | 官方 lark-mcp（多维表格） |
| `http://localhost:3000/callback?redirect_uri=http://localhost:3000/callback` | 官方 lark-mcp（实际 OAuth 回调，**必填**） |

> 注意：lovelts 的路径是 `/oauth/callback`，不是 `/callback`。
>
> 若 OAuth 报错 **20028 client_id 不合法**，通常是重定向 URL 未配全，或应用未发布。终端里出现 `client_id_for_local_auth` 是正常现象（本地代理），不是你的 App ID 错了。

若有 **刷新 user_access_token** 开关，请开启。

## 4. 发布应用

**版本管理与发布** → 创建版本 → 提交审核 → 管理员通过后生效。

新增权限后需重新发布，并重新 OAuth 登录。

## 5. 填写本地配置

```bash
cp cursor-feishu/.env.example cursor-feishu/.env
# 编辑 .env，填入 LARK_APP_ID 和 LARK_APP_SECRET
# 官方 MCP 必须使用 LARK_OPEN_DOMAIN=https://open.feishu.cn（不要用 feishu.cn）
```

## 6. OAuth 授权

```bash
cd cursor-feishu
./scripts/login-official.sh          # 官方 MCP（多维表格 + block + wiki move）
./scripts/configure-lark-cli.sh      # 绑定同一 App 到 lark-cli
./scripts/login-lark-cli.sh          # lark-cli（Block 编辑、日历、消息等）
./scripts/install-lark-cli-skills.sh # Cursor Agent Skills
# lark-doc 首次在 Cursor Agent 调用文档工具时自动弹出浏览器授权
```

## 7. 重启 Cursor

Settings → MCP → 确认 `lark-doc` 和 `lark-official` 均为绿色。
