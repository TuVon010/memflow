import Foundation

/// 复习队列条目
struct ReviewItem: Identifiable {
    let id = UUID()
    let card: Card
    let reviewState: ReviewState?

    /// 是否为新卡片（从未学习过）
    var isNewCard: Bool {
        reviewState == nil || reviewState?.reps == 0
    }
}

/// 每日复习队列生成器
///
/// 负责组装每日复习队列：到期待复习卡片 + 新卡片，按比例交错排列。
/// 支持面试倒计时模式下的优先级排序和动态新卡上限调整。
struct QueueGenerator {
    /// 默认新卡与复习卡的交错比例：每 3 张复习卡插入 1 张新卡
    static let defaultInterleaveRatio = 3

    /// 面试模式下的每日最大新卡数
    static let interviewMaxNewCards = 50

    /// 生成当天的复习队列
    ///
    /// - Parameters:
    ///   - dueCards: 到期待复习的卡片及其状态（按 due 升序）
    ///   - newCards: 从未学习过的新卡片
    ///   - settings: 用户设置
    ///   - deckPriorities: 卡组 ID 到优先级的映射
    ///   - daysUntilInterview: 距离面试剩余天数
    /// - Returns: 有序的复习队列
    func generate(
        dueCards: [(Card, ReviewState)],
        newCards: [Card],
        settings: UserSettings,
        deckPriorities: [PersistentIdentifier: Double] = [:],
        daysUntilInterview: Int? = nil
    ) -> [ReviewItem] {
        // 1. 构建到期卡片条目（已按 due 升序排列）
        let dueItems = dueCards.map { card, state in
            ReviewItem(card: card, reviewState: state)
        }

        // 2. 排序新卡片
        let sortedNewCards: [Card]
        if settings.interviewModeEnabled {
            sortedNewCards = newCards.sorted { a, b in
                let aDeckPriority = deckPriorities[a.deck?.persistentModelID ?? UUID() as! PersistentIdentifier] ?? 0.0
                let bDeckPriority = deckPriorities[b.deck?.persistentModelID ?? UUID() as! PersistentIdentifier] ?? 0.0
                let aScore = a.difficulty * 0.6 + aDeckPriority * 0.4
                let bScore = b.difficulty * 0.6 + bDeckPriority * 0.4
                if aScore != bScore {
                    return aScore > bScore
                }
                return a.createdAt < b.createdAt
            }
        } else {
            sortedNewCards = newCards.sorted { $0.createdAt < $1.createdAt }
        }

        // 3. 计算今日新卡数量上限
        let newCardLimit: Int
        if settings.interviewModeEnabled, let daysLeft = daysUntilInterview, daysLeft > 0 {
            newCardLimit = calculateDynamicLimit(
                baseLimit: settings.dailyNewCardLimit,
                totalNewCards: sortedNewCards.count,
                daysUntilInterview: daysLeft
            )
        } else {
            newCardLimit = settings.dailyNewCardLimit
        }

        // 4. 截取新卡
        let todayNewCards = Array(sortedNewCards.prefix(newCardLimit))

        // 5. 交错合并
        return interleave(dueItems, todayNewCards, ratio: Self.defaultInterleaveRatio)
    }

    /// 动态计算面试模式下的每日新卡上限
    private func calculateDynamicLimit(baseLimit: Int, totalNewCards: Int, daysUntilInterview: Int) -> Int {
        guard daysUntilInterview > 0 else { return baseLimit }
        let neededPerDay = Int(ceil(Double(totalNewCards) / Double(daysUntilInterview)))
        return min(max(baseLimit, neededPerDay), Self.interviewMaxNewCards)
    }

    /// 按比例交错合并两个列表
    private func interleave(_ dueItems: [ReviewItem], _ newCards: [Card], ratio: Int) -> [ReviewItem] {
        var result: [ReviewItem] = []
        var dueIndex = 0
        var newIndex = 0

        while dueIndex < dueItems.count || newIndex < newCards.count {
            // 每轮先放 ratio 张到期卡片
            for _ in 0..<ratio where dueIndex < dueItems.count {
                result.append(dueItems[dueIndex])
                dueIndex += 1
            }
            // 再放 1 张新卡
            if newIndex < newCards.count {
                result.append(ReviewItem(card: newCards[newIndex], reviewState: nil))
                newIndex += 1
            }
        }

        return result
    }
}
