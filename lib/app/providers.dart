import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../core/models/screenshot_detail.dart';
import '../core/models/screenshot_summary.dart';
import '../core/repositories/category_repository.dart';
import '../core/repositories/organization_repository.dart';
import '../core/repositories/screenshot_repository.dart';
import '../core/repositories/search_repository.dart';
import '../core/services/settings_repository.dart';
import '../features/actions/application/action_repository.dart';
import '../features/backup/application/backup_service.dart';
import '../features/library/application/library_service.dart';
import '../features/reminders/application/reminder_service.dart';
import '../features/screenshot_import/application/import_service.dart';
import '../features/settings/application/data_management_service.dart';
import '../features/wishlist/application/wishlist_repository.dart';
import '../services/file_storage/file_storage_service.dart';
import '../services/notifications/notification_service.dart';
import '../services/ocr/ocr_service.dart';
import '../services/platform/platform_service.dart';
import '../services/processing/job_runner.dart';
import '../services/search/search_indexer.dart';
import 'bootstrap.dart';

final screenshotRepositoryProvider = Provider<ScreenshotRepository>(
  (ref) => ScreenshotRepository(ref.watch(appDatabaseProvider)),
);

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(ref.watch(appDatabaseProvider)),
);

final searchIndexerProvider = Provider<SearchIndexer>(
  (ref) => SearchIndexer(ref.watch(appDatabaseProvider)),
);

/// Overridden in host tests, where the ML Kit plugin is unavailable.
final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = MlKitOcrService();
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});

final platformServiceProvider = Provider<PlatformService>((ref) {
  final service = PlatformService();
  ref.onDispose(service.dispose);
  return service;
});

final jobRunnerProvider = Provider<JobRunner>((ref) {
  final runner = JobRunner(
    db: ref.watch(appDatabaseProvider),
    ocr: ref.watch(ocrServiceProvider),
    indexer: ref.watch(searchIndexerProvider),
    settings: ref.watch(settingsRepositoryProvider),
  );
  unawaited(runner.start());
  ref.onDispose(() => unawaited(runner.dispose()));
  return runner;
});

final importServiceProvider = Provider<ImportService>((ref) {
  final settings = ref.watch(settingsRepositoryProvider);
  return ImportService(
    db: ref.watch(appDatabaseProvider),
    storage: ref.watch(fileStorageProvider),
    indexer: ref.watch(searchIndexerProvider),
    detectSimilar: settings.getBool(
      SettingsKeys.similarDetection,
      fallback: true,
    ),
  );
});

final libraryServiceProvider = Provider<LibraryService>((ref) {
  final reminders = ref.watch(reminderServiceProvider);
  return LibraryService(
    db: ref.watch(appDatabaseProvider),
    storage: ref.watch(fileStorageProvider),
    indexer: ref.watch(searchIndexerProvider),
    cancelNotifications: reminders.cancelNotifications,
  );
});

/// Overridden in tests, where the notifications plugin is unavailable.
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => LocalNotificationService(),
);

final reminderServiceProvider = Provider<ReminderService>(
  (ref) => ReminderService(
    db: ref.watch(appDatabaseProvider),
    notifications: ref.watch(notificationServiceProvider),
  ),
);

final remindersProvider = StreamProvider.autoDispose
    .family<List<ReminderItem>, bool>(
      (ref, completed) =>
          ref.watch(reminderServiceProvider).watch(completed: completed),
    );

final notificationsEnabledProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.watch(notificationServiceProvider).areEnabled(),
);

final actionRepositoryProvider = Provider<ActionRepository>(
  (ref) => ActionRepository(ref.watch(appDatabaseProvider)),
);

final pendingActionsProvider = StreamProvider.autoDispose<List<ActionItem>>(
  (ref) => ref.watch(actionRepositoryProvider).watchPending(),
);

final needsConfirmationProvider =
    StreamProvider.autoDispose<List<ScreenshotSummary>>((ref) {
      final repo = ref.watch(screenshotRepositoryProvider);
      return ref
          .watch(actionRepositoryProvider)
          .watchNeedingConfirmation()
          .asyncMap(repo.summariesByIds);
    });

final backupServiceProvider = Provider<BackupService>((ref) {
  final storage = ref.watch(fileStorageProvider);
  return BackupService(
    db: ref.watch(appDatabaseProvider),
    storage: storage,
    indexer: ref.watch(searchIndexerProvider),
    exportDir: storage.exportsDir,
  );
});

final dataManagementServiceProvider = Provider<DataManagementService>(
  (ref) => DataManagementService(
    db: ref.watch(appDatabaseProvider),
    storage: ref.watch(fileStorageProvider),
    settings: ref.watch(settingsRepositoryProvider),
    notifications: ref.watch(notificationServiceProvider),
    indexer: ref.watch(searchIndexerProvider),
  ),
);

final storageUsageProvider = FutureProvider.autoDispose<StorageUsage>((ref) {
  ref.watch(libraryStatsProvider);
  return ref.watch(fileStorageProvider).usage();
});

final wishlistRepositoryProvider = Provider<WishlistRepository>(
  (ref) => WishlistRepository(ref.watch(appDatabaseProvider)),
);

final wishlistProvider = StreamProvider.autoDispose<List<WishlistEntry>>(
  (ref) => ref.watch(wishlistRepositoryProvider).watchAll(),
);

final screenshotsProvider = StreamProvider.autoDispose
    .family<List<ScreenshotSummary>, ScreenshotQuery>(
      (ref, query) =>
          ref.watch(screenshotRepositoryProvider).watchSummaries(query),
    );

/// Total number of screenshots matching a query regardless of its page
/// limit; with `failedOnly` only those whose processing failed. Callers
/// should pass the query with a fixed limit so paging does not change the
/// key.
final screenshotCountProvider = StreamProvider.autoDispose
    .family<int, ({ScreenshotQuery query, bool failedOnly})>(
      (ref, key) => ref
          .watch(screenshotRepositoryProvider)
          .watchCount(key.query, failedOnly: key.failedOnly),
    );

final libraryStatsProvider = StreamProvider.autoDispose<LibraryStats>(
  (ref) => ref.watch(screenshotRepositoryProvider).watchStats(),
);

final screenshotDetailProvider = StreamProvider.autoDispose
    .family<ScreenshotDetail?, int>(
      (ref, id) => ref.watch(screenshotRepositoryProvider).watchDetail(id),
    );

final categoriesProvider = StreamProvider<List<CategoryInfo>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchAll(),
);

final categoryCountsProvider = StreamProvider.autoDispose<List<CategoryCount>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchWithCounts(),
);

final organizationRepositoryProvider = Provider<OrganizationRepository>(
  (ref) => OrganizationRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(searchIndexerProvider),
  ),
);

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepository(ref.watch(appDatabaseProvider)),
);

final collectionsProvider = StreamProvider.autoDispose<List<CollectionSummary>>(
  (ref) => ref.watch(organizationRepositoryProvider).watchCollections(),
);

final collectionProvider = StreamProvider.autoDispose
    .family<CollectionRow?, int>(
      (ref, id) =>
          ref.watch(organizationRepositoryProvider).watchCollection(id),
    );

final tagsProvider = StreamProvider.autoDispose<List<TagCount>>(
  (ref) => ref.watch(organizationRepositoryProvider).watchTags(),
);

final searchHistoryProvider = StreamProvider.autoDispose<List<String>>(
  (ref) => ref.watch(searchRepositoryProvider).watchHistory(),
);

final searchResultsProvider = FutureProvider.autoDispose
    .family<SearchResults, SearchRequest>((ref, request) {
      // Re-run when screenshots change while results are shown.
      ref.watch(libraryStatsProvider);
      return ref.watch(searchRepositoryProvider).search(request);
    });
