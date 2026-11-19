import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snapaction/app/bootstrap.dart';
import 'package:snapaction/app/providers.dart';
import 'package:snapaction/services/processing/job_runner.dart';

import '../helpers/test_app.dart';

/// Re-analysis that finishes only when the test says so.
class _GatedRunner extends JobRunner {
  _GatedRunner({
    required super.db,
    required super.ocr,
    required super.indexer,
    required super.settings,
  });

  final gate = Completer<void>();
  var calls = 0;

  @override
  Future<void> reanalyzeAll() {
    calls++;
    return gate.future;
  }
}

void main() {
  testWidgets('re-analyse all shows progress and cannot start twice', (
    tester,
  ) async {
    _GatedRunner? runner;
    await pumpTestApp(
      tester,
      overrides: [
        jobRunnerProvider.overrideWith(
          (ref) => runner = _GatedRunner(
            db: ref.watch(appDatabaseProvider),
            ocr: ref.watch(ocrServiceProvider),
            indexer: ref.watch(searchIndexerProvider),
            settings: ref.watch(settingsRepositoryProvider),
          ),
        ),
      ],
    );
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Settings'),
      ),
    );
    await tester.pumpAndSettle();

    final tile = find.byKey(const Key('reanalyze_all'));
    await tester.scrollUntilVisible(
      tile,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(tile);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Re-analyse'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Re-analysing screenshots…'), findsOneWidget);
    expect(runner!.calls, 1);
    // While it runs the tile is disabled, so it cannot start twice.
    expect(tester.widget<ListTile>(tile).enabled, isFalse);

    runner!.gate.complete();
    await tester.pumpAndSettle();
    expect(find.text('Re-analysing screenshots…'), findsNothing);
    expect(find.text('Screenshots re-analysed'), findsOneWidget);
    expect(tester.widget<ListTile>(tile).enabled, isTrue);
    expect(runner!.calls, 1);
  });
}
