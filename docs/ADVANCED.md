# 高级功能指南

## 自定义智能体

### 添加新智能体

编辑 `agents.json` 添加新的智能体配置：

```json
{
  "id": "custom_agent",
  "name": "自定义智能体",
  "mission": "执行特定任务",
  "focus": ["方向1", "方向2"],
  "handoff": "将结果交接给下一个智能体"
}
```

### 自定义提示词

创建 `prompts/custom_agent.md`：

```markdown
# 自定义智能体提示词

你的角色是...
你需要关注...
你应该输出...
```

## 高级 API 用法

### 批量操作

```python
import requests

# 批量导入
response = requests.post(
    'http://localhost:8765/api/knowledge/batch-import',
    json={
        'files': ['file1.md', 'file2.txt'],
        'tags': ['project-a', 'reference']
    }
)
```

### WebSocket 实时流

```javascript
const socket = io('http://localhost:8765');

socket.on('agent:thinking', (data) => {
  console.log(`${data.agent} 正在思考...`);
});

socket.on('agent:speaking', (data) => {
  console.log(`${data.agent}: ${data.content}`);
});
```

## 插件系统

### 开发插件

```python
from scriptroom.plugins import BasePlugin

class MyPlugin(BasePlugin):
    name = "my-plugin"
    version = "1.0.0"
    
    def on_agent_output(self, agent_id, output):
        # 处理智能体输出
        return modified_output
    
    def on_script_complete(self, script):
        # 处理完成后处理
        pass
```

### 注册插件

```python
from scriptroom.app import app
from my_plugin import MyPlugin

app.register_plugin(MyPlugin())
```

## 工作流自定义

### 定义工作流

```yaml
# workflows/custom.yaml
name: "自定义编剧工作流"
agents:
  - id: showrunner
    timeout: 300
  - id: story_architect
    timeout: 600
  - id: screenplay_writer
    timeout: 900

rules:
  - if: "screenplay_writer.word_count < 5000"
    then: "route_to: showrunner"
```

## 数据分析

### 获取统计数据

```python
from scriptroom.analytics import Analytics

analytics = Analytics()

# 获取运行统计
stats = analytics.get_run_statistics(
    start_date='2026-06-01',
    end_date='2026-06-30'
)

print(f"总运行数: {stats['total_runs']}")
print(f"平均耗时: {stats['avg_duration']}")
```

## 企业级部署

### 多机房部署

使用 Kubernetes 实现多机房高可用

### 数据同步

跨机房数据同步和一致性保证

### 灾备策略

主-备模式实现自动故障转移
