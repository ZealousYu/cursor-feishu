# 芙芙小助手驯养指南 — 新电脑完整安装 SOP

> **代码仓库（GitHub）**：<GITHUB_REPO_URL>（推送后替换为实际地址）  
> **本文档（飞书）**：https://rcnimfkpyebd.feishu.cn/wiki/DiOlwipeiiWKCgkmWOwcNKOAnGf  
> **Agent 路由 Skill**：仓库内 `.cursor/skills/feishu-cursor-integration/SKILL.md`

---

## 一、芙芙能干什么？

连接 **飞书** 与 **Cursor Agent**，实现：

| 能力 | 工具 |
|------|------|
| 快速读/写 wiki、docx（Markdown） | MCP `lark-doc` |
| 多维表格 CRUD、wiki 移动、docx block API | MCP `lark-official` |
| 文档内嵌入表格 / block 精细编辑 | **Lark CLI** |
| 日历、消息、云盘搜索等 | **Lark CLI** |

Agent 会根据任务自动选择 MCP 或 CLI（见文末「Agent 怎么说」）。

---

## 二、新电脑前置条件

- macOS（本文以 Mac 为例；Linux 同理改路径即可）
- 可访问 [飞书开放平台](https://open.feishu.cn/app)
- 已安装 [Cursor](https://cursor.com)
- 已安装 Git（`git --version`）
- （可选）GitHub CLI：`brew install gh && gh auth login`

---

## 三、一次性：飞书开发者后台

> 若已有自建应用且权限配齐，可跳过至第四节。

### 3.1 创建应用

1. 打开 https://open.feishu.cn/app → **创建企业自建应用**
2. **凭证与基础信息** 复制 **App ID**、**App Secret**

### 3.2 开通权限

**权限管理 → 开通权限**，用户身份 + 应用身份各开一遍：

```
im:chat:create, im:chat, im:message, wiki:wiki, wiki:wiki:readonly,
docx:document, bitable:app, drive:drive, docs:document:import,
contact:user.id:readonly, search:docs:read
```

### 3.3 OAuth 重定向 URL

**安全设置 → 重定向 URL**，添加：

| URL | 用途 |
|-----|------|
| `http://localhost:9997/oauth/callback` | lark-doc MCP |
| `http://localhost:3000/callback` | lark-official MCP |
| `http://localhost:3000/callback?redirect_uri=http://localhost:3000/callback` | lark-official（**必填**） |

开启 **刷新 user_access_token**（若有该选项）。

### 3.4 发布应用

**版本管理与发布** → 创建版本 → 提交审核 → 管理员通过。

---

## 四、新电脑：克隆代码并安装

### 4.1 克隆 GitHub 仓库

```bash
git clone <GITHUB_REPO_URL>.git
cd cursor-feishu
```

> 若仓库为私有，使用 SSH：`git clone git@github.com:<user>/cursor-feishu.git`

### 4.2 一键安装依赖

```bash
chmod +x setup.sh scripts/*.sh
./setup.sh
```

安装内容：便携 Node.js、lovelts/lark-mcp、官方 MCP、Lark CLI、写入 `~/.cursor/mcp.json`。

### 4.3 填写凭证

```bash
cp .env.example .env
# 编辑 .env，填入 LARK_APP_ID 和 LARK_APP_SECRET
# 国内务必保留：LARK_OPEN_DOMAIN=https://open.feishu.cn
```

### 4.4 OAuth 授权（每台电脑各做一次）

```bash
./scripts/login-official.sh          # MCP 官方（浏览器授权，等 Successfully logged in）
./scripts/configure-lark-cli.sh      # 绑定同一 App
./scripts/login-lark-cli.sh          # Lark CLI（钥匙串持久化）
./scripts/install-lark-cli-skills.sh # Agent Skills（lark-doc/block 等）
./scripts/install-project-skill.sh   # 安装 MCP/CLI 路由 Skill 到 ~/.cursor/skills
```

`lark-doc` MCP：首次在 Cursor 里读写文档时，浏览器可能再弹一次（端口 9997）。

### 4.5 重启 Cursor

**Settings → MCP**，确认 `lark-doc`、`lark-official` 均为 **绿色**。

### 4.6 验证

```bash
./scripts/verify-setup.sh
export PATH=".node/bin:$PATH"
./scripts/lark-cli.sh auth status    # user.available 应为 true
```

---

## 五、目录结构速查

```text
cursor-feishu/
├── setup.sh                 # 一键安装
├── SOP.md                   # 本文件（与飞书 wiki 同步）
├── .env                     # 凭证（勿提交 Git）
├── scripts/
│   ├── lark-cli.sh          # lark-cli 包装（自动带 Node PATH）
│   ├── login-official.sh
│   ├── login-lark-cli.sh
│   └── verify-setup.sh
├── .cursor/skills/feishu-cursor-integration/  # MCP vs CLI 路由
└── feishu-sync/             # 本地文档镜像
```

---

## 六、Agent 怎么说？（不用记命令）

直接说目标即可，例如：

| 你说 | Agent 会用 |
|------|-----------|
| 读这个飞书 wiki 并总结 | MCP `lark-doc` |
| 在文档末尾追加一段 | MCP `lark-doc` |
| 查多维表格并新增一行 | MCP `lark-official` |
| 把 xx 文档移到蓝麟下 | MCP `lark-official` |
| **读文档里的竞品对比表** | **Lark CLI** fetch + sheets |
| **改文档内表格某一格** | **Lark CLI** block/sheets |
| 查明天日历 | Lark CLI |

Agent 加载 Skill **`feishu-cursor-integration`** 后会自动路由；也可显式说：「按 feishu-cursor-integration skill 处理」。

---

## 七、MCP vs Lark CLI 路由表（给 Agent / 人工排查）

| 场景 | 首选 |
|------|------|
| URL 含 `/base/` | MCP lark-official |
| 简单 Markdown 读写 | MCP lark-doc |
| wiki 移动 / 搜索 | MCP lark-official |
| 文档内 **嵌入 sheet** 或 block 级编辑 | Lark CLI |
| 日历 / IM / 云盘 | Lark CLI |
| MCP 只读到标题、无正文 | 改 Lark CLI（含 sheet 的文档） |

**lark-cli 务必带 Node：**

```bash
./scripts/lark-cli.sh docs +fetch --api-version v2 --doc "<wiki_url>" --detail full --doc-format xml
./scripts/lark-cli.sh sheets +csv-get --spreadsheet-token "<token>" --sheet-id "<id>"
```

---

## 八、常见问题

| 现象 | 处理 |
|------|------|
| `env: node: No such file or directory` | 用 `./scripts/lark-cli.sh`，勿直接跑裸 `lark-cli` |
| `cd cursor-feishu` 找不到目录 | 路径是 `~/cursorProject/cursor-feishu` 或你 clone 的位置 |
| MCP 变红 | `./scripts/verify-setup.sh`，重新 OAuth |
| OAuth 20028 | 检查飞书后台重定向 URL 三条是否齐全 |
| 读文档只有标题 | 文档含嵌入表格 → 用 Lark CLI |

---

## 九、换电脑迁移清单

- [ ] `git clone` 仓库
- [ ] `./setup.sh`
- [ ] 复制或重新填写 `.env`（**勿把 .env 提交 Git**）
- [ ] `./scripts/login-official.sh`
- [ ] `./scripts/configure-lark-cli.sh && ./scripts/login-lark-cli.sh`
- [ ] `./scripts/install-lark-cli-skills.sh`
- [ ] 重启 Cursor，MCP 绿色
- [ ] `./scripts/verify-setup.sh` 通过

---

## 十、相关链接

- GitHub：<GITHUB_REPO_URL>
- 飞书后台：https://open.feishu.cn/app
- 详细权限清单：仓库 `FEISHU_APP_CHECKLIST.md`
- 测试用例：仓库 `TEST_PROMPTS.md`
