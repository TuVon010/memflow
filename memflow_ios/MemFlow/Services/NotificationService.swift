import Foundation
import UserNotifications

/// MemFlow 本地通知服务
///
/// 基于 UserNotifications 框架实现每日复习提醒。
/// 支持设置 1~3 个每日固定提醒时间，无需联网。
@MainActor
final class NotificationService: NSObject, @unchecked Sendable {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()

    private override init() {
        super.init()
        center.delegate = self
    }

    /// 请求通知权限
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("通知权限请求失败: \(error)")
            return false
        }
    }

    /// 根据提醒时间列表更新定时通知
    func updateReminders(_ times: [Date]) async {
        // 先取消所有已有通知
        center.removeAllPendingNotificationRequests()

        let calendar = Calendar.current
        for (index, time) in times.enumerated() where index < 3 {
            let components = calendar.dateComponents([.hour, .minute], from: time)

            let content = UNMutableNotificationContent()
            content.title = "📚 该复习了"
            content.body = "今天还有卡片等待复习，趁热打铁吧！"
            content.sound = .default
            content.badge = 1

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: true
            )

            let request = UNNotificationRequest(
                identifier: "memflow-review-\(index)",
                content: content,
                trigger: trigger
            )

            do {
                try await center.add(request)
            } catch {
                print("添加通知失败: \(error)")
            }
        }
    }

    /// 取消所有通知
    func cancelAll() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }

    /// 查看当前排队的通知
    func pendingNotifications() async -> [UNNotificationRequest] {
        await center.pendingNotificationRequests()
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // 前台也显示通知
        completionHandler([.banner, .sound, .badge])
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // 点击通知后切换到复习 Tab 的逻辑由 App 层处理
        completionHandler()
    }
}
