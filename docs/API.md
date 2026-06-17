# API 文档

## 概览

多智能体编剧系统提供以下 API 接口：

### 基础 URL

```
http://localhost:8765/api
```

## 知识库 API

### 获取资料源列表

```
GET /knowledge/sources
```

**响应**:
```json
{
  "sources": [
    {
      "id": 1,
      "title": "剧本语料库",
      "type": "script",
      "created_at": "2024-01-01T00:00:00Z",
      "description": "收集的优秀剧本样本"
    }
  ]
}
```

### 导入资料

```
POST /knowledge/import
```

**请求体**:
```json
{
  "title": "新资料",
  "type": "text",
  "content": "资料内容文本或文件路径",
  "source_type": "paste|file|url",
  "use_for_reference": true
}
```

**响应**:
```json
{
  "success": true,
  "source_id": 2,
  "message": "资料导入成功"
}
```

### 搜索资料

```
POST /knowledge/search
```

**请求体**:
```json
{
  "agent_id": "showrunner",
  "query": "故事结构",
  "limit": 5
}
```

**响应**:
```json
{
  "results": [
    {
      "source_id": 1,
      "title": "剧本语料库",
      "excerpt": "优秀剧本的故事结构分析...",
      "relevance": 0.95
    }
  ]
}
```

## 编剧室运行 API

### 启动编剧室

```
POST /projects/:id/run-stream
```

**请求体**:
```json
{
  "title": "故事标题",
  "genre": "类型",
  "tone": "基调",
  "theme": "主题",
  "premise": "前提",
  "provider": "offline|openai|deepseek",
  "model": "gpt-4-mini",
  "skip_tls_verify": false
}
```

**流式响应** (Server-Sent Events):
```
data: {"agent": "showrunner", "status": "thinking", "timestamp": "2024-01-01T00:00:00Z"}
data: {"agent": "showrunner", "status": "speaking", "content": "总编剧开始讨论..."}
data: {"agent": "story_architect", "status": "thinking", "timestamp": "2024-01-01T00:00:01Z"}
```

### 查询运行历史

```
GET /projects/:id/runs
```

**查询参数**:
- `limit`: 返回结果数量（默认10）
- `offset`: 分页偏移（默认0）

**响应**:
```json
{
  "runs": [
    {
      "id": "run-123",
      "title": "故事标题",
      "created_at": "2024-01-01T00:00:00Z",
      "status": "completed",
      "output_file": "outputs/故事标题.md"
    }
  ],
  "total": 25
}
```

### 获取运行详情

```
GET /projects/:id/runs/:run_id
```

**响应**:
```json
{
  "id": "run-123",
  "title": "故事标题",
  "agents_output": [
    {
      "agent_id": "showrunner",
      "agent_name": "总编剧",
      "output": "总编剧的讨论内容...",
      "duration_ms": 1234
    }
  ],
  "created_at": "2024-01-01T00:00:00Z",
  "completed_at": "2024-01-01T00:05:00Z",
  "status": "completed"
}
```

## 人工干预 API

### 发送人工意见

```
POST /projects/:id/runs/:run_id/feedback
```

**请求体**:
```json
{
  "user": "创意总监",
  "message": "@故事架构师 需要加强第二幕的冲突",
  "mention_agent": "story_architect"
}
```

**响应**:
```json
{
  "success": true,
  "feedback_id": "feedback-456",
  "next_run_id": "run-124"
}
```

### 请求修改

```
POST /projects/:id/runs/:run_id/revise
```

**请求体**:
```json
{
  "target_agent": "dialogue_writer",
  "revision_notes": "对白需要更有张力和节奏感",
  "priority": "high"
}
```

**响应**:
```json
{
  "success": true,
  "revision_id": "rev-789",
  "status": "queued"
}
```

## 剧本导出 API

### 导出为 Word

```
GET /projects/:id/runs/:run_id/export/docx
```

**响应**: Word 文件（application/vnd.openxmlformats-officedocument.wordprocessingml.document）

### 导出为 Markdown

```
GET /projects/:id/runs/:run_id/export/markdown
```

**响应**: Markdown 文件（text/markdown）

### 导出为 PDF

```
GET /projects/:id/runs/:run_id/export/pdf
```

**响应**: PDF 文件（application/pdf）

## 错误响应

所有 API 错误返回统一格式：

```json
{
  "error": {
    "code": "INVALID_REQUEST",
    "message": "请求参数错误",
    "details": {
      "field": "title",
      "issue": "标题不能为空"
    }
  }
}
```

### 错误代码

- `INVALID_REQUEST`: 请求参数无效
- `AUTHENTICATION_FAILED`: 认证失败
- `RATE_LIMITED`: 请求过于频繁
- `PROVIDER_ERROR`: AI 提供商错误
- `INTERNAL_ERROR`: 服务器内部错误

## 认证

某些 API 端点可能需要认证。使用 API Key 认证：

```
Authorization: Bearer YOUR_API_KEY
```

或作为查询参数：

```
GET /api/endpoint?api_key=YOUR_API_KEY
```

## 速率限制

- 免费用户: 10 请求/分钟
- 付费用户: 100 请求/分钟

响应头包含：
- `X-RateLimit-Limit`: 限制数
- `X-RateLimit-Remaining`: 剩余请求数
- `X-RateLimit-Reset`: 重置时间戳
