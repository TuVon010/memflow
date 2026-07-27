import Foundation
import SwiftData

/// MemFlow 复习状态数据模型
///
/// 每张卡片对应一条复习状态，记录 SM-2 算法的调度参数。
/// 包含复习历史日志（评分记录），用于追踪学习历史。
@Model
final class ReviewState {
    /// 关联卡片（一对一）
    @Relationship(inverse: \Card.reviewState)
    var card: Card?

    /// 下次复习到期时间
    var due: Date

    /// 记忆稳定性 / 当前间隔（天）
    var stability: Double

    /// 难度系数 EF (SM-2)，默认 2.5
    var difficultyFactor: Double

    /// 总复习次数
    var reps: Int

    /// 遗忘次数（评分=生疏的次数）
    var lapses: Int

    /// 上次复习日期
    var lastReview: Date?

    /// 实际计算出的下次复习日期
    var nextReview: Date?

    /// 复习历史记录（一对多，级联删除）
    @Relationship(deleteRule: .cascade)
    var reviewLogs: [ReviewLogEntry] = []

    init(
        due: Date = Date(),
        stability: Double = 1.0,
        difficultyFactor: Double = 2.5,
        reps: Int = 0,
        lapses: Int = 0,
        lastReview: Date? = nil,
        nextReview: Date? = nil
    ) {
        self.due = due
        self.stability = stability
        self.difficultyFactor = difficultyFactor
        self.reps = reps
        self.lapses = lapses
        self.lastReview = lastReview
        self.nextReview = nextReview
    }
}
