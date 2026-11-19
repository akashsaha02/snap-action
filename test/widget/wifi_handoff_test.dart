import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snapaction/app/bootstrap.dart';
import 'package:snapaction/app/providers.dart';
import 'package:snapaction/core/database/app_database.dart';
import 'package:snapaction/features/actions/application/action_executor.dart';

import '../helpers/test_app.dart';

/// Runs the Wi-Fi suggestion through [ActionExecutor] and picks [option].
Future<void> runWifiAction(
  WidgetTester tester,
  FakePlatformService platform,
  String option,
) async {
  final services = (await tester.runAsync(createTestServices))!;
  final db = services.database;
  final action = (await tester.runAsync(() async {
    final shot = await db
        .into(db.screenshots)
        .insert(
          ScreenshotsCompanion.insert(
            localFilePath: '/wifi.png',
            contentHash: 'wifi',
            importedAt: DateTime(2026, 11, 18),
            source: ScreenshotSource.picker,
            processingStatus: ProcessingStatus.completed,
            fileSize: 1,
          ),
        );
    final id = await db
        .into(db.suggestedActions)
        .insert(
          SuggestedActionsCompanion.insert(
            screenshotId: shot,
            actionType: ActionType.copyWifi,
            title: 'Wi-Fi Guest Lounge',
            payloadJson: jsonEncode({
              'ssid': 'Guest Lounge',
              'password': 'hunter22',
            }),
            status: ActionStatus.suggested,
          ),
        );
    return (db.select(
      db.suggestedActions,
    )..where((a) => a.id.equals(id))).getSingle();
  }))!;
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(db.close);
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appBootstrapProvider.overrideWith((ref) async => services),
        platformServiceProvider.overrideWithValue(platform),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) {
              ref.watch(appBootstrapProvider);
              return TextButton(
                onPressed: () => ActionExecutor.run(context, ref, action),
                child: const Text('run'),
              );
            },
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('run'));
  await tester.pumpAndSettle();
  expect(find.text('Wi-Fi: Guest Lounge'), findsOneWidget);
  await tester.tap(find.text(option));
  await tester.pumpAndSettle();
}

void main() {
  String? clipboard;
  setUp(() {
    clipboard = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboard = (call.arguments as Map)['text'] as String?;
          }
          return null;
        });
  });

  testWidgets('Connect hands the network to the system sheet', (tester) async {
    final platform = FakePlatformService();
    await runWifiAction(tester, platform, 'Connect');
    expect(platform.wifiNetworks, [
      {'ssid': 'Guest Lounge', 'password': 'hunter22'},
    ]);
    expect(clipboard, isNull);
  });

  testWidgets('without system support the password is copied instead', (
    tester,
  ) async {
    final platform = FakePlatformService()..wifiSupported = false;
    await runWifiAction(tester, platform, 'Connect');
    expect(platform.wifiNetworks, isEmpty);
    expect(clipboard, 'hunter22');
    expect(find.textContaining('Password copied'), findsOneWidget);
  });
}
