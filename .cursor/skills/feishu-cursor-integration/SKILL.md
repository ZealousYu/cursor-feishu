---
name: feishu-cursor-integration
description: >-
  Routes Feishu/Lark tasks between MCP (lark-doc, lark-official) and lark-cli.
  Use when the user asks to read/write Feishu docs, wiki, bitable, move wiki
  nodes, edit embedded tables or sheets, block_replace, calendar, IM, drive,
  芙芙, or any 飞书/Cursor integration task. MUST read this skill first and pick
  MCP or CLI before executing.
---

# Feishu + Cursor 集成路由（芙芙）

**安装 SOP（新电脑）**：飞书 wiki《芙芙小助手驯养指南》  
https://rcnimfkpyebd.feishu.cn/wiki/DiOlwipeiiWKCgkmWOwcNKOAnGf  

**代码仓库**：https://github.com/PLACEHOLDER/cursor-feishu  
**仓库内文档**：`SOP.md`、`FEISHU_APP_CHECKLIST.md`、`TEST_PROMPTS.md`

**硬性规则：执行任何飞书操作前，先走下方决策流程，再调用工具。禁止在未判断前同时乱试 MCP 和 CLI。**

## 决策流程（按顺序，命中即停）

```
1. URL 含 /base/ 或用户说「多维表格」？
   → MCP lark-official（bitable_v1_*）

2. 用户要移动 wiki 节点 / 改知识库目录结构？
   → MCP lark-official（wiki_v2_spaceNode.move）
   或 scripts/move-wiki-node.mjs（MCP 不可用时）

3. 只需读/写纯文本或 Markdown（整段 append / replace）？
   → MCP lark-doc（get_doc_content / update_doc）

4. 需要以下任一？
   - block 级编辑（block_replace / block_insert_after / block_delete）
   - 读文档内嵌入 sheet 表格
   - 改电子表格单元格
   - docs +fetch 带 block_id 的结构
   → Lark CLI（见下方命令）

5. 日历 / 群消息 / 云盘文件 / sheets 公式 / 透视表？
   → Lark CLI（calendar / im / drive / sheets 子命令）

6. MCP get_doc_content 只返回标题、正文为空？
   → 文档含嵌入 <sheet> → 转 Lark CLI fetch xml + sheets +csv-get
```

## 路由表

| 场景 | 首选 | 工具/命令 |
|------|------|-----------|
| 读 wiki/docx 纯文本 | MCP | `lark-doc` → `get_doc_content` |
| 追加/覆盖 Markdown | MCP | `lark-doc` → `update_doc` |
| 创建文档 | MCP | `lark-doc` → `create_doc` |
| 搜索 wiki | MCP | `lark-doc` → `search_wiki` |
| 多维表格 CRUD | MCP | `lark-official` → `bitable_v1_*` |
| 搜索云文档 | MCP | `lark-official` → `docx_builtin_search` |
| 移动 wiki 节点 | MCP | `wiki_v2_spaceNode.move` |
| wiki 节点信息 | MCP | `wiki_v2_space_getNode` |
| **嵌入 sheet 表格（读）** | **CLI** | `docs +fetch --doc-format xml` → `sheets +csv-get` |
| **block 精细编辑** | **CLI** | `docs +update --command block_*` |
| docx block API（备选） | MCP | `docx_v1_documentBlock.list` 等 |
| 日历 / IM / drive | CLI | `lark-cli calendar` / `im` / `drive` |

## Lark CLI 调用规范（必须遵守）

**禁止**直接运行裸 `lark-cli`（会报 `env: node: No such file or directory`）。

在仓库根目录执行：

```bash
./scripts/lark-cli.sh docs +fetch --api-version v2 --doc "<url>" --detail full --doc-format xml
./scripts/lark-cli.sh sheets +csv-get --spreadsheet-token "<token>" --sheet-id "<sheet-id>"
./scripts/lark-cli.sh docs +update --api-version v2 --doc "<token>" --command block_replace --block-id "<id>" --content '...'
```

### 嵌入 sheet 识别

`docs +fetch` 的 XML 中出现：

```xml
<sheet id="..." sheet-id="cluoSN" token="DNN6s..."></sheet>
```

→ 用 `token` 作 `--spreadsheet-token`，`sheet-id` 作 `--sheet-id`，再 `sheets +csv-get`。

**注意**：嵌入 sheet ≠ 多维表格 `/base/`；后者走 MCP bitable。

## MCP 工具速查

| MCP | 工具 |
|-----|------|
| lark-doc | `get_doc_content`, `update_doc`, `create_doc`, `search_wiki` |
| lark-official | `bitable_v1_*`, `wiki_v2_space_getNode`, `wiki_v2_spaceNode.move`, `docx_v1_documentBlock.*`, `docx_v1_document_rawContent`, `docx_builtin_search` |

## 失败降级

| 现象 | 动作 |
|------|------|
| 只返回标题、无正文 | 转 CLI fetch xml；若有 `<sheet>` 再 csv-get |
| lark-doc OAuth 弹窗 | 用户浏览器授权（localhost:9997），或改用 CLI |
| `env: node: No such file` | 必须用 `./scripts/lark-cli.sh` |
| MCP 权限错误 | 见 SOP/FEISHU_APP_CHECKLIST，重新 OAuth |
| CLI user identity missing | 用户运行 `./scripts/login-lark-cli.sh` |

## 示例

**用户**：读竞品调研 wiki 里的表格  
**Agent**：CLI `docs +fetch xml` → 发现 `<sheet token=...>` → `sheets +csv-get` → 输出 Markdown 表

**用户**：在文档末尾加一段说明  
**Agent**：MCP `update_doc` mode append

**用户**：多维表格新增一行  
**Agent**：MCP `bitable_v1_appTableRecord_create`

**用户**：把「任务」移到「蓝麟」下  
**Agent**：MCP `wiki_v2_spaceNode.move`（先 search/getNode 拿 token）
