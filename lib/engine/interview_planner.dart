/// MemFlow 面试倒计时计划器
///
/// 根据用户设定的面试日期、日均可投入时间、卡组优先级，
/// 计算每日建议新卡量和预期完成度。

import 'dart:math';

/// 面试计划结果
class InterviewPlan {
  /// 剩余天数
  final int daysRemaining;

  /// 建议每日新卡数
  final int suggestedDailyNewCards;

  /// 建议每日复习数
  final int suggestedDailyReviews;

  /// 总新卡数量
  final int totalNewCards;

  /// 预计面试前完成百分比 (0.0~1.0)
  final double estimatedCompletionRate;

  /// 高优先级卡片能否在面试前完成 3 轮复习
  final bool highPriorityComplete;

  InterviewPlan({
    required this.daysRemaining,
    required this.suggestedDailyNewCards,
    required this.suggestedDailyReviews,
    required this.totalNewCards,
    required this.estimatedCompletionRate,
    required this.highPriorityComplete,
  });
}

/// 面试计划时长选项
enum InterviewDailyTime {
  thirtyMin(30, '30分钟'),
  oneHour(60, '1小时'),
  twoHours(120, '2小时'),
  custom(0, '自定义');

  final int minutes;
  final String label;
  const InterviewDailyTime(this.minutes, this.label);
}

/// 面试倒计时计划器
class InterviewPlanner {
  /// 每分钟平均可复习卡片数（经验值）
  static const double cardsPerMinute = 2.0;

  /// 高优先级阈值（卡片优先级 >= 此值视为高频题）
  static const double highPriorityThreshold = 0.7;

  /// 计算面试冲刺计划
  ///
  /// [interviewDate] 面试日期
  /// [dailyTime] 每日可投入时间
  /// [totalNewCards] 所有未学习的卡片总数
  /// [totalDueCards] 当前到期待复习卡片数
  /// [highPriorityCardCount] 高优先级卡片数量
  InterviewPlan calculate({
    required DateTime interviewDate,
    required InterviewDailyTime dailyTime,
    required int totalNewCards,
    required int totalDueCards,
    required int highPriorityCardCount,
  }) {
    final now = DateTime.now();
    final daysRemaining = max(0, interviewDate.difference(now).inDays);

    // 每日可复习卡片总数 = 时间 × 每分钟卡片数
    final dailyCapacity = (dailyTime.minutes * cardsPerMinute).round();

    // 如果无剩余天数或日常容量为 0，返回默认计划
    if (daysRemaining <= 0 || dailyCapacity <= 0) {
      return InterviewPlan(
        daysRemaining: daysRemaining,
        suggestedDailyNewCards: 0,
        suggestedDailyReviews: totalDueCards,
        totalNewCards: totalNewCards,
        estimatedCompletionRate: 0.0,
        highPriorityComplete: false,
      );
    }

    // 建议每日新卡数 = 总新卡 / 剩余天数（向上取整）
    final suggestedDailyNewCards = min(
      (totalNewCards / daysRemaining).ceil(),
      dailyCapacity, // 不超过日常容量
    );

    // 建议每日复习数 = 日常容量 - 每日新卡数
    final suggestedDailyReviews = max(0, dailyCapacity - suggestedDailyNewCards);

    // 预计完成率：已安排新卡 vs 总新卡，但受容量限制
    final totalCapacity = dailyCapacity * daysRemaining;
    final estimatedCompletionRate = totalNewCards > 0
        ? min(1.0, totalCapacity / totalNewCards)
        : 1.0;

    // 高优先级卡片能否在面试前完成 3 轮复习（每轮需要 N 天）
    final highPriorityDaysNeeded = highPriorityCardCount > 0
        ? (highPriorityCardCount * 3 / dailyCapacity).ceil()
        : 0;
    final highPriorityComplete = highPriorityDaysNeeded <= daysRemaining;

    return InterviewPlan(
      daysRemaining: daysRemaining,
      suggestedDailyNewCards: suggestedDailyNewCards,
      suggestedDailyReviews: suggestedDailyReviews,
      totalNewCards: totalNewCards,
      estimatedCompletionRate: estimatedCompletionRate,
      highPriorityComplete: highPriorityComplete,
    );
  }
}
