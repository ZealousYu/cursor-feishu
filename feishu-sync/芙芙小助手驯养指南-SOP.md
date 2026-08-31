# 芙芙小助手驯养指南（SOP）

**用途**：在新电脑上从零配置「飞书 + Cursor Agent」全能力集成。

**最后更新**：2026-08-28

## 一、芙芙能干什么？

连接飞书与 Cursor，让 Agent 直接读写你的飞书文档、多维表格、知识库。

**场景速查（对 Agent 说人话即可，不用记命令）：**

**① 快速读/写 wiki 或 docx** — 工具：MCP lark-doc — 例：「读这个飞书链接并总结」

**② 多维表格增删改查** — 工具：MCP lark-official — 例：「查这个 base 表格所有记录」

**③ 文档内嵌入表格 / Block 编辑** — 工具：Lark CLI — 例：「用 lark-cli fetch 读 block 并整理成表格」

**④ 移动 wiki 目录** — 工具：MCP 或脚本 — 例：「把 xx 文档移到蓝麟下」

**⑤ 日历 / 消息 / 云盘** — 工具：Lark CLI — 例：「查我明天日程」

配置完成后，日常直接跟 Agent 描述任务即可。只有换电脑或首次安装时才需要跑下面步骤。

## 二、前置条件

**2.1 新电脑需要安装**

Cursor（已登录）、Git（拉取代码）、网络可访问 open.feishu.cn。

本项目自带便携 Node（.node/ 目录），不必单独装 Node。手动跑命令时要先加 PATH（见 Step 0）。

**2.2 飞书侧（换电脑不用重做）**

沿用同一套企业自建应用：已在飞书开发者后台创建应用、已记录 App ID 和 App Secret、应用已发布。

**2.3 获取项目代码**

git clone 你的仓库地址，然后 cd 到 cursor-feishu 目录。

常见路径：cd ~/cursorProject/cursor-feishu

注意：不是 ~/cursor-feishu，项目在 cursorProject 仓库里面。

## 三、飞书开发者后台（首次或加权限时）

打开：https://open.feishu.cn/app/你的AppID/safe

**3.1 开通权限**

权限管理 → 开通权限，用户身份和应用身份各开一遍，批量粘贴：

im:chat:create, im:chat, im:message, wiki:wiki, wiki:wiki:readonly, docx:document, bitable:app, drive:drive, docs:document:import, contact:user.id:readonly, search:docs:read

权限说明：docx:document 云文档读写 | bitable:app 多维表格 | drive:drive 云盘搜索 | wiki:wiki 知识库移动 | wiki:wiki:readonly 知识库搜索 | search:docs:read 文档搜索

**3.2 OAuth 重定向 URL（三条都要加）**

（1）http://localhost:9997/oauth/callback — lark-doc MCP

（2）http://localhost:3000/callback — lark-official MCP

（3）http://localhost:3000/callback?redirect_uri=http://localhost:3000/callback — 官方 MCP 实际回调（必填）

若有「刷新 user_access_token」开关，请开启。

**3.3 发布应用**

版本管理与发布 → 创建版本 → 审核通过。新增权限后需重新发布并重新 OAuth。

## 四、新电脑本地安装（按顺序）

以下均在 cursor-feishu 目录执行。

**Step 0：进入目录 + 设置 PATH**

cd ~/cursorProject/cursor-feishu

export PATH="$(pwd)/.node/bin:$PATH"

以后手动跑 lark-cli 也要先 export PATH，或直接用 ./scripts/ 下脚本。

**Step 1：一键安装**

./setup.sh

会安装便携 Node、lovelts/lark-mcp、官方 lark-mcp、Lark CLI，并生成 ~/.cursor/mcp.json。

**Step 2：填写凭证**

cp .env.example .env，编辑填入 LARK_APP_ID 和 LARK_APP_SECRET。必须保留 LARK_OPEN_DOMAIN=https://open.feishu.cn

**Step 3：OAuth 授权（新电脑各做一次）**

依次执行：./scripts/login-official.sh → ./scripts/configure-lark-cli.sh → ./scripts/login-lark-cli.sh → ./scripts/install-lark-cli-skills.sh

login-official 等终端显示 Successfully logged in；login-lark-cli 浏览器授权存钥匙串；install-lark-cli-skills 安装约 28 个 lark-* Skills。lark-doc 在 Cursor 首次读写文档时浏览器可能再弹一次（端口 9997）。

**Step 4：重启 Cursor**

Settings → MCP → 确认 lark-doc 和 lark-official 均为绿色。

**Step 5：验证**

export PATH=".node/bin:$PATH"

./scripts/verify-setup.sh

./node_modules/.bin/lark-cli auth status

auth status 里 user.available 应为 true。

## 五、验收测试（Agent 模式粘贴）

**5.1 读 wiki**：读取这个飞书文档并总结要点：https://rcnimfkpyebd.feishu.cn/wiki/DiOlwipeiiWKCgkmWOwcNKOAnGf

**5.2 读嵌入表格**：请用 lark-cli docs +fetch --api-version v2 读取 wiki block 结构并整理表格：https://rcnimfkpyebd.feishu.cn/wiki/ObnXwHvvhioGX5kBYjXcICocnAe

**5.3 多维表格**：查询这个多维表格的所有记录：（填你的 base 链接）

**5.4 本地同步**：把这个飞书文档保存到 cursor-feishu/feishu-sync/xxx.md：（填 URL）

验收勾选：MCP 两个服务绿色 / 能读写文档 / 能查改多维表格 / lark-cli 用户身份 ready / 能 fetch 嵌入 sheet

## 六、日常怎么用

不用每天开终端。打开 Cursor Agent 模式，用自然语言描述任务，Agent 自动选 MCP 或 Lark CLI。

示例：「在文档末尾追加本周总结」/ 「把任务文档移到蓝麟下」/ 「查竞品调研 wiki 表格对比下载量」

换电脑后需重新授权：lark-official 重跑 login-official.sh；lark-cli 重跑 login-lark-cli.sh；lark-doc 在 Cursor 重启后首次用文档可能弹窗。

## 七、架构说明

你 → Cursor Agent → 三条路径：MCP lark-doc（快速文档读写）、MCP lark-official（多维表格/搜索/wiki移动/block API）、Shell lark-cli（block精细编辑/日历/IM/云盘）。Agent Skills 在 ~/.agents/skills/lark-* 教 Agent 何时用 CLI。

项目目录：setup.sh 一键安装 | .env 凭证勿提交 | scripts/ MCP与OAuth | feishu-sync/ 本地镜像 | vendor/lark-mcp | .node/ 便携Node | node_modules/

## 八、常见问题

**node 找不到**：export PATH=".node/bin:$PATH" 或用 ./scripts/*.sh

**路径错了**：用 ~/cursorProject/cursor-feishu，不是 ~/cursor-feishu

**OAuth 20028**：重定向 URL 未配全，检查第三节 3.2 三条

**Token 404**：.env 里 LARK_OPEN_DOMAIN 必须是 https://open.feishu.cn

**读 wiki 没表格**：表格可能是嵌入 sheet，用 lark-cli docs +fetch + sheets +csv-get

**MCP 变红**：重跑 login 脚本，重启 Cursor

## 九、换电脑 Checklist

安装 Cursor + Git → clone 项目 cd 到 cursor-feishu → ./setup.sh → 填 .env → login-official → configure-lark-cli → login-lark-cli → install-lark-cli-skills → 重启 Cursor MCP 绿色 → verify-setup 通过 → Agent 跑一条验收

## 十、手动 lark-cli 命令

cd ~/cursorProject/cursor-feishu && export PATH=".node/bin:$PATH"

读 block：lark-cli docs +fetch --api-version v2 --doc "链接" --detail full --doc-format xml

读 sheet：lark-cli sheets +csv-get --spreadsheet-token "token" --sheet-id "id"

查登录：lark-cli auth status

驯养愉快 🦊
