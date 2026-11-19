import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:snapaction/core/database/app_database.dart';
import 'package:snapaction/core/repositories/search_repository.dart';
import 'package:snapaction/core/services/settings_repository.dart';
import 'package:snapaction/features/backup/application/backup_codec.dart';
import 'package:snapaction/features/backup/application/backup_service.dart';
import 'package:snapaction/features/settings/application/data_management_service.dart';
import 'package:snapaction/services/file_storage/file_storage_service.dart';
import 'package:snapaction/services/search/search_indexer.dart';

import '../helpers/test_app.dart';

class _Library {
  _Library(this.db, this.storage, this.root);

  final AppDatabase db;
  final FileStorageService storage;
  final Directory root;

  late final backup = BackupService(
    db: db,
    storage: storage,
    indexer: SearchIndexer(db),
    exportDir: storage.exportsDir,
    clock: () => DateTime(2026, 11, 18, 10, 30),
  );

  static Future<_Library> create() async {
    final root = await Directory.systemTemp.createTemp('snapaction_backup');
    final storage = FileStorageService(root);
    await storage.ensureDirectories();
    return _Library(createTestDatabase(), storage, root);
  }

  Future<void> dispose() async {
    await db.close();
    if (root.existsSync()) await root.delete(recursive: true);
  }

  Future<int> addScreenshot(
    List<int> bytes, {
    String text = '',
    String? title,
    ProcessingStatus status = ProcessingStatus.completed,
  }) async {
    final image = File(storage.newScreenshotPath('.png'))
      ..writeAsBytesSync(bytes);
    final thumb = File(storage.newThumbnailPath())
      ..writeAsBytesSync([9, ...bytes]);
    final id = await db
        .into(db.screenshots)
        .insert(
          ScreenshotsCompanion.insert(
            localFilePath: image.path,
            thumbnailPath: Value(thumb.path),
            contentHash: sha256.convert(bytes).toString(),
            importedAt: DateTime(2026, 11, 1),
            source: ScreenshotSource.picker,
            processingStatus: status,
            fileSize: bytes.length,
            title: Value(title),
          ),
        );
    if (text.isNotEmpty) {
      await db
          .into(db.ocrResults)
          .insert(
            OcrResultsCompanion.insert(
              screenshotId: id,
              rawText: text,
              textBlocksJson: '[]',
              recognizerName: 'fake',
              recognizerVersion: '0',
              processedAt: DateTime(2026, 11, 1),
            ),
          );
    }
    return id;
  }
}

Future<void> _rewriteZip(
  String path,
  ArchiveFile? Function(ArchiveFile f) map, {
  List<ArchiveFile> extra = const [],
}) async {
  final original = ZipDecoder().decodeBytes(File(path).readAsBytesSync());
  final out = Archive();
  for (final f in original.files) {
    final replaced = map(f);
    if (replaced != null) out.add(replaced);
  }
  extra.forEach(out.add);
  File(path).writeAsBytesSync(ZipEncoder().encodeBytes(out));
}

ArchiveFile _copy(ArchiveFile f) => ArchiveFile.bytes(f.name, f.readBytes()!);

void main() {
  // Restore tests use a source and a target library side by side.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late _Library source;

  setUp(() async => source = await _Library.create());
  tearDown(() => source.dispose());

  Future<void> seedRichLibrary() async {
    final db = source.db;
    final a = await source.addScreenshot(
      [1, 2, 3, 4],
      text: 'Invoice 2041 total EUR 49.99',
      title: 'Invoice',
    );
    final b = await source.addScreenshot([5, 6, 7], text: 'Flight LH 123');
    await db
        .into(db.extractedEntities)
        .insert(
          ExtractedEntitiesCompanion.insert(
            screenshotId: a,
            entityType: EntityType.amount,
            rawValue: 'EUR 49.99',
            normalizedValue: const Value('{"currency":"EUR","minor":4999}'),
            validationStatus: ValidationStatus.valid,
          ),
        );
    final tag = await db
        .into(db.tags)
        .insert(TagsCompanion.insert(name: 'work'));
    await db
        .into(db.screenshotTags)
        .insert(ScreenshotTagsCompanion.insert(screenshotId: a, tagId: tag));
    final col = await db
        .into(db.collections)
        .insert(
          CollectionsCompanion.insert(name: 'Trips', icon: 'flight', color: 1),
        );
    await db
        .into(db.collectionItems)
        .insert(
          CollectionItemsCompanion.insert(collectionId: col, screenshotId: b),
        );
    await db
        .into(db.notes)
        .insert(
          NotesCompanion.insert(screenshotId: a, content: 'Pay by Friday'),
        );
    await db
        .into(db.reminders)
        .insert(
          RemindersCompanion.insert(
            title: 'Pay invoice',
            scheduledAt: DateTime(2026, 12, 1, 9),
            timezone: 'Europe/Berlin',
            notificationId: 4242,
            status: ReminderStatus.scheduled,
            screenshotId: Value(a),
          ),
        );
    await db
        .into(db.wishlistItems)
        .insert(
          WishlistItemsCompanion.insert(
            productName: const Value('Headphones'),
            amountMinorUnits: const Value(12900),
            currency: const Value('EUR'),
          ),
        );
  }

  group('ZIP backup', () {
    test('round-trips images and records into an empty library', () async {
      await seedRichLibrary();
      final export = await source.backup.export(ExportKind.zip);
      expect(export.name, 'mindtiq-20261118-1030.zip');
      expect(export.mime, 'application/zip');
      expect(export.screenshots, 2);

      final target = await _Library.create();
      addTearDown(target.dispose);
      final preview = await target.backup.inspect(export.file.path);
      expect(preview.screenshots, 2);
      expect(preview.collections, 1);
      expect(preview.tags, 1);
      expect(preview.reminders, 1);
      expect(preview.wishlistItems, 1);
      expect(preview.missingImages, 0);
      expect(preview.schemaVersion, BackupCodec.schemaVersion);

      final report = await target.backup.restore(export.file.path);
      expect(report.restored, 2);
      expect(report.duplicates, 0);
      expect(report.corrupted, 0);
      expect(report.reminders, 1);

      final db = target.db;
      final shots = await db.select(db.screenshots).get();
      expect(shots, hasLength(2));
      for (final s in shots) {
        expect(s.source, ScreenshotSource.backup);
        expect(target.storage.isAppOwned(s.localFilePath), isTrue);
        expect(File(s.localFilePath).existsSync(), isTrue);
        expect(
          sha256.convert(File(s.localFilePath).readAsBytesSync()).toString(),
          s.contentHash,
        );
        expect(File(s.thumbnailPath!).existsSync(), isTrue);
      }
      final invoice = shots.firstWhere((s) => s.title == 'Invoice');
      final note = await db.select(db.notes).getSingle();
      expect(note.screenshotId, invoice.id);
      final entity = await db.select(db.extractedEntities).getSingle();
      expect(entity.screenshotId, invoice.id);
      expect(entity.normalizedValue, contains('4999'));
      expect(
        (await db.select(db.screenshotTags).getSingle()).screenshotId,
        invoice.id,
      );
      expect(await db.select(db.collectionItems).get(), hasLength(1));
      final reminder = await db.select(db.reminders).getSingle();
      expect(reminder.screenshotId, invoice.id);
      expect(reminder.scheduledAt, DateTime(2026, 12, 1, 9));
      final wish = await db.select(db.wishlistItems).getSingle();
      expect(wish.amountMinorUnits, 12900);

      // Restored text is searchable straight away.
      final results = await SearchRepository(db)
          .search(const SearchRequest(text: 'invoice'));
      expect(results.hits.map((h) => h.screenshot.id), [invoice.id]);

      // Staging and the restore marker are cleaned up.
      expect(target.storage.restoreMarker.existsSync(), isFalse);
      final staged = target.storage.stagingDir.existsSync()
          ? target.storage.stagingDir.listSync()
          : const <FileSystemEntity>[];
      expect(staged, isEmpty);
    });

    test(
      'restoring into the same library skips duplicates and changes nothing',
      () async {
        await seedRichLibrary();
        final export = await source.backup.export(ExportKind.zip);
        final report = await source.backup.restore(export.file.path);
        expect(report.restored, 0);
        expect(report.duplicates, 2);
        expect(report.reminders, 0);
        final db = source.db;
        expect(await db.select(db.screenshots).get(), hasLength(2));
        expect(await db.select(db.notes).get(), hasLength(1));
        expect(await db.select(db.reminders).get(), hasLength(1));
        expect(await db.select(db.collections).get(), hasLength(1));
        expect(await db.select(db.tags).get(), hasLength(1));
        expect(await db.select(db.wishlistItems).get(), hasLength(1));
        expect(source.storage.screenshotsDir.listSync(), hasLength(2));
      },
    );

    test('merges into a library that has its own data', () async {
      await seedRichLibrary();
      final export = await source.backup.export(ExportKind.zip);

      final target = await _Library.create();
      addTearDown(target.dispose);
      final db = target.db;
      await target.addScreenshot([1, 2, 3, 4], title: 'Mine');
      await db.into(db.tags).insert(TagsCompanion.insert(name: 'work'));
      await db
          .into(db.collections)
          .insert(
            CollectionsCompanion.insert(name: 'trips', icon: 'x', color: 2),
          );
      await db
          .into(db.reminders)
          .insert(
            RemindersCompanion.insert(
              title: 'Mine',
              scheduledAt: DateTime(2026, 12, 2),
              timezone: 'UTC',
              notificationId: 4242,
              status: ReminderStatus.scheduled,
            ),
          );

      final report = await target.backup.restore(export.file.path);
      expect(report.restored, 1);
      expect(report.duplicates, 1);

      // The local copy keeps its own title; nothing is overwritten.
      final shots = await db.select(db.screenshots).get();
      expect(shots, hasLength(2));
      expect(shots.where((s) => s.title == 'Mine'), hasLength(1));
      expect(shots.where((s) => s.title == 'Invoice'), isEmpty);
      // Tags and collections merge by name.
      expect(await db.select(db.tags).get(), hasLength(1));
      expect(await db.select(db.collections).get(), hasLength(1));
      // The restored reminder gets a fresh notification id.
      final ids = (await db.select(db.reminders).get()).map(
        (r) => r.notificationId,
      );
      expect(ids.toSet(), hasLength(2));
    });

    test('pending screenshots are queued for processing again', () async {
      await source.addScreenshot([
        1,
        1,
        1,
      ], status: ProcessingStatus.processing);
      final export = await source.backup.export(ExportKind.zip);
      final target = await _Library.create();
      addTearDown(target.dispose);
      await target.backup.restore(export.file.path);
      final shot = await target.db.select(target.db.screenshots).getSingle();
      expect(shot.processingStatus, ProcessingStatus.pending);
      final job = await target.db.select(target.db.processingJobs).getSingle();
      expect(job.screenshotId, shot.id);
      expect(job.status, JobStatus.queued);
    });

    test(
      'a damaged image is skipped and reported, the rest is restored',
      () async {
        await source.addScreenshot([1, 2, 3, 4], title: 'Good');
        final bad = await source.addScreenshot([5, 6, 7], title: 'Bad');
        final export = await source.backup.export(ExportKind.zip);
        await _rewriteZip(
          export.file.path,
          (f) => f.name.startsWith('images/$bad.')
              ? ArchiveFile.bytes(f.name, [0, 0, 0])
              : _copy(f),
        );
        final target = await _Library.create();
        addTearDown(target.dispose);
        final report = await target.backup.restore(export.file.path);
        expect(report.restored, 1);
        expect(report.corrupted, 1);
        final shots = await target.db.select(target.db.screenshots).get();
        expect(shots.single.title, 'Good');
        expect(target.storage.screenshotsDir.listSync(), hasLength(1));
      },
    );

    test('missing images are counted in the preview', () async {
      final id = await source.addScreenshot([1, 2, 3]);
      final export = await source.backup.export(ExportKind.zip);
      await _rewriteZip(
        export.file.path,
        (f) => f.name.startsWith('images/$id.') ? null : _copy(f),
      );
      final preview = await source.backup.inspect(export.file.path);
      expect(preview.missingImages, 1);
    });
  });

  group('archive validation', () {
    Future<String> exportOne() async {
      await source.addScreenshot([1, 2, 3]);
      return (await source.backup.export(ExportKind.zip)).file.path;
    }

    Future<void> expectRejected(String path, Matcher message) async {
      await expectLater(
        source.backup.restore(path),
        throwsA(
          isA<BackupException>().having((e) => e.message, 'message', message),
        ),
      );
      // Nothing was added and nothing was left behind.
      expect(await source.db.select(source.db.screenshots).get(), hasLength(1));
      expect(source.storage.screenshotsDir.listSync(), hasLength(1));
    }

    for (final name in [
      '../evil.png',
      'images/../../evil.png',
      '/etc/passwd',
      r'images\..\evil.png',
      'C:/evil.png',
      'images/./1.png',
      'other/1.png',
      'images/1.exe',
    ]) {
      test('rejects the entry "$name"', () {
        expect(
          () => BackupCodec.checkEntryName(name, isFile: true),
          throwsA(isA<BackupException>()),
        );
      });
    }

    test('accepts the expected layout', () {
      for (final name in [
        'manifest.json',
        'data.json',
        'images/12.png',
        'thumbs/12.jpg',
      ]) {
        BackupCodec.checkEntryName(name, isFile: true);
      }
      BackupCodec.checkEntryName('images/', isFile: false);
    });

    test('rejects an archive with a path-traversal entry', () async {
      final path = await exportOne();
      await _rewriteZip(
        path,
        _copy,
        extra: [
          ArchiveFile.bytes('../../outside.png', [1]),
        ],
      );
      await expectRejected(
        path,
        anyOf(contains('unsafe'), contains('not a valid ZIP')),
      );
      expect(
        File('${source.root.parent.path}/outside.png').existsSync(),
        isFalse,
      );
    });

    test('rejects an image record that points outside the layout', () async {
      final path = await exportOne();
      await _rewriteZip(path, (f) {
        if (f.name != BackupCodec.dataName) return _copy(f);
        final data =
            jsonDecode(utf8.decode(f.readBytes()!)) as Map<String, Object?>;
        final shots = data['screenshots']! as List<Object?>;
        (shots.first! as Map<String, Object?>)['image'] = '../data.json';
        return ArchiveFile.string(f.name, jsonEncode(data));
      });
      await expectRejected(path, contains('damaged'));
    });

    test('restores a version 1 backup made before titleLocked', () async {
      final path = await exportOne();
      await _rewriteZip(path, (f) {
        if (f.name != BackupCodec.manifestName &&
            f.name != BackupCodec.dataName) {
          return _copy(f);
        }
        final body =
            jsonDecode(utf8.decode(f.readBytes()!)) as Map<String, Object?>;
        if (f.name == BackupCodec.manifestName) {
          body['schemaVersion'] = 1;
        } else {
          for (final s in body['screenshots']! as List<Object?>) {
            ((s! as Map<String, Object?>)['row']! as Map<String, Object?>)
                .remove('titleLocked');
          }
        }
        return ArchiveFile.string(f.name, jsonEncode(body));
      });
      final target = await _Library.create();
      addTearDown(target.dispose);
      final report = await target.backup.restore(path);
      expect(report.restored, 1);
      final row = await target.db.select(target.db.screenshots).getSingle();
      expect(row.titleLocked, isFalse);
    });

    test('rejects a backup from a newer app version', () async {
      final path = await exportOne();
      await _rewriteZip(path, (f) {
        if (f.name != BackupCodec.manifestName) return _copy(f);
        final m =
            jsonDecode(utf8.decode(f.readBytes()!)) as Map<String, Object?>;
        m['schemaVersion'] = BackupCodec.schemaVersion + 1;
        return ArchiveFile.string(f.name, jsonEncode(m));
      });
      await expectRejected(path, contains('newer version'));
    });

    test('rejects files that are not Mindtiq backups', () async {
      final path = await exportOne();
      final notZip = File('${source.root.path}/notes.zip')
        ..writeAsStringSync('hello');
      await expectRejected(
        notZip.path,
        anyOf(contains('not a valid ZIP'), contains('not a Mindtiq backup')),
      );

      await _rewriteZip(
        path,
        (f) => f.name == BackupCodec.manifestName ? null : _copy(f),
      );
      await expectRejected(path, contains('not a Mindtiq backup'));
    });

    test('rejects malformed records', () async {
      final path = await exportOne();
      await _rewriteZip(path, (f) {
        if (f.name != BackupCodec.dataName) return _copy(f);
        final data =
            jsonDecode(utf8.decode(f.readBytes()!)) as Map<String, Object?>;
        data['reminders'] = [
          {'title': 42},
        ];
        return ArchiveFile.string(f.name, jsonEncode(data));
      });
      await expectRejected(path, contains('"reminders" record is invalid'));
    });

    test('rejects duplicate screenshot records', () async {
      final path = await exportOne();
      await _rewriteZip(path, (f) {
        if (f.name != BackupCodec.dataName) return _copy(f);
        final data =
            jsonDecode(utf8.decode(f.readBytes()!)) as Map<String, Object?>;
        final shots = data['screenshots']! as List<Object?>;
        data['screenshots'] = [...shots, ...shots];
        return ArchiveFile.string(f.name, jsonEncode(data));
      });
      await expectRejected(path, contains('duplicate'));
    });

    test('enforces entry count and size limits', () async {
      final path = await exportOne();
      expect(
        () => BackupCodec.inspect(
          path,
          limits: const BackupLimits(maxEntries: 2),
        ),
        throwsA(
          isA<BackupException>().having(
            (e) => e.message,
            'message',
            contains('too many'),
          ),
        ),
      );
      expect(
        () => BackupCodec.inspect(
          path,
          limits: const BackupLimits(maxImageBytes: 2),
        ),
        throwsA(
          isA<BackupException>().having(
            (e) => e.message,
            'message',
            contains('larger than allowed'),
          ),
        ),
      );
      expect(
        () => BackupCodec.inspect(
          path,
          limits: const BackupLimits(maxArchiveBytes: 10),
        ),
        throwsA(isA<BackupException>()),
      );
    });
  });

  group('JSON and CSV export', () {
    test(
      'JSON export carries the schema version and no device paths',
      () async {
        await seedRichLibrary();
        final export = await source.backup.export(ExportKind.json);
        expect(export.mime, 'application/json');
        final body = jsonDecode(
          await export.file.readAsString(),
        ) as Map<String, Object?>;
        expect(body['format'], BackupCodec.format);
        expect(body['schemaVersion'], BackupCodec.schemaVersion);
        final text = await export.file.readAsString();
        expect(text, isNot(contains(source.root.path.replaceAll(r'\', r'\\'))));
        final data = body['data']! as Map<String, Object?>;
        expect(data['screenshots'], hasLength(2));
        expect(data['ocrResults'], hasLength(2));
      },
    );

    test('CSV export quotes values and neutralises formulas', () async {
      expect(BackupService.csvField(null), '');
      expect(BackupService.csvField('plain'), 'plain');
      expect(BackupService.csvField('a,b'), '"a,b"');
      expect(BackupService.csvField('say "hi"'), '"say ""hi"""');
      expect(BackupService.csvField('line\nbreak'), '"line\nbreak"');
      expect(
        BackupService.csvField('=HYPERLINK("x")'),
        '"\'=HYPERLINK(""x"")"',
      );
      expect(BackupService.csvField('+1 555'), "'+1 555");
      expect(BackupService.csvField('@SUM(A1)'), "'@SUM(A1)");

      await seedRichLibrary();
      final export = await source.backup.export(ExportKind.csv);
      final lines = (await export.file.readAsString()).split('\r\n');
      expect(
        lines.first,
        startsWith('screenshot_id,title,imported_at,category,type'),
      );
      expect(lines[1], contains('EUR 49.99'));
      expect(lines[1], contains(',amount,'));
    });

    test('only the newest export file is kept', () async {
      await source.backup.export(ExportKind.json);
      await source.backup.export(ExportKind.csv);
      final files = source.storage.exportsDir.listSync();
      expect(files, hasLength(1));
      expect(files.single.path, endsWith('.csv'));
    });
  });

  test(
    'an interrupted restore leaves no orphaned files after restart',
    () async {
      final kept = await source.addScreenshot([1, 2, 3]);
      final orphan = File(source.storage.newScreenshotPath('.png'))
        ..writeAsBytesSync([7]);
      await source.storage.restoreMarker.writeAsString('1');
      await BackupService.recoverInterruptedRestore(source.db, source.storage);
      expect(orphan.existsSync(), isFalse);
      final row = await (source.db.select(
        source.db.screenshots,
      )..where((s) => s.id.equals(kept))).getSingle();
      expect(File(row.localFilePath).existsSync(), isTrue);
      expect(source.storage.restoreMarker.existsSync(), isFalse);
    },
  );

  group('delete all data', () {
    test('removes app copies and records but keeps system categories and key settings', () async {
      await seedRichLibrary();
      final db = source.db;
      await db
          .into(db.searchHistory)
          .insert(
            SearchHistoryCompanion.insert(
              query: 'invoice',
              searchedAt: DateTime(2026),
            ),
          );
      final settings = await SettingsRepository.load(db);
      await settings.setString(SettingsKeys.themeMode, 'dark');
      await settings.setBool(SettingsKeys.onboardingCompleted, value: true);
      await settings.setBool(SettingsKeys.appLockEnabled, value: true);
      await settings.setString(SettingsKeys.dateOrder, 'mdy');
      final notifications = FakeNotificationService();
      await notifications.schedule(
        id: 4242,
        title: 'Pay',
        at: DateTime(2026, 12),
        route: '/reminders',
      );
      final categoriesBefore = await db.select(db.categories).get();
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              slug: 'custom',
              name: 'Custom',
              icon: 'x',
              color: 1,
            ),
          );
      // A file outside the app's folders stands in for the gallery original.
      final outside = await Directory.systemTemp.createTemp('gallery');
      addTearDown(() => outside.delete(recursive: true));
      final original = File('${outside.path}/original.png')
        ..writeAsBytesSync([1, 2, 3, 4]);

      final service = DataManagementService(
        db: db,
        storage: source.storage,
        settings: settings,
        notifications: notifications,
        indexer: SearchIndexer(db),
      );
      await service.deleteAll();

      for (final table in <TableInfo<Table, Object?>>[
        db.screenshots,
        db.ocrResults,
        db.extractedEntities,
        db.notes,
        db.tags,
        db.collections,
        db.reminders,
        db.wishlistItems,
        db.searchHistory,
        db.processingJobs,
      ]) {
        expect(
          await db.select(table).get(),
          isEmpty,
          reason: table.actualTableName,
        );
      }
      expect(
        await db.select(db.categories).get(),
        hasLength(categoriesBefore.length),
      );
      expect(notifications.scheduled, isEmpty);
      expect(source.storage.screenshotsDir.listSync(), isEmpty);
      expect(source.storage.thumbnailsDir.listSync(), isEmpty);
      expect(original.existsSync(), isTrue);
      expect(settings.getString(SettingsKeys.themeMode), 'dark');
      expect(settings.getBool(SettingsKeys.onboardingCompleted), isTrue);
      expect(settings.getBool(SettingsKeys.appLockEnabled), isTrue);
      expect(settings.getString(SettingsKeys.dateOrder), isNull);
      final results = await SearchRepository(db)
          .search(const SearchRequest(text: 'invoice'));
      expect(results.hits, isEmpty);
    });

    test('clears search history only', () async {
      final db = source.db;
      await source.addScreenshot([1]);
      await db
          .into(db.searchHistory)
          .insert(
            SearchHistoryCompanion.insert(
              query: 'x',
              searchedAt: DateTime(2026),
            ),
          );
      final service = DataManagementService(
        db: db,
        storage: source.storage,
        settings: await SettingsRepository.load(db),
        notifications: FakeNotificationService(),
        indexer: SearchIndexer(db),
      );
      await service.clearSearchHistory();
      expect(await db.select(db.searchHistory).get(), isEmpty);
      expect(await db.select(db.screenshots).get(), hasLength(1));
    });
  });
}
