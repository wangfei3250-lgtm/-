# 部署指南

## 本地开发部署

### 前置要求

- Python 3.8+
- Git
- 文本编辑器或 IDE

### 步骤

```bash
# 克隆仓库
git clone https://github.com/wangfei3250-lgtm/-.git
cd -

# 创建虚拟环境
python -m venv venv

# 激活虚拟环境
# Windows
venv\Scripts\activate
# macOS/Linux
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt

# 启动 Web UI
.\ui.ps1  # Windows
python -m scriptroom.ui  # macOS/Linux
```

## Docker 部署

### Dockerfile

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件
COPY requirements.txt .

# 安装 Python 依赖
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用代码
COPY . .

# 创建输出目录
RUN mkdir -p outputs data logs

# 暴露端口
EXPOSE 8765

# 运行应用
CMD ["python", "-m", "scriptroom.ui"]
```

### 构建和运行

```bash
# 构建镜像
docker build -t scriptroom:latest .

# 运行容器
docker run -d \
  -p 8765:8765 \
  -v $(pwd)/outputs:/app/outputs \
  -v $(pwd)/data:/app/data \
  -e OPENAI_API_KEY="your-key-here" \
  --name scriptroom \
  scriptroom:latest

# 查看日志
docker logs scriptroom

# 停止容器
docker stop scriptroom
```

## Docker Compose 部署

### docker-compose.yml

```yaml
version: '3.8'

services:
  scriptroom:
    build: .
    container_name: scriptroom
    ports:
      - "8765:8765"
    volumes:
      - ./outputs:/app/outputs
      - ./data:/app/data
      - ./logs:/app/logs
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - OPENAI_MODEL=gpt-4-mini
      - SCRIPTROOM_LOG_LEVEL=INFO
      - FLASK_ENV=production
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8765/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # 可选: Nginx 反向代理
  nginx:
    image: nginx:alpine
    container_name: scriptroom-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - scriptroom
```

### 使用 Docker Compose

```bash
# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f scriptroom

# 停止服务
docker-compose down

# 清理数据
docker-compose down -v
```

## 云服务器部署 (Linux)

### AWS EC2

```bash
# 连接到 EC2 实例
ssh -i "key.pem" ubuntu@your-instance-ip

# 更新系统
sudo apt-get update && sudo apt-get upgrade -y

# 安装 Python 和依赖
sudo apt-get install -y python3.11 python3-pip git

# 克隆仓库
git clone https://github.com/wangfei3250-lgtm/-.git
cd -

# 创建虚拟环境
python3 -m venv venv
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt

# 安装 Gunicorn (生产级 WSGI 服务器)
pip install gunicorn

# 运行应用
gunicorn -w 4 -b 0.0.0.0:8765 scriptroom.wsgi:app
```

### Systemd 服务配置

创建 `/etc/systemd/system/scriptroom.service`:

```ini
[Unit]
Description=ScriptRoom Multi-Agent Scriptwriting System
After=network.target

[Service]
User=www-data
WorkingDirectory=/var/www/scriptroom
Environment="PATH=/var/www/scriptroom/venv/bin"
Environment="OPENAI_API_KEY=your-key-here"
ExecStart=/var/www/scriptroom/venv/bin/gunicorn \
    -w 4 \
    -b 0.0.0.0:8765 \
    scriptroom.wsgi:app
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

启用服务:
```bash
sudo systemctl enable scriptroom
sudo systemctl start scriptroom
sudo systemctl status scriptroom
```

### Nginx 反向代理

编辑 `/etc/nginx/sites-available/scriptroom`:

```nginx
upstream scriptroom {
    server 127.0.0.1:8765;
}

server {
    listen 80;
    server_name your-domain.com;

    # 重定向到 HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    client_max_body_size 100M;

    location / {
        proxy_pass http://scriptroom;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    location /socket.io {
        proxy_pass http://scriptroom/socket.io;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

启用配置:
```bash
sudo ln -s /etc/nginx/sites-available/scriptroom /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## 生产环境检查清单

- [ ] 设置强密码和访问控制
- [ ] 配置 HTTPS/SSL 证书
- [ ] 设置环境变量和敏感信息管理
- [ ] 启用日志和监控
- [ ] 配置备份策略
- [ ] 设置自动更新规则
- [ ] 配置速率限制和防DDoS
- [ ] 定期安全审计
- [ ] 计划灾难恢复策略

## 监控和维护

### 日志管理

```bash
# 查看实时日志
journalctl -u scriptroom -f

# 查看历史日志
journalctl -u scriptroom --since "2024-01-01" --until "2024-01-02"

# 导出日志
journalctl -u scriptroom -o json > logs.json
```

### 性能监控

使用 `htop` 或 `top` 监控资源使用:

```bash
sudo apt-get install htop
htop
```

### 数据库维护

```bash
# 定期备份
sudo crontab -e
# 添加: 0 2 * * * /usr/bin/sqlite3 /path/to/scriptroom.db ".dump" > /backups/scriptroom-$(date +\%Y\%m\%d).sql

# 数据库整理
sqlite3 /path/to/scriptroom.db "VACUUM;"
```

## 更新和滚动更新

```bash
# 获取最新代码
git pull origin main

# 更新依赖
pip install -r requirements.txt --upgrade

# 运行迁移（如有）
python -m scriptroom.migrate

# 重启服务
sudo systemctl restart scriptroom
```

## 故障转移和高可用

### 使用 HAProxy 进行负载均衡

参考生产级负载均衡配置...

### 数据库复制

配置主从复制以提高可用性...
