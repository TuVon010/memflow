/// MemFlow AI 服务
///
/// 封装 LLM API 调用，支持 OpenAI、DeepSeek、Ollama 及自定义端点。
/// 提供拆卡生成和划词答疑两个核心 AI 能力。
/// 所有调用由客户端直连，不经过任何第三方服务器。

import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';

/// AI 服务异常
class AIServiceException implements Exception {
  final String message;
  final String? code;
  AIServiceException(this.message, {this.code});

  @override
  String toString() => 'AIServiceException: $message';
}

/// AI 调用超时异常
class AITimeoutException extends AIServiceException {
  AITimeoutException() : super('请求超时，请检查网络后重试');
}

/// AI 生成的卡片预览数据
class CardPreview {
  final String question;
  final String answer;
  final String cardType;
  final List<String> tags;

  CardPreview({
    required this.question,
    required this.answer,
    this.cardType = 'basic',
    List<String>? tags,
  }) : tags = tags ?? [];

  factory CardPreview.fromJson(Map<String, dynamic> json) {
    return CardPreview(
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      cardType: json['cardType'] as String? ?? 'basic',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

/// AI 服务抽象接口
abstract class AIService {
  /// 将一段文本拆解为记忆卡片
  Future<List<CardPreview>> generateCards(String text, {String? customPrompt});

  /// 根据卡片上下文解释选中的文字
  Future<String> explain(String selectedText, String question, String answer);
}

/// OpenAI 兼容接口实现
///
/// 支持所有 OpenAI-compatible API（OpenAI、DeepSeek、Ollama 等）。
class OpenAIService implements AIService {
  final Dio _dio;
  final String apiKey;
  final String baseUrl;
  final String model;

  /// 最大重试次数
  static const int maxRetries = 2;

  /// 请求超时时间（秒）
  static const int timeoutSeconds = 30;

  OpenAIService({
    required this.apiKey,
    required this.baseUrl,
    required this.model,
  }) : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: timeoutSeconds),
          receiveTimeout: const Duration(seconds: timeoutSeconds),
        ));

  @override
  Future<List<CardPreview>> generateCards(String text,
      {String? customPrompt}) async {
    final systemPrompt =
        '你是一位面试专家，擅长将技术文本拆解为简洁的问答卡片。'
        '请严格按照 JSON 数组格式输出，每张卡片包含 question(问题)、answer(答案)、cardType(类型: basic/cloz/comparison/code)、tags(标签数组) 字段。'
        'cardType 默认为 "basic"。只生成 3~5 张卡片。';

    final userPrompt = customPrompt ??
        '请将以下文本拆解为 3~5 张记忆卡片：\n\n$text';

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': userPrompt},
    ];

    final content = await _callAPI(messages, temperature: 0.3, maxTokens: 2000);
    return _parseCardsResponse(content);
  }

  @override
  Future<String> explain(
      String selectedText, String question, String answer) async {
    final systemPrompt =
        '你是一位耐心的技术导师。请根据卡片上下文，简洁解释用户选中的技术概念或代码。'
        '必要时给出示例，如果涉及面试常考点可附上追问建议。';

    final userPrompt =
        '卡片问题：$question\n卡片答案：$answer\n\n用户选中了以下文字，请解释：\n"$selectedText"';

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': userPrompt},
    ];

    return await _callAPI(messages, temperature: 0.5, maxTokens: 600);
  }

  /// 调用 LLM API，包含重试逻辑
  Future<String> _callAPI(
    List<Map<String, String>> messages, {
    double temperature = 0.3,
    int maxTokens = 2000,
  }) async {
    final url = '${baseUrl}/chat/completions';
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
    final body = {
      'model': model,
      'messages': messages,
      'temperature': temperature,
      'max_tokens': maxTokens,
    };

    int retries = 0;
    while (retries <= maxRetries) {
      try {
        final response = await _dio.post(url,
            data: body, options: Options(headers: headers));

        if (response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>;
          final choices = data['choices'] as List<dynamic>;
          if (choices.isEmpty) {
            throw AIServiceException('AI 返回空结果');
          }
          return choices[0]['message']['content'] as String;
        } else if (response.statusCode == 401) {
          throw AIServiceException('API Key 无效，请检查设置',
              code: 'unauthorized');
        } else if (response.statusCode == 402) {
          throw AIServiceException('API 余额不足，请充值后重试',
              code: 'insufficient_quota');
        } else if (response.statusCode == 429) {
          // 速率限制：退避等待后重试
          retries++;
          if (retries > maxRetries) {
            throw AIServiceException('请求过于频繁，请稍后重试', code: 'rate_limited');
          }
          await Future.delayed(
              Duration(seconds: pow(2, retries).toInt()));
        } else {
          retries++;
          if (retries > maxRetries) {
            throw AIServiceException('AI 服务暂时不可用 (${response.statusCode})',
                code: 'server_error');
          }
        }
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          retries++;
          if (retries > maxRetries) {
            throw AITimeoutException();
          }
        } else if (e.type == DioExceptionType.connectionError) {
          throw AIServiceException('网络连接失败，请检查网络设置',
              code: 'network_error');
        } else {
          retries++;
          if (retries > maxRetries) {
            throw AIServiceException('请求失败: ${e.message}', code: 'unknown');
          }
        }
      }
    }

    throw AIServiceException('AI 服务不可用，已达最大重试次数');
  }

  /// 解析 AI 生成的卡片 JSON 响应
  ///
  /// 支持三种格式（不同 LLM 返回不同）：
  ///   {"cards": [{...}, ...]}    — OpenAI json_object 模式
  ///   [{...}, ...]               — 有些模型直接返回数组
  ///   文本中嵌入的数组              — 某些模型会加说明文字
  List<CardPreview> _parseCardsResponse(String content) {
    try {
      final decoded = jsonDecode(content);

      List<dynamic> cardsList;

      if (decoded is Map<String, dynamic>) {
        // 格式1: { "cards": [...] }
        if (decoded.containsKey('cards')) {
          cardsList = decoded['cards'] as List<dynamic>;
        } else {
          throw AIServiceException('JSON 对象中未找到 cards 字段');
        }
      } else if (decoded is List) {
        // 格式2: 直接返回数组 [...]
        cardsList = decoded;
      } else {
        throw AIServiceException('AI 返回了无法识别的格式');
      }

      return cardsList
          .map((e) => CardPreview.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is AIServiceException) rethrow;
      // 最后兜底：尝试在文本中找 JSON 数组
      final match = RegExp(r'\[\s*\{[\s\S]*\}\s*\]').firstMatch(content);
      if (match != null) {
        try {
          final list = jsonDecode(match.group(0)!) as List<dynamic>;
          return list
              .map((e) => CardPreview.fromJson(e as Map<String, dynamic>))
              .toList();
        } catch (_) {}
      }
      throw AIServiceException('解析 AI 响应失败: ${e.toString()}');
    }
  }
}
