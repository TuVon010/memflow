import Foundation
import SwiftUI
import SwiftData
import Observation

/// 设置管理 ViewModel
@MainActor
@Observable
final class SettingsViewModel {
    private(set) var settings: UserSettings?

    var apiKey: String = ""
    var isApiKeyLoaded: Bool = false

    var isLoading: Bool = false

    /// 加载设置
    func loadSettings(modelContext: ModelContext) {
        isLoading = true
        let descriptor = FetchDescriptor<UserSettings>()

        if let existing = try? modelContext.fetch(descriptor).first {
            settings = existing
        } else {
            let newSettings = UserSettings()
            modelContext.insert(newSettings)
            try? modelContext.save()
            settings = newSettings
        }

        // 加载 API Key
        Task {
            await loadApiKey()
            isLoading = false
        }
    }

    /// 从 Keychain 加载 API Key
    private func loadApiKey() async {
        if let key = await KeychainService.shared.getApiKey() {
            apiKey = key
            isApiKeyLoaded = true
        }
    }

    /// 保存 API Key
    func saveApiKey(_ key: String) async {
        let success = await KeychainService.shared.saveApiKey(key)
        if success {
            apiKey = key
            isApiKeyLoaded = true
        }
    }

    /// 删除 API Key
    func deleteApiKey() async {
        let _ = await KeychainService.shared.deleteApiKey()
        apiKey = ""
        isApiKeyLoaded = false
    }

    /// 更新 AI 配置
    func updateAIConfig(provider: String, baseURL: String, model: String, modelContext: ModelContext) {
        guard let s = settings else { return }
        s.preferredLLMProvider = provider
        s.llmBaseURL = baseURL
        s.llmModel = model
        try? modelContext.save()
    }

    /// 更新面试模式
    func setInterviewMode(enabled: Bool, date: Date?, modelContext: ModelContext) {
        guard let s = settings else { return }
        s.interviewModeEnabled = enabled
        s.interviewDate = date
        try? modelContext.save()
    }

    /// 更新主题
    func setThemeMode(_ mode: Int, modelContext: ModelContext) {
        guard let s = settings else { return }
        s.themeMode = mode
        try? modelContext.save()
    }

    /// 更新提醒时间
    func setReminderTimes(_ times: [Date], modelContext: ModelContext) {
        guard let s = settings else { return }
        s.reminderTimes = times
        try? modelContext.save()
    }

    /// 更新每日新卡上限
    func setDailyNewCardLimit(_ limit: Int, modelContext: ModelContext) {
        guard let s = settings else { return }
        s.dailyNewCardLimit = limit
        try? modelContext.save()
    }
}
