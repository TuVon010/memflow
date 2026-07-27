import Foundation
import SwiftData

/// MemFlow 卡组数据模型
///
/// 卡组是卡片的容器，支持归档和优先级标记。
/// 删除卡组时通过 cascade 规则级联删除其下所有卡片及复习状态。
@Model
final class Deck {
    /// 卡组名称
    @Attribute(.unique) var name: String

    /// 卡组描述（可选）
    var deckDescription: String

    /// 主题色，存储为 RGB 整数值（默认蓝色 0x4A90D9）
    var color: Int

    /// 创建时间
    var createdAt: Date

    /// 最后修改时间
    var updatedAt: Date

    /// 是否归档，归档后卡片不参与复习
    var isArchived: Bool

    /// 卡组优先级 (0.0~1.0)，用于面试倒计时排序
    var priority: Double

    /// 全局标签，存储为逗号分隔字符串（SwiftData 不支持直接存 [String]）
    var tagsString: String

    /// 该卡组下的所有卡片（一对多，级联删除）
    @Relationship(deleteRule: .cascade, inverse: \Card.deck)
    var cards: [Card] = []

    /// 计算属性：标签数组
    var tags: [String] {
        get { tagsString.isEmpty ? [] : tagsString.components(separatedBy: ",") }
        set { tagsString = newValue.joined(separator: ",") }
    }

    /// 卡片数量
    var cardCount: Int { cards.count }

    /// 待复习卡片数量（due <= now 且 reps > 0）
    var dueCardCount: Int {
        cards.filter { card in
            if let state = card.reviewState {
                return state.due <= Date() && state.reps > 0
            }
            return true // 新卡片也算待复习
        }.count
    }

    init(
        name: String = "",
        deckDescription: String = "",
        color: Int = 0x4A90D9,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isArchived: Bool = false,
        priority: Double = 0.0,
        tags: [String] = []
    ) {
        self.name = name
        self.deckDescription = deckDescription
        self.color = color
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isArchived = isArchived
        self.priority = priority
        self.tagsString = tags.joined(separator: ",")
    }
}
