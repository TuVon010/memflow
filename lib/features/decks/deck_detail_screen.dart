/// MemFlow 卡组详情页
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../core/theme.dart';
import 'card_edit_screen.dart';
import '../ai_generate/ai_generate_screen.dart';
import 'widgets/card_list_tile.dart';

class DeckDetailScreen extends ConsumerWidget {
  final int deckId;
  const DeckDetailScreen({super.key, required this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardsOfDeckProvider(deckId));
    final deckList = ref.watch(deckListProvider).valueOrNull;
    final deck = deckList?.where((d) => d.id == deckId).firstOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(deck?.name ?? '卡组详情')),
      body: cards.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.style_outlined, size: 52, color: AppColors.textTertiary),
                  const SizedBox(height: 14),
                  Text('还没有卡片', style: AppText.headline.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Text('点击右下角添加第一张卡片', style: AppText.footnote.copyWith(color: AppColors.textTertiary)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            itemCount: list.length,
            itemBuilder: (_, i) => CardListTile(
              card: list[i],
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CardEditScreen(deckId: deckId, existingCard: list[i])),
              ),
              onDelete: () async {
                await ref.read(cardRepoProvider).deleteCard(list[i].id);
                ref.invalidate(cardsOfDeckProvider(deckId));
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 36, height: 5,
                  decoration: BoxDecoration(color: AppColors.textTertiary, borderRadius: BorderRadius.circular(3))),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.primaryBg, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.edit_note, color: AppColors.primary),
                ),
                title: const Text('手动添加'), subtitle: const Text('逐张编写问答卡片'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => CardEditScreen(deckId: deckId)));
                },
              ),
              const SizedBox(height: 4),
              ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.primaryBg, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.auto_awesome, color: AppColors.primary),
                ),
                title: const Text('AI 生成'), subtitle: const Text('粘贴文本，AI 自动拆解'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => AIGenerateScreen(deckId: deckId)));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
