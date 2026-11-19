import 'package:flutter_test/flutter_test.dart';
import 'package:snapaction/services/entity_extraction/date_parser.dart';
import 'package:snapaction/services/entity_extraction/entity_models.dart';
import 'package:snapaction/services/entity_extraction/money_parser.dart';
import 'package:snapaction/services/entity_extraction/text_normalizer.dart';

void main() {
  group('TextNormalizer', () {
    test('unifies quotes, dashes and whitespace but keeps lines', () {
      final out = TextNormalizer.normalize(
        'We\u2019re  hiring\u200B\r\n\u201CSenior\u201D \u2013 dev\n\n\n\nEnd',
      );
      expect(out, 'We\'re hiring\n"Senior" - dev\n\nEnd');
    });
  });

  group('DateParser.findDates', () {
    String iso(String text, {DateOrder order = DateOrder.dmy}) =>
        DateParser.findDates(text, order: order).single.date.iso;

    test('ISO dates', () => expect(iso('Due 2026-03-15.'), '2026-03-15'));

    test('day month name year in several languages', () {
      expect(iso('15 March 2026'), '2026-03-15');
      expect(iso('15th of March, 2026'), '2026-03-15');
      expect(iso('15. März 2026'), '2026-03-15');
      expect(iso('15 mars 2026'), '2026-03-15');
      expect(iso('15 de marzo de 2026'), '2026-03-15');
    });

    test('month name day year', () {
      expect(iso('March 15, 2026'), '2026-03-15');
      expect(iso('Sept 3rd 2026'), '2026-09-03');
    });

    test('missing year is never guessed', () {
      final d = DateParser.findDates('Deadline: 15 March').single;
      expect(d.date.iso, '--03-15');
      expect(d.date.hasYear, isFalse);
      expect(d.needsConfirmation, isTrue);
    });

    test(
      'ambiguous numeric dates follow the setting and keep the other reading',
      () {
        final dmy = DateParser.findDates('03/04/2026').single;
        expect(dmy.date.iso, '2026-04-03');
        expect(dmy.ambiguous, isTrue);
        expect(dmy.alternative?.iso, '2026-03-04');
        expect(dmy.needsConfirmation, isTrue);

        final mdy = DateParser.findDates(
          '03/04/2026',
          order: DateOrder.mdy,
        ).single;
        expect(mdy.date.iso, '2026-03-04');
      },
    );

    test('unambiguous numeric dates are not flagged', () {
      final d = DateParser.findDates('25.12.2026', order: DateOrder.mdy).single;
      expect(d.date.iso, '2026-12-25');
      expect(d.needsConfirmation, isFalse);
    });

    test('rejects impossible dates and version numbers', () {
      expect(DateParser.findDates('31/02/2026'), isEmpty);
      expect(DateParser.findDates('version 1.2.3'), isEmpty);
      expect(DateParser.findDates('You may 5 times'), isEmpty);
    });
  });

  group('DateParser.findTimes', () {
    List<String> times(String t) =>
        DateParser.findTimes(t).map((m) => m.normalized).toList();

    test('24 hour, 12 hour and French notation', () {
      expect(times('Doors 10:30'), ['10:30']);
      expect(times('Starts 7 pm'), ['19:00']);
      expect(times('7:30 PM'), ['19:30']);
      expect(times('12 am'), ['00:00']);
      expect(times('10h30'), ['10:30']);
    });

    test('decimal numbers are not times', () {
      expect(times('Price 12.50'), isEmpty);
    });
  });

  group('MoneyParser', () {
    MoneyAmount one(String text) => MoneyParser.find(text).single.amount;

    test('prefix and suffix symbols with local separators', () {
      expect(one('€49.99').minorUnits, 4999);
      expect(one('49,99 €').minorUnits, 4999);
      expect(one('1.299,00 €').minorUnits, 129900);
      expect(one('USD 1,299.00').minorUnits, 129900);
      expect(one('£0.10').minorUnits, 10);
      expect(one('49,99 €').currency, 'EUR');
    });

    test('zero-decimal currencies', () {
      final yen = one('¥1,500');
      expect(yen.currency, 'JPY');
      expect(yen.decimals, 0);
      expect(yen.minorUnits, 1500);
    });

    test('Bangladeshi taka spellings', () {
      expect(one('Tk 1,500').currency, 'BDT');
      expect(one('Tk 1,500').minorUnits, 150000);
      expect(one('৳250').minorUnits, 25000);
    });

    test('bare dollar sign is flagged as ambiguous', () {
      expect(one(r'$20').currencyAmbiguous, isTrue);
      expect(one(r'US$20').currencyAmbiguous, isFalse);
    });

    test('formatted value uses integer arithmetic', () {
      expect(one('€0.07').formatted, 'EUR 0.07');
      expect(one('¥980').formatted, 'JPY 980');
    });

    test('numbers without currency are ignored', () {
      expect(MoneyParser.find('Order 12345 qty 2'), isEmpty);
    });
  });
}
