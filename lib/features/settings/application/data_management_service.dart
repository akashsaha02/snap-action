import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/settings_repository.dart';
import '../../../services/file_storage/file_storage_service.dart';
import '../../../services/notifications/notification_service.dart';
import '../../../services/search/search_indexer.dart';

/// Local data deletion. Only SnapAction's own copies are removed; images in
/// the user's gallery are never touched.
class DataManagementService {
  DataManagementService({
    required this._db,
    required this._storage,
    required this._settings,
    required this._notifications,
    required this._indexer,
  });

  final AppDatabase _db;
  final FileStorageService _storage;
  final SettingsRepository _settings;
  final NotificationService _notifications;
  final SearchIndexer _indexer;

  Future<StorageUsage> usage() => _storage.usage();

  Future<void> clearSearchHistory() => _db.delete(_db.searchHistory).go();

  /// Deletes every screenshot copy, all metadata, reminders and their
  /// notifications, custom categories and settings. Theme and onboarding
  /// state are kept so the app does not start over from the welcome screens,
  /// and the app lock and hide-in-recents choices are kept so deleting data
  /// never lowers protection.
  Future<void> deleteAll() async {
    await _notifications.cancelAll();
    await _db.transaction(() async {
      for (final table in <TableInfo<Table, Object?>>[
        _db.processingJobs,
        _db.suggestedActions,
        _db.reminders,
        _db.wishlistItems,
        _db.notes,
        _db.screenshotTags,
        _db.tags,
        _db.collectionItems,
        _db.collections,
        _db.extractedEntities,
        _db.ocrResults,
        _db.screenshots,
        _db.searchHistory,
        _db.classificationRules,
      ]) {
        await _db.delete(table).go();
      }
      await (_db.delete(
        _db.categories,
      )..where((c) => c.isSystem.equals(false))).go();
    });
    await _indexer.rebuild();
    await _storage.deleteAll();
    await _settings.clearExcept({
      SettingsKeys.themeMode,
      SettingsKeys.onboardingCompleted,
      SettingsKeys.appLockEnabled,
      SettingsKeys.secureWindow,
    });
  }
}
