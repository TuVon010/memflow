import Foundation
import SwiftData

/// MemFlow 复习会话模型
///
/// 用于统计每日学习时长和复习量（P2 功能）。
/// 每次复习会话记录开始/结束时间和卡片数量。
@Model
final class ReviewSession {
    /// 会话开始时间
    var startedAt: Date

    /// 会话结束时间
    var endedAt: Date?

    /// 本次复习卡片数量
    var cardsReviewed: Int

    /// 会话日期（用于按日分组统计）
    var date: Date

    /// 本次复习中 rating 分布: again/hard/good 计数
    var againCount: Int
    var hardCount: Int
    var goodCount: Int

    /// 会话耗时（秒）
    var duration: TimeInterval {
        guard let end = endedAt else { return 0 }
        return end.timeIntervalSince(startedAt)
    }

    init(
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        cardsReviewed: Int = 0,
        date: Date = Date(),
        againCount: Int = 0,
        hardCount: Int = 0,
        goodCount: Int = 0
    ) {
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.cardsReviewed = cardsReviewed
        self.date = date
        self.againCount = againCount
        self.hardCount = hardCount
        self.goodCount = goodCount
    }
}
