/// MemFlow AI 答疑底部抽屉 — 自由提问
///
/// 显示卡片 Q&A 引用，用户可输入自己的问题，向 AI 追问
import 'package:flutter/material.dart';
import '../../../services/ai_service.dart';

class AIExplainSheet extends StatefulWidget {
  final String question;   // 卡片问题（作上下文）
  final String answer;     // 卡片答案（作上下文）
  final String? apiKey;
  final String baseUrl;
  final String model;

  const AIExplainSheet({
    super.key,
    required this.question,
    required this.answer,
    this.apiKey,
    this.baseUrl = '',
    this.model = '',
  });

  @override
  State<AIExplainSheet> createState() => _AIExplainSheetState();
}

class _AIExplainSheetState extends State<AIExplainSheet> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <_Msg>[];
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    final key = widget.apiKey;
    if (key == null || key.isEmpty) {
      _messages.add(_Msg(isUser: false, text: '请先在"设置"中配置 API Key'));
      return;
    }

    setState(() {
      _messages.add(_Msg(isUser: true, text: text));
      _messages.add(_Msg(isUser: false, loading: true));
      _loading = true;
    });
    _controller.clear();

    final url = widget.baseUrl.isNotEmpty ? widget.baseUrl : 'https://api.openai.com/v1';
    final model = widget.model.isNotEmpty ? widget.model : 'gpt-4o';

    try {
      final service = OpenAIService(apiKey: key, baseUrl: url, model: model);
      // 把卡片上下文 + 用户问题一起发给 AI
      final prompt = '卡片问题：${widget.question}\n卡片答案：${widget.answer}\n\n用户追问：$text\n\n请根据上述上下文简洁回答用户的问题。';
      final result = await service.explain(prompt, widget.question, widget.answer);

      if (mounted) {
        setState(() {
          _messages.removeLast();
          _messages.add(_Msg(isUser: false, text: result));
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.removeLast();
          _messages.add(_Msg(isUser: false, text: '请求失败: ${e.toString()}', error: true));
          _loading = false;
        });
      }
    }

    // 滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 18, color: Color(0xFF5856D6)),
                const SizedBox(width: 8),
                const Text('AI 答疑', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // 消息列表
          Flexible(
            child: _messages.isEmpty ? _buildWelcome(context) : ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _bubble(_messages[i]),
            ),
          ),

          // 输入框
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: '输入你的问题…',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: const BorderSide(color: Color(0xFF5856D6)),
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _loading ? null : _send,
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: _loading ? Colors.grey.shade300 : const Color(0xFF5856D6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_loading ? Icons.hourglass_top : Icons.arrow_upward,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFF5856D6).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Text('Q. ${widget.question}', style: const TextStyle(fontSize: 14, color: Color(0xFF5856D6))),
                  const SizedBox(height: 8),
                  Text('A. ${widget.answer.length > 80 ? widget.answer.substring(0, 80)+'…' : widget.answer}',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('在下方输入你的问题', style: TextStyle(fontSize: 15, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _bubble(_Msg msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (msg.isUser) const Spacer(),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: msg.isUser ? const Color(0xFF5856D6) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: msg.loading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(msg.text, style: TextStyle(fontSize: 15, color: msg.isUser ? Colors.white : (msg.error ? Colors.red : Colors.black87), height: 1.5)),
            ),
          ),
          if (!msg.isUser) const Spacer(),
        ],
      ),
    );
  }
}

class _Msg {
  final bool isUser;
  final String text;
  final bool loading;
  final bool error;
  _Msg({this.isUser = false, this.text = '', this.loading = false, this.error = false});
}
