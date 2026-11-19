import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../../../core/database/app_database.dart';
import '../../../services/file_storage/file_storage_service.dart';
import '../../../services/search/search_indexer.dart';
import 'backup_codec.dart';

enum ExportKind { json, csv, zip }

class ExportResult {
  const ExportResult({
    required this.file,
    required this.mime,
    required this.screenshots,
  });

  final File file;
  final String mime;
  final int screenshots;

  String get name => p.basename(file.path);
}

class RestoreReport {
  const RestoreReport({
    required this.restored,
    required this.duplicates,
    required this.corrupted,
    required this.reminders,
  });

  final int restored;
  final int duplicates;
  final int corrupted;
  final int reminders;
}

/// User-initiated export and restore. Nothing is uploaded; files are written
/// to a temporary folder and handed to the system picker or share sheet.
class BackupService {
  BackupService({
    required this._db,
    required this._storage,
    required this._indexer,
    required this._exportDir,
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final FileStorageService _storage;
  final SearchIndexer _indexer;
  final Directory _exportDir;
  final DateTime Function() _now;

  String _stamp() {
    final n = _now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${n.year}${two(n.month)}${two(n.day)}-${two(n.hour)}${two(n.minute)}';
  }

  Future<File> _target(String ext) async {
    await _exportDir.create(recursive: true);
    // Earlier exports are temporary; only the newest is kept.
    await for (final e in _exportDir.list()) {
      if (e is File && p.basename(e.path).startsWith('snapaction-')) {
        await e.delete();
      }
    }
    return File(p.join(_exportDir.path, 'snapaction-${_stamp()}.$ext'));
  }

  Future<Map<String, Object?>> _snapshot({required bool forArchive}) async {
    final screenshots = await _db.select(_db.screenshots).get();
    List<Map<String, Object?>> json<T>(
      List<T> rows,
      Map<String, Object?> Function(T) f,
    ) => [for (final r in rows) f(r)];
    return {
      'categories': json(
        await _db.select(_db.categories).get(),
        (r) => r.toJson(),
      ),
      'screenshots': [
        for (final s in screenshots)
          {
            'row': (s.toJson()
              ..['localFilePath'] = ''
              ..['thumbnailPath'] = null),
            if (forArchive)
              'image': BackupCodec.imageEntry(s.id, s.localFilePath),
            if (forArchive && s.thumbnailPath != null)
              'thumbnail': BackupCodec.thumbnailEntry(s.id),
          },
      ],
      'ocrResults': json(
        await _db.select(_db.ocrResults).get(),
        (r) => r.toJson(),
      ),
      'entities': json(
        await _db.select(_db.extractedEntities).get(),
        (r) => r.toJson(),
      ),
      'collections': json(
        await _db.select(_db.collections).get(),
        (r) => r.toJson(),
      ),
      'collectionItems': json(
        await _db.select(_db.collectionItems).get(),
        (r) => r.toJson(),
      ),
      'tags': json(await _db.select(_db.tags).get(), (r) => r.toJson()),
      'screenshotTags': json(
        await _db.select(_db.screenshotTags).get(),
        (r) => r.toJson(),
      ),
      'notes': json(await _db.select(_db.notes).get(), (r) => r.toJson()),
      'reminders': json(
        await _db.select(_db.reminders).get(),
        (r) => r.toJson(),
      ),
      'suggestedActions': json(
        await _db.select(_db.suggestedActions).get(),
        (r) => r.toJson(),
      ),
      'wishlistItems': json(
        await _db.select(_db.wishlistItems).get(),
        (r) => r.toJson(),
      ),
      'classificationRules': json(
        await _db.select(_db.classificationRules).get(),
        (r) => r.toJson(),
      ),
    };
  }

  Map<String, Object?> _manifest(int screenshots) => {
    'format': BackupCodec.format,
    'schemaVersion': BackupCodec.schemaVersion,
    'createdAt': _now().millisecondsSinceEpoch,
    'app': 'SnapAction',
    'screenshots': screenshots,
  };

  Future<ExportResult> export(ExportKind kind) async {
    final count = await _db.screenshots.count().getSingle();
    switch (kind) {
      case ExportKind.json:
        final file = await _target('json');
        final body = {
          ..._manifest(count),
          'data': await _snapshot(forArchive: false),
        };
        await file.writeAsString(
          const JsonEncoder.withIndent('  ').convert(body),
          flush: true,
        );
        return ExportResult(
          file: file,
          mime: 'application/json',
          screenshots: count,
        );
      case ExportKind.csv:
        final file = await _target('csv');
        await file.writeAsString(await _entitiesCsv(), flush: true);
        return ExportResult(file: file, mime: 'text/csv', screenshots: count);
      case ExportKind.zip:
        final file = await _target('zip');
        final shots = await _db.select(_db.screenshots).get();
        final request = BackupWriteRequest(
          zipPath: file.path,
          manifestJson: jsonEncode(_manifest(count)),
          dataJson: jsonEncode(await _snapshot(forArchive: true)),
          files: [
            for (final s in shots) ...[
              (s.localFilePath, BackupCodec.imageEntry(s.id, s.localFilePath)),
              if (s.thumbnailPath != null)
                (s.thumbnailPath!, BackupCodec.thumbnailEntry(s.id)),
            ],
          ],
        );
        await _writeInIsolate(request);
        return ExportResult(
          file: file,
          mime: 'application/zip',
          screenshots: count,
        );
    }
  }

  Future<String> _entitiesCsv() async {
    final rows = await _db
        .customSelect(
          'SELECT s.id, s.title, s.imported_at, c.name AS category, e.entity_type, '
          'e.raw_value, e.normalized_value, e.validation_status '
          'FROM extracted_entities e JOIN screenshots s ON s.id = e.screenshot_id '
          'LEFT JOIN categories c ON c.id = coalesce(s.primary_category_id, s.suggested_category_id) '
          'ORDER BY s.id, e.id',
          readsFrom: {_db.extractedEntities, _db.screenshots, _db.categories},
        )
        .get();
    final out = StringBuffer(
      'screenshot_id,title,imported_at,category,type,raw_value,normalized_value,status\r\n',
    );
    for (final r in rows) {
      final imported = DateTime.fromMillisecondsSinceEpoch(
        r.read<int>('imported_at') * 1000,
      );
      out
        ..writeAll([
          r.read<int>('id'),
          csvField(r.read<String?>('title')),
          imported.toIso8601String(),
          csvField(r.read<String?>('category')),
          r.read<String>('entity_type'),
          csvField(r.read<String>('raw_value')),
          csvField(r.read<String?>('normalized_value')),
          r.read<String>('validation_status'),
        ], ',')
        ..write('\r\n');
    }
    return out.toString();
  }

  /// RFC 4180 quoting. Values that spreadsheet apps would run as formulas
  /// are prefixed with an apostrophe.
  static String csvField(String? value) {
    if (value == null) return '';
    var v = value;
    if (v.isNotEmpty && '=+-@\t\r'.contains(v[0])) v = "'$v";
    if (v.contains(RegExp(r'[",\r\n]'))) v = '"${v.replaceAll('"', '""')}"';
    return v;
  }

  // Isolate entry points are static so their closures cannot capture the
  // service, whose database connection cannot be sent to another isolate.
  static Future<void> _writeInIsolate(BackupWriteRequest request) =>
      Isolate.run(() => BackupCodec.writeZip(request));

  static Future<BackupPreview> _inspectInIsolate(String zipPath) =>
      Isolate.run(() => BackupCodec.inspect(zipPath));

  static Future<StagedBackup> _stageInIsolate(String zipPath, String dir) =>
      Isolate.run(() => BackupCodec.stage(zipPath, dir));

  Future<BackupPreview> inspect(String zipPath) => _inspectInIsolate(zipPath);

  /// Merges a backup into the library. Screenshots that already exist (same
  /// content hash) are skipped, together with their OCR text, notes and
  /// suggestions; nothing local is overwritten.
  Future<RestoreReport> restore(String zipPath) async {
    await _storage.stagingDir.create(recursive: true);
    final staged = await _stageInIsolate(zipPath, _storage.stagingDir.path);
    final moved = <String>[];
    // If the app is killed mid-restore, the transaction rolls back and the
    // next start removes files that no row references.
    await _storage.restoreMarker.writeAsString('1', flush: true);
    try {
      final report = await _db.transaction(() => _merge(staged, moved));
      await _indexer.rebuild();
      return report;
    } on Object {
      await _storage.deleteFiles(moved);
      rethrow;
    } finally {
      await _storage.deleteFiles(staged.stagedFiles.values);
      if (_storage.restoreMarker.existsSync()) {
        await _storage.restoreMarker.delete();
      }
    }
  }

  /// Removes image files left behind by an interrupted restore.
  static Future<void> recoverInterruptedRestore(
    AppDatabase db,
    FileStorageService storage,
  ) async {
    if (!storage.restoreMarker.existsSync()) return;
    final rows = await db.select(db.screenshots).get();
    await storage.removeOrphans({
      for (final r in rows) ...[
        p.normalize(r.localFilePath),
        if (r.thumbnailPath != null) p.normalize(r.thumbnailPath!),
      ],
    });
    await storage.restoreMarker.delete();
  }

  Future<RestoreReport> _merge(StagedBackup staged, List<String> moved) async {
    final d = staged.data;

    // Categories: system categories match by slug; custom ones are added.
    final localCats = {
      for (final c in await _db.select(_db.categories).get()) c.slug: c.id,
    };
    final catMap = <int, int>{};
    for (final c in d.categories) {
      final existing = localCats[c.slug];
      catMap[c.id] =
          existing ??
          await _db
              .into(_db.categories)
              .insert(
                CategoriesCompanion.insert(
                  slug: c.slug,
                  name: c.name,
                  icon: c.icon,
                  color: c.color,
                ),
              );
    }

    // Screenshots.
    final shotMap = <int, int>{};
    final restoredIds = <int>{};
    var duplicates = 0;
    for (final s in d.screenshots) {
      if (staged.corrupted.contains(s.row.id)) continue;
      final existing =
          await (_db.selectOnly(_db.screenshots)
                ..addColumns([_db.screenshots.id])
                ..where(_db.screenshots.contentHash.equals(s.row.contentHash)))
              .map((r) => r.read(_db.screenshots.id))
              .getSingleOrNull();
      if (existing != null) {
        shotMap[s.row.id] = existing;
        duplicates++;
        continue;
      }
      final image = staged.stagedFiles[s.image];
      if (image == null) continue;
      final finalImage = _storage.newScreenshotPath(p.extension(image));
      await File(image).rename(finalImage);
      moved.add(finalImage);
      String? finalThumb;
      final thumb = s.thumbnail == null
          ? null
          : staged.stagedFiles[s.thumbnail];
      if (thumb != null) {
        finalThumb = _storage.newThumbnailPath();
        await File(thumb).rename(finalThumb);
        moved.add(finalThumb);
      }
      final r = s.row;
      final pending = r.processingStatus != ProcessingStatus.completed;
      final id = await _db
          .into(_db.screenshots)
          .insert(
            r
                .toCompanion(false)
                .copyWith(
                  id: const Value.absent(),
                  localFilePath: Value(finalImage),
                  thumbnailPath: Value(finalThumb),
                  source: const Value(ScreenshotSource.backup),
                  primaryCategoryId: Value(
                    r.primaryCategoryId == null
                        ? null
                        : catMap[r.primaryCategoryId],
                  ),
                  suggestedCategoryId: Value(
                    r.suggestedCategoryId == null
                        ? null
                        : catMap[r.suggestedCategoryId],
                  ),
                  processingStatus: Value(
                    pending ? ProcessingStatus.pending : r.processingStatus,
                  ),
                ),
          );
      shotMap[r.id] = id;
      restoredIds.add(r.id);
      if (pending) {
        await _db
            .into(_db.processingJobs)
            .insert(
              ProcessingJobsCompanion.insert(
                screenshotId: id,
                jobType: JobType.process,
                status: JobStatus.queued,
              ),
            );
      }
    }

    // Per-screenshot data, only for newly restored screenshots.
    for (final o in d.ocr.where((o) => restoredIds.contains(o.screenshotId))) {
      await _db
          .into(_db.ocrResults)
          .insert(
            o
                .toCompanion(false)
                .copyWith(
                  id: const Value.absent(),
                  screenshotId: Value(shotMap[o.screenshotId]!),
                ),
          );
    }
    for (final e in d.entities.where(
      (e) => restoredIds.contains(e.screenshotId),
    )) {
      await _db
          .into(_db.extractedEntities)
          .insert(
            e
                .toCompanion(false)
                .copyWith(
                  id: const Value.absent(),
                  screenshotId: Value(shotMap[e.screenshotId]!),
                ),
          );
    }
    for (final n in d.notes.where(
      (n) => restoredIds.contains(n.screenshotId),
    )) {
      await _db
          .into(_db.notes)
          .insert(
            n
                .toCompanion(false)
                .copyWith(
                  id: const Value.absent(),
                  screenshotId: Value(shotMap[n.screenshotId]!),
                ),
          );
    }
    for (final a in d.actions.where(
      (a) => restoredIds.contains(a.screenshotId),
    )) {
      await _db
          .into(_db.suggestedActions)
          .insert(
            a
                .toCompanion(false)
                .copyWith(
                  id: const Value.absent(),
                  screenshotId: Value(shotMap[a.screenshotId]!),
                ),
          );
    }

    // Collections and tags merge by name.
    final localCollections = {
      for (final c in await _db.select(_db.collections).get())
        c.name.toLowerCase(): c.id,
    };
    final collectionMap = <int, int>{};
    for (final c in d.collections) {
      collectionMap[c.id] =
          localCollections[c.name.toLowerCase()] ??
          await _db
              .into(_db.collections)
              .insert(c.toCompanion(false).copyWith(id: const Value.absent()));
    }
    for (final i in d.collectionItems) {
      final shot = shotMap[i.screenshotId];
      final col = collectionMap[i.collectionId];
      if (shot == null || col == null) continue;
      await _db
          .into(_db.collectionItems)
          .insert(
            CollectionItemsCompanion.insert(
              collectionId: col,
              screenshotId: shot,
              addedAt: Value(i.addedAt),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
    final localTags = {
      for (final t in await _db.select(_db.tags).get()) t.name: t.id,
    };
    final tagMap = <int, int>{};
    for (final t in d.tags) {
      tagMap[t.id] =
          localTags[t.name] ??
          await _db.into(_db.tags).insert(TagsCompanion.insert(name: t.name));
    }
    for (final st in d.screenshotTags) {
      final shot = shotMap[st.screenshotId];
      final tag = tagMap[st.tagId];
      if (shot == null || tag == null) continue;
      await _db
          .into(_db.screenshotTags)
          .insert(
            ScreenshotTagsCompanion.insert(screenshotId: shot, tagId: tag),
            mode: InsertMode.insertOrIgnore,
          );
    }

    // Reminders get fresh notification ids; exact repeats are skipped.
    var reminders = 0;
    final usedNotificationIds = {
      for (final r in await _db.select(_db.reminders).get()) r.notificationId,
    };
    for (final r in d.reminders) {
      final shot = r.screenshotId == null ? null : shotMap[r.screenshotId];
      if (r.screenshotId != null && shot == null) continue;
      final clash =
          await (_db.select(_db.reminders)
                ..where(
                  (x) =>
                      x.title.equals(r.title) &
                      x.scheduledAt.equals(r.scheduledAt) &
                      (shot == null
                          ? x.screenshotId.isNull()
                          : x.screenshotId.equals(shot)),
                )
                ..limit(1))
              .get();
      if (clash.isNotEmpty) continue;
      var notificationId = r.notificationId;
      while (usedNotificationIds.contains(notificationId)) {
        notificationId = (notificationId * 31 + 7) % 0x7FFFFFFF + 1;
      }
      usedNotificationIds.add(notificationId);
      await _db
          .into(_db.reminders)
          .insert(
            r
                .toCompanion(false)
                .copyWith(
                  id: const Value.absent(),
                  screenshotId: Value(shot),
                  notificationId: Value(notificationId),
                ),
          );
      reminders++;
    }

    for (final w in d.wishlist) {
      final shot = w.screenshotId == null ? null : shotMap[w.screenshotId];
      if (w.screenshotId != null && shot == null) continue;
      if (shot != null && !restoredIds.contains(w.screenshotId)) continue;
      if (shot == null) {
        final same =
            await (_db.select(_db.wishlistItems)..where(
                  (x) =>
                      x.screenshotId.isNull() &
                      (w.productName == null
                          ? x.productName.isNull()
                          : x.productName.equals(w.productName!)) &
                      (w.amountMinorUnits == null
                          ? x.amountMinorUnits.isNull()
                          : x.amountMinorUnits.equals(w.amountMinorUnits!)),
                ))
                .get();
        if (same.isNotEmpty) continue;
      }
      await _db
          .into(_db.wishlistItems)
          .insert(
            w
                .toCompanion(false)
                .copyWith(id: const Value.absent(), screenshotId: Value(shot)),
          );
    }

    final localRules = {
      for (final r in await _db.select(_db.classificationRules).get())
        '${r.keyword.toLowerCase()}|${r.categoryId}',
    };
    for (final r in d.rules) {
      final cat = catMap[r.categoryId];
      if (cat == null || !localRules.add('${r.keyword.toLowerCase()}|$cat')) {
        continue;
      }
      await _db
          .into(_db.classificationRules)
          .insert(
            ClassificationRulesCompanion.insert(
              keyword: r.keyword,
              categoryId: cat,
            ),
          );
    }

    return RestoreReport(
      restored: restoredIds.length,
      duplicates: duplicates,
      corrupted: staged.corrupted.length,
      reminders: reminders,
    );
  }
}
