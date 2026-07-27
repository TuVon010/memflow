import Foundation

/// SM-2 改良调度算法 — 核心复习引擎
///
/// 在标准 SM-2 基础上增加 EF 下限保护(1.3)、阶梯间隔(前两次强制 1/6 天)、
/// 面试倒计时模式下的间隔缩短(80%)。
enum SM2Scheduler {
    /// EF 下限，防止卡片因多次遗忘进入极度密集的复习循环
    static let minEF: Double = 1.3

    /// 面试模式下高优先级卡片的间隔缩短比例
    static let interviewIntervalRatio: Double = 0.8

    /// 面试模式下触发缩短的优先级阈值
    static let interviewPriorityThreshold: Double = 0.8

    /// 用户评分枚举
    enum Rating: Int, CaseIterable {
        /// 生疏 (Again) — 完全遗忘，内部质量分 q=0
        case again = 0
        /// 犹豫 (Hard) — 回忆困难，内部质量分 q=3
        case hard = 1
        /// 顺畅 (Good) — 轻松回忆，内部质量分 q=5
        case good = 2

        /// 内部质量分
        var quality: Int {
            switch self {
            case .again: return 0
            case .hard: return 3
            case .good: return 5
            }
        }

        var label: String {
            switch self {
            case .again: return "生疏"
            case .hard: return "犹豫"
            case .good: return "顺畅"
            }
        }
    }

    /// 调度结果
    struct Result {
        /// 更新后的难度系数 EF
        let difficultyFactor: Double
        /// 新的间隔（天）
        let interval: Int
        /// 下次复习到期日
        let due: Date
        /// 连续成功复习次数
        let repetitions: Int
    }

    /// 核心调度算法
    ///
    /// - Parameters:
    ///   - ef: 当前难度系数
    ///   - interval: 当前间隔（天）
    ///   - repetitions: 连续成功复习次数
    ///   - rating: 用户评分
    ///   - interviewMode: 是否开启面试倒计时模式
    ///   - cardPriority: 卡片优先级 (0.0~1.0)
    /// - Returns: 更新后的调度参数
    static func schedule(
        ef: Double,
        interval: Int,
        repetitions: Int,
        rating: Rating,
        interviewMode: Bool = false,
        cardPriority: Double = 0.0
    ) -> Result {
        let q = rating.quality

        // 1. 更新难度系数 EF
        let newEF: Double
        let newRepetitions: Int

        if q >= 3 {
            // 成功回忆：EF 根据质量分调整
            // EF' = EF + (0.1 - (5-q)*(0.08 + (5-q)*0.02))
            let delta = 0.1 - Double(5 - q) * (0.08 + Double(5 - q) * 0.02)
            newEF = ef + delta
            newRepetitions = repetitions + 1
        } else {
            // 遗忘：EF 惩罚并重置连续成功次数
            newEF = ef - 0.2
            newRepetitions = 0
        }

        // EF 边界保护
        let clampedEF = max(newEF, minEF)

        // 2. 计算新间隔
        let newInterval: Int
        if q == 0 {
            // 完全遗忘，明天再复习
            newInterval = 1
        } else if newRepetitions == 1 {
            // 第一次成功，1 天后
            newInterval = 1
        } else if newRepetitions == 2 {
            // 第二次成功，6 天后（早期巩固关键期）
            newInterval = 6
        } else {
            // 常规间隔 = 上次间隔 × EF
            newInterval = max(Int((Double(interval) * clampedEF).rounded()), 1)
        }

        // 3. 面试倒计时模式调整
        var finalInterval = newInterval
        if interviewMode && cardPriority >= interviewPriorityThreshold {
            // 高优先级卡片缩短间隔 20%，但不低于 1 天
            finalInterval = max(1, Int((Double(newInterval) * interviewIntervalRatio).rounded(.down)))
        }

        // 4. 计算下次复习到期时间
        let due = Calendar.current.date(byAdding: .day, value: finalInterval, to: Date()) ?? Date()

        return Result(
            difficultyFactor: clampedEF,
            interval: finalInterval,
            due: due,
            repetitions: newRepetitions
        )
    }
}
