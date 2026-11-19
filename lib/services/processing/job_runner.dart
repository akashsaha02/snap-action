import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import '../../core/database/app_database.dart';
import '../../core/services/settings_repository.dart';
import '../classification/classifier.dart';
import '../entity_extraction/entity_models.dart';
import '../ocr/ocr_service.dart';
import '../search/search_indexer.dart';
import 'screenshot_analyzer.dart';

/// Drains the durable `processing_jobs` queue: OCR -> extraction ->
/// classification -> actions -> search index. Jobs survive restarts; jobs
/// interrupted mid-run are queued again on [start].
class JobRunner {
  JobRunner({
    required this._db,
    required this._ocr,
    required this._indexer,
    required this._settings,
    this.analyzer = const ScreenshotAnalyzer(),
  });

  final AppDatabase _db;
  final OcrService _ocr;
  final SearchIndexer _indexer;
  final SettingsRepository _settings;
  final ScreenshotAnalyzer analyzer;

  bool _started = false;
  bool _disposed = false;
  int _active = 0;
  Completer<void>? _idle;

  int get concurrency =>
      _settings.getInt(SettingsKeys.ocrConcurrency, fallback: 1).clamp(1, 2);

  bool get ocrEnabled =>
      _settings.getBool(SettingsKeys.ocrEnabled, fallback: true);

  DateOrder get dateOrder =>
      DateOrder.values.asNameMap()[_settings.getString(
        SettingsKeys.dateOrder,
      )] ??
      DateOrder.dmy;

  bool get isBusy => _active > 0;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    await (_db.update(_db.processingJobs)
          ..where((j) => j.status.equalsValue(JobStatus.running)))
        .write(const ProcessingJobsCompanion(status: Value(JobStatus.queued)));
    await (_db.update(_db.screenshots)..where(
          (s) => s.processingStatus.equalsValue(ProcessingStatus.processing),
        ))
        .write(
          const ScreenshotsCompanion(
            processingStatus: Value(ProcessingStatus.pending),
          ),
        );
    kick();
  }

  /// Wakes workers after new jobs were queued.
  void kick() {
    if (_disposed || !_started) return;
    while (_active < concurrency) {
      _active++;
      unawaited(_worker());
    }
  }

  /// Completes when no worker is running.
  Future<void> whenIdle() {
    if (_active == 0) return Future.value();
    return (_idle ??= Completer<void>()).future;
  }

  Future<void> _worker() async {
    try {
      while (!_disposed) {
        final job = await _claim();
        if (job == null) break;
        await _run(job);
      }
    } finally {
      _active--;
      if (_active == 0) {
        _idle?.complete();
        _idle = null;
      }
    }
  }

  Future<ProcessingJobRow?> _claim() => _db.transaction(() async {
    final job =
        await (_db.select(_db.processingJobs)
              ..where((j) => j.status.equalsValue(JobStatus.queued))
              ..orderBy([(j) => OrderingTerm.asc(j.id)])
              ..limit(1))
            .getSingleOrNull();
    if (job == null) return null;
    final claimed = job.copyWith(
      status: JobStatus.running,
      attemptCount: job.attemptCount + 1,
      updatedAt: DateTime.now(),
    );
    await _db.update(_db.processingJobs).replace(claimed);
    return claimed;
  });

  Future<void> _run(ProcessingJobRow job) async {
    final id = job.screenshotId;
    final shot = await _screenshot(id);
    if (shot == null) {
      await (_db.delete(
        _db.processingJobs,
      )..where((j) => j.id.equals(job.id))).go();
      return;
    }
    await _setStatus(id, ProcessingStatus.processing);
    try {
      final existing = await _ocrRow(id);
      String text;
      if (ocrEnabled) {
        if (!File(shot.localFilePath).existsSync()) {
          throw const OcrException('The image file is missing.');
        }
        final out = await _ocr.recognize(shot.localFilePath);
        await _db
            .into(_db.ocrResults)
            .insert(
              OcrResultsCompanion.insert(
                screenshotId: id,
                rawText: out.text,
                correctedText: Value(existing?.correctedText),
                textBlocksJson: out.blocksJson,
                recognizerName: out.recognizerName,
                recognizerVersion: out.recognizerVersion,
                processedAt: DateTime.now(),
              ),
              onConflict: DoUpdate(
                (_) => OcrResultsCompanion(
                  rawText: Value(out.text),
                  textBlocksJson: Value(out.blocksJson),
                  recognizerName: Value(out.recognizerName),
                  recognizerVersion: Value(out.recognizerVersion),
                  processedAt: Value(DateTime.now()),
                ),
                target: [_db.ocrResults.screenshotId],
              ),
            );
        text = existing?.correctedText ?? out.text;
      } else {
        text = existing?.correctedText ?? existing?.rawText ?? '';
      }
      await _apply(id, text);
      await _finishJob(job.id, JobStatus.done);
    } on Object catch (e) {
      await _finishJob(job.id, JobStatus.failed, error: _describe(e));
      await _setStatus(id, ProcessingStatus.failed);
    }
  }

  /// Re-runs analysis on the stored text, for example after the user edited
  /// the recognized text or changed classification rules. No OCR involved.
  Future<AnalysisResult?> reanalyze(int screenshotId) async {
    final ocr = await _ocrRow(screenshotId);
    if (await _screenshot(screenshotId) == null) return null;
    return _apply(screenshotId, ocr?.correctedText ?? ocr?.rawText ?? '');
  }

  Future<void> reanalyzeAll() async {
    final ids =
        await (_db.selectOnly(_db.screenshots)
              ..addColumns([_db.screenshots.id])
              ..where(
                _db.screenshots.processingStatus.equalsValue(
                  ProcessingStatus.completed,
                ),
              ))
            .map((r) => r.read(_db.screenshots.id)!)
            .get();
    for (final id in ids) {
      await reanalyze(id);
    }
  }

  /// Saves user-corrected text and re-derives entities and actions from it.
  Future<void> updateText(int screenshotId, String text) async {
    final existing = await _ocrRow(screenshotId);
    final corrected = text.trim().isEmpty ? null : text;
    if (existing == null) {
      await _db
          .into(_db.ocrResults)
          .insert(
            OcrResultsCompanion.insert(
              screenshotId: screenshotId,
              rawText: '',
              correctedText: Value(corrected),
              textBlocksJson: '[]',
              recognizerName: 'manual',
              recognizerVersion: '1',
              processedAt: DateTime.now(),
            ),
          );
    } else {
      await (_db.update(_db.ocrResults)..where((o) => o.id.equals(existing.id)))
          .write(OcrResultsCompanion(correctedText: Value(corrected)));
    }
    await reanalyze(screenshotId);
  }

  /// Queues screenshots for a fresh OCR + analysis pass.
  Future<void> retry(Iterable<int> screenshotIds) async {
    await _db.transaction(() async {
      for (final id in screenshotIds) {
        final updated =
            await (_db.update(
              _db.processingJobs,
            )..where((j) => j.screenshotId.equals(id))).write(
              ProcessingJobsCompanion(
                status: const Value(JobStatus.queued),
                attemptCount: const Value(0),
                errorMessage: const Value(null),
                updatedAt: Value(DateTime.now()),
              ),
            );
        if (updated == 0) {
          await _db
              .into(_db.processingJobs)
              .insert(
                ProcessingJobsCompanion.insert(
                  screenshotId: id,
                  jobType: JobType.process,
                  status: JobStatus.queued,
                ),
              );
        }
        await _setStatus(id, ProcessingStatus.pending);
      }
    });
    kick();
  }

  Future<String?> lastError(int screenshotId) async {
    final job =
        await (_db.select(_db.processingJobs)
              ..where((j) => j.screenshotId.equals(screenshotId))
              ..orderBy([(j) => OrderingTerm.desc(j.updatedAt)])
              ..limit(1))
            .getSingleOrNull();
    final message = job?.errorMessage;
    // Earlier versions stored raw exceptions (with stack traces) here.
    if (message != null &&
        (message.length > 200 || message.contains('Exception'))) {
      return 'The text in this image could not be read. Tap Retry to try '
          'again.';
    }
    return message;
  }

  Future<AnalysisResult> _apply(int id, String text) async {
    final shot = (await _screenshot(id))!;
    final slugToId = <String, int>{};
    final idToSlug = <int, String>{};
    for (final c in await _db.select(_db.categories).get()) {
      slugToId[c.slug] = c.id;
      idToSlug[c.id] = c.slug;
    }
    final rules = await _userRules(idToSlug);
    final locked = shot.categoryLocked && shot.primaryCategoryId != null;
    final ocrRow = await _ocrRow(id);
    final result = analyzer.analyze(
      text,
      // Text size per line; only valid while the text is the OCR result.
      lineHeights: ocrRow?.correctedText == null
          ? lineHeightsFromBlocks(ocrRow?.textBlocksJson)
          : null,
      dateOrder: dateOrder,
      userRules: rules,
      // Generated titles are refreshed; a title the user typed is kept.
      existingTitle: shot.titleLocked ? shot.title : null,
      lockedCategorySlug: locked ? idToSlug[shot.primaryCategoryId] : null,
    );
    final classified = result.classification;
    final categoryId = slugToId[classified.categorySlug] ?? slugToId['other'];
    final now = DateTime.now();

    await _db.transaction(() async {
      // Keep what the user already decided ("Looks right", a corrected
      // value, "Not correct") for details that are found again unchanged.
      final decided = {
        for (final old
            in await (_db.select(_db.extractedEntities)..where(
                  (e) =>
                      e.screenshotId.equals(id) &
                      e.validationStatus.isInValues([
                        ValidationStatus.confirmed,
                        ValidationStatus.rejected,
                      ]),
                ))
                .get())
          (old.entityType, old.rawValue): old,
      };
      await (_db.delete(
        _db.extractedEntities,
      )..where((e) => e.screenshotId.equals(id))).go();
      await _db.batch((b) {
        b.insertAll(_db.extractedEntities, [
          for (final e in result.extraction.entities)
            if (decided[(e.type, e.raw)] case final old?)
              ExtractedEntitiesCompanion.insert(
                screenshotId: id,
                entityType: e.type,
                rawValue: e.raw,
                normalizedValue: Value(old.normalizedValue ?? e.normalized),
                metadataJson: Value(old.metadataJson),
                validationStatus: old.validationStatus,
              )
            else
              ExtractedEntitiesCompanion.insert(
                screenshotId: id,
                entityType: e.type,
                rawValue: e.raw,
                normalizedValue: Value(e.normalized),
                metadataJson: Value(
                  e.metadata.isEmpty ? null : jsonEncode(e.metadata),
                ),
                validationStatus: e.validationStatus,
              ),
        ]);
      });

      final kept =
          await (_db.select(_db.suggestedActions)..where(
                (a) =>
                    a.screenshotId.equals(id) &
                    a.status.equalsValue(ActionStatus.suggested).not(),
              ))
              .get();
      await (_db.delete(_db.suggestedActions)..where(
            (a) =>
                a.screenshotId.equals(id) &
                a.status.equalsValue(ActionStatus.suggested),
          ))
          .go();
      final keptKeys = {
        for (final a in kept) '${a.actionType.name}|${a.payloadJson}',
      };
      await _db.batch((b) {
        for (final a in result.actions) {
          final payload = jsonEncode({
            for (final MapEntry(:key, :value) in a.payload.entries) key: ?value,
          });
          if (keptKeys.contains('${a.type.name}|$payload')) continue;
          b.insert(
            _db.suggestedActions,
            SuggestedActionsCompanion.insert(
              screenshotId: id,
              actionType: a.type,
              title: a.title,
              payloadJson: payload,
              status: ActionStatus.suggested,
            ),
          );
        }
      });

      await (_db.update(_db.screenshots)..where((s) => s.id.equals(id))).write(
        ScreenshotsCompanion(
          suggestedCategoryId: Value(categoryId),
          classificationScore: Value(classified.score),
          primaryCategoryId: locked ? const Value.absent() : Value(categoryId),
          needsCategoryConfirmation: locked
              ? const Value(false)
              : Value(classified.needsConfirmation),
          title: shot.titleLocked
              ? const Value.absent()
              : Value(result.title ?? shot.title),
          isSensitive: Value(shot.isSensitive || result.extraction.isSensitive),
          processingStatus: const Value(ProcessingStatus.completed),
          updatedAt: Value(now),
        ),
      );
    });
    await _indexer.reindex(id);
    return result;
  }

  /// Line text -> height in pixels, from the stored OCR boxes.
  static Map<String, double>? lineHeightsFromBlocks(String? json) {
    if (json == null || json.isEmpty) return null;
    try {
      final out = <String, double>{};
      for (final b in jsonDecode(json) as List<Object?>) {
        for (final l in ((b! as Map)['lines'] as List<Object?>? ?? const [])) {
          final line = l! as Map;
          final box = (line['box'] as List<Object?>).cast<num>();
          final text = (line['text'] as String).trim();
          final h = (box[3] - box[1]).toDouble();
          if (text.isNotEmpty && h > (out[text] ?? 0)) out[text] = h;
        }
      }
      return out.isEmpty ? null : out;
    } on Object {
      return null;
    }
  }

  Future<List<UserRule>> _userRules(Map<int, String> idToSlug) async {
    final rows = await _db.select(_db.classificationRules).get();
    return [
      for (final r in rows)
        if (idToSlug.containsKey(r.categoryId))
          UserRule(keyword: r.keyword, categorySlug: idToSlug[r.categoryId]!),
    ];
  }

  Future<ScreenshotRow?> _screenshot(int id) => (_db.select(
    _db.screenshots,
  )..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<OcrResultRow?> _ocrRow(int id) => (_db.select(
    _db.ocrResults,
  )..where((o) => o.screenshotId.equals(id))).getSingleOrNull();

  Future<void> _setStatus(int id, ProcessingStatus status) =>
      (_db.update(_db.screenshots)..where((s) => s.id.equals(id))).write(
        ScreenshotsCompanion(
          processingStatus: Value(status),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> _finishJob(int jobId, JobStatus status, {String? error}) =>
      (_db.update(_db.processingJobs)..where((j) => j.id.equals(jobId))).write(
        ProcessingJobsCompanion(
          status: Value(status),
          errorMessage: Value(error),
          updatedAt: Value(DateTime.now()),
        ),
      );

  static String _describe(Object e) {
    switch (e) {
      case OcrException(:final message):
        return message;
      case FileSystemException():
        return 'The image file could not be read.';
    }
    // Shown on the details screen: keep it human, log the detail.
    debugPrint('Processing failed: $e');
    return 'Something went wrong while analysing this screenshot. '
        'Tap Retry to try again.';
  }

  Future<void> dispose() async {
    _disposed = true;
    await whenIdle();
    await _ocr.dispose();
  }
}
