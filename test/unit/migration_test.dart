// Schema migration tests against a real database written by the schema-2
// app (test/fixtures/db/schema_v2.sqlite, see generate_schema_v2_test.dart).
// Legacy data is read with raw SQL so the checks do not depend on the
// current Drift schema.
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapaction/core/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

const _fixtureV2 = 'test/fixtures/db/schema_v2.sqlite';

const _legacyTables = [
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

const _newTables = [
  'memory_chunks',
  'embeddings',
  'spaces',
  'space_memberships',
  'memory_relationships',
  'model_registry',
];

/// Bookkeeping the app itself writes on start; not user data.
const _snapshotKey = 'pre_v3_snapshot_starts';

typedef _Rows = List<Map<String, Object?>>;

T _withRaw<T>(String path, T Function(raw.Database db) body) {
  final db = raw.sqlite3.open(path);
  try {
    return body(db);
  } finally {
    db.close();
  }
}

Map<String, _Rows> _dump(String path) => _withRaw(path, (db) {
  return {
    for (final table in _legacyTables)
      table: [
        for (final row in db.select('SELECT * FROM "$table" ORDER BY rowid'))
          if (!(table == 'app_settings' && row['key'] == _snapshotKey))
            Map<String, Object?>.of(row),
      ],
  };
});

int _userVersion(String path) => _withRaw(
  path,
  (db) => db.select('PRAGMA user_version').single.values[0]! as int,
);

Set<String> _columns(String path, String table) => _withRaw(
  path,
  (db) => {
    for (final r in db.select('SELECT name FROM pragma_table_info(?)', [table]))
      r['name']! as String,
  },
);

bool _tableExists(String path, String table) => _withRaw(
  path,
  (db) => db.select(
    "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?",
    [table],
  ).isNotEmpty,
);

/// Columns (sorted by name, since ALTER appends at the end), indexes and
/// foreign keys of every table, comparable between databases.
Map<String, Object?> _schema(String path) => _withRaw(path, (db) {
  final tables = [
    for (final r in db.select(
      "SELECT name FROM sqlite_master WHERE type = 'table' "
      "AND name NOT LIKE 'sqlite_%' ORDER BY name",
    ))
      r['name']! as String,
  ];
  String rows(String sql, List<Object?> args) =>
      db.select(sql, args).map((r) => r.values.join('|')).join('; ');
  return {
    for (final t in tables)
      t: {
        'columns': rows(
          'SELECT name, type, "notnull", dflt_value, pk '
          'FROM pragma_table_info(?) ORDER BY name',
          [t],
        ),
        'indexes': [
          for (final i in db.select(
            'SELECT name, "unique", origin, partial '
            'FROM pragma_index_list(?) ORDER BY name',
            [t],
          ))
            '${i.values.join('|')}: ${rows('SELECT name FROM pragma_index_info(?) ORDER BY seqno', [i['name']])}',
        ],
        'foreignKeys': rows(
          'SELECT "table", "from", "to", on_update, on_delete '
          'FROM pragma_foreign_key_list(?) ORDER BY "from"',
          [t],
        ),
      },
  };
});

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('mindtiq_migration'));
  tearDown(() => dir.deleteSync(recursive: true));

  String copyFixture({String name = 'app.sqlite'}) =>
      File(_fixtureV2).copySync('${dir.path}/$name').path;

  /// Opens the app database at [path], runs one query so migrations happen,
  /// and closes it.
  Future<void> openOnce(String path) async {
    final db = AppDatabase(NativeDatabase(File(path)));
    try {
      await db.select(db.screenshots).get();
    } finally {
      await db.close();
    }
  }

  String snapshotPath() => '${dir.path}/snapshots/pre_v3.sqlite';

  test('the fixture is a populated schema 2 database', () {
    expect(_userVersion(_fixtureV2), 2);
    final data = _dump(_fixtureV2);
    for (final table in _legacyTables) {
      expect(data[table], isNotEmpty, reason: '$table has no fixture rows');
    }
    expect(_tableExists(_fixtureV2, 'spaces'), isFalse);
  });

  test('upgrades schema 2 with every legacy value unchanged', () async {
    final path = copyFixture();
    final before = _dump(path);
    await openOnce(path);

    expect(_userVersion(path), 3);
    final after = _dump(path);
    for (final table in _legacyTables) {
      final old = before[table]!;
      final now = after[table]!;
      expect(now, hasLength(old.length), reason: table);
      for (var i = 0; i < old.length; i++) {
        expect(
          {for (final key in old[i].keys) key: now[i][key]},
          old[i],
          reason: '$table row $i',
        );
      }
    }
    for (final row in after['screenshots']!) {
      expect(row['memory_type'], 'screenshot');
      expect(row['description'], isNull);
      expect(row['event_at'], isNull);
    }
    for (final row in after['processing_jobs']!) {
      expect(row['priority'], 0);
      expect(row['progress'], isNull);
    }
    for (final table in _newTables) {
      expect(_tableExists(path, table), isTrue, reason: table);
    }
  });

  test('upgrades a schema 1 database, treating titles as generated', () async {
    final path = copyFixture();
    _withRaw(path, (db) {
      db
        ..execute('ALTER TABLE screenshots DROP COLUMN title_locked')
        ..execute('PRAGMA user_version = 1');
    });
    final before = _dump(path);
    await openOnce(path);

    expect(_userVersion(path), 3);
    final after = _dump(path);
    expect(after['screenshots'], hasLength(before['screenshots']!.length));
    for (var i = 0; i < before['screenshots']!.length; i++) {
      final old = before['screenshots']![i];
      final now = after['screenshots']![i];
      expect({for (final key in old.keys) key: now[key]}, old);
      expect(now['title_locked'], 0);
      expect(now['memory_type'], 'screenshot');
    }
  });

  test('fresh and upgraded databases have the same schema', () async {
    final fresh = '${dir.path}/fresh.sqlite';
    await openOnce(fresh);
    final fromV2 = copyFixture(name: 'v2.sqlite');
    await openOnce(fromV2);
    final fromV1 = copyFixture(name: 'v1.sqlite');
    _withRaw(fromV1, (db) {
      db
        ..execute('ALTER TABLE screenshots DROP COLUMN title_locked')
        ..execute('PRAGMA user_version = 1');
    });
    await openOnce(fromV1);

    final expected = _schema(fresh);
    expect(_schema(fromV2), expected);
    expect(_schema(fromV1), expected);
  });

  test('a failed upgrade rolls back completely and later converges', () async {
    final path = copyFixture();
    // A view where a new table belongs: CREATE TABLE IF NOT EXISTS skips it,
    // then indexing it fails halfway through the migration.
    _withRaw(path, (db) {
      db.execute('CREATE VIEW space_memberships AS SELECT 1 AS memory_id');
    });
    final before = _dump(path);

    final failing = AppDatabase(NativeDatabase(File(path)));
    await expectLater(
      failing.select(failing.screenshots).get(),
      throwsA(anything),
    );
    await failing.close();

    expect(_userVersion(path), 2);
    expect(_columns(path, 'screenshots'), isNot(contains('memory_type')));
    expect(_columns(path, 'processing_jobs'), isNot(contains('priority')));
    expect(_tableExists(path, 'spaces'), isFalse);
    expect(_dump(path), before);

    _withRaw(path, (db) => db.execute('DROP VIEW space_memberships'));
    await openOnce(path);
    expect(_userVersion(path), 3);
    expect(_tableExists(path, 'space_memberships'), isTrue);
  });

  test('rerunning a committed upgrade is harmless', () async {
    // The commit happened but the version write was lost (a crash between
    // the two): the next start reruns the guarded steps.
    final path = copyFixture();
    await openOnce(path);
    final upgraded = _dump(path);
    _withRaw(path, (db) => db.execute('PRAGMA user_version = 2'));
    await openOnce(path);

    expect(_userVersion(path), 3);
    expect(_dump(path), upgraded);
    final fresh = '${dir.path}/fresh.sqlite';
    await openOnce(fresh);
    expect(_schema(path), _schema(fresh));
  });

  test('keeps a pre-upgrade snapshot for three starts', () async {
    final path = copyFixture();
    final before = _dump(path);
    await openOnce(path);

    final snapshot = snapshotPath();
    expect(File(snapshot).existsSync(), isTrue);
    expect(_userVersion(snapshot), 2);
    expect(_dump(snapshot), before);

    await openOnce(path); // second start
    await openOnce(path); // third start
    expect(File(snapshot).existsSync(), isTrue);
    await openOnce(path); // fourth start
    expect(File(snapshot).existsSync(), isFalse);
  });

  test(
    'reminders, notification ids and relations work after upgrade',
    () async {
      final path = copyFixture();
      final db = AppDatabase(NativeDatabase(File(path)));
      addTearDown(db.close);

      final flight = await (db.select(
        db.screenshots,
      )..where((s) => s.title.equals('Flight LH1234'))).getSingle();
      expect(flight.memoryType, MemoryType.screenshot);
      expect(flight.isFavorite, isTrue);

      final reminder = await db.select(db.reminders).getSingle();
      expect(reminder.notificationId, 424242);
      expect(reminder.title, 'Check in');
      expect(reminder.scheduledAt, DateTime(2026, 12, 1, 9));
      expect(reminder.timezone, 'Asia/Dhaka');
      expect(reminder.screenshotId, flight.id);
      expect(reminder.status, ReminderStatus.scheduled);

      // The new tables accept rows and enforce their foreign keys.
      final space = await db
          .into(db.spaces)
          .insert(
            SpacesCompanion.insert(title: 'Lisbon', icon: 'flight', color: 1),
          );
      await db
          .into(db.spaceMemberships)
          .insert(
            SpaceMembershipsCompanion.insert(
              spaceId: space,
              memoryId: flight.id,
              source: 'user',
            ),
          );
      await expectLater(
        db
            .into(db.spaceMemberships)
            .insert(
              SpaceMembershipsCompanion.insert(
                spaceId: space,
                memoryId: 999999,
                source: 'user',
              ),
            ),
        throwsA(isA<SqliteException>()),
      );

      // Deleting a memory still cascades as before, and to the new tables.
      await (db.delete(
        db.screenshots,
      )..where((s) => s.id.equals(flight.id))).go();
      final orphan = await db.select(db.reminders).getSingle();
      expect(orphan.screenshotId, isNull);
      expect(orphan.notificationId, 424242);
      expect(await db.select(db.spaceMemberships).get(), isEmpty);
      expect(
        await db.select(db.extractedEntities).get(),
        isEmpty,
        reason: 'the only entity belonged to the deleted screenshot',
      );
    },
  );
}
