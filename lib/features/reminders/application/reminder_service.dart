import 'dart:math';

import 'package:drift/drift.dart';

import '../../../app/routes.dart';
import '../../../core/database/app_database.dart';
import '../../../services/notifications/notification_service.dart';

class ReminderDraft {
  const ReminderDraft({
    required this.title,
    required this.scheduledAt,
    this.description,
    this.screenshotId,
    this.repeat = RepeatRule.none,
    this.notify = true,
  });

  final String title;
  final String? description;
  final DateTime scheduledAt;
  final int? screenshotId;
  final RepeatRule repeat;
  final bool notify;
}

class ReminderItem {
  const ReminderItem({
    required this.reminder,
    this.thumbnailPath,
    this.screenshotTitle,
  });

  final ReminderRow reminder;
  final String? thumbnailPath;
  final String? screenshotTitle;
}

/// Reminders and their notifications. The database is the source of truth;
/// notifications are (re)derived from it.
class ReminderService {
  ReminderService({
    required this._db,
    required this._notifications,
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final NotificationService _notifications;
  final DateTime Function() _now;
  final _random = Random();

  static String routeFor(ReminderRow r) => r.screenshotId == null
      ? Routes.reminders
      : Routes.screenshot(r.screenshotId!);

  Stream<List<ReminderItem>> watch({bool completed = false}) {
    final query =
        _db.select(_db.reminders).join([
            leftOuterJoin(
              _db.screenshots,
              _db.screenshots.id.equalsExp(_db.reminders.screenshotId),
            ),
          ])
          ..where(
            completed
                ? _db.reminders.status.equalsValue(ReminderStatus.completed)
                : _db.reminders.status.equalsValue(ReminderStatus.scheduled),
          )
          ..orderBy([
            completed
                ? OrderingTerm.desc(_db.reminders.completedAt)
                : OrderingTerm.asc(_db.reminders.scheduledAt),
          ]);
    if (completed) query.limit(100);
    return query.watch().map(
      (rows) => [
        for (final r in rows)
          ReminderItem(
            reminder: r.readTable(_db.reminders),
            thumbnailPath: r.readTableOrNull(_db.screenshots)?.thumbnailPath,
            screenshotTitle: r.readTableOrNull(_db.screenshots)?.title,
          ),
      ],
    );
  }

  Future<ReminderRow?> byId(int id) => (_db.select(
    _db.reminders,
  )..where((r) => r.id.equals(id))).getSingleOrNull();

  Future<ReminderRow?> byNotificationId(int notificationId) => (_db.select(
    _db.reminders,
  )..where((r) => r.notificationId.equals(notificationId))).getSingleOrNull();

  Future<int> _uniqueNotificationId() async {
    while (true) {
      final candidate = _random.nextInt(0x7FFFFFFF - 1) + 1;
      final clash = await (_db.select(
        _db.reminders,
      )..where((r) => r.notificationId.equals(candidate))).getSingleOrNull();
      if (clash == null) return candidate;
    }
  }

  Future<int> create(ReminderDraft d) async {
    final title = d.title.trim();
    if (title.isEmpty) throw ArgumentError('Please enter a title.');
    final notificationId = await _uniqueNotificationId();
    final id = await _db
        .into(_db.reminders)
        .insert(
          RemindersCompanion.insert(
            screenshotId: Value(d.screenshotId),
            title: title,
            description: Value(_blankToNull(d.description)),
            scheduledAt: d.scheduledAt,
            timezone: _notifications.timezone,
            notificationId: notificationId,
            notify: Value(d.notify),
            repeatRule: Value(d.repeat),
            status: ReminderStatus.scheduled,
          ),
        );
    await _sync((await byId(id))!);
    return id;
  }

  Future<void> update(int id, ReminderDraft d) async {
    final title = d.title.trim();
    if (title.isEmpty) throw ArgumentError('Please enter a title.');
    await (_db.update(_db.reminders)..where((r) => r.id.equals(id))).write(
      RemindersCompanion(
        title: Value(title),
        description: Value(_blankToNull(d.description)),
        scheduledAt: Value(d.scheduledAt),
        timezone: Value(_notifications.timezone),
        notify: Value(d.notify),
        repeatRule: Value(d.repeat),
        status: const Value(ReminderStatus.scheduled),
        completedAt: const Value(null),
        updatedAt: Value(_now()),
      ),
    );
    await _sync((await byId(id))!);
  }

  /// Changes only the title and notes, keeping the schedule and status, so
  /// an overdue or completed reminder can be renamed without rescheduling.
  Future<void> rename(
    int id, {
    required String title,
    String? description,
  }) async {
    final clean = title.trim();
    if (clean.isEmpty) throw ArgumentError('Please enter a title.');
    await (_db.update(_db.reminders)..where((r) => r.id.equals(id))).write(
      RemindersCompanion(
        title: Value(clean),
        description: Value(_blankToNull(description)),
        updatedAt: Value(_now()),
      ),
    );
    // Refreshes the pending notification's text; past one-off reminders
    // have none and are not rescheduled.
    final row = await byId(id);
    if (row != null) await _sync(row);
  }

  /// Completing a repeating reminder moves it to its next occurrence.
  Future<void> complete(int id) async {
    final r = await byId(id);
    if (r == null) return;
    if (r.repeatRule != RepeatRule.none) {
      await (_db.update(_db.reminders)..where((x) => x.id.equals(id))).write(
        RemindersCompanion(
          scheduledAt: Value(
            nextOccurrence(r.scheduledAt, r.repeatRule, after: _now()),
          ),
          updatedAt: Value(_now()),
        ),
      );
      await _sync((await byId(id))!);
      return;
    }
    await (_db.update(_db.reminders)..where((x) => x.id.equals(id))).write(
      RemindersCompanion(
        status: const Value(ReminderStatus.completed),
        completedAt: Value(_now()),
        updatedAt: Value(_now()),
      ),
    );
    await _notifications.cancel(r.notificationId);
  }

  Future<void> reopen(int id) async {
    await (_db.update(_db.reminders)..where((x) => x.id.equals(id))).write(
      RemindersCompanion(
        status: const Value(ReminderStatus.scheduled),
        completedAt: const Value(null),
        updatedAt: Value(_now()),
      ),
    );
    await _sync((await byId(id))!);
  }

  Future<void> snooze(int id, Duration by) async {
    await (_db.update(_db.reminders)..where((x) => x.id.equals(id))).write(
      RemindersCompanion(
        scheduledAt: Value(_now().add(by)),
        status: const Value(ReminderStatus.scheduled),
        updatedAt: Value(_now()),
      ),
    );
    await _sync((await byId(id))!);
  }

  Future<void> delete(int id) async {
    final r = await byId(id);
    if (r == null) return;
    await _notifications.cancel(r.notificationId);
    await (_db.delete(_db.reminders)..where((x) => x.id.equals(id))).go();
  }

  Future<void> cancelNotifications(List<int> notificationIds) async {
    for (final n in notificationIds) {
      await _notifications.cancel(n);
    }
  }

  /// Re-registers every scheduled notification, for example after a restore
  /// or when notifications were re-enabled. Past one-off reminders stay
  /// listed as overdue; past repeating reminders advance to their next
  /// occurrence.
  Future<void> resyncAll() async {
    final rows = await (_db.select(
      _db.reminders,
    )..where((r) => r.status.equalsValue(ReminderStatus.scheduled))).get();
    final now = _now();
    for (final r in rows) {
      var row = r;
      if (r.repeatRule != RepeatRule.none && r.scheduledAt.isBefore(now)) {
        final next = nextOccurrence(r.scheduledAt, r.repeatRule, after: now);
        await (_db.update(_db.reminders)..where((x) => x.id.equals(r.id)))
            .write(RemindersCompanion(scheduledAt: Value(next)));
        row = r.copyWith(scheduledAt: next);
      }
      await _sync(row);
    }
  }

  Future<void> _sync(ReminderRow r) async {
    await _notifications.cancel(r.notificationId);
    if (!r.notify || r.status != ReminderStatus.scheduled) return;
    await _notifications.schedule(
      id: r.notificationId,
      title: r.title,
      body:
          r.description ??
          (r.screenshotId == null ? null : 'Tap to open the screenshot'),
      at: r.scheduledAt,
      route: routeFor(r),
      repeat: r.repeatRule,
    );
  }

  /// First occurrence of [start] repeated by [rule] that is after [after].
  static DateTime nextOccurrence(
    DateTime start,
    RepeatRule rule, {
    required DateTime after,
  }) {
    var next = start;
    var guard = 0;
    while (!next.isAfter(after) && guard++ < 100000) {
      next = switch (rule) {
        RepeatRule.none => next,
        RepeatRule.daily => DateTime(
          next.year,
          next.month,
          next.day + 1,
          next.hour,
          next.minute,
        ),
        RepeatRule.weekly => DateTime(
          next.year,
          next.month,
          next.day + 7,
          next.hour,
          next.minute,
        ),
        RepeatRule.monthly => _addMonth(next, start.day),
      };
      if (rule == RepeatRule.none) break;
    }
    return next;
  }

  /// Keeps the original day where possible (31 Jan -> 28/29 Feb -> 31 Mar).
  static DateTime _addMonth(DateTime d, int preferredDay) {
    final year = d.month == 12 ? d.year + 1 : d.year;
    final month = d.month == 12 ? 1 : d.month + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, min(preferredDay, lastDay), d.hour, d.minute);
  }

  static String? _blankToNull(String? s) {
    final t = s?.trim();
    return t == null || t.isEmpty ? null : t;
  }
}
