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

定期更换 API Key 以降低泄露风险：

```bash
#!/bin/bash
# rotate-keys.sh

# 1. 生成新的 secret key
NEW_SECRET=$(python -c "import secrets; print(secrets.token_urlsafe(32))")

# 2. 更新环境变量
sed -i "s/^SCRIPTROOM_SECRET_KEY=.*/SCRIPTROOM_SECRET_KEY=$NEW_SECRET/" .env

# 3. 重启应用
systemctl restart scriptroom

# 4. 监控日志
tail -f logs/scriptroom.log
```

## 认证和授权

### 启用 API Key 认证

```python
from flask import request, abort

def require_api_key(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        api_key = request.headers.get('X-API-Key')
        if not api_key or not validate_api_key(api_key):
            abort(401)
        return f(*args, **kwargs)
    return decorated_function

@app.route('/api/protected')
@require_api_key
def protected_endpoint():
    return {'status': 'ok'}
```

### 用户权限管理

```python
# 定义角色
ROLES = {
    'admin': ['create', 'read', 'update', 'delete'],
    'editor': ['create', 'read', 'update'],
    'viewer': ['read'],
}

def check_permission(user_role, action):
    return action in ROLES.get(user_role, [])
```

## HTTPS/TLS 配置

### 获取 SSL 证书 (Let's Encrypt)

```bash
# 安装 Certbot
sudo apt-get install certbot python3-certbot-nginx

# 获取证书
sudo certbot certonly --standalone -d your-domain.com

# 自动续期
sudo certbot renew --dry-run
```

### Nginx SSL 配置

```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    # 强制 TLS 1.2+
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    # 启用 HSTS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # 其他安全头
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
```

## 数据保护

### 数据库加密

```bash
# SQLite 数据库加密 (使用 sqlcipher)
pip install sqlcipher3

# 使用加密数据库
sqlite_uri = "sqlite+pysqlcipher:///:memory:?cipher=aes&key=password"
```

### 数据备份

```bash
#!/bin/bash
# backup.sh

BACKUP_DIR="/backups/scriptroom"
DB_FILE="/var/lib/scriptroom/scriptroom.db"

# 每日备份
mkdir -p $BACKUP_DIR
sqlite3 $DB_FILE ".dump" | gzip > $BACKUP_DIR/scriptroom-$(date +%Y%m%d).sql.gz

# 定期清理旧备份 (保留 30 天)
find $BACKUP_DIR -name "*.gz" -mtime +30 -delete
```

### 数据脱敏

敏感数据应在日志和输出中脱敏：

```python
import re

def redact_sensitive_data(text):
    # 脱敏 API Key
    text = re.sub(r'sk-proj-[a-zA-Z0-9]{48}', '[REDACTED-API-KEY]', text)
    
    # 脱敏邮箱
    text = re.sub(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', 
                  '[REDACTED-EMAIL]', text)
    
    # 脱敏电话
    text = re.sub(r'\d{3}-\d{3}-\d{4}', '[REDACTED-PHONE]', text)
    
    return text
```

## 日志安全

### 安全日志配置

```python
import logging

# 不要记录敏感信息
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/scriptroom.log'),
        logging.handlers.RotatingFileHandler(
            'logs/scriptroom.log',
            maxBytes=10485760,  # 10MB
            backupCount=10
        )
    ]
)

# 审计关键事件
logger.info(f"User {user_id} accessed API endpoint {endpoint}")
logger.warning(f"Failed authentication attempt from {ip_address}")
logger.error(f"Database error: {error}")
```

## 防火墙配置

### UFW (Ubuntu)

```bash
# 启用防火墙
sudo ufw enable

# 允许 SSH
sudo ufw allow 22/tcp

# 允许 HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# 限制特定 IP 访问管理面板
sudo ufw allow from 192.168.1.0/24 to any port 8765

# 查看规则
sudo ufw status
```

## DDoS 防护

### Rate Limiting

```python
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"]
)

@app.route('/api/scriptroom/run')
@limiter.limit("5 per minute")  # 严格限制
def run_scriptroom():
    return {'status': 'running'}
```

### Cloudflare 集成

1. 注册 Cloudflare 账户
2. 将域名 DNS 指向 Cloudflare
3. 启用 DDoS 防护选项
4. 配置速率限制规则

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

### 安全扫描工具

```bash
# 依赖库安全检查
pip install safety
safety check

# Python 代码静态分析
pip install bandit
bandit -r scriptroom/

# OWASP 依赖检查
pip install pip-audit
pip-audit

# 容器镜像扫描
trivy image scriptroom:latest
```

## 事件响应

### 安全事件处理流程

1. **发现** - 监控日志和告警
2. **隔离** - 停止受影响的服务
3. **分析** - 确定事件范围和影响
4. **恢复** - 从备份恢复数据
5. **通知** - 通知相关方
6. **改进** - 实施预防措施

### 安全事件日志

```python
def log_security_incident(incident_type, details):
    incident = {
        'timestamp': datetime.now().isoformat(),
        'type': incident_type,
        'details': details,
        'severity': determine_severity(incident_type),
        'action_taken': '...'
    }
    
    # 存储在安全日志
    with open('logs/security-incidents.log', 'a') as f:
        f.write(json.dumps(incident) + '\n')
    
    # 发送告警
    send_alert_to_admin(incident)
```

## 合规性

### GDPR 合规

- 实现数据导出功能
- 支持数据删除请求
- 记录用户同意
- 定期隐私审计

### SOC 2 认证

准备以下文档：
- 访问控制策略
- 数据安全策略
- 事件响应计划
- 审计日志
- 备灾计划

## 安全资源

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- [Python 安全指南](https://python.readthedocs.io/en/latest/library/security_warnings.html)
- [Flask 安全最佳实践](https://flask.palletsprojects.com/en/latest/security/)
