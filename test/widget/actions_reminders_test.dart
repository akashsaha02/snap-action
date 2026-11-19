import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snapaction/app/routes.dart';
import 'package:snapaction/core/database/app_database.dart';
import 'package:snapaction/features/reminders/application/reminder_service.dart';
import 'package:snapaction/features/screenshot_details/presentation/screenshot_details_screen.dart';

import '../helpers/test_app.dart';

Future<int> _seedScreenshot(AppDatabase db, {String title = 'Boarding pass'}) =>
    db
        .into(db.screenshots)
        .insert(
          ScreenshotsCompanion.insert(
            localFilePath: '/missing/${title.hashCode}.png',
            contentHash: 'hash-$title',
            title: Value(title),
            importedAt: DateTime(2026, 5, 1),
            source: ScreenshotSource.picker,
            processingStatus: ProcessingStatus.completed,
            fileSize: 1,
          ),
        );

Future<int> _seedAction(
  AppDatabase db,
  int shot,
  ActionType type,
  String title,
  Map<String, Object?> payload,
) => db
    .into(db.suggestedActions)
    .insert(
      SuggestedActionsCompanion.insert(
        screenshotId: shot,
        actionType: type,
        title: title,
        payloadJson: jsonEncode(payload),
        status: ActionStatus.suggested,
      ),
    );

Future<void> _tapTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tapping a reminder notification opens its screenshot', (
    tester,
  ) async {
    final notifications = FakeNotificationService();
    var id = 0;
    await pumpTestApp(
      tester,
      notifications: notifications,
      seed: (db) async => id = await _seedScreenshot(db),
    );

    notifications.tap(Routes.screenshot(id));
    await tester.pumpAndSettle();

    expect(find.byType(ScreenshotDetailsScreen), findsOneWidget);
    expect(find.text('Boarding pass'), findsWidgets);
  });

  testWidgets('a notification that launched the app is opened after startup', (
    tester,
  ) async {
    final notifications = FakeNotificationService()
      ..pendingLaunchRoute = Routes.reminders;
    await pumpTestApp(tester, notifications: notifications);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Reminders'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('reminders are grouped and can be completed', (tester) async {
    final notifications = FakeNotificationService();
    await pumpTestApp(
      tester,
      notifications: notifications,
      seed: (db) async {
        final service = ReminderService(db: db, notifications: notifications);
        await service.create(
          ReminderDraft(
            title: 'Submit essay',
            scheduledAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        );
        await service.create(
          ReminderDraft(
            title: 'Book flights',
            scheduledAt: DateTime.now().add(const Duration(days: 3)),
          ),
        );
      },
    );

    await _tapTab(tester, 'Reminders');
    expect(find.text('Overdue · 1'), findsOneWidget);
    expect(find.text('Upcoming · 1'), findsOneWidget);

    await tester.ensureVisible(find.text('Overdue · 1'));
    await tester.tap(find.text('Overdue · 1'));
    await tester.pumpAndSettle();
    expect(find.text('Submit essay'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(find.text('Marked as done'), findsOneWidget);
    expect(find.text('Completed · 1'), findsOneWidget);
    expect(notifications.scheduled, hasLength(1));
  });

  testWidgets(
    'notification permission banner offers to turn notifications on',
    (tester) async {
      final notifications = FakeNotificationService(enabled: false);
      await pumpTestApp(tester, notifications: notifications);
      await _tapTab(tester, 'Reminders');
      expect(find.textContaining('Notifications are off'), findsOneWidget);
      await tester.tap(find.text('Turn on'));
      await tester.pumpAndSettle();
      expect(notifications.enabled, isTrue);
      expect(find.textContaining('Notifications are off'), findsNothing);
    },
  );

  testWidgets(
    'action center: accept needs confirmation, dismiss can be undone',
    (tester) async {
      await pumpTestApp(
        tester,
        seed: (db) async {
          final shot = await _seedScreenshot(db, title: 'Shop page');
          await _seedAction(
            db,
            shot,
            ActionType.openUrl,
            'Open shop.example.com',
            {'url': 'https://shop.example.com'},
          );
        },
      );
      expect(find.text('1 suggestion to review'), findsOneWidget);

      await tester.tap(find.byKey(const Key('action_center_card')));
      await tester.pumpAndSettle();
      expect(find.text('Open shop.example.com'), findsOneWidget);

      // Accepting shows the full address and does nothing when cancelled.
      await tester.tap(find.text('Open website'));
      await tester.pumpAndSettle();
      expect(find.textContaining('https://shop.example.com'), findsWidgets);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Open shop.example.com'), findsOneWidget);

      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();
      expect(find.text('Open shop.example.com'), findsNothing);
      expect(find.text('All caught up'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('Open shop.example.com'), findsOneWidget);
    },
  );

  testWidgets('a reminder suggestion without a year asks for the date', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      seed: (db) async {
        final shot = await _seedScreenshot(db, title: 'Concert poster');
        await _seedAction(
          db,
          shot,
          ActionType.createReminder,
          'Remind me on 15 Mar (confirm)',
          {'title': 'Concert', 'date': '--03-15', 'needsConfirmation': true},
        );
      },
    );

    await tester.tap(find.byKey(const Key('action_center_card')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create reminder'));
    await tester.pumpAndSettle();

    expect(find.textContaining('year is missing'), findsOneWidget);
    expect(find.text('Choose date'), findsOneWidget);
    await tester.tap(find.byKey(const Key('reminder_save')));
    await tester.pumpAndSettle();
    expect(find.text('Please choose a date.'), findsOneWidget);
    expect(find.byKey(const Key('reminder_title')), findsOneWidget);
  });

  testWidgets('wishlist items can be added with an exact price', (
    tester,
  ) async {
    await pumpTestApp(tester);
    await _tapTab(tester, 'Collections');
    await tester.tap(find.text('Wishlist'));
    await tester.pumpAndSettle();
    expect(find.text('Your wishlist is empty'), findsOneWidget);

    await tester.tap(find.byKey(const Key('wishlist_add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('wishlist_name')),
      'Headphones',
    );
    await tester.enterText(find.byKey(const Key('wishlist_price')), '49.99');
    await tester.enterText(find.widgetWithText(TextField, 'Currency'), 'eur');
    await tester.tap(find.byKey(const Key('wishlist_save')));
    await tester.pumpAndSettle();

    expect(find.text('Headphones'), findsOneWidget);
    expect(find.text('Still to buy: EUR 49.99'), findsOneWidget);
  });
}
