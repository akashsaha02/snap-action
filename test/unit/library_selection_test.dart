import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:snapaction/core/database/app_database.dart';
import 'package:snapaction/core/repositories/organization_repository.dart';
import 'package:snapaction/core/repositories/screenshot_repository.dart';
import 'package:snapaction/services/search/search_indexer.dart';

import '../helpers/test_app.dart';

void main() {
  late AppDatabase db;
  late ScreenshotRepository repo;
  var n = 0;

  setUp(() {
    db = createTestDatabase();
    repo = ScreenshotRepository(db);
  });

  tearDown(() => db.close());

  Future<int> add({
    ProcessingStatus status = ProcessingStatus.completed,
    bool archived = false,
  }) => db
      .into(db.screenshots)
      .insert(
        ScreenshotsCompanion.insert(
          localFilePath: '/s${n++}.png',
          contentHash: 'hash$n',
          importedAt: DateTime(2026, 1, 1).add(Duration(minutes: n)),
          source: ScreenshotSource.picker,
          processingStatus: status,
          fileSize: 1,
          isArchived: Value(archived),
        ),
      );

  test('idsMatching ignores the page limit', () async {
    final ids = [for (var i = 0; i < 75; i++) await add()];
    await add(archived: true);
    const query = ScreenshotQuery(limit: 60);

    final page = await repo.watchSummaries(query).first;
    expect(page, hasLength(60));

    final all = await repo.idsMatching(query);
    expect(all, hasLength(75));
    expect(all.toSet(), ids.toSet());
    // Same order as the list.
    expect(all.take(60), [for (final s in page) s.id]);
    expect(await repo.watchCount(query).first, 75);
  });

  test('failedOnly narrows to failed screenshots of the view', () async {
    final failed = await add(status: ProcessingStatus.failed);
    await add();
    final failedArchived = await add(
      status: ProcessingStatus.failed,
      archived: true,
    );

    expect(await repo.idsMatching(const ScreenshotQuery(), failedOnly: true), [
      failed,
    ]);
    expect(
      (await repo.idsMatching(
        const ScreenshotQuery(filter: ScreenshotFilter.failed),
        failedOnly: true,
      )).toSet(),
      {failed, failedArchived},
    );
    expect(
      await repo.watchCount(const ScreenshotQuery(), failedOnly: true).first,
      1,
    );
  });

  test('excludeCollectionId leaves out screenshots already added', () async {
    final a = await add();
    final b = await add();
    final org = OrganizationRepository(db, SearchIndexer(db));
    final collection = await org.createCollection(name: 'Trip');
    await org.addToCollection(collection, [a]);

    expect(
      await repo.idsMatching(ScreenshotQuery(excludeCollectionId: collection)),
      [b],
    );
    expect(
      await repo.idsMatching(ScreenshotQuery(collectionId: collection)),
      [a],
    );
  });
}
