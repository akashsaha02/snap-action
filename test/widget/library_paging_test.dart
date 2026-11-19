import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snapaction/app/routes.dart';
import 'package:snapaction/core/database/app_database.dart';
import 'package:snapaction/core/widgets/screenshot_card.dart';
import 'package:snapaction/core/widgets/states.dart';

import '../helpers/test_app.dart';

/// Seeds [count] screenshots; the newest has the highest index.
Future<List<int>> _seed(
  AppDatabase db,
  int count, {
  ProcessingStatus status = ProcessingStatus.completed,
  String prefix = 'Shot',
}) async {
  final ids = <int>[];
  for (var i = 0; i < count; i++) {
    ids.add(
      await db
          .into(db.screenshots)
          .insert(
            ScreenshotsCompanion.insert(
              localFilePath: '/missing/$prefix$i.png',
              contentHash: 'hash-$prefix-$i',
              title: Value('$prefix $i'),
              importedAt: DateTime(2026).add(Duration(minutes: i)),
              source: ScreenshotSource.picker,
              processingStatus: status,
              fileSize: 1,
            ),
          ),
    );
  }
  return ids;
}

Future<void> _push(WidgetTester tester, String location) async {
  // ignore: unawaited_futures
  GoRouter.of(tester.element(find.byType(NavigationBar))).push(location);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('select all selects every match, not just the loaded page', (
    tester,
  ) async {
    await pumpTestApp(tester, seed: (db) => _seed(db, 130));
    await _push(tester, '${Routes.inbox}?filter=all');

    // Only the first page (60) is loaded.
    await tester.longPress(find.byType(ScreenshotCard).first);
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget);

    await tester.tap(find.byKey(const Key('library_select_all')));
    await tester.pumpAndSettle();
    expect(find.text('130 selected'), findsOneWidget);
  });

  testWidgets('loading the next page keeps the list on screen', (
    tester,
  ) async {
    await pumpTestApp(tester, seed: (db) => _seed(db, 130));
    await _push(tester, '${Routes.inbox}?filter=all');
    expect(find.byType(SkeletonList), findsNothing);

    final grid = find.byType(GridView);
    var sawLoadingMore = false;
    // Scroll to the end of each page; every frame must still show the grid.
    for (var i = 0; i < 12; i++) {
      await tester.drag(grid, const Offset(0, -3000));
      for (var f = 0; f < 5; f++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(find.byType(SkeletonList), findsNothing);
        expect(grid, findsOneWidget);
        if (find
            .byKey(const Key('library_loading_more'))
            .evaluate()
            .isNotEmpty) {
          sawLoadingMore = true;
        }
      }
      await tester.pumpAndSettle();
    }
    expect(sawLoadingMore, isTrue);
    // The oldest screenshot (only on the third page) was reached.
    expect(find.text('Shot 0'), findsOneWidget);
  });

  testWidgets('failed view offers to retry every failed screenshot', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      seed: (db) => _seed(db, 3, status: ProcessingStatus.failed),
    );
    await _push(tester, '${Routes.inbox}?filter=failed');

    expect(find.text('3 screenshots could not be processed.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('library_retry_failed')));
    await tester.pumpAndSettle();
    expect(find.text('Processing 3 screenshots again'), findsOneWidget);
  });

  testWidgets('an empty collection offers to add library screenshots', (
    tester,
  ) async {
    var collectionId = 0;
    final services = await pumpTestApp(
      tester,
      seed: (db) async {
        await _seed(db, 2);
        collectionId = await db
            .into(db.collections)
            .insert(
              CollectionsCompanion.insert(
                name: 'Trip',
                icon: 'folder',
                color: 0xFF4F46E5,
              ),
            );
      },
    );
    await _push(tester, Routes.collection(collectionId));

    expect(find.text('This collection is empty'), findsOneWidget);
    expect(find.textContaining('Import screenshots'), findsNothing);

    await tester.tap(find.byKey(const Key('collection_empty_add')));
    await tester.pumpAndSettle();
    expect(find.text('Add to Trip'), findsOneWidget);

    await tester.tap(find.text('Shot 1'));
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget);
    await tester.tap(find.byKey(const Key('picker_add')));
    await tester.pumpAndSettle();

    expect(find.text('Added 1 screenshot'), findsOneWidget);
    expect(find.text('This collection is empty'), findsNothing);
    expect(find.text('Shot 1'), findsOneWidget);
    final items = await tester.runAsync(
      () => services.database.select(services.database.collectionItems).get(),
    );
    expect(items, hasLength(1));
  });
}
