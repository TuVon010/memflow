import SwiftUI
import SwiftData

/// MemFlow 应用入口
///
/// 使用 SwiftData 持久化全部数据，SwiftUI 驱动 UI。
/// 4 个 Tab：复习、卡组、统计、设置。
@main
struct MemFlowApp: App {
    @State private var settingsVM = SettingsViewModel()

    /// SwiftData 容器配置
    var modelContainer: ModelContainer = {
        let schema = Schema([
            Deck.self,
            Card.self,
            ReviewState.self,
            ReviewLogEntry.self,
            AIUsageLog.self,
            UserSettings.self,
            ReviewSession.self,
        ])

        let config = ModelConfiguration(
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("SwiftData 初始化失败: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear {
                    // 请求通知权限
                    Task {
                        await NotificationService.shared.requestAuthorization()
                    }
                }
        }
        .modelContainer(modelContainer)
    }
}

// MARK: - 主 Tab 导航

struct MainTabView: View {
    var body: some View {
        TabView {
            ReviewHomeView()
                .tabItem {
                    Label("复习", systemImage: "book.fill")
                }

            DeckListView()
                .tabItem {
                    Label("卡组", systemImage: "folder.fill")
                }

            StatsView()
                .tabItem {
                    Label("统计", systemImage: "chart.bar.fill")
                }

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape.fill")
                }
        }
    }
}
