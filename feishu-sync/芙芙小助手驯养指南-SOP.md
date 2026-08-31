# 芙芙小助手驯养指南（SOP）

> **用途**：在新电脑上从零配置「飞书 + Cursor Agent」全能力集成。
>
> **最后更新**：2026-08-28

---

## 一、芙芙能干什么？

连接飞书与 Cursor，让 Agent **直接读写**你的飞书文档、多维表格、知识库。

**场景速查（不用记命令，对 Agent 说人话即可）：**

- **快速读/写 wiki / docx** → 用 MCP `lark-doc`
  - 例：「读这个飞书链接并总结」

- **多维表格增删改查** → 用 MCP `lark-official`
  - 例：「查这个 base 表格所有记录」

- **文档内嵌入表格 / Block 精细编辑** → 用 **Lark CLI**
  - 例：「用 lark-cli fetch 读 block 并整理成表格」

- **移动 wiki 目录** → MCP 或脚本
  - 例：「把 xx 文档移到蓝麟下」

- **日历 / 消息 / 云盘** → **Lark CLI**
  - 例：「查我明天日程」

**日常用法**：配置好后，直接跟 Cursor Agent 描述任务即可。只有**换电脑**或**首次安装**时才需要跑下面步骤。

---

## 二、前置条件

### 2.1 新电脑需要安装

- Cursor（已登录账号）
- Git（拉取项目代码）
- 网络可访问 open.feishu.cn

> 本项目自带便携 Node（`.node/` 目录），**不必单独装 Node**。但手动跑命令时要先加 PATH（见 Step 0）。

### 2.2 飞书侧（换电脑不用重做）

沿用**同一套**企业自建应用即可：

- 已在 [飞书开发者后台](https://open.feishu.cn/app) 创建应用
- 已记录 **App ID**、**App Secret**
- 应用已发布（或对你可见）

### 2.3 获取项目代码

```bash
git clone <你的仓库地址>
cd <项目名>/cursor-feishu
```

**常见路径**（按实际调整）：

```bash
cd ~/cursorProject/cursor-feishu
```

⚠️ **注意**：不是 `~/cursor-feishu`，项目在 `cursorProject` 仓库里面。

---

## 三、飞书开发者后台（首次或加权限时）

打开：`https://open.feishu.cn/app/<AppID>/safe`

### 3.1 开通权限

**权限管理 → 开通权限**，用户身份 + 应用身份**各开一遍**，批量粘贴：

```
im:chat:create, im:chat, im:message, wiki:wiki, wiki:wiki:readonly,
docx:document, bitable:app, drive:drive, docs:document:import,
contact:user.id:readonly, search:docs:read
```

**权限说明：**

- `docx:document` — 云文档读写
- `bitable:app` — 多维表格
- `drive:drive` — 云盘搜索
- `wiki:wiki` — 知识库节点移动
- `wiki:wiki:readonly` — 知识库搜索
- `search:docs:read` — 文档搜索

### 3.2 OAuth 重定向 URL（三条都要加）

1. `http://localhost:9997/oauth/callback` — lark-doc MCP
2. `http://localhost:3000/callback` — lark-official MCP
3. `http://localhost:3000/callback?redirect_uri=http://localhost:3000/callback` — 官方 MCP 实际回调（**必填**）

另：若有「刷新 user_access_token」开关，请开启。

### 3.3 发布应用

**版本管理与发布** → 创建版本 → 审核通过。

新增权限后需重新发布，并在新电脑重新 OAuth。

---

## 四、新电脑本地安装（按顺序）

以下均在 **cursor-feishu** 目录执行。

### Step 0：进入目录 + 设置 PATH

```bash
cd ~/cursorProject/cursor-feishu
export PATH="$(pwd)/.node/bin:$PATH"
```

> 以后手动跑 `lark-cli` 也要先 export PATH，或直接用 `./scripts/` 下脚本（已内置 PATH）。

### Step 1：一键安装

```bash
./setup.sh
```

安装内容：便携 Node、lovelts/lark-mcp、官方 lark-mcp、Lark CLI，并生成 `~/.cursor/mcp.json`。

### Step 2：填写凭证

```bash
cp .env.example .env
```

编辑 `.env`，填入 `LARK_APP_ID` 和 `LARK_APP_SECRET`。

必须保留：`LARK_OPEN_DOMAIN=https://open.feishu.cn`

### Step 3：OAuth 授权（新电脑各做一次）

```bash
./scripts/login-official.sh
./scripts/configure-lark-cli.sh
./scripts/login-lark-cli.sh
./scripts/install-lark-cli-skills.sh
```

说明：

- `login-official.sh` — 等终端显示 Successfully logged in
- `login-lark-cli.sh` — 浏览器授权，token 存钥匙串
- `install-lark-cli-skills.sh` — 安装约 28 个 lark-* Agent Skills
- **lark-doc**：Cursor 里首次读写文档时，浏览器可能再弹一次（端口 9997）

### Step 4：重启 Cursor

Settings → MCP → 确认 `lark-doc` 和 `lark-official` 均为**绿色**。

### Step 5：验证

```bash
export PATH=".node/bin:$PATH"
./scripts/verify-setup.sh
./node_modules/.bin/lark-cli auth status
```

`auth status` 里 `user.available` 应为 `true`。

---

## 五、验收测试（Agent 模式粘贴）

**5.1 读 wiki**

```
读取这个飞书文档并总结要点：
https://rcnimfkpyebd.feishu.cn/wiki/DiOlwipeiiWKCgkmWOwcNKOAnGf
```

**5.2 读文档内嵌入表格**

```
请用 lark-cli docs +fetch --api-version v2 读取这个 wiki 的 block 结构，
把嵌入表格整理成 Markdown 表格：
https://rcnimfkpyebd.feishu.cn/wiki/ObnXwHvvhioGX5kBYjXcICocnAe
```

**5.3 多维表格**

```
查询这个多维表格的所有记录：<你的 base 链接>
```

**5.4 本地同步**

```
把这个飞书文档保存到 cursor-feishu/feishu-sync/xxx.md：<URL>
```

**验收勾选：**

- [ ] MCP 两个服务绿色
- [ ] 能读/写飞书文档
- [ ] 能查/改多维表格
- [ ] lark-cli 用户身份 ready
- [ ] 能 fetch 文档内 sheet/表格

---

## 六、日常怎么用

1. **不用**每天开终端
2. 打开 Cursor → Agent 模式 → 自然语言描述任务
3. Agent 自动选 MCP 或 Lark CLI

**示例：**

- 「在文档末尾追加本周总结：<wiki链接>」
- 「把任务文档移到蓝麟目录下」
- 「查竞品调研 wiki 里的表格并对比下载量」

**换电脑后要重新授权的部分：**

- lark-official MCP → 重跑 `login-official.sh`
- lark-cli → 重跑 `login-lark-cli.sh`（钥匙串持久化）
- lark-doc → Cursor 重启后首次用文档可能弹窗

---

## 七、架构说明

```
你 → Cursor Agent
     ├─ MCP lark-doc       → 快速 Markdown 文档读写
     ├─ MCP lark-official  → 多维表格 / 搜索 / wiki 移动 / block API
     └─ Shell lark-cli     → block 精细编辑 / 日历 / IM / 云盘
            ↑
       Agent Skills（~/.agents/skills/lark-*）
```

**项目目录：**

```
cursor-feishu/
├── setup.sh          一键安装
├── .env              App 凭证（勿提交 git）
├── scripts/          MCP 启动、OAuth、验证
├── feishu-sync/      本地文档镜像
├── vendor/lark-mcp/  lovelts 文档 MCP
├── .node/            便携 Node
└── node_modules/     官方 MCP + Lark CLI
```

---

## 八、常见问题

**Q：`env: node: No such file or directory`**

A：未加 PATH。执行 `export PATH=".node/bin:$PATH"` 或用 `./scripts/*.sh`。

**Q：`cd: no such file or directory: cursor-feishu`**

A：路径错了。用 `~/cursorProject/cursor-feishu`。

**Q：OAuth 报错 20028 client_id 不合法**

A：重定向 URL 未配全，检查第三节 3.2 三条 URL。

**Q：Token exchange 404**

A：`.env` 里必须是 `LARK_OPEN_DOMAIN=https://open.feishu.cn`，不要用 `feishu.cn`。

**Q：读 wiki 只有标题，没有表格内容**

A：表格可能是嵌入 sheet，需 lark-cli `docs +fetch` + `sheets +csv-get`。

**Q：MCP 变红**

A：重跑对应 login 脚本，重启 Cursor。

---

## 九、换电脑 Checklist

- [ ] 安装 Cursor + Git
- [ ] clone 项目，cd 到 cursor-feishu
- [ ] `./setup.sh`
- [ ] 填写 `.env`
- [ ] `./scripts/login-official.sh`
- [ ] `./scripts/configure-lark-cli.sh`
- [ ] `./scripts/login-lark-cli.sh`
- [ ] `./scripts/install-lark-cli-skills.sh`
- [ ] 重启 Cursor，MCP 绿色
- [ ] `./scripts/verify-setup.sh` 通过
- [ ] Agent 跑一条验收测试

---

## 十、附录：手动 lark-cli 命令

```bash
cd ~/cursorProject/cursor-feishu
export PATH=".node/bin:$PATH"

# 读文档 block 结构
./node_modules/.bin/lark-cli docs +fetch --api-version v2 \
  --doc "<wiki或docx链接>" --detail full --doc-format xml

# 读嵌入电子表格
./node_modules/.bin/lark-cli sheets +csv-get \
  --spreadsheet-token "<token>" --sheet-id "<sheet_id>"

# 查看登录状态
./node_modules/.bin/lark-cli auth status
```

---

*驯养愉快 🦊*
