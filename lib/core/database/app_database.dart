import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../constants/system_categories.dart';
import 'enums.dart';
import 'tables.dart';

export 'enums.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Categories,
    Screenshots,
    OcrResults,
    ExtractedEntities,
    Collections,
    CollectionItems,
    Tags,
    ScreenshotTags,
    Notes,
    Reminders,
    SuggestedActions,
    WishlistItems,
    ProcessingJobs,
    SearchHistory,
    AppSettings,
    ClassificationRules,
    MemoryChunks,
    Embeddings,
    Spaces,
    SpaceMemberships,
    MemoryRelationships,
    ModelRegistry,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  factory AppDatabase.open() => AppDatabase(
    driftDatabase(
      name: 'snapaction',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    ),
  );

  static const ftsTable = 'screenshot_fts';

  bool _ftsAvailable = false;

  /// Whether the FTS5 index exists. When false, search falls back to LIKE.
  bool get ftsAvailable => _ftsAvailable;

  /// Forces the LIKE fallback, as on devices whose SQLite lacks FTS5.
  void disableFullTextSearch() => _ftsAvailable = false;

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // Atomic and repeatable: if a first launch is interrupted (or two opens
    // race) the next start creates whatever is missing instead of failing
    // on "index already exists" forever. Tables already use IF NOT EXISTS.
    onCreate: (m) => transaction(() async {
      for (final entity in allSchemaEntities) {
        await m.create(entity is Index ? _ifNotExists(entity) : entity);
      }
      await _seedCategories();
    }),
    onUpgrade: (m, from, to) async {
      // Drift stores the new user_version only after this returns, so a
      // crash after the commit below reruns these steps on the next start.
      // Every step is therefore guarded and safe to repeat
      // (docs/MIGRATION_PLAN.md). Each step is covered by a test.
      if (from < 3) await _snapshotBeforeV3();
      await transaction(() async {
        final before = await _integrityCounts();
        if (from < 2) {
          // Titles the user typed are kept; generated ones may be improved.
          await _addMissingColumns(m, screenshots, [screenshots.titleLocked]);
        }
        if (from < 3) await _upgradeToV3(m);
        final after = await _integrityCounts();
        if (!_sameCounts(before, after)) {
          // Throwing rolls the transaction back; the old data stays as is.
          throw StateError('Migration check failed: $before -> $after');
        }
      });
    },
    beforeOpen: (details) async {
      await _ageSnapshot();
      await customStatement('PRAGMA foreign_keys = ON');
      // Write-ahead logging with NORMAL sync: commits no longer wait for a
      // full disk sync each time, which dominated processing time on device
      // (several commits per screenshot). Committed data survives an app
      // crash; only a power loss can drop the most recent commits.
      await customStatement('PRAGMA journal_mode = WAL');
      await customStatement('PRAGMA synchronous = NORMAL');
      _ftsAvailable = await _ensureFts();
    },
  );

  static Index _ifNotExists(Index index) => Index.byDialect(index.entityName, {
    for (final MapEntry(:key, :value)
        in index.createStatementsByDialect.entries)
      key: value.replaceFirst(
        RegExp('^CREATE INDEX (?!IF NOT EXISTS)', caseSensitive: false),
        'CREATE INDEX IF NOT EXISTS ',
      ),
  });

  /// Tables that existed before schema 3, whose rows a migration must keep.
  static const _legacyTables = [
    'categories',
    'screenshots',
    'ocr_results',
    'extracted_entities',
    'collections',
    'collection_items',
    'tags',
    'screenshot_tags',
    'notes',
    'reminders',
    'suggested_actions',
    'wishlist_items',
    'processing_jobs',
    'search_history',
    'app_settings',
    'classification_rules',
  ];

  /// Tables added in schema 3.
  static const _v3Tables = {
    'memory_chunks',
    'embeddings',
    'spaces',
    'space_memberships',
    'memory_relationships',
    'model_registry',
  };

  Future<void> _upgradeToV3(Migrator m) async {
    await _addMissingColumns(m, screenshots, [
      screenshots.memoryType,
      screenshots.mimeType,
      screenshots.description,
      screenshots.sourceUrl,
      screenshots.pageCount,
      screenshots.durationMs,
      screenshots.eventAt,
    ]);
    await _addMissingColumns(m, processingJobs, [
      processingJobs.priority,
      processingJobs.progress,
      processingJobs.checkpointJson,
    ]);
    for (final table in allTables) {
      if (_v3Tables.contains(table.actualTableName)) {
        await m.createTable(table); // CREATE TABLE IF NOT EXISTS
      }
    }
    for (final entity in allSchemaEntities.whereType<Index>()) {
      await m.create(_ifNotExists(entity));
    }
  }

  /// Adds the [columns] that [table] lacks, so a rerun skips finished work.
  Future<void> _addMissingColumns(
    Migrator m,
    TableInfo<Table, dynamic> table,
    List<GeneratedColumn<Object>> columns,
  ) async {
    final existing = await customSelect(
      'SELECT name FROM pragma_table_info(?)',
      variables: [Variable.withString(table.actualTableName)],
    ).map((r) => r.read<String>('name')).get();
    for (final column in columns) {
      if (!existing.contains(column.name)) await m.addColumn(table, column);
    }
  }

  /// Row counts of the legacy tables plus the number of foreign-key
  /// violations. A migration may add columns and tables but must not change
  /// any of these. Existing violations, if any, are tolerated; only new ones
  /// fail the check, so a damaged old database still opens.
  Future<Map<String, int>> _integrityCounts() async {
    final counts = <String, int>{};
    for (final table in _legacyTables) {
      counts[table] = await customSelect('SELECT COUNT(*) AS c FROM "$table"')
          .map((r) => r.read<int>('c'))
          .getSingle();
    }
    final violations = await customSelect('PRAGMA foreign_key_check').get();
    counts['foreign_key_violations'] = violations.length;
    return counts;
  }

  static bool _sameCounts(Map<String, int> a, Map<String, int> b) =>
      a.length == b.length && a.entries.every((e) => b[e.key] == e.value);

  /// Path of the main database file, or null for an in-memory database.
  Future<String?> _databasePath() async {
    final rows = await customSelect('PRAGMA database_list').get();
    for (final row in rows) {
      if (row.read<String>('name') == 'main') {
        final path = row.readNullable<String>('file');
        return (path == null || path.isEmpty) ? null : path;
      }
    }
    return null;
  }

  Future<File?> _snapshotFile() async {
    final path = await _databasePath();
    if (path == null) return null;
    return File(p.join(p.dirname(path), 'snapshots', 'pre_v3.sqlite'));
  }

  /// Copies the database before the schema-3 upgrade (VACUUM INTO must run
  /// outside a transaction). An existing snapshot is kept: it comes from an
  /// earlier attempt and is the older, truer copy. A failed snapshot (for
  /// example a full disk) does not block the upgrade, which is itself
  /// transactional.
  Future<void> _snapshotBeforeV3() async {
    try {
      final file = await _snapshotFile();
      if (file == null || file.existsSync()) return;
      file.parent.createSync(recursive: true);
      await customStatement('VACUUM INTO ?', [file.path]);
      await _setSnapshotStarts(0);
    } on Object catch (error) {
      debugPrint('Pre-upgrade snapshot skipped: $error');
    }
  }

  static const _snapshotStartsKey = 'pre_v3_snapshot_starts';

  /// Keeps the pre-upgrade snapshot through three starts on the new schema
  /// and deletes it on the fourth.
  Future<void> _ageSnapshot() async {
    try {
      final file = await _snapshotFile();
      if (file == null || !file.existsSync()) return;
      final row = await (select(
        appSettings,
      )..where((s) => s.key.equals(_snapshotStartsKey))).getSingleOrNull();
      final starts = (int.tryParse(row?.value ?? '') ?? 0) + 1;
      if (starts > 3) {
        file.deleteSync();
        await (delete(
          appSettings,
        )..where((s) => s.key.equals(_snapshotStartsKey))).go();
      } else {
        await _setSnapshotStarts(starts);
      }
    } on Object catch (error) {
      debugPrint('Snapshot cleanup skipped: $error');
    }
  }

  Future<void> _setSnapshotStarts(int starts) => into(appSettings)
      .insertOnConflictUpdate(
        AppSettingsCompanion.insert(key: _snapshotStartsKey, value: '$starts'),
      );

  Future<bool> _ensureFts() async {
    try {
      await customStatement(
        'CREATE VIRTUAL TABLE IF NOT EXISTS $ftsTable USING fts5('
        'title, body, notes, tags, entities, collections, category, '
        "tokenize = 'unicode61 remove_diacritics 2')",
      );
      return true;
    } on Object {
      return false;
    }
  }

  Future<void> _seedCategories() async {
    await batch((b) {
      b.insertAll(categories, [
        for (final c in systemCategories)
          CategoriesCompanion.insert(
            slug: c.slug,
            name: c.name,
            icon: c.icon,
            color: c.color,
            isSystem: const Value(true),
          ),
      ], mode: InsertMode.insertOrIgnore);
    });
  }
}
