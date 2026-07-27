/// MemFlow 设置仓库
///
/// 封装 UserSettings 的读写操作（单例模式，id=0）。
/// API Key 不在此处存储，由 SecureStorageService 管理。

import 'package:isar/isar.dart';
import '../isar_service.dart';
import '../models/user_settings.dart';

class SettingsRepo {
  final IsarService _isarService;

  Isar get _isar => _isarService.isar;

  SettingsRepo(this._isarService);

  /// 获取用户设置（始终返回非 null，若不存在则创建默认设置）
  Future<UserSettings> get() async {
    final settings = await _isar.userSettings.get(0);
    if (settings == null) {
      final defaultSettings = UserSettings();
      await _isar.writeTxn(() async {
        await _isar.userSettings.put(defaultSettings);
      });
      return defaultSettings;
    }
    return settings;
  }

  /// 更新用户设置
  Future<void> update(UserSettings settings) async {
    await _isar.writeTxn(() async {
      await _isar.userSettings.put(settings);
    });
  }

  /// 更新每日新卡上限
  Future<void> setDailyNewCardLimit(int limit) async {
    await _isar.writeTxn(() async {
      final settings = await _isar.userSettings.get(0);
      if (settings != null) {
        settings.dailyNewCardLimit = limit;
        await _isar.userSettings.put(settings);
      }
    });
  }

  /// 更新面试倒计时模式
  Future<void> setInterviewMode({
    required bool enabled,
    DateTime? interviewDate,
  }) async {
    await _isar.writeTxn(() async {
      final settings = await _isar.userSettings.get(0);
      if (settings != null) {
        settings.interviewModeEnabled = enabled;
        settings.interviewDate = interviewDate;
        await _isar.userSettings.put(settings);
      }
    });
  }

  /// 更新 AI 配置（不包含 API Key）
  Future<void> setAIConfig({
    required String provider,
    required String baseUrl,
    required String model,
  }) async {
    await _isar.writeTxn(() async {
      final settings = await _isar.userSettings.get(0);
      if (settings != null) {
        settings.preferredLLMProvider = provider;
        settings.llmBaseURL = baseUrl;
        settings.llmModel = model;
        await _isar.userSettings.put(settings);
      }
    });
  }

  /// 更新主题模式
  Future<void> setThemeMode(int mode) async {
    await _isar.writeTxn(() async {
      final settings = await _isar.userSettings.get(0);
      if (settings != null) {
        settings.themeMode = mode.clamp(0, 2);
        await _isar.userSettings.put(settings);
      }
    });
  }

  /// 更新复习提醒时间
  Future<void> setReminderTimes(List<DateTime> times) async {
    await _isar.writeTxn(() async {
      final settings = await _isar.userSettings.get(0);
      if (settings != null) {
        settings.reviewReminderTimes = times;
        await _isar.userSettings.put(settings);
      }
    });
  }
}
