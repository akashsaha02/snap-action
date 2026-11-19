import 'package:flutter_test/flutter_test.dart';
import 'package:snapaction/core/constants/system_categories.dart';
import 'package:snapaction/services/classification/classifier.dart';
import 'package:snapaction/services/processing/screenshot_analyzer.dart';

import '../fixtures/ocr_samples.dart';

void main() {
  const analyzer = ScreenshotAnalyzer();
  String classify(String text, {List<UserRule> rules = const []}) =>
      analyzer.analyze(text, userRules: rules).classification.categorySlug;

  test('fixtures land in the expected category', () {
    expect(classify(shoppingProduct), CategorySlugs.shopping);
    expect(classify(receipt), CategorySlugs.finance);
    expect(classify(boardingPass), CategorySlugs.travel);
    expect(classify(assignment), CategorySlugs.education);
    expect(classify(jobPost), CategorySlugs.jobs);
    expect(classify(conferencePoster), CategorySlugs.events);
    expect(classify(recipe), CategorySlugs.food);
    expect(classify(codeSnippet), CategorySlugs.technology);
    expect(classify(chat), CategorySlugs.messages);
  });

  test('weak or no evidence falls back to Other', () {
    final r = analyzer.analyze('hello there').classification;
    expect(r.categorySlug, CategorySlugs.other);
    expect(r.score, 0);
    expect(r.needsConfirmation, isFalse);
    expect(classify(''), CategorySlugs.other);
  });

  test('score is the winner share of all evidence', () {
    final r = analyzer.analyze(boardingPass).classification;
    expect(r.score, greaterThan(0.5));
    expect(r.score, lessThanOrEqualTo(1));
    expect(r.evidence[CategorySlugs.travel], isNotEmpty);
  });

  test('close scores ask the user to confirm', () {
    final r = analyzer.analyze('Add to cart\nInvoice').classification;
    expect(r.needsConfirmation, isTrue);
  });

  test('user keyword rules boost their category', () {
    const text = 'Project Phoenix kickoff notes';
    expect(classify(text), CategorySlugs.other);
    expect(
      classify(
        text,
        rules: const [
          UserRule(keyword: 'phoenix', categorySlug: CategorySlugs.documents),
        ],
      ),
      CategorySlugs.documents,
    );
  });

  test('titles come from extracted values', () {
    expect(analyzer.analyze(boardingPass).title, 'Flight LH1234');
    expect(analyzer.analyze(shoppingProduct).title, 'Wireless Headphones Pro');
    expect(
      analyzer.analyze(conferencePoster).title,
      'Flutter Forward Conference',
    );
    expect(analyzer.analyze(receipt).title, 'Payment EUR 23.50');
    expect(analyzer.analyze('').title, isNull);
  });

  test('an existing title is never replaced', () {
    expect(
      analyzer.analyze(boardingPass, existingTitle: 'My trip').title,
      'My trip',
    );
  });
}
