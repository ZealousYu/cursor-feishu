# 飞书 + Cursor Agent 集成（全能力版）

三套能力并存：**MCP 快速读写** + **MCP Block/Wiki 扩展** + **Lark CLI 精细编辑**。

所有相关代码与配置均在本目录 `cursor-feishu/` 下。

## 能力矩阵

| 场景 | 用什么 | 示例 |
|------|--------|------|
| 快速读/写 Markdown 文档 | MCP `lark-doc` | 「读这个 wiki 链接并追加一段」 |
| 多维表格 CRUD | MCP `lark-official` | 「查 base 表格所有记录并新增一行」 |
| 文档内表格 / Block 精细编辑 | **Lark CLI** | 「用 lark-cli fetch 读 block，block_replace 改表格」 |
| 移动 wiki 节点 | MCP `lark-official` 或脚本 | 「把任务文档移到蓝麟下」 |
| 日历 / 消息 / 云盘等 | **Lark CLI** | 「查明天日程」「发群消息」 |

## 目录结构

```text
cursor-feishu/
├── setup.sh                      # 一键安装（MCP + Lark CLI）
├── .env                          # 飞书 App 凭证（勿提交）
├── scripts/
│   ├── run-lark-doc-mcp.sh       # lovelts 文档 MCP
│   ├── run-lark-official-mcp.sh  # 官方 MCP（含 block + wiki move）
│   ├── login-official.sh         # 官方 MCP OAuth
│   ├── configure-lark-cli.sh     # 绑定现有 App 到 lark-cli
│   ├── login-lark-cli.sh         # lark-cli OAuth（钥匙串持久化）
│   ├── install-lark-cli-skills.sh
│   └── move-wiki-node.mjs        # wiki 节点移动（备用）
├── feishu-sync/                  # 本地文档镜像
├── vendor/lark-mcp/              # lovelts 文档 MCP
├── .node/                        # 便携 Node.js
└── node_modules/                 # @larksuiteoapi/lark-mcp + @larksuite/cli
```

## 快速开始

```bash
cd cursor-feishu
./setup.sh
```

然后按 [`FEISHU_APP_CHECKLIST.md`](./FEISHU_APP_CHECKLIST.md) 配置飞书应用，填写 `.env`：

```bash
./scripts/login-official.sh          # MCP 官方 OAuth（一次）
./scripts/configure-lark-cli.sh      # 绑定同一飞书 App
./scripts/login-lark-cli.sh          # Lark CLI OAuth（一次，存钥匙串）
./scripts/install-lark-cli-skills.sh # 安装 Agent Skills
```

重启 Cursor，确认 Settings → MCP 里 `lark-doc` 和 `lark-official` 均为绿色。

验证：

```bash
./scripts/verify-setup.sh
lark-cli auth status    # 或通过 node_modules/.bin/lark-cli
```

## MCP Server

| 名称 | 脚本 | 能力 |
|------|------|------|
| `lark-doc` | `run-lark-doc-mcp.sh` | 文档 create / read / update / search_wiki |
| `lark-official` | `run-lark-official-mcp.sh` | 多维表格、搜索、纯文本、**wiki 移动**、**docx block 读写** |

## Lark CLI（Block 编辑）

安装并授权后，直接对 Agent 说：

```text
请用 lark-cli docs +fetch --api-version v2 --doc <token> --detail with-ids 读取文档结构，
找到表格 block_id，再用 block_replace 更新单元格内容。
```

常用命令：

```bash
# 读文档（含 block id，可看到嵌入表格）
./node_modules/.bin/lark-cli docs +fetch --api-version v2 --doc <doc_token> --detail with-ids

# Block 级更新
./node_modules/.bin/lark-cli docs +update --api-version v2 --doc <doc_token> \
  --command block_replace --block-id <block_id> --content '...'
```

Skills 安装后 Agent 会自动选用合适命令，无需你记参数。

## 本地同步

- `feishu-sync/` — Agent 下载飞书文档到此目录
- 上级目录 `CV_Helper/docs/` — 项目绑定文档

## 测试

见 [`TEST_PROMPTS.md`](./TEST_PROMPTS.md)。

## 授权说明

| 组件 | 授权次数 | 持久化 |
|------|----------|--------|
| lark-official MCP | 首次 + 偶尔刷新 | 本地加密存储 |
| lark-doc MCP | Cursor 重启后首次用文档可能弹窗 | 内存（重启需再授权） |
| lark-cli | 首次 `./scripts/login-lark-cli.sh` | 系统钥匙串，长期有效 |

日常跟 Agent 说任务即可；只有 token 过期或重启 Cursor 后第一次用文档 MCP 时，才可能再弹浏览器。
