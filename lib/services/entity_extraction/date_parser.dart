import 'entity_models.dart';

class DateMatch {
  const DateMatch({
    required this.raw,
    required this.start,
    required this.end,
    required this.date,
    this.ambiguous = false,
    this.alternative,
  });

  final String raw;
  final int start;
  final int end;
  final PartialDate date;

  /// Day and month could be swapped (for example 03/04/2026).
  final bool ambiguous;

  /// The other reading of an ambiguous numeric date.
  final PartialDate? alternative;

  bool get needsConfirmation => ambiguous || !date.hasYear;
}

class TimeMatch {
  const TimeMatch({
    required this.raw,
    required this.start,
    required this.end,
    required this.hour,
    required this.minute,
  });

  final String raw;
  final int start;
  final int end;
  final int hour;
  final int minute;

  String get normalized =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

/// Finds dates in English, German, French and Spanish text.
abstract final class DateParser {
  static const Map<String, int> months = {
    // English
    'january': 1, 'jan': 1, 'february': 2, 'feb': 2, 'march': 3, 'mar': 3,
    'april': 4, 'apr': 4, 'may': 5, 'june': 6, 'jun': 6, 'july': 7, 'jul': 7,
    'august': 8, 'aug': 8, 'september': 9, 'sept': 9, 'sep': 9,
    'october': 10, 'oct': 10, 'november': 11, 'nov': 11, 'december': 12,
    'dec': 12,
    // German
    'januar': 1, 'jänner': 1, 'februar': 2, 'märz': 3, 'maerz': 3, 'mai': 5,
    'juni': 6, 'juli': 7, 'oktober': 10, 'okt': 10, 'dezember': 12, 'dez': 12,
    // French
    'janvier': 1, 'février': 2, 'fevrier': 2, 'mars': 3, 'avril': 4,
    'juin': 6, 'juillet': 7, 'août': 8, 'aout': 8, 'septembre': 9,
    'octobre': 10, 'novembre': 11, 'décembre': 12, 'decembre': 12,
    // Spanish
    'enero': 1, 'febrero': 2, 'marzo': 3, 'abril': 4, 'mayo': 5, 'junio': 6,
    'julio': 7, 'agosto': 8, 'septiembre': 9, 'setiembre': 9, 'octubre': 10,
    'noviembre': 11, 'diciembre': 12,
  };

  static final String _monthAlt =
      (months.keys.toList()..sort((a, b) => b.length.compareTo(a.length)))
          .map(RegExp.escape)
          .join('|');

  static final _iso = RegExp(r'\b(\d{4})-(\d{1,2})-(\d{1,2})\b');
  static final _numeric = RegExp(
    r'(?<![\d/.-])(\d{1,2})([./-])(\d{1,2})\2(\d{4}|\d{2})(?![\d/.-])',
  );
  static final _dayMonth = RegExp(
    '\\b(\\d{1,2})(?:st|nd|rd|th|er|\\.)?\\s+(?:of\\s+|de\\s+)?($_monthAlt)\\.?'
    '(?:,?\\s+(?:de\\s+)?(\\d{4}))?(?![\\w])',
    caseSensitive: false,
    unicode: true,
  );
  static final _monthDay = RegExp(
    '\\b($_monthAlt)\\.?\\s+(\\d{1,2})(?:st|nd|rd|th)?(?![\\d])'
    '(?:,?\\s+(\\d{4}))?',
    caseSensitive: false,
    unicode: true,
  );
  static final _time24 = RegExp(
    r'\b([01]?\d|2[0-3])[:.h]([0-5]\d)\s*(a\.?m\.?|p\.?m\.?)?(?![\d])',
    caseSensitive: false,
  );
  static final _time12 = RegExp(
    r'\b(1[0-2]|0?[1-9])\s*(a\.?m\.?|p\.?m\.?)(?![a-z])',
    caseSensitive: false,
  );

  static bool _valid(int? year, int month, int day) {
    if (month < 1 || month > 12 || day < 1 || day > 31) return false;
    final y = year ?? 2024; // leap year so 29 Feb stays possible
    final d = DateTime(y, month, day);
    return d.month == month && d.day == day;
  }

  static int _year(String s) {
    final v = int.parse(s);
    return s.length == 2 ? 2000 + v : v;
  }

  static List<DateMatch> findDates(
    String text, {
    DateOrder order = DateOrder.dmy,
  }) {
    final found = <DateMatch>[];
    bool overlaps(int s, int e) => found.any((m) => s < m.end && e > m.start);

    for (final m in _iso.allMatches(text)) {
      final y = int.parse(m[1]!);
      final mo = int.parse(m[2]!);
      final d = int.parse(m[3]!);
      if (_valid(y, mo, d)) {
        found.add(
          DateMatch(
            raw: m[0]!,
            start: m.start,
            end: m.end,
            date: PartialDate(year: y, month: mo, day: d),
          ),
        );
      }
    }

    for (final m in _dayMonth.allMatches(text)) {
      if (overlaps(m.start, m.end)) continue;
      final month = months[m[2]!.toLowerCase()];
      final day = int.parse(m[1]!);
      final year = m[3] == null ? null : int.parse(m[3]!);
      if (month != null && _valid(year, month, day)) {
        found.add(
          DateMatch(
            raw: m[0]!.trim(),
            start: m.start,
            end: m.end,
            date: PartialDate(year: year, month: month, day: day),
          ),
        );
      }
    }

    for (final m in _monthDay.allMatches(text)) {
      if (overlaps(m.start, m.end)) continue;
      final month = months[m[1]!.toLowerCase()];
      final day = int.parse(m[2]!);
      final year = m[3] == null ? null : int.parse(m[3]!);
      // "May" alone is too common a word; require a day and a capital letter.
      if (m[1]!.toLowerCase() == 'may' && m[1] == 'may') continue;
      if (month != null && _valid(year, month, day)) {
        found.add(
          DateMatch(
            raw: m[0]!.trim(),
            start: m.start,
            end: m.end,
            date: PartialDate(year: year, month: month, day: day),
          ),
        );
      }
    }

    for (final m in _numeric.allMatches(text)) {
      if (overlaps(m.start, m.end)) continue;
      final a = int.parse(m[1]!);
      final b = int.parse(m[3]!);
      final y = _year(m[4]!);
      final dmy = _valid(y, b, a)
          ? PartialDate(year: y, month: b, day: a)
          : null;
      final mdy = _valid(y, a, b)
          ? PartialDate(year: y, month: a, day: b)
          : null;
      if (dmy == null && mdy == null) continue;
      final preferMdy = order == DateOrder.mdy;
      final primary = preferMdy ? (mdy ?? dmy)! : (dmy ?? mdy)!;
      final other = identical(primary, dmy) ? mdy : dmy;
      final ambiguous = dmy != null && mdy != null && a != b;
      found.add(
        DateMatch(
          raw: m[0]!,
          start: m.start,
          end: m.end,
          date: primary,
          ambiguous: ambiguous,
          alternative: ambiguous ? other : null,
        ),
      );
    }

    found.sort((x, y) => x.start.compareTo(y.start));
    return found;
  }

  static List<TimeMatch> findTimes(String text) {
    final found = <TimeMatch>[];
    for (final m in _time24.allMatches(text)) {
      var hour = int.parse(m[1]!);
      final minute = int.parse(m[2]!);
      final meridiem = m[3]?.toLowerCase().replaceAll('.', '');
      // "12.50" without am/pm is more likely a price than a time.
      if (m[0]!.contains('.') && meridiem == null) continue;
      if (meridiem != null) {
        if (hour > 12 || hour == 0) continue;
        if (meridiem == 'pm' && hour != 12) hour += 12;
        if (meridiem == 'am' && hour == 12) hour = 0;
      }
      found.add(
        TimeMatch(
          raw: m[0]!.trim(),
          start: m.start,
          end: m.end,
          hour: hour,
          minute: minute,
        ),
      );
    }
    for (final m in _time12.allMatches(text)) {
      if (found.any((t) => m.start < t.end && m.end > t.start)) continue;
      var hour = int.parse(m[1]!);
      final meridiem = m[2]!.toLowerCase().replaceAll('.', '');
      if (meridiem == 'pm' && hour != 12) hour += 12;
      if (meridiem == 'am' && hour == 12) hour = 0;
      found.add(
        TimeMatch(
          raw: m[0]!.trim(),
          start: m.start,
          end: m.end,
          hour: hour,
          minute: 0,
        ),
      );
    }
    found.sort((a, b) => a.start.compareTo(b.start));
    return found;
  }
}
