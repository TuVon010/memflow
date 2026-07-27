import Foundation

/// 全局常量与预设
enum Constants {
    /// LLM 提供商预设
    enum LLMPresets {
        static let openai = (name: "OpenAI", url: "https://api.openai.com/v1", model: "gpt-4o")
        static let deepseek = (name: "DeepSeek", url: "https://api.deepseek.com/v1", model: "deepseek-chat")
        static let ollama = (name: "Ollama", url: "http://localhost:11434/v1", model: "llama3")
    }

    /// 导出文件扩展名
    static let exportFileExtension = "mfcard.json"
    static let exportFileMimeType = "application/json"

    /// 卡片类型
    enum CardType: String, CaseIterable {
        case basic = "basic"
        case cloz = "cloz"
        case comparison = "comparison"
        case code = "code"

        var label: String {
            switch self {
            case .basic: return "基本"
            case .cloz: return "填空"
            case .comparison: return "对比"
            case .code: return "代码"
            }
        }
    }
}
