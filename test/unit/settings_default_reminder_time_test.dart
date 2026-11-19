import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snapaction/core/database/app_database.dart';
import 'package:snapaction/core/services/settings_repository.dart';
import 'package:snapaction/features/reminders/application/reminder_defaults.dart';

import '../helpers/test_app.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  test('defaults to 9:00 when nothing is stored', () async {
    final settings = await SettingsRepository.load(db);
    expect(defaultReminderTime(settings), const TimeOfDay(hour: 9, minute: 0));
  });

  test('keeps minutes, so 8:30 stays 8:30 after a reload', () async {
    final settings = await SettingsRepository.load(db);
    await saveDefaultReminderTime(
      settings,
      const TimeOfDay(hour: 8, minute: 30),
    );
    final reloaded = await SettingsRepository.load(db);
    expect(
      defaultReminderTime(reloaded),
      const TimeOfDay(hour: 8, minute: 30),
    );
    // The hour stays in the original key for older readers.
    expect(reloaded.getInt(SettingsKeys.defaultReminderHour, fallback: 0), 8);
  });

  test('an hour stored by an older version reads as that hour', () async {
    final settings = await SettingsRepository.load(db);
    await settings.setInt(SettingsKeys.defaultReminderHour, 7);
    expect(defaultReminderTime(settings), const TimeOfDay(hour: 7, minute: 0));
  });
}
