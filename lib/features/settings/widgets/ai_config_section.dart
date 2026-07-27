/// MemFlow AI 配置区域组件
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers.dart';
import '../../../core/constants.dart';
import '../../../data/models/user_settings.dart';

class AIConfigSection extends ConsumerStatefulWidget {
  const AIConfigSection({super.key});

  @override
  ConsumerState<AIConfigSection> createState() => _AIConfigSectionState();
}

class _AIConfigSectionState extends ConsumerState<AIConfigSection> {
  bool _isKeyVisible = false;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final apiKeyAsync = ref.watch(apiKeyProvider);

    return Card(
      child: settingsAsync.when(
        data: (settings) => Column(
          children: [
            // 提供商 — 选择预设时只更新 URL 和模型，不锁定
            ListTile(
              title: const Text('提供商'),
              trailing: DropdownButton<String>(
                value: settings.preferredLLMProvider,
                underline: const SizedBox(),
                items: [
                  for (final e in llmPresets.entries)
                    DropdownMenuItem(value: e.key, child: Text(e.value.name)),
                  const DropdownMenuItem(value: 'custom', child: Text('自定义')),
                ],
                onChanged: (provider) {
                  if (provider == null) return;
                  if (provider == 'custom') {
                    // 切到自定义模式只改标识，不动已有 URL
                    ref.read(settingsProvider.notifier).updateAIConfig(
                          provider: 'custom',
                          baseUrl: settings.llmBaseURL,
                          model: settings.llmModel,
                        );
                  } else {
                    final preset = llmPresets[provider];
                    if (preset != null) {
                      ref.read(settingsProvider.notifier).updateAIConfig(
                            provider: provider,
                            baseUrl: preset.baseUrl,
                            model: preset.defaultModel,
                          );
                    }
                  }
                },
              ),
            ),
            const Divider(height: 1),

            // Base URL — 随时可编辑，适配中转站 / API 代理
            ListTile(
              title: const Text('API 地址'),
              subtitle: Text(
                settings.llmBaseURL,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
              onTap: () => _editBaseUrl(context, ref, settings),
            ),
            const Divider(height: 1),

            // API Key
            ListTile(
              title: const Text('API Key'),
              subtitle: apiKeyAsync.when(
                data: (key) => Text(
                  _isKeyVisible ? (key ?? '未设置') : _maskKey(key),
                ),
                loading: () => const Text('加载中…'),
                error: (_, __) => const Text('加载失败'),
              ),
              trailing: IconButton(
                icon: Icon(_isKeyVisible ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _isKeyVisible = !_isKeyVisible),
              ),
              onTap: () => _editApiKey(context, ref),
            ),
            const Divider(height: 1),

            // 模型
            ListTile(
              title: const Text('模型'),
              subtitle: Text(settings.llmModel, style: const TextStyle(fontSize: 12)),
              onTap: () => _editModel(context, ref, settings),
            ),
          ],
        ),
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text('加载设置失败: $e'),
        ),
      ),
    );
  }

  String _maskKey(String? key) {
    if (key == null || key.isEmpty) return '未设置';
    if (key.length <= 8) return '*' * key.length;
    return '${key.substring(0, 4)}${'*' * (key.length - 8)}${key.substring(key.length - 4)}';
  }

  void _editBaseUrl(BuildContext context, WidgetRef ref, UserSettings settings) {
    final controller = TextEditingController(text: settings.llmBaseURL);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('API 地址'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://api.openai.com/v1',
            helperText: '中转站地址或代理 URL，以 /v1 结尾',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                ref.read(settingsProvider.notifier).updateAIConfig(
                      provider: settings.preferredLLMProvider,
                      baseUrl: url,
                      model: settings.llmModel,
                    );
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _editApiKey(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('API Key'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'sk-...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              final key = controller.text.trim();
              if (key.isNotEmpty) {
                ref.read(secureStorageProvider).saveApiKey(key);
                ref.invalidate(apiKeyProvider);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _editModel(BuildContext context, WidgetRef ref, UserSettings settings) {
    final controller = TextEditingController(text: settings.llmModel);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('模型名称'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'gpt-4o / deepseek-chat / llama3'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).updateAIConfig(
                    provider: settings.preferredLLMProvider,
                    baseUrl: settings.llmBaseURL,
                    model: controller.text.trim(),
                  );
              Navigator.of(ctx).pop();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
