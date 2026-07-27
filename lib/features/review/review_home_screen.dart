/// MemFlow 复习首页 — 行动导向
///
/// 设计理念：这是用户每天打开 App 的第一眼，核心任务是"去复习"。
/// 因此页面聚焦一个动作：开始复习按钮。
/// 辅助信息（打卡、待复习数）只是辅助情绪锚点，不喧宾夺主。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../core/theme.dart';
import 'review_screen.dart';
import 'card_picker_screen.dart';

class ReviewHomeScreen extends ConsumerStatefulWidget {
  const ReviewHomeScreen({super.key});

  @override
  ConsumerState<ReviewHomeScreen> createState() => _ReviewHomeScreenState();
}

class _ReviewHomeScreenState extends ConsumerState<ReviewHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider);
    final queueState = ref.watch(reviewQueueProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('MemFlow')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(statsProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            // ── 打卡行（紧凑，一行） ──
            _StreakRow(stats: stats),
            const SizedBox(height: 24),

            // ── 核心数字 + 按钮 ──
            _HeroSection(queueState: queueState),
            const SizedBox(height: 20),

            // ── 面试横幅 ──
            const _InterviewBanner(),
            const SizedBox(height: 32),

            // ── 开始复习（CTA） ──
            _CTAButton(queueState: queueState),
            const SizedBox(height: 36),

            // ── 周概览（微缩版，仅4个小格） ──
            _WeekPreview(stats: stats),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────
// 顶部打卡行 — 一行搞定，不占地
// ───────────────────────────────────────────────────────

class _StreakRow extends StatelessWidget {
  final AsyncValue<LearningStats> stats;
  const _StreakRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return stats.when(
      data: (s) => Row(
        children: [
          Text('🔥 连续 ${s.streakDays} 天', style: AppText.callout.copyWith(color: AppColors.textPrimary)),
          const Spacer(),
          Text('留存 ${(s.retentionRate * 100).toInt()}%',
              style: AppText.footnote.copyWith(color: AppColors.textSecondary)),
        ],
      ),
      loading: () => const SizedBox(height: 22),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ───────────────────────────────────────────────────────
// 核心区 — 大号数字 + 进度条
// ───────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final ReviewQueueState queueState;
  const _HeroSection({required this.queueState});

  @override
  Widget build(BuildContext context) {
    final newCount = queueState.queue.where((i) => i.isNewCard).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 主数字 — 今日待复习
        Text('${queueState.totalCards}',
            style: AppText.largeTitle.copyWith(
                color: AppColors.primary, fontSize: 56, height: 1)),
        const SizedBox(height: 4),
        Text('今日待复习 · $newCount 张新卡',
            style: AppText.callout.copyWith(color: AppColors.textSecondary)),

        if (queueState.totalCards > 0) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: queueState.progress,
              minHeight: 4,
              backgroundColor: const Color(0xFFE5E5EA),
            ),
          ),
        ],
      ],
    );
  }
}

// ───────────────────────────────────────────────────────
// 面试倒计时横幅
// ───────────────────────────────────────────────────────

class _InterviewBanner extends ConsumerWidget {
  const _InterviewBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sAsync = ref.watch(settingsProvider);
    return sAsync.when(
      data: (s) {
        if (!s.interviewModeEnabled || s.interviewDate == null) return const SizedBox.shrink();
        final days = s.interviewDate!.difference(DateTime.now()).inDays;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primaryBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
              const SizedBox(width: 10),
              Text('距离面试还有 $days 天',
                  style: AppText.callout.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ───────────────────────────────────────────────────────
// 开始复习按钮 — 全宽药丸，视觉焦点
// ───────────────────────────────────────────────────────

class _CTAButton extends StatelessWidget {
  final ReviewQueueState queueState;
  const _CTAButton({required this.queueState});

  @override
  Widget build(BuildContext context) {
    final hasCards = queueState.totalCards > 0;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 58,
          child: FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CardReviewScreen()),
            ),
            icon: Icon(hasCards ? Icons.play_arrow_rounded : Icons.refresh_rounded, size: 26),
            label: Text(hasCards ? '开始复习 (${queueState.totalCards})' : '自由复习'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CardPickerScreen()),
            ),
            icon: const Icon(Icons.checklist, size: 20),
            label: const Text('选择卡片复习'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeekPreview extends StatelessWidget {
  final AsyncValue<LearningStats> stats;
  const _WeekPreview({required this.stats});

  @override
  Widget build(BuildContext context) {
    return stats.when(
      data: (s) {
        final entries = s.dailyReviewCounts.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        final last4 = entries.length > 4 ? entries.sublist(entries.length - 4) : entries;
        final maxV = last4.map((e) => e.value).fold(0, (a, b) => a > b ? a : b);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('最近学习', style: AppText.subhead.copyWith(color: AppColors.textSecondary)),
                const Spacer(),
                Text('查看统计 →', style: AppText.footnote.copyWith(color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: last4.map((e) {
                final isLast = e.key == last4.last.key;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        Text('${e.value}',
                            style: AppText.headline.copyWith(
                                color: isLast ? AppColors.primary : AppColors.textPrimary)),
                        const SizedBox(height: 6),
                        Container(
                          height: maxV > 0 ? (e.value / maxV * 36).clamp(4, 36) : 0,
                          decoration: BoxDecoration(
                            color: isLast ? AppColors.primary : AppColors.primary.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(e.key.substring(5),
                            style: AppText.caption.copyWith(
                                color: isLast ? AppColors.primary : AppColors.textTertiary)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
