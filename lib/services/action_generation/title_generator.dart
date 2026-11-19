import '../../core/constants/system_categories.dart';
import '../../core/database/enums.dart';
import '../entity_extraction/entity_extractor.dart';
import '../entity_extraction/text_normalizer.dart';

/// Builds a short, descriptive title from extracted values only. Returns null
/// when nothing meaningful can be said, so the UI falls back to a date label.
class TitleGenerator {
  const TitleGenerator();

  static const maxLength = 60;

  static final _noise = RegExp(
    r'^(?:\d{1,2}[:.]\d{2}(?:\s?[ap]m)?|\d+%|[^A-Za-zÀ-ÿ]*|.*\b(?:lte|5g|4g|wi-?fi)\b.*|back|search|menu|home|share|more|done|cancel|edit)$',
    caseSensitive: false,
  );

  String? generate({
    required String text,
    required ExtractionResult extraction,
    required String categorySlug,
    Map<String, double>? lineHeights,
  }) {
    String? first(EntityType t) => extraction.ofType(t).firstOrNull?.normalized;

    final flight = first(EntityType.flightReference);
    if (flight != null) return _clip('Flight $flight');

    final product = first(EntityType.productName);
    if (product != null) return _clip(product);

    final event = first(EntityType.eventTitle);
    if (event != null) return _clip(event);

    if (extraction.has(EntityType.wifiCredentials)) {
      return _clip('Wi-Fi: ${first(EntityType.wifiCredentials)}');
    }

    if (categorySlug == CategorySlugs.finance) {
      final amount = first(EntityType.amount);
      if (amount != null) return _clip('Payment $amount');
    }

    if (extraction.has(EntityType.codeSnippet)) return 'Code snippet';

    final candidates = [
      for (final line in TextNormalizer.lines(text).take(8))
        if (_meaningful(line)) line,
    ];

    final deadline = extraction.ofType(EntityType.deadline).firstOrNull;
    if (deadline != null || categorySlug == CategorySlugs.jobs) {
      // Name the thing that is due, not the due date: the longest heading
      // near the top that is not itself a date line. App bars ("Jobs",
      // "University Portal") are short, so they lose to the real heading.
      final dated = [
        ...extraction.ofType(EntityType.deadline),
        ...extraction.ofType(EntityType.date),
      ].map((e) => e.raw).where((r) => r.isNotEmpty).toList();
      final headings = candidates
          .take(5)
          .where((l) => !dated.any(l.contains))
          .toList();
      final heading = _heading(headings, lineHeights);
      if (heading != null) return _clip(heading);
      if (deadline != null) return _clip(deadline.raw);
    }

    return candidates.isEmpty ? null : _clip(candidates.first);
  }

  /// The biggest text is the heading. A short first line is usually the
  /// app bar ("Jobs", "University Portal"), so it needs to be clearly bigger.
  /// Without sizes (edited text), the longest of the first lines wins.
  static String? _heading(List<String> lines, Map<String, double>? heights) {
    if (lines.isEmpty) return null;
    double score(int i) {
      final line = lines[i];
      final h = heights?[line.trim()];
      if (h == null) return -1;
      final appBar = i == 0 && line.split(' ').length <= 3;
      return appBar ? h * 0.8 : h;
    }

    if (heights != null && lines.any((l) => heights.containsKey(l.trim()))) {
      var best = 0;
      for (var i = 1; i < lines.length; i++) {
        if (score(i) > score(best)) best = i;
      }
      return lines[best];
    }
    final ranked = lines.take(3).toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    return ranked.first;
  }

  static bool _meaningful(String line) {
    if (line.length < 4 || _noise.hasMatch(line)) return false;
    final letters = line.replaceAll(RegExp(r'[^A-Za-zÀ-ÿ]'), '').length;
    return letters >= 4 && letters / line.length >= 0.5;
  }

  static String _clip(String s) {
    final t = s.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (t.length <= maxLength) return t;
    final cut = t.substring(0, maxLength - 1);
    final space = cut.lastIndexOf(' ');
    return '${space > maxLength * 0.6 ? cut.substring(0, space) : cut}…';
  }
}
