import SwiftUI
import SwiftData

/// 设置页面
///
/// "设置" Tab，管理 AI 配置、复习偏好、面试计划、提醒时间、数据导入导出等。
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            Form {
                // AI 配置
                aiConfigSection

                // 复习设置
                reviewSettingsSection

                // 面试计划
                interviewPlanSection

                // 通知
                reminderSection

                // 外观
                themeSection

                // 数据管理
                dataManagementSection

                // 关于
                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("v0.5.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
            .task {
                viewModel.loadSettings(modelContext: modelContext)
            }
        }
    }

    // MARK: - AI 配置

    private var aiConfigSection: some View {
        Section("AI 配置") {
            Picker("提供商", selection: Binding(
                get: { viewModel.settings?.preferredLLMProvider ?? "openai" },
                set: { provider in
                    let presets: [String: (url: String, model: String)] = [
                        "openai": ("https://api.openai.com/v1", "gpt-4o"),
                        "deepseek": ("https://api.deepseek.com/v1", "deepseek-chat"),
                        "ollama": ("http://localhost:11434/v1", "llama3"),
                    ]
                    if let preset = presets[provider] {
                        viewModel.updateAIConfig(
                            provider: provider,
                            baseURL: preset.url,
                            model: preset.model,
                            modelContext: modelContext
                        )
                    }
                }
            )) {
                Text("OpenAI").tag("openai")
                Text("DeepSeek").tag("deepseek")
                Text("Ollama").tag("ollama")
            }

            HStack {
                Text("Base URL")
                Spacer()
                Text(viewModel.settings?.llmBaseURL ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            HStack {
                Text("API Key")
                Spacer()
                if viewModel.isApiKeyLoaded {
                    SecureField("", text: $viewModel.apiKey)
                        .frame(width: 120)
                } else {
                    Text("未设置")
                        .foregroundStyle(.red)
                }
            }

            HStack {
                Text("模型")
                Spacer()
                Text(viewModel.settings?.llmModel ?? "gpt-4o")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - 复习设置

    private var reviewSettingsSection: some View {
        Section("复习设置") {
            Stepper(
                "每日新卡上限: \(viewModel.settings?.dailyNewCardLimit ?? 20) 张",
                value: Binding(
                    get: { viewModel.settings?.dailyNewCardLimit ?? 20 },
                    set: { viewModel.setDailyNewCardLimit($0, modelContext: modelContext) }
                ),
                in: 5...100,
                step: 5
            )
        }
    }

    // MARK: - 面试计划

    private var interviewPlanSection: some View {
        Section {
            Toggle("面试倒计时模式", isOn: Binding(
                get: { viewModel.settings?.interviewModeEnabled ?? false },
                set: { viewModel.setInterviewMode(
                    enabled: $0,
                    date: viewModel.settings?.interviewDate,
                    modelContext: modelContext
                )}
            ))

            if viewModel.settings?.interviewModeEnabled == true {
                DatePicker(
                    "面试日期",
                    selection: Binding(
                        get: { viewModel.settings?.interviewDate ?? Date().addingTimeInterval(30 * 24 * 3600) },
                        set: { viewModel.setInterviewMode(enabled: true, date: $0, modelContext: modelContext) }
                    ),
                    displayedComponents: .date
                )

                if let days = viewModel.settings?.daysUntilInterview {
                    HStack {
                        Text("剩余天数")
                        Spacer()
                        Text("\(days) 天")
                            .fontWeight(.bold)
                    }
                }

                Picker("每日可用时间", selection: .constant(InterviewDailyTime.oneHour)) {
                    ForEach(InterviewDailyTime.allCases, id: \.self) { time in
                        Text(time.label).tag(time)
                    }
                }
            }
        } header: {
            Text("面试计划")
        }
    }

    // MARK: - 通知

    private var reminderSection: some View {
        Section("复习提醒") {
            ForEach(Array((viewModel.settings?.reminderTimes ?? []).enumerated()), id: \.offset) { index, _ in
                HStack {
                    Text("提醒 \(index + 1)")
                    Spacer()
                    // 简化显示——实际应从 DatePicker 获取
                    Text("待设置")
                        .foregroundStyle(.secondary)
                }
            }

            if (viewModel.settings?.reminderTimes.count ?? 0) < 3 {
                Button("添加提醒时间") {
                    // TODO: 添加自定义时间选择
                }
            }
        }
    }

    // MARK: - 主题

    private var themeSection: some View {
        Section("外观") {
            Picker("主题", selection: Binding(
                get: { viewModel.settings?.themeMode ?? 0 },
                set: { viewModel.setThemeMode($0, modelContext: modelContext) }
            )) {
                Text("跟随系统").tag(0)
                Text("浅色").tag(1)
                Text("深色").tag(2)
            }
        }
    }

    // MARK: - 数据管理

    private var dataManagementSection: some View {
        Section("数据管理") {
            Button {
                // TODO: 导出功能
            } label: {
                Label("导出卡组", systemImage: "square.and.arrow.up")
            }

            Button {
                // TODO: 导入功能
            } label: {
                Label("导入卡组", systemImage: "square.and.arrow.down")
            }
        }
    }
}
