/// MemFlow 复习状态数据模型

import 'package:isar/isar.dart';
import 'review_log_entry.dart';

part 'review_state.g.dart';

@collection
class ReviewState {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late int cardId;

  @Index()
  DateTime due = DateTime.now();
  double stability = 1.0;
  double difficultyFactor = 2.5;
  int reps = 0;
  int lapses = 0;
  DateTime? lastReview;
  DateTime? nextReview;

  /// 复习历史记录（内嵌对象列表）
  List<ReviewLogEntry> reviewLog = [];

  ReviewState({
    this.cardId = 0,
    this.stability = 1.0,
    this.difficultyFactor = 2.5,
    this.reps = 0,
    this.lapses = 0,
    this.lastReview,
    this.nextReview,
  });
}
