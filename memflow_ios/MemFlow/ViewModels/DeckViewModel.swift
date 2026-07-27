import Foundation
import SwiftUI
import SwiftData
import Observation

/// 卡组管理 ViewModel
@MainActor
@Observable
final class DeckViewModel {
    private(set) var decks: [Deck] = []
    private(set) var isLoading: Bool = false

    /// 加载所有卡组
    func loadDecks(modelContext: ModelContext, includeArchived: Bool = false) {
        isLoading = true
        var descriptor = FetchDescriptor<Deck>(sortBy: [SortDescriptor(\.createdAt)])
        if !includeArchived {
            descriptor.predicate = #Predicate { !$0.isArchived }
        }

        do {
            decks = try modelContext.fetch(descriptor)
        } catch {
            print("加载卡组失败: \(error)")
        }
        isLoading = false
    }

    /// 创建卡组
    func createDeck(name: String, description: String = "", modelContext: ModelContext) {
        let deck = Deck(name: name, deckDescription: description)
        modelContext.insert(deck)
        try? modelContext.save()
        loadDecks(modelContext: modelContext)
    }

    /// 删除卡组（级联删除由 SwiftData cascade 规则处理）
    func deleteDeck(_ deck: Deck, modelContext: ModelContext) {
        modelContext.delete(deck)
        try? modelContext.save()
        loadDecks(modelContext: modelContext)
    }

    /// 切换归档状态
    func toggleArchive(_ deck: Deck, modelContext: ModelContext) {
        deck.isArchived.toggle()
        deck.updatedAt = Date()
        try? modelContext.save()
        loadDecks(modelContext: modelContext)
    }

    /// 更新优先级
    func updatePriority(_ deck: Deck, priority: Double, modelContext: ModelContext) {
        deck.priority = min(max(priority, 0), 1)
        deck.updatedAt = Date()
        try? modelContext.save()
    }
}
