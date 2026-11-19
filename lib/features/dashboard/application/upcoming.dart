import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap.dart';
import '../../../app/providers.dart';
import '../../reminders/application/reminder_service.dart';

/// Where an upcoming item on Home comes from.
enum UpcomingKind { reminder, deadline, date }

/// One dated item shown in the Home "Coming up" section.
class UpcomingItem {
  const UpcomingItem({
    required this.kind,
    required this.title,
    required this.at,
    this.hasTime = false,
    this.screenshotId,
    this.reminderId,
    this.detail,
  });

  final UpcomingKind kind;
  final String title;

  /// Local date (and time, when [hasTime]) of the item.
  final DateTime at;
  final bool hasTime;
  final int? screenshotId;
  final int? reminderId;

  /// Secondary context, for example the screenshot category.
  final String? detail;
}

/// A date or deadline found in a screenshot.
class DatedEntity {
  const DatedEntity({
    required this.screenshotId,
    required this.isDeadline,
    required this.iso,
    this.time,
    this.screenshotTitle,
    this.category,
  });

  final int screenshotId;
  final bool isDeadline;

  /// `YYYY-MM-DD`, or `--MM-DD` when the year is unknown.
  final String iso;

  /// `HH:mm` found on the same line, if any.
  final String? time;
  final String? screenshotTitle;
  final String? category;
}

/// Resolves an extracted date to a local calendar day. A year-less date is
/// taken as its next occurrence on or after [today].
DateTime? resolveIsoDate(String iso, DateTime today) {
  final full = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(iso);
  if (full != null) {
    return _validDate(
      int.parse(full[1]!),
      int.parse(full[2]!),
      int.parse(full[3]!),
    );
  }
  final partial = RegExp(r'^--(\d{2})-(\d{2})$').firstMatch(iso);
  if (partial == null) return null;
  final month = int.parse(partial[1]!);
  final day = int.parse(partial[2]!);
  final day0 = DateTime(today.year, today.month, today.day);
  // 29 Feb only exists in leap years, so look a few years ahead.
  for (var year = today.year; year <= today.year + 4; year++) {
    final d = _validDate(year, month, day);
    if (d != null && !d.isBefore(day0)) return d;
  }
  return null;
}

DateTime? _validDate(int y, int m, int d) {
  if (m < 1 || m > 12 || d < 1 || d > 31) return null;
  final date = DateTime(y, m, d);
  return date.month == m && date.day == d ? date : null;
}

(int, int)? _parseTime(String? hhmm) {
  if (hhmm == null) return null;
  final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(hhmm);
  if (m == null) return null;
  final h = int.parse(m[1]!);
  final min = int.parse(m[2]!);
  if (h > 23 || min > 59) return null;
  return (h, min);
}

/// Merges scheduled reminders and dates found in screenshots into the next
/// [limit] items between today and [window] days ahead.
///
/// Each screenshot appears once (its earliest upcoming date); a screenshot
/// date on the same day as one of its reminders is left out, since the
/// reminder already covers it. Deadlines win over plain dates on a tie.
List<UpcomingItem> buildUpcoming({
  required List<ReminderItem> reminders,
  required List<DatedEntity> dates,
  required DateTime now,
  int window = 30,
  int limit = 5,
}) {
  final today = DateTime(now.year, now.month, now.day);
  final end = DateTime(today.year, today.month, today.day + window + 1);
  final items = <UpcomingItem>[];
  final reminderDays = <(int, DateTime)>{};

  for (final r in reminders) {
    final row = r.reminder;
    final at = row.scheduledAt.toLocal();
    if (at.isBefore(now) || !at.isBefore(end)) continue;
    if (row.screenshotId != null) {
      reminderDays.add((
        row.screenshotId!,
        DateTime(at.year, at.month, at.day),
      ));
    }
    items.add(
      UpcomingItem(
        kind: UpcomingKind.reminder,
        title: row.title,
        at: at,
        hasTime: true,
        screenshotId: row.screenshotId,
        reminderId: row.id,
        detail: r.screenshotTitle,
      ),
    );
  }

  final perScreenshot = <int, UpcomingItem>{};
  for (final e in dates) {
    final day = resolveIsoDate(e.iso, today);
    if (day == null || day.isBefore(today) || !day.isBefore(end)) continue;
    if (reminderDays.contains((e.screenshotId, day))) continue;
    final time = _parseTime(e.time);
    final at = time == null
        ? day
        : DateTime(day.year, day.month, day.day, time.$1, time.$2);
    if (time != null && at.isBefore(now)) continue;
    final item = UpcomingItem(
      kind: e.isDeadline ? UpcomingKind.deadline : UpcomingKind.date,
      title: _titleOf(e.screenshotTitle),
      at: at,
      hasTime: time != null,
      screenshotId: e.screenshotId,
      detail: e.category,
    );
    final existing = perScreenshot[e.screenshotId];
    if (existing == null || _earlier(item, existing)) {
      perScreenshot[e.screenshotId] = item;
    }
  }
  items
    ..addAll(perScreenshot.values)
    ..sort(_compare);
  return items.take(limit).toList();
}

String _titleOf(String? title) {
  final t = title?.trim();
  return t == null || t.isEmpty ? 'Screenshot' : t;
}

bool _earlier(UpcomingItem a, UpcomingItem b) {
  final aDay = DateTime(a.at.year, a.at.month, a.at.day);
  final bDay = DateTime(b.at.year, b.at.month, b.at.day);
  if (aDay != bDay) return aDay.isBefore(bDay);
  if (a.kind != b.kind) return a.kind == UpcomingKind.deadline;
  return a.at.isBefore(b.at);
}

int _compare(UpcomingItem a, UpcomingItem b) {
  final c = a.at.compareTo(b.at);
  if (c != 0) return c;
  return a.kind.index.compareTo(b.kind.index);
}

/// Dates and deadlines extracted from screenshots that are not archived.
final datedEntitiesProvider = StreamProvider.autoDispose<List<DatedEntity>>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  return db
      .customSelect(
        'SELECT e.screenshot_id, e.entity_type, e.normalized_value, '
        'e.metadata_json, s.title, c.name AS category '
        'FROM extracted_entities e '
        'JOIN screenshots s ON s.id = e.screenshot_id '
        'LEFT JOIN categories c '
        'ON c.id = coalesce(s.primary_category_id, s.suggested_category_id) '
        "WHERE e.entity_type IN ('date', 'deadline') "
        "AND e.validation_status != 'rejected' "
        'AND e.normalized_value IS NOT NULL '
        'AND s.is_archived = 0',
        readsFrom: {db.extractedEntities, db.screenshots, db.categories},
      )
      .watch()
      .map(
        (rows) => [
          for (final r in rows)
            DatedEntity(
              screenshotId: r.read<int>('screenshot_id'),
              isDeadline: r.read<String>('entity_type') == 'deadline',
              iso: r.read<String>('normalized_value'),
              time: _timeFrom(r.read<String?>('metadata_json')),
              screenshotTitle: r.read<String?>('title'),
              category: r.read<String?>('category'),
            ),
        ],
      );
});

String? _timeFrom(String? json) {
  if (json == null) return null;
  try {
    final meta = jsonDecode(json);
    if (meta is Map && meta['time'] is String) return meta['time'] as String;
  } on FormatException {
    return null;
  }
  return null;
}

/// The next few dated items for Home; empty while loading.
final upcomingProvider = Provider.autoDispose<List<UpcomingItem>>((ref) {
  final reminders = ref.watch(remindersProvider(false)).value ?? const [];
  final dates = ref.watch(datedEntitiesProvider).value ?? const [];
  return buildUpcoming(reminders: reminders, dates: dates, now: DateTime.now());
});

/// Scheduled reminders whose time has passed.
final overdueRemindersProvider = Provider.autoDispose<int>((ref) {
  final reminders = ref.watch(remindersProvider(false)).value ?? const [];
  final now = DateTime.now();
  return reminders.where((r) => r.reminder.scheduledAt.isBefore(now)).length;
});
