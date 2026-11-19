import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snapaction/core/constants/system_categories.dart';
import 'package:snapaction/core/database/app_database.dart';
import 'package:snapaction/core/repositories/search_repository.dart';
import 'package:snapaction/features/screenshot_import/application/import_service.dart';
import 'package:snapaction/services/ocr/ocr_service.dart';
import 'package:snapaction/services/processing/job_runner.dart';
import 'package:snapaction/services/search/search_indexer.dart';

import '../test/fixtures/ocr_samples.dart' as samples;
import '../test/helpers/test_app.dart';

/// Renders [text] as a phone-sized screenshot (black on white).
Future<File> renderScreenshot(String text, String path) async {
  const width = 1080.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final painter = TextPainter(
    text: TextSpan(
      text: text.trim(),
      style: const TextStyle(
        color: Color(0xFF000000),
        fontSize: 44,
        height: 1.5,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: width - 120);
  final height = (painter.height + 240).clamp(600.0, 2400.0);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, width, height),
    Paint()..color = const Color(0xFFFFFFFF),
  );
  painter.paint(canvas, const Offset(60, 120));
  final image = await recorder.endRecording().toImage(
    width.toInt(),
    height.toInt(),
  );
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return File(path)..writeAsBytesSync(bytes!.buffer.asUint8List());
}

Future<bool> networkReachable() async {
  try {
    final r = await InternetAddress.lookup('example.com')
        .timeout(const Duration(seconds: 3));
    return r.isNotEmpty;
  } on Object {
    return false;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'imports rendered screenshots and reads them with on-device OCR',
    (tester) async {
      final online = await tester.runAsync(networkReachable);
      // ignore: avoid_print
      print('METRIC network_reachable=$online');

      final services = (await tester.runAsync(createTestServices))!;
      final db = services.database;
      addTearDown(() => tester.runAsync(db.close));
      final ocr = MlKitOcrService();
      final runner = JobRunner(
        db: db,
        ocr: ocr,
        indexer: SearchIndexer(db),
        settings: services.settings,
      );

      final ocrMillis = await tester.runAsync(() async {
        final dir = await Directory.systemTemp.createTemp('snapaction_it');
        final files = [
          await renderScreenshot(samples.receipt, '${dir.path}/receipt.png'),
          await renderScreenshot(
            samples.boardingPass,
            '${dir.path}/boarding.png',
          ),
          await renderScreenshot(
            samples.assignment,
            '${dir.path}/assignment.png',
          ),
          await renderScreenshot(samples.wifiCard, '${dir.path}/wifi.png'),
        ];
        final result =
            await ImportService(
              db: db,
              storage: services.storage,
              indexer: SearchIndexer(db),
            ).importFiles([
              for (final f in files) ImportCandidate(path: f.path),
            ], source: ScreenshotSource.picker);
        expect(result.importedIds, hasLength(4));
        expect(result.failures, isEmpty);
        // The originals are only read, never removed.
        for (final f in files) {
          expect(f.existsSync(), isTrue);
        }

        final sw = Stopwatch()..start();
        await runner.start();
        runner.kick();
        await runner.whenIdle();
        sw.stop();
        await runner.dispose();
        await ocr.dispose();
        await dir.delete(recursive: true);
        return sw.elapsedMilliseconds;
      });
      // ignore: avoid_print
      print('METRIC ocr_and_analysis_ms_per_screenshot=${ocrMillis! ~/ 4}');

      await tester.runAsync(() async {
        final shots = await db.select(db.screenshots).get();
        expect(
          shots.map((s) => s.processingStatus),
          everyElement(ProcessingStatus.completed),
        );
        final texts = await db.select(db.ocrResults).get();
        final all = texts.map((t) => t.rawText.toLowerCase()).join('\n');
        expect(all, contains('payment successful'));
        expect(all, contains('boarding pass'));
        expect(all, contains('submission deadline'));

        final entities = await db.select(db.extractedEntities).get();
        final types = entities.map((e) => e.entityType).toSet();
        expect(
          types,
          containsAll([
            EntityType.amount,
            EntityType.flightReference,
            EntityType.deadline,
          ]),
        );
        final amount = entities.firstWhere(
          (e) => e.entityType == EntityType.amount,
        );
        expect(amount.normalizedValue, 'EUR 23.50');
        expect(amount.metadataJson, contains('2350'));

        final categories = {
          for (final c in await db.select(db.categories).get()) c.id: c.slug,
        };
        final slugs = shots
            .map(
              (s) => categories[s.primaryCategoryId ?? s.suggestedCategoryId],
            )
            .toSet();
        expect(
          slugs,
          containsAll([
            CategorySlugs.finance,
            CategorySlugs.travel,
            CategorySlugs.education,
          ]),
        );

        final hits = await SearchRepository(db)
            .search(const SearchRequest(text: 'lisbon'));
        expect(hits.hits, hasLength(1));
        expect(hits.usedFullText, isTrue);
      });
    },
  );

  testWidgets('the app opens, searches and shows details without a network', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      seed: (db) async {
        final id = await db
            .into(db.screenshots)
            .insert(
              ScreenshotsCompanion.insert(
                localFilePath: '/missing.png',
                contentHash: 'h1',
                importedAt: DateTime(2026, 11, 1),
                source: ScreenshotSource.picker,
                processingStatus: ProcessingStatus.completed,
                fileSize: 1,
                title: const Value('Boarding pass LH 1234'),
              ),
            );
        await db
            .into(db.ocrResults)
            .insert(
              OcrResultsCompanion.insert(
                screenshotId: id,
                rawText: samples.boardingPass,
                textBlocksJson: '[]',
                recognizerName: 'fake',
                recognizerVersion: '0',
                processedAt: DateTime(2026, 11, 1),
              ),
            );
        await SearchIndexer(db).rebuild();
      },
    );
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Search'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'lisbon');
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(find.textContaining('Boarding pass LH 1234'), findsWidgets);
    await tester.tap(find.textContaining('Boarding pass LH 1234').first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.textContaining('Frankfurt'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Frankfurt'), findsWidgets);
    expect(find.text('Recognized on this device'), findsOneWidget);
  });
}
