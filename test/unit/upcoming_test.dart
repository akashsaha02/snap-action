import 'package:flutter_test/flutter_test.dart';
import 'package:snapaction/core/database/app_database.dart';
import 'package:snapaction/features/dashboard/application/upcoming.dart';
import 'package:snapaction/features/reminders/application/reminder_service.dart';

ReminderItem _reminder(int id, DateTime at, {int? screenshotId}) =>
    ReminderItem(
      reminder: ReminderRow(
        id: id,
        screenshotId: screenshotId,
        title: 'Reminder $id',
        scheduledAt: at,
        timezone: 'UTC',
        notificationId: id,
        notify: true,
        repeatRule: RepeatRule.none,
        status: ReminderStatus.scheduled,
        createdAt: at,
        updatedAt: at,
      ),
    );

void main() {
  final now = DateTime(2026, 11, 18, 10);

  test('year-less dates resolve to their next occurrence', () {
    expect(resolveIsoDate('--11-25', now), DateTime(2026, 11, 25));
    expect(resolveIsoDate('--01-05', now), DateTime(2027, 1, 5));
    expect(resolveIsoDate('--02-29', now), DateTime(2028, 2, 29));
    expect(resolveIsoDate('2026-02-30', now), isNull);
    expect(resolveIsoDate('garbage', now), isNull);
  });

  test('merges reminders and dates, one entry per screenshot', () {
    final items = buildUpcoming(
      now: now,
      reminders: [
        _reminder(1, DateTime(2026, 11, 17)), // overdue
        _reminder(2, DateTime(2026, 12, 2, 6), screenshotId: 10),
      ],
      dates: const [
        // Same day as its reminder: covered by the reminder.
        DatedEntity(screenshotId: 10, isDeadline: false, iso: '2026-12-02'),
        DatedEntity(screenshotId: 11, isDeadline: false, iso: '--11-25'),
        DatedEntity(screenshotId: 11, isDeadline: true, iso: '2026-11-25'),
        DatedEntity(screenshotId: 11, isDeadline: false, iso: '2026-11-28'),
        DatedEntity(
          screenshotId: 12,
          isDeadline: false,
          iso: '2026-11-18',
          time: '09:00', // already passed today
        ),
        DatedEntity(
          screenshotId: 13,
          isDeadline: false,
          iso: '2026-11-18',
          time: '18:30',
          screenshotTitle: 'Dinner',
          category: 'Events',
        ),
        DatedEntity(screenshotId: 14, isDeadline: false, iso: '2027-03-01'),
      ],
    );
    expect(items.map((i) => (i.kind, i.screenshotId)).toList(), [
      (UpcomingKind.date, 13),
      (UpcomingKind.deadline, 11),
      (UpcomingKind.reminder, 10),
    ]);
    expect(items.first.at, DateTime(2026, 11, 18, 18, 30));
    expect(items.first.hasTime, isTrue);
    expect(items.first.title, 'Dinner');
    expect(items.first.detail, 'Events');
  });

  test('limits the number of items', () {
    final items = buildUpcoming(
      now: now,
      reminders: const [],
      dates: [
        for (var i = 0; i < 9; i++)
          DatedEntity(screenshotId: i, isDeadline: false, iso: '2026-11-2$i'),
      ],
    );
    expect(items, hasLength(5));
  });
}
