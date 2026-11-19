import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snapaction/core/database/app_database.dart';
import 'package:snapaction/features/dashboard/presentation/home_screen.dart';
import 'package:snapaction/features/library/presentation/library_screen.dart';
import 'package:snapaction/features/reminders/application/reminder_service.dart';
import 'package:snapaction/features/screenshot_details/presentation/screenshot_details_screen.dart';
import 'package:snapaction/features/screenshot_import/application/import_controller.dart';
import 'package:snapaction/features/screenshot_import/application/import_service.dart';
import 'package:snapaction/features/screenshot_import/presentation/import_feedback.dart';

import '../helpers/test_app.dart';

Future<int> _seedScreenshot(
  AppDatabase db,
  String title, {
  ProcessingStatus status = ProcessingStatus.completed,
}) => db
    .into(db.screenshots)
    .insert(
      ScreenshotsCompanion.insert(
        localFilePath: '/missing/${title.hashCode}.png',
        contentHash: 'hash-$title',
        title: Value(title),
        importedAt: DateTime(2026, 5, 1),
        source: ScreenshotSource.picker,
        processingStatus: status,
        fileSize: 1,
      ),
    );

String _iso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

Future<void> _seedDate(
  AppDatabase db,
  int shot,
  DateTime day, {
  EntityType type = EntityType.date,
  ValidationStatus status = ValidationStatus.valid,
}) => db
    .into(db.extractedEntities)
    .insert(
      ExtractedEntitiesCompanion.insert(
        screenshotId: shot,
        entityType: type,
        rawValue: _iso(day),
        normalizedValue: Value(_iso(day)),
        validationStatus: status,
      ),
    );

class _RunningImport extends ImportController {
  @override
  ImportState build() => const ImportState(running: true, done: 1, total: 3);
}

class _ScriptedImport extends ImportController {
  void finish(ImportResult result) =>
      state = ImportState(result: result, source: ScreenshotSource.share);
}

void main() {
  testWidgets('Coming up lists the next dated items and opens them', (
    tester,
  ) async {
    final today = DateTime.now();
    DateTime inDays(int n) => DateTime(today.year, today.month, today.day + n);
    final notifications = FakeNotificationService();
    await pumpTestApp(
      tester,
      notifications: notifications,
      seed: (db) async {
        final assignment = await _seedScreenshot(db, 'Assignment brief');
        await _seedDate(db, assignment, inDays(7), type: EntityType.deadline);
        await _seedDate(db, assignment, inDays(7));
        final flight = await _seedScreenshot(db, 'Flight to Lisbon');
        await _seedDate(db, flight, inDays(14));
        final old = await _seedScreenshot(db, 'Old receipt');
        await _seedDate(db, old, inDays(-3));
        final far = await _seedScreenshot(db, 'Far away event');
        await _seedDate(db, far, inDays(90));
        final wrong = await _seedScreenshot(db, 'Rejected date');
        await _seedDate(
          db,
          wrong,
          inDays(2),
          status: ValidationStatus.rejected,
        );
        await ReminderService(db: db, notifications: notifications).create(
          ReminderDraft(
            title: 'Pay rent',
            scheduledAt: DateTime.now().add(const Duration(days: 3)),
          ),
        );
      },
    );

    final section = find.byKey(const Key('home_coming_up'));
    await tester.scrollUntilVisible(
      section,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Coming up'), findsOneWidget);
    Finder inSection(String text) =>
        find.descendant(of: section, matching: find.text(text));
    expect(inSection('Pay rent'), findsOneWidget);
    expect(inSection('Assignment brief'), findsOneWidget);
    expect(inSection('Flight to Lisbon'), findsOneWidget);
    expect(inSection('Old receipt'), findsNothing);
    expect(inSection('Far away event'), findsNothing);
    expect(inSection('Rejected date'), findsNothing);
    expect(
      find.descendant(of: section, matching: find.textContaining('Deadline')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp(r'^Deadline: Assignment brief, ')),
      findsOneWidget,
    );

    // Ordered by date: reminder (3 days), deadline (7), flight (14).
    final y = [
      for (final t in ['Pay rent', 'Assignment brief', 'Flight to Lisbon'])
        tester.getTopLeft(inSection(t)).dy,
    ];
    expect(y[0] < y[1] && y[1] < y[2], isTrue);

    await tester.tap(inSection('Flight to Lisbon'));
    await tester.pumpAndSettle();
    expect(find.byType(ScreenshotDetailsScreen), findsOneWidget);
  });

  testWidgets('home lays out in dark mode at 1.3x text', (tester) async {
    tester.platformDispatcher
      ..textScaleFactorTestValue = 1.3
      ..platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    final today = DateTime.now();
    await pumpTestApp(
      tester,
      seed: (db) async {
        final shot = await _seedScreenshot(
          db,
          'A very long screenshot title that needs to be shortened somewhere',
        );
        await _seedDate(
          db,
          shot,
          DateTime(today.year, today.month, today.day + 2),
          type: EntityType.deadline,
        );
        await _seedScreenshot(db, 'Failed', status: ProcessingStatus.failed);
      },
    );
    expect(
      Theme.of(tester.element(find.byType(HomeScreen))).brightness,
      Brightness.dark,
    );
    expect(find.byKey(const Key('home_count_failed')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Recent'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('home_coming_up')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Coming up is hidden without dated items', (tester) async {
    await pumpTestApp(
      tester,
      seed: (db) async => _seedScreenshot(db, 'Plain screenshot'),
    );
    expect(find.byKey(const Key('home_coming_up')), findsNothing);
    expect(find.text('Coming up'), findsNothing);
    expect(find.text('Recent'), findsOneWidget);
  });

  testWidgets('count strip shows processing only when non-zero', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      seed: (db) async {
        await _seedScreenshot(db, 'Done');
        await _seedScreenshot(db, 'Queued', status: ProcessingStatus.pending);
      },
    );
    expect(find.byKey(const Key('home_count_review')), findsOneWidget);
    expect(find.byKey(const Key('home_count_processing')), findsOneWidget);
    expect(find.byKey(const Key('home_count_failed')), findsNothing);
    expect(find.bySemanticsLabel('1 processing'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home_count_review')));
    await tester.pumpAndSettle();
    expect(find.byType(LibraryScreen), findsOneWidget);
  });

  testWidgets('import progress stays visible on pushed screens', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      overrides: [importControllerProvider.overrideWith(_RunningImport.new)],
      seed: (db) async => _seedScreenshot(db, 'Done'),
    );
    // Inline banner on the shell.
    expect(find.text('Importing 1 of 3…'), findsOneWidget);
    expect(find.byKey(const Key('floating_import_banner')), findsNothing);

    // The library shows an endless spinner while importing, so the route
    // transition is pumped explicitly instead of settling.
    Future<void> settleRoute() async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();
    }

    await tester.tap(find.byKey(const Key('home_count_review')));
    await settleRoute();
    expect(find.byType(LibraryScreen), findsOneWidget);
    expect(find.byKey(const Key('floating_import_banner')), findsOneWidget);
    expect(find.text('Importing 1 of 3…'), findsOneWidget);

    await tester.pageBack();
    await settleRoute();
    expect(find.byKey(const Key('floating_import_banner')), findsNothing);
    expect(find.text('Importing 1 of 3…'), findsOneWidget);
  });

  testWidgets('results arriving while the sheet is open are merged', (
    tester,
  ) async {
    late _ScriptedImport controller;
    await pumpTestApp(
      tester,
      overrides: [
        importControllerProvider.overrideWith(
          () => controller = _ScriptedImport(),
        ),
      ],
      seed: (db) async => _seedScreenshot(db, 'Done'),
    );
    for (var i = 0; i < 3; i++) {
      controller.finish(
        ImportResult(
          failures: [ImportFailure(name: 'f$i.pdf', reason: 'Not an image.')],
        ),
      );
      await tester.pumpAndSettle();
    }
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Import failed'), findsOneWidget);
    expect(find.text('3 files: Not an image.'), findsOneWidget);

    // One back press closes it.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  group('import result summary', () {
    Future<void> pumpSummary(WidgetTester tester, ImportResult result) =>
        tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImportResultSummary(result: result, onOpen: (_) {}),
            ),
          ),
        );

    testWidgets('nothing imported is not shown as a success', (tester) async {
      await pumpSummary(
        tester,
        const ImportResult(
          failures: [
            ImportFailure(name: 'a.pdf', reason: 'Not an image.'),
            ImportFailure(name: 'b.pdf', reason: 'Not an image.'),
            ImportFailure(name: 'c.png', reason: 'Too large.'),
          ],
        ),
      );
      expect(find.text('Import failed'), findsOneWidget);
      expect(find.text('No screenshots imported'), findsOneWidget);
      expect(find.text('0 screenshots imported'), findsNothing);
      expect(find.byIcon(Icons.check_circle_outline), findsNothing);
      expect(find.text('2 files: Not an image.'), findsOneWidget);
      expect(find.text('c.png: Too large.'), findsOneWidget);
      expect(find.text('Review'), findsNothing);
    });

    testWidgets('only duplicates reads as nothing new', (tester) async {
      await pumpSummary(
        tester,
        const ImportResult(
          duplicates: [DuplicateHit(name: 'x.png', existingId: 4)],
        ),
      );
      expect(find.text('Nothing new to import'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsNothing);
      expect(find.text('Open existing'), findsOneWidget);
    });

    testWidgets('a partial import keeps the success row', (tester) async {
      await pumpSummary(
        tester,
        const ImportResult(
          importedIds: [1, 2],
          failures: [ImportFailure(name: 'a.pdf', reason: 'Not an image.')],
        ),
      );
      expect(find.text('Import finished'), findsOneWidget);
      expect(find.text('2 screenshots imported'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });
  });
}
