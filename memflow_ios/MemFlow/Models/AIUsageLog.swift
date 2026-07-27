import Foundation
import SwiftData

/// MemFlow AI 调用日志
///
/// 记录每次 AI API 调用的基本信息，用于统计和用户自我监控。
@Model
final class AIUsageLog {
    /// 调用时间
    var timestamp: Date

    /// 用途: generate-cards(拆卡), explain(答疑)
    var purpose: String

    /// LLM 提供商: openai, deepseek, ollama
    var provider: String

    /// 模型名称
    var model: String

    /// 消耗的 Token 数量（近似值）
    var tokenCount: Int

    /// 是否调用成功
    var success: Bool

    init(
        timestamp: Date = Date(),
        purpose: String = "",
        provider: String = "",
        model: String = "",
        tokenCount: Int = 0,
        success: Bool = true
    ) {
        self.timestamp = timestamp
        self.purpose = purpose
        self.provider = provider
        self.model = model
        self.tokenCount = tokenCount
        self.success = success
    }
}
