# 故障排查指南

## 常见问题

### 1. 网页前端无法打开

**问题**: 运行 `.\ui.ps1` 后浏览器没有自动打开，或显示"无法连接到 localhost"

**解决方案**:

1. 检查 Python 是否正确安装：
   ```powershell
   python --version
   ```

2. 手动打开浏览器访问：
   ```
   http://127.0.0.1:8765
   ```

3. 检查端口 8765 是否被占用：
   ```powershell
   netstat -ano | findstr :8765
   ```
   如果有进程占用，请：
   - 关闭那个进程
   - 或在 `ui.ps1` 中修改端口号

4. 检查防火墙设置：
   - Windows 防火墙可能阻止 Python
   - 在防火墙允许列表中添加 Python 或端口 8765

### 2. 局域网访问失败

**问题**: 运行 `.\ui-lan.ps1` 后其他设备无法访问指定的 IP 地址

**解决方案**:

1. 确认两台设备在同一 Wi-Fi/局域网：
   ```powershell
   ipconfig  # 查看本机 IP
   ```

2. 在 Windows 防火墙中允许访问：
   - 打开 Windows Defender 防火墙
   - 点击"允许应用通过防火墙"
   - 确保 Python 被允许（公用网络和专用网络都选中）

3. 检查目标 IP 地址是否正确

### 3. API Key 测试失败

**问题**: 填写 OpenAI API Key 后点击"测试 API"显示错误

**解决方案**:

1. 确认 API Key 正确无误
2. 检查网络连接
3. 确认 API 额度未用尽（检查 OpenAI 账户）
4. 检查 Base URL 是否正确
5. 如果使用代理，确认代理设置正确

### 4. 离线模式不生成输出

**问题**: 使用离线模式运行编剧室，但没有生成输出文件

**解决方案**:

1. 检查 `outputs/` 目录是否存在：
   ```powershell
   New-Item -ItemType Directory -Path outputs -Force
   ```

2. 查看命令行输出是否有错误信息

3. 检查磁盘空间是否充足

4. 尝试运行示例：
   ```powershell
   .\run.ps1
   ```

### 5. 知识库导入失败

**问题**: 导入资料文件时显示错误

**解决方案**:

1. **支持的文件格式**:
   - 文本: `.txt`, `.md`
   - 数据: `.csv`, `.json`
   - 文档: `.docx`, `.pdf`

2. 检查文件编码（建议 UTF-8）

3. 检查文件大小（大文件可能需要更长处理时间）

4. 确保文件路径正确（避免特殊字符）

5. 检查数据库连接：
   ```powershell
   ls data/scriptroom.db  # 检查数据库文件是否存在
   ```

### 6. 智能体没有响应

**问题**: 运行编剧室但智能体没有生成内容

**解决方案**:

1. **离线模式**:
   - 这是预期行为，会生成结构化报告而非完整内容

2. **API 模式**:
   - 检查 API Key 是否有效
   - 检查网络连接
   - 查看系统日志获取更多信息
   - 尝试用简单的故事简报测试

### 7. 性能问题

**问题**: 编剧室运行很慢或频繁超时

**解决方案**:

1. 减小知识库搜索范围
2. 使用更快的 AI 模型（如 GPT-4 Mini）
3. 检查网络速度
4. 减少资料库中的文档数量
5. 关闭不必要的后台程序

### 8. Word 文件生成失败

**问题**: 编剧室运行完成，但没有生成 `.docx` 文件

**解决方案**:

1. 确认安装了 `python-docx`：
   ```powershell
   pip install python-docx
   ```

2. 检查 `outputs/` 目录权限

3. 查看是否有足够的磁盘空间

4. 检查系统日志：
   ```powershell
   Get-EventLog -LogName Application -Source Python
   ```

## 日志和调试

### 启用详细日志

设置环境变量：
```powershell
$env:SCRIPTROOM_LOG_LEVEL = "DEBUG"
```

运行编剧室：
```powershell
.\run.ps1
```

日志会输出到 `logs/scriptroom.log`

### 收集调试信息

遇到问题时，请收集以下信息：

```powershell
# Python 版本
python --version

# 已安装包
pip list

# 环境变量
$env:OPENAI_API_KEY
$env:OPENAI_MODEL
$env:OPENAI_BASE_URL

# 系统信息
systeminfo

# 最近的日志
Get-Content logs/scriptroom.log -Tail 100
```

## 联系支持

如果问题未能解决，请提供以下信息后联系支持：

1. 详细错误信息和堆栈跟踪
2. 使用的操作系统和 Python 版本
3. 重现问题的步骤
4. 相关日志文件（脱敏后）
5. 正在使用的 AI 提供商和模型

## 性能优化建议

### 网页前端响应慢

1. 清理浏览器缓存
2. 在隐私/无痕模式下测试
3. 尝试不同的浏览器
4. 检查网络连接

### 编剧室执行慢

1. 使用流式 API 而非批量 API
2. 减少知识库搜索范围
3. 禁用不必要的智能体
4. 使用计算能力更强的 AI 模型

### 数据库查询慢

1. 定期维护 SQLite 数据库：
   ```powershell
   sqlite3 data/scriptroom.db "VACUUM;"
   ```

2. 添加必要的索引
3. 清理过期数据

## 安全建议

1. **不要在代码中硬编码 API Key**
   - 使用环境变量或 `.env` 文件
   - 使用 `.gitignore` 排除敏感文件

2. **保护知识库数据**
   - 定期备份 `data/scriptroom.db`
   - 限制访问权限

3. **HTTPS/TLS**
   - 在生产环境使用 HTTPS
   - 只在本地开发时禁用 TLS 验证

4. **访问控制**
   - 启用身份验证
   - 使用 API Key 进行授权
