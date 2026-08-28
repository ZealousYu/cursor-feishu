# 此目录已废弃

飞书 + Cursor 集成已统一到上级目录 [`../`](../)。

请改用：

```bash
cd cursor-feishu
./setup.sh
./scripts/verify-setup.sh
```

本目录下的 `node_modules/` 为迁移遗留，可安全删除：

```bash
rm -rf cursor-feishu/feishu-integration
```
