/// 卡片选择复习
///
/// 从各卡组中选择想复习的卡片，确认后仅复习勾选的卡片。
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../core/theme.dart';
import '../../data/models/card.dart';
import '../../engine/queue_generator.dart';
import 'widgets/card_widget.dart';
import 'widgets/rating_buttons.dart';
import 'widgets/ai_explain_sheet.dart';

class CardPickerScreen extends ConsumerStatefulWidget {
  const CardPickerScreen({super.key});

  @override
  ConsumerState<CardPickerScreen> createState() => _CardPickerScreenState();
}

class _CardPickerScreenState extends ConsumerState<CardPickerScreen> {
  final Set<int> _selected = {};
  List<Card> _allCards = [];
  Map<int, String> _deckNames = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cardRepo = ref.read(cardRepoProvider);
    final deckRepo = ref.read(deckRepoProvider);

    final decks = await deckRepo.getAll();
    final cards = <Card>[];
    for (final d in decks) {
      final dc = await cardRepo.getByDeck(d.id);
      for (final c in dc) {
        cards.add(c);
        _deckNames[c.id] = d.name;
      }
    }

    if (mounted) {
      setState(() {
        _allCards = cards;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('选择复习卡片')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_allCards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('选择复习卡片')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textTertiary),
              const SizedBox(height: 12),
              const Text('还没有卡片'),
              const SizedBox(height: 16),
              FilledButton(onPressed: () => Navigator.pop(context), child: const Text('返回')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('已选 ${_selected.length} 张'),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              if (_selected.length == _allCards.length) {
                _selected.clear();
              } else {
                _selected.addAll(_allCards.map((Card c) => c.id));
              }
            }),
            child: Text(_selected.length == _allCards.length ? '取消全选' : '全选'),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        itemCount: _allCards.length,
        separatorBuilder: (_, __) => const SizedBox(height: 2),
        itemBuilder: (_, i) {
          final card = _allCards[i];
          final selected = _selected.contains(card.id);
          return Material(
            color: selected ? AppColors.primaryBg : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => setState(() {
                if (selected) { _selected.remove(card.id); }
                else { _selected.add(card.id); }
              }),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: Row(
                  children: [
                    Icon(
                      selected ? Icons.check_circle : Icons.circle_outlined,
                      color: selected ? AppColors.primary : AppColors.textTertiary,
                      size: 24,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(card.question, maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: AppText.callout.copyWith(color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text(_deckNames[card.id] ?? '', style: AppText.caption.copyWith(color: AppColors.textTertiary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: FilledButton.icon(
            onPressed: _selected.isEmpty ? null : () {
              // 仅将选中的卡片放入复习队列
              // 收集选中的卡片
              final List<Card> pickedList = [];
              for (final c in _allCards) {
                if (_selected.contains(c.id)) pickedList.add(c);
              }
              final items = pickedList.map((card) => ReviewItem(card: card)).toList();
              final qs = ReviewQueueState(queue: items, totalCards: items.length);
              ref.read(reviewQueueProvider.notifier).setCustomQueue(qs);
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReviewScreenWithCustomQueue()));
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text('开始复习 (${_selected.length})'),
          ),
        ),
      ),
    );
  }
}

/// 走自定义队列的复习页
class ReviewScreenWithCustomQueue extends ConsumerWidget {
  const ReviewScreenWithCustomQueue({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 复用现有复习页逻辑，只是队列已预设
    return const _ReviewWithQueue();
  }
}

class _ReviewWithQueue extends ConsumerStatefulWidget {
  const _ReviewWithQueue();

  @override
  ConsumerState<_ReviewWithQueue> createState() => _ReviewWithQueueState();
}

class _ReviewWithQueueState extends ConsumerState<_ReviewWithQueue> {
  bool _answerShown = false;
  DateTime? _questionTime;
  String? _apiKey;
  String _baseUrl = '';
  String _model = '';

  void _markTime() => _questionTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadConfig();
    _markTime();
  }

  Future<void> _loadConfig() async {
    final apiKey = await ref.read(secureStorageProvider).getApiKey();
    final settings = await ref.read(settingsRepoProvider).get();
    if (mounted) setState(() {
      _apiKey = apiKey;
      _baseUrl = settings.llmBaseURL;
      _model = settings.llmModel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final qs = ref.watch(reviewQueueProvider);

    if (qs.queue.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('复习')),
        body: const Center(child: Text('没有选择卡片')),
      );
    }

    final card = qs.currentCard!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.popUntil(context, (r) => r.isFirst)),
        title: Text('${qs.currentIndex + 1} / ${qs.totalCards}'),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: qs.progress, minHeight: 3, backgroundColor: const Color(0xFFE5E5EA)),
          Expanded(
            child: GestureDetector(
              onTap: _answerShown ? null : () => setState(() => _answerShown = true),
              behavior: HitTestBehavior.translucent,
              child: ReviewCardWidget(
                card: card.card,
                isAnswerShown: _answerShown,
                isNewCard: card.isNewCard,
              ),
            ),
          ),
          // AI 答疑按钮
          if (_answerShown)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                    builder: (_) => AIExplainSheet(
                      question: card.card.question, answer: card.card.answer,
                      apiKey: _apiKey, baseUrl: _baseUrl, model: _model,
                    ),
                  );
                },
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('AI 答疑'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF5856D6),
                  side: const BorderSide(color: Color(0xFF5856D6), width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
            ),
          if (_answerShown)
            RatingButtons(onRated: (r) async {
              final ms = _questionTime != null ? DateTime.now().difference(_questionTime!).inMilliseconds : 0;
              await ref.read(reviewQueueProvider.notifier).submitRating(r, elapsedMs: ms);
              setState(() {
                _answerShown = false;
                _markTime();
              });
            }),
        ],
      ),
    );
  }
}
