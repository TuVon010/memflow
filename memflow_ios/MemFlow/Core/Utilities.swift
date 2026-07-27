import Foundation

/// 工具函数集
enum Utilities {
    /// 获取当天开始时间 (00:00:00)
    static func startOfDay(_ date: Date = Date()) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    /// 格式化日期为简短显示
    static func formatDateShort(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date, to: now)

        if let days = components.day {
            if days == 0 { return "今天" }
            if days == 1 { return "昨天" }
            if days < 7 { return "\(days)天前" }
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }

    /// 格式化日期为完整显示
    static func formatDateFull(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    /// 格式化学习时长
    static func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds / 60)
        if minutes >= 60 {
            return "\(minutes / 60)小时\(minutes % 60)分钟"
        } else if minutes > 0 {
            return "\(minutes)分钟"
        } else {
            return "不到1分钟"
        }
    }
}
