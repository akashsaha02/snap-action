import 'package:drift/drift.dart';

import '../database/app_database.dart';

abstract final class SettingsKeys {
  static const onboardingCompleted = 'onboarding_completed';
  static const themeMode = 'theme_mode';
  static const ocrEnabled = 'ocr_enabled';
  static const ocrConcurrency = 'ocr_concurrency';
  static const dateOrder = 'date_order';
  static const notificationsEnabled = 'notifications_enabled';
  static const hideSensitivePreviews = 'hide_sensitive_previews';
  static const appLockEnabled = 'app_lock_enabled';
  static const secureWindow = 'secure_window';
  static const similarDetection = 'similar_detection';
  static const inboxViewMode = 'inbox_view_mode';
  static const defaultReminderHour = 'default_reminder_hour';
}

/// Key-value settings persisted in `app_settings` with an in-memory cache so
/// reads are synchronous after startup.
class SettingsRepository {
  SettingsRepository(this._db, Map<String, String> initial)
    : _cache = Map.of(initial);

  final AppDatabase _db;
  final Map<String, String> _cache;

  static Future<SettingsRepository> load(AppDatabase db) async {
    final rows = await db.select(db.appSettings).get();
    return SettingsRepository(db, {for (final r in rows) r.key: r.value});
  }

  String? getString(String key) => _cache[key];

  bool getBool(String key, {bool fallback = false}) {
    final v = _cache[key];
    if (v == null) return fallback;
    return v == 'true';
  }

  int getInt(String key, {required int fallback}) =>
      int.tryParse(_cache[key] ?? '') ?? fallback;

  Future<void> setString(String key, String value) async {
    _cache[key] = value;
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: key,
            value: value,
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> setBool(String key, {required bool value}) =>
      setString(key, value.toString());

  Future<void> setInt(String key, int value) =>
      setString(key, value.toString());

  Future<void> remove(String key) async {
    _cache.remove(key);
    await (_db.delete(_db.appSettings)..where((t) => t.key.equals(key))).go();
  }

  /// Removes every setting except [keep].
  Future<void> clearExcept(Set<String> keep) async {
    _cache.removeWhere((k, _) => !keep.contains(k));
    await (_db.delete(_db.appSettings)..where((t) => t.key.isNotIn(keep))).go();
  }

  void clearCache() => _cache.clear();
}
