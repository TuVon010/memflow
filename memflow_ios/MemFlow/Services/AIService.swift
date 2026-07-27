import Foundation

// MARK: - AI 服务错误

enum AIServiceError: LocalizedError {
    case unauthorized
    case insufficientQuota
    case rateLimited
    case timeout
    case networkError
    case parseError(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "API Key 无效，请检查设置"
        case .insufficientQuota:
            return "API 余额不足，请充值后重试"
        case .rateLimited:
            return "请求过于频繁，请稍后重试"
        case .timeout:
            return "请求超时，请检查网络后重试"
        case .networkError:
            return "网络连接失败，请检查网络设置"
        case .parseError(let msg):
            return "解析 AI 响应失败: \(msg)"
        case .unknown(let msg):
            return msg
        }
    }
}

// MARK: - 卡片预览数据

/// AI 生成的卡片预览
struct CardPreview: Identifiable, Codable {
    let id = UUID()
    let question: String
    let answer: String
    let cardType: String
    let tags: [String]

    enum CodingKeys: String, CodingKey {
        case question, answer, cardType, tags
    }
}

// MARK: - AI 响应模型

private struct ChatCompletionRequest: Codable {
    let model: String
    let messages: [Message]
    let temperature: Double
    let maxTokens: Int
    let responseFormat: ResponseFormat?

    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
        case responseFormat = "response_format"
    }

    struct Message: Codable {
        let role: String
        let content: String
    }

    struct ResponseFormat: Codable {
        let type: String
    }
}

private struct ChatCompletionResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
        let message: Message
    }

    struct Message: Codable {
        let content: String
    }
}

private struct CardsResponse: Codable {
    let cards: [CardPreview]
}

// MARK: - AI 服务

/// OpenAI 兼容接口的 AI 服务
///
/// 支持所有 OpenAI-compatible API（OpenAI、DeepSeek、Ollama 等）。
/// 所有调用由客户端直连，不经过任何第三方服务器。
actor AIService {
    private let apiKey: String
    private let baseURL: String
    private let model: String
    private let maxRetries = 2
    private let timeoutSeconds: TimeInterval = 30

    init(apiKey: String, baseURL: String, model: String) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.model = model
    }

    // MARK: - 公开方法

    /// 将文本拆解为记忆卡片
    func generateCards(from text: String, customPrompt: String? = nil) async throws -> [CardPreview] {
        let systemPrompt = """
        你是一位面试专家，擅长将技术文本拆解为简洁的问答卡片。
        请严格按照 JSON 数组格式输出，每张卡片包含 question(问题)、answer(答案)、\
        cardType(类型: basic/cloz/comparison/code)、tags(标签数组) 字段。
        cardType 默认为 "basic"。只生成 3~5 张卡片。
        """

        let userPrompt = customPrompt ?? "请将以下文本拆解为 3~5 张记忆卡片：\n\n\(text)"

        let content = try await callAPI(
            messages: [
                (role: "system", content: systemPrompt),
                (role: "user", content: userPrompt),
            ],
            temperature: 0.3,
            maxTokens: 2000
        )

        return try parseCardsResponse(content)
    }

    /// 划词 AI 答疑
    func explain(selectedText: String, question: String, answer: String) async throws -> String {
        let systemPrompt = """
        你是一位耐心的技术导师。请根据卡片上下文，简洁解释用户选中的技术概念或代码。\
        必要时给出示例，如果涉及面试常考点可附上追问建议。
        """

        let userPrompt = """
        卡片问题：\(question)
        卡片答案：\(answer)

        用户选中了以下文字，请解释：
        "\(selectedText)"
        """

        return try await callAPI(
            messages: [
                (role: "system", content: systemPrompt),
                (role: "user", content: userPrompt),
            ],
            temperature: 0.5,
            maxTokens: 600
        )
    }

    // MARK: - 核心 API 调用

    private func callAPI(
        messages: [(role: String, content: String)],
        temperature: Double,
        maxTokens: Int
    ) async throws -> String {
        let urlString = "\(baseURL)/chat/completions"
        guard let url = URL(string: urlString) else {
            throw AIServiceError.unknown("无效的 URL: \(urlString)")
        }

        let requestBody = ChatCompletionRequest(
            model: model,
            messages: messages.map { ChatCompletionRequest.Message(role: $0.role, content: $0.content) },
            temperature: temperature,
            maxTokens: maxTokens,
            responseFormat: ChatCompletionRequest.ResponseFormat(type: "json_object")
        )

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.timeoutInterval = timeoutSeconds
        urlRequest.httpBody = try JSONEncoder().encode(requestBody)

        // 重试循环
        for retryCount in 0...maxRetries {
            do {
                let (data, response) = try await URLSession.shared.data(for: urlRequest)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw AIServiceError.networkError
                }

                switch httpResponse.statusCode {
                case 200:
                    let decoded = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
                    guard let content = decoded.choices.first?.message.content else {
                        throw AIServiceError.parseError("AI 返回空结果")
                    }
                    return content

                case 401:
                    throw AIServiceError.unauthorized
                case 402:
                    throw AIServiceError.insufficientQuota
                case 429:
                    if retryCount >= maxRetries {
                        throw AIServiceError.rateLimited
                    }
                    // 退避等待: 1s, 2s, 4s
                    let waitSeconds = pow(2.0, Double(retryCount))
                    try await Task.sleep(nanoseconds: UInt64(waitSeconds * 1_000_000_000))
                    continue
                case 500...599:
                    if retryCount >= maxRetries {
                        throw AIServiceError.unknown("AI 服务暂时不可用 (\(httpResponse.statusCode))")
                    }
                    continue
                default:
                    throw AIServiceError.unknown("未知错误 (\(httpResponse.statusCode))")
                }

            } catch let error as AIServiceError {
                throw error
            } catch let error as URLError where error.code == .timedOut {
                if retryCount >= maxRetries {
                    throw AIServiceError.timeout
                }
                continue
            } catch let error as URLError where error.code == .notConnectedToInternet {
                throw AIServiceError.networkError
            } catch {
                if retryCount >= maxRetries {
                    throw AIServiceError.unknown(error.localizedDescription)
                }
                continue
            }
        }

        throw AIServiceError.unknown("AI 服务不可用，已达最大重试次数")
    }

    // MARK: - 解析响应

    private func parseCardsResponse(_ content: String) throws -> [CardPreview] {
        guard let data = content.data(using: .utf8) else {
            throw AIServiceError.parseError("无效的响应编码")
        }

        // 尝试解析 {"cards": [...]} 格式
        if let cardsResponse = try? JSONDecoder().decode(CardsResponse.self, from: data) {
            return cardsResponse.cards
        }

        // 尝试解析 [...] 格式
        if let cardsArray = try? JSONDecoder().decode([CardPreview].self, from: data) {
            return cardsArray
        }

        // 尝试从 content 中提取 JSON 数组
        if let match = try? /\[[\s\S]*\]/.firstMatch(in: content),
           let arrayData = String(match.0).data(using: .utf8),
           let cardsArray = try? JSONDecoder().decode([CardPreview].self, from: arrayData) {
            return cardsArray
        }

        throw AIServiceError.parseError("无法识别 AI 返回的卡片格式")
    }
}
