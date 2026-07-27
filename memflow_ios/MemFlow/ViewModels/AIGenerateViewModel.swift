import Foundation
import SwiftUI
import SwiftData
import Observation

/// AI 生成状态
enum AIGenerateStatus {
    case idle
    case loading
    case success
    case error(String)
}

/// AI 制卡 ViewModel
@MainActor
@Observable
final class AIGenerateViewModel {
    var status: AIGenerateStatus = .idle
    var inputText: String = ""
    var previewCards: [CardPreview] = []

    var errorMessage: String? {
        if case .error(let msg) = status { return msg }
        return nil
    }

    var isLoading: Bool {
        if case .loading = status { return true }
        return false
    }

    private var aiService: AIService?

    /// 初始化 AI 服务（需要 API Key）
    func configure(apiKey: String?, baseURL: String, model: String) {
        guard let key = apiKey, !key.isEmpty else {
            status = .error("请先在设置中配置 AI API Key")
            return
        }
        aiService = AIService(apiKey: key, baseURL: baseURL, model: model)
    }

    /// 调用 AI 生成卡片
    func generate() async {
        guard let service = aiService else {
            status = .error("AI 服务未配置")
            return
        }

        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            status = .error("请输入要生成卡片的文本")
            return
        }

        status = .loading
        do {
            let cards = try await service.generateCards(from: inputText)
            previewCards = cards
            status = .success
        } catch let error as AIServiceError {
            status = .error(error.localizedDescription)
        } catch {
            status = .error("生成失败: \(error.localizedDescription)")
        }
    }

    /// 删除预览卡片
    func removePreviewCard(at index: Int) {
        guard index < previewCards.count else { return }
        previewCards.remove(at: index)
    }

    /// 保存所有预览卡片到指定卡组
    func saveAllToDeck(deckId: PersistentIdentifier, modelContext: ModelContext) {
        guard let deck = modelContext.model(for: deckId) as? Deck else { return }

        for preview in previewCards {
            let card = Card(
                question: preview.question,
                answer: preview.answer,
                cardType: preview.cardType,
                tags: preview.tags
            )
            card.deck = deck
            modelContext.insert(card)
        }

        try? modelContext.save()
        reset()
    }

    /// 重置状态
    func reset() {
        status = .idle
        inputText = ""
        previewCards = []
    }
}
