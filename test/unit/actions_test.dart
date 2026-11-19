import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:snapaction/core/database/app_database.dart';
import 'package:snapaction/features/actions/application/action_repository.dart';
import 'package:snapaction/features/actions/application/external_intents.dart';
import 'package:snapaction/features/wishlist/application/wishlist_repository.dart';
import 'package:snapaction/services/entity_extraction/money_parser.dart';

import '../helpers/test_app.dart';

void main() {
  group('ExternalIntents', () {
    test('web accepts only http(s) with a real host', () {
      expect(ExternalIntents.web('https://shop.example.com/p?id=1'), isNotNull);
      expect(ExternalIntents.web('http://example.org'), isNotNull);
      expect(ExternalIntents.web('javascript:alert(1)'), isNull);
      expect(ExternalIntents.web('file:///data/data/x'), isNull);
      expect(ExternalIntents.web('intent://scan/#Intent;end'), isNull);
      expect(ExternalIntents.web('https://localhost'), isNull);
      expect(ExternalIntents.web('https://user:pw@evil.example.com'), isNull);
      expect(ExternalIntents.web(null), isNull);
    });

    test('dial strips formatting and rejects non-numbers', () {
      expect(
        ExternalIntents.dial('+49 (30) 123-4567').toString(),
        'tel:+49301234567',
      );
      expect(ExternalIntents.dial('12'), isNull);
      expect(ExternalIntents.dial('call me;rm'), isNull);
    });

    test('email builds a mailto only for valid addresses', () {
      expect(
        ExternalIntents.email('a.b@example.co.uk').toString(),
        'mailto:a.b@example.co.uk',
      );
      expect(ExternalIntents.email('a@b'), isNull);
      expect(ExternalIntents.email('x@example.com?bcc=all@corp.com'), isNull);
    });

    test('map encodes the address as a geo query', () {
      final uri = ExternalIntents.map('Main St 5, 10115 Berlin')!;
      expect(uri.scheme, 'geo');
      expect(uri.queryParameters['q'], 'Main St 5, 10115 Berlin');
      expect(ExternalIntents.map('   '), isNull);
    });
  });

  group('MoneyParser user input', () {
    test('parses to minor units without floating point', () {
      expect(MoneyParser.parseUserAmount('49.99'), 4999);
      expect(MoneyParser.parseUserAmount('49,9'), 4990);
      expect(MoneyParser.parseUserAmount('0.1'), 10);
      expect(MoneyParser.parseUserAmount('1299'), 129900);
      expect(MoneyParser.parseUserAmount('1500', decimals: 0), 1500);
    });

    test('rejects malformed input', () {
      expect(MoneyParser.parseUserAmount('12.345'), isNull);
      expect(MoneyParser.parseUserAmount('1.5', decimals: 0), isNull);
      expect(MoneyParser.parseUserAmount('-3'), isNull);
      expect(MoneyParser.parseUserAmount('abc'), isNull);
    });

    test('round-trips through formatUserAmount', () {
      expect(MoneyParser.formatUserAmount(4999), '49.99');
      expect(MoneyParser.formatUserAmount(5), '0.05');
      expect(MoneyParser.formatUserAmount(1500, decimals: 0), '1500');
      expect(MoneyParser.decimalsFor('jpy'), 0);
      expect(MoneyParser.decimalsFor('EUR'), 2);
    });
  });

  group('repositories', () {
    late AppDatabase db;

    setUp(() => db = createTestDatabase());
    tearDown(() => db.close());

    Future<int> addScreenshot({bool archived = false}) => db
        .into(db.screenshots)
        .insert(
          ScreenshotsCompanion.insert(
            localFilePath: '/x.png',
            contentHash: 'h${DateTime.now().microsecondsSinceEpoch}',
            importedAt: DateTime(2026),
            source: ScreenshotSource.picker,
            processingStatus: ProcessingStatus.completed,
            fileSize: 1,
            isArchived: Value(archived),
          ),
        );

    Future<int> addAction(
      int shot, {
      ActionStatus status = ActionStatus.suggested,
      DateTime? until,
    }) => db
        .into(db.suggestedActions)
        .insert(
          SuggestedActionsCompanion.insert(
            screenshotId: shot,
            actionType: ActionType.openUrl,
            title: 'Open example.com',
            payloadJson: jsonEncode({'url': 'https://example.com'}),
            status: status,
            postponedUntil: Value(until),
          ),
        );

    test('pending actions exclude dismissed, accepted, archived and future postponed', () async {
      final repo = ActionRepository(db);
      final shot = await addScreenshot();
      final archived = await addScreenshot(archived: true);
      final visible = await addAction(shot);
      await addAction(shot, status: ActionStatus.dismissed);
      await addAction(shot, status: ActionStatus.accepted);
      await addAction(archived);
      await addAction(
        shot,
        status: ActionStatus.postponed,
        until: DateTime(2026, 6, 1),
      );
      final due = await addAction(
        shot,
        status: ActionStatus.postponed,
        until: DateTime(2026, 5, 1),
      );

      final pending = await repo.watchPending(now: DateTime(2026, 5, 10)).first;
      expect(pending.map((p) => p.action.id), unorderedEquals([visible, due]));
      expect(pending.first.payload['url'], 'https://example.com');
    });

    test('setStatus and updatePayload persist', () async {
      final repo = ActionRepository(db);
      final id = await addAction(await addScreenshot());
      await repo.updatePayload(id, {'url': 'https://fixed.example.com'});
      await repo.setStatus(
        id,
        ActionStatus.postponed,
        postponedUntil: DateTime(2026, 7),
      );
      final row = (await repo.byId(id))!;
      expect(
        ActionRepository.decode(row.payloadJson)['url'],
        'https://fixed.example.com',
      );
      expect(row.status, ActionStatus.postponed);
      expect(row.postponedUntil, DateTime(2026, 7));
      expect(ActionRepository.decode('not json'), isEmpty);
    });

    test('wishlist validates and totals per currency', () async {
      final repo = WishlistRepository(db);
      await repo.add(
        const WishlistDraft(
          productName: 'Headphones',
          minorUnits: 4999,
          currency: 'EUR',
        ),
      );
      await repo.add(
        const WishlistDraft(
          productName: 'Case',
          minorUnits: 1001,
          currency: 'EUR',
        ),
      );
      final bought = await repo.add(
        const WishlistDraft(
          productName: 'Book',
          minorUnits: 1500,
          currency: 'EUR',
        ),
      );
      await repo.add(
        const WishlistDraft(
          productName: 'Game',
          minorUnits: 6000,
          currency: 'JPY',
        ),
      );
      await repo.setPurchased(bought, purchased: true);

      final items = await repo.watchAll().first;
      expect(items.last.item.purchased, isTrue);
      expect(WishlistRepository.openTotals(items), {'EUR': 6000, 'JPY': 6000});

      expect(
        () => repo.add(const WishlistDraft(productName: ' ')),
        throwsArgumentError,
      );
      expect(
        () => repo.add(const WishlistDraft(productName: 'X', minorUnits: 5)),
        throwsArgumentError,
      );
      expect(
        () => repo.add(
          const WishlistDraft(
            productName: 'X',
            minorUnits: -5,
            currency: 'EUR',
          ),
        ),
        throwsArgumentError,
      );
    });

    test('wishlist items are removed with their screenshot', () async {
      final repo = WishlistRepository(db);
      final shot = await addScreenshot();
      await repo.add(WishlistDraft(productName: 'Lamp', screenshotId: shot));
      await (db.delete(db.screenshots)..where((s) => s.id.equals(shot))).go();
      expect(await repo.watchAll().first, isEmpty);
    });
  });
}
