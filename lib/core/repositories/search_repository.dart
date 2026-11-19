import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/screenshot_summary.dart';
import 'category_repository.dart';
import 'screenshot_repository.dart';

enum SearchSort { relevance, newest, oldest }

enum SearchContent { date, amount, link, phone, email, address, code }

class SearchRequest {
  const SearchRequest({
    this.text = '',
    this.categoryId,
    this.collectionId,
    this.tagId,
    this.contains = const {},
    this.favoritesOnly = false,
    this.includeArchived = false,
    this.from,
    this.to,
    this.sort = SearchSort.relevance,
    this.limit = defaultLimit,
  });

  /// Results per page; "Load more" asks for another page of this size.
  static const defaultLimit = 100;

  final String text;
  final int? categoryId;
  final int? collectionId;
  final int? tagId;
  final Set<SearchContent> contains;
  final bool favoritesOnly;
  final bool includeArchived;

  /// Inclusive import-date range.
  final DateTime? from;
  final DateTime? to;
  final SearchSort sort;
  final int limit;

  bool get hasFilters =>
      categoryId != null ||
      collectionId != null ||
      tagId != null ||
      contains.isNotEmpty ||
      favoritesOnly ||
      includeArchived ||
      from != null ||
      to != null;

  bool get isEmpty => text.trim().isEmpty && !hasFilters;

  SearchRequest copyWith({
    String? text,
    int? Function()? categoryId,
    int? Function()? collectionId,
    int? Function()? tagId,
    Set<SearchContent>? contains,
    bool? favoritesOnly,
    bool? includeArchived,
    DateTime? Function()? from,
    DateTime? Function()? to,
    SearchSort? sort,
    int? limit,
  }) => SearchRequest(
    text: text ?? this.text,
    categoryId: categoryId == null ? this.categoryId : categoryId(),
    collectionId: collectionId == null ? this.collectionId : collectionId(),
    tagId: tagId == null ? this.tagId : tagId(),
    contains: contains ?? this.contains,
    favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    includeArchived: includeArchived ?? this.includeArchived,
    from: from == null ? this.from : from(),
    to: to == null ? this.to : to(),
    sort: sort ?? this.sort,
    limit: limit ?? this.limit,
  );

  @override
  bool operator ==(Object other) =>
      other is SearchRequest &&
      other.text == text &&
      other.categoryId == categoryId &&
      other.collectionId == collectionId &&
      other.tagId == tagId &&
      other.contains.length == contains.length &&
      other.contains.containsAll(contains) &&
      other.favoritesOnly == favoritesOnly &&
      other.includeArchived == includeArchived &&
      other.from == from &&
      other.to == to &&
      other.sort == sort &&
      other.limit == limit;

  @override
  int get hashCode => Object.hash(
    text,
    categoryId,
    collectionId,
    tagId,
    Object.hashAllUnordered(contains),
    favoritesOnly,
    includeArchived,
    from,
    to,
    sort,
    limit,
  );
}

class SearchHit {
  const SearchHit({required this.screenshot, this.snippet});

  final ScreenshotSummary screenshot;

  /// Matching excerpt; matched terms are wrapped in [highlightStart] and
  /// [highlightEnd].
  final String? snippet;

  static const highlightStart = '\u0002';
  static const highlightEnd = '\u0003';
}

class SearchResults {
  const SearchResults({
    required this.hits,
    required this.usedFullText,
    this.hasMore = false,
  });

  final List<SearchHit> hits;

  /// True when more screenshots match than the request's limit returned.
  final bool hasMore;

  /// False when SQLite FTS5 is unavailable and a slower LIKE search was used.
  final bool usedFullText;
}

class SearchRepository {
  SearchRepository(this._db);

  final AppDatabase _db;

  /// Turns user input into a safe FTS5 query: every word must match, the
  /// last word as a prefix. FTS syntax characters are never passed through.
  static String? toFtsQuery(String input) {
    final words = RegExp(r'[\p{L}\p{N}_]+', unicode: true)
        .allMatches(input.toLowerCase())
        .map((m) => m[0]!)
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return null;
    return [for (final w in words) '"$w"*'].join(' ');
  }

  static List<String> terms(String input) => RegExp(
    r'[\p{L}\p{N}_]+',
    unicode: true,
  ).allMatches(input.toLowerCase()).map((m) => m[0]!).toList();

  Future<SearchResults> search(SearchRequest r) async {
    final where = <String>[];
    final vars = <Variable<Object>>[];

    where.add(r.includeArchived ? '1 = 1' : 's.is_archived = 0');
    if (r.favoritesOnly) where.add('s.is_favorite = 1');
    if (r.categoryId != null) {
      where.add('coalesce(s.primary_category_id, s.suggested_category_id) = ?');
      vars.add(Variable.withInt(r.categoryId!));
    }
    if (r.collectionId != null) {
      where.add(
        'EXISTS (SELECT 1 FROM collection_items ci WHERE ci.screenshot_id = s.id AND ci.collection_id = ?)',
      );
      vars.add(Variable.withInt(r.collectionId!));
    }
    if (r.tagId != null) {
      where.add(
        'EXISTS (SELECT 1 FROM screenshot_tags st WHERE st.screenshot_id = s.id AND st.tag_id = ?)',
      );
      vars.add(Variable.withInt(r.tagId!));
    }
    if (r.from != null) {
      where.add('s.imported_at >= ?');
      vars.add(
        Variable.withDateTime(
          DateTime(r.from!.year, r.from!.month, r.from!.day),
        ),
      );
    }
    if (r.to != null) {
      where.add('s.imported_at < ?');
      vars.add(
        Variable.withDateTime(DateTime(r.to!.year, r.to!.month, r.to!.day + 1)),
      );
    }
    for (final c in r.contains) {
      final types = switch (c) {
        SearchContent.date => ['date', 'deadline'],
        SearchContent.amount => ['amount'],
        SearchContent.link => ['url'],
        SearchContent.phone => ['phone'],
        SearchContent.email => ['email'],
        SearchContent.address => ['address'],
        SearchContent.code => ['codeSnippet'],
      };
      where.add(
        'EXISTS (SELECT 1 FROM extracted_entities e WHERE e.screenshot_id = s.id '
        "AND e.entity_type IN (${types.map((t) => "'$t'").join(',')}))",
      );
    }

    final fts = toFtsQuery(r.text);
    final useFts = fts != null && _db.ftsAvailable;
    final order = switch (r.sort) {
      SearchSort.relevance when useFts => 'score ASC, s.imported_at DESC',
      SearchSort.oldest => 's.imported_at ASC, s.id ASC',
      _ => 's.imported_at DESC, s.id DESC',
    };

    final List<QueryRow> rows;
    if (useFts) {
      const fts = AppDatabase.ftsTable;
      rows = await _db
          .customSelect(
            'SELECT ${ScreenshotRepository.summaryColumns}, '
            "snippet($fts, -1, '${SearchHit.highlightStart}', '${SearchHit.highlightEnd}', '…', 14) AS snip, "
            // Column weights: title, body, notes, tags, entities, collections, category.
            'bm25($fts, 10.0, 1.0, 4.0, 6.0, 3.0, 4.0, 2.0) AS score '
            'FROM $fts f JOIN screenshots s ON s.id = f.rowid '
            'LEFT JOIN ocr_results o ON o.screenshot_id = s.id '
            'WHERE $fts MATCH ? AND ${where.join(' AND ')} '
            'ORDER BY $order LIMIT ?',
            variables: [
              Variable.withString(toFtsQuery(r.text)!),
              ...vars,
              // One extra row tells whether there are more results.
              Variable.withInt(r.limit + 1),
            ],
          )
          .get();
    } else {
      final likeWhere = <String>[];
      final likeVars = <Variable<Object>>[];
      for (final t in terms(r.text)) {
        likeWhere.add(
          "(lower(coalesce(s.title, '')) LIKE ? ESCAPE '\\' "
          "OR lower(coalesce(o.corrected_text, o.raw_text, '')) LIKE ? ESCAPE '\\' "
          'OR EXISTS (SELECT 1 FROM notes n WHERE n.screenshot_id = s.id AND lower(n.content) LIKE ? ESCAPE \'\\\') '
          'OR EXISTS (SELECT 1 FROM screenshot_tags st JOIN tags t ON t.id = st.tag_id '
          "WHERE st.screenshot_id = s.id AND t.name LIKE ? ESCAPE '\\'))",
        );
        final pattern =
            '%${t.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_')}%';
        likeVars.addAll(List.filled(4, Variable.withString(pattern)));
      }
      rows = await _db
          .customSelect(
            'SELECT ${ScreenshotRepository.summaryColumns} FROM screenshots s '
            'LEFT JOIN ocr_results o ON o.screenshot_id = s.id '
            'WHERE ${[...where, ...likeWhere].join(' AND ')} '
            'ORDER BY $order LIMIT ?',
            variables: [...vars, ...likeVars, Variable.withInt(r.limit + 1)],
          )
          .get();
    }

    final categories = {
      for (final c in await CategoryRepository(_db).getAll()) c.id: c,
    };
    final searchTerms = terms(r.text);
    final hasMore = rows.length > r.limit;
    return SearchResults(
      usedFullText: useFts || fts == null,
      hasMore: hasMore,
      hits: [
        for (final row in hasMore ? rows.take(r.limit) : rows)
          SearchHit(
            screenshot: ScreenshotRepository.toSummary(
              _db.screenshots.map(row.data),
              categories,
              preview: row.read<String?>('preview'),
              actionList: row.read<String?>('action_list'),
            ),
            snippet: useFts
                ? _cleanSnippet(row.read<String?>('snip'))
                : highlight(row.read<String?>('preview'), searchTerms),
          ),
      ],
    );
  }

  static String? _cleanSnippet(String? s) {
    if (s == null) return null;
    final clean = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return clean.contains(SearchHit.highlightStart) ? clean : null;
  }

  /// Marks [terms] in [text] for the fallback search.
  static String? highlight(String? text, List<String> terms) {
    if (text == null || terms.isEmpty) return null;
    final flat = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    final pattern = RegExp(
      terms.map(RegExp.escape).join('|'),
      caseSensitive: false,
    );
    if (!pattern.hasMatch(flat)) return null;
    return flat.replaceAllMapped(
      pattern,
      (m) => '${SearchHit.highlightStart}${m[0]}${SearchHit.highlightEnd}',
    );
  }

  // History and suggestions ------------------------------------------------

  Future<void> remember(String query) async {
    final q = query.trim();
    if (q.length < 2) return;
    await _db
        .into(_db.searchHistory)
        .insert(
          SearchHistoryCompanion.insert(query: q, searchedAt: DateTime.now()),
          onConflict: DoUpdate(
            (_) => SearchHistoryCompanion(searchedAt: Value(DateTime.now())),
            target: [_db.searchHistory.query],
          ),
        );
    await _db.customStatement(
      'DELETE FROM search_history WHERE id NOT IN '
      '(SELECT id FROM search_history ORDER BY searched_at DESC LIMIT 30)',
    );
  }

  Stream<List<String>> watchHistory({int limit = 8}) =>
      (_db.select(_db.searchHistory)
            ..orderBy([(h) => OrderingTerm.desc(h.searchedAt)])
            ..limit(limit))
          .watch()
          .map((rows) => [for (final r in rows) r.query]);

  Future<void> forget(String query) =>
      (_db.delete(_db.searchHistory)..where((h) => h.query.equals(query))).go();

  Future<void> clearHistory() => _db.delete(_db.searchHistory).go();

  /// Tags, categories, collections and past searches that start with [prefix].
  Future<List<String>> suggestions(String prefix, {int limit = 6}) async {
    final p = prefix.trim().toLowerCase();
    if (p.isEmpty) return const [];
    final like =
        '${p.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_')}%';
    final rows = await _db
        .customSelect(
          "SELECT name AS v FROM tags WHERE name LIKE ?1 ESCAPE '\\' "
          "UNION SELECT name FROM categories WHERE lower(name) LIKE ?1 ESCAPE '\\' "
          "UNION SELECT name FROM collections WHERE lower(name) LIKE ?1 ESCAPE '\\' "
          "UNION SELECT query FROM search_history WHERE lower(query) LIKE ?1 ESCAPE '\\' "
          'LIMIT ?2',
          variables: [Variable.withString(like), Variable.withInt(limit)],
        )
        .get();
    return [
      for (final r in rows)
        if (r.read<String>('v').toLowerCase() != p) r.read<String>('v'),
    ];
  }
}
