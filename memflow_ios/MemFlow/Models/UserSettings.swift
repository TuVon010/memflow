import Foundation
import SwiftData

/// MemFlow 用户设置模型
///
/// 单例模型，仅存储一条记录。
/// API Key 存储于系统 Keychain，此处仅保存其他配置项。
@Model
final class UserSettings {
    /// 每日新卡片上限，默认 20
    var dailyNewCardLimit: Int

    /// 每日复习上限（0 表示不限制）
    var dailyReviewLimit: Int

    /// 首选 LLM 提供商标识: openai, deepseek, ollama, custom
    var preferredLLMProvider: String

    /// LLM API 基础 URL
    var llmBaseURL: String

    /// LLM 模型名称
    var llmModel: String

    /// 面试倒计时目标日期（可选）
    var interviewDate: Date?

    /// 是否开启面试倒计时模式
    var interviewModeEnabled: Bool

    /// 主题模式: 0=跟随系统, 1=浅色, 2=深色
    var themeMode: Int

    /// 每日提醒时间列表，存储为时间字符串数组 "HH:mm"
    var reminderTimesString: String

    /// 计算属性：提醒时间列表
    var reminderTimes: [Date] {
        get {
            guard !reminderTimesString.isEmpty else { return [] }
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return reminderTimesString.components(separatedBy: ",").compactMap {
                formatter.date(from: $0)
            }
        }
        set {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            reminderTimesString = newValue.compactMap { formatter.string(from: $0) }.joined(separator: ",")
        }
    }

    /// 面试剩余天数
    var daysUntilInterview: Int? {
        guard let date = interviewDate else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        return max(0, days)
    }

    init(
        dailyNewCardLimit: Int = 20,
        dailyReviewLimit: Int = 0,
        preferredLLMProvider: String = "openai",
        llmBaseURL: String = "https://api.openai.com/v1",
        llmModel: String = "gpt-4o",
        interviewDate: Date? = nil,
        interviewModeEnabled: Bool = false,
        themeMode: Int = 0,
        reminderTimes: [Date] = []
    ) {
        self.dailyNewCardLimit = dailyNewCardLimit
        self.dailyReviewLimit = dailyReviewLimit
        self.preferredLLMProvider = preferredLLMProvider
        self.llmBaseURL = llmBaseURL
        self.llmModel = llmModel
        self.interviewDate = interviewDate
        self.interviewModeEnabled = interviewModeEnabled
        self.themeMode = themeMode
        self.reminderTimesString = ""
        self.reminderTimes = reminderTimes
    }
}
