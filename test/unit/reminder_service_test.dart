import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show TimeOfDay;
import 'package:snapaction/app/routes.dart';
import 'package:snapaction/core/database/app_database.dart';
import 'package:snapaction/features/reminders/application/reminder_service.dart';
import 'package:snapaction/features/reminders/presentation/reminder_editor.dart';
import 'package:snapaction/features/reminders/presentation/reminders_screen.dart';

import '../helpers/test_app.dart';

void main() {
  late AppDatabase db;
  late FakeNotificationService notifications;
  late ReminderService service;
  var now = DateTime(2026, 5, 10, 12);

  setUp(() {
    now = DateTime(2026, 5, 10, 12);
    db = createTestDatabase();
    notifications = FakeNotificationService();
    service = ReminderService(
      db: db,
      notifications: notifications,
      clock: () => now,
    );
  });

  tearDown(() => db.close());

  Future<int> addScreenshot() => db
      .into(db.screenshots)
      .insert(
        ScreenshotsCompanion.insert(
          localFilePath: '/x.png',
          contentHash: 'h${DateTime.now().microsecondsSinceEpoch}',
          importedAt: now,
          source: ScreenshotSource.picker,
          processingStatus: ProcessingStatus.completed,
          fileSize: 1,
        ),
      );

  test(
    'create stores the reminder and schedules a deep-linked notification',
    () async {
      final shot = await addScreenshot();
      final id = await service.create(
        ReminderDraft(
          title: '  Pay rent ',
          scheduledAt: DateTime(2026, 5, 11, 9),
          screenshotId: shot,
        ),
      );
      final row = (await service.byId(id))!;
      expect(row.title, 'Pay rent');
      expect(row.status, ReminderStatus.scheduled);
      expect(row.timezone, 'Europe/Berlin');
      final n = notifications.scheduled[row.notificationId]!;
      expect(n.route, Routes.screenshot(shot));
      expect(n.at, DateTime(2026, 5, 11, 9));
    },
  );

  test('reminders without a screenshot link to the reminders tab', () async {
    final id = await service.create(
      ReminderDraft(title: 'Call mum', scheduledAt: DateTime(2026, 5, 11)),
    );
    final row = (await service.byId(id))!;
    expect(
      notifications.scheduled[row.notificationId]!.route,
      Routes.reminders,
    );
  });

  test('notification ids are unique and positive', () async {
    final ids = <int>{};
    for (var i = 0; i < 20; i++) {
      final id = await service.create(
        ReminderDraft(title: 'R$i', scheduledAt: DateTime(2026, 6, 1)),
      );
      final n = (await service.byId(id))!.notificationId;
      expect(n, greaterThan(0));
      ids.add(n);
    }
    expect(ids, hasLength(20));
  });

  test('empty titles are rejected', () {
    expect(
      () => service.create(
        ReminderDraft(title: '  ', scheduledAt: DateTime(2026, 6, 1)),
      ),
      throwsArgumentError,
    );
  });

  test(
    'turning notify off cancels the notification but keeps the reminder',
    () async {
      final id = await service.create(
        ReminderDraft(title: 'A', scheduledAt: DateTime(2026, 6, 1)),
      );
      expect(notifications.scheduled, hasLength(1));
      await service.update(
        id,
        ReminderDraft(
          title: 'A',
          scheduledAt: DateTime(2026, 6, 1),
          notify: false,
        ),
      );
      expect(notifications.scheduled, isEmpty);
      expect((await service.byId(id))!.notify, isFalse);
    },
  );

  test(
    'complete cancels a one-off reminder and reopen reschedules it',
    () async {
      final id = await service.create(
        ReminderDraft(title: 'A', scheduledAt: DateTime(2026, 6, 1)),
      );
      await service.complete(id);
      var row = (await service.byId(id))!;
      expect(row.status, ReminderStatus.completed);
      expect(row.completedAt, now);
      expect(notifications.scheduled, isEmpty);

      await service.reopen(id);
      row = (await service.byId(id))!;
      expect(row.status, ReminderStatus.scheduled);
      expect(notifications.scheduled, hasLength(1));
    },
  );

  test('completing a repeating reminder advances it instead', () async {
    final id = await service.create(
      ReminderDraft(
        title: 'Water plants',
        scheduledAt: DateTime(2026, 5, 10, 8),
        repeat: RepeatRule.weekly,
      ),
    );
    await service.complete(id);
    final row = (await service.byId(id))!;
    expect(row.status, ReminderStatus.scheduled);
    expect(row.scheduledAt, DateTime(2026, 5, 17, 8));
    expect(
      notifications.scheduled[row.notificationId]!.repeat,
      RepeatRule.weekly,
    );
  });

  test('snooze moves the reminder relative to now', () async {
    final id = await service.create(
      ReminderDraft(title: 'A', scheduledAt: DateTime(2026, 5, 10, 13)),
    );
    await service.snooze(id, const Duration(hours: 1));
    final row = (await service.byId(id))!;
    expect(row.scheduledAt, DateTime(2026, 5, 10, 13));
    expect(
      notifications.scheduled[row.notificationId]!.at,
      DateTime(2026, 5, 10, 13),
    );
  });

  test('delete removes the row and the notification', () async {
    final id = await service.create(
      ReminderDraft(title: 'A', scheduledAt: DateTime(2026, 6, 1)),
    );
    await service.delete(id);
    expect(await service.byId(id), isNull);
    expect(notifications.scheduled, isEmpty);
  });

  test(
    'resyncAll re-registers notifications and advances past repeats',
    () async {
      final once = await service.create(
        ReminderDraft(title: 'Once', scheduledAt: DateTime(2026, 5, 11)),
      );
      final daily = await service.create(
        ReminderDraft(
          title: 'Daily',
          scheduledAt: DateTime(2026, 5, 10, 13),
          repeat: RepeatRule.daily,
        ),
      );
      notifications.scheduled.clear();
      now = DateTime(2026, 5, 12, 20);
      await service.resyncAll();
      expect(
        (await service.byId(daily))!.scheduledAt,
        DateTime(2026, 5, 13, 13),
      );
      // The past one-off stays overdue and is not rescheduled into the past.
      expect((await service.byId(once))!.scheduledAt, DateTime(2026, 5, 11));
      expect(notifications.scheduled, hasLength(2));
    },
  );

  test('deleting the screenshot keeps the reminder unlinked', () async {
    final shot = await addScreenshot();
    final id = await service.create(
      ReminderDraft(
        title: 'A',
        scheduledAt: DateTime(2026, 6, 1),
        screenshotId: shot,
      ),
    );
    await (db.delete(db.screenshots)..where((s) => s.id.equals(shot))).go();
    expect((await service.byId(id))!.screenshotId, isNull);
  });

  group('nextOccurrence', () {
    test('monthly keeps the preferred day across short months', () {
      final start = DateTime(2026, 1, 31, 9);
      final feb = ReminderService.nextOccurrence(
        start,
        RepeatRule.monthly,
        after: DateTime(2026, 2, 1),
      );
      expect(feb, DateTime(2026, 2, 28, 9));
      final mar = ReminderService.nextOccurrence(
        start,
        RepeatRule.monthly,
        after: DateTime(2026, 3, 1),
      );
      expect(mar, DateTime(2026, 3, 31, 9));
    });

    test('daily skips to the first future occurrence', () {
      final next = ReminderService.nextOccurrence(
        DateTime(2026, 5, 1, 7),
        RepeatRule.daily,
        after: DateTime(2026, 5, 10, 12),
      );
      expect(next, DateTime(2026, 5, 11, 7));
    });
  });

  group('groupReminders', () {
    ReminderItem item(DateTime at) => ReminderItem(
      reminder: ReminderRow(
        id: at.millisecondsSinceEpoch,
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

    test('splits into overdue, today and upcoming', () {
      final groups = groupReminders([
        item(DateTime(2026, 5, 10, 8)),
        item(DateTime(2026, 5, 10, 18)),
        item(DateTime(2026, 5, 11, 0, 1)),
      ], now);
      expect(groups[ReminderTab.overdue], hasLength(1));
      expect(groups[ReminderTab.today], hasLength(1));
      expect(groups[ReminderTab.upcoming], hasLength(1));
    });
  });

  group('ReminderPrefill', () {
    test('never completes a date without a year', () {
      final p = ReminderPrefill.fromPayload({
        'title': 'Concert',
        'date': '--03-15',
        'needsConfirmation': true,
      }, screenshotId: 1);
      expect(p.date, isNull);
      expect(p.hint, contains('year is missing'));
    });

    test('suggests the day before a future deadline', () {
      final p = ReminderPrefill.fromPayload(
        {
          'title': 'Essay',
          'date': '2026-05-20',
          'time': '23:59',
          'isDeadline': true,
        },
        screenshotId: 1,
        now: now,
      );
      expect(p.date, DateTime(2026, 5, 19));
      // Not 23:59 the night before: the editor uses the default time.
      expect(p.time, isNull);
      expect(p.hint, contains('usual reminder time'));
    });

    test('keeps the deadline day when the day before has passed', () {
      final p = ReminderPrefill.fromPayload(
        {'title': 'Essay', 'date': '2026-05-10', 'isDeadline': true},
        screenshotId: 1,
        now: now,
      );
      expect(p.date, DateTime(2026, 5, 10));
      expect(p.time, const TimeOfDay(hour: 9, minute: 0));
    });

    test('flags ambiguous dates', () {
      final p = ReminderPrefill.fromPayload(
        {'title': 'X', 'date': '2026-04-05', 'needsConfirmation': true},
        screenshotId: 1,
        now: now,
      );
      expect(p.date, DateTime(2026, 4, 5));
      expect(p.hint, contains('ambiguous'));
    });
  });
}
