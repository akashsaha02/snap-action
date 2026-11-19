import 'package:intl/intl.dart';

abstract final class Formatters {
  static String relativeDay(DateTime value, {DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final day = _dateOnly(value);
    final diff = day.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == -1) return 'Yesterday';
    if (diff == 1) return 'Tomorrow';
    if (day.year == today.year) return DateFormat.MMMd().format(value);
    return DateFormat.yMMMd().format(value);
  }

  static String dateTime(DateTime value, {DateTime? now}) =>
      '${relativeDay(value, now: now)}, ${DateFormat.jm().format(value)}';

  static String fullDate(DateTime value) => DateFormat.yMMMMd().format(value);

  static String time(DateTime value) => DateFormat.jm().format(value);

  static String fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    final mb = kb / 1024;
    if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
    return '${(mb / 1024).toStringAsFixed(2)} GB';
  }

  /// Formats `YYYY-MM-DD` or the year-less `--MM-DD` form without inventing
  /// a year.
  static String isoDate(String? iso) {
    if (iso == null) return '';
    final full = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(iso);
    if (full != null) {
      return DateFormat.yMMMd().format(
        DateTime(int.parse(full[1]!), int.parse(full[2]!), int.parse(full[3]!)),
      );
    }
    final partial = RegExp(r'^--(\d{2})-(\d{2})$').firstMatch(iso);
    if (partial != null) {
      final d = DateTime(2024, int.parse(partial[1]!), int.parse(partial[2]!));
      return '${DateFormat.MMMd().format(d)} (year unknown)';
    }
    return iso;
  }

  /// Formats integer minor units without converting through floating point.
  static String money(int minorUnits, String currency, {int decimals = 2}) {
    if (decimals == 0) return '$currency $minorUnits';
    var factor = 1;
    for (var i = 0; i < decimals; i++) {
      factor *= 10;
    }
    final sign = minorUnits < 0 ? '-' : '';
    final abs = minorUnits.abs();
    final major = NumberFormat.decimalPattern().format(abs ~/ factor);
    final minor = (abs % factor).toString().padLeft(decimals, '0');
    return '$sign$currency $major.$minor';
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
