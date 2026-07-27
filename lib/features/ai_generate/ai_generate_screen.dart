/// MemFlow AI 生成卡片页面
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../services/ai_service.dart';
import '../../data/models/card.dart' as model;

class AIGenerateScreen extends ConsumerStatefulWidget {
  final int deckId;

  const AIGenerateScreen({super.key, required this.deckId});

  @override
  ConsumerState<AIGenerateScreen> createState() => _AIGenerateScreenState();
}

class _AIGenerateScreenState extends ConsumerState<AIGenerateScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final generateState = ref.watch(aiGenerateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('AI 生成卡片')),
      body: Column(
        children: [
          if (generateState.status != AIGenerateStatus.success)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: '粘贴面试题、技术文档、面经等内容…',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 8,
                    onChanged: (v) {
                      ref.read(aiGenerateProvider.notifier).setInputText(v);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildAIConfigHint(context, ref),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: generateState.status == AIGenerateStatus.loading
                          ? null
                          : () => ref.read(aiGenerateProvider.notifier).generate(),
                      icon: generateState.status == AIGenerateStatus.loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(
                        generateState.status == AIGenerateStatus.loading
                            ? '正在生成…'
                            : '✨ 开始生成',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (generateState.errorMessage != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(child: Text(generateState.errorMessage!)),
                  TextButton(
                    onPressed: () => ref.read(aiGenerateProvider.notifier).generate(),
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
          if (generateState.status == AIGenerateStatus.success)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('生成结果 (${generateState.previewCards.length} 张)',
                            style: Theme.of(context).textTheme.titleSmall),
                        TextButton(
                          onPressed: () {
                            ref.read(aiGenerateProvider.notifier).reset();
                            _textController.clear();
                          },
                          child: const Text('重新生成'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: generateState.previewCards.length,
                      itemBuilder: (context, index) {
                        return _buildPreviewCard(context, ref, generateState.previewCards[index], index);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => _saveAllCards(context, ref),
                        icon: const Icon(Icons.check),
                        label: const Text('全部添加'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAIConfigHint(BuildContext context, WidgetRef ref) {
    final apiKey = ref.watch(apiKeyProvider);
    final hasKey = apiKey.valueOrNull != null && apiKey.valueOrNull!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasKey
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(hasKey ? Icons.check_circle : Icons.info_outline, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasKey ? 'AI 服务已配置' : '请先在设置中配置 AI API Key',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context, WidgetRef ref, CardPreview preview, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('#${index + 1}', style: Theme.of(context).textTheme.labelMedium),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () => ref.read(aiGenerateProvider.notifier).removePreviewCard(index),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Q: ${preview.question}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('A: ${preview.answer}',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 4,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAllCards(BuildContext context, WidgetRef ref) async {
    final previews = ref.read(aiGenerateProvider).previewCards;
    if (previews.isEmpty) return;

    final cards = previews.map((p) => model.Card(
      question: p.question,
      answer: p.answer,
      cardType: p.cardType,
      tags: p.tags,
    )).toList();

    await ref.read(cardRepoProvider).createCardsToDeck(cards, widget.deckId);

    ref.invalidate(cardsOfDeckProvider(widget.deckId));
    ref.read(aiGenerateProvider.notifier).reset();

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已添加 ${previews.length} 张卡片')),
      );
    }
  }
}
