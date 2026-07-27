/// MemFlow 复习调度引擎
///
/// 实现 SM-2 改良算法，用于计算卡片的复习间隔。

import 'dart:math';

/// 用户评分枚举
enum Rating {
  /// 生疏 (Again) — 完全遗忘，内部质量分 q=0
  again(0, '生疏'),

  /// 犹豫 (Hard) — 回忆困难，内部质量分 q=3
  hard(1, '犹豫'),

  /// 顺畅 (Good) — 轻松回忆，内部质量分 q=5
  good(2, '顺畅');

  final int ratingIndex;
  final String label;
  const Rating(this.ratingIndex, this.label);

  /// 内部质量分（SM-2 算法使用）
  int get quality {
    switch (this) {
      case Rating.again: return 0;
      case Rating.hard: return 3;
      case Rating.good: return 5;
    }
  }
}

/// 调度结果
class ScheduleResult {
  final double difficultyFactor;
  final int interval;
  final DateTime due;
  final int repetitions;

  ScheduleResult({
    required this.difficultyFactor,
    required this.interval,
    required this.due,
    required this.repetitions,
  });
}

/// 调度算法抽象接口
abstract class Scheduler {
  ScheduleResult schedule({
    required double ef,
    required int interval,
    required int repetitions,
    required Rating rating,
    bool interviewMode = false,
    double cardPriority = 0.0,
  });
}

/// SM-2 改良算法实现
class SM2Scheduler implements Scheduler {
  static const double minEF = 1.3;
  static const double interviewIntervalRatio = 0.8;
  static const double interviewPriorityThreshold = 0.8;

  @override
  ScheduleResult schedule({
    required double ef,
    required int interval,
    required int repetitions,
    required Rating rating,
    bool interviewMode = false,
    double cardPriority = 0.0,
  }) {
    final q = rating.quality;

    double newEF;
    int newRepetitions;

    if (q >= 3) {
      newEF = ef + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
      newRepetitions = repetitions + 1;
    } else {
      newEF = ef - 0.2;
      newRepetitions = 0;
    }

    newEF = max(newEF, minEF);

    int newInterval;
    if (q == 0) {
      newInterval = 1;
    } else if (newRepetitions == 1) {
      newInterval = 1;
    } else if (newRepetitions == 2) {
      newInterval = 6;
    } else {
      newInterval = max((interval * newEF).round(), 1);
    }

    if (interviewMode && cardPriority >= interviewPriorityThreshold) {
      newInterval = max(1, (newInterval * interviewIntervalRatio).floor());
    }

    final due = DateTime.now().add(Duration(days: newInterval));

    return ScheduleResult(
      difficultyFactor: newEF,
      interval: newInterval,
      due: due,
      repetitions: newRepetitions,
    );
  }
}
