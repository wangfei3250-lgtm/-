# 安全指南

本文档提供了多智能体编剧系统的安全最佳实践和配置建议。

## API Key 安全

### ❌ 不要这样做

```python
# ❌ 不要在代码中硬编码 API Key
api_key = "sk-proj-xxxxxxxx"

# ❌ 不要提交敏感信息到 Git
git add .env  # 会暴露密钥
```

### ✅ 正确做法

```python
# ✅ 使用环境变量
import os
api_key = os.getenv("OPENAI_API_KEY")

# ✅ 使用 .env 文件 (在 .gitignore 中)
from dotenv import load_dotenv
load_dotenv()
api_key = os.getenv("OPENAI_API_KEY")
```

### .env 文件模板

```
# .env
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxx
OPENAI_API_BASE=https://api.openai.com/v1
SCRIPTROOM_SECRET_KEY=random-secret-key
SCRIPTROOM_LOG_LEVEL=INFO
SCRIPTROOM_DEBUG=False
```

### .gitignore 配置

```
# .gitignore
.env
.env.local
.env.*.local
secrets/
*.key
*.pem
*.jks
```

## 密钥轮换

定期更换 API Key 以降低泄露风险

## 认证和授权

### 启用 API Key 认证

实现基于 API Key 的认证机制

## HTTPS/TLS 配置

### 获取 SSL 证书 (Let's Encrypt)

使用 certbot 获取和管理 SSL 证书

## 数据保护

### 数据库加密

使用 sqlcipher 对 SQLite 数据库进行加密

### 数据备份

定期备份重要数据并进行恢复测试

### 数据脱敏

在日志和输出中脱敏敏感数据

## 安全审计

### 定期安全检查清单

- [ ] 检查 API Key 是否泄露
- [ ] 验证 SSL 证书有效期
- [ ] 审计数据库访问日志
- [ ] 检查文件权限
- [ ] 验证依赖库版本
- [ ] 扫描代码漏洞
- [ ] 测试认证机制
- [ ] 验证数据加密

## 合规性

### GDPR 合规

- 实现数据导出功能
- 支持数据删除请求
- 记录用户同意
- 定期隐私审计
