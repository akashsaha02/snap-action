import '../database/enums.dart';

class CategoryInfo {
  const CategoryInfo({
    required this.id,
    required this.slug,
    required this.name,
    required this.icon,
    required this.color,
    required this.isSystem,
  });

  final int id;
  final String slug;
  final String name;
  final String icon;
  final int color;
  final bool isSystem;
}

/// Lightweight projection of a screenshot for lists and grids.
class ScreenshotSummary {
  const ScreenshotSummary({
    required this.id,
    required this.localFilePath,
    required this.importedAt,
    required this.status,
    this.title,
    this.thumbnailPath,
    this.category,
    this.suggestedCategory,
    this.textPreview,
    this.isFavorite = false,
    this.isReviewed = false,
    this.isArchived = false,
    this.isSensitive = false,
    this.needsCategoryConfirmation = false,
    this.actionTypes = const [],
  });

  final int id;
  final String? title;
  final String localFilePath;
  final String? thumbnailPath;
  final DateTime importedAt;
  final ProcessingStatus status;
  final CategoryInfo? category;
  final CategoryInfo? suggestedCategory;
  final String? textPreview;
  final bool isFavorite;
  final bool isReviewed;
  final bool isArchived;
  final bool isSensitive;
  final bool needsCategoryConfirmation;
  final List<ActionType> actionTypes;

  String get displayTitle {
    final t = title?.trim();
    if (t != null && t.isNotEmpty) return t;
    return 'Screenshot';
  }

  CategoryInfo? get effectiveCategory => category ?? suggestedCategory;
}
