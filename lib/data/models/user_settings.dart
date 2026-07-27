/// MemFlow 用户设置模型

import 'package:isar/isar.dart';

part 'user_settings.g.dart';

@collection
class UserSettings {
  Id id = 0;

  int dailyNewCardLimit = 20;
  int dailyReviewLimit = 0;
  String preferredLLMProvider = 'openai';
  String llmBaseURL = 'https://api.openai.com/v1';
  String llmModel = 'gpt-4o';
  DateTime? interviewDate;
  bool interviewModeEnabled = false;
  int themeMode = 0;
  List<DateTime> reviewReminderTimes = [];

  UserSettings({
    this.dailyNewCardLimit = 20,
    this.dailyReviewLimit = 0,
    this.preferredLLMProvider = 'openai',
    this.llmBaseURL = 'https://api.openai.com/v1',
    this.llmModel = 'gpt-4o',
    this.interviewDate,
    this.interviewModeEnabled = false,
    this.themeMode = 0,
    this.reviewReminderTimes = const [],
  });
}
