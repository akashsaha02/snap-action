import '../../core/constants/system_categories.dart';
import '../../core/database/enums.dart';
import '../entity_extraction/entity_extractor.dart';
import '../entity_extraction/entity_models.dart';

/// A suggestion the user may accept. Nothing is executed automatically.
class GeneratedAction {
  const GeneratedAction({
    required this.type,
    required this.title,
    required this.payload,
  });

  final ActionType type;
  final String title;
  final Map<String, Object?> payload;

  @override
  String toString() => 'GeneratedAction(${type.name}, $title)';
}

class ActionGenerator {
  const ActionGenerator({this.maxPerType = 2});

  final int maxPerType;

  List<GeneratedAction> generate({
    required ExtractionResult extraction,
    required String categorySlug,
    String? title,
    String? text,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final today = DateTime(clock.year, clock.month, clock.day);
    final out = <GeneratedAction>[];
    final counts = <ActionType, int>{};
    void add(ActionType type, String label, Map<String, Object?> payload) {
      final n = counts[type] ?? 0;
      if (n >= maxPerType) return;
      counts[type] = n + 1;
      out.add(GeneratedAction(type: type, title: label, payload: payload));
    }

    final x = extraction;
    final subject = title ?? _categoryLabel(categorySlug);

    // A date that has already passed is history, not something to act on.
    // Dates without a year are kept: the user is asked to confirm them.
    bool upcoming(Entity e) {
      final d = PartialDate.parseIso(e.normalized);
      if (d == null || !d.hasYear) return true;
      return !DateTime(d.year!, d.month, d.day).isBefore(today);
    }

    final deadlines = x.ofType(EntityType.deadline).where(upcoming).toList();
    final dates = x.ofType(EntityType.date).where(upcoming).toList();
    final allDates = x.ofType(EntityType.date).toList();
    final address = x.ofType(EntityType.address).firstOrNull;

    final flight = x.ofType(EntityType.flightReference).firstOrNull;
    final trip = flight == null ? null : _TripDetails.parse(text ?? '');
    final link = x.ofType(EntityType.url).firstOrNull?.normalized;

    for (final d in deadlines) {
      add(ActionType.createReminder, 'Remind me before ${_describeDate(d)}', {
        'title': subject,
        'date': d.normalized,
        'time': d.metadata['time'],
        'isDeadline': true,
        'needsConfirmation': d.needsConfirmation,
      });
      // Deadlines also belong in the calendar people already use.
      add(
        ActionType.addCalendarEvent,
        'Add deadline to calendar · ${_describeDate(d)}',
        {
          'title': 'Deadline: $subject',
          'date': d.normalized,
          'time': d.metadata['time'],
          'description': _description([if (d.raw.isNotEmpty) d.raw, ?link]),
          'needsConfirmation': d.needsConfirmation,
        },
      );
    }

    final isEventLike =
        categorySlug == CategorySlugs.events ||
        categorySlug == CategorySlugs.travel ||
        categorySlug == CategorySlugs.personal ||
        x.has(EntityType.eventTitle);
    for (final d in dates) {
      if (deadlines.any((dl) => dl.normalized == d.normalized)) continue;
      if (flight != null) {
        // A boarding pass becomes a proper flight entry: number and route in
        // the title, departure airport as location, gate and seat as notes.
        add(
          ActionType.addCalendarEvent,
          'Add flight to calendar · ${_describeDate(d)}',
          {
            'title': trip?.route == null
                ? 'Flight ${flight.normalized}'
                : 'Flight ${flight.normalized} · ${trip!.route}',
            'date': d.normalized,
            'time': d.metadata['time'],
            'location': trip?.departure,
            'description': _description([?trip?.gateAndSeat]),
            'needsConfirmation': d.needsConfirmation,
          },
        );
      } else if (isEventLike) {
        add(
          ActionType.addCalendarEvent,
          'Add to calendar · ${_describeDate(d)}',
          {
            'title':
                x.ofType(EntityType.eventTitle).firstOrNull?.normalized ??
                subject,
            'date': d.normalized,
            'time': d.metadata['time'],
            'location': address?.normalized,
            'description': _description([?link]),
            'needsConfirmation': d.needsConfirmation,
          },
        );
      } else if (deadlines.isEmpty && categorySlug != CategorySlugs.finance) {
        // A receipt's date is when the payment happened, not a to-do.
        add(ActionType.createReminder, 'Remind me on ${_describeDate(d)}', {
          'title': subject,
          'date': d.normalized,
          'time': d.metadata['time'],
          'needsConfirmation': d.needsConfirmation,
        });
      }
    }

    final product = x.ofType(EntityType.productName).firstOrNull;
    final amount = x.ofType(EntityType.amount).firstOrNull;
    final url = x.ofType(EntityType.url).firstOrNull;
    if (categorySlug == CategorySlugs.shopping &&
        (product != null || amount != null)) {
      add(ActionType.addToWishlist, 'Add to wishlist', {
        'productName': product?.normalized ?? subject,
        ..._money(amount),
        'productUrl': url?.normalized,
      });
    }

    if (categorySlug == CategorySlugs.finance && amount != null) {
      add(ActionType.saveTransaction, 'Save payment ${amount.normalized}', {
        ..._money(amount),
        'reference': x
            .ofType(EntityType.orderReference)
            .firstOrNull
            ?.normalized,
        'date': allDates.firstOrNull?.normalized,
      });
    }

    if (flight != null) {
      add(ActionType.saveTravel, 'Save trip ${flight.normalized}', {
        'flight': flight.normalized,
        'route': trip?.route,
        'details': trip?.gateAndSeat,
        'date': dates.firstOrNull?.normalized,
        'time': dates.firstOrNull?.metadata['time'],
      });
    }

    for (final u in x.ofType(EntityType.url)) {
      add(
        ActionType.openUrl,
        'Open ${Uri.tryParse(u.normalized!)?.host ?? u.raw}',
        {'url': u.normalized},
      );
    }

    final phones = x.ofType(EntityType.phone).toList();
    final emails = x.ofType(EntityType.email).toList();
    for (final p in phones) {
      add(ActionType.callPhone, 'Call ${p.raw}', {'phone': p.normalized});
    }
    for (final e in emails) {
      add(ActionType.sendEmail, 'Email ${e.normalized}', {
        'email': e.normalized,
      });
    }
    if (phones.isNotEmpty || emails.isNotEmpty) {
      add(ActionType.saveContact, 'Save contact', {
        // In a chat the screenshot is titled with the person's name.
        if (categorySlug == CategorySlugs.messages && title != null)
          'name': title,
        'phone': phones.firstOrNull?.normalized,
        'email': emails.firstOrNull?.normalized,
      });
    }

    if (address != null) {
      add(ActionType.openMap, 'Show on map', {'address': address.normalized});
    }

    final wifi = x.ofType(EntityType.wifiCredentials).firstOrNull;
    if (wifi != null && wifi.metadata['password'] != null) {
      add(ActionType.copyWifi, 'Wi-Fi ${wifi.metadata['ssid'] ?? 'network'}', {
        'ssid': wifi.metadata['ssid'],
        'password': wifi.metadata['password'],
      });
    }

    final code = x.ofType(EntityType.codeSnippet).firstOrNull;
    if (code != null) {
      add(ActionType.copyCode, 'Copy code', {'code': code.normalized});
    }

    if ((categorySlug == CategorySlugs.education ||
            categorySlug == CategorySlugs.quotes ||
            categorySlug == CategorySlugs.food) &&
        (text?.trim().isNotEmpty ?? false)) {
      add(ActionType.saveNotes, 'Save text as note', {'title': subject});
    }

    return out;
  }

  /// Notes for the calendar event, so it still makes sense later.
  static String _description(List<String> lines) =>
      [...lines, 'Saved from a screenshot with Snaptiq'].join('\n');

  static Map<String, Object?> _money(Entity? amount) {
    if (amount == null) return const {};
    return {
      'minorUnits': amount.metadata['minorUnits'],
      'currency': amount.metadata['currency'],
      'decimals': amount.metadata['decimals'],
      'currencyAmbiguous': amount.needsConfirmation,
    };
  }

  static String _describeDate(Entity e) {
    final d = PartialDate.parseIso(e.normalized);
    if (d == null) return e.raw;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final base =
        '${d.day} ${months[d.month - 1]}${d.hasYear ? ' ${d.year}' : ''}';
    return e.needsConfirmation ? '$base (confirm)' : base;
  }

  static String _categoryLabel(String slug) =>
      systemCategories.where((c) => c.slug == slug).firstOrNull?.name ??
      'Screenshot';
}

/// Route, departure airport, gate and seat read from a boarding pass.
class _TripDetails {
  const _TripDetails({this.route, this.departure, this.gateAndSeat});

  final String? route;
  final String? departure;
  final String? gateAndSeat;

  static final _route = RegExp(
    r'([A-Za-zÀ-ÿ .\-]*?)\s*\(([A-Z]{3})\)\s*(?:→|->|>|to|-)?\s*'
    r'([A-Za-zÀ-ÿ .\-]*?)\s*\(([A-Z]{3})\)',
  );
  static final _gate = RegExp(
    r'\bgate\s*:?\s*([A-Z]?\d{1,3}[A-Z]?)\b',
    caseSensitive: false,
  );
  static final _seat = RegExp(
    r'\bseat\s*:?\s*(\d{1,2}[A-K])\b',
    caseSensitive: false,
  );

  static _TripDetails parse(String text) {
    final r = _route.firstMatch(text);
    final gate = _gate.firstMatch(text)?[1];
    final seat = _seat.firstMatch(text)?[1];
    final from = r?[1]?.trim();
    return _TripDetails(
      route: r == null ? null : '${r[2]} → ${r[4]}',
      departure: r == null
          ? null
          : (from == null || from.isEmpty
                ? '${r[2]} airport'
                : '$from (${r[2]})'),
      gateAndSeat: [
        if (gate != null) 'Gate $gate',
        if (seat != null) 'Seat $seat',
      ].join(' · ').ifEmpty,
    );
  }
}

extension on String {
  String? get ifEmpty => isEmpty ? null : this;
}
