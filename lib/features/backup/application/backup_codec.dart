import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../../../core/database/app_database.dart';

/// Pure, isolate-safe reading and writing of Mindtiq backup archives.
///
/// Layout:
///  - `manifest.json`: format name, schema version, creation time, counts.
///  - `data.json`: every user table as typed Drift JSON.
///  - `images/<id>.<ext>` and `thumbs/<id>.jpg`: app-private image copies.
abstract final class BackupCodec {
  // Internal identifier, unchanged by the app's rename so older backups
  // keep restoring.
  static const format = 'snapaction-backup';
  static const schemaVersion = 3;
  static const manifestName = 'manifest.json';
  static const dataName = 'data.json';

  static final _imageEntry = RegExp(
    r'^(images|thumbs)/[A-Za-z0-9_-]{1,64}\.(png|jpe?g|webp|gif|bmp|heic|heif|bin)$',
  );
  static const _imageExtensions = {
    '.png',
    '.jpg',
    '.jpeg',
    '.webp',
    '.gif',
    '.bmp',
    '.heic',
    '.heif',
  };

  /// Entry name for an image stored at [path] for screenshot [id].
  static String imageEntry(int id, String path) {
    final ext = p.extension(path).toLowerCase();
    return 'images/$id${_imageExtensions.contains(ext) ? ext : '.bin'}';
  }

  static String thumbnailEntry(int id) => 'thumbs/$id.jpg';

  /// Rejects absolute paths, parent references, drive letters, backslashes
  /// and anything outside the expected layout.
  static void checkEntryName(String name, {required bool isFile}) {
    final unsafe =
        name.isEmpty ||
        name.startsWith('/') ||
        name.contains(r'\') ||
        name.contains(':') ||
        name.contains('\u0000') ||
        name.split('/').any((s) => s == '..' || s == '.');
    if (unsafe) {
      throw BackupException(
        'The backup contains an unsafe file path ("$name") and was not opened.',
      );
    }
    if (!isFile) {
      if (name == 'images/' || name == 'thumbs/') return;
      throw BackupException(
        'The backup contains an unexpected folder ("$name").',
      );
    }
    if (name == manifestName ||
        name == dataName ||
        _imageEntry.hasMatch(name)) {
      return;
    }
    throw BackupException('The backup contains an unexpected file ("$name").');
  }

  // Writing ---------------------------------------------------------------

  /// Writes the archive. Images are stored uncompressed because PNG and JPEG
  /// are already compressed.
  static Future<void> writeZip(BackupWriteRequest r) async {
    final encoder = ZipFileEncoder()..create(r.zipPath);
    try {
      encoder
        ..addArchiveFile(ArchiveFile.string(manifestName, r.manifestJson))
        ..addArchiveFile(ArchiveFile.string(dataName, r.dataJson));
      for (final (source, entry) in r.files) {
        final file = File(source);
        if (!file.existsSync()) continue;
        await encoder.addFile(file, entry, 0);
      }
    } finally {
      await encoder.close();
    }
  }

  // Reading ---------------------------------------------------------------

  /// Validates structure, manifest and records without extracting images.
  static BackupPreview inspect(
    String zipPath, {
    BackupLimits limits = const BackupLimits(),
  }) {
    final opened = _open(zipPath, limits);
    try {
      final data = _readData(opened.archive, limits);
      return BackupPreview(
        createdAt: data.createdAt,
        schemaVersion: data.schemaVersion,
        screenshots: data.screenshots.length,
        collections: data.collections.length,
        tags: data.tags.length,
        reminders: data.reminders.length,
        wishlistItems: data.wishlist.length,
        missingImages: data.screenshots
            .where((s) => !opened.names.contains(s.image))
            .length,
      );
    } finally {
      opened.input.closeSync();
    }
  }

  /// Validates the backup and extracts images into [stagingDir], verifying
  /// each against its recorded SHA-256 hash. Damaged images are reported in
  /// [StagedBackup.corrupted] and left out.
  static StagedBackup stage(
    String zipPath,
    String stagingDir, {
    BackupLimits limits = const BackupLimits(),
  }) {
    final opened = _open(zipPath, limits);
    final staged = <String, String>{};
    final corrupted = <int>{};
    final random = Random.secure();
    String target(String entry) => p.join(
      stagingDir,
      'restore_${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}'
      '${random.nextInt(1 << 32).toRadixString(36)}${p.extension(entry)}',
    );
    try {
      final data = _readData(opened.archive, limits);
      final byName = {for (final f in opened.archive.files) f.name: f};
      for (final s in data.screenshots) {
        final image = byName[s.image];
        if (image == null) {
          corrupted.add(s.row.id);
          continue;
        }
        final path = _extract(image, target(s.image), limits.maxImageBytes);
        if (path == null || _sha256(path) != s.row.contentHash) {
          if (path != null) File(path).deleteSync();
          corrupted.add(s.row.id);
          continue;
        }
        staged[s.image] = path;
        final thumb = s.thumbnail == null ? null : byName[s.thumbnail];
        if (thumb != null) {
          final tPath = _extract(
            thumb,
            target(s.thumbnail!),
            limits.maxImageBytes,
          );
          if (tPath != null) staged[s.thumbnail!] = tPath;
        }
      }
      return StagedBackup(
        data: data,
        stagedFiles: staged,
        corrupted: corrupted,
      );
    } on Object {
      for (final path in staged.values) {
        final f = File(path);
        if (f.existsSync()) f.deleteSync();
      }
      rethrow;
    } finally {
      opened.input.closeSync();
    }
  }

  static _Opened _open(String zipPath, BackupLimits limits) {
    final file = File(zipPath);
    if (!file.existsSync()) {
      throw const BackupException('The backup file could not be read.');
    }
    if (file.lengthSync() > limits.maxArchiveBytes) {
      throw const BackupException(
        'The backup is larger than Mindtiq can restore.',
      );
    }
    final input = InputFileStream(zipPath);
    final Archive archive;
    try {
      archive = ZipDecoder().decodeStream(input);
    } on Object {
      input.closeSync();
      throw const BackupException(
        'This file is not a valid ZIP archive or it is damaged.',
      );
    }
    try {
      if (archive.files.length > limits.maxEntries) {
        throw const BackupException('The backup contains too many files.');
      }
      var total = 0;
      final names = <String>{};
      for (final f in archive.files) {
        checkEntryName(f.name, isFile: f.isFile);
        if (!f.isFile) continue;
        if (!names.add(f.name)) {
          throw BackupException(
            'The backup contains "${f.name}" more than once.',
          );
        }
        final max = f.name.endsWith('.json')
            ? limits.maxJsonBytes
            : limits.maxImageBytes;
        if (f.size < 0 || f.size > max) {
          throw BackupException('"${f.name}" is larger than allowed.');
        }
        total += f.size;
        if (total > limits.maxTotalBytes) {
          throw const BackupException(
            'The backup expands to more data than Mindtiq can restore.',
          );
        }
      }
      if (!names.contains(manifestName) || !names.contains(dataName)) {
        throw const BackupException('This file is not a Mindtiq backup.');
      }
      return _Opened(input, archive, names);
    } on Object {
      input.closeSync();
      rethrow;
    }
  }

  static Map<String, Object?> _json(
    Archive archive,
    String name,
    BackupLimits limits,
  ) {
    final f = archive.files.firstWhere((f) => f.name == name);
    final bytes = f.readBytes();
    if (bytes == null || bytes.length > limits.maxJsonBytes) {
      throw BackupException('$name could not be read.');
    }
    try {
      final value = jsonDecode(utf8.decode(bytes));
      if (value is Map<String, Object?>) return value;
    } on FormatException {
      // Reported below.
    }
    throw BackupException('$name is damaged.');
  }

  static BackupData _readData(Archive archive, BackupLimits limits) {
    final manifest = _json(archive, manifestName, limits);
    if (manifest['format'] != format) {
      throw const BackupException('This file is not a Mindtiq backup.');
    }
    final version = manifest['schemaVersion'];
    if (version is! int || version < 1) {
      throw const BackupException('The backup has an unknown version.');
    }
    if (version > schemaVersion) {
      throw const BackupException(
        'This backup was made by a newer version of Mindtiq. Please update the app first.',
      );
    }
    final created = manifest['createdAt'];
    final data = _json(archive, dataName, limits);
    return BackupData.fromJson(
      data,
      schemaVersion: version,
      createdAt: created is int
          ? DateTime.fromMillisecondsSinceEpoch(created)
          : null,
    );
  }

  static String? _extract(ArchiveFile f, String target, int maxBytes) {
    final out = OutputFileStream(target);
    try {
      f.writeContent(out);
    } on Object {
      out.closeSync();
      final file = File(target);
      if (file.existsSync()) file.deleteSync();
      return null;
    }
    out.closeSync();
    final file = File(target);
    if (file.lengthSync() > maxBytes) {
      file.deleteSync();
      return null;
    }
    return target;
  }

  static String _sha256(String path) =>
      sha256.convert(File(path).readAsBytesSync()).toString();
}

class _Opened {
  _Opened(this.input, this.archive, this.names);

  final InputFileStream input;
  final Archive archive;
  final Set<String> names;
}

class BackupException implements Exception {
  const BackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BackupLimits {
  const BackupLimits({
    this.maxArchiveBytes = 2 * 1024 * 1024 * 1024,
    this.maxTotalBytes = 4 * 1024 * 1024 * 1024,
    this.maxEntries = 30000,
    this.maxImageBytes = 40 * 1024 * 1024,
    this.maxJsonBytes = 128 * 1024 * 1024,
  });

  final int maxArchiveBytes;
  final int maxTotalBytes;
  final int maxEntries;
  final int maxImageBytes;
  final int maxJsonBytes;
}

class BackupWriteRequest {
  const BackupWriteRequest({
    required this.zipPath,
    required this.manifestJson,
    required this.dataJson,
    required this.files,
  });

  final String zipPath;
  final String manifestJson;
  final String dataJson;

  /// (source path, archive entry name)
  final List<(String, String)> files;
}

class BackupPreview {
  const BackupPreview({
    required this.createdAt,
    required this.schemaVersion,
    required this.screenshots,
    required this.collections,
    required this.tags,
    required this.reminders,
    required this.wishlistItems,
    required this.missingImages,
  });

  final DateTime? createdAt;
  final int schemaVersion;
  final int screenshots;
  final int collections;
  final int tags;
  final int reminders;
  final int wishlistItems;
  final int missingImages;
}

class StagedBackup {
  const StagedBackup({
    required this.data,
    required this.stagedFiles,
    required this.corrupted,
  });

  final BackupData data;

  /// Archive entry name -> extracted file in the staging directory.
  final Map<String, String> stagedFiles;

  /// Backup ids of screenshots whose image was missing or damaged.
  final Set<int> corrupted;
}

class BackupScreenshot {
  const BackupScreenshot({
    required this.row,
    required this.image,
    this.thumbnail,
  });

  final ScreenshotRow row;
  final String image;
  final String? thumbnail;
}

/// Typed contents of `data.json`. Every record is parsed with the generated
/// Drift `fromJson`, so wrong types are rejected rather than coerced.
class BackupData {
  BackupData({
    required this.schemaVersion,
    required this.createdAt,
    required this.categories,
    required this.screenshots,
    required this.ocr,
    required this.entities,
    required this.collections,
    required this.collectionItems,
    required this.tags,
    required this.screenshotTags,
    required this.notes,
    required this.reminders,
    required this.actions,
    required this.wishlist,
    required this.rules,
  });

  factory BackupData.fromJson(
    Map<String, Object?> json, {
    required int schemaVersion,
    DateTime? createdAt,
  }) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) parse) {
      final raw = json[key] ?? const <Object?>[];
      if (raw is! List) {
        throw BackupException('The backup is damaged ("$key" is not a list).');
      }
      final out = <T>[];
      for (final item in raw) {
        if (item is! Map<String, Object?>) {
          throw BackupException(
            'The backup is damaged (a "$key" record is invalid).',
          );
        }
        try {
          out.add(parse(item));
        } on Object {
          throw BackupException(
            'The backup is damaged (a "$key" record is invalid).',
          );
        }
      }
      return out;
    }

    final screenshots = list('screenshots', (m) {
      final row = m['row'];
      final image = m['image'];
      final thumb = m['thumbnail'];
      if (row is! Map<String, Object?> ||
          image is! String ||
          (thumb != null && thumb is! String)) {
        throw const FormatException();
      }
      BackupCodec.checkEntryName(image, isFile: true);
      if (thumb is String) BackupCodec.checkEntryName(thumb, isFile: true);
      return BackupScreenshot(
        // Fill what older backups lack, as the database migration does:
        // version 1 predates titleLocked (titles count as generated) and
        // versions 1-2 hold only screenshots. Schema-3 fields that are
        // nullable read as null when absent.
        row: ScreenshotRow.fromJson({
          'titleLocked': false,
          'memoryType': MemoryType.screenshot.name,
          ...row,
        }),
        image: image,
        thumbnail: thumb as String?,
      );
    });

    final ids = <int>{};
    final hashes = <String>{};
    for (final s in screenshots) {
      if (!ids.add(s.row.id) || !hashes.add(s.row.contentHash)) {
        throw const BackupException(
          'The backup is damaged (duplicate screenshot records).',
        );
      }
    }

    return BackupData(
      schemaVersion: schemaVersion,
      createdAt: createdAt,
      categories: list('categories', CategoryRow.fromJson),
      screenshots: screenshots,
      ocr: list('ocrResults', OcrResultRow.fromJson),
      entities: list('entities', ExtractedEntityRow.fromJson),
      collections: list('collections', CollectionRow.fromJson),
      collectionItems: list('collectionItems', CollectionItemRow.fromJson),
      tags: list('tags', TagRow.fromJson),
      screenshotTags: list('screenshotTags', ScreenshotTagRow.fromJson),
      notes: list('notes', NoteRow.fromJson),
      reminders: list('reminders', ReminderRow.fromJson),
      actions: list('suggestedActions', SuggestedActionRow.fromJson),
      wishlist: list('wishlistItems', WishlistItemRow.fromJson),
      rules: list('classificationRules', ClassificationRuleRow.fromJson),
    );
  }

  final int schemaVersion;
  final DateTime? createdAt;
  final List<CategoryRow> categories;
  final List<BackupScreenshot> screenshots;
  final List<OcrResultRow> ocr;
  final List<ExtractedEntityRow> entities;
  final List<CollectionRow> collections;
  final List<CollectionItemRow> collectionItems;
  final List<TagRow> tags;
  final List<ScreenshotTagRow> screenshotTags;
  final List<NoteRow> notes;
  final List<ReminderRow> reminders;
  final List<SuggestedActionRow> actions;
  final List<WishlistItemRow> wishlist;
  final List<ClassificationRuleRow> rules;
}
