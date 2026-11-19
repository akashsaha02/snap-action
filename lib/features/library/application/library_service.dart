import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/repositories/screenshot_repository.dart';
import '../../../services/file_storage/file_storage_service.dart';
import '../../../services/search/search_indexer.dart';

typedef CancelNotifications = Future<void> Function(List<int> notificationIds);

/// Library-wide operations that span the database, the search index and the
/// private file store.
class LibraryService {
  LibraryService({
    required this._db,
    required this._storage,
    required this._indexer,
    this.cancelNotifications,
  });

  final AppDatabase _db;
  final FileStorageService _storage;
  final SearchIndexer _indexer;
  CancelNotifications? cancelNotifications;

  /// Deletes screenshots and their app-private copies. Gallery originals are
  /// never touched: only files inside the app's own directories are removed.
  /// Reminders created from these screenshots are cancelled.
  Future<int> delete(Iterable<int> screenshotIds) async {
    final ids = screenshotIds.toSet().toList();
    if (ids.isEmpty) return 0;
    final paths = await ScreenshotRepository(_db).filePaths(ids);

    final reminders =
        await (_db.select(_db.reminders)..where(
              (r) =>
                  r.screenshotId.isIn(ids) &
                  r.status.equalsValue(ReminderStatus.scheduled),
            ))
            .get();
    if (reminders.isNotEmpty) {
      await cancelNotifications?.call([
        for (final r in reminders) r.notificationId,
      ]);
    }

    final deleted = await _db.transaction(() async {
      await (_db.update(
        _db.reminders,
      )..where((r) => r.screenshotId.isIn(ids))).write(
        RemindersCompanion(
          status: const Value(ReminderStatus.cancelled),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return (_db.delete(_db.screenshots)..where((s) => s.id.isIn(ids))).go();
    });
    await _indexer.remove(ids);
    await _storage.deleteFiles(paths);
    return deleted;
  }
}
