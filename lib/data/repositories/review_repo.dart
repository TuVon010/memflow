/// MemFlow 复习仓库

import 'package:isar/isar.dart';
import '../isar_service.dart';
import '../models/review_state.dart';
import '../models/review_log_entry.dart';

class ReviewRepo {
  final IsarService _isarService;
  Isar get _isar => _isarService.isar;

  ReviewRepo(this._isarService);

  /// 获取所有到期的复习状态
  Future<List<ReviewState>> getDueStates({int? limit}) async {
    final now = DateTime.now();
    var query = _isar.reviewStates
        .filter()
        .dueLessThan(now)
        .and()
        .repsGreaterThan(0)
        .sortByDue();

    if (limit != null) {
      return await query.limit(limit).findAll();
    }
    return await query.findAll();
  }

  /// 获取到期卡片 ID 列表
  Future<List<int>> getDueCardIds({int? limit}) async {
    final states = await getDueStates(limit: limit);
    return states.map((s) => s.cardId).toList();
  }

  /// 根据卡片 ID 获取复习状态
  Future<ReviewState?> getByCardId(int cardId) async {
    return await _isar.reviewStates
        .filter()
        .cardIdEqualTo(cardId)
        .findFirst();
  }

  /// 更新复习状态（评分后调用）
  Future<void> updateAfterReview(
    ReviewState state, {
    required int rating,
    required int elapsedMs,
  }) async {
    await _isar.writeTxn(() async {
      final logEntry = ReviewLogEntry(
        rating: rating,
        elapsedMs: elapsedMs,
      );
      // Isar 内嵌对象列表是不可变的，需要 copy 一份再赋值
      state.reviewLog = [...state.reviewLog, logEntry];

      state.lastReview = DateTime.now();
      state.nextReview = state.due;
      await _isar.reviewStates.put(state);
    });
  }

  /// 统计今日已复习的卡片数
  Future<int> getTodayReviewedCount() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    return await _isar.reviewStates
        .filter()
        .lastReviewGreaterThan(startOfDay, include: true)
        .count();
  }

  /// 统计指定日期的复习卡片数
  Future<int> getReviewedCountByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await _isar.reviewStates
        .filter()
        .lastReviewBetween(startOfDay, endOfDay)
        .count();
  }

  /// 获取过去 N 天的每日复习量
  Future<Map<String, int>> getDailyReviewCounts(int days) async {
    final result = <String, int>{};
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      result[dateKey] = await getReviewedCountByDate(date);
    }

    return result;
  }

  /// 计算记忆留存率
  Future<double> getEstimatedRetention() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    final states = await _isar.reviewStates
        .filter()
        .lastReviewGreaterThan(thirtyDaysAgo, include: true)
        .findAll();

    if (states.isEmpty) return 0.0;

    int totalRatings = 0;
    int goodRatings = 0;

    for (final state in states) {
      for (final log in state.reviewLog) {
        if (!log.date.isBefore(thirtyDaysAgo)) {
          totalRatings++;
          if (log.rating >= 1) {
            goodRatings++;
          }
        }
      }
    }

    if (totalRatings == 0) return 0.0;
    return goodRatings / totalRatings;
  }

  /// 获取连续打卡天数
  Future<int> getStreakDays() async {
    int streak = 0;
    final now = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final count = await getReviewedCountByDate(date);
      if (count > 0) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}
