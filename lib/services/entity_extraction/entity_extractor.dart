import '../../core/database/enums.dart';
import 'date_parser.dart';
import 'entity_models.dart';
import 'money_parser.dart';
import 'text_normalizer.dart';

class ExtractionResult {
  const ExtractionResult({required this.entities, required this.isSensitive});

  final List<Entity> entities;

  /// The text looks like it contains credentials or financial identifiers.
  final bool isSensitive;

  Iterable<Entity> ofType(EntityType t) => entities.where((e) => e.type == t);

  bool has(EntityType t) => entities.any((e) => e.type == t);
}

/// Rule-based, on-device extraction of structured values from OCR text.
/// Values that cannot be read unambiguously are flagged for confirmation
/// instead of being guessed.
class EntityExtractor {
  const EntityExtractor({this.dateOrder = DateOrder.dmy});

  final DateOrder dateOrder;

  static final _email = RegExp(
    r'(?<![\w.+-])[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,24}\b',
  );
  static final _url = RegExp(
    r'''\b(?:https?://|www\.)[^\s<>"'`]+''',
    caseSensitive: false,
  );
  static final _bareDomain = RegExp(
    r'(?<![@\w./-])(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+'
    r'(?:com|org|net|edu|gov|io|de|fr|es|it|nl|eu|uk|co|app|dev|info|me|ai|bd|in|ch|at)'
    r'''(?:/[^\s<>"'`]*)?(?![\w@])''',
    caseSensitive: false,
  );
  static final _phone = RegExp(
    r'(?<![\w/.,-])(?:\+|00)?\(?\d[\d\s().-]{5,18}\d(?![\w/-])',
  );
  static final _phoneContext = RegExp(
    r'\b(tel|phone|call|mobile|mob|cell|whatsapp|contact|hotline|telefon|téléphone|teléfono|móvil)\b|☎|📞',
    caseSensitive: false,
  );
  static final _deadlineContext = RegExp(
    r'\b(deadline|due(?: date| by)?|apply by|submit(?:ted)? by|submission|closes?|closing date|last date|expires?|expiry|valid until|until|before|no later than|frist|bis zum|date limite|fecha l[ií]mite|antes del?)\b',
    caseSensitive: false,
  );
  static final _flightContext = RegExp(
    r'\b(flight|flug|vol|vuelo|boarding|gate|departure|arrival|airline|terminal|seat|pnr)\b',
    caseSensitive: false,
  );
  static final _networkType = RegExp(r'^[2-6]G$');
  static final _flight = RegExp(
    r'\b((?:[A-Z]{2}|[A-Z]\d|\d[A-Z]))\s?(\d{2,4})\b',
  );
  static final _orderKeyword = RegExp(
    r'\b(?:order|booking|reservation|reference|ref|confirmation|invoice|receipt|transaction|txn|ticket|pnr|bestellung|buchung|rechnung|commande|pedido|factura)\b'
    r'(?:\s*(?:no|nr|number|id|code|#)\.?)?\s*[:#]?\s*([A-Z0-9][A-Z0-9-]{4,24})\b',
    caseSensitive: false,
  );
  static final _orderPattern = RegExp(
    r'\b(?:ORD|INV|REF|TXN|PNR|BK)[-#]?\d{3,}\b',
  );
  static final _address = RegExp(
    r'(\b\d{1,5}[a-z]?\s+(?:[A-ZÄÖÜ][\wäöüß.\-]*\s){0,4}'
    r'(?:street|st\.|road|rd\.|avenue|ave\.?|boulevard|blvd\.?|lane|ln\.|drive|dr\.|way|place|square|plaza)\b[^\n]*)'
    r'|(\b[A-ZÄÖÜ][\wäöüß\-]*(?:straße|strasse|str\.|weg|platz|allee|gasse|ring)\s+\d{1,4}[a-z]?\b[^\n]*)'
    r'|(\b(?:rue|avenue|boulevard|calle|avenida|plaza)\s+[^\n]{3,60})',
    caseSensitive: false,
  );
  // Same line only: "CS 4410" followed by "Max." on the next line is not a
  // postal code and city.
  static final _postalCity = RegExp(
    r'\b\d{4,5}[ \t]+[A-ZÄÖÜ][a-zäöüß]+(?:[ \t][A-ZÄÖÜ][a-zäöüß]+)?\b',
  );
  // Lines that contain a number but are never an address.
  static final _notAddress = RegExp(
    r'\b(?:visa|mastercard|amex|card|paid|course|room|seat|gate|flight|'
    r'order|invoice|transaction|txn|ref|pages?|ratings?)\b',
    caseSensitive: false,
  );
  static final _wifiQr = RegExp(
    r'WIFI:(?:[^;]*;)*?S:([^;]*);(?:[^;]*;)*?P:([^;]*);',
    caseSensitive: false,
  );
  static final _ssid = RegExp(
    r'\b(?:ssid|network(?: name)?|wi-?fi(?: name| network)?|wlan|netzwerk(?:name)?|r[ée]seau)\s*[:=]\s*([^\n]{1,40})',
    caseSensitive: false,
  );
  static final _wifiPassword = RegExp(
    r'\b(?:password|passwort|pass|key|wpa key|mot de passe|contraseña|pw)\s*[:=]\s*(\S{1,63})',
    caseSensitive: false,
  );
  static final _sensitive = RegExp(
    r'\b(password|passwort|passcode|iban|swift|bic|account (?:no|number)|card number|cvv|cvc|pin\b|otp|one-time|verification code|security code|ssn|social security|passport|national id|tax id|routing number|sort code|balance)\b',
    caseSensitive: false,
  );
  static final _iban = RegExp(r'\b[A-Z]{2}\d{2}(?:\s?[A-Z0-9]{4}){3,7}\b');
  static final _cardCandidate = RegExp(r'\b(?:\d[ -]?){13,19}\b');
  static final _codeTokens = RegExp(
    r'(;\s*$|\{\s*$|^\s*\}|=>|\bfunction\b|\bdef\s+\w+\(|\bclass\s+\w+|\bimport\s+[\w.]+|\breturn\b|\bconst\s+\w+\s*=|\blet\s+\w+\s*=|\bvar\s+\w+|\bpublic\s+(?:static\s+)?\w+|#include|console\.log|print\(|System\.out|Traceback|Exception|at\s+[\w.$]+\([\w.]+:\d+\))',
    multiLine: true,
  );
  static final _shoppingContext = RegExp(
    r'\b(add to (?:cart|bag|basket)|buy now|in stock|free shipping|price|sale|discount|% off|checkout|warenkorb|kaufen|ajouter au panier|comprar|añadir al carrito|wishlist)\b',
    caseSensitive: false,
  );
  static final _eventContext = RegExp(
    r'\b(conference|concert|festival|meetup|webinar|workshop|event|summit|exhibition|show|party|gig|tickets?|venue|doors open|register|registration|rsvp|konzert|veranstaltung|concierto|évènement|événement)\b',
    caseSensitive: false,
  );
  static final _uiNoise = RegExp(
    r'^(add to (cart|bag|basket)|buy now|share|save|like|follow|home|menu|search|back|next|more|login|sign in|sign up|subscribe|\d+%|[\d:]+|[^a-zA-ZÀ-ÿ]+)$',
    caseSensitive: false,
  );

  // OCR often reads "https://flutter.example.com" as "https://flutter.
  // example.com"; matching the pieces would open the wrong site.
  static final _splitUrl = RegExp(
    r'\b((?:https?://|www\.)[\w-]+\.) ([\w-]+(?:\.[\w-]+)*\.[a-z]{2,24})\b',
    caseSensitive: false,
  );

  ExtractionResult extract(String input) {
    final text = TextNormalizer.normalize(input)
        .replaceAllMapped(_splitUrl, (m) => '${m[1]}${m[2]}');
    if (text.isEmpty) {
      return const ExtractionResult(entities: [], isSensitive: false);
    }
    final lines = TextNormalizer.lines(text);
    final entities = <Entity>[];
    final consumed = <(int, int)>[];
    bool isConsumed(int s, int e) => consumed.any((c) => s < c.$2 && e > c.$1);

    // Wi-Fi first so passwords are not re-read as other entities.
    final wifi = _extractWifi(text);
    if (wifi != null) entities.add(wifi);

    for (final m in _email.allMatches(text)) {
      consumed.add((m.start, m.end));
      entities.add(
        Entity(
          type: EntityType.email,
          raw: m[0]!,
          normalized: m[0]!.toLowerCase(),
        ),
      );
    }

    final urls = <String>{};
    for (final m in [
      ..._url.allMatches(text),
      ..._bareDomain.allMatches(text),
    ]) {
      if (isConsumed(m.start, m.end)) continue;
      final raw = _trimTrailing(m[0]!);
      final normalized = normalizeUrl(raw);
      if (normalized == null || !urls.add(normalized)) continue;
      consumed.add((m.start, m.start + raw.length));
      entities.add(
        Entity(type: EntityType.url, raw: raw, normalized: normalized),
      );
    }

    final dates = DateParser.findDates(text, order: dateOrder);
    for (final d in dates) {
      consumed.add((d.start, d.end));
    }
    final times = DateParser.findTimes(text);
    final money = MoneyParser.find(text);
    for (final m in money) {
      consumed.add((m.start, m.end));
    }

    for (final m in _orderPattern.allMatches(text)) {
      consumed.add((m.start, m.end));
      entities.add(
        Entity(
          type: EntityType.orderReference,
          raw: m[0]!,
          normalized: m[0]!.toUpperCase(),
        ),
      );
    }
    for (final m in _orderKeyword.allMatches(text)) {
      final value = m[1]!;
      final start = m.start + m[0]!.lastIndexOf(value);
      if (!RegExp(r'\d').hasMatch(value) ||
          isConsumed(start, start + value.length)) {
        continue;
      }
      consumed.add((start, start + value.length));
      entities.add(
        Entity(
          type: EntityType.orderReference,
          raw: value,
          normalized: value.toUpperCase(),
        ),
      );
    }

    if (_flightContext.hasMatch(text)) {
      final seen = <String>{};
      for (final m in _flight.allMatches(text)) {
        if (isConsumed(m.start, m.end)) continue;
        final code = '${m[1]}${m[2]}';
        // "5G 87%" from a status bar, or any number that is a percentage.
        if (_networkType.hasMatch(m[1]!)) continue;
        if (m.end < text.length && text[m.end] == '%') continue;
        if (!seen.add(code)) continue;
        consumed.add((m.start, m.end));
        entities.add(
          Entity(
            type: EntityType.flightReference,
            raw: m[0]!,
            normalized: code,
            metadata: {'airline': m[1], 'number': m[2]},
          ),
        );
      }
    }

    for (final m in _phone.allMatches(text)) {
      if (isConsumed(m.start, m.end)) continue;
      final raw = m[0]!.trim();
      final phone = _normalizePhone(raw, lineOf(text, m.start));
      if (phone == null) continue;
      consumed.add((m.start, m.end));
      entities.add(Entity(type: EntityType.phone, raw: raw, normalized: phone));
    }

    for (final d in dates) {
      final line = lineOf(text, d.start);
      final timeOnLine = times
          .where((t) => lineOf(text, t.start) == line)
          .firstOrNull;
      entities.add(
        Entity(
          type: EntityType.date,
          raw: d.raw,
          normalized: d.date.iso,
          needsConfirmation: d.needsConfirmation,
          metadata: {
            'yearMissing': !d.date.hasYear,
            'ambiguous': d.ambiguous,
            if (d.alternative != null) 'alternative': d.alternative!.iso,
            'time': ?timeOnLine?.normalized,
            'line': line,
          },
        ),
      );
      if (_deadlineContext.hasMatch(line)) {
        entities.add(
          Entity(
            type: EntityType.deadline,
            raw: line,
            normalized: d.date.iso,
            needsConfirmation: d.needsConfirmation,
            metadata: {'date': d.date.iso, 'time': ?timeOnLine?.normalized},
          ),
        );
      }
    }

    for (final t in times) {
      entities.add(
        Entity(type: EntityType.time, raw: t.raw, normalized: t.normalized),
      );
    }

    for (final m in money) {
      entities.add(
        Entity(
          type: EntityType.amount,
          raw: m.raw,
          normalized: m.amount.formatted,
          needsConfirmation: m.amount.currencyAmbiguous,
          metadata: {
            'minorUnits': m.amount.minorUnits,
            'currency': m.amount.currency,
            'decimals': m.amount.decimals,
            if (m.amount.currencyAmbiguous) 'currencyAmbiguous': true,
          },
        ),
      );
    }

    final addresses = <String>{};
    for (final m in _address.allMatches(text)) {
      final raw = _trimTrailing(m[0]!.trim());
      if (raw.length < 6 || !addresses.add(raw)) continue;
      entities.add(
        Entity(
          type: EntityType.address,
          raw: raw,
          normalized: raw,
          needsConfirmation: true,
        ),
      );
    }
    if (addresses.isEmpty) {
      for (final m in _postalCity.allMatches(text)) {
        final line = lineOf(text, m.start);
        if (isConsumed(m.start, m.end) || line.length > 80) continue;
        if (_notAddress.hasMatch(line)) continue;
        if (!addresses.add(line)) continue;
        entities.add(
          Entity(
            type: EntityType.address,
            raw: line,
            normalized: line,
            needsConfirmation: true,
          ),
        );
      }
    }

    if (money.isNotEmpty && _shoppingContext.hasMatch(text)) {
      final product = _titleCandidate(lines, avoid: money.map((m) => m.raw));
      if (product != null) {
        entities.add(
          Entity(
            type: EntityType.productName,
            raw: product,
            normalized: product,
            needsConfirmation: true,
          ),
        );
      }
    }

    if (dates.isNotEmpty && _eventContext.hasMatch(text)) {
      final title = _titleCandidate(lines, avoid: dates.map((d) => d.raw));
      if (title != null) {
        entities.add(
          Entity(
            type: EntityType.eventTitle,
            raw: title,
            normalized: title,
            needsConfirmation: true,
          ),
        );
      }
    }

    final code = _codeBlock(lines);
    if (code != null) {
      entities.add(
        Entity(type: EntityType.codeSnippet, raw: code, normalized: code),
      );
    }

    return ExtractionResult(
      entities: entities,
      isSensitive: _isSensitive(text) || wifi != null,
    );
  }

  static String lineOf(String text, int index) {
    final start = text.lastIndexOf('\n', index > 0 ? index - 1 : 0);
    final end = text.indexOf('\n', index);
    return text
        .substring(start < 0 ? 0 : start + 1, end < 0 ? text.length : end)
        .trim();
  }

  static String _trimTrailing(String s) =>
      s.replaceAll(RegExp(r'''[.,;:!?)\]}'"»>]+$'''), '');

  /// Returns an `https` URL or null when the value is not a web link.
  static String? normalizeUrl(String raw) {
    var value = _trimTrailing(raw.trim());
    if (!value.toLowerCase().startsWith('http')) value = 'https://$value';
    final uri = Uri.tryParse(value);
    if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      return null;
    }
    if (uri.host.isEmpty || !uri.host.contains('.')) return null;
    return uri.toString();
  }

  static String? _normalizePhone(String raw, String line) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7 || digits.length > 15) return null;
    final international = raw.startsWith('+') || raw.startsWith('00');
    final hasContext = _phoneContext.hasMatch(line);
    // Long digit runs without separators are usually IDs, not phone numbers.
    final grouped = RegExp(r'[\s().-]').hasMatch(raw);
    if (!international && !hasContext && !(grouped && digits.length >= 9)) {
      return null;
    }
    if (RegExp(r'^\d{4}[-.]\d{2}[-.]\d{2}$').hasMatch(raw)) return null;
    if (raw.startsWith('00')) return '+${digits.substring(2)}';
    return international ? '+$digits' : digits;
  }

  Entity? _extractWifi(String text) {
    final qr = _wifiQr.firstMatch(text);
    if (qr != null) {
      return Entity(
        type: EntityType.wifiCredentials,
        raw: qr[0]!,
        normalized: qr[1],
        metadata: {'ssid': qr[1], 'password': qr[2]},
      );
    }
    final ssid = _ssid.firstMatch(text);
    final pass = _wifiPassword.firstMatch(text);
    final wifiMentioned = RegExp(
      r'wi-?fi|wlan|ssid|network',
      caseSensitive: false,
    ).hasMatch(text);
    if (ssid == null || pass == null || !wifiMentioned) return null;
    final name = ssid[1]!.trim();
    return Entity(
      type: EntityType.wifiCredentials,
      raw: '${ssid[0]}\n${pass[0]}',
      normalized: name,
      metadata: {'ssid': name, 'password': pass[1]},
    );
  }

  bool _isSensitive(String text) {
    if (_sensitive.hasMatch(text) || _iban.hasMatch(text)) return true;
    for (final m in _cardCandidate.allMatches(text)) {
      if (_luhn(m[0]!.replaceAll(RegExp(r'\D'), ''))) return true;
    }
    return false;
  }

  static bool _luhn(String digits) {
    if (digits.length < 13 || digits.length > 19) return false;
    var sum = 0;
    var alt = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var d = digits.codeUnitAt(i) - 48;
      if (alt) {
        d *= 2;
        if (d > 9) d -= 9;
      }
      sum += d;
      alt = !alt;
    }
    return sum % 10 == 0;
  }

  /// First prominent, title-like line: 2-10 words, mostly letters.
  String? _titleCandidate(
    List<String> lines, {
    Iterable<String> avoid = const [],
  }) {
    for (final line in lines.take(12)) {
      if (line.length < 4 || line.length > 80) continue;
      if (_uiNoise.hasMatch(line)) continue;
      if (avoid.any(line.contains)) continue;
      final words = line.split(' ');
      if (words.length < 2 || words.length > 10) continue;
      final letters = line.replaceAll(RegExp(r'[^A-Za-zÀ-ÿ]'), '').length;
      if (letters / line.length < 0.6) continue;
      if (_email.hasMatch(line) || _url.hasMatch(line)) continue;
      return line;
    }
    return null;
  }

  String? _codeBlock(List<String> lines) {
    if (lines.length < 3) return null;
    final codeLines = lines.where(_codeTokens.hasMatch).length;
    if (codeLines < 3 || codeLines / lines.length < 0.3) return null;
    return lines.join('\n');
  }
}
