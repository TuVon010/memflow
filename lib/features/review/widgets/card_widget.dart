/// MemFlow 复习卡片组件
import 'package:flutter/material.dart' hide Card;
import '../../../core/theme.dart';
import '../../../data/models/card.dart';

class ReviewCardWidget extends StatelessWidget {
  final Card card;
  final bool isAnswerShown;
  final bool isNewCard;

  const ReviewCardWidget({
    super.key,
    required this.card,
    required this.isAnswerShown,
    this.isNewCard = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNewCard
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.04),
          width: isNewCard ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(card: card, isNewCard: isNewCard),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Section(label: '问题', content: card.question, cardType: card.cardType),
                  if (isAnswerShown) ...[
                    const SizedBox(height: 24),
                    Container(height: 1, color: const Color(0xFFE5E5EA)),
                    const SizedBox(height: 20),
                    _Section(label: '答案', content: card.answer, cardType: card.cardType),
                  ],
                ],
              ),
            ),
          ),
          if (!isAnswerShown)
            Container(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text('轻触显示答案', textAlign: TextAlign.center,
                  style: AppText.callout.copyWith(color: AppColors.textTertiary)),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Card card;
  final bool isNewCard;
  const _Header({required this.card, required this.isNewCard});

  @override
  Widget build(BuildContext context) {
    final tags = <Widget>[];
    if (isNewCard) tags.add(_tag('新卡片', AppColors.primaryBg, AppColors.primary));
    for (final t in card.tags) {
      tags.add(_tag(t, const Color(0xFFF2F2F7), AppColors.textSecondary));
    }
    if (tags.isEmpty) return const SizedBox(height: 16);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Wrap(spacing: 8, runSpacing: 6, children: tags),
    );
  }

  Widget _tag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: AppText.caption.copyWith(color: fg, fontWeight: FontWeight.w600)),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final String content;
  final String cardType;

  const _Section({required this.label, required this.content, required this.cardType});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.caption.copyWith(
            color: AppColors.textTertiary, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 14),
        cardType == 'code' ? _codeBlock() : SelectableText(content,
            style: AppText.body.copyWith(color: Theme.of(context).colorScheme.onSurface, height: 1.7)),
      ],
    );
  }

  Widget _codeBlock() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.codeBg, borderRadius: BorderRadius.circular(12)),
      child: SelectableText(content,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14, height: 1.55, color: AppColors.codeText)),
    );
  }
}
