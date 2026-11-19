import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Owns the app-private directories that hold imported screenshots and their
/// thumbnails. Nothing here touches the user's gallery.
class FileStorageService {
  FileStorageService(this._root);

  final Directory _root;
  final _random = Random.secure();

  static Future<FileStorageService> create() async {
    final support = await getApplicationSupportDirectory();
    final service = FileStorageService(support);
    await service.ensureDirectories();
    return service;
  }

  Directory get screenshotsDir => Directory(p.join(_root.path, 'screenshots'));
  Directory get thumbnailsDir => Directory(p.join(_root.path, 'thumbnails'));
  Directory get stagingDir => Directory(p.join(_root.path, 'staging'));

  /// Temporary export files; only the newest export is kept.
  Directory get exportsDir => Directory(p.join(_root.path, 'exports'));

  /// Present while a backup restore is in progress.
  File get restoreMarker => File(p.join(_root.path, 'restore_in_progress'));

  Future<void> ensureDirectories() async {
    for (final d in [screenshotsDir, thumbnailsDir, stagingDir]) {
      await d.create(recursive: true);
    }
  }

  String _newName(String extension) {
    final stamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final rand = _random.nextInt(1 << 32).toRadixString(36);
    return '$stamp$rand$extension';
  }

  String newScreenshotPath(String extension) =>
      p.join(screenshotsDir.path, _newName(extension));

  String newThumbnailPath() => p.join(thumbnailsDir.path, _newName('.jpg'));

  String newStagingPath(String extension) =>
      p.join(stagingDir.path, _newName(extension));

  /// Copies [source] into private storage, preserving the original bytes.
  Future<File> storeOriginal(File source, String extension) =>
      source.copy(newScreenshotPath(extension));

  Future<void> writeThumbnail(String path, List<int> bytes) async {
    await File(path).writeAsBytes(bytes, flush: true);
  }

  bool isAppOwned(String path) {
    final normalized = p.normalize(path);
    return p.isWithin(_root.path, normalized);
  }

  /// Deletes files only if they live inside the app's private directories.
  Future<void> deleteFiles(Iterable<String?> paths) async {
    for (final path in paths) {
      if (path == null || !isAppOwned(path)) continue;
      try {
        final file = File(path);
        if (file.existsSync()) await file.delete();
      } on FileSystemException {
        // Already gone or locked; orphan cleanup handles leftovers.
      }
    }
  }

  Future<StorageUsage> usage() async {
    Future<(int, int)> sizeOf(Directory d) async {
      if (!d.existsSync()) return (0, 0);
      var bytes = 0;
      var count = 0;
      await for (final e in d.list(recursive: true, followLinks: false)) {
        if (e is File) {
          bytes += await e.length();
          count++;
        }
      }
      return (bytes, count);
    }

    final (imgBytes, imgCount) = await sizeOf(screenshotsDir);
    final (thumbBytes, _) = await sizeOf(thumbnailsDir);
    // The database runs in WAL mode, so recent writes live in the -wal file.
    var dbBytes = 0;
    for (final suffix in ['', '-wal']) {
      final f = File(p.join(_root.path, 'snapaction.sqlite$suffix'));
      if (f.existsSync()) dbBytes += await f.length();
    }
    return StorageUsage(
      imageBytes: imgBytes,
      imageCount: imgCount,
      thumbnailBytes: thumbBytes,
      databaseBytes: dbBytes,
    );
  }

  /// Removes files that no database row references any more.
  Future<int> removeOrphans(Set<String> referenced) async {
    var removed = 0;
    for (final dir in [screenshotsDir, thumbnailsDir]) {
      if (!dir.existsSync()) continue;
      await for (final e in dir.list(followLinks: false)) {
        if (e is File && !referenced.contains(p.normalize(e.path))) {
          await e.delete();
          removed++;
        }
      }
    }
    return removed;
  }

  Future<void> clearStaging() async {
    if (stagingDir.existsSync()) {
      await stagingDir.delete(recursive: true);
    }
    await stagingDir.create(recursive: true);
  }

  Future<void> deleteAll() async {
    for (final d in [screenshotsDir, thumbnailsDir, stagingDir, exportsDir]) {
      if (d.existsSync()) await d.delete(recursive: true);
    }
    await ensureDirectories();
  }
}

class StorageUsage {
  const StorageUsage({
    required this.imageBytes,
    required this.imageCount,
    required this.thumbnailBytes,
    required this.databaseBytes,
  });

  final int imageBytes;
  final int imageCount;
  final int thumbnailBytes;
  final int databaseBytes;

  int get totalBytes => imageBytes + thumbnailBytes + databaseBytes;
}
