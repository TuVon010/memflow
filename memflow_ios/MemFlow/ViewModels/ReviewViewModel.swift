import Foundation
import SwiftUI
import SwiftData
import Observation

/// 复习功能 ViewModel
///
/// 管理每日复习队列的生成、当前卡片状态、评分提交和完成统计。
/// 使用 @Observable 宏实现响应式数据绑定（iOS 17+）。
@MainActor
@Observable
final class ReviewViewModel {
    /// 复习队列
    private(set) var queue: [ReviewItem] = []

    /// 当前卡片索引
    private(set) var currentIndex: Int = 0

    /// 是否已完成全部复习
    private(set) var isCompleted: Bool = false

    /// 统计
    private(set) var againCount: Int = 0
    private(set) var hardCount: Int = 0
    private(set) var goodCount: Int = 0
    private(set) var reviewedCount: Int = 0

    /// 学习耗时
    private(set) var elapsedTime: TimeInterval = 0
    private var sessionStart: Date?
    private var questionShownTime: Date?

    /// 加载状态
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?

    /// 当前卡片
    var currentCard: ReviewItem? {
        guard currentIndex < queue.count else { return nil }
        return queue[currentIndex]
    }

    /// 是否还有下一张卡片
    var hasNextCard: Bool {
        currentIndex < queue.count
    }

    /// 总卡片数
    var totalCards: Int { queue.count }

    /// 复习进度
    var progress: Double {
        guard totalCards > 0 else { return 0 }
        return Double(reviewedCount) / Double(totalCards)
    }

    /// 记忆留存率
    var retentionRate: Double {
        guard reviewedCount > 0 else { return 0 }
        return Double(goodCount + hardCount) / Double(reviewedCount)
    }

    /// 当前问题显示时间
    func markQuestionShown() {
        questionShownTime = Date()
    }

    // MARK: - 队列生成

    /// 生成今日复习队列
    func generateQueue(modelContext: ModelContext) async {
        isLoading = true
        errorMessage = nil
        sessionStart = Date()

        let settings = await loadOrCreateSettings(modelContext: modelContext)

        // 查询到期待复习卡片
        let now = Date()
        let dueDescriptor = FetchDescriptor<ReviewState>(
            predicate: #Predicate { $0.due <= now && $0.reps > 0 },
            sortBy: [SortDescriptor(\.due)]
        )

        do {
            let dueStates = try modelContext.fetch(dueDescriptor)
            var dueItems: [(Card, ReviewState)] = []

            for state in dueStates {
                if let card = state.card {
                    dueItems.append((card, state))
                }
            }

            // 查询新卡片（reps == 0 或无 ReviewState）
            var newCardDescriptor = FetchDescriptor<Card>()
            newCardDescriptor.predicate = #Predicate { $0.reviewState == nil || $0.reviewState?.reps == 0 }
            newCardDescriptor.sortBy = [SortDescriptor(\.createdAt)]
            let newCards = try modelContext.fetch(newCardDescriptor)

            let generator = QueueGenerator()
            let items = generator.generate(
                dueCards: dueItems,
                newCards: newCards,
                settings: settings,
                deckPriorities: [:],
                daysUntilInterview: settings.daysUntilInterview
            )

            self.queue = items
            self.currentIndex = 0
            self.isCompleted = items.isEmpty
            self.reviewedCount = 0
            self.againCount = 0
            self.hardCount = 0
            self.goodCount = 0
            self.isLoading = false

        } catch {
            self.errorMessage = "生成复习队列失败: \(error.localizedDescription)"
            self.isLoading = false
        }
    }

    // MARK: - 评分提交

    /// 提交评分并移到下一张卡片
    func submitRating(_ rating: SM2Scheduler.Rating, modelContext: ModelContext) {
        guard let item = currentCard, !isCompleted else { return }

        let elapsedMs = questionShownTime.map {
            Int(Date().timeIntervalSince($0) * 1000)
        } ?? 0

        let settings = loadSettingsSync(modelContext: modelContext)

        // 获取或创建 ReviewState
        let state: ReviewState
        if let existingState = item.reviewState {
            state = existingState
        } else {
            state = ReviewState()
            state.card = item.card
            item.card.reviewState = state
            modelContext.insert(state)
        }

        // SM-2 调度
        let result = SM2Scheduler.schedule(
            ef: state.difficultyFactor,
            interval: Int(state.stability),
            repetitions: state.reps,
            rating: rating,
            interviewMode: settings?.interviewModeEnabled ?? false,
            cardPriority: item.card.difficulty
        )

        state.difficultyFactor = result.difficultyFactor
        state.stability = Double(result.interval)
        state.reps = result.repetitions
        state.due = result.due
        state.lastReview = Date()
        state.nextReview = result.due

        if rating == .again {
            state.lapses += 1
        }

        // 追加复习日志
        let log = ReviewLogEntry(date: Date(), rating: rating.rawValue, elapsedMs: elapsedMs)
        state.reviewLogs.append(log)

        // 更新统计
        reviewedCount += 1
        switch rating {
        case .again: againCount += 1
        case .hard: hardCount += 1
        case .good: goodCount += 1
        }

        if let start = sessionStart {
            elapsedTime = Date().timeIntervalSince(start)
        }

        // 移到下一张
        currentIndex += 1
        if currentIndex >= queue.count {
            isCompleted = true
            saveReviewSession(modelContext: modelContext)
        }
    }

    /// 重置状态
    func reset() {
        queue = []
        currentIndex = 0
        isCompleted = false
        againCount = 0
        hardCount = 0
        goodCount = 0
        reviewedCount = 0
        elapsedTime = 0
        sessionStart = nil
        questionShownTime = nil
    }

    // MARK: - 私有

    private func loadOrCreateSettings(modelContext: ModelContext) async -> UserSettings {
        let descriptor = FetchDescriptor<UserSettings>()
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }
        let settings = UserSettings()
        modelContext.insert(settings)
        try? modelContext.save()
        return settings
    }

    private func loadSettingsSync(modelContext: ModelContext) -> UserSettings? {
        let descriptor = FetchDescriptor<UserSettings>()
        return try? modelContext.fetch(descriptor).first
    }

    private func saveReviewSession(modelContext: ModelContext) {
        let session = ReviewSession(
            startedAt: sessionStart ?? Date(),
            endedAt: Date(),
            cardsReviewed: reviewedCount,
            date: Date(),
            againCount: againCount,
            hardCount: hardCount,
            goodCount: goodCount
        )
        modelContext.insert(session)
        try? modelContext.save()
    }
}
