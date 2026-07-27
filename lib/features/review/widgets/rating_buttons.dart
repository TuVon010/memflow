/// MemFlow 评分按钮 — 三个等宽药丸按钮
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../engine/scheduler.dart';

class RatingButtons extends StatelessWidget {
  final void Function(Rating) onRated;
  const RatingButtons({super.key, required this.onRated});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(child: _Btn(emoji: '🙈', label: '生疏', fg: AppColors.again, bg: AppColors.againBg, onTap: () => onRated(Rating.again))),
            const SizedBox(width: 10),
            Expanded(child: _Btn(emoji: '🤔', label: '犹豫', fg: AppColors.hard, bg: AppColors.hardBg, onTap: () => onRated(Rating.hard))),
            const SizedBox(width: 10),
            Expanded(child: _Btn(emoji: '✨', label: '顺畅', fg: AppColors.good, bg: AppColors.goodBg, onTap: () => onRated(Rating.good))),
          ],
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String emoji, label;
  final Color fg, bg;
  final VoidCallback onTap;

  const _Btn({required this.emoji, required this.label, required this.fg, required this.bg, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: fg.withValues(alpha: 0.15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(label, style: AppText.subhead.copyWith(color: fg, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
