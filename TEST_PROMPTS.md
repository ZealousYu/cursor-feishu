# Cursor Agent 测试提示词

配置完成且 MCP 为绿色后，在 **Agent 模式**下使用以下提示词验证。

## 文档 CRUD（lark-doc）

### 读取
```
读取这个飞书文档的内容并总结要点：
https://xxx.feishu.cn/docx/xxxxxx
```

### 创建
```
创建一个飞书文档，标题「Cursor 集成测试」，内容为：
# 测试文档
- 创建时间：今天
- 来源：Cursor Agent
```

### 更新
```
在飞书文档 <document_id> 末尾追加：
## 更新日志
- 由 Cursor Agent 追加测试
```

## 多维表格（lark-official）

### 查询
```
查询这个多维表格的所有记录：
https://xxx.feishu.cn/base/bascnxxx?table=tblxxx
```

### 新增
```
在 app_token=bascnxxx table_id=tblxxx 的多维表格中新增一行：
标题=测试任务，状态=进行中
```

### 更新
```
把上述表格中标题为「测试任务」的记录，状态改为「已完成」
```

## 本地同步

### 飞书 → 本地
```
把这个飞书文档保存到 cursor-feishu/feishu-sync/test-doc.md：
https://xxx.feishu.cn/docx/xxxxxx
```

### 本地 → 飞书
```
读取 CV_Helper/简历面试助手-产品方案.md，创建一个新的飞书文档并写入全部内容
```

### 双向
```
1. 从飞书下载文档到 cursor-feishu/feishu-sync/weekly.md
2. 我确认修改后，再上传回同一个飞书文档
```

## 文档内表格 / Block 编辑（lark-cli）

> 需要已运行 `./scripts/login-lark-cli.sh` 并安装 Skills。

### 读取含表格的 wiki 文档
```
请用 lark-cli docs +fetch --api-version v2 读取这个文档的 block 结构（含 block_id）：
https://rcnimfkpyebd.feishu.cn/wiki/ObnXwHvvhioGX5kBYjXcICocnAe
把表格内容整理成 Markdown 表格给我看。
```

### 替换文档内某个 block
```
用 lark-cli 对这个文档执行 block_replace，把指定 block 替换为新内容：
doc_token=xxx block_id=xxx
（先 fetch 确认 block_id，再更新）
```

## Wiki 节点移动（lark-official MCP 或脚本）

```
把文档库里的「任务」文档移动到「蓝麟」目录下。
```

## Lark CLI 其他能力

```
用 lark-cli 搜索飞书里标题包含「竞品」的文档，列出前 5 条。
```

```
用 lark-cli 查我明天的日历日程。
```

## 验收标准

- [ ] `lark-doc` MCP 绿色，能读取文档
- [ ] 能创建并更新飞书文档
- [ ] `lark-official` MCP 绿色，能查询多维表格
- [ ] 能新增/更新表格记录
- [ ] 能将飞书文档保存到 `cursor-feishu/feishu-sync/` 本地目录
- [ ] `lark-cli auth status` 显示已登录
- [ ] 能用 lark-cli fetch 读到文档内嵌入表格的 block 结构
