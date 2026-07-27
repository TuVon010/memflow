/// MemFlow 复习会话模型
///
/// 用于统计每日学习时长和复习量（P2 功能），记录每次复习会话的基本信息。

import 'package:isar/isar.dart';

part 'review_session.g.dart';

@collection
class ReviewSession {
  /// 自增主键
  Id id = Isar.autoIncrement;

  /// 会话开始时间
  DateTime startedAt = DateTime.now();

  /// 会话结束时间
  DateTime? endedAt;

  /// 本次复习卡片数量
  int cardsReviewed = 0;

  /// 会话日期（用于按日统计）
  @Index()
  DateTime date = DateTime.now();

  ReviewSession({
    this.endedAt,
    this.cardsReviewed = 0,
  });
}
