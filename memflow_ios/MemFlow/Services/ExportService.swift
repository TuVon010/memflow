import Foundation

/// MemFlow 导出/导入服务
///
/// 支持将卡组及其卡片序列化为 .mfcard.json 格式文件，
/// 以及从 JSON 文件导入卡组（深度复制，复习状态不导入）。

// MARK: - 导出数据模型

struct ExportData: Codable {
    let version: String
    let exportedAt: String
    let decks: [ExportDeck]

    init(version: String = "1.0", exportedAt: Date = Date(), decks: [ExportDeck] = []) {
        self.version = version
        let formatter = ISO8601DateFormatter()
        self.exportedAt = formatter.string(from: exportedAt)
        self.decks = decks
    }
}

struct ExportDeck: Codable {
    let name: String
    let description: String
    let color: Int
    let cards: [ExportCard]
}

struct ExportCard: Codable {
    let question: String
    let answer: String
    let cardType: String
    let difficulty: Double
    let tags: [String]
}

struct ImportResult {
    let decksImported: Int
    let cardsImported: Int
    let warnings: [String]
}

// MARK: - 导出服务

struct ExportService {
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    /// 将卡组列表导出为 .mfcard.json 格式 Data
    func exportToData(decks: [Deck]) throws -> Data {
        let exportDecks = decks.map { deck in
            ExportDeck(
                name: deck.name,
                description: deck.deckDescription,
                color: deck.color,
                cards: deck.cards.map { card in
                    ExportCard(
                        question: card.question,
                        answer: card.answer,
                        cardType: card.cardType,
                        difficulty: card.difficulty,
                        tags: card.tags
                    )
                }
            )
        }

        let exportData = ExportData(decks: exportDecks)
        return try encoder.encode(exportData)
    }

    /// 将单个卡组导出为 .mfcard.json 格式 Data
    func exportSingleDeck(_ deck: Deck) throws -> Data {
        try exportToData(decks: [deck])
    }

    /// 将卡组列表导出为 JSON 字符串
    func exportToString(decks: [Deck]) throws -> String {
        let data = try exportToData(decks: decks)
        return String(data: data, encoding: .utf8) ?? ""
    }
}

// MARK: - 导入服务

struct ImportService {
    private let decoder = JSONDecoder()

    /// 解析 JSON Data 为导出数据
    func parseJSON(_ data: Data) throws -> ExportData {
        try decoder.decode(ExportData.self, from: data)
    }

    /// 验证导入数据的版本兼容性
    func isVersionCompatible(_ version: String) -> Bool {
        version.hasPrefix("1.")
    }

    /// 从导出数据创建 Deck 对象列表（不插入数据库）
    func createDecks(from exportData: ExportData) -> [Deck] {
        exportData.decks.map { exportDeck in
            let deck = Deck(
                name: exportDeck.name,
                deckDescription: exportDeck.description,
                color: exportDeck.color
            )

            deck.cards = exportDeck.cards.map { exportCard in
                Card(
                    question: exportCard.question,
                    answer: exportCard.answer,
                    cardType: exportCard.cardType,
                    difficulty: exportCard.difficulty,
                    tags: exportCard.tags
                )
            }

            return deck
        }
    }
}
