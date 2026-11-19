import '../database/app_database.dart';
import 'screenshot_summary.dart';

class ScreenshotDetail {
  const ScreenshotDetail({
    required this.screenshot,
    required this.entities,
    required this.actions,
    required this.tags,
    required this.collections,
    required this.reminders,
    required this.wishlistItems,
    this.category,
    this.suggestedCategory,
    this.ocr,
    this.note,
  });

  final ScreenshotRow screenshot;
  final CategoryInfo? category;
  final CategoryInfo? suggestedCategory;
  final OcrResultRow? ocr;
  final List<ExtractedEntityRow> entities;
  final List<SuggestedActionRow> actions;
  final List<TagRow> tags;
  final List<CollectionRow> collections;
  final NoteRow? note;
  final List<ReminderRow> reminders;
  final List<WishlistItemRow> wishlistItems;

  String get text => ocr?.correctedText ?? ocr?.rawText ?? '';

  bool get hasText => text.trim().isNotEmpty;

  String get displayTitle {
    final t = screenshot.title?.trim();
    return t == null || t.isEmpty ? 'Screenshot' : t;
  }

  CategoryInfo? get effectiveCategory => category ?? suggestedCategory;

  List<SuggestedActionRow> get pendingActions => [
    for (final a in actions)
      if (a.status == ActionStatus.suggested) a,
  ];
}
