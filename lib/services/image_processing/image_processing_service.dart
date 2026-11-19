import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;

import '../duplicate_detection/perceptual_hash.dart';

class ImageAnalysis {
  const ImageAnalysis({
    required this.sha256,
    required this.perceptualHash,
    required this.width,
    required this.height,
    required this.fileSize,
    required this.extension,
    this.capturedAt,
  });

  final String sha256;
  final String perceptualHash;
  final int width;
  final int height;
  final int fileSize;
  final String extension;
  final DateTime? capturedAt;
}

sealed class ImageValidationException implements Exception {
  const ImageValidationException(this.message);
  final String message;

  @override
  String toString() => message;
}

class UnsupportedImageException extends ImageValidationException {
  const UnsupportedImageException()
    : super('This file is not a supported image (PNG, JPEG, WebP, GIF, BMP).');
}

class CorruptImageException extends ImageValidationException {
  const CorruptImageException() : super('The image could not be decoded.');
}

class ImageTooLargeException extends ImageValidationException {
  const ImageTooLargeException(this.bytes)
    : super('The image is larger than the 40 MB import limit.');
  final int bytes;
}

/// CPU-heavy work (hashing, decoding, thumbnailing) runs in a background
/// isolate so the UI stays responsive.
class ImageProcessingService {
  const ImageProcessingService();

  static const maxFileBytes = 40 * 1024 * 1024;
  static const maxPixels = 40000000;
  static const thumbnailWidth = 360;

  Future<ImageAnalysis> analyzeAndThumbnail({
    required String sourcePath,
    required String thumbnailPath,
  }) => Isolate.run(() => _analyze(sourcePath, thumbnailPath));

  static ImageAnalysis _analyze(String sourcePath, String thumbnailPath) {
    final file = File(sourcePath);
    final length = file.lengthSync();
    if (length > maxFileBytes) throw ImageTooLargeException(length);
    if (length == 0) throw const CorruptImageException();

    final bytes = file.readAsBytesSync();
    final ext = detectExtension(bytes);
    if (ext == null) throw const UnsupportedImageException();

    final decoder = img.findDecoderForData(bytes);
    if (decoder == null) throw const UnsupportedImageException();
    final info = decoder.startDecode(bytes);
    if (info == null) throw const CorruptImageException();
    if (info.width * info.height > maxPixels) {
      throw ImageTooLargeException(length);
    }

    final image = decoder.decode(bytes, frame: 0);
    if (image == null || image.width == 0) throw const CorruptImageException();

    final digest = sha256.convert(bytes).toString();
    final phash = PerceptualHash.dHash(image);

    final thumb = image.width > thumbnailWidth
        ? img.copyResize(
            image,
            width: thumbnailWidth,
            interpolation: img.Interpolation.average,
          )
        : image;
    var flattened = thumb;
    if (thumb.hasAlpha) {
      // JPEG has no alpha channel; composite onto white.
      flattened = img.Image(width: thumb.width, height: thumb.height)
        ..clear(img.ColorRgb8(255, 255, 255));
      img.compositeImage(flattened, thumb);
    }
    File(thumbnailPath).writeAsBytesSync(img.encodeJpg(flattened, quality: 82));

    return ImageAnalysis(
      sha256: digest,
      perceptualHash: phash,
      width: image.width,
      height: image.height,
      fileSize: length,
      extension: ext,
      capturedAt: _exifDate(image),
    );
  }

  static DateTime? _exifDate(img.Image image) {
    final raw = image.exif.exifIfd['DateTimeOriginal']?.toString();
    if (raw == null || raw.length < 19) return null;
    // EXIF format: "YYYY:MM:DD HH:MM:SS"
    final normalized =
        '${raw.substring(0, 4)}-${raw.substring(5, 7)}-${raw.substring(8, 10)}'
        'T${raw.substring(11, 19)}';
    return DateTime.tryParse(normalized);
  }

  /// Identifies the format from magic bytes rather than the file name.
  static String? detectExtension(List<int> b) {
    bool starts(List<int> sig, [int offset = 0]) {
      if (b.length < sig.length + offset) return false;
      for (var i = 0; i < sig.length; i++) {
        if (b[i + offset] != sig[i]) return false;
      }
      return true;
    }

    if (starts([0x89, 0x50, 0x4E, 0x47])) return '.png';
    if (starts([0xFF, 0xD8, 0xFF])) return '.jpg';
    if (starts([0x52, 0x49, 0x46, 0x46]) &&
        starts([0x57, 0x45, 0x42, 0x50], 8)) {
      return '.webp';
    }
    if (starts([0x47, 0x49, 0x46, 0x38])) return '.gif';
    if (starts([0x42, 0x4D])) return '.bmp';
    return null;
  }
}
