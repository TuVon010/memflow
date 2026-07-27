/// MemFlow 面试倒计时计划区域组件
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers.dart';
import '../../../data/models/user_settings.dart';

class InterviewPlanSection extends ConsumerWidget {
  const InterviewPlanSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Card(
      child: settingsAsync.when(
        data: (settings) => Column(
          children: [
            SwitchListTile(
              title: const Text('面试倒计时模式'),
              subtitle: Text(settings.interviewModeEnabled ? '已开启' : '未开启'),
              value: settings.interviewModeEnabled,
              onChanged: (enabled) {
                ref.read(settingsProvider.notifier).setInterviewMode(
                      enabled: enabled,
                      interviewDate: settings.interviewDate,
                    );
              },
            ),
            if (settings.interviewModeEnabled) ...[
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('面试日期'),
                trailing: TextButton(
                  onPressed: () => _pickDate(context, ref, settings),
                  child: Text(
                    settings.interviewDate != null
                        ? '${settings.interviewDate!.year}-${settings.interviewDate!.month.toString().padLeft(2, '0')}-${settings.interviewDate!.day.toString().padLeft(2, '0')}'
                        : '选择日期',
                  ),
                ),
              ),
              if (settings.interviewDate != null) ...[
                ListTile(
                  leading: const Icon(Icons.timer),
                  title: const Text('剩余天数'),
                  trailing: Text(
                    '${settings.interviewDate!.difference(DateTime.now()).inDays} 天',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ],
        ),
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text('加载失败: $e'),
        ),
      ),
    );
  }

  void _pickDate(BuildContext context, WidgetRef ref, UserSettings settings) async {
    final date = await showDatePicker(
      context: context,
      initialDate: settings.interviewDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      ref.read(settingsProvider.notifier).setInterviewMode(enabled: true, interviewDate: date);
    }
  }
}
