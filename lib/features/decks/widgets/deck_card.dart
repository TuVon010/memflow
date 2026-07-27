/// MemFlow 卡组卡片
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/models/deck.dart';

class DeckCard extends StatelessWidget {
  final Deck deck;
  final VoidCallback? onTap;
  final VoidCallback? onArchive;
  final VoidCallback? onExport;

  const DeckCard({
    super.key,
    required this.deck,
    this.onTap,
    this.onArchive,
    this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              // 左侧色条
              Container(
                width: 4,
                height: 52,
                decoration: BoxDecoration(
                  color: Color(deck.color),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(deck.name,
                        style: AppText.headline.copyWith(color: AppColors.textPrimary)),
                    if (deck.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(deck.description,
                          style: AppText.footnote.copyWith(color: AppColors.textSecondary),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: 6),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'archive') onArchive?.call();
                  if (v == 'export') onExport?.call();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'archive', child: Text(deck.isArchived ? '取消归档' : '归档')),
                  const PopupMenuItem(value: 'export', child: Text('导出')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


}
