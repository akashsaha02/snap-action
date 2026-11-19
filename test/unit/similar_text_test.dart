import 'package:flutter_test/flutter_test.dart';
import 'package:snapaction/services/duplicate_detection/perceptual_hash.dart';

// Texts as ML Kit read them from the test screenshots.
const _receiptA =
    'Payment successful\nAmount paid: €23.50\nMerchant: Corner Bakery\n'
    'Transaction ID: TXN123456\n12 November 2026\nPaid with Visa eoeo 4821\n'
    'Done';
const _receiptB =
    'Payment successful\nAmount paid: €64.18\nMerchant: Fresh Market\n'
    'Transaction ID: TXN998812\n16 November 2026\nPaid with Visa eoeo 4821\n'
    'Done';
const _productA =
    'Wireless Headphones Pro\n4.6 ★ 1,203 ratings\n€49.99\n'
    'Free shipping · In stock\nAdd to cart\nBuy now';
const _productB =
    'Wireless Headphones Pro\n4.6 ★ 1,204 ratings\n€49.99\n'
    'Free shipping · In stock\nAdd to cart\nBuy now';

void main() {
  test('re-taken screenshots read almost the same', () {
    expect(
      TextSimilarity.ratio(_productA, _productB),
      greaterThan(PerceptualHash.textSimilarThreshold),
    );
  });

  test('two payments from the same app do not', () {
    expect(
      TextSimilarity.ratio(_receiptA, _receiptB),
      lessThan(PerceptualHash.textSimilarThreshold),
    );
  });

  test('grouping needs both a similar image and similar text', () {
    // All four images hash alike, as same-app screenshots do.
    const hash = '0f0f0f0f0f0f0f0f';
    final groups = PerceptualHash.group(
      [(1, hash), (2, hash), (3, hash), (4, hash)],
      texts: {1: _receiptA, 2: _receiptB, 3: _productA, 4: _productB},
    );
    final sets = groups.map((g) => g.toSet()).toList();
    expect(sets, hasLength(1));
    expect(sets.single, {3, 4});
  });

  test('without enough text the image alone decides', () {
    const hash = '0f0f0f0f0f0f0f0f';
    final groups = PerceptualHash.group(
      [(1, hash), (2, hash)],
      texts: {1: '', 2: 'short'},
    );
    expect(groups.single.toSet(), {1, 2});
  });
}
