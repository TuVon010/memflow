import Foundation
import SwiftData

/// MemFlow 卡片数据模型
///
/// 卡片是复习的基本单元，支持 Markdown 内容和多种类型。
/// 通过 cardType 区分：basic(一问一答)、cloz(填空)、comparison(对比)、code(代码)。
@Model
final class Card {
    /// 所属卡组
    @Relationship(inverse: \Deck.cards)
    var deck: Deck?

    /// 问题内容，支持 Markdown
    var question: String

    /// 答案内容，支持 Markdown
    var answer: String

    /// 卡片类型: basic, cloz, comparison, code
    var cardType: String

    /// 原始来源 URL（可选）
    var sourceUrl: String

    /// 卡片难度，由 AI 或用户标记 (0.0~1.0)
    var difficulty: Double

    /// 卡片级标签，逗号分隔
    var tagsString: String

    /// 创建时间
    var createdAt: Date

    /// 最后修改时间
    var updatedAt: Date

    /// 一对一关联：复习状态（级联删除）
    @Relationship(deleteRule: .cascade, inverse: \ReviewState.card)
    var reviewState: ReviewState?

    /// 计算属性：标签数组
    var tags: [String] {
        get { tagsString.isEmpty ? [] : tagsString.components(separatedBy: ",") }
        set { tagsString = newValue.joined(separator: ",") }
    }

    /// 是否为从未学习过的新卡片
    var isNewCard: Bool {
        reviewState == nil || reviewState?.reps == 0
    }

    init(
        question: String = "",
        answer: String = "",
        cardType: String = "basic",
        sourceUrl: String = "",
        difficulty: Double = 0.5,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        tags: [String] = []
    ) {
        self.question = question
        self.answer = answer
        self.cardType = cardType
        self.sourceUrl = sourceUrl
        self.difficulty = difficulty
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tagsString = tags.joined(separator: ",")
    }
}
