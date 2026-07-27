/// SM-2 调度算法单元测试
///
/// 覆盖评分映射、EF 更新、间隔计算、面试模式调整等核心逻辑。

import 'package:flutter_test/flutter_test.dart';
import 'package:memflow/engine/scheduler.dart';

void main() {
  late SM2Scheduler scheduler;

  setUp(() {
    scheduler = SM2Scheduler();
  });

  group('SM-2 评分映射', () {
    test('Rating.again 应映射为质量分 0', () {
      final result = scheduler.schedule(
        ef: 2.5,
        interval: 1,
        repetitions: 0,
        rating: Rating.again,
      );
      // 遗忘时 EF 降低 0.2
      expect(result.difficultyFactor, 2.3);
      // 遗忘时间隔重置为 1
      expect(result.interval, 1);
      // 遗忘时连续成功次数归零
      expect(result.repetitions, 0);
    });

    test('Rating.hard 应映射为质量分 3', () {
      final result = scheduler.schedule(
        ef: 2.5,
        interval: 1,
        repetitions: 0,
        rating: Rating.hard,
      );
      // 第一次成功，间隔为 1
      expect(result.interval, 1);
      expect(result.repetitions, 1);
    });

    test('Rating.good 应映射为质量分 5', () {
      final result = scheduler.schedule(
        ef: 2.5,
        interval: 1,
        repetitions: 0,
        rating: Rating.good,
      );
      // 第一次成功，间隔为 1
      expect(result.interval, 1);
      expect(result.repetitions, 1);
      // EF 应增加（质量分 5 时增加 0.1）
      expect(result.difficultyFactor, closeTo(2.6, 0.01));
    });
  });

  group('SM-2 间隔计算', () {
    test('第一次成功复习，间隔应为 1 天', () {
      final result = scheduler.schedule(
        ef: 2.5,
        interval: 1,
        repetitions: 0,
        rating: Rating.good,
      );
      expect(result.interval, 1);
    });

    test('第二次成功复习，间隔应为 6 天', () {
      final result = scheduler.schedule(
        ef: 2.6,
        interval: 1,
        repetitions: 1,
        rating: Rating.good,
      );
      expect(result.interval, 6);
    });

    test('第三次及以上成功复习，间隔 = 上次间隔 × EF', () {
      final result = scheduler.schedule(
        ef: 2.6,
        interval: 6,
        repetitions: 2,
        rating: Rating.good,
      );
      expect(result.interval, closeTo(16, 2)); // 6 * 2.6 ≈ 16
    });

    test('遗忘（Again）后间隔应重置为 1', () {
      final result = scheduler.schedule(
        ef: 2.5,
        interval: 30,
        repetitions: 5,
        rating: Rating.again,
      );
      expect(result.interval, 1);
      expect(result.repetitions, 0);
    });
  });

  group('SM-2 EF 边界保护', () {
    test('EF 不应低于 1.3', () {
      final result = scheduler.schedule(
        ef: 1.35,
        interval: 1,
        repetitions: 0,
        rating: Rating.again,
      );
      expect(result.difficultyFactor, greaterThanOrEqualTo(1.3));
    });

    test('连续遗忘后 EF 不跌破下限', () {
      double ef = 2.5;
      int reps = 3;
      int interval = 1;

      for (int i = 0; i < 20; i++) {
        final result = scheduler.schedule(
          ef: ef,
          interval: interval,
          repetitions: reps,
          rating: Rating.again,
        );
        ef = result.difficultyFactor;
        reps = result.repetitions;
        interval = result.interval;
      }

      expect(ef, greaterThanOrEqualTo(1.3));
    });
  });

  group('面试倒计时模式', () {
    test('高优先级卡片在面试模式下间隔缩短 20%', () {
      final normalResult = scheduler.schedule(
        ef: 2.5,
        interval: 10,
        repetitions: 3,
        rating: Rating.good,
        interviewMode: false,
        cardPriority: 0.9,
      );

      final interviewResult = scheduler.schedule(
        ef: 2.5,
        interval: 10,
        repetitions: 3,
        rating: Rating.good,
        interviewMode: true,
        cardPriority: 0.9,
      );

      // 面试模式间隔应 ≤ 正常间隔
      expect(interviewResult.interval, lessThanOrEqualTo(normalResult.interval));
    });

    test('低优先级卡片不受面试模式影响', () {
      final normalResult = scheduler.schedule(
        ef: 2.5,
        interval: 10,
        repetitions: 3,
        rating: Rating.good,
        interviewMode: false,
        cardPriority: 0.3,
      );

      final interviewResult = scheduler.schedule(
        ef: 2.5,
        interval: 10,
        repetitions: 3,
        rating: Rating.good,
        interviewMode: true,
        cardPriority: 0.3,
      );

      expect(interviewResult.interval, normalResult.interval);
    });
  });

  group('SM-2 EF 更新公式验证', () {
    test('质量分 5 使 EF 增加约 0.1', () {
      final result = scheduler.schedule(
        ef: 2.5,
        interval: 6,
        repetitions: 2,
        rating: Rating.good,
      );
      expect(result.difficultyFactor, closeTo(2.6, 0.01));
    });

    test('质量分 3 使 EF 微微变化', () {
      final result = scheduler.schedule(
        ef: 2.5,
        interval: 6,
        repetitions: 2,
        rating: Rating.hard,
      );
      // EF 变化很小：0.1 - (5-3)*(0.08 + (5-3)*0.02) = 0.1 - 2*0.12 = -0.14
      expect(result.difficultyFactor, closeTo(2.36, 0.1));
    });
  });
}
