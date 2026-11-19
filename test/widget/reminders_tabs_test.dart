import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snapaction/core/database/app_database.dart';
import 'package:snapaction/features/reminders/application/reminder_defaults.dart';
import 'package:snapaction/features/reminders/application/reminder_service.dart';
import 'package:snapaction/features/reminders/presentation/reminders_screen.dart';

import '../helpers/test_app.dart';

Future<void> _tapTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}

Future<void> _seedOverdueAndUpcoming(
  AppDatabase db,
  FakeNotificationService notifications,
) async {
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
}

ChoiceChip _chip(WidgetTester tester, String prefix) => tester.widget(
  find.ancestor(
    of: find.textContaining(prefix),
    matching: find.byType(ChoiceChip),
  ),
);

void main() {
  test('the default tab is the first non-empty one, overdue first', () {
    ReminderItem item(DateTime at) => ReminderItem(
      reminder: ReminderRow(
        id: 1,
        title: 't',
        scheduledAt: at,
        timezone: 'UTC',
        notificationId: 1,
        notify: true,
        repeatRule: RepeatRule.none,
        status: ReminderStatus.scheduled,
        createdAt: at,
        updatedAt: at,
      ),
    );
    final now = DateTime(2026, 6, 1, 12);
    final overdue = item(now.subtract(const Duration(hours: 1)));
    final today = item(now.add(const Duration(hours: 1)));
    final later = item(now.add(const Duration(days: 3)));

    expect(
      defaultReminderTab(groupReminders([today, overdue, later], now)),
      ReminderTab.overdue,
    );
    expect(
      defaultReminderTab(groupReminders([later, today], now)),
      ReminderTab.today,
    );
    expect(
      defaultReminderTab(groupReminders([later], now)),
      ReminderTab.upcoming,
    );
    expect(defaultReminderTab(groupReminders([], now)), ReminderTab.today);
  });

  testWidgets('reminders open on Overdue when something is overdue', (
    tester,
  ) async {
    final notifications = FakeNotificationService();
    await pumpTestApp(
      tester,
      notifications: notifications,
      seed: (db) => _seedOverdueAndUpcoming(db, notifications),
    );
    await _tapTab(tester, 'Reminders');

    expect(_chip(tester, 'Overdue').selected, isTrue);
    expect(find.text('Submit essay'), findsOneWidget);
    expect(find.text('Nothing due today'), findsNothing);
  });

  testWidgets('a tab in the route selects that tab, even when already open', (
    tester,
  ) async {
    final notifications = FakeNotificationService();
    await pumpTestApp(
      tester,
      notifications: notifications,
      seed: (db) => _seedOverdueAndUpcoming(db, notifications),
    );
    final router = GoRouter.of(tester.element(find.byType(NavigationBar)));

    router.go(RemindersScreen.location(tab: ReminderTab.upcoming));
    await tester.pumpAndSettle();
    expect(_chip(tester, 'Upcoming').selected, isTrue);
    expect(find.text('Book flights'), findsOneWidget);

    await tester.tap(find.textContaining('Today ·'));
    await tester.pumpAndSettle();
    expect(_chip(tester, 'Today').selected, isTrue);
    await _tapTab(tester, 'Home');

    router.go(RemindersScreen.location(tab: ReminderTab.overdue));
    await tester.pumpAndSettle();
    expect(_chip(tester, 'Overdue').selected, isTrue);
    expect(find.text('Submit essay'), findsOneWidget);
  });

  testWidgets('the editor shows the minute-precise default reminder time', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      settings: {'default_reminder_hour': '8', defaultReminderMinuteKey: '30'},
    );
    await _tapTab(tester, 'Reminders');
    await tester.tap(find.byKey(const Key('new_reminder')));
    await tester.pumpAndSettle();

    expect(find.text('8:30 AM (default)'), findsOneWidget);
    expect(find.text('9:00 AM (default)'), findsNothing);
  });

  testWidgets('an overdue reminder can be renamed without rescheduling', (
    tester,
  ) async {
    final notifications = FakeNotificationService();
    final services = await pumpTestApp(
      tester,
      notifications: notifications,
      seed: (db) => _seedOverdueAndUpcoming(db, notifications),
    );
    await _tapTab(tester, 'Reminders');
    final before = await tester.runAsync(
      () => services.database.select(services.database.reminders).get(),
    );
    final overdue = before!.firstWhere((r) => r.title == 'Submit essay');

    await tester.tap(find.text('Submit essay'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('reminder_title')),
      'Submit final essay',
    );
    await tester.tap(find.byKey(const Key('reminder_save')));
    await tester.pumpAndSettle();

    expect(find.text('Please choose a time in the future.'), findsNothing);
    expect(find.text('Reminder updated'), findsOneWidget);
    expect(find.text('Submit final essay'), findsOneWidget);
    final after = await tester.runAsync(
      () => (services.database.select(
        services.database.reminders,
      )..where((r) => r.id.equals(overdue.id))).getSingle(),
    );
    expect(after!.title, 'Submit final essay');
    expect(after.scheduledAt, overdue.scheduledAt);
    expect(after.status, ReminderStatus.scheduled);
  });
}
