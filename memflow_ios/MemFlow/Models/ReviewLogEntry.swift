import Foundation
import SwiftData

/// MemFlow 复习日志条目
///
/// 关联于 ReviewState，每次用户对卡片评分后追加一条记录。
/// rating: 0=生疏(Again), 1=犹豫(Hard), 2=顺畅(Good)
@Model
final class ReviewLogEntry {
    /// 评分时间
    var date: Date

    /// 评分: 0=生疏(Again), 1=犹豫(Hard), 2=顺畅(Good)
    var rating: Int

    /// 从显示问题到评分的耗时（毫秒）
    var elapsedMs: Int

    /// 所属复习状态
    @Relationship(inverse: \ReviewState.reviewLogs)
    var reviewState: ReviewState?

    /// 评分对应的质量分（SM-2 算法使用）
    var quality: Int {
        switch rating {
        case 0: return 0   // Again → q=0
        case 1: return 3   // Hard → q=3
        case 2: return 5   // Good → q=5
        default: return 5
        }
    }

    /// 评分的文本标签
    var ratingLabel: String {
        switch rating {
        case 0: return "生疏"
        case 1: return "犹豫"
        case 2: return "顺畅"
        default: return "未知"
        }
    }

    init(
        date: Date = Date(),
        rating: Int = 0,
        elapsedMs: Int = 0
    ) {
        self.date = date
        self.rating = rating
        self.elapsedMs = elapsedMs
    }
}
