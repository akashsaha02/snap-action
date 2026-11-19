import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/database/app_database.dart';
import '../core/services/settings_repository.dart';
import '../features/backup/application/backup_service.dart';
import '../services/file_storage/file_storage_service.dart';

/// Services that must exist before any feature screen is shown.
class AppServices {
  const AppServices({
    required this.database,
    required this.settings,
    required this.storage,
  });

  final AppDatabase database;
  final SettingsRepository settings;
  final FileStorageService storage;
}

/// Opens the database and loads settings. Overridden in tests with an
/// in-memory database.
final appBootstrapProvider = FutureProvider<AppServices>((ref) async {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  try {
    final settings = await SettingsRepository.load(db);
    final storage = await FileStorageService.create();
    await storage.clearStaging();
    await BackupService.recoverInterruptedRestore(db, storage);
    return AppServices(database: db, settings: settings, storage: storage);
  } catch (error, stack) {
    // The splash screen shows a generic message; keep the cause in the
    // device log (no data leaves the device).
    debugPrint('SnapAction startup failed: $error\n$stack');
    rethrow;
  }
});

final fileStorageProvider = Provider<FileStorageService>(
  (ref) => ref.watch(appBootstrapProvider).requireValue.storage,
);

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => ref.watch(appBootstrapProvider).requireValue.database,
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => ref.watch(appBootstrapProvider).requireValue.settings,
);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final services = ref.watch(appBootstrapProvider).value;
    final stored = services?.settings.getString(SettingsKeys.themeMode);
    return ThemeMode.values.firstWhere(
      (m) => m.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref
        .read(settingsRepositoryProvider)
        .setString(SettingsKeys.themeMode, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class OnboardingController extends Notifier<bool> {
  @override
  bool build() {
    final services = ref.watch(appBootstrapProvider).value;
    return services?.settings.getBool(SettingsKeys.onboardingCompleted) ??
        false;
  }

  Future<void> complete() async {
    await ref
        .read(settingsRepositoryProvider)
        .setBool(SettingsKeys.onboardingCompleted, value: true);
    state = true;
  }
}

final onboardingCompletedProvider =
    NotifierProvider<OnboardingController, bool>(OnboardingController.new);
