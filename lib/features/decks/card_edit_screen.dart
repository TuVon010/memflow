/// MemFlow 卡片编辑页面
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../core/constants.dart';
import '../../data/models/card.dart' as model;

class CardEditScreen extends ConsumerStatefulWidget {
  final int deckId;
  final model.Card? existingCard;

  const CardEditScreen({super.key, required this.deckId, this.existingCard});

  bool get isEditing => existingCard != null;

  @override
  ConsumerState<CardEditScreen> createState() => _CardEditScreenState();
}

class _CardEditScreenState extends ConsumerState<CardEditScreen> {
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  late String _cardType;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.existingCard?.question ?? '');
    _answerController = TextEditingController(text: widget.existingCard?.answer ?? '');
    _cardType = widget.existingCard?.cardType ?? CardTypes.basic;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? '编辑卡片' : '新建卡片'),
        actions: [
          TextButton(onPressed: _saveCard, child: const Text('保存')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _cardType,
              decoration: const InputDecoration(labelText: '卡片类型'),
              items: CardTypes.labels.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _cardType = v);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: '问题',
                hintText: '请输入问题（支持 Markdown）',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(
                labelText: '答案',
                hintText: '请输入答案（支持 Markdown 和代码块）',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              textInputAction: TextInputAction.newline,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCard() async {
    final question = _questionController.text.trim();
    final answer = _answerController.text.trim();

    if (question.isEmpty || answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('问题和答案不能为空')),
      );
      return;
    }

    final cardRepo = ref.read(cardRepoProvider);

    if (widget.isEditing && widget.existingCard != null) {
      widget.existingCard!.question = question;
      widget.existingCard!.answer = answer;
      widget.existingCard!.cardType = _cardType;
      widget.existingCard!.updatedAt = DateTime.now();
      await cardRepo.updateCard(widget.existingCard!);
    } else {
      final newCard = model.Card(
        question: question,
        answer: answer,
        cardType: _cardType,
        deckId: widget.deckId,
      );
      await cardRepo.createCard(newCard);
    }

    ref.invalidate(cardsOfDeckProvider(widget.deckId));

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.isEditing ? '卡片已更新' : '卡片已创建')),
      );
    }
  }
}
