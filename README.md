# 多智能体编剧团队

这是一个可直接运行的“编剧室”小项目。它把一个故事想法交给 11 个角色依次讨论：

- 总编剧
- 故事架构师
- 角色设计师
- 世界观与考据顾问
- 场景策划
- 对白作者
- 剧本医生
- 审核智能体
- 统筹编辑
- 成稿编剧
- 红后超级审核

默认不需要 API Key，会使用离线规则生成一份结构化报告。设置 `OPENAI_API_KEY` 后，可以切换到 OpenAI 兼容接口，让每个角色用真实模型协作。

## 快速运行

### 网页前端

```powershell
cd "C:\Users\admin04\Documents\编剧智能体"
.\ui.ps1
```

启动后打开：

```text
http://127.0.0.1:8765
```

`.\ui.ps1` 会自动打开网页。网页里可以填写故事简报，在固定智能体聊天框里观看每个智能体互相接话、收到消息、回复和工作，并下载最终 Word 剧本。

如果要让同一 Wi-Fi/局域网里的其他电脑打开：

```powershell
cd "C:\Users\admin04\Documents\编剧智能体"
.\ui-lan.ps1
```

脚本会打印类似 `http://192.168.x.x:8765` 的地址，别人电脑在浏览器里打开这个地址即可。若打不开，通常需要在 Windows 防火墙里允许 Python 或端口 `8765` 的入站访问。

网页前端还支持：

- 人类主创可以在聊天框里 `@` 任意智能体，干预意见会进入后续编剧室记忆。
- 运行中收到人工修正会中断当前任务，下一次运行按最新意见调整策略。
- 审核智能体不满意时会定向打回对应智能体返工，再重新审核。
- 所有智能体都会先联网检索，再基于实时资料和自身职责判断。
- 数据喂养中心可以导入剧本语料、项目资料、论文摘要和竞品资料，智能体会在发言前引用本地知识库。
- 成稿质量面板会按集显示字数、场景数、对白人物和风险。
- 成稿编剧按集输出完整剧本初稿，并生成 `.docx` 文件。
- 红后超级审核会做最终质量门，并用结构化结果把问题落实到对应智能体。

网页前端支持这些模式：

- 离线：不需要 API Key，适合快速试流程。
- DeepSeek：默认模型 `deepseek-v4-flash`，Base URL `https://api.deepseek.com`。
- OpenAI：填写 API Key、模型和 Base URL 后，点击“测试 API”，通过后再运行编剧室。API Key 只用于本次请求，不会保存到项目文件。

如果本机提示证书链不受信任，可以勾选“跳过 TLS 证书验证”做本地测试。正常环境建议保持不勾选。

### 命令行

最简单的方式：

```powershell
.\run.ps1
```

它会使用示例简报生成 `outputs/雾港回声.md`。

你也可以直接调用命令行：

```powershell
python -m scriptroom.cli --brief examples/brief_cn.json --provider offline --output outputs/雾港回声.md
```

或者直接传入一个想法：

```powershell
python -m scriptroom.cli `
  --title "长夜便利店" `
  --genre "奇幻悬疑" `
  --tone "温暖、诡异、带黑色幽默" `
  --theme "孤独" `
  --premise "一个夜班店员发现每天凌晨三点进店的客人，都是明天将要做出重大选择的人。" `
  --output outputs/长夜便利店.md
```

## 使用真实模型

网页里可以直接填写 API Key 测试。也可以用环境变量：

```powershell
$env:OPENAI_API_KEY="你的 key"
$env:OPENAI_MODEL="gpt-4.1-mini"
python -m scriptroom.cli --brief examples/brief_cn.json --provider openai --output outputs/雾港回声-ai.md
```

如果你使用其他 OpenAI 兼容服务，也可以设置：

```powershell
$env:OPENAI_BASE_URL="https://your-provider.example/v1"
```

## 自定义团队

编辑 `agents.json` 即可调整角色、任务、关注点和交接要求。流程会按文件里的顺序依次运行每个角色。

## 输出

默认输出在 `outputs` 文件夹里。网页运行会生成 Markdown 讨论报告，以及最终剧本 Word 文件 `*-剧本.docx`。

## 数据喂养

网页左侧“数据喂养中心”会把资料写入本地 SQLite 知识库 `data/scriptroom.db`。默认会自动加入一批全球编剧/多智能体方法摘要；你也可以导入自有或已授权资料。

支持：

- 粘贴文本资料。
- 导入 `.txt`、`.md`、`.csv`、`.json` 文本文件。
- 通过本机路径导入 `.docx`、`.pdf`、`.txt`、`.md`、`.csv`、`.json`。

接口：

- `GET /api/knowledge/sources`：查看资料源。
- `POST /api/knowledge/import`：导入资料。
- `POST /api/knowledge/search`：按智能体和关键词检索资料。
- `POST /api/projects/:id/run-stream`：运行带知识库和项目记忆的编剧室。

版权提醒：默认只把“自有/已授权、公开许可、摘要资料”用于智能体引用；“仅存档不引用”的资料会保存但不会进入检索结果。

## 检查

```powershell
.\test.ps1
```
