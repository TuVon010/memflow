# MemFlow API 接口说明（外部 AI）

## 1. 概述

MemFlow 纯移动端架构**不依赖自有后端服务器**，所有 AI 功能通过 App 直接调用大模型提供商的标准 API 实现。本文档定义 AI 调用的端点、请求/响应格式、错误处理与重试策略。

---

## 2. 你的系统需要哪些 API？

### 2.1 结论：**只有一种——大模型 API**

因为你选择了纯移动端方案（无服务器），所以：
- **不需要** 设计用户认证 API
- **不需要** 设计数据同步 API
- **不需要** 设计卡组社区 API
- **需要** 的仅仅是：**调用大模型（LLM）的聊天补全接口**

所有数据存储、复习调度、卡组管理都在本地完成，AI 拆卡和答疑直接由 App 内 HTTP 客户端向 OpenAI / DeepSeek 等发送请求。

### 2.2 未来可能需要的新 API（占位思考）

| 场景 | API | 触发时机 |
|------|-----|---------|
| 用户反馈/报错 | `POST /api/feedback`（可选自建） | 用户主动提交 |
| 版本更新检查 | `GET /api/version`（GitHub Releases API） | 启动时 |
| 卡组社区（Web 浏览） | GitHub REST API（读取 `memflow-cards` 主题仓库） | P3 |

这些不是 MVP 必需，可用 GitHub API 零成本实现，无需自建服务器。

---

## 3. 大模型聊天补全 API

### 3.1 端点

| 提供商 | 端点 |
|--------|------|
| OpenAI | `https://api.openai.com/v1/chat/completions` |
| DeepSeek | `https://api.deepseek.com/v1/chat/completions` |
| Ollama（本地） | `http://localhost:11434/v1/chat/completions` |
| 其他兼容接口 | 用户自定义 `{BASE_URL}/v1/chat/completions` |

所有主流大模型 API 均兼容 OpenAI 的请求/响应格式，因此只需编写一个统一的客户端。

### 3.2 认证

- **Header**：`Authorization: Bearer {API_KEY}`
- API Key 由用户在设置中填写，使用 `flutter_secure_storage` 加密存储。

---

## 4. 请求格式

### 4.1 AI 拆卡（生成多张卡片）

**请求体**：

```json
{
  "model": "gpt-4o",
  "messages": [
    {
      "role": "system",
      "content": "你是一位面试专家，擅长将技术文本拆解为简洁的问答卡片。请严格按照 JSON 数组格式输出，每张卡片包含 question, answer, cardType, tags 字段。"
    },
    {
      "role": "user",
      "content": "请将以下文本拆解为 3~5 张记忆卡片：\n\nHashMap 是 Java 中最常用的 Map 实现。JDK 1.8 之前，HashMap 底层是数组+链表；JDK 1.8 之后，当链表长度大于 8 且数组长度大于等于 64 时，链表会转换为红黑树，以提升查询效率。HashMap 允许 null 键和 null 值，非线程安全。多线程环境可以使用 ConcurrentHashMap 替代。"
    }
  ],
  "temperature": 0.3,
  "max_tokens": 2000,
  "response_format": { "type": "json_object" }
}
```

**期望响应**：

```json
{
  "choices": [
    {
      "message": {
        "content": "{\n  \"cards\": [\n    {\n      \"question\": \"HashMap 的底层数据结构是什么？\",\n      \"answer\": \"JDK 1.8 之前：数组 + 链表；JDK 1.8 之后：当链表长度 > 8 且数组长度 ≥ 64 时，链表转为红黑树。\",\n      \"cardType\": \"basic\",\n      \"tags\": [\"java\", \"hashmap\"]\n    },\n    {\n      \"question\": \"HashMap 是线程安全的吗？多线程用什么替代？\",\n      \"answer\": \"HashMap 非线程安全，多线程环境应使用 ConcurrentHashMap。\",\n      \"cardType\": \"basic\",\n      \"tags\": [\"java\", \"hashmap\", \"concurrent\"]\n    }\n  ]\n}"
      }
    }
  ]
}
```

客户端解析 `content` 字段中的 JSON 字符串，提取 `cards` 数组并映射为 `CardPreview` 对象展示。

### 4.2 AI 划词答疑

**请求体**：

```json
{
  "model": "gpt-4o",
  "messages": [
    {
      "role": "system",
      "content": "你是一位耐心的技术导师。请根据卡片上下文，简洁解释用户选中的技术概念或代码。必要时给出示例，如果涉及面试常考点可附上追问建议。"
    },
    {
      "role": "user",
      "content": "卡片问题：HashMap 的底层数据结构是什么？\n卡片答案：JDK 1.8 之前：数组 + 链表；JDK 1.8 之后：当链表长度 > 8 且数组长度 ≥ 64 时，链表转为红黑树。\n\n用户选中了以下文字，请解释：\n\"链表转为红黑树\""
    }
  ],
  "temperature": 0.5,
  "max_tokens": 600
}
```

**期望响应**：

```json
{
  "choices": [
    {
      "message": {
        "content": "当 HashMap 中某个位置（桶）的链表长度超过 8 且整个数组长度 ≥ 64 时，链表会被转换为红黑树。这样做的原因是：链表查询时间复杂度为 O(n)，当 n 较大时性能很差；红黑树查询时间复杂度为 O(log n)，可以显著提升性能。\n\n面试追问：为什么阈值是 8 而不是其他数字？（提示：根据泊松分布，链表长度为 8 的概率极低）"
      }
    }
  ]
}
```

客户端直接提取 `choices[0].message.content` 展示在底部抽屉中。

---

## 5. 错误处理与重试策略

### 5.1 错误分类

| 状态码 | 含义 | 处理方式 |
|--------|------|---------|
| 200 | 成功 | 正常解析 |
| 401 | API Key 无效 | 提示用户检查 API Key 配置 |
| 402 | 余额不足 | 提示用户充值或更换 Key |
| 429 | 速率限制 | 等待后重试（最多 3 次），递增退避 |
| 500 | 服务器错误 | 提示用户稍后重试 |
| 超时 | 网络/服务无响应 | 等待后重试（最多 2 次） |

### 5.2 重试策略

```
function callAI(prompt, maxRetries=2):
    retries = 0
    while retries <= maxRetries:
        try:
            response = http.post(url, headers, body, timeout=30)
            
            if response.status == 200:
                return parseResponse(response)
            elif response.status == 429:
                // 速率限制：退避等待后重试
                waitSeconds = pow(2, retries)  // 1, 2, 4 秒
                sleep(waitSeconds)
                retries += 1
            elif response.status in [401, 402]:
                // 认证/余额错误不重试，直接抛错
                throw AIException(response.body)
            else:
                retries += 1
                
        except TimeoutException:
            retries += 1
            if retries > maxRetries:
                throw AITimeoutException("请求超时，请检查网络后重试")
    
    throw AIMaxRetriesException("AI 服务暂时不可用")
```

### 5.3 用户体验策略

- **Loading 态**：请求发出后立即显示骨架屏或进度指示器。
- **超时设置**：请求超时 30 秒，超时前显示“正在生成…”，超时后显示友好提示和重试按钮。
- **离线检测**：在调用 AI 前检查网络状态，若离线则直接提示，不发起请求。
- **错误信息**：将 API 返回的英文错误信息映射为中文友好提示（如 `insufficient_quota` → “API 余额不足，请充值后重试”）。

---

## 6. AI Service 抽象接口

在代码中，所有 AI 调用通过统一的抽象接口实现，方便切换提供商或模拟测试：

```dart
abstract class AIService {
  /// 将一段文本拆解为记忆卡片
  Future<List<CardPreview>> generateCards(String text, {String? customPrompt});
  
  /// 根据卡片上下文解释选中的文字
  Future<String> explain(String selectedText, CardContext context);
}

// 实现
class OpenAIService implements AIService {
  final Dio _dio;
  final String apiKey;
  final String baseUrl;
  final String model;
  // ...
}
```

通过 Riverpod 注入：

```dart
final aiServiceProvider = Provider<AIService>((ref) {
  final settings = ref.watch(settingsProvider);
  return OpenAIService(
    apiKey: settings.llmApiKey,
    baseUrl: settings.llmBaseURL,
    model: settings.llmModel,
  );
});
```

---

此文档覆盖了 MVP 阶段 App 所需的所有外部 API 调用，无需设计其他接口。