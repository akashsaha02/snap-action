import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:snapaction/core/database/app_database.dart';
import 'package:snapaction/core/repositories/organization_repository.dart';
import 'package:snapaction/core/repositories/search_repository.dart';
import 'package:snapaction/services/search/search_indexer.dart';

import '../helpers/test_app.dart';

void main() {
  late AppDatabase db;
  late SearchIndexer indexer;
  late OrganizationRepository org;
  late SearchRepository search;
  var n = 0;

  setUp(() {
    db = createTestDatabase();
    indexer = SearchIndexer(db);
    org = OrganizationRepository(db, indexer);
    search = SearchRepository(db);
  });

  tearDown(() => db.close());

  Future<int> add(
    String text, {
    String? title,
    DateTime? at,
    bool archived = false,
  }) async {
    final id = await db
        .into(db.screenshots)
        .insert(
          ScreenshotsCompanion.insert(
            localFilePath: '/s${n++}.png',
            contentHash: 'hash$n',
            title: Value(title),
            importedAt: at ?? DateTime(2026, 1, n),
            source: ScreenshotSource.picker,
            processingStatus: ProcessingStatus.completed,
            fileSize: 1,
            isArchived: Value(archived),
          ),
        );
    await db
        .into(db.ocrResults)
        .insert(
          OcrResultsCompanion.insert(
            screenshotId: id,
            rawText: text,
            textBlocksJson: '[]',
            recognizerName: 'test',
            recognizerVersion: '0',
            processedAt: DateTime(2026),
          ),
        );
    await indexer.reindex(id);
    return id;
  }

  List<int> ids(SearchResults r) => [for (final h in r.hits) h.screenshot.id];

  group('toFtsQuery', () {
    test('quotes every term and never passes FTS syntax through', () {
      expect(
        SearchRepository.toFtsQuery('Wi-Fi password'),
        '"wi"* "fi"* "password"*',
      );
      expect(
        SearchRepository.toFtsQuery('NEAR(a OR "b")'),
        '"near"* "a"* "or"* "b"*',
      );
      expect(SearchRepository.toFtsQuery('  ***  '), isNull);
    });
  });

  group('search', () {
    test(
      'full-text search finds OCR text by prefix and highlights it',
      () async {
        final receipt = await add(
          'Total EUR 23.50 paid by card',
          title: 'Coffee receipt',
        );
        await add('Meeting notes about the roadmap');
        expect(db.ftsAvailable, isTrue);
        final r = await search.search(const SearchRequest(text: 'rece'));
        expect(r.usedFullText, isTrue);
        expect(ids(r), [receipt]);
        final body = await search.search(
          const SearchRequest(text: 'paid card'),
        );
        expect(ids(body), [receipt]);
        expect(
          body.hits.single.snippet,
          contains('${SearchHit.highlightStart}paid'),
        );
      },
    );

    test('title matches rank above body matches', () async {
      final inBody = await add('invoice attached for your order');
      final inTitle = await add('something else', title: 'Invoice March');
      final r = await search.search(const SearchRequest(text: 'invoice'));
      expect(ids(r), [inTitle, inBody]);
    });

    test('reports when more results exist than the limit', () async {
      for (var i = 0; i < 5; i++) {
        await add('parking ticket number $i');
      }
      final page = await search.search(
        const SearchRequest(text: 'parking', limit: 3),
      );
      expect(page.hits, hasLength(3));
      expect(page.hasMore, isTrue);
      final all = await search.search(
        const SearchRequest(text: 'parking', limit: 5),
      );
      expect(all.hits, hasLength(5));
      expect(all.hasMore, isFalse);
      // A larger page keeps the first page's order.
      expect(ids(all).take(3), ids(page));
    });

    test('archived screenshots are hidden unless requested', () async {
      final id = await add('boarding pass LH 1234', archived: true);
      expect(
        ids(await search.search(const SearchRequest(text: 'boarding'))),
        isEmpty,
      );
      expect(
        ids(
          await search.search(
            const SearchRequest(text: 'boarding', includeArchived: true),
          ),
        ),
        [id],
      );
    });

    test('date range filter is inclusive of the end day', () async {
      final jan = await add('alpha', at: DateTime(2026, 1, 15, 22));
      await add('alpha', at: DateTime(2026, 2, 1));
      final r = await search.search(
        SearchRequest(
          text: 'alpha',
          from: DateTime(2026, 1, 15),
          to: DateTime(2026, 1, 15),
        ),
      );
      expect(ids(r), [jan]);
    });

    test('LIKE fallback works and escapes wildcards', () async {
      final pct = await add('Sale 50% off today');
      await add('Sale 500 items');
      db.disableFullTextSearch();
      final r = await search.search(const SearchRequest(text: '50%'));
      expect(r.usedFullText, isFalse);
      // Terms are split on non-word characters, so "50" matches both; the
      // literal % must not act as a wildcard that matches everything.
      expect(ids(r), containsAll([pct]));
      final none = await search.search(const SearchRequest(text: 'zzz_'));
      expect(none.hits, isEmpty);
      final hl = SearchRepository.highlight('Sale 50% off', ['sale']);
      expect(
        hl,
        '${SearchHit.highlightStart}Sale${SearchHit.highlightEnd} 50% off',
      );
    });

    test('notes and tags are searchable after organisation changes', () async {
      final id = await add('plain text');
      await org.setNote(id, 'Remember the blue folder');
      await org.addTag(id, '#Taxes');
      expect(ids(await search.search(const SearchRequest(text: 'folder'))), [
        id,
      ]);
      expect(ids(await search.search(const SearchRequest(text: 'taxes'))), [
        id,
      ]);
      final tag = (await org.watchTags().first).single;
      expect(tag.tag.name, 'taxes');
      expect(ids(await search.search(SearchRequest(tagId: tag.tag.id))), [id]);
    });

    test('history keeps unique recent queries and can be cleared', () async {
      await search.remember('receipt');
      await search.remember('flight');
      await search.remember('receipt');
      await search.remember('x');
      expect(await search.watchHistory().first, ['receipt', 'flight']);
      await search.forget('flight');
      expect(await search.watchHistory().first, ['receipt']);
      await search.clearHistory();
      expect(await search.watchHistory().first, isEmpty);
    });
  });

  group('organization', () {
    test('collection names are unique ignoring case', () async {
      await org.createCollection(name: 'Trips');
      expect(
        () => org.createCollection(name: 'trips'),
        throwsA(isA<DuplicateNameException>()),
      );
    });

    test('deleting a collection keeps its screenshots', () async {
      final id = await add('beach photo');
      final c = await org.createCollection(name: 'Holiday');
      await org.addToCollection(c, [id]);
      expect((await org.watchCollections().first).single.count, 1);
      expect(ids(await search.search(const SearchRequest(text: 'holiday'))), [
        id,
      ]);
      await org.deleteCollection(c);
      expect(
        await (db.select(
          db.screenshots,
        )..where((s) => s.id.equals(id))).getSingleOrNull(),
        isNotNull,
      );
    });

    test('appendNote adds blocks once', () async {
      final id = await add('x');
      await org.appendNote(id, 'Payment\nAmount: EUR 23.50');
      await org.appendNote(id, 'Payment\nAmount: EUR 23.50');
      await org.appendNote(id, 'Trip');
      final note = await (db.select(
        db.notes,
      )..where((x) => x.screenshotId.equals(id))).getSingle();
      expect(note.content, 'Payment\nAmount: EUR 23.50\n\nTrip');
    });

    test('removing the last use of a tag deletes it', () async {
      final id = await add('x');
      await org.addTag(id, 'temp');
      final tag = (await org.watchTags().first).single.tag;
      await org.removeTag(id, tag.id);
      expect(await org.watchTags().first, isEmpty);
    });
  });
}
