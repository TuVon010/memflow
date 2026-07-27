/// MemFlow Isar 数据库服务

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/deck.dart';
import 'models/card.dart';
import 'models/review_state.dart';
import 'models/review_log_entry.dart';
import 'models/ai_usage_log.dart';
import 'models/user_settings.dart';
import 'models/review_session.dart';

class IsarService {
  late final Isar isar;

  Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [
        DeckSchema,
        CardSchema,
        ReviewStateSchema,
        AIUsageLogSchema,
        UserSettingsSchema,
        ReviewSessionSchema,
      ],
      directory: dir.path,
    );

    await _ensureDefaultSettings();
  }

  Future<void> _ensureDefaultSettings() async {
    final existing = await isar.userSettings.get(0);
    if (existing == null) {
      await isar.writeTxn(() async {
        await isar.userSettings.put(UserSettings());
      });
    }
  }

  Future<void> close() async {
    await isar.close();
  }
}
