import 'package:flutter_test/flutter_test.dart';
import 'package:snapaction/core/database/enums.dart';
import 'package:snapaction/services/entity_extraction/entity_extractor.dart';

import '../fixtures/ocr_samples.dart';

void main() {
  const extractor = EntityExtractor();

  List<String?> values(ExtractionResult r, EntityType t) =>
      r.ofType(t).map((e) => e.normalized).toList();

  test('empty text yields nothing', () {
    final r = extractor.extract('   ');
    expect(r.entities, isEmpty);
    expect(r.isSensitive, isFalse);
  });

  test('emails are lower-cased and not re-read as links', () {
    final r = extractor.extract('Contact: Jane.Doe@Example.com');
    expect(values(r, EntityType.email), ['jane.doe@example.com']);
    expect(r.has(EntityType.url), isFalse);
  });

  test('links are normalized to http(s) only', () {
    final r = extractor.extract(
      'Visit https://example.com/path. or www.shop.de\njavascript:alert(1)',
    );
    expect(values(r, EntityType.url), [
      'https://example.com/path',
      'https://www.shop.de',
    ]);
    expect(EntityExtractor.normalizeUrl('ftp://x.org'), isNull);
    expect(EntityExtractor.normalizeUrl('localhost'), isNull);
  });

  test('phones need a prefix, context or grouping', () {
    expect(values(extractor.extract('Call +49 30 1234567'), EntityType.phone), [
      '+49301234567',
    ]);
    expect(values(extractor.extract('Tel: 0171 2345678'), EntityType.phone), [
      '01712345678',
    ]);
    expect(extractor.extract('Code 20260315').has(EntityType.phone), isFalse);
  });

  test('deadlines are tied to the keyword line', () {
    final r = extractor.extract(
      'Scholarship programme\nApplication deadline: 15 March 2026\nInfo day 2 April 2026',
    );
    expect(values(r, EntityType.deadline), ['2026-03-15']);
    expect(values(r, EntityType.date), ['2026-03-15', '2026-04-02']);
  });

  test('dates without a year are flagged and keep the partial form', () {
    final r = extractor.extract('Submit by 15 March');
    final date = r.ofType(EntityType.date).single;
    expect(date.normalized, '--03-15');
    expect(date.needsConfirmation, isTrue);
    expect(date.validationStatus, ValidationStatus.needsConfirmation);
  });

  test('time on the date line is attached to the date', () {
    final r = extractor.extract('Concert\n15 March 2026, 19:30\nDoors open');
    expect(r.ofType(EntityType.date).single.metadata['time'], '19:30');
  });

  test('amounts carry minor units and currency', () {
    final amount = extractor
        .extract('Total: 1.299,00 €')
        .ofType(EntityType.amount)
        .single;
    expect(amount.metadata['minorUnits'], 129900);
    expect(amount.metadata['currency'], 'EUR');
    expect(amount.needsConfirmation, isFalse);
  });

  test('order references from keywords and prefixes', () {
    final r = extractor.extract('Order number: 112-4455667\nInvoice INV-20391');
    expect(
      values(r, EntityType.orderReference),
      containsAll(['112-4455667', 'INV-20391']),
    );
    expect(r.has(EntityType.phone), isFalse);
  });

  test('flight numbers only with flight context', () {
    final r = extractor.extract(boardingPass);
    expect(values(r, EntityType.flightReference), ['LH1234']);
    expect(
      extractor.extract('Room AB 123').has(EntityType.flightReference),
      isFalse,
    );
  });

  test('Wi-Fi QR payload and labelled credentials', () {
    final qr = extractor.extract('WIFI:T:WPA;S:CafeNet;P:secret123;;');
    final wifi = qr.ofType(EntityType.wifiCredentials).single;
    expect(wifi.metadata['ssid'], 'CafeNet');
    expect(wifi.metadata['password'], 'secret123');
    expect(qr.isSensitive, isTrue);

    final labelled = extractor.extract(
      'Wi-Fi network: Guest Lounge\nPassword: hunter22',
    );
    expect(labelled.ofType(EntityType.wifiCredentials).single.metadata, {
      'ssid': 'Guest Lounge',
      'password': 'hunter22',
    });
  });

  test('sensitive content: IBAN and Luhn-valid card numbers', () {
    expect(
      extractor.extract('IBAN DE89 3704 0044 0532 0130 00').isSensitive,
      isTrue,
    );
    expect(extractor.extract('Card 4111 1111 1111 1111').isSensitive, isTrue);
    expect(
      extractor.extract('Tracking 1234 5678 9012 3456').isSensitive,
      isFalse,
    );
    expect(extractor.extract(shoppingProduct).isSensitive, isFalse);
  });

  test('product name only with a price and shopping context', () {
    final r = extractor.extract(shoppingProduct);
    expect(values(r, EntityType.productName), ['Wireless Headphones Pro']);
    expect(r.ofType(EntityType.productName).single.needsConfirmation, isTrue);
    expect(
      extractor.extract('Wireless Headphones Pro').has(EntityType.productName),
      isFalse,
    );
  });

  test('event title with a date and event context', () {
    final r = extractor.extract(conferencePoster);
    expect(values(r, EntityType.eventTitle), ['Flutter Forward Conference']);
  });

  test('addresses always need confirmation', () {
    final r = extractor.extract('Venue: 221B Baker Street, London');
    final address = r.ofType(EntityType.address).single;
    expect(address.raw, contains('Baker Street'));
    expect(address.needsConfirmation, isTrue);

    final de = extractor.extract('Hauptstraße 12\n10115 Berlin');
    expect(de.has(EntityType.address), isTrue);
  });

  test('code blocks are detected', () {
    final r = extractor.extract(codeSnippet);
    expect(r.has(EntityType.codeSnippet), isTrue);
    expect(
      extractor.extract(shoppingProduct).has(EntityType.codeSnippet),
      isFalse,
    );
  });

  test('a URL split by OCR after a dot is joined again', () {
    final r = extractor.extract('Register at https://flutter. example.com');
    expect(values(r, EntityType.url), ['https://flutter.example.com']);
  });
}
