import Foundation
import SwiftUI
import SwiftData
import Observation

/// 统计数据 ViewModel
@MainActor
@Observable
final class StatsViewModel {
    private(set) var todayReviewCount: Int = 0
    private(set) var streakDays: Int = 0
    private(set) var retentionRate: Double = 0
    private(set) var dailyReviewData: [(date: String, count: Int)] = []
    private(set) var deckSummaries: [(deck: Deck, cardCount: Int, dueCount: Int)] = []

    /// 加载全部统计数据
    func loadStats(modelContext: ModelContext) {
        let now = Date()
        let startOfToday = Calendar.current.startOfDay(for: now)

        // 今日复习量
        let todayDescriptor = FetchDescriptor<ReviewLogEntry>(
            predicate: #Predicate { $0.date >= startOfToday }
        )
        todayReviewCount = (try? modelContext.fetch(todayDescriptor).count) ?? 0

        // 连续打卡天数
        streakDays = calculateStreak(modelContext: modelContext)

        // 记忆留存率（近30天）
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: now) ?? now
        let recentLogsDescriptor = FetchDescriptor<ReviewLogEntry>(
            predicate: #Predicate { $0.date >= thirtyDaysAgo }
        )
        if let recentLogs = try? modelContext.fetch(recentLogsDescriptor), !recentLogs.isEmpty {
            let remembered = recentLogs.filter { $0.rating >= 1 }.count
            retentionRate = Double(remembered) / Double(recentLogs.count)
        }

        // 过去 30 天每日复习量
        dailyReviewData = calculateDailyReviewCounts(days: 30, modelContext: modelContext)

        // 卡组概览
        let deckDescriptor = FetchDescriptor<Deck>(
            predicate: #Predicate { !$0.isArchived }
        )
        if let decks = try? modelContext.fetch(deckDescriptor) {
            deckSummaries = decks.map { deck in
                let dueCount = deck.cards.filter { card in
                    if let state = card.reviewState {
                        return state.due <= now || state.reps == 0
                    }
                    return true
                }.count
                return (deck, deck.cardCount, dueCount)
            }
        }
    }

    // MARK: - 私有计算方法

    private func calculateStreak(modelContext: ModelContext) -> Int {
        let calendar = Calendar.current
        let now = Date()
        var streak = 0

        for dayOffset in 0..<365 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) ?? now
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date

            let descriptor = FetchDescriptor<ReviewLogEntry>(
                predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay }
            )

            if let count = try? modelContext.fetch(descriptor).count, count > 0 {
                streak += 1
            } else {
                break
            }
        }

        return streak
    }

    private func calculateDailyReviewCounts(days: Int, modelContext: ModelContext) -> [(String, Int)] {
        let calendar = Calendar.current
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        var result: [(String, Int)] = []

        for dayOffset in 0..<days {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) ?? now
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
            let key = formatter.string(from: date)

            let descriptor = FetchDescriptor<ReviewLogEntry>(
                predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay }
            )
            let count = (try? modelContext.fetch(descriptor).count) ?? 0

            result.append((key, count))
        }

        return result
    }
}
