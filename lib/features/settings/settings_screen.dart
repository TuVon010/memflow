/// MemFlow 设置页面
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../core/theme.dart';
import '../../data/models/user_settings.dart';
import 'widgets/ai_config_section.dart';
import 'widgets/interview_plan_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: sAsync.when(
        data: (s) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            _section('AI 配置'),
            const AIConfigSection(),
            const SizedBox(height: 28),
            _section('复习'),
            _ReviewSetting(s: s),
            const SizedBox(height: 28),
            _section('面试计划'),
            const InterviewPlanSection(),
            const SizedBox(height: 28),
            _section('数据'),
            _DataManagement(),
            const SizedBox(height: 28),
            _section('外观'),
            _ThemeSetting(s: s),
            const SizedBox(height: 28),
            _section('关于'),
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline, color: AppColors.textSecondary),
                title: const Text('版本'), subtitle: const Text('v0.5.0 · 内部测试'),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
    );
  }

  Widget _section(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(t, style: AppText.footnote.copyWith(
        color: AppColors.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
  );
}

// ── 复习设置 ──────────────────────────────────────────

class _ReviewSetting extends StatelessWidget {
  final UserSettings s;
  const _ReviewSetting({required this.s});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Consumer(builder: (context, ref, _) {
        return ListTile(
          leading: const Icon(Icons.speed, color: AppColors.textSecondary),
          title: const Text('每日新卡上限'),
          subtitle: Text('${s.dailyNewCardLimit} 张', style: AppText.footnote.copyWith(color: AppColors.textSecondary)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _circleBtn(Icons.remove, s.dailyNewCardLimit > 5, () {
                s.dailyNewCardLimit -= 5;
                ref.read(settingsProvider.notifier).saveSettings(s);
              }),
              const SizedBox(width: 8),
              _circleBtn(Icons.add, s.dailyNewCardLimit < 100, () {
                s.dailyNewCardLimit += 5;
                ref.read(settingsProvider.notifier).saveSettings(s);
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _circleBtn(IconData icon, bool enabled, VoidCallback onTap) {
    return Material(
      color: enabled ? AppColors.primaryBg : const Color(0xFFF2F2F7),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20, color: enabled ? AppColors.primary : AppColors.textTertiary),
        ),
      ),
    );
  }
}

// ── 数据管理 ──────────────────────────────────────────

class _DataManagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.upload_outlined, color: AppColors.textSecondary),
            title: const Text('导出卡组'),
            subtitle: Text('.mfcard.json', style: AppText.footnote.copyWith(color: AppColors.textTertiary)),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('即将上线'))),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.download_outlined, color: AppColors.textSecondary),
            title: const Text('导入卡组'),
            subtitle: Text('从文件导入', style: AppText.footnote.copyWith(color: AppColors.textTertiary)),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('即将上线'))),
          ),
        ],
      ),
    );
  }
}

// ── 外观设置 ──────────────────────────────────────────

class _ThemeSetting extends StatelessWidget {
  final UserSettings s;
  const _ThemeSetting({required this.s});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Consumer(builder: (context, ref, _) {
        return Column(
          children: [
            _radio(context, ref, '跟随系统', 0),
            const Divider(),
            _radio(context, ref, '浅色', 1),
            const Divider(),
            _radio(context, ref, '深色', 2),
          ],
        );
      }),
    );
  }

  Widget _radio(BuildContext context, WidgetRef ref, String label, int value) {
    return ListTile(
      leading: Icon(
        value == 0 ? Icons.brightness_auto : value == 1 ? Icons.light_mode : Icons.dark_mode,
        color: AppColors.textSecondary,
      ),
      title: Text(label),
      trailing: s.themeMode == value
          ? const Icon(Icons.check, color: AppColors.primary, size: 22)
          : const SizedBox(width: 22),
      onTap: () {
        s.themeMode = value;
        ref.read(settingsProvider.notifier).saveSettings(s);
      },
    );
  }
}
