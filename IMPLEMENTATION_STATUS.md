# 实施状态

## 目录说明

所有飞书 + Cursor 集成内容位于 **`cursor-feishu/`** 根目录：

| 路径 | 用途 |
|------|------|
| `scripts/` | MCP 启动、OAuth、验证脚本 |
| `feishu-sync/` | 飞书文档本地镜像 |
| `vendor/lark-mcp/` | lovelts 文档 MCP |
| `.node/` | 便携 Node.js |
| `node_modules/` | 官方 lark-mcp |
| `.env` | 飞书 App 凭证 |

`feishu-integration/` 子目录为迁移遗留，见 [`feishu-integration/DEPRECATED.md`](./feishu-integration/DEPRECATED.md)，可删除。

## 已完成（自动化）

- [x] 目录统一到 `cursor-feishu/`
- [x] `~/.cursor/mcp.json` 指向 `cursor-feishu/scripts/`
- [x] lovelts/lark-mcp → `vendor/lark-mcp`（可链接已有 `~/lark-mcp`）
- [x] 官方 MCP → `cursor-feishu/node_modules`（含 block API + wiki move）
- [x] Lark CLI → `@larksuite/cli` + 配置脚本 + Agent Skills（`~/.agents/skills/lark-*`）
- [x] 本地同步目录 `feishu-sync/`、`CV_Helper/docs/`

## 三套能力并存

| 组件 | 用途 |
|------|------|
| MCP `lark-doc` | 快速 Markdown 文档读写 |
| MCP `lark-official` | 多维表格、搜索、wiki 移动、docx block API |
| Lark CLI | 文档内表格 block 精细编辑、日历、消息、云盘等 |

## 需你手动完成

1. 飞书开发者后台 — [`FEISHU_APP_CHECKLIST.md`](./FEISHU_APP_CHECKLIST.md)（含 `wiki:wiki` 写权限）
2. 填写 `cursor-feishu/.env`
3. `./scripts/login-official.sh`
4. `./scripts/configure-lark-cli.sh && ./scripts/login-lark-cli.sh`
5. `./scripts/install-lark-cli-skills.sh`（若 Skills 未安装）
6. 重启 Cursor，验证 MCP 绿色
7. 使用 [`TEST_PROMPTS.md`](./TEST_PROMPTS.md) 验收

## 验证

```bash
cd cursor-feishu
./scripts/verify-setup.sh
```
