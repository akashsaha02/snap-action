import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snapaction/app/routes.dart';
import 'package:snapaction/core/database/app_database.dart';

import '../helpers/test_app.dart';

Future<int> _seedScreenshot(
  AppDatabase db, {
  ProcessingStatus status = ProcessingStatus.completed,
}) => db
    .into(db.screenshots)
    .insert(
      ScreenshotsCompanion.insert(
        localFilePath: '/missing/details.png',
        contentHash: 'hash-details',
        title: const Value('Invoice'),
        importedAt: DateTime(2026, 5, 1),
        source: ScreenshotSource.picker,
        processingStatus: status,
        fileSize: 1,
      ),
    );

Future<int> _seedEntity(
  AppDatabase db,
  int shot,
  EntityType type,
  String value, {
  ValidationStatus status = ValidationStatus.valid,
}) => db
    .into(db.extractedEntities)
    .insert(
      ExtractedEntitiesCompanion.insert(
        screenshotId: shot,
        entityType: type,
        rawValue: value,
        normalizedValue: Value(value),
        validationStatus: status,
      ),
    );

Future<void> _openDetails(
  WidgetTester tester,
  FakeNotificationService notifications,
  int id,
) async {
  notifications.tap(Routes.screenshot(id));
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('confirming a detected date removes "Please check"', (
    tester,
  ) async {
    final notifications = FakeNotificationService();
    var shot = 0;
    var date = 0;
    await pumpTestApp(
      tester,
      notifications: notifications,
      seed: (db) async {
        shot = await _seedScreenshot(db);
        date = await _seedEntity(
          db,
          shot,
          EntityType.date,
          '2026-12-01',
          status: ValidationStatus.needsConfirmation,
        );
        await _seedEntity(
          db,
          shot,
          EntityType.productName,
          'Wrong product',
          status: ValidationStatus.rejected,
        );
      },
    );
    await _openDetails(tester, notifications, shot);

    await _scrollTo(tester, find.byKey(ValueKey('confirm_entity_$date')));
    expect(find.text('Please check'), findsOneWidget);
    expect(find.text('Wrong product'), findsNothing);

    await tester.tap(find.byKey(ValueKey('confirm_entity_$date')));
    await tester.pumpAndSettle();
    expect(find.text('Please check'), findsNothing);
    expect(find.byKey(ValueKey('confirm_entity_$date')), findsNothing);
    expect(find.byKey(ValueKey('entity_$date')), findsOneWidget);
  });

  testWidgets('a value marked "Not correct" disappears', (tester) async {
    final notifications = FakeNotificationService();
    var shot = 0;
    var amount = 0;
    await pumpTestApp(
      tester,
      notifications: notifications,
      seed: (db) async {
        shot = await _seedScreenshot(db);
        amount = await _seedEntity(
          db,
          shot,
          EntityType.amount,
          'USD 12.00',
          status: ValidationStatus.needsConfirmation,
        );
        await _seedEntity(db, shot, EntityType.url, 'https://example.com');
      },
    );
    await _openDetails(tester, notifications, shot);

    await _scrollTo(tester, find.byKey(ValueKey('reject_entity_$amount')));
    await tester.tap(find.byKey(ValueKey('reject_entity_$amount')));
    await tester.pumpAndSettle();
    expect(find.byKey(ValueKey('entity_$amount')), findsNothing);
    expect(find.text('https://example.com'), findsOneWidget);
  });

  testWidgets('long lists of details offer "Show all"', (tester) async {
    final notifications = FakeNotificationService();
    var shot = 0;
    await pumpTestApp(
      tester,
      notifications: notifications,
      seed: (db) async {
        shot = await _seedScreenshot(db);
        for (var i = 0; i < 30; i++) {
          await _seedEntity(db, shot, EntityType.orderReference, 'REF$i');
        }
      },
    );
    await _openDetails(tester, notifications, shot);

    await _scrollTo(tester, find.byKey(const Key('entities_show_all')));
    expect(find.text('Show all 30'), findsOneWidget);
    await tester.tap(find.text('Show all 30'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('entities_show_all')), findsNothing);
    await _scrollTo(tester, find.text('REF29'));
    expect(find.text('REF29'), findsOneWidget);
  });

  testWidgets('a long processing error is clamped and Retry stays visible', (
    tester,
  ) async {
    final notifications = FakeNotificationService();
    var shot = 0;
    final message = List.filled(25, 'The text could not be read.').join(' ');
    await pumpTestApp(
      tester,
      notifications: notifications,
      seed: (db) async {
        shot = await _seedScreenshot(db, status: ProcessingStatus.failed);
        await db
            .into(db.processingJobs)
            .insert(
              ProcessingJobsCompanion.insert(
                screenshotId: shot,
                jobType: JobType.process,
                status: JobStatus.failed,
                errorMessage: Value(message.substring(0, 199)),
              ),
            );
      },
    );
    await _openDetails(tester, notifications, shot);

    await _scrollTo(tester, find.byKey(const Key('retry_processing')));
    final text = tester.widget<Text>(
      find
          .descendant(
            of: find.byKey(const Key('processing_failed')),
            matching: find.byType(Text),
          )
          .first,
    );
    expect(text.maxLines, 4);
    expect(find.byKey(const Key('retry_processing')), findsOneWidget);
  });
}
