---
name: feishu-cursor-integration
description: >-
  Routes Feishu/Lark tasks between MCP (lark-doc, lark-official) and lark-cli.
  Use when the user asks to read/write Feishu docs, wiki, bitable, move wiki
  nodes, edit embedded tables or sheets, block_replace, calendar, IM, drive,
  or any 飞书/Cursor/芙芙 integration task. MUST read this skill first and pick
  MCP or CLI before executing.
---

# Feishu + Cursor 集成路由

**代码仓库**：<GITHUB_REPO_URL>  
**安装 SOP**：飞书 wiki《芙芙小助手驯养指南》或仓库 `SOP.md`

**硬性规则：执行任何飞书操作前，先走下方决策流程，再调用工具。**

## 决策流程（按顺序）

```
1. URL 含 /base/ 或用户说「多维表格」？ → MCP lark-official (bitable_*)
2. 用户要移动 wiki 节点 / 改目录结构？ → MCP lark-official (wiki_v2_spaceNode.move)
3. 只需读/写纯文本或 Markdown（append/replace）？ → MCP lark-doc
4. 需要 block 级编辑 / block_replace / 嵌入 sheet 表格 / 改单元格？
   → Lark CLI（docs +fetch xml + sheets +csv-get 或 docs +update block_*）
5. 日历 / 消息 / 云盘文件 / sheets 公式？ → Lark CLI
6. MCP 读文档只有标题、正文为空？ → 文档含嵌入 sheet → 转 Lark CLI
```

## 路由表

| 场景 | 首选 | 工具/命令 |
|------|------|-----------|
| 读 wiki/docx 纯文本 | MCP | `lark-doc` → `get_doc_content` |
| 追加/覆盖 Markdown | MCP | `lark-doc` → `update_doc` |
| 多维表格 CRUD | MCP | `lark-official` → `bitable_v1_*` |
| 搜索 wiki/云文档 | MCP | `search_wiki` / `docx_builtin_search` |
| 移动 wiki 节点 | MCP | `wiki_v2_spaceNode.move` |
| **嵌入 sheet 表格（读）** | **CLI** | `docs +fetch --doc-format xml` → `sheets +csv-get` |
| **block 精细编辑** | **CLI** | `docs +update --command block_replace` 等 |
| docx block API（备选） | MCP | `docx_v1_documentBlock.*` |
| 日历 / IM / drive | CLI | `lark-cli calendar` / `im` / `drive` |

## Lark CLI 调用规范

**禁止**直接运行裸 `lark-cli`（会报 `env: node: No such file`）。

```bash
cd <cursor-feishu-root>
./scripts/lark-cli.sh docs +fetch --api-version v2 --doc "<url>" --detail full --doc-format xml
./scripts/lark-cli.sh sheets +csv-get --spreadsheet-token "<token>" --sheet-id "<id>"
```

嵌入 sheet 识别：XML 中出现 `<sheet sheet-id="..." token="...">`，用 token + sheet-id 读表。

## MCP 工具速查

| MCP | 工具 |
|-----|------|
| lark-doc | `get_doc_content`, `update_doc`, `create_doc`, `search_wiki` |
| lark-official | `bitable_v1_*`, `wiki_v2_space_getNode`, `wiki_v2_spaceNode.move`, `docx_v1_documentBlock.list`, `docx_builtin_search` |

## 失败降级

| 现象 | 动作 |
|------|------|
| 只返回标题 | 转 CLI fetch + sheets |
| lark-doc OAuth 弹窗 | 用户浏览器授权，或改用 CLI |
| `env: node: No such file` | 用 `./scripts/lark-cli.sh` |
| 权限错误 | 见 `FEISHU_APP_CHECKLIST.md`，重新 OAuth |

## 示例

**用户**：读竞品调研 wiki 里的表格  
**Agent**：CLI fetch xml → 发现 `<sheet>` → `sheets +csv-get` → 输出 Markdown 表

**用户**：在文档末尾加一段说明  
**Agent**：MCP `update_doc` mode append

**用户**：多维表格新增一行  
**Agent**：MCP `bitable_v1_appTableRecord_create`
