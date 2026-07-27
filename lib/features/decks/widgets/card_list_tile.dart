/// MemFlow 卡片列表项
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/models/card.dart' as model;

class CardListTile extends StatelessWidget {
  final model.Card card;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CardListTile({super.key, required this.card, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        title: Text(card.question,
            maxLines: 2, overflow: TextOverflow.ellipsis,
            style: AppText.callout.copyWith(color: AppColors.textPrimary)),
        subtitle: card.tags.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Wrap(
                  spacing: 6, runSpacing: 4,
                  children: card.tags.map((t) => _chip(t)).toList(),
                ),
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.textTertiary),
          onPressed: onDelete,
        ),
      ),
    );
  }

  Widget _chip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(6)),
    child: Text(text, style: AppText.caption.copyWith(color: AppColors.textSecondary)),
  );
}
