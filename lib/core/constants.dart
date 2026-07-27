/// MemFlow 全局常量与配置
///
/// 包含 LLM 预设、算法参数、UI 常量等应用级配置。

/// LLM 提供商预设
class LLMPreset {
  final String name;
  final String baseUrl;
  final String defaultModel;

  const LLMPreset({
    required this.name,
    required this.baseUrl,
    required this.defaultModel,
  });
}

/// AI 服务预设端点（用户仍可在设置中修改）
const Map<String, LLMPreset> llmPresets = {
  'openai': LLMPreset(
    name: 'OpenAI',
    baseUrl: 'https://api.openai.com/v1',
    defaultModel: 'gpt-4o',
  ),
  'deepseek': LLMPreset(
    name: 'DeepSeek',
    baseUrl: 'https://api.deepseek.com/v1',
    defaultModel: 'deepseek-chat',
  ),
  'ollama': LLMPreset(
    name: 'Ollama',
    baseUrl: 'http://localhost:11434/v1',
    defaultModel: 'llama3',
  ),
};

/// 卡片类型定义
class CardTypes {
  static const String basic = 'basic';
  static const String cloz = 'cloz';
  static const String comparison = 'comparison';
  static const String code = 'code';

  /// 卡片类型的中文标签映射
  static const Map<String, String> labels = {
    basic: '基本',
    cloz: '填空',
    comparison: '对比',
    code: '代码',
  };
}

/// 导出文件扩展名
const String exportFileExtension = 'mfcard.json';

/// 导出文件 MIME 类型
const String exportFileMimeType = 'application/json';
