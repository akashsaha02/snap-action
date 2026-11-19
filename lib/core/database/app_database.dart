import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
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
  int get schemaVersion => 2;

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
      // Each step is explicit and covered by a test.
      if (from < 2) {
        // Titles the user typed are kept; generated ones may be improved.
        await m.addColumn(screenshots, screenshots.titleLocked);
      }
    },
    beforeOpen: (details) async {
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
