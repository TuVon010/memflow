import Foundation

/// 面试计划结果
struct InterviewPlan {
    /// 剩余天数
    let daysRemaining: Int
    /// 建议每日新卡数
    let suggestedDailyNewCards: Int
    /// 建议每日复习数
    let suggestedDailyReviews: Int
    /// 总新卡数量
    let totalNewCards: Int
    /// 预计面试前完成百分比 (0.0~1.0)
    let estimatedCompletionRate: Double
    /// 高优先级卡片能否在面试前完成 3 轮复习
    let highPriorityComplete: Bool
}

/// 面试每日可用时间
enum InterviewDailyTime: CaseIterable {
    case thirtyMin
    case oneHour
    case twoHours

    var minutes: Int {
        switch self {
        case .thirtyMin: return 30
        case .oneHour: return 60
        case .twoHours: return 120
        }
    }

    var label: String {
        switch self {
        case .thirtyMin: return "30分钟"
        case .oneHour: return "1小时"
        case .twoHours: return "2小时"
        }
    }
}

/// 面试倒计时计划器
///
/// 根据用户设定的面试日期、日均可投入时间、卡组优先级，
/// 计算每日建议新卡量和预期完成度。
struct InterviewPlanner {
    /// 每分钟平均可复习卡片数（经验值）
    static let cardsPerMinute: Double = 2.0

    /// 计算面试冲刺计划
    func calculate(
        interviewDate: Date,
        dailyTime: InterviewDailyTime,
        totalNewCards: Int,
        totalDueCards: Int,
        highPriorityCardCount: Int
    ) -> InterviewPlan {
        let now = Date()
        let daysRemaining = max(0, Calendar.current.dateComponents([.day], from: now, to: interviewDate).day ?? 0)

        let dailyCapacity = Int((Double(dailyTime.minutes) * Self.cardsPerMinute).rounded())

        guard daysRemaining > 0, dailyCapacity > 0 else {
            return InterviewPlan(
                daysRemaining: daysRemaining,
                suggestedDailyNewCards: 0,
                suggestedDailyReviews: totalDueCards,
                totalNewCards: totalNewCards,
                estimatedCompletionRate: 0,
                highPriorityComplete: false
            )
        }

        let suggestedDailyNewCards = min(
            Int(ceil(Double(totalNewCards) / Double(daysRemaining))),
            dailyCapacity
        )

        let suggestedDailyReviews = max(0, dailyCapacity - suggestedDailyNewCards)

        let totalCapacity = dailyCapacity * daysRemaining
        let completionRate = totalNewCards > 0 ? min(1.0, Double(totalCapacity) / Double(totalNewCards)) : 1.0

        let highPriorityDaysNeeded = highPriorityCardCount > 0
            ? Int(ceil(Double(highPriorityCardCount * 3) / Double(dailyCapacity)))
            : 0
        let highPriorityComplete = highPriorityDaysNeeded <= daysRemaining

        return InterviewPlan(
            daysRemaining: daysRemaining,
            suggestedDailyNewCards: suggestedDailyNewCards,
            suggestedDailyReviews: suggestedDailyReviews,
            totalNewCards: totalNewCards,
            estimatedCompletionRate: completionRate,
            highPriorityComplete: highPriorityComplete
        )
    }
}
