# 芙芙小助手驯养指南（飞书 × Cursor 全能力 SOP）

> **代码仓库**：https://github.com/PLACEHOLDER/cursor-feishu  
> **适用场景**：在新电脑上从零配置「飞书文档 / 多维表格 / Block 编辑 + Cursor Agent」  
> **最后更新**：2026-08-28

---

## 一、芙芙能干什么？

连接飞书与 Cursor，让 Agent **以你的身份**直接：

| 能力 | 说明 |
|------|------|
| 读/写云文档、wiki | Markdown 级快速读写 |
| 多维表格 CRUD | 查/增/改记录 |
| **文档内嵌入表格** | 读 sheet、block 级精细编辑 |
| 移动 wiki 目录 | 把文档挪到指定文件夹下 |
| 日历 / 消息 / 云盘 | 通过 Lark CLI 扩展 |

**三套引擎并存**（Agent 会自动选，见文末「路由规则」）：

1. **MCP `lark-doc`** — 快速 Markdown 读写  
2. **MCP `lark-official`** — 多维表格、wiki 移动、block API  
3. **Lark CLI** — 嵌入 sheet、block_replace、日历/IM 等  

---

## 二、新电脑安装（约 30 分钟）

### 0. 前置条件

- macOS（本文以 Mac 为例；Windows 需自行调整路径）
- 能访问 [飞书开放平台](https://open.feishu.cn/app)
- 已安装 [Cursor](https://cursor.com)
- 已安装 **git**（`git --version` 可用）

### 1. 克隆代码

```bash
git clone https://github.com/PLACEHOLDER/cursor-feishu.git
cd cursor-feishu
```

若放在更大 monorepo 里，确保路径例如：`~/Projects/cursor-feishu`。

### 2. 一键安装依赖

```bash
./setup.sh
```

会自动：便携 Node.js、lovelts/lark-mcp、官方 MCP、Lark CLI、写入 `~/.cursor/mcp.json`。

### 3. 飞书开发者后台（只做一次，换电脑不用重做）

打开 [飞书开发者后台](https://open.feishu.cn/app) → 你的自建应用。

#### 3.1 权限（用户身份 + 应用身份各开一遍）

```
im:chat:create, im:chat, im:message, wiki:wiki, wiki:wiki:readonly,
docx:document, bitable:app, drive:drive, docs:document:import,
contact:user.id:readonly, search:docs:read
```

#### 3.2 OAuth 重定向 URL（安全设置 → 重定向 URL）

| URL | 用途 |
|-----|------|
| `http://localhost:9997/oauth/callback` | lark-doc MCP |
| `http://localhost:3000/callback` | 官方 MCP |
| `http://localhost:3000/callback?redirect_uri=http://localhost:3000/callback` | 官方 MCP（**必填**） |

开启 **刷新 user_access_token**。改权限后需重新发布应用。

### 4. 填写本地凭证

```bash
cp .env.example .env
# 编辑 .env，填入 LARK_APP_ID、LARK_APP_SECRET
# 必须保留：LARK_OPEN_DOMAIN=https://open.feishu.cn
```

### 5. OAuth 授权（每台新电脑各做一次）

```bash
./scripts/login-official.sh      # 官方 MCP → 浏览器授权，看到 Successfully logged in
./scripts/configure-lark-cli.sh  # 绑定同一 App
./scripts/login-lark-cli.sh      # Lark CLI → 浏览器授权（token 存钥匙串）
./scripts/install-lark-cli-skills.sh  # 安装 Agent Skills（可选但强烈推荐）
```

`lark-doc` MCP：首次在 Cursor 里读写文档时可能再弹一次浏览器（端口 9997）。

### 6. 重启 Cursor 并验证

Settings → MCP → **`lark-doc`**、**`lark-official`** 均为绿色。

```bash
./scripts/verify-setup.sh
export PATH=".node/bin:$PATH"
./scripts/lark-cli.sh auth status   # user.available 应为 true
```

### 7. 安装项目 Skill（Agent 自动选 MCP / CLI）

本仓库已含 `.cursor/skills/feishu-cursor-integration/`。  
若 Cursor 未自动加载，将 skill 复制到个人目录：

```bash
mkdir -p ~/.cursor/skills
cp -R .cursor/skills/feishu-cursor-integration ~/.cursor/skills/
```

重启 Cursor 后，Agent 处理飞书任务时会先读该 Skill 再选工具。

---

## 三、日常使用（不用记命令）

直接对 Agent 说人话即可，例如：

```
读这个 wiki 并总结：https://xxx.feishu.cn/wiki/xxx
把「任务」文档移到「蓝麟」下
查这个多维表格所有记录：https://xxx.feishu.cn/base/xxx
读竞品调研 wiki 里的表格，整理成 Markdown
在文档末尾追加一段说明
```

Agent 会根据任务类型自动选 **MCP** 或 **Lark CLI**（见第四节）。

---

## 四、Agent 路由规则（MCP vs Lark CLI）

> Skill 文件：仓库 `.cursor/skills/feishu-cursor-integration/SKILL.md`

| 你的需求 | Agent 用什么 |
|----------|-------------|
| 读/写纯文本、Markdown 追加 | MCP `lark-doc` |
| 多维表格 `/base/` | MCP `lark-official` |
| 移动 wiki 节点 | MCP `lark-official` 或 `scripts/move-wiki-node.mjs` |
| **文档内嵌入表格**（fetch 只有标题） | **Lark CLI**：`docs +fetch xml` → `sheets +csv-get` |
| block_replace / 改单元格 / 复杂排版 | **Lark CLI** |
| 日历 / 消息 / 云盘 | **Lark CLI** |

**CLI 务必用包装脚本**（避免 `env: node: No such file`）：

```bash
./scripts/lark-cli.sh docs +fetch --api-version v2 --doc "<url>" --detail full --doc-format xml
./scripts/lark-cli.sh sheets +csv-get --spreadsheet-token "<token>" --sheet-id "<id>"
```

---

## 五、授权与维护

| 组件 | 新电脑要重做？ | 持久化 |
|------|---------------|--------|
| 飞书应用配置 | 否（云端） | 开发者后台 |
| `.env` | 是（复制 App ID/Secret） | 本地文件 |
| lark-official MCP OAuth | 是 | `~/.lark-mcp/` |
| lark-cli OAuth | 是 | 系统钥匙串 |
| lark-doc MCP | 首次用文档可能弹窗 | 内存（重启 Cursor 可能再授权） |

**常见问题**

| 现象 | 处理 |
|------|------|
| `env: node: No such file` | 用 `./scripts/lark-cli.sh`，不要裸跑 `lark-cli` |
| MCP 变红 | `./setup.sh` → 重启 Cursor |
| OAuth 20028 | 检查重定向 URL 是否配齐 3 条 |
| 读文档只有标题 | 文档含嵌入 sheet → 走 Lark CLI |
| 权限不足 | 后台补权限 → 发布 → 重新 OAuth |

---

## 六、目录与脚本速查

```text
cursor-feishu/
├── setup.sh                 # 一键安装
├── SOP.md                   # 本文（与飞书 wiki 同步）
├── FEISHU_APP_CHECKLIST.md  # 飞书后台清单
├── TEST_PROMPTS.md          # Agent 测试话术
├── scripts/
│   ├── lark-cli.sh          # CLI 包装（必用）
│   ├── login-official.sh    # MCP OAuth
│   ├── login-lark-cli.sh    # CLI OAuth
│   ├── configure-lark-cli.sh
│   ├── verify-setup.sh
│   └── move-wiki-node.mjs
└── .cursor/skills/feishu-cursor-integration/  # Agent 路由 Skill
```

---

## 七、验收清单（新电脑配置完成打勾）

- [ ] `git clone` 成功，`./setup.sh` 无报错  
- [ ] `.env` 已填真实 App ID / Secret  
- [ ] 飞书后台 3 条重定向 URL + 权限已开  
- [ ] `./scripts/login-official.sh` 成功  
- [ ] `./scripts/login-lark-cli.sh` 成功，`auth status` 中 user 为 ready  
- [ ] Cursor MCP 两个 server 绿色  
- [ ] Agent 能读一篇 wiki 文档  
- [ ] Agent 能用 lark-cli 读出嵌入 sheet 表格（竞品调研类文档）  

---

## 八、参考链接

- 代码仓库：https://github.com/PLACEHOLDER/cursor-feishu  
- 飞书开放平台：https://open.feishu.cn/app  
- Lark CLI 官方：https://feishu-cli.com/  
- 本 SOP 飞书 wiki：https://rcnimfkpyebd.feishu.cn/wiki/DiOlwipeiiWKCgkmWOwcNKOAnGf  
