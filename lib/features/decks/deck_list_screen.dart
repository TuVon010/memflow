/// MemFlow 卡组列表
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../core/theme.dart';
import '../../data/models/deck.dart';
import 'deck_detail_screen.dart';
import 'widgets/deck_card.dart';

class DeckListScreen extends ConsumerWidget {
  const DeckListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decks = ref.watch(deckListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('卡组')),
      body: decks.when(
        data: (list) {
          final active = list.where((d) => !d.isArchived).toList();
          final archived = list.where((d) => d.isArchived).toList();

          if (active.isEmpty && archived.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_open, size: 56, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text('还没有卡组', style: AppText.headline.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Text('点击下方按钮创建第一个卡组', style: AppText.footnote.copyWith(color: AppColors.textTertiary)),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            children: [
              ...active.map((d) => DeckCard(
                    deck: d,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => DeckDetailScreen(deckId: d.id)),
                    ),
                    onArchive: () async {
                      await ref.read(deckListProvider.notifier).toggleArchive(d.id, !d.isArchived);
                    },
                  )),
              if (archived.isNotEmpty) ...[
                const SizedBox(height: 24),
                ExpansionTile(
                  title: Text('已归档 (${archived.length})',
                      style: AppText.footnote.copyWith(color: AppColors.textSecondary)),
                  children: archived.map((d) => DeckCard(
                        deck: d,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => DeckDetailScreen(deckId: d.id)),
                        ),
                        onArchive: () async {
                          await ref.read(deckListProvider.notifier).toggleArchive(d.id, !d.isArchived);
                        },
                      )).toList(),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('新建卡组'),
      ),
    );
  }

  void _create(BuildContext ctx, WidgetRef ref) {
    final nameC = TextEditingController();
    final descC = TextEditingController();
    showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('新建卡组'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameC, decoration: const InputDecoration(labelText: '名称', hintText: '如: Java 集合'), autofocus: true),
            const SizedBox(height: 12),
            TextField(controller: descC, decoration: const InputDecoration(labelText: '描述（可选）'), maxLines: 2),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              if (nameC.text.trim().isEmpty) return;
              ref.read(deckListProvider.notifier).createDeck(Deck(name: nameC.text.trim(), description: descC.text.trim()));
              Navigator.pop(c);
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }
}
