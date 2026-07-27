/// MemFlow 复习日志条目
///
/// 内嵌于 ReviewState 的复习历史记录。
/// 每次用户对卡片评分后追加一条记录。

import 'package:isar/isar.dart';

part 'review_log_entry.g.dart';

@embedded
class ReviewLogEntry {
  /// 评分时间
  DateTime date = DateTime.now();

  /// 评分: 0=生疏(Again), 1=犹豫(Hard), 2=顺畅(Good)
  int rating = 0;

  /// 从显示问题到评分的耗时（毫秒）
  int elapsedMs = 0;

  ReviewLogEntry({
    this.rating = 0,
    this.elapsedMs = 0,
  });
}
