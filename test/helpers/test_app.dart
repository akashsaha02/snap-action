import 'dart:io';
import 'dart:ui' show Size;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart' show SizedBox;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:snapaction/app/app.dart';
import 'package:snapaction/app/bootstrap.dart';
import 'package:snapaction/app/providers.dart';
import 'package:snapaction/core/database/app_database.dart';
import 'package:snapaction/core/services/settings_repository.dart';
import 'package:snapaction/services/file_storage/file_storage_service.dart';
import 'package:snapaction/services/notifications/notification_service.dart';
import 'package:snapaction/services/ocr/ocr_service.dart';
import 'package:snapaction/services/platform/platform_service.dart';

/// Platform channel stand-in: no pending shares, external intents succeed.
class FakePlatformService extends PlatformService {
  final calendarEvents = <Map<String, Object?>>[];
  final wifiNetworks = <Map<String, String?>>[];

  /// Set to false to simulate Android 10 or an invalid passphrase.
  bool wifiSupported = true;

  @override
  Future<List<SharedFile>> takePendingShares() async => const [];

  @override
  Future<bool> insertCalendarEvent({
    required String title,
    DateTime? begin,
    DateTime? end,
    bool allDay = false,
    String? description,
    String? location,
  }) async {
    calendarEvents.add({
      'title': title,
      'begin': begin,
      'location': location,
      'description': description,
    });
    return true;
  }

  @override
  Future<bool> addWifiNetwork({required String ssid, String? password}) async {
    if (!wifiSupported) return false;
    wifiNetworks.add({'ssid': ssid, 'password': password});
    return true;
  }

  @override
  Future<bool> openWifiSettings() async => true;

  @override
  Future<bool> insertContact({
    String? name,
    String? phone,
    String? email,
  }) async => true;
}

AppDatabase createTestDatabase() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

Future<AppServices> createTestServices({
  AppDatabase? database,
  Map<String, String> settings = const {},
}) async {
  final db = database ?? createTestDatabase();
  final repo = await SettingsRepository.load(db);
  for (final e in settings.entries) {
    await repo.setString(e.key, e.value);
  }
  final root = await Directory.systemTemp.createTemp('snapaction_test');
  final storage = FileStorageService(root);
  await storage.ensureDirectories();
  return AppServices(database: db, settings: repo, storage: storage);
}

/// OCR stand-in for host tests, where ML Kit is unavailable.
class FakeOcrService implements OcrService {
  FakeOcrService([this.text = '']);

  final String text;

  @override
  Future<OcrOutput> recognize(String imagePath) async => OcrOutput(
    text: text,
    blocksJson: '[]',
    recognizerName: 'fake',
    recognizerVersion: '0',
  );

  @override
  Future<void> dispose() async {}
}

/// Records scheduled notifications instead of talking to the OS.
class FakeNotificationService implements NotificationService {
  FakeNotificationService({this.enabled = true, this.grant = true});

  bool enabled;
  bool grant;
  final scheduled =
      <int, ({String title, DateTime at, String route, RepeatRule repeat})>{};
  String? pendingLaunchRoute;
  void Function(String route)? _onOpen;

  /// Simulates the user tapping a notification.
  void tap(String route) => _onOpen?.call(route);

  @override
  String get timezone => 'Europe/Berlin';

  @override
  Future<void> initialize({
    required void Function(String route) onOpen,
  }) async => _onOpen = onOpen;

  @override
  Future<String?> launchRoute() async => pendingLaunchRoute;

  @override
  Future<bool> areEnabled() async => enabled;

  @override
  Future<bool> requestPermission() async => enabled = grant;

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required DateTime at,
    required String route,
    String? body,
    RepeatRule repeat = RepeatRule.none,
  }) async {
    scheduled[id] = (title: title, at: at, route: route, repeat: repeat);
  }

  @override
  Future<void> cancel(int id) async => scheduled.remove(id);

  @override
  Future<void> cancelAll() async => scheduled.clear();
}

/// Pumps the full app with an in-memory database.
Future<AppServices> pumpTestApp(
  WidgetTester tester, {
  bool onboarded = true,
  FakeNotificationService? notifications,
  List<Override> overrides = const [],
  Map<String, String> settings = const {},
  Future<void> Function(AppDatabase db)? seed,
}) async {
  // A typical phone screen (360 x 780 logical pixels).
  tester.view
    ..physicalSize = const Size(1080, 2340)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  // Seeding must happen before the app runs: once its stream queries are
  // active in the fake-async zone, real-zone writes can wait on the
  // database lock forever.
  final services = await tester.runAsync(() async {
    final s = await createTestServices(
      settings: {
        if (onboarded) SettingsKeys.onboardingCompleted: 'true',
        ...settings,
      },
    );
    await seed?.call(s.database);
    return s;
  });
  addTearDown(() async {
    // Unmount first so stream queries release the database lock; otherwise
    // closing can wait forever after a failed expectation.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await services!.database.close();
  });
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        appBootstrapProvider.overrideWith((ref) async => services!),
        ocrServiceProvider.overrideWithValue(FakeOcrService()),
        platformServiceProvider.overrideWithValue(FakePlatformService()),
        notificationServiceProvider.overrideWithValue(
          notifications ?? FakeNotificationService(),
        ),
        ...overrides,
      ],
      child: const MindtiqApp(),
    ),
  );
  await tester.pumpAndSettle();
  return services!;
}
