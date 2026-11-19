import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:snapaction/core/database/app_database.dart';
import 'package:snapaction/core/repositories/screenshot_repository.dart';
import 'package:snapaction/core/repositories/search_repository.dart';
import 'package:snapaction/core/services/settings_repository.dart';
import 'package:snapaction/services/ocr/ocr_service.dart';
import 'package:snapaction/services/processing/job_runner.dart';
import 'package:snapaction/services/search/search_indexer.dart';

import '../test/fixtures/ocr_samples.dart' as samples;

/// Stored text is analysed with OCR switched off, so this never runs.
class _NoOcr implements OcrService {
  @override
  Future<OcrOutput> recognize(String imagePath) =>
      throw StateError('OCR is off');

  @override
  Future<void> dispose() async {}
}

const _texts = [
  samples.shoppingProduct,
  samples.receipt,
  samples.boardingPass,
  samples.assignment,
  samples.jobPost,
  samples.conferencePoster,
  samples.recipe,
  samples.codeSnippet,
  samples.chat,
  samples.wifiCard,
];

int _median(List<int> values) => (values.toList()..sort())[values.length ~/ 2];

Future<int> _timeMs(Future<void> Function() f) async {
  final sw = Stopwatch()..start();
  await f();
  return sw.elapsedMilliseconds;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final report = <String, Object>{};

  for (final size in [100, 500, 1000, 5000]) {
    testWidgets(
      'library of $size screenshots',
      timeout: const Timeout(Duration(minutes: 30)),
      (tester) async {
        final metrics = (await tester.runAsync(() async {
          final dir = await Directory.systemTemp.createTemp('snapaction_large');
          final db = AppDatabase(
            NativeDatabase.createInBackground(
              File('${dir.path}/library.sqlite'),
            ),
          );
          try {
            final settings = await SettingsRepository.load(db);
            await settings.setBool(SettingsKeys.ocrEnabled, value: false);
            final m = <String, int>{};

            // Rows as the importer leaves them: stored text, job queued.
            m['insert_ms'] = await _timeMs(
              () => db.transaction(() async {
                for (var i = 0; i < size; i++) {
                  final id = await db
                      .into(db.screenshots)
                      .insert(
                        ScreenshotsCompanion.insert(
                          localFilePath: '${dir.path}/$i.png',
                          contentHash: 'hash-$size-$i',
                          importedAt: DateTime(2026).add(Duration(minutes: i)),
                          source: ScreenshotSource.picker,
                          processingStatus: ProcessingStatus.pending,
                          fileSize: 250000,
                        ),
                      );
                  await db
                      .into(db.ocrResults)
                      .insert(
                        OcrResultsCompanion.insert(
                          screenshotId: id,
                          rawText: '${_texts[i % _texts.length]}\nRef #$i',
                          textBlocksJson: '[]',
                          recognizerName: 'synthetic',
                          recognizerVersion: '0',
                          processedAt: DateTime(2026),
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
                }
              }),
            );

            final runner = JobRunner(
              db: db,
              ocr: _NoOcr(),
              indexer: SearchIndexer(db),
              settings: settings,
            );
            m['analysis_total_ms'] = await _timeMs(() async {
              await runner.start();
              runner.kick();
              await runner.whenIdle();
            });
            await runner.dispose();
            m['analysis_per_screenshot_us'] =
                m['analysis_total_ms']! * 1000 ~/ size;

            final done =
                await (db.selectOnly(db.screenshots)
                      ..addColumns([db.screenshots.id.count()])
                      ..where(
                        db.screenshots.processingStatus.equalsValue(
                          ProcessingStatus.completed,
                        ),
                      ))
                    .map((r) => r.read(db.screenshots.id.count()))
                    .getSingle();
            expect(done, size);

            final search = SearchRepository(db);
            for (final (name, query) in [
              ('search_word_ms', 'boarding'),
              ('search_prefix_ms', 'head'),
              ('search_two_words_ms', 'payment bakery'),
            ]) {
              final runs = <int>[];
              late SearchResults last;
              for (var r = 0; r < 7; r++) {
                runs.add(
                  await _timeMs(
                    () async =>
                        last = await search.search(SearchRequest(text: query)),
                  ),
                );
              }
              expect(last.hits, isNotEmpty, reason: query);
              m[name] = _median(runs);
            }

            final repo = ScreenshotRepository(db);
            final pageRuns = <int>[];
            for (var r = 0; r < 7; r++) {
              pageRuns.add(
                await _timeMs(
                  () => repo.watchSummaries(const ScreenshotQuery()).first,
                ),
              );
            }
            m['library_first_page_ms'] = _median(pageRuns);
            m['stats_ms'] = await _timeMs(() => repo.watchStats().first);
            m['index_rebuild_ms'] = await _timeMs(
              () => SearchIndexer(db).rebuild(),
            );
            m['database_kb'] =
                File('${dir.path}/library.sqlite').lengthSync() ~/ 1024;
            return m;
          } finally {
            await db.close();
            await dir.delete(recursive: true);
          }
        }))!;

        for (final e in metrics.entries) {
          report['${size}_${e.key}'] = e.value;
          // ignore: avoid_print
          print('METRIC size=$size ${e.key}=${e.value}');
        }
        binding.reportData = report;
      },
    );
  }
}
