/// MemFlow 学习统计 — 回顾与反思
///
/// 与复习首页不同：统计页聚焦"回头看"而非"往前做"。
/// 信息层级：打卡天数 → 留存率环形 → 30天趋势 → 卡组占比
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../core/theme.dart';
import '../../data/models/deck.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final decks = ref.watch(deckListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('统计')),
      body: stats.when(
        data: (s) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _TopCards(s: s),
            const SizedBox(height: 16),
            _ThirtyDayChart(dailyData: s.dailyReviewCounts),
            const SizedBox(height: 16),
            decks.whenOrNull(data: (dl) => _DeckBreakdown(decks: dl)) ?? const SizedBox.shrink(),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────
// 顶部双卡片 — 打卡 + 留存率
// ───────────────────────────────────────────────────────

class _TopCards extends StatelessWidget {
  final LearningStats s;
  const _TopCards({required this.s});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 打卡天数
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text('${s.streakDays} 天',
                      style: AppText.title2.copyWith(color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('连续打卡', style: AppText.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 今日复习
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.auto_stories, size: 28, color: AppColors.primary),
                  const SizedBox(height: 8),
                  Text('${s.todayReviewCount} 张',
                      style: AppText.title2.copyWith(color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('今日已复习', style: AppText.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────
// 30天趋势 — 整月数据
// ───────────────────────────────────────────────────────

class _ThirtyDayChart extends StatelessWidget {
  final Map<String, int> dailyData;
  const _ThirtyDayChart({required this.dailyData});

  @override
  Widget build(BuildContext context) {
    final entries = dailyData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final total = entries.fold<int>(0, (s, e) => s + e.value);
    final maxV = entries.map((e) => e.value).fold(0, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('30天趋势', style: AppText.subhead.copyWith(color: AppColors.textSecondary)),
                const Spacer(),
                Text('$total 张', style: AppText.footnote.copyWith(color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 90,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: entries.map((e) {
                  final h = maxV > 0 ? (e.value / maxV * 64).clamp(2.0, 64.0) : 0.0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Container(
                        height: h,
                        decoration: BoxDecoration(
                          color: h > 30 ? AppColors.primary : AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entries.first.key, style: AppText.caption.copyWith(color: AppColors.textTertiary)),
                Text(entries[entries.length ~/ 2].key,
                    style: AppText.caption.copyWith(color: AppColors.textTertiary)),
                Text(entries.last.key, style: AppText.caption.copyWith(color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────
// 卡组占比 — 环形比例可视化
// ───────────────────────────────────────────────────────

class _DeckBreakdown extends StatelessWidget {
  final List<Deck> decks;
  const _DeckBreakdown({required this.decks});

  @override
  Widget build(BuildContext context) {
    if (decks.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('卡组分布', style: AppText.subhead.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ...decks.map((d) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(
                          color: Color(d.color), borderRadius: BorderRadius.circular(4)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(d.name,
                            style: AppText.callout.copyWith(color: AppColors.textPrimary)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
