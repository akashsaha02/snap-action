import 'package:image/image.dart' as img;

/// Difference hash (dHash): compares horizontally adjacent pixels of a 9x8
/// grayscale thumbnail, giving 64 bits that change little under resizing or
/// recompression.
abstract final class PerceptualHash {
  static const bits = 64;

  /// Default maximum Hamming distance for "visually similar".
  static const similarThreshold = 6;

  static String dHash(img.Image image) {
    final small = img.copyResize(
      img.grayscale(image.clone()),
      width: 9,
      height: 8,
      interpolation: img.Interpolation.average,
    );
    var hash = BigInt.zero;
    for (var y = 0; y < 8; y++) {
      for (var x = 0; x < 8; x++) {
        final left = small.getPixel(x, y).luminance;
        final right = small.getPixel(x + 1, y).luminance;
        hash = (hash << 1) | (left > right ? BigInt.one : BigInt.zero);
      }
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }

  static int hammingDistance(String a, String b) {
    final (a1, a2) = _halves(a);
    final (b1, b2) = _halves(b);
    return _popcount(a1 ^ b1) + _popcount(a2 ^ b2);
  }

  static bool isSimilar(
    String a,
    String b, {
    int threshold = similarThreshold,
  }) => hammingDistance(a, b) <= threshold;

  /// Groups ids whose hashes are within [threshold] of each other
  /// (transitively). Only groups with two or more members are returned.
  ///
  /// [texts] (id -> recognized text) adds a second check: two screenshots
  /// that both have enough text must also read nearly the same. Two receipts
  /// from the same app share a layout but are different payments.
  static List<List<int>> group(
    List<(int, String)> hashes, {
    int threshold = similarThreshold,
    Map<int, String>? texts,
  }) {
    final n = hashes.length;
    final hi = List<int>.filled(n, 0);
    final lo = List<int>.filled(n, 0);
    for (var i = 0; i < n; i++) {
      final (h, l) = _halves(hashes[i].$2);
      hi[i] = h;
      lo[i] = l;
    }
    final parent = List<int>.generate(n, (i) => i);
    int find(int i) {
      while (parent[i] != i) {
        parent[i] = parent[parent[i]];
        i = parent[i];
      }
      return i;
    }

    for (var i = 0; i < n; i++) {
      for (var j = i + 1; j < n; j++) {
        if (_popcount(hi[i] ^ hi[j]) + _popcount(lo[i] ^ lo[j]) <= threshold &&
            _sameText(texts, hashes[i].$1, hashes[j].$1)) {
          final ri = find(i);
          final rj = find(j);
          if (ri != rj) parent[rj] = ri;
        }
      }
    }
    final groups = <int, List<int>>{};
    for (var i = 0; i < n; i++) {
      (groups[find(i)] ??= []).add(hashes[i].$1);
    }
    return [
      for (final g in groups.values)
        if (g.length > 1) g,
    ];
  }

  static bool _sameText(Map<int, String>? texts, int a, int b) {
    final ta = texts?[a]?.trim() ?? '';
    final tb = texts?[b]?.trim() ?? '';
    // Too little text to judge: the image alone decides.
    if (ta.length < textCheckMinLength || tb.length < textCheckMinLength) {
      return true;
    }
    return TextSimilarity.ratio(ta, tb) >= textSimilarThreshold;
  }

  /// Below this many characters the text check is skipped.
  static const textCheckMinLength = 20;

  /// Measured on real OCR: re-taken screenshots score about 0.99, different
  /// receipts from one app about 0.85.
  static const textSimilarThreshold = 0.93;

  static (int, int) _halves(String hash) {
    if (hash.length != 16) {
      throw ArgumentError('Perceptual hashes must be 16 hex characters');
    }
    return (
      int.parse(hash.substring(0, 8), radix: 16),
      int.parse(hash.substring(8), radix: 16),
    );
  }

  static int _popcount(int v) {
    var x = v;
    var count = 0;
    while (x != 0) {
      x &= x - 1;
      count++;
    }
    return count;
  }
}

/// Edit-distance similarity of two texts, from 0 (unrelated) to 1 (equal).
abstract final class TextSimilarity {
  /// Longer texts are compared on their first [maxLength] characters.
  static const maxLength = 1500;

  static double ratio(String a, String b) {
    final x = _clean(a);
    final y = _clean(b);
    if (x.isEmpty && y.isEmpty) return 1;
    final longest = x.length > y.length ? x.length : y.length;
    return 1 - _distance(x, y) / longest;
  }

  static String _clean(String s) {
    final t = s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    return t.length > maxLength ? t.substring(0, maxLength) : t;
  }

  static int _distance(String a, String b) {
    var prev = List<int>.generate(b.length + 1, (i) => i);
    var cur = List<int>.filled(b.length + 1, 0);
    for (var i = 1; i <= a.length; i++) {
      cur[0] = i;
      final ca = a.codeUnitAt(i - 1);
      for (var j = 1; j <= b.length; j++) {
        final cost = ca == b.codeUnitAt(j - 1) ? 0 : 1;
        final del = prev[j] + 1;
        final ins = cur[j - 1] + 1;
        final sub = prev[j - 1] + cost;
        cur[j] = del < ins ? (del < sub ? del : sub) : (ins < sub ? ins : sub);
      }
      final t = prev;
      prev = cur;
      cur = t;
    }
    return prev[b.length];
  }
}
