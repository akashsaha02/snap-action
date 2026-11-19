import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapaction/core/constants/system_categories.dart';
import 'package:snapaction/core/database/app_database.dart';
import 'package:snapaction/core/services/settings_repository.dart';

import '../helpers/test_app.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  Future<int> insertScreenshot({String hash = 'abc'}) => db
      .into(db.screenshots)
      .insert(
        ScreenshotsCompanion.insert(
          localFilePath: '/tmp/$hash.png',
          contentHash: hash,
          importedAt: DateTime(2026, 11, 18),
          source: ScreenshotSource.picker,
          processingStatus: ProcessingStatus.pending,
          fileSize: 1024,
        ),
      );

  test('seeds every system category exactly once', () async {
    final rows = await db.select(db.categories).get();
    expect(rows, hasLength(systemCategories.length));
    expect(rows.every((r) => r.isSystem), isTrue);
    expect(
      rows.map((r) => r.slug).toSet(),
      systemCategories.map((c) => c.slug).toSet(),
    );
  });

  test('creates the FTS5 index', () async {
    await db.customSelect('SELECT 1').get();
    expect(db.ftsAvailable, isTrue);
    await db.customStatement(
      'INSERT INTO ${AppDatabase.ftsTable}(rowid, title, body) '
      "VALUES (1, 'Flight', 'Departure Berlin 20 December')",
    );
    final hits = await db
        .customSelect(
          'SELECT rowid FROM ${AppDatabase.ftsTable} '
          "WHERE ${AppDatabase.ftsTable} MATCH 'berlin'",
        )
        .get();
    expect(hits, hasLength(1));
  });

  test('rejects duplicate content hashes', () async {
    await insertScreenshot(hash: 'same');
    expect(() => insertScreenshot(hash: 'same'), throwsA(isA<Exception>()));
  });

  test('deleting a screenshot cascades to dependent rows', () async {
    final id = await insertScreenshot();
    await db
        .into(db.ocrResults)
        .insert(
          OcrResultsCompanion.insert(
            screenshotId: id,
            rawText: 'hello',
            textBlocksJson: '[]',
            recognizerName: 'test',
            recognizerVersion: '1',
            processedAt: DateTime(2026),
          ),
        );
    await db
        .into(db.extractedEntities)
        .insert(
          ExtractedEntitiesCompanion.insert(
            screenshotId: id,
            entityType: EntityType.email,
            rawValue: 'a@b.co',
            validationStatus: ValidationStatus.valid,
          ),
        );
    await db
        .into(db.processingJobs)
        .insert(
          ProcessingJobsCompanion.insert(
            screenshotId: id,
            jobType: JobType.process,
            status: JobStatus.queued,
          ),
        );
    final tagId = await db
        .into(db.tags)
        .insert(TagsCompanion.insert(name: 'trip'));
    await db
        .into(db.screenshotTags)
        .insert(ScreenshotTagsCompanion.insert(screenshotId: id, tagId: tagId));

    await (db.delete(db.screenshots)..where((s) => s.id.equals(id))).go();

    expect(await db.select(db.ocrResults).get(), isEmpty);
    expect(await db.select(db.extractedEntities).get(), isEmpty);
    expect(await db.select(db.processingJobs).get(), isEmpty);
    expect(await db.select(db.screenshotTags).get(), isEmpty);
    expect(await db.select(db.tags).get(), hasLength(1));
  });

  test('settings round-trip through the repository', () async {
    final repo = await SettingsRepository.load(db);
    await repo.setBool(SettingsKeys.onboardingCompleted, value: true);
    await repo.setString(SettingsKeys.themeMode, 'dark');

    final reloaded = await SettingsRepository.load(db);
    expect(reloaded.getBool(SettingsKeys.onboardingCompleted), isTrue);
    expect(reloaded.getString(SettingsKeys.themeMode), 'dark');

    await reloaded.remove(SettingsKeys.themeMode);
    final again = await SettingsRepository.load(db);
    expect(again.getString(SettingsKeys.themeMode), isNull);
  });

  test('money is stored as integer minor units', () async {
    await db
        .into(db.wishlistItems)
        .insert(
          WishlistItemsCompanion.insert(
            productName: const Value('Headphones'),
            amountMinorUnits: const Value(7999),
            currency: const Value('EUR'),
          ),
        );
    final item = await db.select(db.wishlistItems).getSingle();
    expect(item.amountMinorUnits, 7999);
  });

  group('file database', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('snapaction_db'));
    tearDown(() => dir.deleteSync(recursive: true));

    AppDatabase openFile() =>
        AppDatabase(NativeDatabase(File('${dir.path}/snapaction.sqlite')));

    test('uses write-ahead logging', () async {
      final file = openFile();
      final mode = await file
          .customSelect('PRAGMA journal_mode')
          .map((r) => r.read<String>('journal_mode'))
          .getSingle();
      expect(mode, 'wal');
      await file.close();
    });

    test('upgrades a version 1 database without losing rows', () async {
      final first = openFile();
      await first
          .into(first.screenshots)
          .insert(
            ScreenshotsCompanion.insert(
              localFilePath: '/a.png',
              contentHash: 'h',
              importedAt: DateTime(2026, 11, 1),
              source: ScreenshotSource.picker,
              processingStatus: ProcessingStatus.completed,
              fileSize: 1,
              title: const Value('Flight 5G87'),
            ),
          );
      // Recreate what a version 1 database looked like.
      await first.customStatement(
        'ALTER TABLE screenshots DROP COLUMN title_locked',
      );
      await first.customStatement('PRAGMA user_version = 1');
      await first.close();

      final second = openFile();
      final row = await second.select(second.screenshots).getSingle();
      expect(row.title, 'Flight 5G87');
      expect(row.titleLocked, isFalse);
      await second.close();
    });

    test('recovers from an interrupted first-time schema creation', () async {
      // The schema exists but the version was never recorded, as when the
      // first launch stops between creating objects and finishing.
      final first = openFile();
      await first.customStatement('PRAGMA user_version = 0');
      await first.close();

      final second = openFile();
      final categories = await second.select(second.categories).get();
      expect(categories, hasLength(systemCategories.length));
      final version = await second
          .customSelect('PRAGMA user_version')
          .map((r) => r.read<int>('user_version'))
          .getSingle();
      expect(version, second.schemaVersion);
      await second.close();
    });
  });
}
