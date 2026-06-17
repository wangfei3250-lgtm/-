# 贡献指南

感谢你对多智能体编剧团队项目的兴趣！本指南将帮助你了解如何贡献代码和想法。

## 开发流程

### 1. 环境搭建

```bash
# 克隆仓库
git clone https://github.com/wangfei3250-lgtm/-.git
cd -

# 创建虚拟环境
python -m venv venv

# 激活虚拟环境
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt

# 安装开发工具
pip install pytest pytest-asyncio black ruff mypy
```

### 2. 代码风格

- 使用 **Black** 格式化代码
- 使用 **Ruff** 检查代码风格
- 使用 **MyPy** 进行类型检查

```bash
# 格式化代码
black .

# 检查风格
ruff check .

# 类型检查
mypy scriptroom/
```

### 3. 提交规范

提交信息格式遵循约定式提交（Conventional Commits）:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**类型**:
- `feat`: 新功能
- `fix`: 修复bug
- `docs`: 文档变更
- `style`: 代码风格变更（不影响功能）
- `refactor`: 代码重构
- `perf`: 性能优化
- `test`: 测试相关
- `chore`: 构建、依赖等辅助改动

**示例**:
```
feat(agents): 添加自定义智能体加载功能

支持从外部配置文件动态加载智能体配置。

Closes #123
```

### 4. 测试

在提交前请运行测试:

```bash
# 运行所有测试
pytest

# 运行特定测试文件
pytest tests/test_cli.py

# 生成覆盖率报告
pytest --cov=scriptroom tests/
```

### 5. 文档更新

如果你的改动涉及新功能或 API 变更，请：
- 更新 `README.md`
- 在 `docs/` 中添加或修改相关文档
- 更新 API 文档（如适用）

## 报告问题

使用 [Issue](https://github.com/wangfei3250-lgtm/-/issues) 功能报告bug或提议功能。请包含：

- 清晰的标题和描述
- 复现步骤（针对bug）
- 期望行为和实际行为
- 环境信息（Python版本、操作系统等）
- 相关的日志或错误信息

## 提交 Pull Request

1. Fork 这个仓库
2. 创建你的特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交你的改动 (`git commit -m 'feat(module): 添加amazing功能'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 打开 Pull Request

### PR 清单

- [ ] 代码遵循项目风格指南
- [ ] 已运行 Black 和 Ruff 检查
- [ ] 已添加或更新相关测试
- [ ] 所有测试通过 (`pytest`)
- [ ] 已更新相关文档
- [ ] 提交信息遵循约定式提交

## 行为准则

本项目参与者应该：
- 使用包容性语言
- 尊重不同观点
- 接受建设性批评
- 关注最适合社区的事情
- 对其他社区成员表现同情

## 许可证

通过提交代码，你同意你的贡献在相同许可证下发布。
