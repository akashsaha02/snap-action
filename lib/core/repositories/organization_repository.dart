import 'package:drift/drift.dart';

import '../../services/search/search_indexer.dart';
import '../database/app_database.dart';

class CollectionSummary {
  const CollectionSummary({
    required this.collection,
    required this.count,
    required this.previewPaths,
  });

  final CollectionRow collection;
  final int count;
  final List<String> previewPaths;
}

class TagCount {
  const TagCount({required this.tag, required this.count});

  final TagRow tag;
  final int count;
}

class DuplicateNameException implements Exception {
  const DuplicateNameException(this.name);

  final String name;

  @override
  String toString() => '"$name" already exists.';
}

/// Custom collections, tags and notes. Every change re-indexes the affected
/// screenshots so search stays in sync.
class OrganizationRepository {
  OrganizationRepository(this._db, this._indexer);

  final AppDatabase _db;
  final SearchIndexer _indexer;

  // Collections ------------------------------------------------------------

  Stream<List<CollectionSummary>> watchCollections() => _db
      .customSelect(
        'SELECT c.*, '
        '(SELECT count(*) FROM collection_items ci JOIN screenshots s ON s.id = ci.screenshot_id '
        'WHERE ci.collection_id = c.id AND s.is_archived = 0) AS n, '
        '(SELECT group_concat(p, char(31)) FROM (SELECT coalesce(s.thumbnail_path, s.local_file_path) AS p '
        'FROM collection_items ci JOIN screenshots s ON s.id = ci.screenshot_id '
        'WHERE ci.collection_id = c.id AND s.is_archived = 0 ORDER BY ci.added_at DESC LIMIT 3)) AS previews '
        'FROM collections c ORDER BY lower(c.name)',
        readsFrom: {_db.collections, _db.collectionItems, _db.screenshots},
      )
      .watch()
      .map(
        (rows) => [
          for (final r in rows)
            CollectionSummary(
              collection: _db.collections.map(r.data),
              count: r.read<int>('n'),
              previewPaths:
                  r.read<String?>('previews')?.split('\u001f') ?? const [],
            ),
        ],
      );

  Stream<CollectionRow?> watchCollection(int id) => (_db.select(
    _db.collections,
  )..where((c) => c.id.equals(id))).watchSingleOrNull();

  Future<int> createCollection({
    required String name,
    String? description,
    String icon = 'folder',
    int color = 0xFF4F46E5,
  }) async {
    final clean = _cleanName(name, 60);
    await _ensureUniqueCollection(clean);
    return _db
        .into(_db.collections)
        .insert(
          CollectionsCompanion.insert(
            name: clean,
            description: Value(_blankToNull(description)),
            icon: icon,
            color: color,
          ),
        );
  }

  Future<void> updateCollection(
    int id, {
    required String name,
    String? description,
    String? icon,
    int? color,
  }) async {
    final clean = _cleanName(name, 60);
    await _ensureUniqueCollection(clean, exceptId: id);
    await (_db.update(_db.collections)..where((c) => c.id.equals(id))).write(
      CollectionsCompanion(
        name: Value(clean),
        description: Value(_blankToNull(description)),
        icon: icon == null ? const Value.absent() : Value(icon),
        color: color == null ? const Value.absent() : Value(color),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _indexer.reindexMany(await _collectionMembers(id));
  }

  /// Deletes the collection only; its screenshots stay in the library.
  Future<void> deleteCollection(int id) async {
    final members = await _collectionMembers(id);
    await (_db.delete(_db.collections)..where((c) => c.id.equals(id))).go();
    await _indexer.reindexMany(members);
  }

  Future<void> addToCollection(
    int collectionId,
    Iterable<int> screenshotIds,
  ) async {
    final ids = screenshotIds.toList();
    await _db.batch((b) {
      b.insertAll(_db.collectionItems, [
        for (final id in ids)
          CollectionItemsCompanion.insert(
            collectionId: collectionId,
            screenshotId: id,
          ),
      ], mode: InsertMode.insertOrIgnore);
    });
    await _touchCollection(collectionId);
    await _indexer.reindexMany(ids);
  }

  Future<void> removeFromCollection(
    int collectionId,
    Iterable<int> screenshotIds,
  ) async {
    final ids = screenshotIds.toList();
    await (_db.delete(_db.collectionItems)..where(
          (ci) =>
              ci.collectionId.equals(collectionId) & ci.screenshotId.isIn(ids),
        ))
        .go();
    await _touchCollection(collectionId);
    await _indexer.reindexMany(ids);
  }

  Future<List<int>> _collectionMembers(int id) =>
      (_db.selectOnly(_db.collectionItems)
            ..addColumns([_db.collectionItems.screenshotId])
            ..where(_db.collectionItems.collectionId.equals(id)))
          .map((r) => r.read(_db.collectionItems.screenshotId)!)
          .get();

  Future<void> _touchCollection(int id) =>
      (_db.update(_db.collections)..where((c) => c.id.equals(id))).write(
        CollectionsCompanion(updatedAt: Value(DateTime.now())),
      );

  Future<void> _ensureUniqueCollection(String name, {int? exceptId}) async {
    final existing = await _db
        .customSelect(
          'SELECT id FROM collections WHERE lower(name) = lower(?)',
          variables: [Variable.withString(name)],
        )
        .get();
    if (existing.any((r) => r.read<int>('id') != exceptId)) {
      throw DuplicateNameException(name);
    }
  }

  // Tags -------------------------------------------------------------------

  Stream<List<TagCount>> watchTags() => _db
      .customSelect(
        'SELECT t.*, (SELECT count(*) FROM screenshot_tags st WHERE st.tag_id = t.id) AS n '
        'FROM tags t ORDER BY lower(t.name)',
        readsFrom: {_db.tags, _db.screenshotTags},
      )
      .watch()
      .map(
        (rows) => [
          for (final r in rows)
            TagCount(tag: _db.tags.map(r.data), count: r.read<int>('n')),
        ],
      );

  static String normalizeTag(String raw) => raw
      .trim()
      .replaceFirst(RegExp('^#+'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .toLowerCase();

  Future<int> _tagId(String name) async {
    final existing = await (_db.select(
      _db.tags,
    )..where((t) => t.name.equals(name))).getSingleOrNull();
    if (existing != null) return existing.id;
    return _db.into(_db.tags).insert(TagsCompanion.insert(name: name));
  }

  Future<void> addTag(int screenshotId, String raw) async {
    final name = normalizeTag(raw);
    if (name.isEmpty || name.length > 40) {
      throw ArgumentError('Tags must be 1 to 40 characters long.');
    }
    final id = await _tagId(name);
    await _db
        .into(_db.screenshotTags)
        .insert(
          ScreenshotTagsCompanion.insert(screenshotId: screenshotId, tagId: id),
          mode: InsertMode.insertOrIgnore,
        );
    await _indexer.reindex(screenshotId);
  }

  Future<void> addTagToMany(Iterable<int> screenshotIds, String raw) async {
    for (final id in screenshotIds) {
      await addTag(id, raw);
    }
  }

  Future<void> removeTag(int screenshotId, int tagId) async {
    await (_db.delete(_db.screenshotTags)..where(
          (st) => st.screenshotId.equals(screenshotId) & st.tagId.equals(tagId),
        ))
        .go();
    await _deleteUnusedTags();
    await _indexer.reindex(screenshotId);
  }

  Future<void> renameTag(int tagId, String raw) async {
    final name = normalizeTag(raw);
    if (name.isEmpty || name.length > 40) {
      throw ArgumentError('Tags must be 1 to 40 characters long.');
    }
    final clash = await (_db.select(
      _db.tags,
    )..where((t) => t.name.equals(name))).getSingleOrNull();
    final members = await _tagMembers(tagId);
    if (clash != null && clash.id != tagId) {
      // Merge into the existing tag.
      await _db.transaction(() async {
        await _db.batch((b) {
          b.insertAll(_db.screenshotTags, [
            for (final id in members)
              ScreenshotTagsCompanion.insert(screenshotId: id, tagId: clash.id),
          ], mode: InsertMode.insertOrIgnore);
        });
        await (_db.delete(_db.tags)..where((t) => t.id.equals(tagId))).go();
      });
    } else {
      await (_db.update(_db.tags)..where((t) => t.id.equals(tagId))).write(
        TagsCompanion(name: Value(name)),
      );
    }
    await _indexer.reindexMany(members);
  }

  Future<void> deleteTag(int tagId) async {
    final members = await _tagMembers(tagId);
    await (_db.delete(_db.tags)..where((t) => t.id.equals(tagId))).go();
    await _indexer.reindexMany(members);
  }

  Future<List<int>> _tagMembers(int tagId) =>
      (_db.selectOnly(_db.screenshotTags)
            ..addColumns([_db.screenshotTags.screenshotId])
            ..where(_db.screenshotTags.tagId.equals(tagId)))
          .map((r) => r.read(_db.screenshotTags.screenshotId)!)
          .get();

  Future<void> _deleteUnusedTags() => _db.customStatement(
    'DELETE FROM tags WHERE id NOT IN (SELECT DISTINCT tag_id FROM screenshot_tags)',
  );

  // Notes ------------------------------------------------------------------

  Future<void> setNote(int screenshotId, String? content) async {
    final text = _blankToNull(content);
    if (text == null) {
      await (_db.delete(
        _db.notes,
      )..where((n) => n.screenshotId.equals(screenshotId))).go();
    } else {
      await _db
          .into(_db.notes)
          .insert(
            NotesCompanion.insert(screenshotId: screenshotId, content: text),
            onConflict: DoUpdate(
              (_) => NotesCompanion(
                content: Value(text),
                updatedAt: Value(DateTime.now()),
              ),
              target: [_db.notes.screenshotId],
            ),
          );
    }
    await _indexer.reindex(screenshotId);
  }

  /// Adds [block] to the end of the note unless the note already contains it.
  Future<void> appendNote(int screenshotId, String block) async {
    final addition = block.trim();
    if (addition.isEmpty) return;
    final existing = await (_db.select(
      _db.notes,
    )..where((n) => n.screenshotId.equals(screenshotId))).getSingleOrNull();
    final current = existing?.content ?? '';
    if (current.contains(addition)) return;
    await setNote(
      screenshotId,
      current.isEmpty ? addition : '$current\n\n$addition',
    );
  }

  static String _cleanName(String raw, int max) {
    final name = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (name.isEmpty) throw ArgumentError('Please enter a name.');
    if (name.length > max) {
      throw ArgumentError('Names can be at most $max characters.');
    }
    return name;
  }

  static String? _blankToNull(String? s) {
    final t = s?.trim();
    return t == null || t.isEmpty ? null : t;
  }
}
