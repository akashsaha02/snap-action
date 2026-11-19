import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:snapaction/core/database/app_database.dart';
import 'package:snapaction/features/actions/application/action_repository.dart';

import '../helpers/test_app.dart';

void main() {
  late AppDatabase db;
  late ActionRepository repo;
  var hash = 0;

  setUp(() {
    db = createTestDatabase();
    repo = ActionRepository(db);
  });
  tearDown(() => db.close());

  Future<int> addScreenshot({
    DateTime? importedAt,
    bool needsCategoryConfirmation = false,
  }) => db
      .into(db.screenshots)
      .insert(
        ScreenshotsCompanion.insert(
          localFilePath: '/x.png',
          contentHash: 'h${hash++}',
          importedAt: importedAt ?? DateTime(2026),
          source: ScreenshotSource.picker,
          processingStatus: ProcessingStatus.completed,
          fileSize: 1,
          needsCategoryConfirmation: Value(needsCategoryConfirmation),
        ),
      );

  Future<int> addEntity(
    int shot,
    EntityType type,
    String value, {
    ValidationStatus status = ValidationStatus.needsConfirmation,
    Map<String, Object?>? meta,
  }) => db
      .into(db.extractedEntities)
      .insert(
        ExtractedEntitiesCompanion.insert(
          screenshotId: shot,
          entityType: type,
          rawValue: value,
          normalizedValue: Value(value),
          metadataJson: Value(meta == null ? null : jsonEncode(meta)),
          validationStatus: status,
        ),
      );

  Future<int> addAction(
    int shot,
    ActionType type,
    Map<String, Object?> payload, {
    String title = 'Action',
    ActionStatus status = ActionStatus.suggested,
    DateTime? until,
  }) => db
      .into(db.suggestedActions)
      .insert(
        SuggestedActionsCompanion.insert(
          screenshotId: shot,
          actionType: type,
          title: title,
          payloadJson: jsonEncode(payload),
          status: status,
          postponedUntil: Value(until),
        ),
      );

  Future<ExtractedEntityRow> entity(int id) => (db.select(
    db.extractedEntities,
  )..where((e) => e.id.equals(id))).getSingle();

  group('needs confirmation', () {
    test('confirming a date clears the screenshot and its deadline', () async {
      final shot = await addScreenshot();
      final date = await addEntity(shot, EntityType.date, '2026-12-01');
      final deadline = await addEntity(shot, EntityType.deadline, '2026-12-01');
      final reminder = await addAction(shot, ActionType.createReminder, {
        'title': 'Pay',
        'date': '2026-12-01',
        'needsConfirmation': true,
      }, title: 'Remind me on 1 Dec 2026 (confirm)');
      expect(await repo.watchNeedingConfirmation().first, [shot]);

      await repo.confirmEntity(await entity(date));

      expect(await repo.watchNeedingConfirmation().first, isEmpty);
      expect(
        (await entity(deadline)).validationStatus,
        ValidationStatus.confirmed,
      );
      final action = (await repo.byId(reminder))!;
      expect(action.title, 'Remind me on 1 Dec 2026');
      expect(
        ActionRepository.decode(action.payloadJson)['needsConfirmation'],
        isFalse,
      );
    });

    test('rejecting an amount clears it and dismisses the payment', () async {
      final shot = await addScreenshot();
      final amount = await addEntity(
        shot,
        EntityType.amount,
        r'USD 12.00',
        meta: {'minorUnits': 1200, 'currency': 'USD', 'decimals': 2},
      );
      final payment = await addAction(shot, ActionType.saveTransaction, {
        'minorUnits': 1200,
        'currency': 'USD',
        'decimals': 2,
        'currencyAmbiguous': true,
      });
      expect(await repo.watchNeedingConfirmation().first, [shot]);

      await repo.rejectEntity(await entity(amount));

      expect(await repo.watchNeedingConfirmation().first, isEmpty);
      expect(
        (await entity(amount)).validationStatus,
        ValidationStatus.rejected,
      );
      expect((await repo.byId(payment))!.status, ActionStatus.dismissed);
    });

    test('correcting a year-less date fills it in everywhere', () async {
      final shot = await addScreenshot();
      final date = await addEntity(
        shot,
        EntityType.date,
        '--03-15',
        meta: {'yearMissing': true},
      );
      final reminder = await addAction(shot, ActionType.createReminder, {
        'title': 'Concert',
        'date': '--03-15',
        'needsConfirmation': true,
      }, title: 'Remind me on 15 Mar (confirm)');

      await repo.correctEntity(
        await entity(date),
        normalized: '2027-03-15',
        metadata: {'yearMissing': false},
      );

      final row = await entity(date);
      expect(row.normalizedValue, '2027-03-15');
      expect(row.validationStatus, ValidationStatus.confirmed);
      expect(await repo.watchNeedingConfirmation().first, isEmpty);
      final action = (await repo.byId(reminder))!;
      expect(action.title, 'Remind me on 15 Mar 2027');
      final payload = ActionRepository.decode(action.payloadJson);
      expect(payload['date'], '2027-03-15');
      expect(payload['needsConfirmation'], isFalse);
    });

    test(
      'mark all as checked confirms dates, amounts and categories',
      () async {
        final a = await addScreenshot();
        final b = await addScreenshot(needsCategoryConfirmation: true);
        final untouched = await addScreenshot();
        await addEntity(a, EntityType.date, '2026-12-01');
        await addEntity(a, EntityType.amount, 'USD 1.00');
        final other = await addEntity(untouched, EntityType.date, '2026-12-02');
        expect(
          await repo.watchNeedingConfirmation().first,
          unorderedEquals([a, b, untouched]),
        );

        await repo.confirmAll([a, b]);

        expect(await repo.watchNeedingConfirmation().first, [untouched]);
        expect(
          (await entity(other)).validationStatus,
          ValidationStatus.needsConfirmation,
        );
      },
    );
  });

  group('pending suggestions', () {
    test('a postponed suggestion comes back on a long-lived stream', () async {
      final shot = await addScreenshot();
      final visible = await addAction(shot, ActionType.openUrl, {
        'url': 'https://example.com',
      });
      // Stored with second precision, so round up to the next full second.
      final now = DateTime.now();
      final until = DateTime.fromMillisecondsSinceEpoch(
        (now.millisecondsSinceEpoch ~/ 1000 + 2) * 1000,
      );
      final postponed = await addAction(
        shot,
        ActionType.openUrl,
        {'url': 'https://later.example.com'},
        status: ActionStatus.postponed,
        until: until,
      );

      final seen = <List<int>>[];
      final comesBack = Completer<void>();
      final sub = repo.watchPending().listen((items) {
        final ids = [for (final i in items) i.action.id];
        seen.add(ids);
        if (ids.contains(postponed) && !comesBack.isCompleted) {
          comesBack.complete();
        }
      });
      addTearDown(sub.cancel);

      await comesBack.future.timeout(const Duration(seconds: 6));
      expect(seen.first, [visible]);
      expect(seen.last, unorderedEquals([visible, postponed]));
    });

    test('time-bound suggestions come first, soonest first', () async {
      final now = DateTime(2026, 5, 10);
      final older = await addScreenshot(importedAt: DateTime(2026, 5, 1));
      final newer = await addScreenshot(importedAt: DateTime(2026, 5, 9));
      final link = await addAction(newer, ActionType.openUrl, {
        'url': 'https://example.com',
      });
      final oldLink = await addAction(older, ActionType.openUrl, {
        'url': 'https://old.example.com',
      });
      final later = await addAction(older, ActionType.addCalendarEvent, {
        'title': 'Later',
        'date': '2026-06-01',
      });
      final soon = await addAction(newer, ActionType.createReminder, {
        'title': 'Soon',
        'date': '2026-05-12',
      });
      final past = await addAction(newer, ActionType.createReminder, {
        'title': 'Past',
        'date': '2026-01-01',
      });

      final items = await repo.watchPending(now: now).first;
      expect(
        [for (final i in items) i.action.id],
        [soon, later, link, past, oldLink],
      );
    });
  });
}
