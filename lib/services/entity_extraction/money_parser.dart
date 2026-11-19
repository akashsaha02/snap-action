import 'entity_models.dart';

class MoneyMatch {
  const MoneyMatch({
    required this.raw,
    required this.start,
    required this.end,
    required this.amount,
  });

  final String raw;
  final int start;
  final int end;
  final MoneyAmount amount;
}

/// Parses prices such as `€49.99`, `49,99 €`, `USD 1,299.00`, `Tk 1.500`.
abstract final class MoneyParser {
  static const Map<String, String> symbols = {
    '€': 'EUR',
    '£': 'GBP',
    '¥': 'JPY',
    '₹': 'INR',
    '৳': 'BDT',
    'US\$': 'USD',
    'C\$': 'CAD',
    'A\$': 'AUD',
    '\$': 'USD',
  };

  static const codes = {
    'EUR',
    'USD',
    'GBP',
    'JPY',
    'INR',
    'BDT',
    'CHF',
    'CAD',
    'AUD',
    'SEK',
    'NOK',
    'DKK',
    'PLN',
    'CZK',
    'SGD',
    'AED',
    'TK',
  };

  static const _zeroDecimal = {'JPY'};

  static int decimalsFor(String? currency) =>
      _zeroDecimal.contains(currency?.toUpperCase()) ? 0 : 2;

  /// Parses a price typed by the user (`12`, `12.5`, `12,50`, `1299.99`)
  /// into minor units without floating point. Returns null when invalid.
  static int? parseUserAmount(String input, {int decimals = 2}) {
    final m = RegExp(r'^\s*(\d{1,12})(?:[.,](\d+))?\s*$').firstMatch(input);
    if (m == null) return null;
    final fraction = m[2] ?? '';
    if (fraction.length > decimals) return null;
    var factor = 1;
    for (var i = 0; i < decimals; i++) {
      factor *= 10;
    }
    final minor = decimals == 0
        ? 0
        : int.parse(fraction.padRight(decimals, '0'));
    return int.parse(m[1]!) * factor + minor;
  }

  static String formatUserAmount(int minorUnits, {int decimals = 2}) {
    if (decimals == 0) return '$minorUnits';
    var factor = 1;
    for (var i = 0; i < decimals; i++) {
      factor *= 10;
    }
    return '${minorUnits ~/ factor}.${(minorUnits % factor).toString().padLeft(decimals, '0')}';
  }

  static const _num =
      r'\d{1,3}(?:[.,\s]\d{3})+(?:[.,]\d{1,2})?|\d+(?:[.,]\d{1,2})?';
  static const _sym = r'US\$|C\$|A\$|[€£¥₹৳$]';
  static final _codeAlt = codes.join('|');

  static final _prefix = RegExp(
    '(?<![\\w])($_sym|(?:$_codeAlt)\\b\\.?)\\s?($_num)(?![\\d])',
    caseSensitive: false,
  );
  static final _suffix = RegExp(
    '(?<![\\w.,])($_num)\\s?($_sym|(?:$_codeAlt)\\b)',
    caseSensitive: false,
  );

  static List<MoneyMatch> find(String text) {
    final out = <MoneyMatch>[];
    void add(RegExpMatch m, String currencyToken, String number) {
      if (out.any((o) => m.start < o.end && m.end > o.start)) return;
      final parsed = parse(number, currencyToken);
      if (parsed != null) {
        out.add(
          MoneyMatch(
            raw: m[0]!.trim(),
            start: m.start,
            end: m.end,
            amount: parsed,
          ),
        );
      }
    }

    for (final m in _prefix.allMatches(text)) {
      add(m, m[1]!, m[2]!);
    }
    for (final m in _suffix.allMatches(text)) {
      add(m, m[2]!, m[1]!);
    }
    out.sort((a, b) => a.start.compareTo(b.start));
    return out;
  }

  static String? currencyFor(String token) {
    final t = token.trim().replaceAll('.', '');
    if (symbols.containsKey(t)) return symbols[t];
    final upper = t.toUpperCase();
    if (upper == 'TK') return 'BDT';
    if (codes.contains(upper)) return upper;
    return null;
  }

  /// Converts a localized number string to minor units without using doubles.
  static MoneyAmount? parse(String number, String currencyToken) {
    final currency = currencyFor(currencyToken);
    if (currency == null) return null;
    final decimals = decimalsFor(currency);
    final cleaned = number.replaceAll(RegExp(r'\s'), '');

    final lastSep = cleaned.lastIndexOf(RegExp('[.,]'));
    String integerPart;
    var fraction = '';
    if (lastSep >= 0 &&
        cleaned.length - lastSep - 1 <= 2 &&
        cleaned.length - lastSep - 1 > 0) {
      integerPart = cleaned.substring(0, lastSep);
      fraction = cleaned.substring(lastSep + 1);
    } else {
      integerPart = cleaned;
    }
    integerPart = integerPart.replaceAll(RegExp('[.,]'), '');
    if (integerPart.isEmpty) integerPart = '0';
    final major = int.tryParse(integerPart);
    if (major == null) return null;

    var minor = 0;
    if (decimals > 0) {
      minor = int.parse(
        fraction.padRight(decimals, '0').substring(0, decimals),
      );
    }
    var factor = 1;
    for (var i = 0; i < decimals; i++) {
      factor *= 10;
    }
    return MoneyAmount(
      minorUnits: major * factor + minor,
      currency: currency,
      decimals: decimals,
      currencyAmbiguous: currencyToken.trim() == r'$',
    );
  }
}
