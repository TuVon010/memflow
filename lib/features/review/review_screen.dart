/// MemFlow 沉浸式卡片复习
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../core/theme.dart';
import 'widgets/card_widget.dart';
import 'widgets/rating_buttons.dart';
import 'widgets/ai_explain_sheet.dart';

class CardReviewScreen extends ConsumerStatefulWidget {
  const CardReviewScreen({super.key});

  @override
  ConsumerState<CardReviewScreen> createState() => _CardReviewScreenState();
}

class _CardReviewScreenState extends ConsumerState<CardReviewScreen> {
  bool _answerShown = false;
  DateTime? _questionTime;
  bool _initialized = false;
  String? _apiKey;
  String _baseUrl = '';
  String _model = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final apiKey = await ref.read(secureStorageProvider).getApiKey();
      final settings = await ref.read(settingsRepoProvider).get();
      await ref.read(reviewQueueProvider.notifier).generateQueue();
      if (mounted) {
        setState(() {
          _initialized = true;
          _apiKey = apiKey;
          _baseUrl = settings.llmBaseURL;
          _model = settings.llmModel;
        });
        _markTime();
      }
    });
  }

  void _markTime() => _questionTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final qs = ref.watch(reviewQueueProvider);

    // loading
    if (!_initialized) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 全部完成 — 显示统计
    if (qs.isCompleted || (qs.queue.isNotEmpty && qs.currentIndex >= qs.queue.length)) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                const Text('复习完成！', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                _row('卡片', '${qs.reviewedCount}'),
                _row('顺畅', '${qs.goodCount}'),
                _row('犹豫', '${qs.hardCount}'),
                _row('生疏', '${qs.againCount}'),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('返回首页'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 队列空
    if (qs.queue.isEmpty) {
      return Scaffold(
        appBar: AppBar(leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))),
        body: const Center(child: Text('排队队列为空')),
      );
    }

    // 安全取出当前卡片
    final current = qs.currentCard;
    if (current == null) {
      return Scaffold(
        appBar: AppBar(leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))),
        body: const Center(child: Text('卡片加载异常')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        title: Text('${qs.currentIndex + 1} / ${qs.totalCards}'),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: qs.progress, minHeight: 3, backgroundColor: const Color(0xFFE5E5EA)),
          Expanded(
            child: GestureDetector(
              onTap: _answerShown ? null : () => setState(() => _answerShown = true),
              child: ReviewCardWidget(
                card: current.card,
                isAnswerShown: _answerShown,
                isNewCard: current.isNewCard,
              ),
            ),
          ),
          // AI 答疑按钮 — 在卡片和评分之间，答案显示后才出现
          if (_answerShown)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton.icon(
                onPressed: () => _showAI(current.card.question, current.card.answer),
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

  Widget _row(String label, String val) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Text('$label: $val', style: const TextStyle(fontSize: 16)),
  );

  void _showAI(String q, String a) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => AIExplainSheet(
        question: q, answer: a,
        apiKey: _apiKey, baseUrl: _baseUrl, model: _model,
      ),
    );
  }
}
