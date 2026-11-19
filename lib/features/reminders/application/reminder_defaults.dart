import 'package:material_ui/material_ui.dart';

import '../../../core/services/settings_repository.dart';

/// Minute of the default reminder time. The hour keeps its original key,
/// [SettingsKeys.defaultReminderHour], so settings saved by older versions
/// (hour only) still read as that hour on the dot.
const defaultReminderMinuteKey = 'default_reminder_minute';

/// The time used when a reminder has a date but no time.
TimeOfDay defaultReminderTime(SettingsRepository settings) => TimeOfDay(
  hour: settings
      .getInt(SettingsKeys.defaultReminderHour, fallback: 9)
      .clamp(0, 23),
  minute: settings.getInt(defaultReminderMinuteKey, fallback: 0).clamp(0, 59),
);

Future<void> saveDefaultReminderTime(
  SettingsRepository settings,
  TimeOfDay time,
) async {
  await settings.setInt(SettingsKeys.defaultReminderHour, time.hour);
  await settings.setInt(defaultReminderMinuteKey, time.minute);
}
