import 'dart:convert';
import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrOutput {
  const OcrOutput({
    required this.text,
    required this.blocksJson,
    required this.recognizerName,
    required this.recognizerVersion,
  });

  final String text;

  /// `[{"text","box":[l,t,r,b],"lines":[{"text","box","confidence"}]}]`
  final String blocksJson;
  final String recognizerName;
  final String recognizerVersion;
}

class OcrException implements Exception {
  const OcrException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// On-device text recognition. Implementations must not use the network.
abstract interface class OcrService {
  Future<OcrOutput> recognize(String imagePath);

  Future<void> dispose();
}

class MlKitOcrService implements OcrService {
  MlKitOcrService();

  static const name = 'mlkit-text-recognition-latin';

  /// Version of the bundled `com.google.mlkit:text-recognition` model.
  static const version = '16.0.1';

  TextRecognizer? _recognizer;

  @override
  Future<OcrOutput> recognize(String imagePath) async {
    final recognizer = _recognizer ??= TextRecognizer();
    final RecognizedText result;
    try {
      result = await recognizer.processImage(
        InputImage.fromFilePath(imagePath),
      );
    } on Exception catch (e, stack) {
      // Technical detail goes to the device log; people see a plain message.
      debugPrint('Text recognition failed: $e\n$stack');
      throw const OcrException(
        'The text in this image could not be read. Tap Retry to try again.',
      );
    }
    final blocks = [...result.blocks]..sort(_readingOrder);
    final text = blocks
        .map(
          (b) => b.lines
              .map((l) => l.text.trim())
              .where((t) => t.isNotEmpty)
              .join('\n'),
        )
        .where((t) => t.isNotEmpty)
        .join('\n\n');
    final json = jsonEncode([
      for (final b in blocks)
        {
          'text': b.text,
          'box': _box(b.boundingBox),
          'lines': [
            for (final l in b.lines)
              {
                'text': l.text,
                'box': _box(l.boundingBox),
                'confidence': ?l.confidence,
              },
          ],
        },
    ]);
    return OcrOutput(
      text: text,
      blocksJson: json,
      recognizerName: name,
      recognizerVersion: version,
    );
  }

  /// Top-to-bottom, then left-to-right for blocks that share a row.
  static int _readingOrder(TextBlock a, TextBlock b) {
    final ra = a.boundingBox;
    final rb = b.boundingBox;
    final overlap =
        (ra.bottom < rb.bottom ? ra.bottom : rb.bottom) -
        (ra.top > rb.top ? ra.top : rb.top);
    final minHeight = ra.height < rb.height ? ra.height : rb.height;
    if (minHeight > 0 && overlap > minHeight * 0.5) {
      return ra.left.compareTo(rb.left);
    }
    return ra.top.compareTo(rb.top);
  }

  static List<int> _box(Rect r) => [
    r.left.round(),
    r.top.round(),
    r.right.round(),
    r.bottom.round(),
  ];

  @override
  Future<void> dispose() async {
    await _recognizer?.close();
    _recognizer = null;
  }
}
