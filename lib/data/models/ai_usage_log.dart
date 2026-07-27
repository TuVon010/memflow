/// MemFlow AI 调用日志
///
/// 记录每次 AI API 调用的基本信息，用于统计和用户自我监控。
/// 存储 Token 消耗估算值，帮助用户了解 API 使用成本。

import 'package:isar/isar.dart';

part 'ai_usage_log.g.dart';

@collection
class AIUsageLog {
  /// 自增主键
  Id id = Isar.autoIncrement;

  /// 调用时间
  DateTime timestamp = DateTime.now();

  /// 用途: generate-cards(拆卡), explain(答疑), score(评分)
  String purpose = '';

  /// LLM 提供商: openai, deepseek, ollama
  String provider = '';

  /// 模型名称
  String model = '';

  /// 消耗的 Token 数量（近似值，由响应中的 usage 字段解析）
  int tokenCount = 0;

  /// 是否调用成功
  bool success = true;

  AIUsageLog({
    this.purpose = '',
    this.provider = '',
    this.model = '',
    this.tokenCount = 0,
    this.success = true,
  });
}
