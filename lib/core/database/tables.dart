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

  // Schema 3: every row is a "memory" (docs/MIGRATION_PLAN.md). The SQL
  // table keeps its name so ids and foreign keys stay where they are.
  TextColumn get memoryType => textEnum<MemoryType>().withDefault(
    Constant(MemoryType.screenshot.name),
  )();
  TextColumn get mimeType => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get sourceUrl => text().nullable()();
  IntColumn get pageCount => integer().nullable()();
  IntColumn get durationMs => integer().nullable()();

  /// An event date the user confirmed, for the timeline. Never guessed.
  DateTimeColumn get eventAt => dateTime().nullable()();
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

  // Schema 3: long jobs (PDF pages, embeddings) report progress and resume.
  IntColumn get priority => integer().withDefault(const Constant(0))();
  RealColumn get progress => real().nullable()();
  TextColumn get checkpointJson => text().nullable()();
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

// ---------------------------------------------------------------------------
// Schema 3 tables (RecallOS foundation). The migration creates them empty and
// later phases fill them. Derived data (chunks, embeddings, relationships)
// is not exported in backups; it is rebuilt after a restore.

/// A memory's text split for retrieval, with its position in the source.
@DataClassName('MemoryChunkRow')
class MemoryChunks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get memoryId =>
      integer().references(Screenshots, #id, onDelete: KeyAction.cascade)();
  IntColumn get chunkIndex => integer()();
  TextColumn get textOriginal => text()();
  TextColumn get textNormalized => text()();
  IntColumn get page => integer().nullable()();
  IntColumn get startMs => integer().nullable()();
  IntColumn get endMs => integer().nullable()();
  TextColumn get regionJson => text().nullable()();
  IntColumn get tokenCount => integer().nullable()();

  /// Hash of the text the chunk came from; a mismatch marks it stale.
  TextColumn get sourceChecksum => text()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {memoryId, chunkIndex},
  ];
}

/// One vector per chunk and model. Vectors from different `spaceId`s are
/// never compared with each other.
@DataClassName('EmbeddingRow')
@TableIndex(name: 'idx_embeddings_memory', columns: {#memoryId})
@TableIndex(name: 'idx_embeddings_space', columns: {#spaceId})
class Embeddings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get chunkId =>
      integer().references(MemoryChunks, #id, onDelete: KeyAction.cascade)();
  IntColumn get memoryId =>
      integer().references(Screenshots, #id, onDelete: KeyAction.cascade)();
  TextColumn get modelId => text()();
  TextColumn get modelVersion => text()();
  TextColumn get spaceId => text()();
  IntColumn get dimension => integer()();

  /// float32, little-endian.
  BlobColumn get vector => blob()();
  TextColumn get sourceChecksum => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {chunkId, modelId, modelVersion},
  ];
}

/// A project, goal or interest that groups memories.
@DataClassName('SpaceRow')
class Spaces extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 80)();
  TextColumn get description => text().nullable()();
  TextColumn get icon => text()();
  IntColumn get color => integer()();
  IntColumn get coverMemoryId => integer().nullable().references(
    Screenshots,
    #id,
    onDelete: KeyAction.setNull,
  )();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('SpaceMembershipRow')
@TableIndex(name: 'idx_space_members_memory', columns: {#memoryId})
class SpaceMemberships extends Table {
  IntColumn get spaceId =>
      integer().references(Spaces, #id, onDelete: KeyAction.cascade)();
  IntColumn get memoryId =>
      integer().references(Screenshots, #id, onDelete: KeyAction.cascade)();

  /// `user` or `suggestion_confirmed`: nothing joins a Space silently.
  TextColumn get source => text()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {spaceId, memoryId};
}

/// An explainable link between two memories.
@DataClassName('MemoryRelationshipRow')
@TableIndex(name: 'idx_relationships_target', columns: {#targetMemoryId})
class MemoryRelationships extends Table {
  IntColumn get id => integer().autoIncrement()();
  @ReferenceName('outgoingRelationships')
  IntColumn get sourceMemoryId =>
      integer().references(Screenshots, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('incomingRelationships')
  IntColumn get targetMemoryId =>
      integer().references(Screenshots, #id, onDelete: KeyAction.cascade)();
  TextColumn get relationshipType => textEnum<RelationshipType>()();

  /// Similarity or rule score; not a calibrated probability.
  RealColumn get score => real().nullable()();

  /// Why the link exists, shown to the user (e.g. "both mention LH1234").
  TextColumn get provenance => text()();
  TextColumn get method => text()();
  BoolColumn get confirmed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {sourceMemoryId, targetMemoryId, relationshipType},
  ];
}

/// On-device models known to the Model Center.
@DataClassName('ModelRegistryRow')
class ModelRegistry extends Table {
  TextColumn get modelId => text()();
  TextColumn get modelType => text()();
  TextColumn get version => text()();
  TextColumn get path => text().nullable()();
  TextColumn get installState => textEnum<ModelInstallState>()();
  TextColumn get sha256 => text()();
  IntColumn get sizeBytes => integer()();
  TextColumn get license => text()();
  TextColumn get embeddingSpaceId => text().nullable()();
  DateTimeColumn get installedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {modelId, version};
}
