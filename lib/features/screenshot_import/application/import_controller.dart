import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../services/platform/platform_service.dart';
import 'import_service.dart';

class ImportState {
  const ImportState({
    this.running = false,
    this.done = 0,
    this.total = 0,
    this.result,
    this.source,
  });

  final bool running;
  final int done;
  final int total;

  /// Result of the most recent finished import, until acknowledged.
  final ImportResult? result;
  final ScreenshotSource? source;

  double? get progress => total == 0 ? null : done / total;
}

/// Picks or receives images and feeds them through [ImportService].
class ImportController extends Notifier<ImportState> {
  static const maxBatch = 100;

  @override
  ImportState build() => const ImportState();

  /// Opens the system Photo Picker. No storage permission is requested.
  Future<ImportResult?> pickFromGallery() async {
    if (state.running) return null;
    final platform = ImagePickerPlatform.instance;
    if (platform is ImagePickerAndroid) {
      platform.useAndroidPhotoPicker = true;
    }
    final List<XFile> files;
    try {
      files = await ImagePicker().pickMultiImage(
        limit: maxBatch,
        requestFullMetadata: false,
      );
    } on PlatformException catch (e) {
      final result = ImportResult(
        failures: [
          ImportFailure(
            name: 'Photo picker',
            reason: e.message ?? 'The photo picker could not be opened.',
          ),
        ],
      );
      state = ImportState(result: result, source: ScreenshotSource.picker);
      return result;
    }
    if (files.isEmpty) return null;
    return _import([
      for (final f in files)
        ImportCandidate(path: f.path, originalName: f.name),
    ], ScreenshotSource.picker);
  }

  /// Imports images shared from another app.
  Future<ImportResult?> importShared(List<SharedFile> shared) async {
    if (shared.isEmpty) return null;
    final failures = <ImportFailure>[
      for (final s in shared)
        if (s.path == null || s.error != null)
          ImportFailure(
            name: s.name ?? 'Shared item',
            reason: _shareError(s.error),
          ),
    ];
    final candidates = [
      for (final s in shared)
        if (s.path != null && s.error == null)
          ImportCandidate(path: s.path!, originalName: s.name),
    ];
    if (candidates.isEmpty) {
      final result = ImportResult(failures: failures);
      state = ImportState(result: result, source: ScreenshotSource.share);
      return result;
    }
    final result = await _import(candidates, ScreenshotSource.share);
    if (result == null) return null;
    final merged = result.merge(ImportResult(failures: failures));
    state = ImportState(result: merged, source: ScreenshotSource.share);
    return merged;
  }

  Future<ImportResult?> _import(
    List<ImportCandidate> files,
    ScreenshotSource source,
  ) async {
    if (state.running) return null;
    state = ImportState(running: true, total: files.length, source: source);
    final cache = await _cacheDir();
    final service = ref.read(importServiceProvider);
    ImportResult result;
    try {
      result = await service.importFiles(
        files,
        source: source,
        onProgress: (done, total) {
          if (ref.mounted) {
            state = ImportState(
              running: true,
              done: done,
              total: total,
              source: source,
            );
          }
        },
      );
    } finally {
      await _deleteTemporaryCopies(files, cache);
    }
    if (result.importedIds.isNotEmpty) {
      ref.read(jobRunnerProvider).kick();
    }
    if (ref.mounted) state = ImportState(result: result, source: source);
    return result;
  }

  void acknowledge() => state = const ImportState();

  /// Picker and share imports arrive as temporary copies in the app cache;
  /// only those copies are removed, never a file outside the cache.
  Future<void> _deleteTemporaryCopies(
    List<ImportCandidate> files,
    String? cache,
  ) async {
    if (cache == null) return;
    for (final f in files) {
      if (!p.isWithin(cache, p.normalize(f.path))) continue;
      try {
        final file = File(f.path);
        if (file.existsSync()) await file.delete();
      } on FileSystemException {
        // The OS clears the cache eventually.
      }
    }
  }

  static Future<String?> _cacheDir() async {
    try {
      return (await getTemporaryDirectory()).path;
    } on Object {
      return null;
    }
  }

  static String _shareError(String? code) => switch (code) {
    'unsupported' => 'This file type is not supported. Share an image.',
    'too_large' => 'The image is larger than 40 MB.',
    'no_space' => 'Not enough storage space on this device.',
    _ => 'The shared file could not be opened.',
  };
}

final importControllerProvider =
    NotifierProvider<ImportController, ImportState>(ImportController.new);
