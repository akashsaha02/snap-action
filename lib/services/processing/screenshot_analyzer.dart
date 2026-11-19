import '../action_generation/action_generator.dart';
import '../action_generation/title_generator.dart';
import '../classification/classifier.dart';
import '../entity_extraction/entity_extractor.dart';
import '../entity_extraction/entity_models.dart';
import '../entity_extraction/text_normalizer.dart';

class AnalysisResult {
  const AnalysisResult({
    required this.extraction,
    required this.classification,
    required this.title,
    required this.actions,
  });

  final ExtractionResult extraction;
  final ClassificationResult classification;
  final String? title;
  final List<GeneratedAction> actions;
}

/// Pure text -> structured result pipeline. Runs on any isolate.
class ScreenshotAnalyzer {
  const ScreenshotAnalyzer({
    this.classifier = const RuleBasedClassifier(),
    this.titles = const TitleGenerator(),
    this.actions = const ActionGenerator(),
  });

  final ScreenshotClassifier classifier;
  final TitleGenerator titles;
  final ActionGenerator actions;

  AnalysisResult analyze(
    String rawText, {
    DateOrder dateOrder = DateOrder.dmy,
    List<UserRule> userRules = const [],
    String? existingTitle,
    String? lockedCategorySlug,
    DateTime? now,
    Map<String, double>? lineHeights,
  }) {
    final text = TextNormalizer.withoutStatusBar(
      TextNormalizer.normalize(rawText),
    );
    final extraction = EntityExtractor(dateOrder: dateOrder).extract(text);
    final classification = classifier.classify(
      ClassificationInput(
        text: text,
        extraction: extraction,
        userRules: userRules,
      ),
    );
    final slug = lockedCategorySlug ?? classification.categorySlug;
    final title =
        existingTitle ??
        titles.generate(
          text: text,
          extraction: extraction,
          categorySlug: slug,
          lineHeights: lineHeights,
        );
    return AnalysisResult(
      extraction: extraction,
      classification: classification,
      title: title,
      actions: actions.generate(
        extraction: extraction,
        categorySlug: slug,
        title: title,
        text: text,
        now: now,
      ),
    );
  }
}
