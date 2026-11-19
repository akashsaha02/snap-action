import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../../../core/database/app_database.dart';
import '../../../core/repositories/screenshot_repository.dart';
import '../../../services/duplicate_detection/perceptual_hash.dart';
import '../../../services/file_storage/file_storage_service.dart';
import '../../../services/image_processing/image_processing_service.dart';
import '../../../services/search/search_indexer.dart';

class ImportCandidate {
  const ImportCandidate({required this.path, this.originalName});

  final String path;
  final String? originalName;
}

class DuplicateHit {
  const DuplicateHit({required this.name, required this.existingId});

  final String name;
  final int existingId;
}

class ImportFailure {
  const ImportFailure({required this.name, required this.reason});

  final String name;
  final String reason;
}

class ImportResult {
  const ImportResult({
    this.importedIds = const [],
    this.duplicates = const [],
    this.failures = const [],
    this.similar = const {},
  });

  final List<int> importedIds;
  final List<DuplicateHit> duplicates;
  final List<ImportFailure> failures;

  /// New screenshot id -> visually similar existing ids (never auto-removed).
  final Map<int, List<int>> similar;

  int get importedCount => importedIds.length;

  ImportResult merge(ImportResult other) => ImportResult(
    importedIds: [...importedIds, ...other.importedIds],
    duplicates: [...duplicates, ...other.duplicates],
    failures: [...failures, ...other.failures],
    similar: {...similar, ...other.similar},
  );
}

typedef ImportProgress = void Function(int done, int total);

/// Image import -> validation -> duplicate detection -> private storage ->
/// thumbnail -> database row + queued processing job.
class ImportService {
  ImportService({
    required this._db,
    required this._storage,
    required this._indexer,
    this.images = const ImageProcessingService(),
    this.concurrency = 2,
    this.detectSimilar = true,
  }) : _repo = ScreenshotRepository(_db);

  final AppDatabase _db;
  final FileStorageService _storage;
  final SearchIndexer _indexer;
  final ScreenshotRepository _repo;
  final ImageProcessingService images;
  final int concurrency;
  final bool detectSimilar;

  Future<ImportResult> importFiles(
    List<ImportCandidate> files, {
    required ScreenshotSource source,
    ImportProgress? onProgress,
    bool deleteSourceAfterImport = false,
  }) async {
    var result = const ImportResult();
    var done = 0;
    final queue = [...files];
    final seenHashes = <String>{};
    final knownHashes = detectSimilar ? await _repo.perceptualHashes() : null;

    Future<void> worker() async {
      while (queue.isNotEmpty) {
        final file = queue.removeAt(0);
        final single = await _importOne(
          file,
          source: source,
          seenHashes: seenHashes,
          knownPerceptual: knownHashes,
        );
        result = result.merge(single);
        if (deleteSourceAfterImport) {
          await _deleteQuietly(file.path);
        }
        done++;
        onProgress?.call(done, files.length);
      }
    }

    await Future.wait([
      for (var i = 0; i < concurrency.clamp(1, 4); i++) worker(),
    ]);
    return result;
  }

  Future<ImportResult> _importOne(
    ImportCandidate file, {
    required ScreenshotSource source,
    required Set<String> seenHashes,
    List<(int, String)>? knownPerceptual,
  }) async {
    final name = file.originalName ?? p.basename(file.path);
    final thumbPath = _storage.newThumbnailPath();
    try {
      if (!File(file.path).existsSync()) {
        return ImportResult(
          failures: [
            ImportFailure(name: name, reason: 'File is no longer available.'),
          ],
        );
      }
      final analysis = await images.analyzeAndThumbnail(
        sourcePath: file.path,
        thumbnailPath: thumbPath,
      );

      final existing = await _repo.idByHash(analysis.sha256);
      if (existing != null || !seenHashes.add(analysis.sha256)) {
        await _storage.deleteFiles([thumbPath]);
        return ImportResult(
          duplicates: [
            if (existing != null)
              DuplicateHit(name: name, existingId: existing),
          ],
          failures: [
            if (existing == null)
              ImportFailure(
                name: name,
                reason: 'Selected twice in this import.',
              ),
          ],
        );
      }

      final stored = await _storage.storeOriginal(
        File(file.path),
        analysis.extension,
      );
      final now = DateTime.now();
      final int id;
      try {
        id = await _db.transaction(() async {
          final newId = await _db
              .into(_db.screenshots)
              .insert(
                ScreenshotsCompanion.insert(
                  originalFilename: Value(file.originalName),
                  localFilePath: stored.path,
                  thumbnailPath: Value(thumbPath),
                  contentHash: analysis.sha256,
                  perceptualHash: Value(analysis.perceptualHash),
                  importedAt: now,
                  capturedAt: Value(analysis.capturedAt),
                  source: source,
                  processingStatus: ProcessingStatus.pending,
                  fileSize: analysis.fileSize,
                  imageWidth: Value(analysis.width),
                  imageHeight: Value(analysis.height),
                ),
              );
          await _db
              .into(_db.processingJobs)
              .insert(
                ProcessingJobsCompanion.insert(
                  screenshotId: newId,
                  jobType: JobType.process,
                  status: JobStatus.queued,
                ),
              );
          return newId;
        });
      } on Object {
        await _storage.deleteFiles([stored.path, thumbPath]);
        rethrow;
      }
      await _indexer.reindex(id);

      final similar = <int>[
        for (final (otherId, hash)
            in knownPerceptual ?? const <(int, String)>[])
          if (PerceptualHash.isSimilar(hash, analysis.perceptualHash)) otherId,
      ];
      knownPerceptual?.add((id, analysis.perceptualHash));
      return ImportResult(
        importedIds: [id],
        similar: similar.isEmpty ? const {} : {id: similar},
      );
    } on ImageValidationException catch (e) {
      await _storage.deleteFiles([thumbPath]);
      return ImportResult(
        failures: [ImportFailure(name: name, reason: e.message)],
      );
    } on FileSystemException catch (e) {
      await _storage.deleteFiles([thumbPath]);
      final noSpace = e.osError?.errorCode == 28;
      return ImportResult(
        failures: [
          ImportFailure(
            name: name,
            reason: noSpace
                ? 'Not enough storage space on this device.'
                : 'The file could not be read.',
          ),
        ],
      );
    }
  }

  Future<void> _deleteQuietly(String path) async {
    try {
      final f = File(path);
      if (f.existsSync()) await f.delete();
    } on FileSystemException {
      // Temporary copy; the OS clears the cache eventually.
    }
  }
}
