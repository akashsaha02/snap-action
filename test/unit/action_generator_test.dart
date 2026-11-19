import 'package:flutter_test/flutter_test.dart';
import 'package:snapaction/core/constants/system_categories.dart';
import 'package:snapaction/core/database/enums.dart';
import 'package:snapaction/services/action_generation/action_generator.dart';
import 'package:snapaction/services/processing/screenshot_analyzer.dart';

import '../fixtures/ocr_samples.dart';

void main() {
  const analyzer = ScreenshotAnalyzer();
  // The fixtures date things in March 2026; pin "now" before that.
  final now = DateTime(2026, 1, 10);
  List<GeneratedAction> actionsFor(
    String text, {
    String? locked,
    DateTime? at,
  }) => analyzer
      .analyze(text, lockedCategorySlug: locked, now: at ?? now)
      .actions;
  GeneratedAction first(List<GeneratedAction> a, ActionType t) =>
      a.firstWhere((x) => x.type == t);
  Set<ActionType> types(List<GeneratedAction> a) =>
      a.map((x) => x.type).toSet();

  test('shopping: wishlist with integer price', () {
    final a = actionsFor(shoppingProduct);
    final wish = first(a, ActionType.addToWishlist);
    expect(wish.payload['productName'], 'Wireless Headphones Pro');
    expect(wish.payload['minorUnits'], 4999);
    expect(wish.payload['currency'], 'EUR');
  });

  test('event: calendar entry with date and time', () {
    final a = actionsFor(conferencePoster);
    final cal = first(a, ActionType.addCalendarEvent);
    expect(cal.payload['date'], '2026-03-15');
    expect(cal.payload['time'], '09:00');
    expect(cal.payload['title'], 'Flutter Forward Conference');
    expect(cal.payload['needsConfirmation'], isFalse);
    expect(types(a), contains(ActionType.openUrl));
  });

  test('deadline: reminder flagged as deadline', () {
    final a = actionsFor(assignment);
    final r = first(a, ActionType.createReminder);
    expect(r.payload['isDeadline'], isTrue);
    expect(r.payload['date'], '2026-03-15');
    expect(r.payload['time'], '23:59');
  });

  test('dates without year produce reminders that need confirmation', () {
    final a = actionsFor(
      'Pay rent by 15 March',
      locked: CategorySlugs.personal,
    );
    final r = a.firstWhere(
      (x) =>
          x.type == ActionType.createReminder ||
          x.type == ActionType.addCalendarEvent,
    );
    expect(r.payload['date'], '--03-15');
    expect(r.payload['needsConfirmation'], isTrue);
    expect(r.title, contains('(confirm)'));
  });

  test('finance: transaction with reference', () {
    final t = first(actionsFor(receipt), ActionType.saveTransaction);
    expect(t.payload['minorUnits'], 2350);
    expect(t.payload['reference'], 'TXN123456');
  });

  test('travel: trip with flight number', () {
    final t = first(actionsFor(boardingPass), ActionType.saveTravel);
    expect(t.payload['flight'], 'LH1234');
    expect(t.payload['date'], '2026-03-15');
  });

  test('contact details: call, email and save contact', () {
    final a = actionsFor(
      'Dr. Smith\nPhone: +44 20 7946 0958\nsmith@example.org',
    );
    expect(
      types(a),
      containsAll([
        ActionType.callPhone,
        ActionType.sendEmail,
        ActionType.saveContact,
      ]),
    );
    expect(first(a, ActionType.callPhone).payload['phone'], '+442079460958');
  });

  test('Wi-Fi and code copy actions', () {
    final wifi = first(actionsFor(wifiCard), ActionType.copyWifi);
    expect(wifi.payload, {'ssid': 'Guest Lounge', 'password': 'hunter22'});
    expect(types(actionsFor(codeSnippet)), contains(ActionType.copyCode));
  });

  test('no actions for plain text', () {
    expect(actionsFor('hello there'), isEmpty);
  });

  test('at most two actions per type', () {
    final text = List.generate(
      5,
      (i) => 'https://site$i.example.com',
    ).join('\n');
    expect(
      actionsFor(text).where((a) => a.type == ActionType.openUrl),
      hasLength(2),
    );
  });

  group('suggestion quality', () {
    test('no reminder or calendar entry for a date that has passed', () {
      final a = actionsFor(conferencePoster, at: DateTime(2026, 11, 18));
      expect(types(a), isNot(contains(ActionType.addCalendarEvent)));
      final d = actionsFor(assignment, at: DateTime(2026, 11, 18));
      expect(types(d), isNot(contains(ActionType.createReminder)));
    });

    test('the deadline day itself still counts as upcoming', () {
      final a = actionsFor(assignment, at: DateTime(2026, 3, 15, 20));
      expect(types(a), contains(ActionType.createReminder));
    });

    test('a receipt date does not become a reminder', () {
      final a = actionsFor(receipt, at: DateTime(2026, 5, 1));
      expect(types(a), isNot(contains(ActionType.createReminder)));
      expect(types(a), contains(ActionType.saveTransaction));
      final pay = first(a, ActionType.saveTransaction);
      expect(pay.payload['date'], '2026-05-12');
    });

    test('a status bar is not read as a flight or address', () {
      final a = actionsFor('9:41\n5G 87%\n$receipt\nPaid with Visa 4821');
      expect(types(a), isNot(contains(ActionType.saveTravel)));
      expect(types(a), isNot(contains(ActionType.openMap)));
      final title = analyzer.analyze('10:18\n5G 87%\n$boardingPass').title;
      expect(title, 'Flight LH1234');
    });

    test('a course code before the next line is not an address', () {
      final a = actionsFor('Course: CS 4410\nMax. 10 pages, PDF only.');
      expect(types(a), isNot(contains(ActionType.openMap)));
    });

    test('a real postal address is still found', () {
      final a = actionsFor('Meet at Herrengasse 14\n1010 Wien');
      expect(types(a), contains(ActionType.openMap));
    });
  });

  group('handoff to other apps', () {
    test('a boarding pass becomes a flight calendar entry', () {
      final a = actionsFor(boardingPass);
      final cal = first(a, ActionType.addCalendarEvent);
      expect(cal.payload['title'], 'Flight LH1234 · FRA → LIS');
      expect(cal.payload['location'], 'Frankfurt (FRA)');
      expect(cal.payload['date'], '2026-03-15');
      expect(cal.payload['time'], '10:30');
      expect(cal.payload['description'], contains('Gate B12 · Seat 14C'));
      final trip = first(a, ActionType.saveTravel);
      expect(trip.payload['route'], 'FRA → LIS');
    });

    test('a deadline can also go to the calendar', () {
      final a = actionsFor(assignment);
      final cal = first(a, ActionType.addCalendarEvent);
      expect(cal.title, startsWith('Add deadline to calendar'));
      expect(cal.payload['title'], startsWith('Deadline: '));
      expect(cal.payload['description'], contains('Submission deadline'));
    });

    test('an event keeps its link in the calendar notes', () {
      final cal = first(
        actionsFor(conferencePoster),
        ActionType.addCalendarEvent,
      );
      expect(
        cal.payload['description'],
        contains('https://flutter.example.com'),
      );
    });

    test('Wi-Fi suggestion names the network', () {
      final w = first(actionsFor(wifiCard), ActionType.copyWifi);
      expect(w.title, 'Wi-Fi Guest Lounge');
      expect(w.payload['password'], 'hunter22');
    });
  });

  group('titles and details read from real screenshots', () {
    test('a deadline screenshot is named after what is due', () {
      final t = analyzer
          .analyze(
            '9:41\nUniversity Portal\nMachine Learning - Assignment 3\n'
            'Submission deadline: 25 November 2026, 23:59\nCourse: CS 4410',
            now: now,
          )
          .title;
      expect(t, 'Machine Learning - Assignment 3');
    });

    test('a job post is named after the role', () {
      final t = analyzer
          .analyze(
            'Jobs\nWe are hiring: Senior Flutter Developer\nAcme · Remote\n'
            'Apply now - application deadline 30 November 2026',
            now: now,
          )
          .title;
      expect(t, 'We are hiring: Senior Flutter Developer');
    });

    test('with OCR sizes the biggest heading wins over long body text', () {
      const text =
          'Jobs\nWe are hiring: Senior Flutter Developer\n'
          'Acme Apps · Full-time · Remote\n'
          'Requirements: 3+ years of experience with Flutter\n'
          'Apply now - application deadline 30 November 2026';
      final t = analyzer
          .analyze(
            text,
            now: now,
            lineHeights: const {
              'Jobs': 54,
              'We are hiring: Senior Flutter Developer': 50,
              'Acme Apps · Full-time · Remote': 42,
              'Requirements: 3+ years of experience with Flutter': 38,
              'Apply now - application deadline 30 November 2026': 38,
            },
          )
          .title;
      expect(t, 'We are hiring: Senior Flutter Developer');
    });

    test('code is titled as code', () {
      expect(analyzer.analyze(codeSnippet, now: now).title, 'Code snippet');
    });

    test('the route is found even when OCR drops the arrow', () {
      final cal = first(
        actionsFor(boardingPass.replaceAll('→', '')),
        ActionType.addCalendarEvent,
      );
      expect(cal.payload['title'], 'Flight LH1234 · FRA → LIS');
    });

    test("a contact from a chat carries the person's name", () {
      final c = first(
        actionsFor('Anna\nonline\nCall me: +43 660 1234567'),
        ActionType.saveContact,
      );
      expect(c.payload['name'], 'Anna');
    });
  });
}
