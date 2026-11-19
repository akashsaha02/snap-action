// One-off generator for test/fixtures/db/schema_v2.sqlite, run with the
// schema-2 code before the schema-3 migration was written:
//   flutter test test/fixtures/db/generate_schema_v2_test.dart
// It is skipped unless GENERATE_DB_FIXTURES=1 so CI never rewrites the
// fixture. Keep the committed .sqlite file; this script documents how it
// was made.
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapaction/core/database/app_database.dart';

void main() {
  final generate = Platform.environment['GENERATE_DB_FIXTURES'] == '1';

  test('generate schema 2 fixture', skip: !generate, () async {
    final file = File('test/fixtures/db/schema_v2.sqlite');
    if (file.existsSync()) file.deleteSync();
    final db = AppDatabase(NativeDatabase(file));
    final now = DateTime(2026, 11, 18, 10, 30);

    final travel = await (db.select(
      db.categories,
    )..where((c) => c.slug.equals('travel'))).getSingle();
    final custom = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            slug: 'thesis',
            name: 'Thesis',
            icon: 'school',
            color: 0xFF7C3AED,
          ),
        );

    Future<int> shot(String hash, String title, {bool locked = false}) => db
        .into(db.screenshots)
        .insert(
          ScreenshotsCompanion.insert(
            originalFilename: Value('$hash.png'),
            localFilePath: '/data/app/screenshots/$hash.png',
            thumbnailPath: Value('/data/app/thumbs/$hash.jpg'),
            contentHash: 'sha-$hash',
            perceptualHash: const Value('0f0f0f0f0f0f0f0f'),
            title: Value(title),
            titleLocked: Value(locked),
            importedAt: now,
            capturedAt: Value(now.subtract(const Duration(days: 1))),
            source: ScreenshotSource.picker,
            processingStatus: ProcessingStatus.completed,
            fileSize: 123456,
            imageWidth: const Value(1080),
            imageHeight: const Value(2400),
          ),
        );

    final a = await shot('boarding', 'Flight LH1234');
    final b = await shot('receipt', 'Lunch receipt', locked: true);
    final c = await shot('notes', 'Thesis outline');

    await (db.update(db.screenshots)..where((s) => s.id.equals(a))).write(
      ScreenshotsCompanion(
        primaryCategoryId: Value(travel.id),
        isFavorite: const Value(true),
      ),
    );
    await (db.update(db.screenshots)..where((s) => s.id.equals(c))).write(
      ScreenshotsCompanion(
        primaryCategoryId: Value(custom),
        categoryLocked: const Value(true),
        isArchived: const Value(true),
        isSensitive: const Value(true),
      ),
    );

    for (final (id, text, corrected) in [
      (a, 'Boarding pass\nFlight LH 1234\nFrankfurt (FRA) Lisbon (LIS)', null),
      (b, 'Payment successful\nAmount paid: €23.50', 'Paid €23.50 at Bakery'),
      (c, 'Chapter 1 Introduction\nChapter 2 Method', null),
    ]) {
      await db
          .into(db.ocrResults)
          .insert(
            OcrResultsCompanion.insert(
              screenshotId: id,
              rawText: text,
              correctedText: Value(corrected),
              textBlocksJson: '[]',
              recognizerName: 'mlkit',
              recognizerVersion: '1',
              processedAt: now,
            ),
          );
    }
    await db
        .into(db.extractedEntities)
        .insert(
          ExtractedEntitiesCompanion.insert(
            screenshotId: a,
            entityType: EntityType.flightReference,
            rawValue: 'LH 1234',
            normalizedValue: const Value('LH1234'),
            validationStatus: ValidationStatus.confirmed,
          ),
        );
    final col = await db
        .into(db.collections)
        .insert(
          CollectionsCompanion.insert(
            name: 'Lisbon trip',
            icon: 'flight',
            color: 0xFFFF2E93,
          ),
        );
    await db
        .into(db.collectionItems)
        .insert(
          CollectionItemsCompanion.insert(collectionId: col, screenshotId: a),
        );
    final tag = await db
        .into(db.tags)
        .insert(TagsCompanion.insert(name: 'work'));
    await db
        .into(db.screenshotTags)
        .insert(ScreenshotTagsCompanion.insert(screenshotId: b, tagId: tag));
    await db
        .into(db.notes)
        .insert(
          NotesCompanion.insert(screenshotId: c, content: 'Ask supervisor'),
        );
    await db
        .into(db.reminders)
        .insert(
          RemindersCompanion.insert(
            screenshotId: Value(a),
            title: 'Check in',
            scheduledAt: DateTime(2026, 12, 1, 9),
            timezone: 'Asia/Dhaka',
            notificationId: 424242,
            status: ReminderStatus.scheduled,
          ),
        );
    await db
        .into(db.suggestedActions)
        .insert(
          SuggestedActionsCompanion.insert(
            screenshotId: a,
            actionType: ActionType.addCalendarEvent,
            title: 'Add flight to calendar',
            payloadJson: '{"title":"Flight LH1234"}',
            status: ActionStatus.suggested,
          ),
        );
    await db
        .into(db.wishlistItems)
        .insert(
          WishlistItemsCompanion.insert(
            screenshotId: Value(b),
            productName: const Value('Headphones'),
            amountMinorUnits: const Value(4999),
            currency: const Value('EUR'),
          ),
        );
    await db
        .into(db.processingJobs)
        .insert(
          ProcessingJobsCompanion.insert(
            screenshotId: b,
            jobType: JobType.process,
            status: JobStatus.done,
          ),
        );
    await db
        .into(db.searchHistory)
        .insert(
          SearchHistoryCompanion.insert(query: 'lisbon', searchedAt: now),
        );
    await db
        .into(db.appSettings)
        .insert(
          AppSettingsCompanion.insert(
            key: 'theme_mode',
            value: 'dark',
            updatedAt: Value(now),
          ),
        );
    await db
        .into(db.classificationRules)
        .insert(
          ClassificationRulesCompanion.insert(
            keyword: 'thesis',
            categoryId: custom,
          ),
        );

    final version = await db
        .customSelect('PRAGMA user_version')
        .map((r) => r.read<int>('user_version'))
        .getSingle();
    expect(version, 2);
    // Fold the WAL into the main file so the fixture is self-contained.
    await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
    await db.customStatement('PRAGMA journal_mode = DELETE');
    await db.close();
    expect(file.existsSync(), isTrue);
  });
}
