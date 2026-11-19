/// Cleans OCR output without changing its meaning: unifies quotes, dashes
/// and whitespace, and removes invisible characters. Line breaks are kept
/// because many heuristics work per line.
abstract final class TextNormalizer {
  static final _invisible = RegExp('[\u200B-\u200D\uFEFF\u00AD]');
  static final _spaces = RegExp('[ \t\u00A0\u2000-\u200A\u202F\u205F\u3000]+');
  static final _blankLines = RegExp(r'\n{3,}');

  static String normalize(String input) {
    var text = input
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll(_invisible, '')
        .replaceAll(RegExp('[\u2018\u2019\u201A\u2032]'), "'")
        .replaceAll(RegExp('[\u201C\u201D\u201E\u2033]'), '"')
        .replaceAll(RegExp('[\u2010-\u2013\u2212]'), '-')
        .replaceAll('\u2014', ' - ')
        .replaceAll('\u2026', '...');
    text = text
        .split('\n')
        .map((l) => l.replaceAll(_spaces, ' ').trim())
        .join('\n')
        .replaceAll(_blankLines, '\n\n');
    return text.trim();
  }

  static final _statusToken = RegExp(
    r'^(?:\d{1,2}[:.]\d{2}(?:\s?[AP]M)?|[2-6]G\+?|LTE\+?|VoLTE|H\+?|E|'
    r'Wi-?Fi|\d{1,3}\s?%|[^\w\s])$',
    caseSensitive: false,
  );

  /// Drops phone status-bar lines (clock, network type, battery) from the
  /// top of a screenshot's text. They are on almost every screenshot and
  /// otherwise read as flight numbers ("5G 87"), times or titles.
  static String withoutStatusBar(String text) {
    final lines = text.split('\n');
    var i = 0;
    while (i < lines.length && i < 3) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        i++;
        continue;
      }
      final tokens = line.split(RegExp(r'\s+'));
      if (!tokens.every(_statusToken.hasMatch)) break;
      lines[i] = '';
      i++;
    }
    return lines.join('\n').trim();
  }

  static List<String> lines(String text) => [
    for (final l in text.split('\n'))
      if (l.trim().isNotEmpty) l.trim(),
  ];

  /// Lower-cased variant used for keyword matching.
  static String forMatching(String text) => text.toLowerCase();
}
