import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snapaction/core/database/app_database.dart';
import 'package:snapaction/features/search/presentation/search_screen.dart';
import 'package:snapaction/services/search/search_indexer.dart';

import '../helpers/test_app.dart';

EditableText _field(WidgetTester tester) => tester.widget<EditableText>(
  find.descendant(
    of: find.byKey(const Key('search_field')),
    matching: find.byType(EditableText),
  ),
);

Future<void> _seedReceipts(AppDatabase db, int count) async {
  final indexer = SearchIndexer(db);
  for (var i = 0; i < count; i++) {
    final id = await db
        .into(db.screenshots)
        .insert(
          ScreenshotsCompanion.insert(
            localFilePath: '/missing/r$i.png',
            contentHash: 'hash-r$i',
            title: Value('Receipt $i'),
            importedAt: DateTime(2026).add(Duration(minutes: i)),
            source: ScreenshotSource.picker,
            processingStatus: ProcessingStatus.completed,
            fileSize: 1,
          ),
        );
    await db
        .into(db.ocrResults)
        .insert(
          OcrResultsCompanion.insert(
            screenshotId: id,
            rawText: 'grocery receipt total',
            textBlocksJson: '[]',
            recognizerName: 'test',
            recognizerVersion: '0',
            processedAt: DateTime(2026),
          ),
        );
    await indexer.reindex(id);
  }
}

void main() {
  testWidgets('arriving with a focus token focuses the search field', (
    tester,
  ) async {
    await pumpTestApp(tester);
    final router = GoRouter.of(tester.element(find.byType(NavigationBar)));

    router.go(SearchScreen.focusLocation());
    await tester.pumpAndSettle();
    expect(_field(tester).focusNode.hasFocus, isTrue);

    // Leaving and coming back from Home focuses it again.
    _field(tester).focusNode.unfocus();
    await tester.pumpAndSettle();
    router.go('/home');
    await tester.pumpAndSettle();
    router.go(SearchScreen.focusLocation());
    await tester.pumpAndSettle();
    expect(_field(tester).focusNode.hasFocus, isTrue);
  });

  testWidgets('the search tab without a token does not grab focus', (
    tester,
  ) async {
    await pumpTestApp(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Search'),
      ),
    );
    await tester.pumpAndSettle();
    expect(_field(tester).focusNode.hasFocus, isFalse);
  });

  testWidgets('capped results say "100+" and can load more', (tester) async {
    await pumpTestApp(tester, seed: (db) => _seedReceipts(db, 105));
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Search'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('search_field')), 'grocery');
    await tester.pumpAndSettle();
    expect(find.text('100+ results'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('search_load_more')),
      2000,
      scrollable: find
          .descendant(
            of: find.byType(ListView).last,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.byKey(const Key('search_load_more')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('search_load_more')), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Receipt 0'),
      2000,
      scrollable: find
          .descendant(
            of: find.byType(ListView).last,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Receipt 0'), findsOneWidget);
  });
}
