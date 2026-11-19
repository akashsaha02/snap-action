import 'dart:async';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/screenshot_detail.dart';
import '../models/screenshot_summary.dart';
import 'category_repository.dart';

enum ScreenshotFilter { inbox, all, favorites, archived, failed, processing }

enum ScreenshotSort { newest, oldest, title }

class ScreenshotQuery {
  const ScreenshotQuery({
    this.filter = ScreenshotFilter.all,
    this.sort = ScreenshotSort.newest,
    this.categoryId,
    this.collectionId,
    this.tagId,
    this.excludeCollectionId,
    this.limit = 60,
  });

  final ScreenshotFilter filter;
  final ScreenshotSort sort;
  final int? categoryId;
  final int? collectionId;
  final int? tagId;

  /// Leaves out screenshots that are already in this collection, for
  /// example when picking screenshots to add to it.
  final int? excludeCollectionId;
  final int limit;

  ScreenshotQuery copyWith({
    ScreenshotFilter? filter,
    ScreenshotSort? sort,
    int? limit,
  }) => ScreenshotQuery(
    filter: filter ?? this.filter,
    sort: sort ?? this.sort,
    categoryId: categoryId,
    collectionId: collectionId,
    tagId: tagId,
    excludeCollectionId: excludeCollectionId,
    limit: limit ?? this.limit,
  );

  @override
  bool operator ==(Object other) =>
      other is ScreenshotQuery &&
      other.filter == filter &&
      other.sort == sort &&
      other.categoryId == categoryId &&
      other.collectionId == collectionId &&
      other.tagId == tagId &&
      other.excludeCollectionId == excludeCollectionId &&
      other.limit == limit;

  @override
  int get hashCode => Object.hash(
    filter,
    sort,
    categoryId,
    collectionId,
    tagId,
    excludeCollectionId,
    limit,
  );
}

class LibraryStats {
  const LibraryStats({
    this.total = 0,
    this.needsReview = 0,
    this.archived = 0,
    this.failed = 0,
    this.queued = 0,
    this.favorites = 0,
  });

  final int total;
  final int needsReview;
  final int archived;
  final int failed;
  final int queued;
  final int favorites;
}

class ScreenshotRepository {
  ScreenshotRepository(this._db);

  final AppDatabase _db;

  /// Columns of the list projection, shared by browse and search queries.
  static const summaryColumns =
      's.*, substr(coalesce(o.corrected_text, o.raw_text), 1, 200) AS preview, '
      '(SELECT group_concat(a.action_type) FROM suggested_actions a '
      "WHERE a.screenshot_id = s.id AND a.status = 'suggested') AS action_list";

  /// WHERE clause (without the keyword) and its variables for [q]; the
  /// order and page limit are not part of it.
  (String, List<Variable<Object>>) _where(
    ScreenshotQuery q, {
    bool failedOnly = false,
  }) {
    final where = <String>[];
    final vars = <Variable<Object>>[];
    switch (q.filter) {
      case ScreenshotFilter.inbox:
        where.add('s.is_archived = 0 AND s.is_reviewed = 0');
      case ScreenshotFilter.all:
        where.add('s.is_archived = 0');
      case ScreenshotFilter.favorites:
        where.add('s.is_archived = 0 AND s.is_favorite = 1');
      case ScreenshotFilter.archived:
        where.add('s.is_archived = 1');
      case ScreenshotFilter.failed:
        where.add("s.processing_status = 'failed'");
      case ScreenshotFilter.processing:
        where.add("s.processing_status IN ('pending', 'processing')");
    }
    if (q.categoryId != null) {
      where.add('coalesce(s.primary_category_id, s.suggested_category_id) = ?');
      vars.add(Variable.withInt(q.categoryId!));
    }
    if (q.collectionId != null) {
      where.add(
        'EXISTS (SELECT 1 FROM collection_items ci '
        'WHERE ci.screenshot_id = s.id AND ci.collection_id = ?)',
      );
      vars.add(Variable.withInt(q.collectionId!));
    }
    if (q.tagId != null) {
      where.add(
        'EXISTS (SELECT 1 FROM screenshot_tags st '
        'WHERE st.screenshot_id = s.id AND st.tag_id = ?)',
      );
      vars.add(Variable.withInt(q.tagId!));
    }
    if (q.excludeCollectionId != null) {
      where.add(
        'NOT EXISTS (SELECT 1 FROM collection_items cx '
        'WHERE cx.screenshot_id = s.id AND cx.collection_id = ?)',
      );
      vars.add(Variable.withInt(q.excludeCollectionId!));
    }
    if (failedOnly) where.add("s.processing_status = 'failed'");
    return (where.join(' AND '), vars);
  }

  static String _order(ScreenshotSort sort) => switch (sort) {
    ScreenshotSort.newest => 's.imported_at DESC, s.id DESC',
    ScreenshotSort.oldest => 's.imported_at ASC, s.id ASC',
    ScreenshotSort.title => "lower(coalesce(s.title, '')) ASC, s.id DESC",
  };

  /// Ids of every screenshot matching [q], ignoring its page limit. Used by
  /// "Select all" and "Retry all failed", which must not depend on how much
  /// of the list has been loaded.
  Future<List<int>> idsMatching(
    ScreenshotQuery q, {
    bool failedOnly = false,
  }) async {
    final (where, vars) = _where(q, failedOnly: failedOnly);
    final rows = await _db
        .customSelect(
          'SELECT s.id AS id FROM screenshots s WHERE $where '
          'ORDER BY ${_order(q.sort)}',
          variables: vars,
        )
        .get();
    return [for (final r in rows) r.read<int>('id')];
  }

  /// Number of screenshots matching [q], ignoring its page limit.
  Stream<int> watchCount(ScreenshotQuery q, {bool failedOnly = false}) {
    final (where, vars) = _where(q, failedOnly: failedOnly);
    return _db
        .customSelect(
          'SELECT count(*) AS n FROM screenshots s WHERE $where',
          variables: vars,
          readsFrom: {_db.screenshots, _db.collectionItems, _db.screenshotTags},
        )
        .watchSingle()
        .map((r) => r.read<int>('n'));
  }

  Stream<List<ScreenshotSummary>> watchSummaries(ScreenshotQuery q) {
    final (where, vars) = _where(q);
    final query = _db.customSelect(
      'SELECT $summaryColumns FROM screenshots s '
      'LEFT JOIN ocr_results o ON o.screenshot_id = s.id '
      'WHERE $where ORDER BY ${_order(q.sort)} LIMIT ?',
      variables: [...vars, Variable.withInt(q.limit)],
      readsFrom: {
        _db.screenshots,
        _db.ocrResults,
        _db.suggestedActions,
        _db.collectionItems,
        _db.screenshotTags,
      },
    );
    return Rx.combine(
      query.watch(),
      CategoryRepository(_db).watchAll(),
      mapSummaries,
    );
  }

  List<ScreenshotSummary> mapSummaries(
    List<QueryRow> rows,
    List<CategoryInfo> categories,
  ) {
    final byId = {for (final c in categories) c.id: c};
    return [
      for (final r in rows)
        toSummary(
          _db.screenshots.map(r.data),
          byId,
          preview: r.read<String?>('preview'),
          actionList: r.read<String?>('action_list'),
        ),
    ];
  }

  static ScreenshotSummary toSummary(
    ScreenshotRow s,
    Map<int, CategoryInfo> categories, {
    String? preview,
    String? actionList,
  }) {
    final actions = <ActionType>{
      for (final name in (actionList ?? '').split(','))
        ?ActionType.values.firstWhereOrNull((a) => a.name == name),
    }.toList();
    return ScreenshotSummary(
      id: s.id,
      title: s.title,
      localFilePath: s.localFilePath,
      thumbnailPath: s.thumbnailPath,
      importedAt: s.importedAt,
      status: s.processingStatus,
      category: categories[s.primaryCategoryId],
      suggestedCategory: categories[s.suggestedCategoryId],
      textPreview: preview?.replaceAll(RegExp(r'\s+'), ' ').trim(),
      isFavorite: s.isFavorite,
      isReviewed: s.isReviewed,
      isArchived: s.isArchived,
      isSensitive: s.isSensitive,
      needsCategoryConfirmation: s.needsCategoryConfirmation,
      actionTypes: actions,
    );
  }

  Stream<LibraryStats> watchStats() {
    return _db
        .customSelect(
          'SELECT '
          'sum(CASE WHEN is_archived = 0 THEN 1 ELSE 0 END) AS total, '
          'sum(CASE WHEN is_archived = 0 AND is_reviewed = 0 THEN 1 ELSE 0 END) AS review, '
          'sum(CASE WHEN is_archived = 1 THEN 1 ELSE 0 END) AS archived, '
          "sum(CASE WHEN processing_status = 'failed' THEN 1 ELSE 0 END) AS failed, "
          "sum(CASE WHEN processing_status IN ('pending','processing') THEN 1 ELSE 0 END) AS queued, "
          'sum(CASE WHEN is_favorite = 1 AND is_archived = 0 THEN 1 ELSE 0 END) AS favs '
          'FROM screenshots',
          readsFrom: {_db.screenshots},
        )
        .watchSingle()
        .map(
          (r) => LibraryStats(
            total: r.read<int?>('total') ?? 0,
            needsReview: r.read<int?>('review') ?? 0,
            archived: r.read<int?>('archived') ?? 0,
            failed: r.read<int?>('failed') ?? 0,
            queued: r.read<int?>('queued') ?? 0,
            favorites: r.read<int?>('favs') ?? 0,
          ),
        );
  }

  Future<ScreenshotRow?> byId(int id) => (_db.select(
    _db.screenshots,
  )..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<int?> idByHash(String hash) async {
    final row = await (_db.select(
      _db.screenshots,
    )..where((s) => s.contentHash.equals(hash))).getSingleOrNull();
    return row?.id;
  }

  /// Screenshot id -> recognized (or corrected) text.
  Future<Map<int, String>> recognizedTexts() async {
    final rows = await _db
        .customSelect(
          'SELECT screenshot_id, coalesce(corrected_text, raw_text) AS t '
          'FROM ocr_results',
        )
        .get();
    return {
      for (final r in rows)
        r.read<int>('screenshot_id'): r.read<String?>('t') ?? '',
    };
  }

  Future<List<(int, String)>> perceptualHashes() async {
    final rows = await _db
        .customSelect(
          'SELECT id, perceptual_hash FROM screenshots '
          'WHERE perceptual_hash IS NOT NULL',
        )
        .get();
    return [
      for (final r in rows)
        (r.read<int>('id'), r.read<String>('perceptual_hash')),
    ];
  }

  Future<List<ScreenshotSummary>> summariesByIds(List<int> ids) async {
    if (ids.isEmpty) return const [];
    final rows = await _db
        .customSelect(
          'SELECT $summaryColumns FROM screenshots s '
          'LEFT JOIN ocr_results o ON o.screenshot_id = s.id '
          'WHERE s.id IN (${List.filled(ids.length, '?').join(',')}) '
          'ORDER BY s.imported_at DESC',
          variables: [for (final id in ids) Variable.withInt(id)],
        )
        .get();
    return mapSummaries(rows, await CategoryRepository(_db).getAll());
  }

  Stream<ScreenshotDetail?> watchDetail(int id) {
    final tables = <ResultSetImplementation<dynamic, dynamic>>{
      _db.screenshots,
      _db.ocrResults,
      _db.extractedEntities,
      _db.suggestedActions,
      _db.tags,
      _db.screenshotTags,
      _db.notes,
      _db.collections,
      _db.collectionItems,
      _db.categories,
      _db.reminders,
      _db.wishlistItems,
    };
    return _db
        .tableUpdates(TableUpdateQuery.onAllTables(tables))
        .asyncMap((_) => loadDetail(id))
        .startWith(() => loadDetail(id));
  }

  Future<ScreenshotDetail?> loadDetail(int id) async {
    final s = await byId(id);
    if (s == null) return null;
    final categories = {
      for (final c in await CategoryRepository(_db).getAll()) c.id: c,
    };
    final ocr = await (_db.select(
      _db.ocrResults,
    )..where((o) => o.screenshotId.equals(id))).getSingleOrNull();
    final entities =
        await (_db.select(_db.extractedEntities)
              ..where((e) => e.screenshotId.equals(id))
              ..orderBy([(e) => OrderingTerm.asc(e.id)]))
            .get();
    final actions =
        await (_db.select(_db.suggestedActions)
              ..where((a) => a.screenshotId.equals(id))
              ..orderBy([(a) => OrderingTerm.asc(a.id)]))
            .get();
    final tags =
        await (_db.select(_db.tags).join([
                innerJoin(
                  _db.screenshotTags,
                  _db.screenshotTags.tagId.equalsExp(_db.tags.id),
                ),
              ])
              ..where(_db.screenshotTags.screenshotId.equals(id))
              ..orderBy([OrderingTerm.asc(_db.tags.name)]))
            .map((r) => r.readTable(_db.tags))
            .get();
    final collections =
        await (_db.select(_db.collections).join([
                innerJoin(
                  _db.collectionItems,
                  _db.collectionItems.collectionId.equalsExp(
                    _db.collections.id,
                  ),
                ),
              ])
              ..where(_db.collectionItems.screenshotId.equals(id))
              ..orderBy([OrderingTerm.asc(_db.collections.name)]))
            .map((r) => r.readTable(_db.collections))
            .get();
    final note = await (_db.select(
      _db.notes,
    )..where((n) => n.screenshotId.equals(id))).getSingleOrNull();
    final reminders =
        await (_db.select(_db.reminders)
              ..where((r) => r.screenshotId.equals(id))
              ..orderBy([(r) => OrderingTerm.asc(r.scheduledAt)]))
            .get();
    final wishlist = await (_db.select(
      _db.wishlistItems,
    )..where((w) => w.screenshotId.equals(id))).get();
    return ScreenshotDetail(
      screenshot: s,
      category: categories[s.primaryCategoryId],
      suggestedCategory: categories[s.suggestedCategoryId],
      ocr: ocr,
      entities: entities,
      actions: actions,
      tags: tags,
      collections: collections,
      note: note,
      reminders: reminders,
      wishlistItems: wishlist,
    );
  }

  // Mutations -------------------------------------------------------------

  Future<void> _update(Iterable<int> ids, ScreenshotsCompanion c) async {
    if (ids.isEmpty) return;
    await (_db.update(_db.screenshots)..where((s) => s.id.isIn(ids))).write(
      c.copyWith(updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> setTitle(int id, String? title) {
    final trimmed = title?.trim();
    return _update(
      [id],
      ScreenshotsCompanion(
        title: Value(trimmed?.isEmpty ?? true ? null : trimmed),
        // Clearing the title hands it back to automatic naming.
        titleLocked: Value(!(trimmed?.isEmpty ?? true)),
      ),
    );
  }

  Future<void> setFavorite(Iterable<int> ids, {required bool value}) =>
      _update(ids, ScreenshotsCompanion(isFavorite: Value(value)));

  Future<void> setArchived(Iterable<int> ids, {required bool value}) =>
      _update(ids, ScreenshotsCompanion(isArchived: Value(value)));

  Future<void> setReviewed(Iterable<int> ids, {required bool value}) =>
      _update(ids, ScreenshotsCompanion(isReviewed: Value(value)));

  /// A user-chosen category is locked against automatic reclassification.
  Future<void> setCategory(Iterable<int> ids, int categoryId) => _update(
    ids,
    ScreenshotsCompanion(
      primaryCategoryId: Value(categoryId),
      categoryLocked: const Value(true),
      needsCategoryConfirmation: const Value(false),
    ),
  );

  Future<void> setProcessingStatus(int id, ProcessingStatus status) =>
      _update([id], ScreenshotsCompanion(processingStatus: Value(status)));

  Future<List<String?>> filePaths(Iterable<int> ids) async {
    final rows = await (_db.select(
      _db.screenshots,
    )..where((s) => s.id.isIn(ids))).get();
    return [
      for (final r in rows) ...[r.localFilePath, r.thumbnailPath],
    ];
  }

  Future<Set<String>> allFilePaths() async {
    final rows = await _db.select(_db.screenshots).get();
    return {
      for (final r in rows) ...[r.localFilePath, ?r.thumbnailPath],
    };
  }
}

/// Minimal stream helpers to avoid an rxdart dependency.
abstract final class Rx {
  static Stream<R> combine<A, B, R>(
    Stream<A> a,
    Stream<B> b,
    R Function(A, B) combiner,
  ) {
    late StreamController<R> controller;
    StreamSubscription<A>? subA;
    StreamSubscription<B>? subB;
    A? lastA;
    B? lastB;
    var hasA = false;
    var hasB = false;
    void emit() {
      if (hasA && hasB) controller.add(combiner(lastA as A, lastB as B));
    }

    controller = StreamController<R>(
      onListen: () {
        subA = a.listen((v) {
          lastA = v;
          hasA = true;
          emit();
        }, onError: controller.addError);
        subB = b.listen((v) {
          lastB = v;
          hasB = true;
          emit();
        }, onError: controller.addError);
      },
      onCancel: () async {
        await subA?.cancel();
        await subB?.cancel();
        await controller.close();
      },
    );
    return controller.stream;
  }
}

extension StartWith<T> on Stream<T> {
  Stream<T> startWith(Future<T> Function() first) async* {
    yield await first();
    yield* this;
  }
}
