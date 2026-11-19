import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:snapaction/core/constants/system_categories.dart';
import 'package:snapaction/core/database/app_database.dart';
import 'package:snapaction/core/repositories/screenshot_repository.dart';
import 'package:snapaction/core/services/settings_repository.dart';
import 'package:snapaction/services/ocr/ocr_service.dart';
import 'package:snapaction/services/processing/job_runner.dart';
import 'package:snapaction/services/search/search_indexer.dart';

import '../fixtures/ocr_samples.dart';
import '../helpers/test_app.dart';

class FakeOcr implements OcrService {
  final texts = <String, String>{};
  final failing = <String>{};
  int calls = 0;

  @override
  Future<OcrOutput> recognize(String imagePath) async {
    calls++;
    if (failing.contains(imagePath)) {
      throw const OcrException('Text recognition failed: test');
    }
    return OcrOutput(
      text: texts[imagePath] ?? '',
      blocksJson: '[]',
      recognizerName: 'fake',
      recognizerVersion: '0',
    );
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  late AppDatabase db;
  late FakeOcr ocr;
  late JobRunner runner;
  late Directory dir;
  var counter = 0;

  setUp(() async {
    db = createTestDatabase();
    ocr = FakeOcr();
    dir = await Directory.systemTemp.createTemp('snapaction_jobs');
    runner = JobRunner(
      db: db,
      ocr: ocr,
      indexer: SearchIndexer(db),
      settings: await SettingsRepository.load(db),
    );
  });

  tearDown(() async {
    await runner.dispose();
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<int> addScreenshot(
    String text, {
    JobStatus job = JobStatus.queued,
  }) async {
    final file = File('${dir.path}/${counter++}.png')
      ..writeAsBytesSync([1, 2, 3]);
    ocr.texts[file.path] = text;
    final id = await db
        .into(db.screenshots)
        .insert(
          ScreenshotsCompanion.insert(
            localFilePath: file.path,
            contentHash: 'hash$counter',
            importedAt: DateTime(2026),
            source: ScreenshotSource.picker,
            processingStatus: ProcessingStatus.pending,
            fileSize: 3,
          ),
        );
    await db
        .into(db.processingJobs)
        .insert(
          ProcessingJobsCompanion.insert(
            screenshotId: id,
            jobType: JobType.process,
            status: job,
          ),
        );
    return id;
  }

  Future<ScreenshotRow> shot(int id) =>
      (db.select(db.screenshots)..where((s) => s.id.equals(id))).getSingle();

  Future<String> slugOf(int? categoryId) async => (await (db.select(
    db.categories,
  )..where((c) => c.id.equals(categoryId!))).getSingle()).slug;

  test('processes queued jobs end to end', () async {
    final id = await addScreenshot(boardingPass);
    await runner.start();
    await runner.whenIdle();

    final s = await shot(id);
    expect(s.processingStatus, ProcessingStatus.completed);
    expect(await slugOf(s.primaryCategoryId), CategorySlugs.travel);
    expect(s.title, 'Flight LH1234');
    expect(s.classificationScore, greaterThan(0));

    final ocrRow = await db.select(db.ocrResults).getSingle();
    expect(ocrRow.rawText, boardingPass);
    expect(ocrRow.recognizerName, 'fake');

    final entities = await db.select(db.extractedEntities).get();
    expect(
      entities.map((e) => e.entityType),
      contains(EntityType.flightReference),
    );
    final actions = await db.select(db.suggestedActions).get();
    expect(actions.map((a) => a.actionType), contains(ActionType.saveTravel));
    expect(actions.every((a) => a.status == ActionStatus.suggested), isTrue);

    final job = await db.select(db.processingJobs).getSingle();
    expect(job.status, JobStatus.done);
    expect(job.attemptCount, 1);

    final hits = await db
        .customSelect(
          "SELECT rowid FROM screenshot_fts WHERE screenshot_fts MATCH 'lisbon'",
        )
        .get();
    expect(hits.single.read<int>('rowid'), id);
  });

  test('never overwrites a user-locked category or title', () async {
    final id = await addScreenshot(shoppingProduct);
    final ids = await db.select(db.categories).get();
    final docs = ids.firstWhere((c) => c.slug == CategorySlugs.documents).id;
    await (db.update(db.screenshots)..where((s) => s.id.equals(id))).write(
      ScreenshotsCompanion(
        primaryCategoryId: Value(docs),
        categoryLocked: const Value(true),
        title: const Value('Gift idea'),
        titleLocked: const Value(true),
      ),
    );
    await runner.start();
    await runner.whenIdle();

    final s = await shot(id);
    expect(s.primaryCategoryId, docs);
    expect(await slugOf(s.suggestedCategoryId), CategorySlugs.shopping);
    expect(s.title, 'Gift idea');
    expect(s.needsCategoryConfirmation, isFalse);
  });

  test('failures are recorded and can be retried', () async {
    final id = await addScreenshot(receipt);
    final path = (await shot(id)).localFilePath;
    ocr.failing.add(path);
    await runner.start();
    await runner.whenIdle();

    expect((await shot(id)).processingStatus, ProcessingStatus.failed);
    expect(await runner.lastError(id), contains('Text recognition failed'));

    ocr.failing.clear();
    await runner.retry([id]);
    await runner.whenIdle();
    expect((await shot(id)).processingStatus, ProcessingStatus.completed);
    expect(await runner.lastError(id), isNull);
  });

  test('a missing image file fails cleanly', () async {
    final id = await addScreenshot(receipt);
    await File((await shot(id)).localFilePath).delete();
    await runner.start();
    await runner.whenIdle();
    expect((await shot(id)).processingStatus, ProcessingStatus.failed);
    expect(await runner.lastError(id), 'The image file is missing.');
  });

  test('re-analysis refreshes generated titles but keeps typed ones', () async {
    final id = await addScreenshot('10:18\n5G 87%\n$boardingPass');
    await (db.update(db.screenshots)..where((s) => s.id.equals(id))).write(
      const ScreenshotsCompanion(title: Value('Flight 5G87')),
    );
    await runner.start();
    await runner.whenIdle();
    expect((await shot(id)).title, 'Flight LH1234');

    await ScreenshotRepository(db).setTitle(id, 'Lisbon trip');
    await runner.reanalyze(id);
    expect((await shot(id)).title, 'Lisbon trip');
    expect((await shot(id)).titleLocked, isTrue);
  });

  test('re-analysis keeps details the user confirmed or rejected', () async {
    final id = await addScreenshot(receipt);
    await runner.start();
    await runner.whenIdle();
    final amount = await (db.select(
      db.extractedEntities,
    )..where((e) => e.entityType.equalsValue(EntityType.amount))).getSingle();
    await (db.update(
      db.extractedEntities,
    )..where((e) => e.id.equals(amount.id))).write(
      const ExtractedEntitiesCompanion(
        validationStatus: Value(ValidationStatus.confirmed),
        normalizedValue: Value('EUR 25.00'),
      ),
    );

    await runner.reanalyze(id);
    final again = await (db.select(
      db.extractedEntities,
    )..where((e) => e.entityType.equalsValue(EntityType.amount))).getSingle();
    expect(again.validationStatus, ValidationStatus.confirmed);
    expect(again.normalizedValue, 'EUR 25.00');
  });

  test('jobs interrupted by a restart are resumed', () async {
    final id = await addScreenshot(receipt, job: JobStatus.running);
    await runner.start();
    await runner.whenIdle();
    expect((await shot(id)).processingStatus, ProcessingStatus.completed);
  });

  test('edited text is re-analyzed without OCR, keeping dismissed actions dismissed', () async {
    final id = await addScreenshot('nothing useful');
    await runner.start();
    await runner.whenIdle();
    expect(await db.select(db.suggestedActions).get(), isEmpty);
    final callsBefore = ocr.calls;

    await runner.updateText(id, 'Visit https://example.com');
    final link = await db.select(db.suggestedActions).getSingle();
    expect(link.actionType, ActionType.openUrl);
    await (db.update(
      db.suggestedActions,
    )..where((a) => a.id.equals(link.id))).write(
      const SuggestedActionsCompanion(status: Value(ActionStatus.dismissed)),
    );

    await runner.reanalyze(id);
    final all = await db.select(db.suggestedActions).get();
    expect(all, hasLength(1));
    expect(all.single.status, ActionStatus.dismissed);
    expect(ocr.calls, callsBefore);

    final ocrRow = await db.select(db.ocrResults).getSingle();
    expect(ocrRow.correctedText, 'Visit https://example.com');
    expect(ocrRow.rawText, 'nothing useful');
  });

  test('OCR can be disabled in settings', () async {
    final settings = await SettingsRepository.load(db);
    await settings.setBool(SettingsKeys.ocrEnabled, value: false);
    await runner.dispose();
    runner = JobRunner(
      db: db,
      ocr: ocr,
      indexer: SearchIndexer(db),
      settings: settings,
    );
    final id = await addScreenshot(receipt);
    await runner.start();
    await runner.whenIdle();
    expect(ocr.calls, 0);
    expect((await shot(id)).processingStatus, ProcessingStatus.completed);
  });

  test('sensitive text marks the screenshot sensitive', () async {
    final id = await addScreenshot(wifiCard);
    await runner.start();
    await runner.whenIdle();
    expect((await shot(id)).isSensitive, isTrue);
  });
}
