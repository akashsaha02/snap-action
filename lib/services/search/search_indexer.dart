import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../entity_extraction/text_normalizer.dart';

/// Keeps the FTS5 table in sync with the searchable fields of a screenshot.
/// When FTS5 is unavailable this is a no-op and search falls back to LIKE
/// queries over the base tables.
class SearchIndexer {
  SearchIndexer(this._db);

  final AppDatabase _db;
  static const _fts = AppDatabase.ftsTable;

  Future<void> reindex(int screenshotId) async {
    if (!_db.ftsAvailable) return;
    final row = await _db
        .customSelect(
          'SELECT s.title, c.name AS category, '
          'coalesce(o.corrected_text, o.raw_text) AS body, '
          'n.content AS notes, '
          '(SELECT group_concat(t.name, \' \') FROM tags t JOIN screenshot_tags st '
          'ON st.tag_id = t.id WHERE st.screenshot_id = s.id) AS tags, '
          "(SELECT group_concat(e.raw_value || ' ' || coalesce(e.normalized_value, ''), ' ') "
          'FROM extracted_entities e WHERE e.screenshot_id = s.id) AS entities, '
          '(SELECT group_concat(col.name, \' \') FROM collections col JOIN collection_items ci '
          'ON ci.collection_id = col.id WHERE ci.screenshot_id = s.id) AS collections '
          'FROM screenshots s '
          'LEFT JOIN ocr_results o ON o.screenshot_id = s.id '
          'LEFT JOIN notes n ON n.screenshot_id = s.id '
          'LEFT JOIN categories c ON c.id = coalesce(s.primary_category_id, s.suggested_category_id) '
          'WHERE s.id = ?',
          variables: [Variable.withInt(screenshotId)],
        )
        .getSingleOrNull();

    await _db.transaction(() async {
      await _db.customStatement('DELETE FROM $_fts WHERE rowid = ?', [
        screenshotId,
      ]);
      if (row == null) return;
      await _db.customStatement(
        'INSERT INTO $_fts(rowid, title, body, notes, tags, entities, '
        'collections, category) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [
          screenshotId,
          row.read<String?>('title') ?? '',
          // Status-bar text ("9:41 5G 87%") is on every screenshot: it only
          // adds noise to results and snippets.
          TextNormalizer.withoutStatusBar(row.read<String?>('body') ?? ''),
          row.read<String?>('notes') ?? '',
          row.read<String?>('tags') ?? '',
          row.read<String?>('entities') ?? '',
          row.read<String?>('collections') ?? '',
          row.read<String?>('category') ?? '',
        ],
      );
    });
  }

  Future<void> reindexMany(Iterable<int> ids) async {
    for (final id in ids) {
      await reindex(id);
    }
  }

  Future<void> remove(Iterable<int> ids) async {
    if (!_db.ftsAvailable || ids.isEmpty) return;
    final placeholders = List.filled(ids.length, '?').join(',');
    await _db.customStatement(
      'DELETE FROM $_fts WHERE rowid IN ($placeholders)',
      ids.toList(),
    );
  }

  /// Rebuilds the whole index, for example after a backup restore.
  /// Runs in one transaction: per-row commits made this take minutes for
  /// thousands of screenshots on a device.
  Future<void> rebuild() async {
    if (!_db.ftsAvailable) return;
    await _db.transaction(() async {
      await _db.customStatement('DELETE FROM $_fts');
      final ids = await _db
          .customSelect('SELECT id FROM screenshots')
          .map((r) => r.read<int>('id'))
          .get();
      await reindexMany(ids);
    });
  }
}
