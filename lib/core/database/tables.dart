import 'package:drift/drift.dart';

import 'enums.dart';

@DataClassName('CategoryRow')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Stable identifier for system categories (for example `shopping`).
  TextColumn get slug => text().unique()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  TextColumn get icon => text()();
  IntColumn get color => integer()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('ScreenshotRow')
@TableIndex(name: 'idx_screenshots_status', columns: {#processingStatus})
@TableIndex(name: 'idx_screenshots_category', columns: {#primaryCategoryId})
@TableIndex(name: 'idx_screenshots_imported', columns: {#importedAt})
@TableIndex(name: 'idx_screenshots_phash', columns: {#perceptualHash})
class Screenshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get originalFilename => text().nullable()();
  TextColumn get localFilePath => text()();
  TextColumn get thumbnailPath => text().nullable()();
  TextColumn get contentHash => text().unique()();

  /// 64-bit dHash encoded as 16 hex characters.
  TextColumn get perceptualHash => text().nullable()();
  TextColumn get title => text().nullable()();

  /// True once the user named the screenshot. Otherwise the title is
  /// generated and re-analysis may improve it.
  BoolColumn get titleLocked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get importedAt => dateTime()();
  DateTimeColumn get capturedAt => dateTime().nullable()();
  TextColumn get source => textEnum<ScreenshotSource>()();
  @ReferenceName('primaryScreenshots')
  IntColumn get primaryCategoryId => integer().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.setNull,
  )();
  @ReferenceName('suggestedScreenshots')
  IntColumn get suggestedCategoryId => integer().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// Normalized rule-match score, not a calibrated probability.
  RealColumn get classificationScore => real().nullable()();

  /// True once the user picked the category; reclassification must not
  /// overwrite it.
  BoolColumn get categoryLocked =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get needsCategoryConfirmation =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isSensitive => boolean().withDefault(const Constant(false))();
  TextColumn get processingStatus => textEnum<ProcessingStatus>()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isReviewed => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get fileSize => integer()();
  IntColumn get imageWidth => integer().nullable()();
  IntColumn get imageHeight => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('OcrResultRow')
class OcrResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get screenshotId => integer().unique().references(
    Screenshots,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get rawText => text()();
  TextColumn get correctedText => text().nullable()();
  TextColumn get textBlocksJson => text()();
  TextColumn get recognizerName => text()();
  TextColumn get recognizerVersion => text()();
  DateTimeColumn get processedAt => dateTime()();
}

@DataClassName('ExtractedEntityRow')
@TableIndex(name: 'idx_entities_screenshot', columns: {#screenshotId})
@TableIndex(name: 'idx_entities_type', columns: {#entityType})
class ExtractedEntities extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get screenshotId =>
      integer().references(Screenshots, #id, onDelete: KeyAction.cascade)();
  TextColumn get entityType => textEnum<EntityType>()();
  TextColumn get rawValue => text()();
  TextColumn get normalizedValue => text().nullable()();
  TextColumn get metadataJson => text().nullable()();
  TextColumn get validationStatus => textEnum<ValidationStatus>()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('CollectionRow')
class Collections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60).unique()();
  TextColumn get description => text().nullable()();
  TextColumn get icon => text()();
  IntColumn get color => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('CollectionItemRow')
@TableIndex(name: 'idx_collection_items_screenshot', columns: {#screenshotId})
class CollectionItems extends Table {
  IntColumn get collectionId =>
      integer().references(Collections, #id, onDelete: KeyAction.cascade)();
  IntColumn get screenshotId =>
      integer().references(Screenshots, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {collectionId, screenshotId};
}

@DataClassName('TagRow')
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 40).unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('ScreenshotTagRow')
@TableIndex(name: 'idx_screenshot_tags_tag', columns: {#tagId})
class ScreenshotTags extends Table {
  IntColumn get screenshotId =>
      integer().references(Screenshots, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {screenshotId, tagId};
}

@DataClassName('NoteRow')
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get screenshotId => integer().unique().references(
    Screenshots,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('ReminderRow')
@TableIndex(name: 'idx_reminders_scheduled', columns: {#scheduledAt})
@TableIndex(name: 'idx_reminders_status', columns: {#status})
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get screenshotId => integer().nullable().references(
    Screenshots,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get scheduledAt => dateTime()();
  TextColumn get timezone => text()();
  IntColumn get notificationId => integer().unique()();
  BoolColumn get notify => boolean().withDefault(const Constant(true))();
  TextColumn get repeatRule =>
      textEnum<RepeatRule>().withDefault(Constant(RepeatRule.none.name))();
  TextColumn get status => textEnum<ReminderStatus>()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('SuggestedActionRow')
@TableIndex(name: 'idx_actions_screenshot', columns: {#screenshotId})
@TableIndex(name: 'idx_actions_status', columns: {#status})
class SuggestedActions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get screenshotId =>
      integer().references(Screenshots, #id, onDelete: KeyAction.cascade)();
  TextColumn get actionType => textEnum<ActionType>()();
  TextColumn get title => text()();
  TextColumn get payloadJson => text()();
  TextColumn get status => textEnum<ActionStatus>()();
  DateTimeColumn get postponedUntil => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('WishlistItemRow')
class WishlistItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get screenshotId => integer().nullable().references(
    Screenshots,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get productName => text().nullable()();

  /// Price in minor units (cents) to avoid floating-point errors.
  IntColumn get amountMinorUnits => integer().nullable()();
  TextColumn get currency => text().nullable()();
  TextColumn get merchantName => text().nullable()();
  TextColumn get productUrl => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get purchased => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('ProcessingJobRow')
@TableIndex(name: 'idx_jobs_status', columns: {#status})
class ProcessingJobs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get screenshotId =>
      integer().references(Screenshots, #id, onDelete: KeyAction.cascade)();
  TextColumn get jobType => textEnum<JobType>()();
  TextColumn get status => textEnum<JobStatus>()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('SearchHistoryRow')
class SearchHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get query => text().unique()();
  DateTimeColumn get searchedAt => dateTime()();
}

@DataClassName('AppSettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// User-defined keyword rules that boost a category during classification.
@DataClassName('ClassificationRuleRow')
class ClassificationRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get keyword => text().withLength(min: 1, max: 80)();
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
