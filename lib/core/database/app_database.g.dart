// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    slug,
    name,
    icon,
    color,
    isSystem,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final int id;

  /// Stable identifier for system categories (for example `shopping`).
  final String slug;
  final String name;
  final String icon;
  final int color;
  final bool isSystem;
  final DateTime createdAt;
  const CategoryRow({
    required this.id,
    required this.slug,
    required this.name,
    required this.icon,
    required this.color,
    required this.isSystem,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['slug'] = Variable<String>(slug);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<int>(color);
    map['is_system'] = Variable<bool>(isSystem);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      slug: Value(slug),
      name: Value(name),
      icon: Value(icon),
      color: Value(color),
      isSystem: Value(isSystem),
      createdAt: Value(createdAt),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<int>(json['id']),
      slug: serializer.fromJson<String>(json['slug']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<int>(json['color']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'slug': serializer.toJson<String>(slug),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<int>(color),
      'isSystem': serializer.toJson<bool>(isSystem),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CategoryRow copyWith({
    int? id,
    String? slug,
    String? name,
    String? icon,
    int? color,
    bool? isSystem,
    DateTime? createdAt,
  }) => CategoryRow(
    id: id ?? this.id,
    slug: slug ?? this.slug,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    isSystem: isSystem ?? this.isSystem,
    createdAt: createdAt ?? this.createdAt,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      slug: data.slug.present ? data.slug.value : this.slug,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isSystem: $isSystem, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, slug, name, icon, color, isSystem, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.slug == this.slug &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.isSystem == this.isSystem &&
          other.createdAt == this.createdAt);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<int> id;
  final Value<String> slug;
  final Value<String> name;
  final Value<String> icon;
  final Value<int> color;
  final Value<bool> isSystem;
  final Value<DateTime> createdAt;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.slug = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String slug,
    required String name,
    required String icon,
    required int color,
    this.isSystem = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : slug = Value(slug),
       name = Value(name),
       icon = Value(icon),
       color = Value(color);
  static Insertable<CategoryRow> custom({
    Expression<int>? id,
    Expression<String>? slug,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? color,
    Expression<bool>? isSystem,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (slug != null) 'slug': slug,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (isSystem != null) 'is_system': isSystem,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? slug,
    Value<String>? name,
    Value<String>? icon,
    Value<int>? color,
    Value<bool>? isSystem,
    Value<DateTime>? createdAt,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isSystem: $isSystem, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ScreenshotsTable extends Screenshots
    with TableInfo<$ScreenshotsTable, ScreenshotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScreenshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _originalFilenameMeta = const VerificationMeta(
    'originalFilename',
  );
  @override
  late final GeneratedColumn<String> originalFilename = GeneratedColumn<String>(
    'original_filename',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localFilePathMeta = const VerificationMeta(
    'localFilePath',
  );
  @override
  late final GeneratedColumn<String> localFilePath = GeneratedColumn<String>(
    'local_file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _perceptualHashMeta = const VerificationMeta(
    'perceptualHash',
  );
  @override
  late final GeneratedColumn<String> perceptualHash = GeneratedColumn<String>(
    'perceptual_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleLockedMeta = const VerificationMeta(
    'titleLocked',
  );
  @override
  late final GeneratedColumn<bool> titleLocked = GeneratedColumn<bool>(
    'title_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("title_locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ScreenshotSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ScreenshotSource>($ScreenshotsTable.$convertersource);
  static const VerificationMeta _primaryCategoryIdMeta = const VerificationMeta(
    'primaryCategoryId',
  );
  @override
  late final GeneratedColumn<int> primaryCategoryId = GeneratedColumn<int>(
    'primary_category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _suggestedCategoryIdMeta =
      const VerificationMeta('suggestedCategoryId');
  @override
  late final GeneratedColumn<int> suggestedCategoryId = GeneratedColumn<int>(
    'suggested_category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _classificationScoreMeta =
      const VerificationMeta('classificationScore');
  @override
  late final GeneratedColumn<double> classificationScore =
      GeneratedColumn<double>(
        'classification_score',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _categoryLockedMeta = const VerificationMeta(
    'categoryLocked',
  );
  @override
  late final GeneratedColumn<bool> categoryLocked = GeneratedColumn<bool>(
    'category_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("category_locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _needsCategoryConfirmationMeta =
      const VerificationMeta('needsCategoryConfirmation');
  @override
  late final GeneratedColumn<bool> needsCategoryConfirmation =
      GeneratedColumn<bool>(
        'needs_category_confirmation',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("needs_category_confirmation" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _isSensitiveMeta = const VerificationMeta(
    'isSensitive',
  );
  @override
  late final GeneratedColumn<bool> isSensitive = GeneratedColumn<bool>(
    'is_sensitive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_sensitive" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ProcessingStatus, String>
  processingStatus =
      GeneratedColumn<String>(
        'processing_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ProcessingStatus>(
        $ScreenshotsTable.$converterprocessingStatus,
      );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isReviewedMeta = const VerificationMeta(
    'isReviewed',
  );
  @override
  late final GeneratedColumn<bool> isReviewed = GeneratedColumn<bool>(
    'is_reviewed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_reviewed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageWidthMeta = const VerificationMeta(
    'imageWidth',
  );
  @override
  late final GeneratedColumn<int> imageWidth = GeneratedColumn<int>(
    'image_width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageHeightMeta = const VerificationMeta(
    'imageHeight',
  );
  @override
  late final GeneratedColumn<int> imageHeight = GeneratedColumn<int>(
    'image_height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MemoryType, String> memoryType =
      GeneratedColumn<String>(
        'memory_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(MemoryType.screenshot.name),
      ).withConverter<MemoryType>($ScreenshotsTable.$convertermemoryType);
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventAtMeta = const VerificationMeta(
    'eventAt',
  );
  @override
  late final GeneratedColumn<DateTime> eventAt = GeneratedColumn<DateTime>(
    'event_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    originalFilename,
    localFilePath,
    thumbnailPath,
    contentHash,
    perceptualHash,
    title,
    titleLocked,
    importedAt,
    capturedAt,
    source,
    primaryCategoryId,
    suggestedCategoryId,
    classificationScore,
    categoryLocked,
    needsCategoryConfirmation,
    isSensitive,
    processingStatus,
    isFavorite,
    isReviewed,
    isArchived,
    fileSize,
    imageWidth,
    imageHeight,
    createdAt,
    updatedAt,
    memoryType,
    mimeType,
    description,
    sourceUrl,
    pageCount,
    durationMs,
    eventAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'screenshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScreenshotRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('original_filename')) {
      context.handle(
        _originalFilenameMeta,
        originalFilename.isAcceptableOrUnknown(
          data['original_filename']!,
          _originalFilenameMeta,
        ),
      );
    }
    if (data.containsKey('local_file_path')) {
      context.handle(
        _localFilePathMeta,
        localFilePath.isAcceptableOrUnknown(
          data['local_file_path']!,
          _localFilePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localFilePathMeta);
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('perceptual_hash')) {
      context.handle(
        _perceptualHashMeta,
        perceptualHash.isAcceptableOrUnknown(
          data['perceptual_hash']!,
          _perceptualHashMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('title_locked')) {
      context.handle(
        _titleLockedMeta,
        titleLocked.isAcceptableOrUnknown(
          data['title_locked']!,
          _titleLockedMeta,
        ),
      );
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    }
    if (data.containsKey('primary_category_id')) {
      context.handle(
        _primaryCategoryIdMeta,
        primaryCategoryId.isAcceptableOrUnknown(
          data['primary_category_id']!,
          _primaryCategoryIdMeta,
        ),
      );
    }
    if (data.containsKey('suggested_category_id')) {
      context.handle(
        _suggestedCategoryIdMeta,
        suggestedCategoryId.isAcceptableOrUnknown(
          data['suggested_category_id']!,
          _suggestedCategoryIdMeta,
        ),
      );
    }
    if (data.containsKey('classification_score')) {
      context.handle(
        _classificationScoreMeta,
        classificationScore.isAcceptableOrUnknown(
          data['classification_score']!,
          _classificationScoreMeta,
        ),
      );
    }
    if (data.containsKey('category_locked')) {
      context.handle(
        _categoryLockedMeta,
        categoryLocked.isAcceptableOrUnknown(
          data['category_locked']!,
          _categoryLockedMeta,
        ),
      );
    }
    if (data.containsKey('needs_category_confirmation')) {
      context.handle(
        _needsCategoryConfirmationMeta,
        needsCategoryConfirmation.isAcceptableOrUnknown(
          data['needs_category_confirmation']!,
          _needsCategoryConfirmationMeta,
        ),
      );
    }
    if (data.containsKey('is_sensitive')) {
      context.handle(
        _isSensitiveMeta,
        isSensitive.isAcceptableOrUnknown(
          data['is_sensitive']!,
          _isSensitiveMeta,
        ),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('is_reviewed')) {
      context.handle(
        _isReviewedMeta,
        isReviewed.isAcceptableOrUnknown(data['is_reviewed']!, _isReviewedMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('image_width')) {
      context.handle(
        _imageWidthMeta,
        imageWidth.isAcceptableOrUnknown(data['image_width']!, _imageWidthMeta),
      );
    }
    if (data.containsKey('image_height')) {
      context.handle(
        _imageHeightMeta,
        imageHeight.isAcceptableOrUnknown(
          data['image_height']!,
          _imageHeightMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('event_at')) {
      context.handle(
        _eventAtMeta,
        eventAt.isAcceptableOrUnknown(data['event_at']!, _eventAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScreenshotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScreenshotRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      originalFilename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_filename'],
      ),
      localFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_file_path'],
      )!,
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      perceptualHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}perceptual_hash'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      titleLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}title_locked'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      ),
      source: $ScreenshotsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      primaryCategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}primary_category_id'],
      ),
      suggestedCategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}suggested_category_id'],
      ),
      classificationScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}classification_score'],
      ),
      categoryLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}category_locked'],
      )!,
      needsCategoryConfirmation: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_category_confirmation'],
      )!,
      isSensitive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_sensitive'],
      )!,
      processingStatus: $ScreenshotsTable.$converterprocessingStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}processing_status'],
        )!,
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isReviewed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_reviewed'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      imageWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}image_width'],
      ),
      imageHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}image_height'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      memoryType: $ScreenshotsTable.$convertermemoryType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}memory_type'],
        )!,
      ),
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      eventAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}event_at'],
      ),
    );
  }

  @override
  $ScreenshotsTable createAlias(String alias) {
    return $ScreenshotsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ScreenshotSource, String, String> $convertersource =
      const EnumNameConverter<ScreenshotSource>(ScreenshotSource.values);
  static JsonTypeConverter2<ProcessingStatus, String, String>
  $converterprocessingStatus = const EnumNameConverter<ProcessingStatus>(
    ProcessingStatus.values,
  );
  static JsonTypeConverter2<MemoryType, String, String> $convertermemoryType =
      const EnumNameConverter<MemoryType>(MemoryType.values);
}

class ScreenshotRow extends DataClass implements Insertable<ScreenshotRow> {
  final int id;
  final String? originalFilename;
  final String localFilePath;
  final String? thumbnailPath;
  final String contentHash;

  /// 64-bit dHash encoded as 16 hex characters.
  final String? perceptualHash;
  final String? title;

  /// True once the user named the screenshot. Otherwise the title is
  /// generated and re-analysis may improve it.
  final bool titleLocked;
  final DateTime importedAt;
  final DateTime? capturedAt;
  final ScreenshotSource source;
  final int? primaryCategoryId;
  final int? suggestedCategoryId;

  /// Normalized rule-match score, not a calibrated probability.
  final double? classificationScore;

  /// True once the user picked the category; reclassification must not
  /// overwrite it.
  final bool categoryLocked;
  final bool needsCategoryConfirmation;
  final bool isSensitive;
  final ProcessingStatus processingStatus;
  final bool isFavorite;
  final bool isReviewed;
  final bool isArchived;
  final int fileSize;
  final int? imageWidth;
  final int? imageHeight;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MemoryType memoryType;
  final String? mimeType;
  final String? description;
  final String? sourceUrl;
  final int? pageCount;
  final int? durationMs;

  /// An event date the user confirmed, for the timeline. Never guessed.
  final DateTime? eventAt;
  const ScreenshotRow({
    required this.id,
    this.originalFilename,
    required this.localFilePath,
    this.thumbnailPath,
    required this.contentHash,
    this.perceptualHash,
    this.title,
    required this.titleLocked,
    required this.importedAt,
    this.capturedAt,
    required this.source,
    this.primaryCategoryId,
    this.suggestedCategoryId,
    this.classificationScore,
    required this.categoryLocked,
    required this.needsCategoryConfirmation,
    required this.isSensitive,
    required this.processingStatus,
    required this.isFavorite,
    required this.isReviewed,
    required this.isArchived,
    required this.fileSize,
    this.imageWidth,
    this.imageHeight,
    required this.createdAt,
    required this.updatedAt,
    required this.memoryType,
    this.mimeType,
    this.description,
    this.sourceUrl,
    this.pageCount,
    this.durationMs,
    this.eventAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || originalFilename != null) {
      map['original_filename'] = Variable<String>(originalFilename);
    }
    map['local_file_path'] = Variable<String>(localFilePath);
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    map['content_hash'] = Variable<String>(contentHash);
    if (!nullToAbsent || perceptualHash != null) {
      map['perceptual_hash'] = Variable<String>(perceptualHash);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['title_locked'] = Variable<bool>(titleLocked);
    map['imported_at'] = Variable<DateTime>(importedAt);
    if (!nullToAbsent || capturedAt != null) {
      map['captured_at'] = Variable<DateTime>(capturedAt);
    }
    {
      map['source'] = Variable<String>(
        $ScreenshotsTable.$convertersource.toSql(source),
      );
    }
    if (!nullToAbsent || primaryCategoryId != null) {
      map['primary_category_id'] = Variable<int>(primaryCategoryId);
    }
    if (!nullToAbsent || suggestedCategoryId != null) {
      map['suggested_category_id'] = Variable<int>(suggestedCategoryId);
    }
    if (!nullToAbsent || classificationScore != null) {
      map['classification_score'] = Variable<double>(classificationScore);
    }
    map['category_locked'] = Variable<bool>(categoryLocked);
    map['needs_category_confirmation'] = Variable<bool>(
      needsCategoryConfirmation,
    );
    map['is_sensitive'] = Variable<bool>(isSensitive);
    {
      map['processing_status'] = Variable<String>(
        $ScreenshotsTable.$converterprocessingStatus.toSql(processingStatus),
      );
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_reviewed'] = Variable<bool>(isReviewed);
    map['is_archived'] = Variable<bool>(isArchived);
    map['file_size'] = Variable<int>(fileSize);
    if (!nullToAbsent || imageWidth != null) {
      map['image_width'] = Variable<int>(imageWidth);
    }
    if (!nullToAbsent || imageHeight != null) {
      map['image_height'] = Variable<int>(imageHeight);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    {
      map['memory_type'] = Variable<String>(
        $ScreenshotsTable.$convertermemoryType.toSql(memoryType),
      );
    }
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || eventAt != null) {
      map['event_at'] = Variable<DateTime>(eventAt);
    }
    return map;
  }

  ScreenshotsCompanion toCompanion(bool nullToAbsent) {
    return ScreenshotsCompanion(
      id: Value(id),
      originalFilename: originalFilename == null && nullToAbsent
          ? const Value.absent()
          : Value(originalFilename),
      localFilePath: Value(localFilePath),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      contentHash: Value(contentHash),
      perceptualHash: perceptualHash == null && nullToAbsent
          ? const Value.absent()
          : Value(perceptualHash),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      titleLocked: Value(titleLocked),
      importedAt: Value(importedAt),
      capturedAt: capturedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(capturedAt),
      source: Value(source),
      primaryCategoryId: primaryCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryCategoryId),
      suggestedCategoryId: suggestedCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestedCategoryId),
      classificationScore: classificationScore == null && nullToAbsent
          ? const Value.absent()
          : Value(classificationScore),
      categoryLocked: Value(categoryLocked),
      needsCategoryConfirmation: Value(needsCategoryConfirmation),
      isSensitive: Value(isSensitive),
      processingStatus: Value(processingStatus),
      isFavorite: Value(isFavorite),
      isReviewed: Value(isReviewed),
      isArchived: Value(isArchived),
      fileSize: Value(fileSize),
      imageWidth: imageWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(imageWidth),
      imageHeight: imageHeight == null && nullToAbsent
          ? const Value.absent()
          : Value(imageHeight),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      memoryType: Value(memoryType),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      eventAt: eventAt == null && nullToAbsent
          ? const Value.absent()
          : Value(eventAt),
    );
  }

  factory ScreenshotRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScreenshotRow(
      id: serializer.fromJson<int>(json['id']),
      originalFilename: serializer.fromJson<String?>(json['originalFilename']),
      localFilePath: serializer.fromJson<String>(json['localFilePath']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      perceptualHash: serializer.fromJson<String?>(json['perceptualHash']),
      title: serializer.fromJson<String?>(json['title']),
      titleLocked: serializer.fromJson<bool>(json['titleLocked']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
      capturedAt: serializer.fromJson<DateTime?>(json['capturedAt']),
      source: $ScreenshotsTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      primaryCategoryId: serializer.fromJson<int?>(json['primaryCategoryId']),
      suggestedCategoryId: serializer.fromJson<int?>(
        json['suggestedCategoryId'],
      ),
      classificationScore: serializer.fromJson<double?>(
        json['classificationScore'],
      ),
      categoryLocked: serializer.fromJson<bool>(json['categoryLocked']),
      needsCategoryConfirmation: serializer.fromJson<bool>(
        json['needsCategoryConfirmation'],
      ),
      isSensitive: serializer.fromJson<bool>(json['isSensitive']),
      processingStatus: $ScreenshotsTable.$converterprocessingStatus.fromJson(
        serializer.fromJson<String>(json['processingStatus']),
      ),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isReviewed: serializer.fromJson<bool>(json['isReviewed']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      imageWidth: serializer.fromJson<int?>(json['imageWidth']),
      imageHeight: serializer.fromJson<int?>(json['imageHeight']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      memoryType: $ScreenshotsTable.$convertermemoryType.fromJson(
        serializer.fromJson<String>(json['memoryType']),
      ),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      description: serializer.fromJson<String?>(json['description']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      eventAt: serializer.fromJson<DateTime?>(json['eventAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'originalFilename': serializer.toJson<String?>(originalFilename),
      'localFilePath': serializer.toJson<String>(localFilePath),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'contentHash': serializer.toJson<String>(contentHash),
      'perceptualHash': serializer.toJson<String?>(perceptualHash),
      'title': serializer.toJson<String?>(title),
      'titleLocked': serializer.toJson<bool>(titleLocked),
      'importedAt': serializer.toJson<DateTime>(importedAt),
      'capturedAt': serializer.toJson<DateTime?>(capturedAt),
      'source': serializer.toJson<String>(
        $ScreenshotsTable.$convertersource.toJson(source),
      ),
      'primaryCategoryId': serializer.toJson<int?>(primaryCategoryId),
      'suggestedCategoryId': serializer.toJson<int?>(suggestedCategoryId),
      'classificationScore': serializer.toJson<double?>(classificationScore),
      'categoryLocked': serializer.toJson<bool>(categoryLocked),
      'needsCategoryConfirmation': serializer.toJson<bool>(
        needsCategoryConfirmation,
      ),
      'isSensitive': serializer.toJson<bool>(isSensitive),
      'processingStatus': serializer.toJson<String>(
        $ScreenshotsTable.$converterprocessingStatus.toJson(processingStatus),
      ),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isReviewed': serializer.toJson<bool>(isReviewed),
      'isArchived': serializer.toJson<bool>(isArchived),
      'fileSize': serializer.toJson<int>(fileSize),
      'imageWidth': serializer.toJson<int?>(imageWidth),
      'imageHeight': serializer.toJson<int?>(imageHeight),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'memoryType': serializer.toJson<String>(
        $ScreenshotsTable.$convertermemoryType.toJson(memoryType),
      ),
      'mimeType': serializer.toJson<String?>(mimeType),
      'description': serializer.toJson<String?>(description),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'pageCount': serializer.toJson<int?>(pageCount),
      'durationMs': serializer.toJson<int?>(durationMs),
      'eventAt': serializer.toJson<DateTime?>(eventAt),
    };
  }

  ScreenshotRow copyWith({
    int? id,
    Value<String?> originalFilename = const Value.absent(),
    String? localFilePath,
    Value<String?> thumbnailPath = const Value.absent(),
    String? contentHash,
    Value<String?> perceptualHash = const Value.absent(),
    Value<String?> title = const Value.absent(),
    bool? titleLocked,
    DateTime? importedAt,
    Value<DateTime?> capturedAt = const Value.absent(),
    ScreenshotSource? source,
    Value<int?> primaryCategoryId = const Value.absent(),
    Value<int?> suggestedCategoryId = const Value.absent(),
    Value<double?> classificationScore = const Value.absent(),
    bool? categoryLocked,
    bool? needsCategoryConfirmation,
    bool? isSensitive,
    ProcessingStatus? processingStatus,
    bool? isFavorite,
    bool? isReviewed,
    bool? isArchived,
    int? fileSize,
    Value<int?> imageWidth = const Value.absent(),
    Value<int?> imageHeight = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    MemoryType? memoryType,
    Value<String?> mimeType = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> sourceUrl = const Value.absent(),
    Value<int?> pageCount = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<DateTime?> eventAt = const Value.absent(),
  }) => ScreenshotRow(
    id: id ?? this.id,
    originalFilename: originalFilename.present
        ? originalFilename.value
        : this.originalFilename,
    localFilePath: localFilePath ?? this.localFilePath,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
    contentHash: contentHash ?? this.contentHash,
    perceptualHash: perceptualHash.present
        ? perceptualHash.value
        : this.perceptualHash,
    title: title.present ? title.value : this.title,
    titleLocked: titleLocked ?? this.titleLocked,
    importedAt: importedAt ?? this.importedAt,
    capturedAt: capturedAt.present ? capturedAt.value : this.capturedAt,
    source: source ?? this.source,
    primaryCategoryId: primaryCategoryId.present
        ? primaryCategoryId.value
        : this.primaryCategoryId,
    suggestedCategoryId: suggestedCategoryId.present
        ? suggestedCategoryId.value
        : this.suggestedCategoryId,
    classificationScore: classificationScore.present
        ? classificationScore.value
        : this.classificationScore,
    categoryLocked: categoryLocked ?? this.categoryLocked,
    needsCategoryConfirmation:
        needsCategoryConfirmation ?? this.needsCategoryConfirmation,
    isSensitive: isSensitive ?? this.isSensitive,
    processingStatus: processingStatus ?? this.processingStatus,
    isFavorite: isFavorite ?? this.isFavorite,
    isReviewed: isReviewed ?? this.isReviewed,
    isArchived: isArchived ?? this.isArchived,
    fileSize: fileSize ?? this.fileSize,
    imageWidth: imageWidth.present ? imageWidth.value : this.imageWidth,
    imageHeight: imageHeight.present ? imageHeight.value : this.imageHeight,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    memoryType: memoryType ?? this.memoryType,
    mimeType: mimeType.present ? mimeType.value : this.mimeType,
    description: description.present ? description.value : this.description,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    pageCount: pageCount.present ? pageCount.value : this.pageCount,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    eventAt: eventAt.present ? eventAt.value : this.eventAt,
  );
  ScreenshotRow copyWithCompanion(ScreenshotsCompanion data) {
    return ScreenshotRow(
      id: data.id.present ? data.id.value : this.id,
      originalFilename: data.originalFilename.present
          ? data.originalFilename.value
          : this.originalFilename,
      localFilePath: data.localFilePath.present
          ? data.localFilePath.value
          : this.localFilePath,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      perceptualHash: data.perceptualHash.present
          ? data.perceptualHash.value
          : this.perceptualHash,
      title: data.title.present ? data.title.value : this.title,
      titleLocked: data.titleLocked.present
          ? data.titleLocked.value
          : this.titleLocked,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      source: data.source.present ? data.source.value : this.source,
      primaryCategoryId: data.primaryCategoryId.present
          ? data.primaryCategoryId.value
          : this.primaryCategoryId,
      suggestedCategoryId: data.suggestedCategoryId.present
          ? data.suggestedCategoryId.value
          : this.suggestedCategoryId,
      classificationScore: data.classificationScore.present
          ? data.classificationScore.value
          : this.classificationScore,
      categoryLocked: data.categoryLocked.present
          ? data.categoryLocked.value
          : this.categoryLocked,
      needsCategoryConfirmation: data.needsCategoryConfirmation.present
          ? data.needsCategoryConfirmation.value
          : this.needsCategoryConfirmation,
      isSensitive: data.isSensitive.present
          ? data.isSensitive.value
          : this.isSensitive,
      processingStatus: data.processingStatus.present
          ? data.processingStatus.value
          : this.processingStatus,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isReviewed: data.isReviewed.present
          ? data.isReviewed.value
          : this.isReviewed,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      imageWidth: data.imageWidth.present
          ? data.imageWidth.value
          : this.imageWidth,
      imageHeight: data.imageHeight.present
          ? data.imageHeight.value
          : this.imageHeight,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      memoryType: data.memoryType.present
          ? data.memoryType.value
          : this.memoryType,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      description: data.description.present
          ? data.description.value
          : this.description,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      eventAt: data.eventAt.present ? data.eventAt.value : this.eventAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScreenshotRow(')
          ..write('id: $id, ')
          ..write('originalFilename: $originalFilename, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('contentHash: $contentHash, ')
          ..write('perceptualHash: $perceptualHash, ')
          ..write('title: $title, ')
          ..write('titleLocked: $titleLocked, ')
          ..write('importedAt: $importedAt, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('source: $source, ')
          ..write('primaryCategoryId: $primaryCategoryId, ')
          ..write('suggestedCategoryId: $suggestedCategoryId, ')
          ..write('classificationScore: $classificationScore, ')
          ..write('categoryLocked: $categoryLocked, ')
          ..write('needsCategoryConfirmation: $needsCategoryConfirmation, ')
          ..write('isSensitive: $isSensitive, ')
          ..write('processingStatus: $processingStatus, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isReviewed: $isReviewed, ')
          ..write('isArchived: $isArchived, ')
          ..write('fileSize: $fileSize, ')
          ..write('imageWidth: $imageWidth, ')
          ..write('imageHeight: $imageHeight, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('memoryType: $memoryType, ')
          ..write('mimeType: $mimeType, ')
          ..write('description: $description, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('pageCount: $pageCount, ')
          ..write('durationMs: $durationMs, ')
          ..write('eventAt: $eventAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    originalFilename,
    localFilePath,
    thumbnailPath,
    contentHash,
    perceptualHash,
    title,
    titleLocked,
    importedAt,
    capturedAt,
    source,
    primaryCategoryId,
    suggestedCategoryId,
    classificationScore,
    categoryLocked,
    needsCategoryConfirmation,
    isSensitive,
    processingStatus,
    isFavorite,
    isReviewed,
    isArchived,
    fileSize,
    imageWidth,
    imageHeight,
    createdAt,
    updatedAt,
    memoryType,
    mimeType,
    description,
    sourceUrl,
    pageCount,
    durationMs,
    eventAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScreenshotRow &&
          other.id == this.id &&
          other.originalFilename == this.originalFilename &&
          other.localFilePath == this.localFilePath &&
          other.thumbnailPath == this.thumbnailPath &&
          other.contentHash == this.contentHash &&
          other.perceptualHash == this.perceptualHash &&
          other.title == this.title &&
          other.titleLocked == this.titleLocked &&
          other.importedAt == this.importedAt &&
          other.capturedAt == this.capturedAt &&
          other.source == this.source &&
          other.primaryCategoryId == this.primaryCategoryId &&
          other.suggestedCategoryId == this.suggestedCategoryId &&
          other.classificationScore == this.classificationScore &&
          other.categoryLocked == this.categoryLocked &&
          other.needsCategoryConfirmation == this.needsCategoryConfirmation &&
          other.isSensitive == this.isSensitive &&
          other.processingStatus == this.processingStatus &&
          other.isFavorite == this.isFavorite &&
          other.isReviewed == this.isReviewed &&
          other.isArchived == this.isArchived &&
          other.fileSize == this.fileSize &&
          other.imageWidth == this.imageWidth &&
          other.imageHeight == this.imageHeight &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.memoryType == this.memoryType &&
          other.mimeType == this.mimeType &&
          other.description == this.description &&
          other.sourceUrl == this.sourceUrl &&
          other.pageCount == this.pageCount &&
          other.durationMs == this.durationMs &&
          other.eventAt == this.eventAt);
}

class ScreenshotsCompanion extends UpdateCompanion<ScreenshotRow> {
  final Value<int> id;
  final Value<String?> originalFilename;
  final Value<String> localFilePath;
  final Value<String?> thumbnailPath;
  final Value<String> contentHash;
  final Value<String?> perceptualHash;
  final Value<String?> title;
  final Value<bool> titleLocked;
  final Value<DateTime> importedAt;
  final Value<DateTime?> capturedAt;
  final Value<ScreenshotSource> source;
  final Value<int?> primaryCategoryId;
  final Value<int?> suggestedCategoryId;
  final Value<double?> classificationScore;
  final Value<bool> categoryLocked;
  final Value<bool> needsCategoryConfirmation;
  final Value<bool> isSensitive;
  final Value<ProcessingStatus> processingStatus;
  final Value<bool> isFavorite;
  final Value<bool> isReviewed;
  final Value<bool> isArchived;
  final Value<int> fileSize;
  final Value<int?> imageWidth;
  final Value<int?> imageHeight;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<MemoryType> memoryType;
  final Value<String?> mimeType;
  final Value<String?> description;
  final Value<String?> sourceUrl;
  final Value<int?> pageCount;
  final Value<int?> durationMs;
  final Value<DateTime?> eventAt;
  const ScreenshotsCompanion({
    this.id = const Value.absent(),
    this.originalFilename = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.perceptualHash = const Value.absent(),
    this.title = const Value.absent(),
    this.titleLocked = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.source = const Value.absent(),
    this.primaryCategoryId = const Value.absent(),
    this.suggestedCategoryId = const Value.absent(),
    this.classificationScore = const Value.absent(),
    this.categoryLocked = const Value.absent(),
    this.needsCategoryConfirmation = const Value.absent(),
    this.isSensitive = const Value.absent(),
    this.processingStatus = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isReviewed = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.imageWidth = const Value.absent(),
    this.imageHeight = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.memoryType = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.description = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.eventAt = const Value.absent(),
  });
  ScreenshotsCompanion.insert({
    this.id = const Value.absent(),
    this.originalFilename = const Value.absent(),
    required String localFilePath,
    this.thumbnailPath = const Value.absent(),
    required String contentHash,
    this.perceptualHash = const Value.absent(),
    this.title = const Value.absent(),
    this.titleLocked = const Value.absent(),
    required DateTime importedAt,
    this.capturedAt = const Value.absent(),
    required ScreenshotSource source,
    this.primaryCategoryId = const Value.absent(),
    this.suggestedCategoryId = const Value.absent(),
    this.classificationScore = const Value.absent(),
    this.categoryLocked = const Value.absent(),
    this.needsCategoryConfirmation = const Value.absent(),
    this.isSensitive = const Value.absent(),
    required ProcessingStatus processingStatus,
    this.isFavorite = const Value.absent(),
    this.isReviewed = const Value.absent(),
    this.isArchived = const Value.absent(),
    required int fileSize,
    this.imageWidth = const Value.absent(),
    this.imageHeight = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.memoryType = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.description = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.eventAt = const Value.absent(),
  }) : localFilePath = Value(localFilePath),
       contentHash = Value(contentHash),
       importedAt = Value(importedAt),
       source = Value(source),
       processingStatus = Value(processingStatus),
       fileSize = Value(fileSize);
  static Insertable<ScreenshotRow> custom({
    Expression<int>? id,
    Expression<String>? originalFilename,
    Expression<String>? localFilePath,
    Expression<String>? thumbnailPath,
    Expression<String>? contentHash,
    Expression<String>? perceptualHash,
    Expression<String>? title,
    Expression<bool>? titleLocked,
    Expression<DateTime>? importedAt,
    Expression<DateTime>? capturedAt,
    Expression<String>? source,
    Expression<int>? primaryCategoryId,
    Expression<int>? suggestedCategoryId,
    Expression<double>? classificationScore,
    Expression<bool>? categoryLocked,
    Expression<bool>? needsCategoryConfirmation,
    Expression<bool>? isSensitive,
    Expression<String>? processingStatus,
    Expression<bool>? isFavorite,
    Expression<bool>? isReviewed,
    Expression<bool>? isArchived,
    Expression<int>? fileSize,
    Expression<int>? imageWidth,
    Expression<int>? imageHeight,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? memoryType,
    Expression<String>? mimeType,
    Expression<String>? description,
    Expression<String>? sourceUrl,
    Expression<int>? pageCount,
    Expression<int>? durationMs,
    Expression<DateTime>? eventAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (originalFilename != null) 'original_filename': originalFilename,
      if (localFilePath != null) 'local_file_path': localFilePath,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (contentHash != null) 'content_hash': contentHash,
      if (perceptualHash != null) 'perceptual_hash': perceptualHash,
      if (title != null) 'title': title,
      if (titleLocked != null) 'title_locked': titleLocked,
      if (importedAt != null) 'imported_at': importedAt,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (source != null) 'source': source,
      if (primaryCategoryId != null) 'primary_category_id': primaryCategoryId,
      if (suggestedCategoryId != null)
        'suggested_category_id': suggestedCategoryId,
      if (classificationScore != null)
        'classification_score': classificationScore,
      if (categoryLocked != null) 'category_locked': categoryLocked,
      if (needsCategoryConfirmation != null)
        'needs_category_confirmation': needsCategoryConfirmation,
      if (isSensitive != null) 'is_sensitive': isSensitive,
      if (processingStatus != null) 'processing_status': processingStatus,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isReviewed != null) 'is_reviewed': isReviewed,
      if (isArchived != null) 'is_archived': isArchived,
      if (fileSize != null) 'file_size': fileSize,
      if (imageWidth != null) 'image_width': imageWidth,
      if (imageHeight != null) 'image_height': imageHeight,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (memoryType != null) 'memory_type': memoryType,
      if (mimeType != null) 'mime_type': mimeType,
      if (description != null) 'description': description,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (pageCount != null) 'page_count': pageCount,
      if (durationMs != null) 'duration_ms': durationMs,
      if (eventAt != null) 'event_at': eventAt,
    });
  }

  ScreenshotsCompanion copyWith({
    Value<int>? id,
    Value<String?>? originalFilename,
    Value<String>? localFilePath,
    Value<String?>? thumbnailPath,
    Value<String>? contentHash,
    Value<String?>? perceptualHash,
    Value<String?>? title,
    Value<bool>? titleLocked,
    Value<DateTime>? importedAt,
    Value<DateTime?>? capturedAt,
    Value<ScreenshotSource>? source,
    Value<int?>? primaryCategoryId,
    Value<int?>? suggestedCategoryId,
    Value<double?>? classificationScore,
    Value<bool>? categoryLocked,
    Value<bool>? needsCategoryConfirmation,
    Value<bool>? isSensitive,
    Value<ProcessingStatus>? processingStatus,
    Value<bool>? isFavorite,
    Value<bool>? isReviewed,
    Value<bool>? isArchived,
    Value<int>? fileSize,
    Value<int?>? imageWidth,
    Value<int?>? imageHeight,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<MemoryType>? memoryType,
    Value<String?>? mimeType,
    Value<String?>? description,
    Value<String?>? sourceUrl,
    Value<int?>? pageCount,
    Value<int?>? durationMs,
    Value<DateTime?>? eventAt,
  }) {
    return ScreenshotsCompanion(
      id: id ?? this.id,
      originalFilename: originalFilename ?? this.originalFilename,
      localFilePath: localFilePath ?? this.localFilePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      contentHash: contentHash ?? this.contentHash,
      perceptualHash: perceptualHash ?? this.perceptualHash,
      title: title ?? this.title,
      titleLocked: titleLocked ?? this.titleLocked,
      importedAt: importedAt ?? this.importedAt,
      capturedAt: capturedAt ?? this.capturedAt,
      source: source ?? this.source,
      primaryCategoryId: primaryCategoryId ?? this.primaryCategoryId,
      suggestedCategoryId: suggestedCategoryId ?? this.suggestedCategoryId,
      classificationScore: classificationScore ?? this.classificationScore,
      categoryLocked: categoryLocked ?? this.categoryLocked,
      needsCategoryConfirmation:
          needsCategoryConfirmation ?? this.needsCategoryConfirmation,
      isSensitive: isSensitive ?? this.isSensitive,
      processingStatus: processingStatus ?? this.processingStatus,
      isFavorite: isFavorite ?? this.isFavorite,
      isReviewed: isReviewed ?? this.isReviewed,
      isArchived: isArchived ?? this.isArchived,
      fileSize: fileSize ?? this.fileSize,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      memoryType: memoryType ?? this.memoryType,
      mimeType: mimeType ?? this.mimeType,
      description: description ?? this.description,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      pageCount: pageCount ?? this.pageCount,
      durationMs: durationMs ?? this.durationMs,
      eventAt: eventAt ?? this.eventAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (originalFilename.present) {
      map['original_filename'] = Variable<String>(originalFilename.value);
    }
    if (localFilePath.present) {
      map['local_file_path'] = Variable<String>(localFilePath.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (perceptualHash.present) {
      map['perceptual_hash'] = Variable<String>(perceptualHash.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (titleLocked.present) {
      map['title_locked'] = Variable<bool>(titleLocked.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $ScreenshotsTable.$convertersource.toSql(source.value),
      );
    }
    if (primaryCategoryId.present) {
      map['primary_category_id'] = Variable<int>(primaryCategoryId.value);
    }
    if (suggestedCategoryId.present) {
      map['suggested_category_id'] = Variable<int>(suggestedCategoryId.value);
    }
    if (classificationScore.present) {
      map['classification_score'] = Variable<double>(classificationScore.value);
    }
    if (categoryLocked.present) {
      map['category_locked'] = Variable<bool>(categoryLocked.value);
    }
    if (needsCategoryConfirmation.present) {
      map['needs_category_confirmation'] = Variable<bool>(
        needsCategoryConfirmation.value,
      );
    }
    if (isSensitive.present) {
      map['is_sensitive'] = Variable<bool>(isSensitive.value);
    }
    if (processingStatus.present) {
      map['processing_status'] = Variable<String>(
        $ScreenshotsTable.$converterprocessingStatus.toSql(
          processingStatus.value,
        ),
      );
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isReviewed.present) {
      map['is_reviewed'] = Variable<bool>(isReviewed.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (imageWidth.present) {
      map['image_width'] = Variable<int>(imageWidth.value);
    }
    if (imageHeight.present) {
      map['image_height'] = Variable<int>(imageHeight.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (memoryType.present) {
      map['memory_type'] = Variable<String>(
        $ScreenshotsTable.$convertermemoryType.toSql(memoryType.value),
      );
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (eventAt.present) {
      map['event_at'] = Variable<DateTime>(eventAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScreenshotsCompanion(')
          ..write('id: $id, ')
          ..write('originalFilename: $originalFilename, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('contentHash: $contentHash, ')
          ..write('perceptualHash: $perceptualHash, ')
          ..write('title: $title, ')
          ..write('titleLocked: $titleLocked, ')
          ..write('importedAt: $importedAt, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('source: $source, ')
          ..write('primaryCategoryId: $primaryCategoryId, ')
          ..write('suggestedCategoryId: $suggestedCategoryId, ')
          ..write('classificationScore: $classificationScore, ')
          ..write('categoryLocked: $categoryLocked, ')
          ..write('needsCategoryConfirmation: $needsCategoryConfirmation, ')
          ..write('isSensitive: $isSensitive, ')
          ..write('processingStatus: $processingStatus, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isReviewed: $isReviewed, ')
          ..write('isArchived: $isArchived, ')
          ..write('fileSize: $fileSize, ')
          ..write('imageWidth: $imageWidth, ')
          ..write('imageHeight: $imageHeight, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('memoryType: $memoryType, ')
          ..write('mimeType: $mimeType, ')
          ..write('description: $description, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('pageCount: $pageCount, ')
          ..write('durationMs: $durationMs, ')
          ..write('eventAt: $eventAt')
          ..write(')'))
        .toString();
  }
}

class $OcrResultsTable extends OcrResults
    with TableInfo<$OcrResultsTable, OcrResultRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OcrResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _screenshotIdMeta = const VerificationMeta(
    'screenshotId',
  );
  @override
  late final GeneratedColumn<int> screenshotId = GeneratedColumn<int>(
    'screenshot_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES screenshots (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _rawTextMeta = const VerificationMeta(
    'rawText',
  );
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
    'raw_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctedTextMeta = const VerificationMeta(
    'correctedText',
  );
  @override
  late final GeneratedColumn<String> correctedText = GeneratedColumn<String>(
    'corrected_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _textBlocksJsonMeta = const VerificationMeta(
    'textBlocksJson',
  );
  @override
  late final GeneratedColumn<String> textBlocksJson = GeneratedColumn<String>(
    'text_blocks_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recognizerNameMeta = const VerificationMeta(
    'recognizerName',
  );
  @override
  late final GeneratedColumn<String> recognizerName = GeneratedColumn<String>(
    'recognizer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recognizerVersionMeta = const VerificationMeta(
    'recognizerVersion',
  );
  @override
  late final GeneratedColumn<String> recognizerVersion =
      GeneratedColumn<String>(
        'recognizer_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _processedAtMeta = const VerificationMeta(
    'processedAt',
  );
  @override
  late final GeneratedColumn<DateTime> processedAt = GeneratedColumn<DateTime>(
    'processed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    screenshotId,
    rawText,
    correctedText,
    textBlocksJson,
    recognizerName,
    recognizerVersion,
    processedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ocr_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<OcrResultRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('screenshot_id')) {
      context.handle(
        _screenshotIdMeta,
        screenshotId.isAcceptableOrUnknown(
          data['screenshot_id']!,
          _screenshotIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_screenshotIdMeta);
    }
    if (data.containsKey('raw_text')) {
      context.handle(
        _rawTextMeta,
        rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta),
      );
    } else if (isInserting) {
      context.missing(_rawTextMeta);
    }
    if (data.containsKey('corrected_text')) {
      context.handle(
        _correctedTextMeta,
        correctedText.isAcceptableOrUnknown(
          data['corrected_text']!,
          _correctedTextMeta,
        ),
      );
    }
    if (data.containsKey('text_blocks_json')) {
      context.handle(
        _textBlocksJsonMeta,
        textBlocksJson.isAcceptableOrUnknown(
          data['text_blocks_json']!,
          _textBlocksJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_textBlocksJsonMeta);
    }
    if (data.containsKey('recognizer_name')) {
      context.handle(
        _recognizerNameMeta,
        recognizerName.isAcceptableOrUnknown(
          data['recognizer_name']!,
          _recognizerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recognizerNameMeta);
    }
    if (data.containsKey('recognizer_version')) {
      context.handle(
        _recognizerVersionMeta,
        recognizerVersion.isAcceptableOrUnknown(
          data['recognizer_version']!,
          _recognizerVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recognizerVersionMeta);
    }
    if (data.containsKey('processed_at')) {
      context.handle(
        _processedAtMeta,
        processedAt.isAcceptableOrUnknown(
          data['processed_at']!,
          _processedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_processedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OcrResultRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OcrResultRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      screenshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}screenshot_id'],
      )!,
      rawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_text'],
      )!,
      correctedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}corrected_text'],
      ),
      textBlocksJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_blocks_json'],
      )!,
      recognizerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recognizer_name'],
      )!,
      recognizerVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recognizer_version'],
      )!,
      processedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}processed_at'],
      )!,
    );
  }

  @override
  $OcrResultsTable createAlias(String alias) {
    return $OcrResultsTable(attachedDatabase, alias);
  }
}

class OcrResultRow extends DataClass implements Insertable<OcrResultRow> {
  final int id;
  final int screenshotId;
  final String rawText;
  final String? correctedText;
  final String textBlocksJson;
  final String recognizerName;
  final String recognizerVersion;
  final DateTime processedAt;
  const OcrResultRow({
    required this.id,
    required this.screenshotId,
    required this.rawText,
    this.correctedText,
    required this.textBlocksJson,
    required this.recognizerName,
    required this.recognizerVersion,
    required this.processedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['screenshot_id'] = Variable<int>(screenshotId);
    map['raw_text'] = Variable<String>(rawText);
    if (!nullToAbsent || correctedText != null) {
      map['corrected_text'] = Variable<String>(correctedText);
    }
    map['text_blocks_json'] = Variable<String>(textBlocksJson);
    map['recognizer_name'] = Variable<String>(recognizerName);
    map['recognizer_version'] = Variable<String>(recognizerVersion);
    map['processed_at'] = Variable<DateTime>(processedAt);
    return map;
  }

  OcrResultsCompanion toCompanion(bool nullToAbsent) {
    return OcrResultsCompanion(
      id: Value(id),
      screenshotId: Value(screenshotId),
      rawText: Value(rawText),
      correctedText: correctedText == null && nullToAbsent
          ? const Value.absent()
          : Value(correctedText),
      textBlocksJson: Value(textBlocksJson),
      recognizerName: Value(recognizerName),
      recognizerVersion: Value(recognizerVersion),
      processedAt: Value(processedAt),
    );
  }

  factory OcrResultRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OcrResultRow(
      id: serializer.fromJson<int>(json['id']),
      screenshotId: serializer.fromJson<int>(json['screenshotId']),
      rawText: serializer.fromJson<String>(json['rawText']),
      correctedText: serializer.fromJson<String?>(json['correctedText']),
      textBlocksJson: serializer.fromJson<String>(json['textBlocksJson']),
      recognizerName: serializer.fromJson<String>(json['recognizerName']),
      recognizerVersion: serializer.fromJson<String>(json['recognizerVersion']),
      processedAt: serializer.fromJson<DateTime>(json['processedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'screenshotId': serializer.toJson<int>(screenshotId),
      'rawText': serializer.toJson<String>(rawText),
      'correctedText': serializer.toJson<String?>(correctedText),
      'textBlocksJson': serializer.toJson<String>(textBlocksJson),
      'recognizerName': serializer.toJson<String>(recognizerName),
      'recognizerVersion': serializer.toJson<String>(recognizerVersion),
      'processedAt': serializer.toJson<DateTime>(processedAt),
    };
  }

  OcrResultRow copyWith({
    int? id,
    int? screenshotId,
    String? rawText,
    Value<String?> correctedText = const Value.absent(),
    String? textBlocksJson,
    String? recognizerName,
    String? recognizerVersion,
    DateTime? processedAt,
  }) => OcrResultRow(
    id: id ?? this.id,
    screenshotId: screenshotId ?? this.screenshotId,
    rawText: rawText ?? this.rawText,
    correctedText: correctedText.present
        ? correctedText.value
        : this.correctedText,
    textBlocksJson: textBlocksJson ?? this.textBlocksJson,
    recognizerName: recognizerName ?? this.recognizerName,
    recognizerVersion: recognizerVersion ?? this.recognizerVersion,
    processedAt: processedAt ?? this.processedAt,
  );
  OcrResultRow copyWithCompanion(OcrResultsCompanion data) {
    return OcrResultRow(
      id: data.id.present ? data.id.value : this.id,
      screenshotId: data.screenshotId.present
          ? data.screenshotId.value
          : this.screenshotId,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      correctedText: data.correctedText.present
          ? data.correctedText.value
          : this.correctedText,
      textBlocksJson: data.textBlocksJson.present
          ? data.textBlocksJson.value
          : this.textBlocksJson,
      recognizerName: data.recognizerName.present
          ? data.recognizerName.value
          : this.recognizerName,
      recognizerVersion: data.recognizerVersion.present
          ? data.recognizerVersion.value
          : this.recognizerVersion,
      processedAt: data.processedAt.present
          ? data.processedAt.value
          : this.processedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OcrResultRow(')
          ..write('id: $id, ')
          ..write('screenshotId: $screenshotId, ')
          ..write('rawText: $rawText, ')
          ..write('correctedText: $correctedText, ')
          ..write('textBlocksJson: $textBlocksJson, ')
          ..write('recognizerName: $recognizerName, ')
          ..write('recognizerVersion: $recognizerVersion, ')
          ..write('processedAt: $processedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    screenshotId,
    rawText,
    correctedText,
    textBlocksJson,
    recognizerName,
    recognizerVersion,
    processedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OcrResultRow &&
          other.id == this.id &&
          other.screenshotId == this.screenshotId &&
          other.rawText == this.rawText &&
          other.correctedText == this.correctedText &&
          other.textBlocksJson == this.textBlocksJson &&
          other.recognizerName == this.recognizerName &&
          other.recognizerVersion == this.recognizerVersion &&
          other.processedAt == this.processedAt);
}

class OcrResultsCompanion extends UpdateCompanion<OcrResultRow> {
  final Value<int> id;
  final Value<int> screenshotId;
  final Value<String> rawText;
  final Value<String?> correctedText;
  final Value<String> textBlocksJson;
  final Value<String> recognizerName;
  final Value<String> recognizerVersion;
  final Value<DateTime> processedAt;
  const OcrResultsCompanion({
    this.id = const Value.absent(),
    this.screenshotId = const Value.absent(),
    this.rawText = const Value.absent(),
    this.correctedText = const Value.absent(),
    this.textBlocksJson = const Value.absent(),
    this.recognizerName = const Value.absent(),
    this.recognizerVersion = const Value.absent(),
    this.processedAt = const Value.absent(),
  });
  OcrResultsCompanion.insert({
    this.id = const Value.absent(),
    required int screenshotId,
    required String rawText,
    this.correctedText = const Value.absent(),
    required String textBlocksJson,
    required String recognizerName,
    required String recognizerVersion,
    required DateTime processedAt,
  }) : screenshotId = Value(screenshotId),
       rawText = Value(rawText),
       textBlocksJson = Value(textBlocksJson),
       recognizerName = Value(recognizerName),
       recognizerVersion = Value(recognizerVersion),
       processedAt = Value(processedAt);
  static Insertable<OcrResultRow> custom({
    Expression<int>? id,
    Expression<int>? screenshotId,
    Expression<String>? rawText,
    Expression<String>? correctedText,
    Expression<String>? textBlocksJson,
    Expression<String>? recognizerName,
    Expression<String>? recognizerVersion,
    Expression<DateTime>? processedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (screenshotId != null) 'screenshot_id': screenshotId,
      if (rawText != null) 'raw_text': rawText,
      if (correctedText != null) 'corrected_text': correctedText,
      if (textBlocksJson != null) 'text_blocks_json': textBlocksJson,
      if (recognizerName != null) 'recognizer_name': recognizerName,
      if (recognizerVersion != null) 'recognizer_version': recognizerVersion,
      if (processedAt != null) 'processed_at': processedAt,
    });
  }

  OcrResultsCompanion copyWith({
    Value<int>? id,
    Value<int>? screenshotId,
    Value<String>? rawText,
    Value<String?>? correctedText,
    Value<String>? textBlocksJson,
    Value<String>? recognizerName,
    Value<String>? recognizerVersion,
    Value<DateTime>? processedAt,
  }) {
    return OcrResultsCompanion(
      id: id ?? this.id,
      screenshotId: screenshotId ?? this.screenshotId,
      rawText: rawText ?? this.rawText,
      correctedText: correctedText ?? this.correctedText,
      textBlocksJson: textBlocksJson ?? this.textBlocksJson,
      recognizerName: recognizerName ?? this.recognizerName,
      recognizerVersion: recognizerVersion ?? this.recognizerVersion,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (screenshotId.present) {
      map['screenshot_id'] = Variable<int>(screenshotId.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (correctedText.present) {
      map['corrected_text'] = Variable<String>(correctedText.value);
    }
    if (textBlocksJson.present) {
      map['text_blocks_json'] = Variable<String>(textBlocksJson.value);
    }
    if (recognizerName.present) {
      map['recognizer_name'] = Variable<String>(recognizerName.value);
    }
    if (recognizerVersion.present) {
      map['recognizer_version'] = Variable<String>(recognizerVersion.value);
    }
    if (processedAt.present) {
      map['processed_at'] = Variable<DateTime>(processedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OcrResultsCompanion(')
          ..write('id: $id, ')
          ..write('screenshotId: $screenshotId, ')
          ..write('rawText: $rawText, ')
          ..write('correctedText: $correctedText, ')
          ..write('textBlocksJson: $textBlocksJson, ')
          ..write('recognizerName: $recognizerName, ')
          ..write('recognizerVersion: $recognizerVersion, ')
          ..write('processedAt: $processedAt')
          ..write(')'))
        .toString();
  }
}

class $ExtractedEntitiesTable extends ExtractedEntities
    with TableInfo<$ExtractedEntitiesTable, ExtractedEntityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExtractedEntitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _screenshotIdMeta = const VerificationMeta(
    'screenshotId',
  );
  @override
  late final GeneratedColumn<int> screenshotId = GeneratedColumn<int>(
    'screenshot_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES screenshots (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<EntityType, String> entityType =
      GeneratedColumn<String>(
        'entity_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<EntityType>($ExtractedEntitiesTable.$converterentityType);
  static const VerificationMeta _rawValueMeta = const VerificationMeta(
    'rawValue',
  );
  @override
  late final GeneratedColumn<String> rawValue = GeneratedColumn<String>(
    'raw_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedValueMeta = const VerificationMeta(
    'normalizedValue',
  );
  @override
  late final GeneratedColumn<String> normalizedValue = GeneratedColumn<String>(
    'normalized_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ValidationStatus, String>
  validationStatus =
      GeneratedColumn<String>(
        'validation_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ValidationStatus>(
        $ExtractedEntitiesTable.$convertervalidationStatus,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    screenshotId,
    entityType,
    rawValue,
    normalizedValue,
    metadataJson,
    validationStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'extracted_entities';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExtractedEntityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('screenshot_id')) {
      context.handle(
        _screenshotIdMeta,
        screenshotId.isAcceptableOrUnknown(
          data['screenshot_id']!,
          _screenshotIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_screenshotIdMeta);
    }
    if (data.containsKey('raw_value')) {
      context.handle(
        _rawValueMeta,
        rawValue.isAcceptableOrUnknown(data['raw_value']!, _rawValueMeta),
      );
    } else if (isInserting) {
      context.missing(_rawValueMeta);
    }
    if (data.containsKey('normalized_value')) {
      context.handle(
        _normalizedValueMeta,
        normalizedValue.isAcceptableOrUnknown(
          data['normalized_value']!,
          _normalizedValueMeta,
        ),
      );
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExtractedEntityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExtractedEntityRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      screenshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}screenshot_id'],
      )!,
      entityType: $ExtractedEntitiesTable.$converterentityType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}entity_type'],
        )!,
      ),
      rawValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_value'],
      )!,
      normalizedValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_value'],
      ),
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      ),
      validationStatus: $ExtractedEntitiesTable.$convertervalidationStatus
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}validation_status'],
            )!,
          ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ExtractedEntitiesTable createAlias(String alias) {
    return $ExtractedEntitiesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EntityType, String, String> $converterentityType =
      const EnumNameConverter<EntityType>(EntityType.values);
  static JsonTypeConverter2<ValidationStatus, String, String>
  $convertervalidationStatus = const EnumNameConverter<ValidationStatus>(
    ValidationStatus.values,
  );
}

class ExtractedEntityRow extends DataClass
    implements Insertable<ExtractedEntityRow> {
  final int id;
  final int screenshotId;
  final EntityType entityType;
  final String rawValue;
  final String? normalizedValue;
  final String? metadataJson;
  final ValidationStatus validationStatus;
  final DateTime createdAt;
  const ExtractedEntityRow({
    required this.id,
    required this.screenshotId,
    required this.entityType,
    required this.rawValue,
    this.normalizedValue,
    this.metadataJson,
    required this.validationStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['screenshot_id'] = Variable<int>(screenshotId);
    {
      map['entity_type'] = Variable<String>(
        $ExtractedEntitiesTable.$converterentityType.toSql(entityType),
      );
    }
    map['raw_value'] = Variable<String>(rawValue);
    if (!nullToAbsent || normalizedValue != null) {
      map['normalized_value'] = Variable<String>(normalizedValue);
    }
    if (!nullToAbsent || metadataJson != null) {
      map['metadata_json'] = Variable<String>(metadataJson);
    }
    {
      map['validation_status'] = Variable<String>(
        $ExtractedEntitiesTable.$convertervalidationStatus.toSql(
          validationStatus,
        ),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExtractedEntitiesCompanion toCompanion(bool nullToAbsent) {
    return ExtractedEntitiesCompanion(
      id: Value(id),
      screenshotId: Value(screenshotId),
      entityType: Value(entityType),
      rawValue: Value(rawValue),
      normalizedValue: normalizedValue == null && nullToAbsent
          ? const Value.absent()
          : Value(normalizedValue),
      metadataJson: metadataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataJson),
      validationStatus: Value(validationStatus),
      createdAt: Value(createdAt),
    );
  }

  factory ExtractedEntityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExtractedEntityRow(
      id: serializer.fromJson<int>(json['id']),
      screenshotId: serializer.fromJson<int>(json['screenshotId']),
      entityType: $ExtractedEntitiesTable.$converterentityType.fromJson(
        serializer.fromJson<String>(json['entityType']),
      ),
      rawValue: serializer.fromJson<String>(json['rawValue']),
      normalizedValue: serializer.fromJson<String?>(json['normalizedValue']),
      metadataJson: serializer.fromJson<String?>(json['metadataJson']),
      validationStatus: $ExtractedEntitiesTable.$convertervalidationStatus
          .fromJson(serializer.fromJson<String>(json['validationStatus'])),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'screenshotId': serializer.toJson<int>(screenshotId),
      'entityType': serializer.toJson<String>(
        $ExtractedEntitiesTable.$converterentityType.toJson(entityType),
      ),
      'rawValue': serializer.toJson<String>(rawValue),
      'normalizedValue': serializer.toJson<String?>(normalizedValue),
      'metadataJson': serializer.toJson<String?>(metadataJson),
      'validationStatus': serializer.toJson<String>(
        $ExtractedEntitiesTable.$convertervalidationStatus.toJson(
          validationStatus,
        ),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ExtractedEntityRow copyWith({
    int? id,
    int? screenshotId,
    EntityType? entityType,
    String? rawValue,
    Value<String?> normalizedValue = const Value.absent(),
    Value<String?> metadataJson = const Value.absent(),
    ValidationStatus? validationStatus,
    DateTime? createdAt,
  }) => ExtractedEntityRow(
    id: id ?? this.id,
    screenshotId: screenshotId ?? this.screenshotId,
    entityType: entityType ?? this.entityType,
    rawValue: rawValue ?? this.rawValue,
    normalizedValue: normalizedValue.present
        ? normalizedValue.value
        : this.normalizedValue,
    metadataJson: metadataJson.present ? metadataJson.value : this.metadataJson,
    validationStatus: validationStatus ?? this.validationStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  ExtractedEntityRow copyWithCompanion(ExtractedEntitiesCompanion data) {
    return ExtractedEntityRow(
      id: data.id.present ? data.id.value : this.id,
      screenshotId: data.screenshotId.present
          ? data.screenshotId.value
          : this.screenshotId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      rawValue: data.rawValue.present ? data.rawValue.value : this.rawValue,
      normalizedValue: data.normalizedValue.present
          ? data.normalizedValue.value
          : this.normalizedValue,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      validationStatus: data.validationStatus.present
          ? data.validationStatus.value
          : this.validationStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExtractedEntityRow(')
          ..write('id: $id, ')
          ..write('screenshotId: $screenshotId, ')
          ..write('entityType: $entityType, ')
          ..write('rawValue: $rawValue, ')
          ..write('normalizedValue: $normalizedValue, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('validationStatus: $validationStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    screenshotId,
    entityType,
    rawValue,
    normalizedValue,
    metadataJson,
    validationStatus,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExtractedEntityRow &&
          other.id == this.id &&
          other.screenshotId == this.screenshotId &&
          other.entityType == this.entityType &&
          other.rawValue == this.rawValue &&
          other.normalizedValue == this.normalizedValue &&
          other.metadataJson == this.metadataJson &&
          other.validationStatus == this.validationStatus &&
          other.createdAt == this.createdAt);
}

class ExtractedEntitiesCompanion extends UpdateCompanion<ExtractedEntityRow> {
  final Value<int> id;
  final Value<int> screenshotId;
  final Value<EntityType> entityType;
  final Value<String> rawValue;
  final Value<String?> normalizedValue;
  final Value<String?> metadataJson;
  final Value<ValidationStatus> validationStatus;
  final Value<DateTime> createdAt;
  const ExtractedEntitiesCompanion({
    this.id = const Value.absent(),
    this.screenshotId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.rawValue = const Value.absent(),
    this.normalizedValue = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.validationStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ExtractedEntitiesCompanion.insert({
    this.id = const Value.absent(),
    required int screenshotId,
    required EntityType entityType,
    required String rawValue,
    this.normalizedValue = const Value.absent(),
    this.metadataJson = const Value.absent(),
    required ValidationStatus validationStatus,
    this.createdAt = const Value.absent(),
  }) : screenshotId = Value(screenshotId),
       entityType = Value(entityType),
       rawValue = Value(rawValue),
       validationStatus = Value(validationStatus);
  static Insertable<ExtractedEntityRow> custom({
    Expression<int>? id,
    Expression<int>? screenshotId,
    Expression<String>? entityType,
    Expression<String>? rawValue,
    Expression<String>? normalizedValue,
    Expression<String>? metadataJson,
    Expression<String>? validationStatus,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (screenshotId != null) 'screenshot_id': screenshotId,
      if (entityType != null) 'entity_type': entityType,
      if (rawValue != null) 'raw_value': rawValue,
      if (normalizedValue != null) 'normalized_value': normalizedValue,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (validationStatus != null) 'validation_status': validationStatus,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ExtractedEntitiesCompanion copyWith({
    Value<int>? id,
    Value<int>? screenshotId,
    Value<EntityType>? entityType,
    Value<String>? rawValue,
    Value<String?>? normalizedValue,
    Value<String?>? metadataJson,
    Value<ValidationStatus>? validationStatus,
    Value<DateTime>? createdAt,
  }) {
    return ExtractedEntitiesCompanion(
      id: id ?? this.id,
      screenshotId: screenshotId ?? this.screenshotId,
      entityType: entityType ?? this.entityType,
      rawValue: rawValue ?? this.rawValue,
      normalizedValue: normalizedValue ?? this.normalizedValue,
      metadataJson: metadataJson ?? this.metadataJson,
      validationStatus: validationStatus ?? this.validationStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (screenshotId.present) {
      map['screenshot_id'] = Variable<int>(screenshotId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(
        $ExtractedEntitiesTable.$converterentityType.toSql(entityType.value),
      );
    }
    if (rawValue.present) {
      map['raw_value'] = Variable<String>(rawValue.value);
    }
    if (normalizedValue.present) {
      map['normalized_value'] = Variable<String>(normalizedValue.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (validationStatus.present) {
      map['validation_status'] = Variable<String>(
        $ExtractedEntitiesTable.$convertervalidationStatus.toSql(
          validationStatus.value,
        ),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExtractedEntitiesCompanion(')
          ..write('id: $id, ')
          ..write('screenshotId: $screenshotId, ')
          ..write('entityType: $entityType, ')
          ..write('rawValue: $rawValue, ')
          ..write('normalizedValue: $normalizedValue, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('validationStatus: $validationStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, CollectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    icon,
    color,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CollectionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class CollectionRow extends DataClass implements Insertable<CollectionRow> {
  final int id;
  final String name;
  final String? description;
  final String icon;
  final int color;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CollectionRow({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<int>(color);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      icon: Value(icon),
      color: Value(color),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CollectionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<int>(json['color']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<int>(color),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CollectionRow copyWith({
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    String? icon,
    int? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CollectionRow(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CollectionRow copyWithCompanion(CollectionsCompanion data) {
    return CollectionRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, icon, color, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CollectionsCompanion extends UpdateCompanion<CollectionRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> icon;
  final Value<int> color;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CollectionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    required String icon,
    required int color,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       icon = Value(icon),
       color = Value(color);
  static Insertable<CollectionRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? icon,
    Expression<int>? color,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CollectionsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? icon,
    Value<int>? color,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return CollectionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CollectionItemsTable extends CollectionItems
    with TableInfo<$CollectionItemsTable, CollectionItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<int> collectionId = GeneratedColumn<int>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collections (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _screenshotIdMeta = const VerificationMeta(
    'screenshotId',
  );
  @override
  late final GeneratedColumn<int> screenshotId = GeneratedColumn<int>(
    'screenshot_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES screenshots (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [collectionId, screenshotId, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collection_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('screenshot_id')) {
      context.handle(
        _screenshotIdMeta,
        screenshotId.isAcceptableOrUnknown(
          data['screenshot_id']!,
          _screenshotIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_screenshotIdMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {collectionId, screenshotId};
  @override
  CollectionItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionItemRow(
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}collection_id'],
      )!,
      screenshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}screenshot_id'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $CollectionItemsTable createAlias(String alias) {
    return $CollectionItemsTable(attachedDatabase, alias);
  }
}

class CollectionItemRow extends DataClass
    implements Insertable<CollectionItemRow> {
  final int collectionId;
  final int screenshotId;
  final DateTime addedAt;
  const CollectionItemRow({
    required this.collectionId,
    required this.screenshotId,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['collection_id'] = Variable<int>(collectionId);
    map['screenshot_id'] = Variable<int>(screenshotId);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  CollectionItemsCompanion toCompanion(bool nullToAbsent) {
    return CollectionItemsCompanion(
      collectionId: Value(collectionId),
      screenshotId: Value(screenshotId),
      addedAt: Value(addedAt),
    );
  }

  factory CollectionItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionItemRow(
      collectionId: serializer.fromJson<int>(json['collectionId']),
      screenshotId: serializer.fromJson<int>(json['screenshotId']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'collectionId': serializer.toJson<int>(collectionId),
      'screenshotId': serializer.toJson<int>(screenshotId),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  CollectionItemRow copyWith({
    int? collectionId,
    int? screenshotId,
    DateTime? addedAt,
  }) => CollectionItemRow(
    collectionId: collectionId ?? this.collectionId,
    screenshotId: screenshotId ?? this.screenshotId,
    addedAt: addedAt ?? this.addedAt,
  );
  CollectionItemRow copyWithCompanion(CollectionItemsCompanion data) {
    return CollectionItemRow(
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      screenshotId: data.screenshotId.present
          ? data.screenshotId.value
          : this.screenshotId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionItemRow(')
          ..write('collectionId: $collectionId, ')
          ..write('screenshotId: $screenshotId, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(collectionId, screenshotId, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionItemRow &&
          other.collectionId == this.collectionId &&
          other.screenshotId == this.screenshotId &&
          other.addedAt == this.addedAt);
}

class CollectionItemsCompanion extends UpdateCompanion<CollectionItemRow> {
  final Value<int> collectionId;
  final Value<int> screenshotId;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const CollectionItemsCompanion({
    this.collectionId = const Value.absent(),
    this.screenshotId = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionItemsCompanion.insert({
    required int collectionId,
    required int screenshotId,
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : collectionId = Value(collectionId),
       screenshotId = Value(screenshotId);
  static Insertable<CollectionItemRow> custom({
    Expression<int>? collectionId,
    Expression<int>? screenshotId,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (collectionId != null) 'collection_id': collectionId,
      if (screenshotId != null) 'screenshot_id': screenshotId,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionItemsCompanion copyWith({
    Value<int>? collectionId,
    Value<int>? screenshotId,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return CollectionItemsCompanion(
      collectionId: collectionId ?? this.collectionId,
      screenshotId: screenshotId ?? this.screenshotId,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (collectionId.present) {
      map['collection_id'] = Variable<int>(collectionId.value);
    }
    if (screenshotId.present) {
      map['screenshot_id'] = Variable<int>(screenshotId.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionItemsCompanion(')
          ..write('collectionId: $collectionId, ')
          ..write('screenshotId: $screenshotId, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, TagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class TagRow extends DataClass implements Insertable<TagRow> {
  final int id;
  final String name;
  final DateTime createdAt;
  const TagRow({required this.id, required this.name, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory TagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TagRow copyWith({int? id, String? name, DateTime? createdAt}) => TagRow(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
  TagRow copyWithCompanion(TagsCompanion data) {
    return TagRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class TagsCompanion extends UpdateCompanion<TagRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<TagRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TagsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ScreenshotTagsTable extends ScreenshotTags
    with TableInfo<$ScreenshotTagsTable, ScreenshotTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScreenshotTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _screenshotIdMeta = const VerificationMeta(
    'screenshotId',
  );
  @override
  late final GeneratedColumn<int> screenshotId = GeneratedColumn<int>(
    'screenshot_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES screenshots (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [screenshotId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'screenshot_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScreenshotTagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('screenshot_id')) {
      context.handle(
        _screenshotIdMeta,
        screenshotId.isAcceptableOrUnknown(
          data['screenshot_id']!,
          _screenshotIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_screenshotIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {screenshotId, tagId};
  @override
  ScreenshotTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScreenshotTagRow(
      screenshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}screenshot_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $ScreenshotTagsTable createAlias(String alias) {
    return $ScreenshotTagsTable(attachedDatabase, alias);
  }
}

class ScreenshotTagRow extends DataClass
    implements Insertable<ScreenshotTagRow> {
  final int screenshotId;
  final int tagId;
  const ScreenshotTagRow({required this.screenshotId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['screenshot_id'] = Variable<int>(screenshotId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  ScreenshotTagsCompanion toCompanion(bool nullToAbsent) {
    return ScreenshotTagsCompanion(
      screenshotId: Value(screenshotId),
      tagId: Value(tagId),
    );
  }

  factory ScreenshotTagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScreenshotTagRow(
      screenshotId: serializer.fromJson<int>(json['screenshotId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'screenshotId': serializer.toJson<int>(screenshotId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  ScreenshotTagRow copyWith({int? screenshotId, int? tagId}) =>
      ScreenshotTagRow(
        screenshotId: screenshotId ?? this.screenshotId,
        tagId: tagId ?? this.tagId,
      );
  ScreenshotTagRow copyWithCompanion(ScreenshotTagsCompanion data) {
    return ScreenshotTagRow(
      screenshotId: data.screenshotId.present
          ? data.screenshotId.value
          : this.screenshotId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScreenshotTagRow(')
          ..write('screenshotId: $screenshotId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(screenshotId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScreenshotTagRow &&
          other.screenshotId == this.screenshotId &&
          other.tagId == this.tagId);
}

class ScreenshotTagsCompanion extends UpdateCompanion<ScreenshotTagRow> {
  final Value<int> screenshotId;
  final Value<int> tagId;
  final Value<int> rowid;
  const ScreenshotTagsCompanion({
    this.screenshotId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScreenshotTagsCompanion.insert({
    required int screenshotId,
    required int tagId,
    this.rowid = const Value.absent(),
  }) : screenshotId = Value(screenshotId),
       tagId = Value(tagId);
  static Insertable<ScreenshotTagRow> custom({
    Expression<int>? screenshotId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (screenshotId != null) 'screenshot_id': screenshotId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScreenshotTagsCompanion copyWith({
    Value<int>? screenshotId,
    Value<int>? tagId,
    Value<int>? rowid,
  }) {
    return ScreenshotTagsCompanion(
      screenshotId: screenshotId ?? this.screenshotId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (screenshotId.present) {
      map['screenshot_id'] = Variable<int>(screenshotId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScreenshotTagsCompanion(')
          ..write('screenshotId: $screenshotId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, NoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _screenshotIdMeta = const VerificationMeta(
    'screenshotId',
  );
  @override
  late final GeneratedColumn<int> screenshotId = GeneratedColumn<int>(
    'screenshot_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES screenshots (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    screenshotId,
    content,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('screenshot_id')) {
      context.handle(
        _screenshotIdMeta,
        screenshotId.isAcceptableOrUnknown(
          data['screenshot_id']!,
          _screenshotIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_screenshotIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      screenshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}screenshot_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class NoteRow extends DataClass implements Insertable<NoteRow> {
  final int id;
  final int screenshotId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  const NoteRow({
    required this.id,
    required this.screenshotId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['screenshot_id'] = Variable<int>(screenshotId);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      screenshotId: Value(screenshotId),
      content: Value(content),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory NoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteRow(
      id: serializer.fromJson<int>(json['id']),
      screenshotId: serializer.fromJson<int>(json['screenshotId']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'screenshotId': serializer.toJson<int>(screenshotId),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  NoteRow copyWith({
    int? id,
    int? screenshotId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => NoteRow(
    id: id ?? this.id,
    screenshotId: screenshotId ?? this.screenshotId,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  NoteRow copyWithCompanion(NotesCompanion data) {
    return NoteRow(
      id: data.id.present ? data.id.value : this.id,
      screenshotId: data.screenshotId.present
          ? data.screenshotId.value
          : this.screenshotId,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteRow(')
          ..write('id: $id, ')
          ..write('screenshotId: $screenshotId, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, screenshotId, content, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteRow &&
          other.id == this.id &&
          other.screenshotId == this.screenshotId &&
          other.content == this.content &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NotesCompanion extends UpdateCompanion<NoteRow> {
  final Value<int> id;
  final Value<int> screenshotId;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.screenshotId = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  NotesCompanion.insert({
    this.id = const Value.absent(),
    required int screenshotId,
    required String content,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : screenshotId = Value(screenshotId),
       content = Value(content);
  static Insertable<NoteRow> custom({
    Expression<int>? id,
    Expression<int>? screenshotId,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (screenshotId != null) 'screenshot_id': screenshotId,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  NotesCompanion copyWith({
    Value<int>? id,
    Value<int>? screenshotId,
    Value<String>? content,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      screenshotId: screenshotId ?? this.screenshotId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (screenshotId.present) {
      map['screenshot_id'] = Variable<int>(screenshotId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('screenshotId: $screenshotId, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, ReminderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _screenshotIdMeta = const VerificationMeta(
    'screenshotId',
  );
  @override
  late final GeneratedColumn<int> screenshotId = GeneratedColumn<int>(
    'screenshot_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES screenshots (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notificationIdMeta = const VerificationMeta(
    'notificationId',
  );
  @override
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
    'notification_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _notifyMeta = const VerificationMeta('notify');
  @override
  late final GeneratedColumn<bool> notify = GeneratedColumn<bool>(
    'notify',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notify" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  late final GeneratedColumnWithTypeConverter<RepeatRule, String> repeatRule =
      GeneratedColumn<String>(
        'repeat_rule',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(RepeatRule.none.name),
      ).withConverter<RepeatRule>($RemindersTable.$converterrepeatRule);
  @override
  late final GeneratedColumnWithTypeConverter<ReminderStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ReminderStatus>($RemindersTable.$converterstatus);
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    screenshotId,
    title,
    description,
    scheduledAt,
    timezone,
    notificationId,
    notify,
    repeatRule,
    status,
    completedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('screenshot_id')) {
      context.handle(
        _screenshotIdMeta,
        screenshotId.isAcceptableOrUnknown(
          data['screenshot_id']!,
          _screenshotIdMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    } else if (isInserting) {
      context.missing(_timezoneMeta);
    }
    if (data.containsKey('notification_id')) {
      context.handle(
        _notificationIdMeta,
        notificationId.isAcceptableOrUnknown(
          data['notification_id']!,
          _notificationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_notificationIdMeta);
    }
    if (data.containsKey('notify')) {
      context.handle(
        _notifyMeta,
        notify.isAcceptableOrUnknown(data['notify']!, _notifyMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      screenshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}screenshot_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      notificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_id'],
      )!,
      notify: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notify'],
      )!,
      repeatRule: $RemindersTable.$converterrepeatRule.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}repeat_rule'],
        )!,
      ),
      status: $RemindersTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RepeatRule, String, String> $converterrepeatRule =
      const EnumNameConverter<RepeatRule>(RepeatRule.values);
  static JsonTypeConverter2<ReminderStatus, String, String> $converterstatus =
      const EnumNameConverter<ReminderStatus>(ReminderStatus.values);
}

class ReminderRow extends DataClass implements Insertable<ReminderRow> {
  final int id;
  final int? screenshotId;
  final String title;
  final String? description;
  final DateTime scheduledAt;
  final String timezone;
  final int notificationId;
  final bool notify;
  final RepeatRule repeatRule;
  final ReminderStatus status;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ReminderRow({
    required this.id,
    this.screenshotId,
    required this.title,
    this.description,
    required this.scheduledAt,
    required this.timezone,
    required this.notificationId,
    required this.notify,
    required this.repeatRule,
    required this.status,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || screenshotId != null) {
      map['screenshot_id'] = Variable<int>(screenshotId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    map['timezone'] = Variable<String>(timezone);
    map['notification_id'] = Variable<int>(notificationId);
    map['notify'] = Variable<bool>(notify);
    {
      map['repeat_rule'] = Variable<String>(
        $RemindersTable.$converterrepeatRule.toSql(repeatRule),
      );
    }
    {
      map['status'] = Variable<String>(
        $RemindersTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      screenshotId: screenshotId == null && nullToAbsent
          ? const Value.absent()
          : Value(screenshotId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      scheduledAt: Value(scheduledAt),
      timezone: Value(timezone),
      notificationId: Value(notificationId),
      notify: Value(notify),
      repeatRule: Value(repeatRule),
      status: Value(status),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReminderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRow(
      id: serializer.fromJson<int>(json['id']),
      screenshotId: serializer.fromJson<int?>(json['screenshotId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      timezone: serializer.fromJson<String>(json['timezone']),
      notificationId: serializer.fromJson<int>(json['notificationId']),
      notify: serializer.fromJson<bool>(json['notify']),
      repeatRule: $RemindersTable.$converterrepeatRule.fromJson(
        serializer.fromJson<String>(json['repeatRule']),
      ),
      status: $RemindersTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'screenshotId': serializer.toJson<int?>(screenshotId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'timezone': serializer.toJson<String>(timezone),
      'notificationId': serializer.toJson<int>(notificationId),
      'notify': serializer.toJson<bool>(notify),
      'repeatRule': serializer.toJson<String>(
        $RemindersTable.$converterrepeatRule.toJson(repeatRule),
      ),
      'status': serializer.toJson<String>(
        $RemindersTable.$converterstatus.toJson(status),
      ),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReminderRow copyWith({
    int? id,
    Value<int?> screenshotId = const Value.absent(),
    String? title,
    Value<String?> description = const Value.absent(),
    DateTime? scheduledAt,
    String? timezone,
    int? notificationId,
    bool? notify,
    RepeatRule? repeatRule,
    ReminderStatus? status,
    Value<DateTime?> completedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ReminderRow(
    id: id ?? this.id,
    screenshotId: screenshotId.present ? screenshotId.value : this.screenshotId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    timezone: timezone ?? this.timezone,
    notificationId: notificationId ?? this.notificationId,
    notify: notify ?? this.notify,
    repeatRule: repeatRule ?? this.repeatRule,
    status: status ?? this.status,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReminderRow copyWithCompanion(RemindersCompanion data) {
    return ReminderRow(
      id: data.id.present ? data.id.value : this.id,
      screenshotId: data.screenshotId.present
          ? data.screenshotId.value
          : this.screenshotId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
      notify: data.notify.present ? data.notify.value : this.notify,
      repeatRule: data.repeatRule.present
          ? data.repeatRule.value
          : this.repeatRule,
      status: data.status.present ? data.status.value : this.status,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRow(')
          ..write('id: $id, ')
          ..write('screenshotId: $screenshotId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('timezone: $timezone, ')
          ..write('notificationId: $notificationId, ')
          ..write('notify: $notify, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    screenshotId,
    title,
    description,
    scheduledAt,
    timezone,
    notificationId,
    notify,
    repeatRule,
    status,
    completedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRow &&
          other.id == this.id &&
          other.screenshotId == this.screenshotId &&
          other.title == this.title &&
          other.description == this.description &&
          other.scheduledAt == this.scheduledAt &&
          other.timezone == this.timezone &&
          other.notificationId == this.notificationId &&
          other.notify == this.notify &&
          other.repeatRule == this.repeatRule &&
          other.status == this.status &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RemindersCompanion extends UpdateCompanion<ReminderRow> {
  final Value<int> id;
  final Value<int?> screenshotId;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> scheduledAt;
  final Value<String> timezone;
  final Value<int> notificationId;
  final Value<bool> notify;
  final Value<RepeatRule> repeatRule;
  final Value<ReminderStatus> status;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.screenshotId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.timezone = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.notify = const Value.absent(),
    this.repeatRule = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.id = const Value.absent(),
    this.screenshotId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required DateTime scheduledAt,
    required String timezone,
    required int notificationId,
    this.notify = const Value.absent(),
    this.repeatRule = const Value.absent(),
    required ReminderStatus status,
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : title = Value(title),
       scheduledAt = Value(scheduledAt),
       timezone = Value(timezone),
       notificationId = Value(notificationId),
       status = Value(status);
  static Insertable<ReminderRow> custom({
    Expression<int>? id,
    Expression<int>? screenshotId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? scheduledAt,
    Expression<String>? timezone,
    Expression<int>? notificationId,
    Expression<bool>? notify,
    Expression<String>? repeatRule,
    Expression<String>? status,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (screenshotId != null) 'screenshot_id': screenshotId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (timezone != null) 'timezone': timezone,
      if (notificationId != null) 'notification_id': notificationId,
      if (notify != null) 'notify': notify,
      if (repeatRule != null) 'repeat_rule': repeatRule,
      if (status != null) 'status': status,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  RemindersCompanion copyWith({
    Value<int>? id,
    Value<int?>? screenshotId,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime>? scheduledAt,
    Value<String>? timezone,
    Value<int>? notificationId,
    Value<bool>? notify,
    Value<RepeatRule>? repeatRule,
    Value<ReminderStatus>? status,
    Value<DateTime?>? completedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      screenshotId: screenshotId ?? this.screenshotId,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      timezone: timezone ?? this.timezone,
      notificationId: notificationId ?? this.notificationId,
      notify: notify ?? this.notify,
      repeatRule: repeatRule ?? this.repeatRule,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (screenshotId.present) {
      map['screenshot_id'] = Variable<int>(screenshotId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
    }
    if (notify.present) {
      map['notify'] = Variable<bool>(notify.value);
    }
    if (repeatRule.present) {
      map['repeat_rule'] = Variable<String>(
        $RemindersTable.$converterrepeatRule.toSql(repeatRule.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $RemindersTable.$converterstatus.toSql(status.value),
      );
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('screenshotId: $screenshotId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('timezone: $timezone, ')
          ..write('notificationId: $notificationId, ')
          ..write('notify: $notify, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SuggestedActionsTable extends SuggestedActions
    with TableInfo<$SuggestedActionsTable, SuggestedActionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuggestedActionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _screenshotIdMeta = const VerificationMeta(
    'screenshotId',
  );
  @override
  late final GeneratedColumn<int> screenshotId = GeneratedColumn<int>(
    'screenshot_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES screenshots (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ActionType, String> actionType =
      GeneratedColumn<String>(
        'action_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ActionType>($SuggestedActionsTable.$converteractionType);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ActionStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ActionStatus>($SuggestedActionsTable.$converterstatus);
  static const VerificationMeta _postponedUntilMeta = const VerificationMeta(
    'postponedUntil',
  );
  @override
  late final GeneratedColumn<DateTime> postponedUntil =
      GeneratedColumn<DateTime>(
        'postponed_until',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    screenshotId,
    actionType,
    title,
    payloadJson,
    status,
    postponedUntil,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suggested_actions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SuggestedActionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('screenshot_id')) {
      context.handle(
        _screenshotIdMeta,
        screenshotId.isAcceptableOrUnknown(
          data['screenshot_id']!,
          _screenshotIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_screenshotIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('postponed_until')) {
      context.handle(
        _postponedUntilMeta,
        postponedUntil.isAcceptableOrUnknown(
          data['postponed_until']!,
          _postponedUntilMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SuggestedActionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SuggestedActionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      screenshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}screenshot_id'],
      )!,
      actionType: $SuggestedActionsTable.$converteractionType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}action_type'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      status: $SuggestedActionsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      postponedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}postponed_until'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SuggestedActionsTable createAlias(String alias) {
    return $SuggestedActionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ActionType, String, String> $converteractionType =
      const EnumNameConverter<ActionType>(ActionType.values);
  static JsonTypeConverter2<ActionStatus, String, String> $converterstatus =
      const EnumNameConverter<ActionStatus>(ActionStatus.values);
}

class SuggestedActionRow extends DataClass
    implements Insertable<SuggestedActionRow> {
  final int id;
  final int screenshotId;
  final ActionType actionType;
  final String title;
  final String payloadJson;
  final ActionStatus status;
  final DateTime? postponedUntil;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SuggestedActionRow({
    required this.id,
    required this.screenshotId,
    required this.actionType,
    required this.title,
    required this.payloadJson,
    required this.status,
    this.postponedUntil,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['screenshot_id'] = Variable<int>(screenshotId);
    {
      map['action_type'] = Variable<String>(
        $SuggestedActionsTable.$converteractionType.toSql(actionType),
      );
    }
    map['title'] = Variable<String>(title);
    map['payload_json'] = Variable<String>(payloadJson);
    {
      map['status'] = Variable<String>(
        $SuggestedActionsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || postponedUntil != null) {
      map['postponed_until'] = Variable<DateTime>(postponedUntil);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SuggestedActionsCompanion toCompanion(bool nullToAbsent) {
    return SuggestedActionsCompanion(
      id: Value(id),
      screenshotId: Value(screenshotId),
      actionType: Value(actionType),
      title: Value(title),
      payloadJson: Value(payloadJson),
      status: Value(status),
      postponedUntil: postponedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(postponedUntil),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SuggestedActionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SuggestedActionRow(
      id: serializer.fromJson<int>(json['id']),
      screenshotId: serializer.fromJson<int>(json['screenshotId']),
      actionType: $SuggestedActionsTable.$converteractionType.fromJson(
        serializer.fromJson<String>(json['actionType']),
      ),
      title: serializer.fromJson<String>(json['title']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      status: $SuggestedActionsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      postponedUntil: serializer.fromJson<DateTime?>(json['postponedUntil']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'screenshotId': serializer.toJson<int>(screenshotId),
      'actionType': serializer.toJson<String>(
        $SuggestedActionsTable.$converteractionType.toJson(actionType),
      ),
      'title': serializer.toJson<String>(title),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'status': serializer.toJson<String>(
        $SuggestedActionsTable.$converterstatus.toJson(status),
      ),
      'postponedUntil': serializer.toJson<DateTime?>(postponedUntil),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SuggestedActionRow copyWith({
    int? id,
    int? screenshotId,
    ActionType? actionType,
    String? title,
    String? payloadJson,
    ActionStatus? status,
    Value<DateTime?> postponedUntil = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SuggestedActionRow(
    id: id ?? this.id,
    screenshotId: screenshotId ?? this.screenshotId,
    actionType: actionType ?? this.actionType,
    title: title ?? this.title,
    payloadJson: payloadJson ?? this.payloadJson,
    status: status ?? this.status,
    postponedUntil: postponedUntil.present
        ? postponedUntil.value
        : this.postponedUntil,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SuggestedActionRow copyWithCompanion(SuggestedActionsCompanion data) {
    return SuggestedActionRow(
      id: data.id.present ? data.id.value : this.id,
      screenshotId: data.screenshotId.present
          ? data.screenshotId.value
          : this.screenshotId,
      actionType: data.actionType.present
          ? data.actionType.value
          : this.actionType,
      title: data.title.present ? data.title.value : this.title,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      status: data.status.present ? data.status.value : this.status,
      postponedUntil: data.postponedUntil.present
          ? data.postponedUntil.value
          : this.postponedUntil,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SuggestedActionRow(')
          ..write('id: $id, ')
          ..write('screenshotId: $screenshotId, ')
          ..write('actionType: $actionType, ')
          ..write('title: $title, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('postponedUntil: $postponedUntil, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    screenshotId,
    actionType,
    title,
    payloadJson,
    status,
    postponedUntil,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SuggestedActionRow &&
          other.id == this.id &&
          other.screenshotId == this.screenshotId &&
          other.actionType == this.actionType &&
          other.title == this.title &&
          other.payloadJson == this.payloadJson &&
          other.status == this.status &&
          other.postponedUntil == this.postponedUntil &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SuggestedActionsCompanion extends UpdateCompanion<SuggestedActionRow> {
  final Value<int> id;
  final Value<int> screenshotId;
  final Value<ActionType> actionType;
  final Value<String> title;
  final Value<String> payloadJson;
  final Value<ActionStatus> status;
  final Value<DateTime?> postponedUntil;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SuggestedActionsCompanion({
    this.id = const Value.absent(),
    this.screenshotId = const Value.absent(),
    this.actionType = const Value.absent(),
    this.title = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.status = const Value.absent(),
    this.postponedUntil = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SuggestedActionsCompanion.insert({
    this.id = const Value.absent(),
    required int screenshotId,
    required ActionType actionType,
    required String title,
    required String payloadJson,
    required ActionStatus status,
    this.postponedUntil = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : screenshotId = Value(screenshotId),
       actionType = Value(actionType),
       title = Value(title),
       payloadJson = Value(payloadJson),
       status = Value(status);
  static Insertable<SuggestedActionRow> custom({
    Expression<int>? id,
    Expression<int>? screenshotId,
    Expression<String>? actionType,
    Expression<String>? title,
    Expression<String>? payloadJson,
    Expression<String>? status,
    Expression<DateTime>? postponedUntil,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (screenshotId != null) 'screenshot_id': screenshotId,
      if (actionType != null) 'action_type': actionType,
      if (title != null) 'title': title,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (status != null) 'status': status,
      if (postponedUntil != null) 'postponed_until': postponedUntil,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SuggestedActionsCompanion copyWith({
    Value<int>? id,
    Value<int>? screenshotId,
    Value<ActionType>? actionType,
    Value<String>? title,
    Value<String>? payloadJson,
    Value<ActionStatus>? status,
    Value<DateTime?>? postponedUntil,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return SuggestedActionsCompanion(
      id: id ?? this.id,
      screenshotId: screenshotId ?? this.screenshotId,
      actionType: actionType ?? this.actionType,
      title: title ?? this.title,
      payloadJson: payloadJson ?? this.payloadJson,
      status: status ?? this.status,
      postponedUntil: postponedUntil ?? this.postponedUntil,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (screenshotId.present) {
      map['screenshot_id'] = Variable<int>(screenshotId.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(
        $SuggestedActionsTable.$converteractionType.toSql(actionType.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $SuggestedActionsTable.$converterstatus.toSql(status.value),
      );
    }
    if (postponedUntil.present) {
      map['postponed_until'] = Variable<DateTime>(postponedUntil.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuggestedActionsCompanion(')
          ..write('id: $id, ')
          ..write('screenshotId: $screenshotId, ')
          ..write('actionType: $actionType, ')
          ..write('title: $title, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('postponedUntil: $postponedUntil, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $WishlistItemsTable extends WishlistItems
    with TableInfo<$WishlistItemsTable, WishlistItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WishlistItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _screenshotIdMeta = const VerificationMeta(
    'screenshotId',
  );
  @override
  late final GeneratedColumn<int> screenshotId = GeneratedColumn<int>(
    'screenshot_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES screenshots (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMinorUnitsMeta = const VerificationMeta(
    'amountMinorUnits',
  );
  @override
  late final GeneratedColumn<int> amountMinorUnits = GeneratedColumn<int>(
    'amount_minor_units',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _merchantNameMeta = const VerificationMeta(
    'merchantName',
  );
  @override
  late final GeneratedColumn<String> merchantName = GeneratedColumn<String>(
    'merchant_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productUrlMeta = const VerificationMeta(
    'productUrl',
  );
  @override
  late final GeneratedColumn<String> productUrl = GeneratedColumn<String>(
    'product_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchasedMeta = const VerificationMeta(
    'purchased',
  );
  @override
  late final GeneratedColumn<bool> purchased = GeneratedColumn<bool>(
    'purchased',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("purchased" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    screenshotId,
    productName,
    amountMinorUnits,
    currency,
    merchantName,
    productUrl,
    notes,
    purchased,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wishlist_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<WishlistItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('screenshot_id')) {
      context.handle(
        _screenshotIdMeta,
        screenshotId.isAcceptableOrUnknown(
          data['screenshot_id']!,
          _screenshotIdMeta,
        ),
      );
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    }
    if (data.containsKey('amount_minor_units')) {
      context.handle(
        _amountMinorUnitsMeta,
        amountMinorUnits.isAcceptableOrUnknown(
          data['amount_minor_units']!,
          _amountMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('merchant_name')) {
      context.handle(
        _merchantNameMeta,
        merchantName.isAcceptableOrUnknown(
          data['merchant_name']!,
          _merchantNameMeta,
        ),
      );
    }
    if (data.containsKey('product_url')) {
      context.handle(
        _productUrlMeta,
        productUrl.isAcceptableOrUnknown(data['product_url']!, _productUrlMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('purchased')) {
      context.handle(
        _purchasedMeta,
        purchased.isAcceptableOrUnknown(data['purchased']!, _purchasedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WishlistItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WishlistItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      screenshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}screenshot_id'],
      ),
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      ),
      amountMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor_units'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      ),
      merchantName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant_name'],
      ),
      productUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_url'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      purchased: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}purchased'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WishlistItemsTable createAlias(String alias) {
    return $WishlistItemsTable(attachedDatabase, alias);
  }
}

class WishlistItemRow extends DataClass implements Insertable<WishlistItemRow> {
  final int id;
  final int? screenshotId;
  final String? productName;

  /// Price in minor units (cents) to avoid floating-point errors.
  final int? amountMinorUnits;
  final String? currency;
  final String? merchantName;
  final String? productUrl;
  final String? notes;
  final bool purchased;
  final DateTime createdAt;
  const WishlistItemRow({
    required this.id,
    this.screenshotId,
    this.productName,
    this.amountMinorUnits,
    this.currency,
    this.merchantName,
    this.productUrl,
    this.notes,
    required this.purchased,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || screenshotId != null) {
      map['screenshot_id'] = Variable<int>(screenshotId);
    }
    if (!nullToAbsent || productName != null) {
      map['product_name'] = Variable<String>(productName);
    }
    if (!nullToAbsent || amountMinorUnits != null) {
      map['amount_minor_units'] = Variable<int>(amountMinorUnits);
    }
    if (!nullToAbsent || currency != null) {
      map['currency'] = Variable<String>(currency);
    }
    if (!nullToAbsent || merchantName != null) {
      map['merchant_name'] = Variable<String>(merchantName);
    }
    if (!nullToAbsent || productUrl != null) {
      map['product_url'] = Variable<String>(productUrl);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['purchased'] = Variable<bool>(purchased);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WishlistItemsCompanion toCompanion(bool nullToAbsent) {
    return WishlistItemsCompanion(
      id: Value(id),
      screenshotId: screenshotId == null && nullToAbsent
          ? const Value.absent()
          : Value(screenshotId),
      productName: productName == null && nullToAbsent
          ? const Value.absent()
          : Value(productName),
      amountMinorUnits: amountMinorUnits == null && nullToAbsent
          ? const Value.absent()
          : Value(amountMinorUnits),
      currency: currency == null && nullToAbsent
          ? const Value.absent()
          : Value(currency),
      merchantName: merchantName == null && nullToAbsent
          ? const Value.absent()
          : Value(merchantName),
      productUrl: productUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(productUrl),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      purchased: Value(purchased),
      createdAt: Value(createdAt),
    );
  }

  factory WishlistItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WishlistItemRow(
      id: serializer.fromJson<int>(json['id']),
      screenshotId: serializer.fromJson<int?>(json['screenshotId']),
      productName: serializer.fromJson<String?>(json['productName']),
      amountMinorUnits: serializer.fromJson<int?>(json['amountMinorUnits']),
      currency: serializer.fromJson<String?>(json['currency']),
      merchantName: serializer.fromJson<String?>(json['merchantName']),
      productUrl: serializer.fromJson<String?>(json['productUrl']),
      notes: serializer.fromJson<String?>(json['notes']),
      purchased: serializer.fromJson<bool>(json['purchased']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'screenshotId': serializer.toJson<int?>(screenshotId),
      'productName': serializer.toJson<String?>(productName),
      'amountMinorUnits': serializer.toJson<int?>(amountMinorUnits),
      'currency': serializer.toJson<String?>(currency),
      'merchantName': serializer.toJson<String?>(merchantName),
      'productUrl': serializer.toJson<String?>(productUrl),
      'notes': serializer.toJson<String?>(notes),
      'purchased': serializer.toJson<bool>(purchased),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WishlistItemRow copyWith({
    int? id,
    Value<int?> screenshotId = const Value.absent(),
    Value<String?> productName = const Value.absent(),
    Value<int?> amountMinorUnits = const Value.absent(),
    Value<String?> currency = const Value.absent(),
    Value<String?> merchantName = const Value.absent(),
    Value<String?> productUrl = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? purchased,
    DateTime? createdAt,
  }) => WishlistItemRow(
    id: id ?? this.id,
    screenshotId: screenshotId.present ? screenshotId.value : this.screenshotId,
    productName: productName.present ? productName.value : this.productName,
    amountMinorUnits: amountMinorUnits.present
        ? amountMinorUnits.value
        : this.amountMinorUnits,
    currency: currency.present ? currency.value : this.currency,
    merchantName: merchantName.present ? merchantName.value : this.merchantName,
    productUrl: productUrl.present ? productUrl.value : this.productUrl,
    notes: notes.present ? notes.value : this.notes,
    purchased: purchased ?? this.purchased,
    createdAt: createdAt ?? this.createdAt,
  );
  WishlistItemRow copyWithCompanion(WishlistItemsCompanion data) {
    return WishlistItemRow(
      id: data.id.present ? data.id.value : this.id,
      screenshotId: data.screenshotId.present
          ? data.screenshotId.value
          : this.screenshotId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      amountMinorUnits: data.amountMinorUnits.present
          ? data.amountMinorUnits.value
          : this.amountMinorUnits,
      currency: data.currency.present ? data.currency.value : this.currency,
      merchantName: data.merchantName.present
          ? data.merchantName.value
          : this.merchantName,
      productUrl: data.productUrl.present
          ? data.productUrl.value
          : this.productUrl,
      notes: data.notes.present ? data.notes.value : this.notes,
      purchased: data.purchased.present ? data.purchased.value : this.purchased,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WishlistItemRow(')
          ..write('id: $id, ')
          ..write('screenshotId: $screenshotId, ')
          ..write('productName: $productName, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('currency: $currency, ')
          ..write('merchantName: $merchantName, ')
          ..write('productUrl: $productUrl, ')
          ..write('notes: $notes, ')
          ..write('purchased: $purchased, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    screenshotId,
    productName,
    amountMinorUnits,
    currency,
    merchantName,
    productUrl,
    notes,
    purchased,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WishlistItemRow &&
          other.id == this.id &&
          other.screenshotId == this.screenshotId &&
          other.productName == this.productName &&
          other.amountMinorUnits == this.amountMinorUnits &&
          other.currency == this.currency &&
          other.merchantName == this.merchantName &&
          other.productUrl == this.productUrl &&
          other.notes == this.notes &&
          other.purchased == this.purchased &&
          other.createdAt == this.createdAt);
}

class WishlistItemsCompanion extends UpdateCompanion<WishlistItemRow> {
  final Value<int> id;
  final Value<int?> screenshotId;
  final Value<String?> productName;
  final Value<int?> amountMinorUnits;
  final Value<String?> currency;
  final Value<String?> merchantName;
  final Value<String?> productUrl;
  final Value<String?> notes;
  final Value<bool> purchased;
  final Value<DateTime> createdAt;
  const WishlistItemsCompanion({
    this.id = const Value.absent(),
    this.screenshotId = const Value.absent(),
    this.productName = const Value.absent(),
    this.amountMinorUnits = const Value.absent(),
    this.currency = const Value.absent(),
    this.merchantName = const Value.absent(),
    this.productUrl = const Value.absent(),
    this.notes = const Value.absent(),
    this.purchased = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WishlistItemsCompanion.insert({
    this.id = const Value.absent(),
    this.screenshotId = const Value.absent(),
    this.productName = const Value.absent(),
    this.amountMinorUnits = const Value.absent(),
    this.currency = const Value.absent(),
    this.merchantName = const Value.absent(),
    this.productUrl = const Value.absent(),
    this.notes = const Value.absent(),
    this.purchased = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  static Insertable<WishlistItemRow> custom({
    Expression<int>? id,
    Expression<int>? screenshotId,
    Expression<String>? productName,
    Expression<int>? amountMinorUnits,
    Expression<String>? currency,
    Expression<String>? merchantName,
    Expression<String>? productUrl,
    Expression<String>? notes,
    Expression<bool>? purchased,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (screenshotId != null) 'screenshot_id': screenshotId,
      if (productName != null) 'product_name': productName,
      if (amountMinorUnits != null) 'amount_minor_units': amountMinorUnits,
      if (currency != null) 'currency': currency,
      if (merchantName != null) 'merchant_name': merchantName,
      if (productUrl != null) 'product_url': productUrl,
      if (notes != null) 'notes': notes,
      if (purchased != null) 'purchased': purchased,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WishlistItemsCompanion copyWith({
    Value<int>? id,
    Value<int?>? screenshotId,
    Value<String?>? productName,
    Value<int?>? amountMinorUnits,
    Value<String?>? currency,
    Value<String?>? merchantName,
    Value<String?>? productUrl,
    Value<String?>? notes,
    Value<bool>? purchased,
    Value<DateTime>? createdAt,
  }) {
    return WishlistItemsCompanion(
      id: id ?? this.id,
      screenshotId: screenshotId ?? this.screenshotId,
      productName: productName ?? this.productName,
      amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
      currency: currency ?? this.currency,
      merchantName: merchantName ?? this.merchantName,
      productUrl: productUrl ?? this.productUrl,
      notes: notes ?? this.notes,
      purchased: purchased ?? this.purchased,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (screenshotId.present) {
      map['screenshot_id'] = Variable<int>(screenshotId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (amountMinorUnits.present) {
      map['amount_minor_units'] = Variable<int>(amountMinorUnits.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (merchantName.present) {
      map['merchant_name'] = Variable<String>(merchantName.value);
    }
    if (productUrl.present) {
      map['product_url'] = Variable<String>(productUrl.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (purchased.present) {
      map['purchased'] = Variable<bool>(purchased.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WishlistItemsCompanion(')
          ..write('id: $id, ')
          ..write('screenshotId: $screenshotId, ')
          ..write('productName: $productName, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('currency: $currency, ')
          ..write('merchantName: $merchantName, ')
          ..write('productUrl: $productUrl, ')
          ..write('notes: $notes, ')
          ..write('purchased: $purchased, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ProcessingJobsTable extends ProcessingJobs
    with TableInfo<$ProcessingJobsTable, ProcessingJobRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProcessingJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _screenshotIdMeta = const VerificationMeta(
    'screenshotId',
  );
  @override
  late final GeneratedColumn<int> screenshotId = GeneratedColumn<int>(
    'screenshot_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES screenshots (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<JobType, String> jobType =
      GeneratedColumn<String>(
        'job_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<JobType>($ProcessingJobsTable.$converterjobType);
  @override
  late final GeneratedColumnWithTypeConverter<JobStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<JobStatus>($ProcessingJobsTable.$converterstatus);
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
    'progress',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkpointJsonMeta = const VerificationMeta(
    'checkpointJson',
  );
  @override
  late final GeneratedColumn<String> checkpointJson = GeneratedColumn<String>(
    'checkpoint_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    screenshotId,
    jobType,
    status,
    attemptCount,
    errorMessage,
    createdAt,
    updatedAt,
    priority,
    progress,
    checkpointJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'processing_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProcessingJobRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('screenshot_id')) {
      context.handle(
        _screenshotIdMeta,
        screenshotId.isAcceptableOrUnknown(
          data['screenshot_id']!,
          _screenshotIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_screenshotIdMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('checkpoint_json')) {
      context.handle(
        _checkpointJsonMeta,
        checkpointJson.isAcceptableOrUnknown(
          data['checkpoint_json']!,
          _checkpointJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProcessingJobRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProcessingJobRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      screenshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}screenshot_id'],
      )!,
      jobType: $ProcessingJobsTable.$converterjobType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}job_type'],
        )!,
      ),
      status: $ProcessingJobsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress'],
      ),
      checkpointJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checkpoint_json'],
      ),
    );
  }

  @override
  $ProcessingJobsTable createAlias(String alias) {
    return $ProcessingJobsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<JobType, String, String> $converterjobType =
      const EnumNameConverter<JobType>(JobType.values);
  static JsonTypeConverter2<JobStatus, String, String> $converterstatus =
      const EnumNameConverter<JobStatus>(JobStatus.values);
}

class ProcessingJobRow extends DataClass
    implements Insertable<ProcessingJobRow> {
  final int id;
  final int screenshotId;
  final JobType jobType;
  final JobStatus status;
  final int attemptCount;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int priority;
  final double? progress;
  final String? checkpointJson;
  const ProcessingJobRow({
    required this.id,
    required this.screenshotId,
    required this.jobType,
    required this.status,
    required this.attemptCount,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
    required this.priority,
    this.progress,
    this.checkpointJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['screenshot_id'] = Variable<int>(screenshotId);
    {
      map['job_type'] = Variable<String>(
        $ProcessingJobsTable.$converterjobType.toSql(jobType),
      );
    }
    {
      map['status'] = Variable<String>(
        $ProcessingJobsTable.$converterstatus.toSql(status),
      );
    }
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['priority'] = Variable<int>(priority);
    if (!nullToAbsent || progress != null) {
      map['progress'] = Variable<double>(progress);
    }
    if (!nullToAbsent || checkpointJson != null) {
      map['checkpoint_json'] = Variable<String>(checkpointJson);
    }
    return map;
  }

  ProcessingJobsCompanion toCompanion(bool nullToAbsent) {
    return ProcessingJobsCompanion(
      id: Value(id),
      screenshotId: Value(screenshotId),
      jobType: Value(jobType),
      status: Value(status),
      attemptCount: Value(attemptCount),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      priority: Value(priority),
      progress: progress == null && nullToAbsent
          ? const Value.absent()
          : Value(progress),
      checkpointJson: checkpointJson == null && nullToAbsent
          ? const Value.absent()
          : Value(checkpointJson),
    );
  }

  factory ProcessingJobRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProcessingJobRow(
      id: serializer.fromJson<int>(json['id']),
      screenshotId: serializer.fromJson<int>(json['screenshotId']),
      jobType: $ProcessingJobsTable.$converterjobType.fromJson(
        serializer.fromJson<String>(json['jobType']),
      ),
      status: $ProcessingJobsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      priority: serializer.fromJson<int>(json['priority']),
      progress: serializer.fromJson<double?>(json['progress']),
      checkpointJson: serializer.fromJson<String?>(json['checkpointJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'screenshotId': serializer.toJson<int>(screenshotId),
      'jobType': serializer.toJson<String>(
        $ProcessingJobsTable.$converterjobType.toJson(jobType),
      ),
      'status': serializer.toJson<String>(
        $ProcessingJobsTable.$converterstatus.toJson(status),
      ),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'priority': serializer.toJson<int>(priority),
      'progress': serializer.toJson<double?>(progress),
      'checkpointJson': serializer.toJson<String?>(checkpointJson),
    };
  }

  ProcessingJobRow copyWith({
    int? id,
    int? screenshotId,
    JobType? jobType,
    JobStatus? status,
    int? attemptCount,
    Value<String?> errorMessage = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    int? priority,
    Value<double?> progress = const Value.absent(),
    Value<String?> checkpointJson = const Value.absent(),
  }) => ProcessingJobRow(
    id: id ?? this.id,
    screenshotId: screenshotId ?? this.screenshotId,
    jobType: jobType ?? this.jobType,
    status: status ?? this.status,
    attemptCount: attemptCount ?? this.attemptCount,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    priority: priority ?? this.priority,
    progress: progress.present ? progress.value : this.progress,
    checkpointJson: checkpointJson.present
        ? checkpointJson.value
        : this.checkpointJson,
  );
  ProcessingJobRow copyWithCompanion(ProcessingJobsCompanion data) {
    return ProcessingJobRow(
      id: data.id.present ? data.id.value : this.id,
      screenshotId: data.screenshotId.present
          ? data.screenshotId.value
          : this.screenshotId,
      jobType: data.jobType.present ? data.jobType.value : this.jobType,
      status: data.status.present ? data.status.value : this.status,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      priority: data.priority.present ? data.priority.value : this.priority,
      progress: data.progress.present ? data.progress.value : this.progress,
      checkpointJson: data.checkpointJson.present
          ? data.checkpointJson.value
          : this.checkpointJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProcessingJobRow(')
          ..write('id: $id, ')
          ..write('screenshotId: $screenshotId, ')
          ..write('jobType: $jobType, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('priority: $priority, ')
          ..write('progress: $progress, ')
          ..write('checkpointJson: $checkpointJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    screenshotId,
    jobType,
    status,
    attemptCount,
    errorMessage,
    createdAt,
    updatedAt,
    priority,
    progress,
    checkpointJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProcessingJobRow &&
          other.id == this.id &&
          other.screenshotId == this.screenshotId &&
          other.jobType == this.jobType &&
          other.status == this.status &&
          other.attemptCount == this.attemptCount &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.priority == this.priority &&
          other.progress == this.progress &&
          other.checkpointJson == this.checkpointJson);
}

class ProcessingJobsCompanion extends UpdateCompanion<ProcessingJobRow> {
  final Value<int> id;
  final Value<int> screenshotId;
  final Value<JobType> jobType;
  final Value<JobStatus> status;
  final Value<int> attemptCount;
  final Value<String?> errorMessage;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> priority;
  final Value<double?> progress;
  final Value<String?> checkpointJson;
  const ProcessingJobsCompanion({
    this.id = const Value.absent(),
    this.screenshotId = const Value.absent(),
    this.jobType = const Value.absent(),
    this.status = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.priority = const Value.absent(),
    this.progress = const Value.absent(),
    this.checkpointJson = const Value.absent(),
  });
  ProcessingJobsCompanion.insert({
    this.id = const Value.absent(),
    required int screenshotId,
    required JobType jobType,
    required JobStatus status,
    this.attemptCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.priority = const Value.absent(),
    this.progress = const Value.absent(),
    this.checkpointJson = const Value.absent(),
  }) : screenshotId = Value(screenshotId),
       jobType = Value(jobType),
       status = Value(status);
  static Insertable<ProcessingJobRow> custom({
    Expression<int>? id,
    Expression<int>? screenshotId,
    Expression<String>? jobType,
    Expression<String>? status,
    Expression<int>? attemptCount,
    Expression<String>? errorMessage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? priority,
    Expression<double>? progress,
    Expression<String>? checkpointJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (screenshotId != null) 'screenshot_id': screenshotId,
      if (jobType != null) 'job_type': jobType,
      if (status != null) 'status': status,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (priority != null) 'priority': priority,
      if (progress != null) 'progress': progress,
      if (checkpointJson != null) 'checkpoint_json': checkpointJson,
    });
  }

  ProcessingJobsCompanion copyWith({
    Value<int>? id,
    Value<int>? screenshotId,
    Value<JobType>? jobType,
    Value<JobStatus>? status,
    Value<int>? attemptCount,
    Value<String?>? errorMessage,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? priority,
    Value<double?>? progress,
    Value<String?>? checkpointJson,
  }) {
    return ProcessingJobsCompanion(
      id: id ?? this.id,
      screenshotId: screenshotId ?? this.screenshotId,
      jobType: jobType ?? this.jobType,
      status: status ?? this.status,
      attemptCount: attemptCount ?? this.attemptCount,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      priority: priority ?? this.priority,
      progress: progress ?? this.progress,
      checkpointJson: checkpointJson ?? this.checkpointJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (screenshotId.present) {
      map['screenshot_id'] = Variable<int>(screenshotId.value);
    }
    if (jobType.present) {
      map['job_type'] = Variable<String>(
        $ProcessingJobsTable.$converterjobType.toSql(jobType.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ProcessingJobsTable.$converterstatus.toSql(status.value),
      );
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (checkpointJson.present) {
      map['checkpoint_json'] = Variable<String>(checkpointJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProcessingJobsCompanion(')
          ..write('id: $id, ')
          ..write('screenshotId: $screenshotId, ')
          ..write('jobType: $jobType, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('priority: $priority, ')
          ..write('progress: $progress, ')
          ..write('checkpointJson: $checkpointJson')
          ..write(')'))
        .toString();
  }
}

class $SearchHistoryTable extends SearchHistory
    with TableInfo<$SearchHistoryTable, SearchHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _searchedAtMeta = const VerificationMeta(
    'searchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> searchedAt = GeneratedColumn<DateTime>(
    'searched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, query, searchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<SearchHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('searched_at')) {
      context.handle(
        _searchedAtMeta,
        searchedAt.isAcceptableOrUnknown(data['searched_at']!, _searchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_searchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SearchHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchHistoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      )!,
      searchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}searched_at'],
      )!,
    );
  }

  @override
  $SearchHistoryTable createAlias(String alias) {
    return $SearchHistoryTable(attachedDatabase, alias);
  }
}

class SearchHistoryRow extends DataClass
    implements Insertable<SearchHistoryRow> {
  final int id;
  final String query;
  final DateTime searchedAt;
  const SearchHistoryRow({
    required this.id,
    required this.query,
    required this.searchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['query'] = Variable<String>(query);
    map['searched_at'] = Variable<DateTime>(searchedAt);
    return map;
  }

  SearchHistoryCompanion toCompanion(bool nullToAbsent) {
    return SearchHistoryCompanion(
      id: Value(id),
      query: Value(query),
      searchedAt: Value(searchedAt),
    );
  }

  factory SearchHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchHistoryRow(
      id: serializer.fromJson<int>(json['id']),
      query: serializer.fromJson<String>(json['query']),
      searchedAt: serializer.fromJson<DateTime>(json['searchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'query': serializer.toJson<String>(query),
      'searchedAt': serializer.toJson<DateTime>(searchedAt),
    };
  }

  SearchHistoryRow copyWith({int? id, String? query, DateTime? searchedAt}) =>
      SearchHistoryRow(
        id: id ?? this.id,
        query: query ?? this.query,
        searchedAt: searchedAt ?? this.searchedAt,
      );
  SearchHistoryRow copyWithCompanion(SearchHistoryCompanion data) {
    return SearchHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      query: data.query.present ? data.query.value : this.query,
      searchedAt: data.searchedAt.present
          ? data.searchedAt.value
          : this.searchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryRow(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, query, searchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchHistoryRow &&
          other.id == this.id &&
          other.query == this.query &&
          other.searchedAt == this.searchedAt);
}

class SearchHistoryCompanion extends UpdateCompanion<SearchHistoryRow> {
  final Value<int> id;
  final Value<String> query;
  final Value<DateTime> searchedAt;
  const SearchHistoryCompanion({
    this.id = const Value.absent(),
    this.query = const Value.absent(),
    this.searchedAt = const Value.absent(),
  });
  SearchHistoryCompanion.insert({
    this.id = const Value.absent(),
    required String query,
    required DateTime searchedAt,
  }) : query = Value(query),
       searchedAt = Value(searchedAt);
  static Insertable<SearchHistoryRow> custom({
    Expression<int>? id,
    Expression<String>? query,
    Expression<DateTime>? searchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (query != null) 'query': query,
      if (searchedAt != null) 'searched_at': searchedAt,
    });
  }

  SearchHistoryCompanion copyWith({
    Value<int>? id,
    Value<String>? query,
    Value<DateTime>? searchedAt,
  }) {
    return SearchHistoryCompanion(
      id: id ?? this.id,
      query: query ?? this.query,
      searchedAt: searchedAt ?? this.searchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (searchedAt.present) {
      map['searched_at'] = Variable<DateTime>(searchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryCompanion(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingRow extends DataClass implements Insertable<AppSettingRow> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSettingRow({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSettingRow copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppSettingRow(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSettingRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingRow &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClassificationRulesTable extends ClassificationRules
    with TableInfo<$ClassificationRulesTable, ClassificationRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClassificationRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _keywordMeta = const VerificationMeta(
    'keyword',
  );
  @override
  late final GeneratedColumn<String> keyword = GeneratedColumn<String>(
    'keyword',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, keyword, categoryId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'classification_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClassificationRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('keyword')) {
      context.handle(
        _keywordMeta,
        keyword.isAcceptableOrUnknown(data['keyword']!, _keywordMeta),
      );
    } else if (isInserting) {
      context.missing(_keywordMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClassificationRuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClassificationRuleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      keyword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keyword'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ClassificationRulesTable createAlias(String alias) {
    return $ClassificationRulesTable(attachedDatabase, alias);
  }
}

class ClassificationRuleRow extends DataClass
    implements Insertable<ClassificationRuleRow> {
  final int id;
  final String keyword;
  final int categoryId;
  final DateTime createdAt;
  const ClassificationRuleRow({
    required this.id,
    required this.keyword,
    required this.categoryId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['keyword'] = Variable<String>(keyword);
    map['category_id'] = Variable<int>(categoryId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ClassificationRulesCompanion toCompanion(bool nullToAbsent) {
    return ClassificationRulesCompanion(
      id: Value(id),
      keyword: Value(keyword),
      categoryId: Value(categoryId),
      createdAt: Value(createdAt),
    );
  }

  factory ClassificationRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClassificationRuleRow(
      id: serializer.fromJson<int>(json['id']),
      keyword: serializer.fromJson<String>(json['keyword']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'keyword': serializer.toJson<String>(keyword),
      'categoryId': serializer.toJson<int>(categoryId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ClassificationRuleRow copyWith({
    int? id,
    String? keyword,
    int? categoryId,
    DateTime? createdAt,
  }) => ClassificationRuleRow(
    id: id ?? this.id,
    keyword: keyword ?? this.keyword,
    categoryId: categoryId ?? this.categoryId,
    createdAt: createdAt ?? this.createdAt,
  );
  ClassificationRuleRow copyWithCompanion(ClassificationRulesCompanion data) {
    return ClassificationRuleRow(
      id: data.id.present ? data.id.value : this.id,
      keyword: data.keyword.present ? data.keyword.value : this.keyword,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClassificationRuleRow(')
          ..write('id: $id, ')
          ..write('keyword: $keyword, ')
          ..write('categoryId: $categoryId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, keyword, categoryId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClassificationRuleRow &&
          other.id == this.id &&
          other.keyword == this.keyword &&
          other.categoryId == this.categoryId &&
          other.createdAt == this.createdAt);
}

class ClassificationRulesCompanion
    extends UpdateCompanion<ClassificationRuleRow> {
  final Value<int> id;
  final Value<String> keyword;
  final Value<int> categoryId;
  final Value<DateTime> createdAt;
  const ClassificationRulesCompanion({
    this.id = const Value.absent(),
    this.keyword = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ClassificationRulesCompanion.insert({
    this.id = const Value.absent(),
    required String keyword,
    required int categoryId,
    this.createdAt = const Value.absent(),
  }) : keyword = Value(keyword),
       categoryId = Value(categoryId);
  static Insertable<ClassificationRuleRow> custom({
    Expression<int>? id,
    Expression<String>? keyword,
    Expression<int>? categoryId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (keyword != null) 'keyword': keyword,
      if (categoryId != null) 'category_id': categoryId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ClassificationRulesCompanion copyWith({
    Value<int>? id,
    Value<String>? keyword,
    Value<int>? categoryId,
    Value<DateTime>? createdAt,
  }) {
    return ClassificationRulesCompanion(
      id: id ?? this.id,
      keyword: keyword ?? this.keyword,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (keyword.present) {
      map['keyword'] = Variable<String>(keyword.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClassificationRulesCompanion(')
          ..write('id: $id, ')
          ..write('keyword: $keyword, ')
          ..write('categoryId: $categoryId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MemoryChunksTable extends MemoryChunks
    with TableInfo<$MemoryChunksTable, MemoryChunkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryChunksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _memoryIdMeta = const VerificationMeta(
    'memoryId',
  );
  @override
  late final GeneratedColumn<int> memoryId = GeneratedColumn<int>(
    'memory_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES screenshots (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _chunkIndexMeta = const VerificationMeta(
    'chunkIndex',
  );
  @override
  late final GeneratedColumn<int> chunkIndex = GeneratedColumn<int>(
    'chunk_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textOriginalMeta = const VerificationMeta(
    'textOriginal',
  );
  @override
  late final GeneratedColumn<String> textOriginal = GeneratedColumn<String>(
    'text_original',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textNormalizedMeta = const VerificationMeta(
    'textNormalized',
  );
  @override
  late final GeneratedColumn<String> textNormalized = GeneratedColumn<String>(
    'text_normalized',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startMsMeta = const VerificationMeta(
    'startMs',
  );
  @override
  late final GeneratedColumn<int> startMs = GeneratedColumn<int>(
    'start_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endMsMeta = const VerificationMeta('endMs');
  @override
  late final GeneratedColumn<int> endMs = GeneratedColumn<int>(
    'end_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _regionJsonMeta = const VerificationMeta(
    'regionJson',
  );
  @override
  late final GeneratedColumn<String> regionJson = GeneratedColumn<String>(
    'region_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tokenCountMeta = const VerificationMeta(
    'tokenCount',
  );
  @override
  late final GeneratedColumn<int> tokenCount = GeneratedColumn<int>(
    'token_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceChecksumMeta = const VerificationMeta(
    'sourceChecksum',
  );
  @override
  late final GeneratedColumn<String> sourceChecksum = GeneratedColumn<String>(
    'source_checksum',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    memoryId,
    chunkIndex,
    textOriginal,
    textNormalized,
    page,
    startMs,
    endMs,
    regionJson,
    tokenCount,
    sourceChecksum,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_chunks';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoryChunkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('memory_id')) {
      context.handle(
        _memoryIdMeta,
        memoryId.isAcceptableOrUnknown(data['memory_id']!, _memoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memoryIdMeta);
    }
    if (data.containsKey('chunk_index')) {
      context.handle(
        _chunkIndexMeta,
        chunkIndex.isAcceptableOrUnknown(data['chunk_index']!, _chunkIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_chunkIndexMeta);
    }
    if (data.containsKey('text_original')) {
      context.handle(
        _textOriginalMeta,
        textOriginal.isAcceptableOrUnknown(
          data['text_original']!,
          _textOriginalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_textOriginalMeta);
    }
    if (data.containsKey('text_normalized')) {
      context.handle(
        _textNormalizedMeta,
        textNormalized.isAcceptableOrUnknown(
          data['text_normalized']!,
          _textNormalizedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_textNormalizedMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    }
    if (data.containsKey('start_ms')) {
      context.handle(
        _startMsMeta,
        startMs.isAcceptableOrUnknown(data['start_ms']!, _startMsMeta),
      );
    }
    if (data.containsKey('end_ms')) {
      context.handle(
        _endMsMeta,
        endMs.isAcceptableOrUnknown(data['end_ms']!, _endMsMeta),
      );
    }
    if (data.containsKey('region_json')) {
      context.handle(
        _regionJsonMeta,
        regionJson.isAcceptableOrUnknown(data['region_json']!, _regionJsonMeta),
      );
    }
    if (data.containsKey('token_count')) {
      context.handle(
        _tokenCountMeta,
        tokenCount.isAcceptableOrUnknown(data['token_count']!, _tokenCountMeta),
      );
    }
    if (data.containsKey('source_checksum')) {
      context.handle(
        _sourceChecksumMeta,
        sourceChecksum.isAcceptableOrUnknown(
          data['source_checksum']!,
          _sourceChecksumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceChecksumMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {memoryId, chunkIndex},
  ];
  @override
  MemoryChunkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryChunkRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      memoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}memory_id'],
      )!,
      chunkIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chunk_index'],
      )!,
      textOriginal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_original'],
      )!,
      textNormalized: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_normalized'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      ),
      startMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_ms'],
      ),
      endMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_ms'],
      ),
      regionJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region_json'],
      ),
      tokenCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}token_count'],
      ),
      sourceChecksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_checksum'],
      )!,
    );
  }

  @override
  $MemoryChunksTable createAlias(String alias) {
    return $MemoryChunksTable(attachedDatabase, alias);
  }
}

class MemoryChunkRow extends DataClass implements Insertable<MemoryChunkRow> {
  final int id;
  final int memoryId;
  final int chunkIndex;
  final String textOriginal;
  final String textNormalized;
  final int? page;
  final int? startMs;
  final int? endMs;
  final String? regionJson;
  final int? tokenCount;

  /// Hash of the text the chunk came from; a mismatch marks it stale.
  final String sourceChecksum;
  const MemoryChunkRow({
    required this.id,
    required this.memoryId,
    required this.chunkIndex,
    required this.textOriginal,
    required this.textNormalized,
    this.page,
    this.startMs,
    this.endMs,
    this.regionJson,
    this.tokenCount,
    required this.sourceChecksum,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['memory_id'] = Variable<int>(memoryId);
    map['chunk_index'] = Variable<int>(chunkIndex);
    map['text_original'] = Variable<String>(textOriginal);
    map['text_normalized'] = Variable<String>(textNormalized);
    if (!nullToAbsent || page != null) {
      map['page'] = Variable<int>(page);
    }
    if (!nullToAbsent || startMs != null) {
      map['start_ms'] = Variable<int>(startMs);
    }
    if (!nullToAbsent || endMs != null) {
      map['end_ms'] = Variable<int>(endMs);
    }
    if (!nullToAbsent || regionJson != null) {
      map['region_json'] = Variable<String>(regionJson);
    }
    if (!nullToAbsent || tokenCount != null) {
      map['token_count'] = Variable<int>(tokenCount);
    }
    map['source_checksum'] = Variable<String>(sourceChecksum);
    return map;
  }

  MemoryChunksCompanion toCompanion(bool nullToAbsent) {
    return MemoryChunksCompanion(
      id: Value(id),
      memoryId: Value(memoryId),
      chunkIndex: Value(chunkIndex),
      textOriginal: Value(textOriginal),
      textNormalized: Value(textNormalized),
      page: page == null && nullToAbsent ? const Value.absent() : Value(page),
      startMs: startMs == null && nullToAbsent
          ? const Value.absent()
          : Value(startMs),
      endMs: endMs == null && nullToAbsent
          ? const Value.absent()
          : Value(endMs),
      regionJson: regionJson == null && nullToAbsent
          ? const Value.absent()
          : Value(regionJson),
      tokenCount: tokenCount == null && nullToAbsent
          ? const Value.absent()
          : Value(tokenCount),
      sourceChecksum: Value(sourceChecksum),
    );
  }

  factory MemoryChunkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryChunkRow(
      id: serializer.fromJson<int>(json['id']),
      memoryId: serializer.fromJson<int>(json['memoryId']),
      chunkIndex: serializer.fromJson<int>(json['chunkIndex']),
      textOriginal: serializer.fromJson<String>(json['textOriginal']),
      textNormalized: serializer.fromJson<String>(json['textNormalized']),
      page: serializer.fromJson<int?>(json['page']),
      startMs: serializer.fromJson<int?>(json['startMs']),
      endMs: serializer.fromJson<int?>(json['endMs']),
      regionJson: serializer.fromJson<String?>(json['regionJson']),
      tokenCount: serializer.fromJson<int?>(json['tokenCount']),
      sourceChecksum: serializer.fromJson<String>(json['sourceChecksum']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'memoryId': serializer.toJson<int>(memoryId),
      'chunkIndex': serializer.toJson<int>(chunkIndex),
      'textOriginal': serializer.toJson<String>(textOriginal),
      'textNormalized': serializer.toJson<String>(textNormalized),
      'page': serializer.toJson<int?>(page),
      'startMs': serializer.toJson<int?>(startMs),
      'endMs': serializer.toJson<int?>(endMs),
      'regionJson': serializer.toJson<String?>(regionJson),
      'tokenCount': serializer.toJson<int?>(tokenCount),
      'sourceChecksum': serializer.toJson<String>(sourceChecksum),
    };
  }

  MemoryChunkRow copyWith({
    int? id,
    int? memoryId,
    int? chunkIndex,
    String? textOriginal,
    String? textNormalized,
    Value<int?> page = const Value.absent(),
    Value<int?> startMs = const Value.absent(),
    Value<int?> endMs = const Value.absent(),
    Value<String?> regionJson = const Value.absent(),
    Value<int?> tokenCount = const Value.absent(),
    String? sourceChecksum,
  }) => MemoryChunkRow(
    id: id ?? this.id,
    memoryId: memoryId ?? this.memoryId,
    chunkIndex: chunkIndex ?? this.chunkIndex,
    textOriginal: textOriginal ?? this.textOriginal,
    textNormalized: textNormalized ?? this.textNormalized,
    page: page.present ? page.value : this.page,
    startMs: startMs.present ? startMs.value : this.startMs,
    endMs: endMs.present ? endMs.value : this.endMs,
    regionJson: regionJson.present ? regionJson.value : this.regionJson,
    tokenCount: tokenCount.present ? tokenCount.value : this.tokenCount,
    sourceChecksum: sourceChecksum ?? this.sourceChecksum,
  );
  MemoryChunkRow copyWithCompanion(MemoryChunksCompanion data) {
    return MemoryChunkRow(
      id: data.id.present ? data.id.value : this.id,
      memoryId: data.memoryId.present ? data.memoryId.value : this.memoryId,
      chunkIndex: data.chunkIndex.present
          ? data.chunkIndex.value
          : this.chunkIndex,
      textOriginal: data.textOriginal.present
          ? data.textOriginal.value
          : this.textOriginal,
      textNormalized: data.textNormalized.present
          ? data.textNormalized.value
          : this.textNormalized,
      page: data.page.present ? data.page.value : this.page,
      startMs: data.startMs.present ? data.startMs.value : this.startMs,
      endMs: data.endMs.present ? data.endMs.value : this.endMs,
      regionJson: data.regionJson.present
          ? data.regionJson.value
          : this.regionJson,
      tokenCount: data.tokenCount.present
          ? data.tokenCount.value
          : this.tokenCount,
      sourceChecksum: data.sourceChecksum.present
          ? data.sourceChecksum.value
          : this.sourceChecksum,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryChunkRow(')
          ..write('id: $id, ')
          ..write('memoryId: $memoryId, ')
          ..write('chunkIndex: $chunkIndex, ')
          ..write('textOriginal: $textOriginal, ')
          ..write('textNormalized: $textNormalized, ')
          ..write('page: $page, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('regionJson: $regionJson, ')
          ..write('tokenCount: $tokenCount, ')
          ..write('sourceChecksum: $sourceChecksum')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    memoryId,
    chunkIndex,
    textOriginal,
    textNormalized,
    page,
    startMs,
    endMs,
    regionJson,
    tokenCount,
    sourceChecksum,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryChunkRow &&
          other.id == this.id &&
          other.memoryId == this.memoryId &&
          other.chunkIndex == this.chunkIndex &&
          other.textOriginal == this.textOriginal &&
          other.textNormalized == this.textNormalized &&
          other.page == this.page &&
          other.startMs == this.startMs &&
          other.endMs == this.endMs &&
          other.regionJson == this.regionJson &&
          other.tokenCount == this.tokenCount &&
          other.sourceChecksum == this.sourceChecksum);
}

class MemoryChunksCompanion extends UpdateCompanion<MemoryChunkRow> {
  final Value<int> id;
  final Value<int> memoryId;
  final Value<int> chunkIndex;
  final Value<String> textOriginal;
  final Value<String> textNormalized;
  final Value<int?> page;
  final Value<int?> startMs;
  final Value<int?> endMs;
  final Value<String?> regionJson;
  final Value<int?> tokenCount;
  final Value<String> sourceChecksum;
  const MemoryChunksCompanion({
    this.id = const Value.absent(),
    this.memoryId = const Value.absent(),
    this.chunkIndex = const Value.absent(),
    this.textOriginal = const Value.absent(),
    this.textNormalized = const Value.absent(),
    this.page = const Value.absent(),
    this.startMs = const Value.absent(),
    this.endMs = const Value.absent(),
    this.regionJson = const Value.absent(),
    this.tokenCount = const Value.absent(),
    this.sourceChecksum = const Value.absent(),
  });
  MemoryChunksCompanion.insert({
    this.id = const Value.absent(),
    required int memoryId,
    required int chunkIndex,
    required String textOriginal,
    required String textNormalized,
    this.page = const Value.absent(),
    this.startMs = const Value.absent(),
    this.endMs = const Value.absent(),
    this.regionJson = const Value.absent(),
    this.tokenCount = const Value.absent(),
    required String sourceChecksum,
  }) : memoryId = Value(memoryId),
       chunkIndex = Value(chunkIndex),
       textOriginal = Value(textOriginal),
       textNormalized = Value(textNormalized),
       sourceChecksum = Value(sourceChecksum);
  static Insertable<MemoryChunkRow> custom({
    Expression<int>? id,
    Expression<int>? memoryId,
    Expression<int>? chunkIndex,
    Expression<String>? textOriginal,
    Expression<String>? textNormalized,
    Expression<int>? page,
    Expression<int>? startMs,
    Expression<int>? endMs,
    Expression<String>? regionJson,
    Expression<int>? tokenCount,
    Expression<String>? sourceChecksum,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memoryId != null) 'memory_id': memoryId,
      if (chunkIndex != null) 'chunk_index': chunkIndex,
      if (textOriginal != null) 'text_original': textOriginal,
      if (textNormalized != null) 'text_normalized': textNormalized,
      if (page != null) 'page': page,
      if (startMs != null) 'start_ms': startMs,
      if (endMs != null) 'end_ms': endMs,
      if (regionJson != null) 'region_json': regionJson,
      if (tokenCount != null) 'token_count': tokenCount,
      if (sourceChecksum != null) 'source_checksum': sourceChecksum,
    });
  }

  MemoryChunksCompanion copyWith({
    Value<int>? id,
    Value<int>? memoryId,
    Value<int>? chunkIndex,
    Value<String>? textOriginal,
    Value<String>? textNormalized,
    Value<int?>? page,
    Value<int?>? startMs,
    Value<int?>? endMs,
    Value<String?>? regionJson,
    Value<int?>? tokenCount,
    Value<String>? sourceChecksum,
  }) {
    return MemoryChunksCompanion(
      id: id ?? this.id,
      memoryId: memoryId ?? this.memoryId,
      chunkIndex: chunkIndex ?? this.chunkIndex,
      textOriginal: textOriginal ?? this.textOriginal,
      textNormalized: textNormalized ?? this.textNormalized,
      page: page ?? this.page,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      regionJson: regionJson ?? this.regionJson,
      tokenCount: tokenCount ?? this.tokenCount,
      sourceChecksum: sourceChecksum ?? this.sourceChecksum,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (memoryId.present) {
      map['memory_id'] = Variable<int>(memoryId.value);
    }
    if (chunkIndex.present) {
      map['chunk_index'] = Variable<int>(chunkIndex.value);
    }
    if (textOriginal.present) {
      map['text_original'] = Variable<String>(textOriginal.value);
    }
    if (textNormalized.present) {
      map['text_normalized'] = Variable<String>(textNormalized.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (startMs.present) {
      map['start_ms'] = Variable<int>(startMs.value);
    }
    if (endMs.present) {
      map['end_ms'] = Variable<int>(endMs.value);
    }
    if (regionJson.present) {
      map['region_json'] = Variable<String>(regionJson.value);
    }
    if (tokenCount.present) {
      map['token_count'] = Variable<int>(tokenCount.value);
    }
    if (sourceChecksum.present) {
      map['source_checksum'] = Variable<String>(sourceChecksum.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryChunksCompanion(')
          ..write('id: $id, ')
          ..write('memoryId: $memoryId, ')
          ..write('chunkIndex: $chunkIndex, ')
          ..write('textOriginal: $textOriginal, ')
          ..write('textNormalized: $textNormalized, ')
          ..write('page: $page, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('regionJson: $regionJson, ')
          ..write('tokenCount: $tokenCount, ')
          ..write('sourceChecksum: $sourceChecksum')
          ..write(')'))
        .toString();
  }
}

class $EmbeddingsTable extends Embeddings
    with TableInfo<$EmbeddingsTable, EmbeddingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmbeddingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _chunkIdMeta = const VerificationMeta(
    'chunkId',
  );
  @override
  late final GeneratedColumn<int> chunkId = GeneratedColumn<int>(
    'chunk_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES memory_chunks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _memoryIdMeta = const VerificationMeta(
    'memoryId',
  );
  @override
  late final GeneratedColumn<int> memoryId = GeneratedColumn<int>(
    'memory_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES screenshots (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dimensionMeta = const VerificationMeta(
    'dimension',
  );
  @override
  late final GeneratedColumn<int> dimension = GeneratedColumn<int>(
    'dimension',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vectorMeta = const VerificationMeta('vector');
  @override
  late final GeneratedColumn<Uint8List> vector = GeneratedColumn<Uint8List>(
    'vector',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceChecksumMeta = const VerificationMeta(
    'sourceChecksum',
  );
  @override
  late final GeneratedColumn<String> sourceChecksum = GeneratedColumn<String>(
    'source_checksum',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    chunkId,
    memoryId,
    modelId,
    modelVersion,
    spaceId,
    dimension,
    vector,
    sourceChecksum,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'embeddings';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmbeddingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('chunk_id')) {
      context.handle(
        _chunkIdMeta,
        chunkId.isAcceptableOrUnknown(data['chunk_id']!, _chunkIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chunkIdMeta);
    }
    if (data.containsKey('memory_id')) {
      context.handle(
        _memoryIdMeta,
        memoryId.isAcceptableOrUnknown(data['memory_id']!, _memoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memoryIdMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modelVersionMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('dimension')) {
      context.handle(
        _dimensionMeta,
        dimension.isAcceptableOrUnknown(data['dimension']!, _dimensionMeta),
      );
    } else if (isInserting) {
      context.missing(_dimensionMeta);
    }
    if (data.containsKey('vector')) {
      context.handle(
        _vectorMeta,
        vector.isAcceptableOrUnknown(data['vector']!, _vectorMeta),
      );
    } else if (isInserting) {
      context.missing(_vectorMeta);
    }
    if (data.containsKey('source_checksum')) {
      context.handle(
        _sourceChecksumMeta,
        sourceChecksum.isAcceptableOrUnknown(
          data['source_checksum']!,
          _sourceChecksumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceChecksumMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {chunkId, modelId, modelVersion},
  ];
  @override
  EmbeddingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmbeddingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      chunkId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chunk_id'],
      )!,
      memoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}memory_id'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      dimension: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dimension'],
      )!,
      vector: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}vector'],
      )!,
      sourceChecksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_checksum'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EmbeddingsTable createAlias(String alias) {
    return $EmbeddingsTable(attachedDatabase, alias);
  }
}

class EmbeddingRow extends DataClass implements Insertable<EmbeddingRow> {
  final int id;
  final int chunkId;
  final int memoryId;
  final String modelId;
  final String modelVersion;
  final String spaceId;
  final int dimension;

  /// float32, little-endian.
  final Uint8List vector;
  final String sourceChecksum;
  final DateTime createdAt;
  const EmbeddingRow({
    required this.id,
    required this.chunkId,
    required this.memoryId,
    required this.modelId,
    required this.modelVersion,
    required this.spaceId,
    required this.dimension,
    required this.vector,
    required this.sourceChecksum,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['chunk_id'] = Variable<int>(chunkId);
    map['memory_id'] = Variable<int>(memoryId);
    map['model_id'] = Variable<String>(modelId);
    map['model_version'] = Variable<String>(modelVersion);
    map['space_id'] = Variable<String>(spaceId);
    map['dimension'] = Variable<int>(dimension);
    map['vector'] = Variable<Uint8List>(vector);
    map['source_checksum'] = Variable<String>(sourceChecksum);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EmbeddingsCompanion toCompanion(bool nullToAbsent) {
    return EmbeddingsCompanion(
      id: Value(id),
      chunkId: Value(chunkId),
      memoryId: Value(memoryId),
      modelId: Value(modelId),
      modelVersion: Value(modelVersion),
      spaceId: Value(spaceId),
      dimension: Value(dimension),
      vector: Value(vector),
      sourceChecksum: Value(sourceChecksum),
      createdAt: Value(createdAt),
    );
  }

  factory EmbeddingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmbeddingRow(
      id: serializer.fromJson<int>(json['id']),
      chunkId: serializer.fromJson<int>(json['chunkId']),
      memoryId: serializer.fromJson<int>(json['memoryId']),
      modelId: serializer.fromJson<String>(json['modelId']),
      modelVersion: serializer.fromJson<String>(json['modelVersion']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      dimension: serializer.fromJson<int>(json['dimension']),
      vector: serializer.fromJson<Uint8List>(json['vector']),
      sourceChecksum: serializer.fromJson<String>(json['sourceChecksum']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'chunkId': serializer.toJson<int>(chunkId),
      'memoryId': serializer.toJson<int>(memoryId),
      'modelId': serializer.toJson<String>(modelId),
      'modelVersion': serializer.toJson<String>(modelVersion),
      'spaceId': serializer.toJson<String>(spaceId),
      'dimension': serializer.toJson<int>(dimension),
      'vector': serializer.toJson<Uint8List>(vector),
      'sourceChecksum': serializer.toJson<String>(sourceChecksum),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  EmbeddingRow copyWith({
    int? id,
    int? chunkId,
    int? memoryId,
    String? modelId,
    String? modelVersion,
    String? spaceId,
    int? dimension,
    Uint8List? vector,
    String? sourceChecksum,
    DateTime? createdAt,
  }) => EmbeddingRow(
    id: id ?? this.id,
    chunkId: chunkId ?? this.chunkId,
    memoryId: memoryId ?? this.memoryId,
    modelId: modelId ?? this.modelId,
    modelVersion: modelVersion ?? this.modelVersion,
    spaceId: spaceId ?? this.spaceId,
    dimension: dimension ?? this.dimension,
    vector: vector ?? this.vector,
    sourceChecksum: sourceChecksum ?? this.sourceChecksum,
    createdAt: createdAt ?? this.createdAt,
  );
  EmbeddingRow copyWithCompanion(EmbeddingsCompanion data) {
    return EmbeddingRow(
      id: data.id.present ? data.id.value : this.id,
      chunkId: data.chunkId.present ? data.chunkId.value : this.chunkId,
      memoryId: data.memoryId.present ? data.memoryId.value : this.memoryId,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      dimension: data.dimension.present ? data.dimension.value : this.dimension,
      vector: data.vector.present ? data.vector.value : this.vector,
      sourceChecksum: data.sourceChecksum.present
          ? data.sourceChecksum.value
          : this.sourceChecksum,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmbeddingRow(')
          ..write('id: $id, ')
          ..write('chunkId: $chunkId, ')
          ..write('memoryId: $memoryId, ')
          ..write('modelId: $modelId, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('spaceId: $spaceId, ')
          ..write('dimension: $dimension, ')
          ..write('vector: $vector, ')
          ..write('sourceChecksum: $sourceChecksum, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    chunkId,
    memoryId,
    modelId,
    modelVersion,
    spaceId,
    dimension,
    $driftBlobEquality.hash(vector),
    sourceChecksum,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmbeddingRow &&
          other.id == this.id &&
          other.chunkId == this.chunkId &&
          other.memoryId == this.memoryId &&
          other.modelId == this.modelId &&
          other.modelVersion == this.modelVersion &&
          other.spaceId == this.spaceId &&
          other.dimension == this.dimension &&
          $driftBlobEquality.equals(other.vector, this.vector) &&
          other.sourceChecksum == this.sourceChecksum &&
          other.createdAt == this.createdAt);
}

class EmbeddingsCompanion extends UpdateCompanion<EmbeddingRow> {
  final Value<int> id;
  final Value<int> chunkId;
  final Value<int> memoryId;
  final Value<String> modelId;
  final Value<String> modelVersion;
  final Value<String> spaceId;
  final Value<int> dimension;
  final Value<Uint8List> vector;
  final Value<String> sourceChecksum;
  final Value<DateTime> createdAt;
  const EmbeddingsCompanion({
    this.id = const Value.absent(),
    this.chunkId = const Value.absent(),
    this.memoryId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.dimension = const Value.absent(),
    this.vector = const Value.absent(),
    this.sourceChecksum = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  EmbeddingsCompanion.insert({
    this.id = const Value.absent(),
    required int chunkId,
    required int memoryId,
    required String modelId,
    required String modelVersion,
    required String spaceId,
    required int dimension,
    required Uint8List vector,
    required String sourceChecksum,
    this.createdAt = const Value.absent(),
  }) : chunkId = Value(chunkId),
       memoryId = Value(memoryId),
       modelId = Value(modelId),
       modelVersion = Value(modelVersion),
       spaceId = Value(spaceId),
       dimension = Value(dimension),
       vector = Value(vector),
       sourceChecksum = Value(sourceChecksum);
  static Insertable<EmbeddingRow> custom({
    Expression<int>? id,
    Expression<int>? chunkId,
    Expression<int>? memoryId,
    Expression<String>? modelId,
    Expression<String>? modelVersion,
    Expression<String>? spaceId,
    Expression<int>? dimension,
    Expression<Uint8List>? vector,
    Expression<String>? sourceChecksum,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chunkId != null) 'chunk_id': chunkId,
      if (memoryId != null) 'memory_id': memoryId,
      if (modelId != null) 'model_id': modelId,
      if (modelVersion != null) 'model_version': modelVersion,
      if (spaceId != null) 'space_id': spaceId,
      if (dimension != null) 'dimension': dimension,
      if (vector != null) 'vector': vector,
      if (sourceChecksum != null) 'source_checksum': sourceChecksum,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  EmbeddingsCompanion copyWith({
    Value<int>? id,
    Value<int>? chunkId,
    Value<int>? memoryId,
    Value<String>? modelId,
    Value<String>? modelVersion,
    Value<String>? spaceId,
    Value<int>? dimension,
    Value<Uint8List>? vector,
    Value<String>? sourceChecksum,
    Value<DateTime>? createdAt,
  }) {
    return EmbeddingsCompanion(
      id: id ?? this.id,
      chunkId: chunkId ?? this.chunkId,
      memoryId: memoryId ?? this.memoryId,
      modelId: modelId ?? this.modelId,
      modelVersion: modelVersion ?? this.modelVersion,
      spaceId: spaceId ?? this.spaceId,
      dimension: dimension ?? this.dimension,
      vector: vector ?? this.vector,
      sourceChecksum: sourceChecksum ?? this.sourceChecksum,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (chunkId.present) {
      map['chunk_id'] = Variable<int>(chunkId.value);
    }
    if (memoryId.present) {
      map['memory_id'] = Variable<int>(memoryId.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (dimension.present) {
      map['dimension'] = Variable<int>(dimension.value);
    }
    if (vector.present) {
      map['vector'] = Variable<Uint8List>(vector.value);
    }
    if (sourceChecksum.present) {
      map['source_checksum'] = Variable<String>(sourceChecksum.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmbeddingsCompanion(')
          ..write('id: $id, ')
          ..write('chunkId: $chunkId, ')
          ..write('memoryId: $memoryId, ')
          ..write('modelId: $modelId, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('spaceId: $spaceId, ')
          ..write('dimension: $dimension, ')
          ..write('vector: $vector, ')
          ..write('sourceChecksum: $sourceChecksum, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SpacesTable extends Spaces with TableInfo<$SpacesTable, SpaceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverMemoryIdMeta = const VerificationMeta(
    'coverMemoryId',
  );
  @override
  late final GeneratedColumn<int> coverMemoryId = GeneratedColumn<int>(
    'cover_memory_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES screenshots (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    icon,
    color,
    coverMemoryId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'spaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpaceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('cover_memory_id')) {
      context.handle(
        _coverMemoryIdMeta,
        coverMemoryId.isAcceptableOrUnknown(
          data['cover_memory_id']!,
          _coverMemoryIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpaceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpaceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      coverMemoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cover_memory_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SpacesTable createAlias(String alias) {
    return $SpacesTable(attachedDatabase, alias);
  }
}

class SpaceRow extends DataClass implements Insertable<SpaceRow> {
  final int id;
  final String title;
  final String? description;
  final String icon;
  final int color;
  final int? coverMemoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SpaceRow({
    required this.id,
    required this.title,
    this.description,
    required this.icon,
    required this.color,
    this.coverMemoryId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<int>(color);
    if (!nullToAbsent || coverMemoryId != null) {
      map['cover_memory_id'] = Variable<int>(coverMemoryId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SpacesCompanion toCompanion(bool nullToAbsent) {
    return SpacesCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      icon: Value(icon),
      color: Value(color),
      coverMemoryId: coverMemoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(coverMemoryId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SpaceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpaceRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<int>(json['color']),
      coverMemoryId: serializer.fromJson<int?>(json['coverMemoryId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<int>(color),
      'coverMemoryId': serializer.toJson<int?>(coverMemoryId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SpaceRow copyWith({
    int? id,
    String? title,
    Value<String?> description = const Value.absent(),
    String? icon,
    int? color,
    Value<int?> coverMemoryId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SpaceRow(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    coverMemoryId: coverMemoryId.present
        ? coverMemoryId.value
        : this.coverMemoryId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SpaceRow copyWithCompanion(SpacesCompanion data) {
    return SpaceRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      coverMemoryId: data.coverMemoryId.present
          ? data.coverMemoryId.value
          : this.coverMemoryId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpaceRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('coverMemoryId: $coverMemoryId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    icon,
    color,
    coverMemoryId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpaceRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.coverMemoryId == this.coverMemoryId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SpacesCompanion extends UpdateCompanion<SpaceRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> icon;
  final Value<int> color;
  final Value<int?> coverMemoryId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SpacesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.coverMemoryId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SpacesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required String icon,
    required int color,
    this.coverMemoryId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : title = Value(title),
       icon = Value(icon),
       color = Value(color);
  static Insertable<SpaceRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? icon,
    Expression<int>? color,
    Expression<int>? coverMemoryId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (coverMemoryId != null) 'cover_memory_id': coverMemoryId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SpacesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? icon,
    Value<int>? color,
    Value<int?>? coverMemoryId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return SpacesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      coverMemoryId: coverMemoryId ?? this.coverMemoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (coverMemoryId.present) {
      map['cover_memory_id'] = Variable<int>(coverMemoryId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpacesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('coverMemoryId: $coverMemoryId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SpaceMembershipsTable extends SpaceMemberships
    with TableInfo<$SpaceMembershipsTable, SpaceMembershipRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpaceMembershipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<int> spaceId = GeneratedColumn<int>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES spaces (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _memoryIdMeta = const VerificationMeta(
    'memoryId',
  );
  @override
  late final GeneratedColumn<int> memoryId = GeneratedColumn<int>(
    'memory_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES screenshots (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [spaceId, memoryId, source, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'space_memberships';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpaceMembershipRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('memory_id')) {
      context.handle(
        _memoryIdMeta,
        memoryId.isAcceptableOrUnknown(data['memory_id']!, _memoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memoryIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {spaceId, memoryId};
  @override
  SpaceMembershipRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpaceMembershipRow(
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}space_id'],
      )!,
      memoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}memory_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $SpaceMembershipsTable createAlias(String alias) {
    return $SpaceMembershipsTable(attachedDatabase, alias);
  }
}

class SpaceMembershipRow extends DataClass
    implements Insertable<SpaceMembershipRow> {
  final int spaceId;
  final int memoryId;

  /// `user` or `suggestion_confirmed`: nothing joins a Space silently.
  final String source;
  final DateTime addedAt;
  const SpaceMembershipRow({
    required this.spaceId,
    required this.memoryId,
    required this.source,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['space_id'] = Variable<int>(spaceId);
    map['memory_id'] = Variable<int>(memoryId);
    map['source'] = Variable<String>(source);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  SpaceMembershipsCompanion toCompanion(bool nullToAbsent) {
    return SpaceMembershipsCompanion(
      spaceId: Value(spaceId),
      memoryId: Value(memoryId),
      source: Value(source),
      addedAt: Value(addedAt),
    );
  }

  factory SpaceMembershipRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpaceMembershipRow(
      spaceId: serializer.fromJson<int>(json['spaceId']),
      memoryId: serializer.fromJson<int>(json['memoryId']),
      source: serializer.fromJson<String>(json['source']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'spaceId': serializer.toJson<int>(spaceId),
      'memoryId': serializer.toJson<int>(memoryId),
      'source': serializer.toJson<String>(source),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  SpaceMembershipRow copyWith({
    int? spaceId,
    int? memoryId,
    String? source,
    DateTime? addedAt,
  }) => SpaceMembershipRow(
    spaceId: spaceId ?? this.spaceId,
    memoryId: memoryId ?? this.memoryId,
    source: source ?? this.source,
    addedAt: addedAt ?? this.addedAt,
  );
  SpaceMembershipRow copyWithCompanion(SpaceMembershipsCompanion data) {
    return SpaceMembershipRow(
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      memoryId: data.memoryId.present ? data.memoryId.value : this.memoryId,
      source: data.source.present ? data.source.value : this.source,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpaceMembershipRow(')
          ..write('spaceId: $spaceId, ')
          ..write('memoryId: $memoryId, ')
          ..write('source: $source, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(spaceId, memoryId, source, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpaceMembershipRow &&
          other.spaceId == this.spaceId &&
          other.memoryId == this.memoryId &&
          other.source == this.source &&
          other.addedAt == this.addedAt);
}

class SpaceMembershipsCompanion extends UpdateCompanion<SpaceMembershipRow> {
  final Value<int> spaceId;
  final Value<int> memoryId;
  final Value<String> source;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const SpaceMembershipsCompanion({
    this.spaceId = const Value.absent(),
    this.memoryId = const Value.absent(),
    this.source = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpaceMembershipsCompanion.insert({
    required int spaceId,
    required int memoryId,
    required String source,
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : spaceId = Value(spaceId),
       memoryId = Value(memoryId),
       source = Value(source);
  static Insertable<SpaceMembershipRow> custom({
    Expression<int>? spaceId,
    Expression<int>? memoryId,
    Expression<String>? source,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (spaceId != null) 'space_id': spaceId,
      if (memoryId != null) 'memory_id': memoryId,
      if (source != null) 'source': source,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpaceMembershipsCompanion copyWith({
    Value<int>? spaceId,
    Value<int>? memoryId,
    Value<String>? source,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return SpaceMembershipsCompanion(
      spaceId: spaceId ?? this.spaceId,
      memoryId: memoryId ?? this.memoryId,
      source: source ?? this.source,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (spaceId.present) {
      map['space_id'] = Variable<int>(spaceId.value);
    }
    if (memoryId.present) {
      map['memory_id'] = Variable<int>(memoryId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpaceMembershipsCompanion(')
          ..write('spaceId: $spaceId, ')
          ..write('memoryId: $memoryId, ')
          ..write('source: $source, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemoryRelationshipsTable extends MemoryRelationships
    with TableInfo<$MemoryRelationshipsTable, MemoryRelationshipRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryRelationshipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceMemoryIdMeta = const VerificationMeta(
    'sourceMemoryId',
  );
  @override
  late final GeneratedColumn<int> sourceMemoryId = GeneratedColumn<int>(
    'source_memory_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES screenshots (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _targetMemoryIdMeta = const VerificationMeta(
    'targetMemoryId',
  );
  @override
  late final GeneratedColumn<int> targetMemoryId = GeneratedColumn<int>(
    'target_memory_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES screenshots (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<RelationshipType, String>
  relationshipType =
      GeneratedColumn<String>(
        'relationship_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RelationshipType>(
        $MemoryRelationshipsTable.$converterrelationshipType,
      );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
    'score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _provenanceMeta = const VerificationMeta(
    'provenance',
  );
  @override
  late final GeneratedColumn<String> provenance = GeneratedColumn<String>(
    'provenance',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confirmedMeta = const VerificationMeta(
    'confirmed',
  );
  @override
  late final GeneratedColumn<bool> confirmed = GeneratedColumn<bool>(
    'confirmed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("confirmed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceMemoryId,
    targetMemoryId,
    relationshipType,
    score,
    provenance,
    method,
    confirmed,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_relationships';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoryRelationshipRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_memory_id')) {
      context.handle(
        _sourceMemoryIdMeta,
        sourceMemoryId.isAcceptableOrUnknown(
          data['source_memory_id']!,
          _sourceMemoryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceMemoryIdMeta);
    }
    if (data.containsKey('target_memory_id')) {
      context.handle(
        _targetMemoryIdMeta,
        targetMemoryId.isAcceptableOrUnknown(
          data['target_memory_id']!,
          _targetMemoryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetMemoryIdMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('provenance')) {
      context.handle(
        _provenanceMeta,
        provenance.isAcceptableOrUnknown(data['provenance']!, _provenanceMeta),
      );
    } else if (isInserting) {
      context.missing(_provenanceMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('confirmed')) {
      context.handle(
        _confirmedMeta,
        confirmed.isAcceptableOrUnknown(data['confirmed']!, _confirmedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sourceMemoryId, targetMemoryId, relationshipType},
  ];
  @override
  MemoryRelationshipRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryRelationshipRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceMemoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_memory_id'],
      )!,
      targetMemoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_memory_id'],
      )!,
      relationshipType: $MemoryRelationshipsTable.$converterrelationshipType
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}relationship_type'],
            )!,
          ),
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}score'],
      ),
      provenance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provenance'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      confirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}confirmed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MemoryRelationshipsTable createAlias(String alias) {
    return $MemoryRelationshipsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RelationshipType, String, String>
  $converterrelationshipType = const EnumNameConverter<RelationshipType>(
    RelationshipType.values,
  );
}

class MemoryRelationshipRow extends DataClass
    implements Insertable<MemoryRelationshipRow> {
  final int id;
  final int sourceMemoryId;
  final int targetMemoryId;
  final RelationshipType relationshipType;

  /// Similarity or rule score; not a calibrated probability.
  final double? score;

  /// Why the link exists, shown to the user (e.g. "both mention LH1234").
  final String provenance;
  final String method;
  final bool confirmed;
  final DateTime createdAt;
  const MemoryRelationshipRow({
    required this.id,
    required this.sourceMemoryId,
    required this.targetMemoryId,
    required this.relationshipType,
    this.score,
    required this.provenance,
    required this.method,
    required this.confirmed,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source_memory_id'] = Variable<int>(sourceMemoryId);
    map['target_memory_id'] = Variable<int>(targetMemoryId);
    {
      map['relationship_type'] = Variable<String>(
        $MemoryRelationshipsTable.$converterrelationshipType.toSql(
          relationshipType,
        ),
      );
    }
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<double>(score);
    }
    map['provenance'] = Variable<String>(provenance);
    map['method'] = Variable<String>(method);
    map['confirmed'] = Variable<bool>(confirmed);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MemoryRelationshipsCompanion toCompanion(bool nullToAbsent) {
    return MemoryRelationshipsCompanion(
      id: Value(id),
      sourceMemoryId: Value(sourceMemoryId),
      targetMemoryId: Value(targetMemoryId),
      relationshipType: Value(relationshipType),
      score: score == null && nullToAbsent
          ? const Value.absent()
          : Value(score),
      provenance: Value(provenance),
      method: Value(method),
      confirmed: Value(confirmed),
      createdAt: Value(createdAt),
    );
  }

  factory MemoryRelationshipRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryRelationshipRow(
      id: serializer.fromJson<int>(json['id']),
      sourceMemoryId: serializer.fromJson<int>(json['sourceMemoryId']),
      targetMemoryId: serializer.fromJson<int>(json['targetMemoryId']),
      relationshipType: $MemoryRelationshipsTable.$converterrelationshipType
          .fromJson(serializer.fromJson<String>(json['relationshipType'])),
      score: serializer.fromJson<double?>(json['score']),
      provenance: serializer.fromJson<String>(json['provenance']),
      method: serializer.fromJson<String>(json['method']),
      confirmed: serializer.fromJson<bool>(json['confirmed']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceMemoryId': serializer.toJson<int>(sourceMemoryId),
      'targetMemoryId': serializer.toJson<int>(targetMemoryId),
      'relationshipType': serializer.toJson<String>(
        $MemoryRelationshipsTable.$converterrelationshipType.toJson(
          relationshipType,
        ),
      ),
      'score': serializer.toJson<double?>(score),
      'provenance': serializer.toJson<String>(provenance),
      'method': serializer.toJson<String>(method),
      'confirmed': serializer.toJson<bool>(confirmed),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MemoryRelationshipRow copyWith({
    int? id,
    int? sourceMemoryId,
    int? targetMemoryId,
    RelationshipType? relationshipType,
    Value<double?> score = const Value.absent(),
    String? provenance,
    String? method,
    bool? confirmed,
    DateTime? createdAt,
  }) => MemoryRelationshipRow(
    id: id ?? this.id,
    sourceMemoryId: sourceMemoryId ?? this.sourceMemoryId,
    targetMemoryId: targetMemoryId ?? this.targetMemoryId,
    relationshipType: relationshipType ?? this.relationshipType,
    score: score.present ? score.value : this.score,
    provenance: provenance ?? this.provenance,
    method: method ?? this.method,
    confirmed: confirmed ?? this.confirmed,
    createdAt: createdAt ?? this.createdAt,
  );
  MemoryRelationshipRow copyWithCompanion(MemoryRelationshipsCompanion data) {
    return MemoryRelationshipRow(
      id: data.id.present ? data.id.value : this.id,
      sourceMemoryId: data.sourceMemoryId.present
          ? data.sourceMemoryId.value
          : this.sourceMemoryId,
      targetMemoryId: data.targetMemoryId.present
          ? data.targetMemoryId.value
          : this.targetMemoryId,
      relationshipType: data.relationshipType.present
          ? data.relationshipType.value
          : this.relationshipType,
      score: data.score.present ? data.score.value : this.score,
      provenance: data.provenance.present
          ? data.provenance.value
          : this.provenance,
      method: data.method.present ? data.method.value : this.method,
      confirmed: data.confirmed.present ? data.confirmed.value : this.confirmed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryRelationshipRow(')
          ..write('id: $id, ')
          ..write('sourceMemoryId: $sourceMemoryId, ')
          ..write('targetMemoryId: $targetMemoryId, ')
          ..write('relationshipType: $relationshipType, ')
          ..write('score: $score, ')
          ..write('provenance: $provenance, ')
          ..write('method: $method, ')
          ..write('confirmed: $confirmed, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceMemoryId,
    targetMemoryId,
    relationshipType,
    score,
    provenance,
    method,
    confirmed,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryRelationshipRow &&
          other.id == this.id &&
          other.sourceMemoryId == this.sourceMemoryId &&
          other.targetMemoryId == this.targetMemoryId &&
          other.relationshipType == this.relationshipType &&
          other.score == this.score &&
          other.provenance == this.provenance &&
          other.method == this.method &&
          other.confirmed == this.confirmed &&
          other.createdAt == this.createdAt);
}

class MemoryRelationshipsCompanion
    extends UpdateCompanion<MemoryRelationshipRow> {
  final Value<int> id;
  final Value<int> sourceMemoryId;
  final Value<int> targetMemoryId;
  final Value<RelationshipType> relationshipType;
  final Value<double?> score;
  final Value<String> provenance;
  final Value<String> method;
  final Value<bool> confirmed;
  final Value<DateTime> createdAt;
  const MemoryRelationshipsCompanion({
    this.id = const Value.absent(),
    this.sourceMemoryId = const Value.absent(),
    this.targetMemoryId = const Value.absent(),
    this.relationshipType = const Value.absent(),
    this.score = const Value.absent(),
    this.provenance = const Value.absent(),
    this.method = const Value.absent(),
    this.confirmed = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MemoryRelationshipsCompanion.insert({
    this.id = const Value.absent(),
    required int sourceMemoryId,
    required int targetMemoryId,
    required RelationshipType relationshipType,
    this.score = const Value.absent(),
    required String provenance,
    required String method,
    this.confirmed = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : sourceMemoryId = Value(sourceMemoryId),
       targetMemoryId = Value(targetMemoryId),
       relationshipType = Value(relationshipType),
       provenance = Value(provenance),
       method = Value(method);
  static Insertable<MemoryRelationshipRow> custom({
    Expression<int>? id,
    Expression<int>? sourceMemoryId,
    Expression<int>? targetMemoryId,
    Expression<String>? relationshipType,
    Expression<double>? score,
    Expression<String>? provenance,
    Expression<String>? method,
    Expression<bool>? confirmed,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceMemoryId != null) 'source_memory_id': sourceMemoryId,
      if (targetMemoryId != null) 'target_memory_id': targetMemoryId,
      if (relationshipType != null) 'relationship_type': relationshipType,
      if (score != null) 'score': score,
      if (provenance != null) 'provenance': provenance,
      if (method != null) 'method': method,
      if (confirmed != null) 'confirmed': confirmed,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MemoryRelationshipsCompanion copyWith({
    Value<int>? id,
    Value<int>? sourceMemoryId,
    Value<int>? targetMemoryId,
    Value<RelationshipType>? relationshipType,
    Value<double?>? score,
    Value<String>? provenance,
    Value<String>? method,
    Value<bool>? confirmed,
    Value<DateTime>? createdAt,
  }) {
    return MemoryRelationshipsCompanion(
      id: id ?? this.id,
      sourceMemoryId: sourceMemoryId ?? this.sourceMemoryId,
      targetMemoryId: targetMemoryId ?? this.targetMemoryId,
      relationshipType: relationshipType ?? this.relationshipType,
      score: score ?? this.score,
      provenance: provenance ?? this.provenance,
      method: method ?? this.method,
      confirmed: confirmed ?? this.confirmed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceMemoryId.present) {
      map['source_memory_id'] = Variable<int>(sourceMemoryId.value);
    }
    if (targetMemoryId.present) {
      map['target_memory_id'] = Variable<int>(targetMemoryId.value);
    }
    if (relationshipType.present) {
      map['relationship_type'] = Variable<String>(
        $MemoryRelationshipsTable.$converterrelationshipType.toSql(
          relationshipType.value,
        ),
      );
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (provenance.present) {
      map['provenance'] = Variable<String>(provenance.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (confirmed.present) {
      map['confirmed'] = Variable<bool>(confirmed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryRelationshipsCompanion(')
          ..write('id: $id, ')
          ..write('sourceMemoryId: $sourceMemoryId, ')
          ..write('targetMemoryId: $targetMemoryId, ')
          ..write('relationshipType: $relationshipType, ')
          ..write('score: $score, ')
          ..write('provenance: $provenance, ')
          ..write('method: $method, ')
          ..write('confirmed: $confirmed, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ModelRegistryTable extends ModelRegistry
    with TableInfo<$ModelRegistryTable, ModelRegistryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModelRegistryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelTypeMeta = const VerificationMeta(
    'modelType',
  );
  @override
  late final GeneratedColumn<String> modelType = GeneratedColumn<String>(
    'model_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ModelInstallState, String>
  installState =
      GeneratedColumn<String>(
        'install_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ModelInstallState>(
        $ModelRegistryTable.$converterinstallState,
      );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _licenseMeta = const VerificationMeta(
    'license',
  );
  @override
  late final GeneratedColumn<String> license = GeneratedColumn<String>(
    'license',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _embeddingSpaceIdMeta = const VerificationMeta(
    'embeddingSpaceId',
  );
  @override
  late final GeneratedColumn<String> embeddingSpaceId = GeneratedColumn<String>(
    'embedding_space_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _installedAtMeta = const VerificationMeta(
    'installedAt',
  );
  @override
  late final GeneratedColumn<DateTime> installedAt = GeneratedColumn<DateTime>(
    'installed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    modelId,
    modelType,
    version,
    path,
    installState,
    sha256,
    sizeBytes,
    license,
    embeddingSpaceId,
    installedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'model_registry';
  @override
  VerificationContext validateIntegrity(
    Insertable<ModelRegistryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('model_type')) {
      context.handle(
        _modelTypeMeta,
        modelType.isAcceptableOrUnknown(data['model_type']!, _modelTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_modelTypeMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('license')) {
      context.handle(
        _licenseMeta,
        license.isAcceptableOrUnknown(data['license']!, _licenseMeta),
      );
    } else if (isInserting) {
      context.missing(_licenseMeta);
    }
    if (data.containsKey('embedding_space_id')) {
      context.handle(
        _embeddingSpaceIdMeta,
        embeddingSpaceId.isAcceptableOrUnknown(
          data['embedding_space_id']!,
          _embeddingSpaceIdMeta,
        ),
      );
    }
    if (data.containsKey('installed_at')) {
      context.handle(
        _installedAtMeta,
        installedAt.isAcceptableOrUnknown(
          data['installed_at']!,
          _installedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {modelId, version};
  @override
  ModelRegistryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModelRegistryRow(
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      modelType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_type'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      ),
      installState: $ModelRegistryTable.$converterinstallState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}install_state'],
        )!,
      ),
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      license: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license'],
      )!,
      embeddingSpaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}embedding_space_id'],
      ),
      installedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}installed_at'],
      ),
    );
  }

  @override
  $ModelRegistryTable createAlias(String alias) {
    return $ModelRegistryTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ModelInstallState, String, String>
  $converterinstallState = const EnumNameConverter<ModelInstallState>(
    ModelInstallState.values,
  );
}

class ModelRegistryRow extends DataClass
    implements Insertable<ModelRegistryRow> {
  final String modelId;
  final String modelType;
  final String version;
  final String? path;
  final ModelInstallState installState;
  final String sha256;
  final int sizeBytes;
  final String license;
  final String? embeddingSpaceId;
  final DateTime? installedAt;
  const ModelRegistryRow({
    required this.modelId,
    required this.modelType,
    required this.version,
    this.path,
    required this.installState,
    required this.sha256,
    required this.sizeBytes,
    required this.license,
    this.embeddingSpaceId,
    this.installedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['model_id'] = Variable<String>(modelId);
    map['model_type'] = Variable<String>(modelType);
    map['version'] = Variable<String>(version);
    if (!nullToAbsent || path != null) {
      map['path'] = Variable<String>(path);
    }
    {
      map['install_state'] = Variable<String>(
        $ModelRegistryTable.$converterinstallState.toSql(installState),
      );
    }
    map['sha256'] = Variable<String>(sha256);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['license'] = Variable<String>(license);
    if (!nullToAbsent || embeddingSpaceId != null) {
      map['embedding_space_id'] = Variable<String>(embeddingSpaceId);
    }
    if (!nullToAbsent || installedAt != null) {
      map['installed_at'] = Variable<DateTime>(installedAt);
    }
    return map;
  }

  ModelRegistryCompanion toCompanion(bool nullToAbsent) {
    return ModelRegistryCompanion(
      modelId: Value(modelId),
      modelType: Value(modelType),
      version: Value(version),
      path: path == null && nullToAbsent ? const Value.absent() : Value(path),
      installState: Value(installState),
      sha256: Value(sha256),
      sizeBytes: Value(sizeBytes),
      license: Value(license),
      embeddingSpaceId: embeddingSpaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(embeddingSpaceId),
      installedAt: installedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(installedAt),
    );
  }

  factory ModelRegistryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModelRegistryRow(
      modelId: serializer.fromJson<String>(json['modelId']),
      modelType: serializer.fromJson<String>(json['modelType']),
      version: serializer.fromJson<String>(json['version']),
      path: serializer.fromJson<String?>(json['path']),
      installState: $ModelRegistryTable.$converterinstallState.fromJson(
        serializer.fromJson<String>(json['installState']),
      ),
      sha256: serializer.fromJson<String>(json['sha256']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      license: serializer.fromJson<String>(json['license']),
      embeddingSpaceId: serializer.fromJson<String?>(json['embeddingSpaceId']),
      installedAt: serializer.fromJson<DateTime?>(json['installedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'modelId': serializer.toJson<String>(modelId),
      'modelType': serializer.toJson<String>(modelType),
      'version': serializer.toJson<String>(version),
      'path': serializer.toJson<String?>(path),
      'installState': serializer.toJson<String>(
        $ModelRegistryTable.$converterinstallState.toJson(installState),
      ),
      'sha256': serializer.toJson<String>(sha256),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'license': serializer.toJson<String>(license),
      'embeddingSpaceId': serializer.toJson<String?>(embeddingSpaceId),
      'installedAt': serializer.toJson<DateTime?>(installedAt),
    };
  }

  ModelRegistryRow copyWith({
    String? modelId,
    String? modelType,
    String? version,
    Value<String?> path = const Value.absent(),
    ModelInstallState? installState,
    String? sha256,
    int? sizeBytes,
    String? license,
    Value<String?> embeddingSpaceId = const Value.absent(),
    Value<DateTime?> installedAt = const Value.absent(),
  }) => ModelRegistryRow(
    modelId: modelId ?? this.modelId,
    modelType: modelType ?? this.modelType,
    version: version ?? this.version,
    path: path.present ? path.value : this.path,
    installState: installState ?? this.installState,
    sha256: sha256 ?? this.sha256,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    license: license ?? this.license,
    embeddingSpaceId: embeddingSpaceId.present
        ? embeddingSpaceId.value
        : this.embeddingSpaceId,
    installedAt: installedAt.present ? installedAt.value : this.installedAt,
  );
  ModelRegistryRow copyWithCompanion(ModelRegistryCompanion data) {
    return ModelRegistryRow(
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      modelType: data.modelType.present ? data.modelType.value : this.modelType,
      version: data.version.present ? data.version.value : this.version,
      path: data.path.present ? data.path.value : this.path,
      installState: data.installState.present
          ? data.installState.value
          : this.installState,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      license: data.license.present ? data.license.value : this.license,
      embeddingSpaceId: data.embeddingSpaceId.present
          ? data.embeddingSpaceId.value
          : this.embeddingSpaceId,
      installedAt: data.installedAt.present
          ? data.installedAt.value
          : this.installedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModelRegistryRow(')
          ..write('modelId: $modelId, ')
          ..write('modelType: $modelType, ')
          ..write('version: $version, ')
          ..write('path: $path, ')
          ..write('installState: $installState, ')
          ..write('sha256: $sha256, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('license: $license, ')
          ..write('embeddingSpaceId: $embeddingSpaceId, ')
          ..write('installedAt: $installedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    modelId,
    modelType,
    version,
    path,
    installState,
    sha256,
    sizeBytes,
    license,
    embeddingSpaceId,
    installedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModelRegistryRow &&
          other.modelId == this.modelId &&
          other.modelType == this.modelType &&
          other.version == this.version &&
          other.path == this.path &&
          other.installState == this.installState &&
          other.sha256 == this.sha256 &&
          other.sizeBytes == this.sizeBytes &&
          other.license == this.license &&
          other.embeddingSpaceId == this.embeddingSpaceId &&
          other.installedAt == this.installedAt);
}

class ModelRegistryCompanion extends UpdateCompanion<ModelRegistryRow> {
  final Value<String> modelId;
  final Value<String> modelType;
  final Value<String> version;
  final Value<String?> path;
  final Value<ModelInstallState> installState;
  final Value<String> sha256;
  final Value<int> sizeBytes;
  final Value<String> license;
  final Value<String?> embeddingSpaceId;
  final Value<DateTime?> installedAt;
  final Value<int> rowid;
  const ModelRegistryCompanion({
    this.modelId = const Value.absent(),
    this.modelType = const Value.absent(),
    this.version = const Value.absent(),
    this.path = const Value.absent(),
    this.installState = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.license = const Value.absent(),
    this.embeddingSpaceId = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModelRegistryCompanion.insert({
    required String modelId,
    required String modelType,
    required String version,
    this.path = const Value.absent(),
    required ModelInstallState installState,
    required String sha256,
    required int sizeBytes,
    required String license,
    this.embeddingSpaceId = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : modelId = Value(modelId),
       modelType = Value(modelType),
       version = Value(version),
       installState = Value(installState),
       sha256 = Value(sha256),
       sizeBytes = Value(sizeBytes),
       license = Value(license);
  static Insertable<ModelRegistryRow> custom({
    Expression<String>? modelId,
    Expression<String>? modelType,
    Expression<String>? version,
    Expression<String>? path,
    Expression<String>? installState,
    Expression<String>? sha256,
    Expression<int>? sizeBytes,
    Expression<String>? license,
    Expression<String>? embeddingSpaceId,
    Expression<DateTime>? installedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (modelId != null) 'model_id': modelId,
      if (modelType != null) 'model_type': modelType,
      if (version != null) 'version': version,
      if (path != null) 'path': path,
      if (installState != null) 'install_state': installState,
      if (sha256 != null) 'sha256': sha256,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (license != null) 'license': license,
      if (embeddingSpaceId != null) 'embedding_space_id': embeddingSpaceId,
      if (installedAt != null) 'installed_at': installedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModelRegistryCompanion copyWith({
    Value<String>? modelId,
    Value<String>? modelType,
    Value<String>? version,
    Value<String?>? path,
    Value<ModelInstallState>? installState,
    Value<String>? sha256,
    Value<int>? sizeBytes,
    Value<String>? license,
    Value<String?>? embeddingSpaceId,
    Value<DateTime?>? installedAt,
    Value<int>? rowid,
  }) {
    return ModelRegistryCompanion(
      modelId: modelId ?? this.modelId,
      modelType: modelType ?? this.modelType,
      version: version ?? this.version,
      path: path ?? this.path,
      installState: installState ?? this.installState,
      sha256: sha256 ?? this.sha256,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      license: license ?? this.license,
      embeddingSpaceId: embeddingSpaceId ?? this.embeddingSpaceId,
      installedAt: installedAt ?? this.installedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (modelType.present) {
      map['model_type'] = Variable<String>(modelType.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (installState.present) {
      map['install_state'] = Variable<String>(
        $ModelRegistryTable.$converterinstallState.toSql(installState.value),
      );
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (license.present) {
      map['license'] = Variable<String>(license.value);
    }
    if (embeddingSpaceId.present) {
      map['embedding_space_id'] = Variable<String>(embeddingSpaceId.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<DateTime>(installedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModelRegistryCompanion(')
          ..write('modelId: $modelId, ')
          ..write('modelType: $modelType, ')
          ..write('version: $version, ')
          ..write('path: $path, ')
          ..write('installState: $installState, ')
          ..write('sha256: $sha256, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('license: $license, ')
          ..write('embeddingSpaceId: $embeddingSpaceId, ')
          ..write('installedAt: $installedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ScreenshotsTable screenshots = $ScreenshotsTable(this);
  late final $OcrResultsTable ocrResults = $OcrResultsTable(this);
  late final $ExtractedEntitiesTable extractedEntities =
      $ExtractedEntitiesTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $CollectionItemsTable collectionItems = $CollectionItemsTable(
    this,
  );
  late final $TagsTable tags = $TagsTable(this);
  late final $ScreenshotTagsTable screenshotTags = $ScreenshotTagsTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $SuggestedActionsTable suggestedActions = $SuggestedActionsTable(
    this,
  );
  late final $WishlistItemsTable wishlistItems = $WishlistItemsTable(this);
  late final $ProcessingJobsTable processingJobs = $ProcessingJobsTable(this);
  late final $SearchHistoryTable searchHistory = $SearchHistoryTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $ClassificationRulesTable classificationRules =
      $ClassificationRulesTable(this);
  late final $MemoryChunksTable memoryChunks = $MemoryChunksTable(this);
  late final $EmbeddingsTable embeddings = $EmbeddingsTable(this);
  late final $SpacesTable spaces = $SpacesTable(this);
  late final $SpaceMembershipsTable spaceMemberships = $SpaceMembershipsTable(
    this,
  );
  late final $MemoryRelationshipsTable memoryRelationships =
      $MemoryRelationshipsTable(this);
  late final $ModelRegistryTable modelRegistry = $ModelRegistryTable(this);
  late final Index idxScreenshotsStatus = Index(
    'idx_screenshots_status',
    'CREATE INDEX idx_screenshots_status ON screenshots (processing_status)',
  );
  late final Index idxScreenshotsCategory = Index(
    'idx_screenshots_category',
    'CREATE INDEX idx_screenshots_category ON screenshots (primary_category_id)',
  );
  late final Index idxScreenshotsImported = Index(
    'idx_screenshots_imported',
    'CREATE INDEX idx_screenshots_imported ON screenshots (imported_at)',
  );
  late final Index idxScreenshotsPhash = Index(
    'idx_screenshots_phash',
    'CREATE INDEX idx_screenshots_phash ON screenshots (perceptual_hash)',
  );
  late final Index idxEntitiesScreenshot = Index(
    'idx_entities_screenshot',
    'CREATE INDEX idx_entities_screenshot ON extracted_entities (screenshot_id)',
  );
  late final Index idxEntitiesType = Index(
    'idx_entities_type',
    'CREATE INDEX idx_entities_type ON extracted_entities (entity_type)',
  );
  late final Index idxCollectionItemsScreenshot = Index(
    'idx_collection_items_screenshot',
    'CREATE INDEX idx_collection_items_screenshot ON collection_items (screenshot_id)',
  );
  late final Index idxScreenshotTagsTag = Index(
    'idx_screenshot_tags_tag',
    'CREATE INDEX idx_screenshot_tags_tag ON screenshot_tags (tag_id)',
  );
  late final Index idxRemindersScheduled = Index(
    'idx_reminders_scheduled',
    'CREATE INDEX idx_reminders_scheduled ON reminders (scheduled_at)',
  );
  late final Index idxRemindersStatus = Index(
    'idx_reminders_status',
    'CREATE INDEX idx_reminders_status ON reminders (status)',
  );
  late final Index idxActionsScreenshot = Index(
    'idx_actions_screenshot',
    'CREATE INDEX idx_actions_screenshot ON suggested_actions (screenshot_id)',
  );
  late final Index idxActionsStatus = Index(
    'idx_actions_status',
    'CREATE INDEX idx_actions_status ON suggested_actions (status)',
  );
  late final Index idxJobsStatus = Index(
    'idx_jobs_status',
    'CREATE INDEX idx_jobs_status ON processing_jobs (status)',
  );
  late final Index idxEmbeddingsMemory = Index(
    'idx_embeddings_memory',
    'CREATE INDEX idx_embeddings_memory ON embeddings (memory_id)',
  );
  late final Index idxEmbeddingsSpace = Index(
    'idx_embeddings_space',
    'CREATE INDEX idx_embeddings_space ON embeddings (space_id)',
  );
  late final Index idxSpaceMembersMemory = Index(
    'idx_space_members_memory',
    'CREATE INDEX idx_space_members_memory ON space_memberships (memory_id)',
  );
  late final Index idxRelationshipsTarget = Index(
    'idx_relationships_target',
    'CREATE INDEX idx_relationships_target ON memory_relationships (target_memory_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    screenshots,
    ocrResults,
    extractedEntities,
    collections,
    collectionItems,
    tags,
    screenshotTags,
    notes,
    reminders,
    suggestedActions,
    wishlistItems,
    processingJobs,
    searchHistory,
    appSettings,
    classificationRules,
    memoryChunks,
    embeddings,
    spaces,
    spaceMemberships,
    memoryRelationships,
    modelRegistry,
    idxScreenshotsStatus,
    idxScreenshotsCategory,
    idxScreenshotsImported,
    idxScreenshotsPhash,
    idxEntitiesScreenshot,
    idxEntitiesType,
    idxCollectionItemsScreenshot,
    idxScreenshotTagsTag,
    idxRemindersScheduled,
    idxRemindersStatus,
    idxActionsScreenshot,
    idxActionsStatus,
    idxJobsStatus,
    idxEmbeddingsMemory,
    idxEmbeddingsSpace,
    idxSpaceMembersMemory,
    idxRelationshipsTarget,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('screenshots', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('screenshots', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'screenshots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ocr_results', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'screenshots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('extracted_entities', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'collections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('collection_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'screenshots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('collection_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'screenshots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('screenshot_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('screenshot_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'screenshots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('notes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'screenshots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminders', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'screenshots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('suggested_actions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'screenshots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('wishlist_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'screenshots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('processing_jobs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('classification_rules', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'screenshots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('memory_chunks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'memory_chunks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('embeddings', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'screenshots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('embeddings', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'screenshots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('spaces', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'spaces',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('space_memberships', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'screenshots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('space_memberships', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'screenshots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('memory_relationships', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'screenshots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('memory_relationships', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  required String slug,
  required String name,
  required String icon,
  required int color,
  Value<bool> isSystem,
  Value<DateTime> createdAt,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<String> slug,
  Value<String> name,
  Value<String> icon,
  Value<int> color,
  Value<bool> isSystem,
  Value<DateTime> createdAt,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ScreenshotsTable, List<ScreenshotRow>>
  _primaryScreenshotsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.screenshots,
    aliasName: 'categories__id__screenshots__primary_category_id',
  );

  $$ScreenshotsTableProcessedTableManager get primaryScreenshots {
    final manager = $$ScreenshotsTableTableManager(
      $_db,
      $_db.screenshots,
    ).filter((f) => f.primaryCategoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_primaryScreenshotsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ScreenshotsTable, List<ScreenshotRow>>
  _suggestedScreenshotsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.screenshots,
    aliasName: 'categories__id__screenshots__suggested_category_id',
  );

  $$ScreenshotsTableProcessedTableManager get suggestedScreenshots {
    final manager = $$ScreenshotsTableTableManager($_db, $_db.screenshots)
        .filter(
          (f) => f.suggestedCategoryId.id.sqlEquals($_itemColumn<int>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _suggestedScreenshotsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ClassificationRulesTable,
    List<ClassificationRuleRow>
  >
  _classificationRulesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.classificationRules,
        aliasName: 'categories__id__classification_rules__category_id',
      );

  $$ClassificationRulesTableProcessedTableManager get classificationRulesRefs {
    final manager = $$ClassificationRulesTableTableManager(
      $_db,
      $_db.classificationRules,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _classificationRulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> primaryScreenshots(
    Expression<bool> Function($$ScreenshotsTableFilterComposer f) f,
  ) {
    final $$ScreenshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.primaryCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableFilterComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> suggestedScreenshots(
    Expression<bool> Function($$ScreenshotsTableFilterComposer f) f,
  ) {
    final $$ScreenshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.suggestedCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableFilterComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> classificationRulesRefs(
    Expression<bool> Function($$ClassificationRulesTableFilterComposer f) f,
  ) {
    final $$ClassificationRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.classificationRules,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClassificationRulesTableFilterComposer(
            $db: $db,
            $table: $db.classificationRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> primaryScreenshots<T extends Object>(
    Expression<T> Function($$ScreenshotsTableAnnotationComposer a) f,
  ) {
    final $$ScreenshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.primaryCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> suggestedScreenshots<T extends Object>(
    Expression<T> Function($$ScreenshotsTableAnnotationComposer a) f,
  ) {
    final $$ScreenshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.suggestedCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> classificationRulesRefs<T extends Object>(
    Expression<T> Function($$ClassificationRulesTableAnnotationComposer a) f,
  ) {
    final $$ClassificationRulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.classificationRules,
          getReferencedColumn: (t) => t.categoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ClassificationRulesTableAnnotationComposer(
                $db: $db,
                $table: $db.classificationRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (CategoryRow, $$CategoriesTableReferences),
          CategoryRow,
          PrefetchHooks Function({
            bool primaryScreenshots,
            bool suggestedScreenshots,
            bool classificationRulesRefs,
          })
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                slug: slug,
                name: name,
                icon: icon,
                color: color,
                isSystem: isSystem,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String slug,
                required String name,
                required String icon,
                required int color,
                Value<bool> isSystem = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                slug: slug,
                name: name,
                icon: icon,
                color: color,
                isSystem: isSystem,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, CategoryRow>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                primaryScreenshots = false,
                suggestedScreenshots = false,
                classificationRulesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (primaryScreenshots) db.screenshots,
                    if (suggestedScreenshots) db.screenshots,
                    if (classificationRulesRefs) db.classificationRules,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (primaryScreenshots)
                        await $_getPrefetchedDataByColumns<
                          CategoryRow,
                          $CategoriesTable,
                          ScreenshotRow,
                          $ScreenshotsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._primaryScreenshotsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).primaryScreenshots,
                          currentColumn: 'id',
                          referencedColumn: 'primary_category_id',
                          typedResults: items,
                        ),
                      if (suggestedScreenshots)
                        await $_getPrefetchedDataByColumns<
                          CategoryRow,
                          $CategoriesTable,
                          ScreenshotRow,
                          $ScreenshotsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._suggestedScreenshotsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).suggestedScreenshots,
                          currentColumn: 'id',
                          referencedColumn: 'suggested_category_id',
                          typedResults: items,
                        ),
                      if (classificationRulesRefs)
                        await $_getPrefetchedDataByColumns<
                          CategoryRow,
                          $CategoriesTable,
                          ClassificationRuleRow,
                          $ClassificationRulesTable
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._classificationRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).classificationRulesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'category_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (CategoryRow, $$CategoriesTableReferences),
      CategoryRow,
      PrefetchHooks Function({
        bool primaryScreenshots,
        bool suggestedScreenshots,
        bool classificationRulesRefs,
      })
    >;
typedef $$ScreenshotsTableCreateCompanionBuilder =
    ScreenshotsCompanion Function({
      Value<int> id,
      Value<String?> originalFilename,
      required String localFilePath,
      Value<String?> thumbnailPath,
      required String contentHash,
      Value<String?> perceptualHash,
      Value<String?> title,
      Value<bool> titleLocked,
      required DateTime importedAt,
      Value<DateTime?> capturedAt,
      required ScreenshotSource source,
      Value<int?> primaryCategoryId,
      Value<int?> suggestedCategoryId,
      Value<double?> classificationScore,
      Value<bool> categoryLocked,
      Value<bool> needsCategoryConfirmation,
      Value<bool> isSensitive,
      required ProcessingStatus processingStatus,
      Value<bool> isFavorite,
      Value<bool> isReviewed,
      Value<bool> isArchived,
      required int fileSize,
      Value<int?> imageWidth,
      Value<int?> imageHeight,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<MemoryType> memoryType,
      Value<String?> mimeType,
      Value<String?> description,
      Value<String?> sourceUrl,
      Value<int?> pageCount,
      Value<int?> durationMs,
      Value<DateTime?> eventAt,
    });
typedef $$ScreenshotsTableUpdateCompanionBuilder =
    ScreenshotsCompanion Function({
      Value<int> id,
      Value<String?> originalFilename,
      Value<String> localFilePath,
      Value<String?> thumbnailPath,
      Value<String> contentHash,
      Value<String?> perceptualHash,
      Value<String?> title,
      Value<bool> titleLocked,
      Value<DateTime> importedAt,
      Value<DateTime?> capturedAt,
      Value<ScreenshotSource> source,
      Value<int?> primaryCategoryId,
      Value<int?> suggestedCategoryId,
      Value<double?> classificationScore,
      Value<bool> categoryLocked,
      Value<bool> needsCategoryConfirmation,
      Value<bool> isSensitive,
      Value<ProcessingStatus> processingStatus,
      Value<bool> isFavorite,
      Value<bool> isReviewed,
      Value<bool> isArchived,
      Value<int> fileSize,
      Value<int?> imageWidth,
      Value<int?> imageHeight,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<MemoryType> memoryType,
      Value<String?> mimeType,
      Value<String?> description,
      Value<String?> sourceUrl,
      Value<int?> pageCount,
      Value<int?> durationMs,
      Value<DateTime?> eventAt,
    });

final class $$ScreenshotsTableReferences
    extends BaseReferences<_$AppDatabase, $ScreenshotsTable, ScreenshotRow> {
  $$ScreenshotsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _primaryCategoryIdTable(_$AppDatabase db) => db
      .categories
      .createAlias('screenshots__primary_category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get primaryCategoryId {
    final $_column = $_itemColumn<int>('primary_category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_primaryCategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _suggestedCategoryIdTable(_$AppDatabase db) => db
      .categories
      .createAlias('screenshots__suggested_category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get suggestedCategoryId {
    final $_column = $_itemColumn<int>('suggested_category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_suggestedCategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$OcrResultsTable, List<OcrResultRow>>
  _ocrResultsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ocrResults,
    aliasName: 'screenshots__id__ocr_results__screenshot_id',
  );

  $$OcrResultsTableProcessedTableManager get ocrResultsRefs {
    final manager = $$OcrResultsTableTableManager(
      $_db,
      $_db.ocrResults,
    ).filter((f) => f.screenshotId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ocrResultsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExtractedEntitiesTable, List<ExtractedEntityRow>>
  _extractedEntitiesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.extractedEntities,
        aliasName: 'screenshots__id__extracted_entities__screenshot_id',
      );

  $$ExtractedEntitiesTableProcessedTableManager get extractedEntitiesRefs {
    final manager = $$ExtractedEntitiesTableTableManager(
      $_db,
      $_db.extractedEntities,
    ).filter((f) => f.screenshotId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _extractedEntitiesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CollectionItemsTable, List<CollectionItemRow>>
  _collectionItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.collectionItems,
    aliasName: 'screenshots__id__collection_items__screenshot_id',
  );

  $$CollectionItemsTableProcessedTableManager get collectionItemsRefs {
    final manager = $$CollectionItemsTableTableManager(
      $_db,
      $_db.collectionItems,
    ).filter((f) => f.screenshotId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _collectionItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ScreenshotTagsTable, List<ScreenshotTagRow>>
  _screenshotTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.screenshotTags,
    aliasName: 'screenshots__id__screenshot_tags__screenshot_id',
  );

  $$ScreenshotTagsTableProcessedTableManager get screenshotTagsRefs {
    final manager = $$ScreenshotTagsTableTableManager(
      $_db,
      $_db.screenshotTags,
    ).filter((f) => f.screenshotId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_screenshotTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NotesTable, List<NoteRow>> _notesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.notes,
    aliasName: 'screenshots__id__notes__screenshot_id',
  );

  $$NotesTableProcessedTableManager get notesRefs {
    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.screenshotId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_notesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RemindersTable, List<ReminderRow>>
  _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: 'screenshots__id__reminders__screenshot_id',
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.screenshotId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SuggestedActionsTable, List<SuggestedActionRow>>
  _suggestedActionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.suggestedActions,
    aliasName: 'screenshots__id__suggested_actions__screenshot_id',
  );

  $$SuggestedActionsTableProcessedTableManager get suggestedActionsRefs {
    final manager = $$SuggestedActionsTableTableManager(
      $_db,
      $_db.suggestedActions,
    ).filter((f) => f.screenshotId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _suggestedActionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WishlistItemsTable, List<WishlistItemRow>>
  _wishlistItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wishlistItems,
    aliasName: 'screenshots__id__wishlist_items__screenshot_id',
  );

  $$WishlistItemsTableProcessedTableManager get wishlistItemsRefs {
    final manager = $$WishlistItemsTableTableManager(
      $_db,
      $_db.wishlistItems,
    ).filter((f) => f.screenshotId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wishlistItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProcessingJobsTable, List<ProcessingJobRow>>
  _processingJobsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.processingJobs,
    aliasName: 'screenshots__id__processing_jobs__screenshot_id',
  );

  $$ProcessingJobsTableProcessedTableManager get processingJobsRefs {
    final manager = $$ProcessingJobsTableTableManager(
      $_db,
      $_db.processingJobs,
    ).filter((f) => f.screenshotId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_processingJobsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MemoryChunksTable, List<MemoryChunkRow>>
  _memoryChunksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.memoryChunks,
    aliasName: 'screenshots__id__memory_chunks__memory_id',
  );

  $$MemoryChunksTableProcessedTableManager get memoryChunksRefs {
    final manager = $$MemoryChunksTableTableManager(
      $_db,
      $_db.memoryChunks,
    ).filter((f) => f.memoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_memoryChunksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EmbeddingsTable, List<EmbeddingRow>>
  _embeddingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.embeddings,
    aliasName: 'screenshots__id__embeddings__memory_id',
  );

  $$EmbeddingsTableProcessedTableManager get embeddingsRefs {
    final manager = $$EmbeddingsTableTableManager(
      $_db,
      $_db.embeddings,
    ).filter((f) => f.memoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_embeddingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SpacesTable, List<SpaceRow>> _spacesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.spaces,
    aliasName: 'screenshots__id__spaces__cover_memory_id',
  );

  $$SpacesTableProcessedTableManager get spacesRefs {
    final manager = $$SpacesTableTableManager(
      $_db,
      $_db.spaces,
    ).filter((f) => f.coverMemoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_spacesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SpaceMembershipsTable, List<SpaceMembershipRow>>
  _spaceMembershipsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.spaceMemberships,
    aliasName: 'screenshots__id__space_memberships__memory_id',
  );

  $$SpaceMembershipsTableProcessedTableManager get spaceMembershipsRefs {
    final manager = $$SpaceMembershipsTableTableManager(
      $_db,
      $_db.spaceMemberships,
    ).filter((f) => f.memoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _spaceMembershipsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MemoryRelationshipsTable,
    List<MemoryRelationshipRow>
  >
  _outgoingRelationshipsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.memoryRelationships,
        aliasName: 'screenshots__id__memory_relationships__source_memory_id',
      );

  $$MemoryRelationshipsTableProcessedTableManager get outgoingRelationships {
    final manager = $$MemoryRelationshipsTableTableManager(
      $_db,
      $_db.memoryRelationships,
    ).filter((f) => f.sourceMemoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _outgoingRelationshipsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MemoryRelationshipsTable,
    List<MemoryRelationshipRow>
  >
  _incomingRelationshipsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.memoryRelationships,
        aliasName: 'screenshots__id__memory_relationships__target_memory_id',
      );

  $$MemoryRelationshipsTableProcessedTableManager get incomingRelationships {
    final manager = $$MemoryRelationshipsTableTableManager(
      $_db,
      $_db.memoryRelationships,
    ).filter((f) => f.targetMemoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _incomingRelationshipsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ScreenshotsTableFilterComposer
    extends Composer<_$AppDatabase, $ScreenshotsTable> {
  $$ScreenshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalFilename => $composableBuilder(
    column: $table.originalFilename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get perceptualHash => $composableBuilder(
    column: $table.perceptualHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get titleLocked => $composableBuilder(
    column: $table.titleLocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ScreenshotSource, ScreenshotSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get classificationScore => $composableBuilder(
    column: $table.classificationScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get categoryLocked => $composableBuilder(
    column: $table.categoryLocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsCategoryConfirmation => $composableBuilder(
    column: $table.needsCategoryConfirmation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSensitive => $composableBuilder(
    column: $table.isSensitive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ProcessingStatus, ProcessingStatus, String>
  get processingStatus => $composableBuilder(
    column: $table.processingStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isReviewed => $composableBuilder(
    column: $table.isReviewed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get imageWidth => $composableBuilder(
    column: $table.imageWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get imageHeight => $composableBuilder(
    column: $table.imageHeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MemoryType, MemoryType, String>
  get memoryType => $composableBuilder(
    column: $table.memoryType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eventAt => $composableBuilder(
    column: $table.eventAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get primaryCategoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.primaryCategoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get suggestedCategoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.suggestedCategoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> ocrResultsRefs(
    Expression<bool> Function($$OcrResultsTableFilterComposer f) f,
  ) {
    final $$OcrResultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ocrResults,
      getReferencedColumn: (t) => t.screenshotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OcrResultsTableFilterComposer(
            $db: $db,
            $table: $db.ocrResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> extractedEntitiesRefs(
    Expression<bool> Function($$ExtractedEntitiesTableFilterComposer f) f,
  ) {
    final $$ExtractedEntitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.extractedEntities,
      getReferencedColumn: (t) => t.screenshotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExtractedEntitiesTableFilterComposer(
            $db: $db,
            $table: $db.extractedEntities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> collectionItemsRefs(
    Expression<bool> Function($$CollectionItemsTableFilterComposer f) f,
  ) {
    final $$CollectionItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionItems,
      getReferencedColumn: (t) => t.screenshotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionItemsTableFilterComposer(
            $db: $db,
            $table: $db.collectionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> screenshotTagsRefs(
    Expression<bool> Function($$ScreenshotTagsTableFilterComposer f) f,
  ) {
    final $$ScreenshotTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.screenshotTags,
      getReferencedColumn: (t) => t.screenshotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotTagsTableFilterComposer(
            $db: $db,
            $table: $db.screenshotTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> notesRefs(
    Expression<bool> Function($$NotesTableFilterComposer f) f,
  ) {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.screenshotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.screenshotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> suggestedActionsRefs(
    Expression<bool> Function($$SuggestedActionsTableFilterComposer f) f,
  ) {
    final $$SuggestedActionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.suggestedActions,
      getReferencedColumn: (t) => t.screenshotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuggestedActionsTableFilterComposer(
            $db: $db,
            $table: $db.suggestedActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> wishlistItemsRefs(
    Expression<bool> Function($$WishlistItemsTableFilterComposer f) f,
  ) {
    final $$WishlistItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wishlistItems,
      getReferencedColumn: (t) => t.screenshotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WishlistItemsTableFilterComposer(
            $db: $db,
            $table: $db.wishlistItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> processingJobsRefs(
    Expression<bool> Function($$ProcessingJobsTableFilterComposer f) f,
  ) {
    final $$ProcessingJobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.processingJobs,
      getReferencedColumn: (t) => t.screenshotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProcessingJobsTableFilterComposer(
            $db: $db,
            $table: $db.processingJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> memoryChunksRefs(
    Expression<bool> Function($$MemoryChunksTableFilterComposer f) f,
  ) {
    final $$MemoryChunksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryChunks,
      getReferencedColumn: (t) => t.memoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryChunksTableFilterComposer(
            $db: $db,
            $table: $db.memoryChunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> embeddingsRefs(
    Expression<bool> Function($$EmbeddingsTableFilterComposer f) f,
  ) {
    final $$EmbeddingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.embeddings,
      getReferencedColumn: (t) => t.memoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmbeddingsTableFilterComposer(
            $db: $db,
            $table: $db.embeddings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> spacesRefs(
    Expression<bool> Function($$SpacesTableFilterComposer f) f,
  ) {
    final $$SpacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.coverMemoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableFilterComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> spaceMembershipsRefs(
    Expression<bool> Function($$SpaceMembershipsTableFilterComposer f) f,
  ) {
    final $$SpaceMembershipsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.spaceMemberships,
      getReferencedColumn: (t) => t.memoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpaceMembershipsTableFilterComposer(
            $db: $db,
            $table: $db.spaceMemberships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> outgoingRelationships(
    Expression<bool> Function($$MemoryRelationshipsTableFilterComposer f) f,
  ) {
    final $$MemoryRelationshipsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryRelationships,
      getReferencedColumn: (t) => t.sourceMemoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryRelationshipsTableFilterComposer(
            $db: $db,
            $table: $db.memoryRelationships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> incomingRelationships(
    Expression<bool> Function($$MemoryRelationshipsTableFilterComposer f) f,
  ) {
    final $$MemoryRelationshipsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryRelationships,
      getReferencedColumn: (t) => t.targetMemoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryRelationshipsTableFilterComposer(
            $db: $db,
            $table: $db.memoryRelationships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScreenshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScreenshotsTable> {
  $$ScreenshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalFilename => $composableBuilder(
    column: $table.originalFilename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get perceptualHash => $composableBuilder(
    column: $table.perceptualHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get titleLocked => $composableBuilder(
    column: $table.titleLocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get classificationScore => $composableBuilder(
    column: $table.classificationScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get categoryLocked => $composableBuilder(
    column: $table.categoryLocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsCategoryConfirmation => $composableBuilder(
    column: $table.needsCategoryConfirmation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSensitive => $composableBuilder(
    column: $table.isSensitive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get processingStatus => $composableBuilder(
    column: $table.processingStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isReviewed => $composableBuilder(
    column: $table.isReviewed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get imageWidth => $composableBuilder(
    column: $table.imageWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get imageHeight => $composableBuilder(
    column: $table.imageHeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memoryType => $composableBuilder(
    column: $table.memoryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eventAt => $composableBuilder(
    column: $table.eventAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get primaryCategoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.primaryCategoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get suggestedCategoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.suggestedCategoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScreenshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScreenshotsTable> {
  $$ScreenshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get originalFilename => $composableBuilder(
    column: $table.originalFilename,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get perceptualHash => $composableBuilder(
    column: $table.perceptualHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get titleLocked => $composableBuilder(
    column: $table.titleLocked,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ScreenshotSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<double> get classificationScore => $composableBuilder(
    column: $table.classificationScore,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get categoryLocked => $composableBuilder(
    column: $table.categoryLocked,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsCategoryConfirmation => $composableBuilder(
    column: $table.needsCategoryConfirmation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSensitive => $composableBuilder(
    column: $table.isSensitive,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ProcessingStatus, String>
  get processingStatus => $composableBuilder(
    column: $table.processingStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isReviewed => $composableBuilder(
    column: $table.isReviewed,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<int> get imageWidth => $composableBuilder(
    column: $table.imageWidth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get imageHeight => $composableBuilder(
    column: $table.imageHeight,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MemoryType, String> get memoryType =>
      $composableBuilder(
        column: $table.memoryType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get eventAt =>
      $composableBuilder(column: $table.eventAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get primaryCategoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.primaryCategoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get suggestedCategoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.suggestedCategoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> ocrResultsRefs<T extends Object>(
    Expression<T> Function($$OcrResultsTableAnnotationComposer a) f,
  ) {
    final $$OcrResultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ocrResults,
      getReferencedColumn: (t) => t.screenshotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OcrResultsTableAnnotationComposer(
            $db: $db,
            $table: $db.ocrResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> extractedEntitiesRefs<T extends Object>(
    Expression<T> Function($$ExtractedEntitiesTableAnnotationComposer a) f,
  ) {
    final $$ExtractedEntitiesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.extractedEntities,
          getReferencedColumn: (t) => t.screenshotId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExtractedEntitiesTableAnnotationComposer(
                $db: $db,
                $table: $db.extractedEntities,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> collectionItemsRefs<T extends Object>(
    Expression<T> Function($$CollectionItemsTableAnnotationComposer a) f,
  ) {
    final $$CollectionItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionItems,
      getReferencedColumn: (t) => t.screenshotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.collectionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> screenshotTagsRefs<T extends Object>(
    Expression<T> Function($$ScreenshotTagsTableAnnotationComposer a) f,
  ) {
    final $$ScreenshotTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.screenshotTags,
      getReferencedColumn: (t) => t.screenshotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.screenshotTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> notesRefs<T extends Object>(
    Expression<T> Function($$NotesTableAnnotationComposer a) f,
  ) {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.screenshotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.screenshotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> suggestedActionsRefs<T extends Object>(
    Expression<T> Function($$SuggestedActionsTableAnnotationComposer a) f,
  ) {
    final $$SuggestedActionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.suggestedActions,
      getReferencedColumn: (t) => t.screenshotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuggestedActionsTableAnnotationComposer(
            $db: $db,
            $table: $db.suggestedActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> wishlistItemsRefs<T extends Object>(
    Expression<T> Function($$WishlistItemsTableAnnotationComposer a) f,
  ) {
    final $$WishlistItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wishlistItems,
      getReferencedColumn: (t) => t.screenshotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WishlistItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.wishlistItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> processingJobsRefs<T extends Object>(
    Expression<T> Function($$ProcessingJobsTableAnnotationComposer a) f,
  ) {
    final $$ProcessingJobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.processingJobs,
      getReferencedColumn: (t) => t.screenshotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProcessingJobsTableAnnotationComposer(
            $db: $db,
            $table: $db.processingJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> memoryChunksRefs<T extends Object>(
    Expression<T> Function($$MemoryChunksTableAnnotationComposer a) f,
  ) {
    final $$MemoryChunksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryChunks,
      getReferencedColumn: (t) => t.memoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryChunksTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryChunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> embeddingsRefs<T extends Object>(
    Expression<T> Function($$EmbeddingsTableAnnotationComposer a) f,
  ) {
    final $$EmbeddingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.embeddings,
      getReferencedColumn: (t) => t.memoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmbeddingsTableAnnotationComposer(
            $db: $db,
            $table: $db.embeddings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> spacesRefs<T extends Object>(
    Expression<T> Function($$SpacesTableAnnotationComposer a) f,
  ) {
    final $$SpacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.coverMemoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableAnnotationComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> spaceMembershipsRefs<T extends Object>(
    Expression<T> Function($$SpaceMembershipsTableAnnotationComposer a) f,
  ) {
    final $$SpaceMembershipsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.spaceMemberships,
      getReferencedColumn: (t) => t.memoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpaceMembershipsTableAnnotationComposer(
            $db: $db,
            $table: $db.spaceMemberships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> outgoingRelationships<T extends Object>(
    Expression<T> Function($$MemoryRelationshipsTableAnnotationComposer a) f,
  ) {
    final $$MemoryRelationshipsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.memoryRelationships,
          getReferencedColumn: (t) => t.sourceMemoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MemoryRelationshipsTableAnnotationComposer(
                $db: $db,
                $table: $db.memoryRelationships,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> incomingRelationships<T extends Object>(
    Expression<T> Function($$MemoryRelationshipsTableAnnotationComposer a) f,
  ) {
    final $$MemoryRelationshipsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.memoryRelationships,
          getReferencedColumn: (t) => t.targetMemoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MemoryRelationshipsTableAnnotationComposer(
                $db: $db,
                $table: $db.memoryRelationships,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ScreenshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScreenshotsTable,
          ScreenshotRow,
          $$ScreenshotsTableFilterComposer,
          $$ScreenshotsTableOrderingComposer,
          $$ScreenshotsTableAnnotationComposer,
          $$ScreenshotsTableCreateCompanionBuilder,
          $$ScreenshotsTableUpdateCompanionBuilder,
          (ScreenshotRow, $$ScreenshotsTableReferences),
          ScreenshotRow,
          PrefetchHooks Function({
            bool primaryCategoryId,
            bool suggestedCategoryId,
            bool ocrResultsRefs,
            bool extractedEntitiesRefs,
            bool collectionItemsRefs,
            bool screenshotTagsRefs,
            bool notesRefs,
            bool remindersRefs,
            bool suggestedActionsRefs,
            bool wishlistItemsRefs,
            bool processingJobsRefs,
            bool memoryChunksRefs,
            bool embeddingsRefs,
            bool spacesRefs,
            bool spaceMembershipsRefs,
            bool outgoingRelationships,
            bool incomingRelationships,
          })
        > {
  $$ScreenshotsTableTableManager(_$AppDatabase db, $ScreenshotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScreenshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScreenshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScreenshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> originalFilename = const Value.absent(),
                Value<String> localFilePath = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<String?> perceptualHash = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<bool> titleLocked = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<DateTime?> capturedAt = const Value.absent(),
                Value<ScreenshotSource> source = const Value.absent(),
                Value<int?> primaryCategoryId = const Value.absent(),
                Value<int?> suggestedCategoryId = const Value.absent(),
                Value<double?> classificationScore = const Value.absent(),
                Value<bool> categoryLocked = const Value.absent(),
                Value<bool> needsCategoryConfirmation = const Value.absent(),
                Value<bool> isSensitive = const Value.absent(),
                Value<ProcessingStatus> processingStatus = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isReviewed = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<int?> imageWidth = const Value.absent(),
                Value<int?> imageHeight = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<MemoryType> memoryType = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<DateTime?> eventAt = const Value.absent(),
              }) => ScreenshotsCompanion(
                id: id,
                originalFilename: originalFilename,
                localFilePath: localFilePath,
                thumbnailPath: thumbnailPath,
                contentHash: contentHash,
                perceptualHash: perceptualHash,
                title: title,
                titleLocked: titleLocked,
                importedAt: importedAt,
                capturedAt: capturedAt,
                source: source,
                primaryCategoryId: primaryCategoryId,
                suggestedCategoryId: suggestedCategoryId,
                classificationScore: classificationScore,
                categoryLocked: categoryLocked,
                needsCategoryConfirmation: needsCategoryConfirmation,
                isSensitive: isSensitive,
                processingStatus: processingStatus,
                isFavorite: isFavorite,
                isReviewed: isReviewed,
                isArchived: isArchived,
                fileSize: fileSize,
                imageWidth: imageWidth,
                imageHeight: imageHeight,
                createdAt: createdAt,
                updatedAt: updatedAt,
                memoryType: memoryType,
                mimeType: mimeType,
                description: description,
                sourceUrl: sourceUrl,
                pageCount: pageCount,
                durationMs: durationMs,
                eventAt: eventAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> originalFilename = const Value.absent(),
                required String localFilePath,
                Value<String?> thumbnailPath = const Value.absent(),
                required String contentHash,
                Value<String?> perceptualHash = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<bool> titleLocked = const Value.absent(),
                required DateTime importedAt,
                Value<DateTime?> capturedAt = const Value.absent(),
                required ScreenshotSource source,
                Value<int?> primaryCategoryId = const Value.absent(),
                Value<int?> suggestedCategoryId = const Value.absent(),
                Value<double?> classificationScore = const Value.absent(),
                Value<bool> categoryLocked = const Value.absent(),
                Value<bool> needsCategoryConfirmation = const Value.absent(),
                Value<bool> isSensitive = const Value.absent(),
                required ProcessingStatus processingStatus,
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isReviewed = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                required int fileSize,
                Value<int?> imageWidth = const Value.absent(),
                Value<int?> imageHeight = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<MemoryType> memoryType = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<DateTime?> eventAt = const Value.absent(),
              }) => ScreenshotsCompanion.insert(
                id: id,
                originalFilename: originalFilename,
                localFilePath: localFilePath,
                thumbnailPath: thumbnailPath,
                contentHash: contentHash,
                perceptualHash: perceptualHash,
                title: title,
                titleLocked: titleLocked,
                importedAt: importedAt,
                capturedAt: capturedAt,
                source: source,
                primaryCategoryId: primaryCategoryId,
                suggestedCategoryId: suggestedCategoryId,
                classificationScore: classificationScore,
                categoryLocked: categoryLocked,
                needsCategoryConfirmation: needsCategoryConfirmation,
                isSensitive: isSensitive,
                processingStatus: processingStatus,
                isFavorite: isFavorite,
                isReviewed: isReviewed,
                isArchived: isArchived,
                fileSize: fileSize,
                imageWidth: imageWidth,
                imageHeight: imageHeight,
                createdAt: createdAt,
                updatedAt: updatedAt,
                memoryType: memoryType,
                mimeType: mimeType,
                description: description,
                sourceUrl: sourceUrl,
                pageCount: pageCount,
                durationMs: durationMs,
                eventAt: eventAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScreenshotsTable, ScreenshotRow>(table),
                  $$ScreenshotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                primaryCategoryId = false,
                suggestedCategoryId = false,
                ocrResultsRefs = false,
                extractedEntitiesRefs = false,
                collectionItemsRefs = false,
                screenshotTagsRefs = false,
                notesRefs = false,
                remindersRefs = false,
                suggestedActionsRefs = false,
                wishlistItemsRefs = false,
                processingJobsRefs = false,
                memoryChunksRefs = false,
                embeddingsRefs = false,
                spacesRefs = false,
                spaceMembershipsRefs = false,
                outgoingRelationships = false,
                incomingRelationships = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (ocrResultsRefs) db.ocrResults,
                    if (extractedEntitiesRefs) db.extractedEntities,
                    if (collectionItemsRefs) db.collectionItems,
                    if (screenshotTagsRefs) db.screenshotTags,
                    if (notesRefs) db.notes,
                    if (remindersRefs) db.reminders,
                    if (suggestedActionsRefs) db.suggestedActions,
                    if (wishlistItemsRefs) db.wishlistItems,
                    if (processingJobsRefs) db.processingJobs,
                    if (memoryChunksRefs) db.memoryChunks,
                    if (embeddingsRefs) db.embeddings,
                    if (spacesRefs) db.spaces,
                    if (spaceMembershipsRefs) db.spaceMemberships,
                    if (outgoingRelationships) db.memoryRelationships,
                    if (incomingRelationships) db.memoryRelationships,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (primaryCategoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.primaryCategoryId,
                            referencedTable: $$ScreenshotsTableReferences
                                ._primaryCategoryIdTable(db),
                            referencedColumn: $$ScreenshotsTableReferences
                                ._primaryCategoryIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (suggestedCategoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.suggestedCategoryId,
                            referencedTable: $$ScreenshotsTableReferences
                                ._suggestedCategoryIdTable(db),
                            referencedColumn: $$ScreenshotsTableReferences
                                ._suggestedCategoryIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (ocrResultsRefs)
                        await $_getPrefetchedDataByColumns<
                          ScreenshotRow,
                          $ScreenshotsTable,
                          OcrResultRow,
                          $OcrResultsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ScreenshotsTableReferences
                              ._ocrResultsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScreenshotsTableReferences(
                                db,
                                table,
                                p0,
                              ).ocrResultsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'screenshot_id',
                          typedResults: items,
                        ),
                      if (extractedEntitiesRefs)
                        await $_getPrefetchedDataByColumns<
                          ScreenshotRow,
                          $ScreenshotsTable,
                          ExtractedEntityRow,
                          $ExtractedEntitiesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ScreenshotsTableReferences
                              ._extractedEntitiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScreenshotsTableReferences(
                                db,
                                table,
                                p0,
                              ).extractedEntitiesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'screenshot_id',
                          typedResults: items,
                        ),
                      if (collectionItemsRefs)
                        await $_getPrefetchedDataByColumns<
                          ScreenshotRow,
                          $ScreenshotsTable,
                          CollectionItemRow,
                          $CollectionItemsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ScreenshotsTableReferences
                              ._collectionItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScreenshotsTableReferences(
                                db,
                                table,
                                p0,
                              ).collectionItemsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'screenshot_id',
                          typedResults: items,
                        ),
                      if (screenshotTagsRefs)
                        await $_getPrefetchedDataByColumns<
                          ScreenshotRow,
                          $ScreenshotsTable,
                          ScreenshotTagRow,
                          $ScreenshotTagsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ScreenshotsTableReferences
                              ._screenshotTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScreenshotsTableReferences(
                                db,
                                table,
                                p0,
                              ).screenshotTagsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'screenshot_id',
                          typedResults: items,
                        ),
                      if (notesRefs)
                        await $_getPrefetchedDataByColumns<
                          ScreenshotRow,
                          $ScreenshotsTable,
                          NoteRow,
                          $NotesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ScreenshotsTableReferences
                              ._notesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScreenshotsTableReferences(
                                db,
                                table,
                                p0,
                              ).notesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'screenshot_id',
                          typedResults: items,
                        ),
                      if (remindersRefs)
                        await $_getPrefetchedDataByColumns<
                          ScreenshotRow,
                          $ScreenshotsTable,
                          ReminderRow,
                          $RemindersTable
                        >(
                          currentTable: table,
                          referencedTable: $$ScreenshotsTableReferences
                              ._remindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScreenshotsTableReferences(
                                db,
                                table,
                                p0,
                              ).remindersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'screenshot_id',
                          typedResults: items,
                        ),
                      if (suggestedActionsRefs)
                        await $_getPrefetchedDataByColumns<
                          ScreenshotRow,
                          $ScreenshotsTable,
                          SuggestedActionRow,
                          $SuggestedActionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ScreenshotsTableReferences
                              ._suggestedActionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScreenshotsTableReferences(
                                db,
                                table,
                                p0,
                              ).suggestedActionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'screenshot_id',
                          typedResults: items,
                        ),
                      if (wishlistItemsRefs)
                        await $_getPrefetchedDataByColumns<
                          ScreenshotRow,
                          $ScreenshotsTable,
                          WishlistItemRow,
                          $WishlistItemsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ScreenshotsTableReferences
                              ._wishlistItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScreenshotsTableReferences(
                                db,
                                table,
                                p0,
                              ).wishlistItemsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'screenshot_id',
                          typedResults: items,
                        ),
                      if (processingJobsRefs)
                        await $_getPrefetchedDataByColumns<
                          ScreenshotRow,
                          $ScreenshotsTable,
                          ProcessingJobRow,
                          $ProcessingJobsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ScreenshotsTableReferences
                              ._processingJobsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScreenshotsTableReferences(
                                db,
                                table,
                                p0,
                              ).processingJobsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'screenshot_id',
                          typedResults: items,
                        ),
                      if (memoryChunksRefs)
                        await $_getPrefetchedDataByColumns<
                          ScreenshotRow,
                          $ScreenshotsTable,
                          MemoryChunkRow,
                          $MemoryChunksTable
                        >(
                          currentTable: table,
                          referencedTable: $$ScreenshotsTableReferences
                              ._memoryChunksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScreenshotsTableReferences(
                                db,
                                table,
                                p0,
                              ).memoryChunksRefs,
                          currentColumn: 'id',
                          referencedColumn: 'memory_id',
                          typedResults: items,
                        ),
                      if (embeddingsRefs)
                        await $_getPrefetchedDataByColumns<
                          ScreenshotRow,
                          $ScreenshotsTable,
                          EmbeddingRow,
                          $EmbeddingsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ScreenshotsTableReferences
                              ._embeddingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScreenshotsTableReferences(
                                db,
                                table,
                                p0,
                              ).embeddingsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'memory_id',
                          typedResults: items,
                        ),
                      if (spacesRefs)
                        await $_getPrefetchedDataByColumns<
                          ScreenshotRow,
                          $ScreenshotsTable,
                          SpaceRow,
                          $SpacesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ScreenshotsTableReferences
                              ._spacesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScreenshotsTableReferences(
                                db,
                                table,
                                p0,
                              ).spacesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'cover_memory_id',
                          typedResults: items,
                        ),
                      if (spaceMembershipsRefs)
                        await $_getPrefetchedDataByColumns<
                          ScreenshotRow,
                          $ScreenshotsTable,
                          SpaceMembershipRow,
                          $SpaceMembershipsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ScreenshotsTableReferences
                              ._spaceMembershipsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScreenshotsTableReferences(
                                db,
                                table,
                                p0,
                              ).spaceMembershipsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'memory_id',
                          typedResults: items,
                        ),
                      if (outgoingRelationships)
                        await $_getPrefetchedDataByColumns<
                          ScreenshotRow,
                          $ScreenshotsTable,
                          MemoryRelationshipRow,
                          $MemoryRelationshipsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ScreenshotsTableReferences
                              ._outgoingRelationshipsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScreenshotsTableReferences(
                                db,
                                table,
                                p0,
                              ).outgoingRelationships,
                          currentColumn: 'id',
                          referencedColumn: 'source_memory_id',
                          typedResults: items,
                        ),
                      if (incomingRelationships)
                        await $_getPrefetchedDataByColumns<
                          ScreenshotRow,
                          $ScreenshotsTable,
                          MemoryRelationshipRow,
                          $MemoryRelationshipsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ScreenshotsTableReferences
                              ._incomingRelationshipsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScreenshotsTableReferences(
                                db,
                                table,
                                p0,
                              ).incomingRelationships,
                          currentColumn: 'id',
                          referencedColumn: 'target_memory_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ScreenshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScreenshotsTable,
      ScreenshotRow,
      $$ScreenshotsTableFilterComposer,
      $$ScreenshotsTableOrderingComposer,
      $$ScreenshotsTableAnnotationComposer,
      $$ScreenshotsTableCreateCompanionBuilder,
      $$ScreenshotsTableUpdateCompanionBuilder,
      (ScreenshotRow, $$ScreenshotsTableReferences),
      ScreenshotRow,
      PrefetchHooks Function({
        bool primaryCategoryId,
        bool suggestedCategoryId,
        bool ocrResultsRefs,
        bool extractedEntitiesRefs,
        bool collectionItemsRefs,
        bool screenshotTagsRefs,
        bool notesRefs,
        bool remindersRefs,
        bool suggestedActionsRefs,
        bool wishlistItemsRefs,
        bool processingJobsRefs,
        bool memoryChunksRefs,
        bool embeddingsRefs,
        bool spacesRefs,
        bool spaceMembershipsRefs,
        bool outgoingRelationships,
        bool incomingRelationships,
      })
    >;
typedef $$OcrResultsTableCreateCompanionBuilder = OcrResultsCompanion Function({
  Value<int> id,
  required int screenshotId,
  required String rawText,
  Value<String?> correctedText,
  required String textBlocksJson,
  required String recognizerName,
  required String recognizerVersion,
  required DateTime processedAt,
});
typedef $$OcrResultsTableUpdateCompanionBuilder = OcrResultsCompanion Function({
  Value<int> id,
  Value<int> screenshotId,
  Value<String> rawText,
  Value<String?> correctedText,
  Value<String> textBlocksJson,
  Value<String> recognizerName,
  Value<String> recognizerVersion,
  Value<DateTime> processedAt,
});

final class $$OcrResultsTableReferences
    extends BaseReferences<_$AppDatabase, $OcrResultsTable, OcrResultRow> {
  $$OcrResultsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ScreenshotsTable _screenshotIdTable(_$AppDatabase db) =>
      db.screenshots.createAlias('ocr_results__screenshot_id__screenshots__id');

  $$ScreenshotsTableProcessedTableManager get screenshotId {
    final $_column = $_itemColumn<int>('screenshot_id')!;

    final manager = $$ScreenshotsTableTableManager(
      $_db,
      $_db.screenshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_screenshotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OcrResultsTableFilterComposer
    extends Composer<_$AppDatabase, $OcrResultsTable> {
  $$OcrResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctedText => $composableBuilder(
    column: $table.correctedText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textBlocksJson => $composableBuilder(
    column: $table.textBlocksJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recognizerName => $composableBuilder(
    column: $table.recognizerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recognizerVersion => $composableBuilder(
    column: $table.recognizerVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ScreenshotsTableFilterComposer get screenshotId {
    final $$ScreenshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableFilterComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OcrResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $OcrResultsTable> {
  $$OcrResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctedText => $composableBuilder(
    column: $table.correctedText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textBlocksJson => $composableBuilder(
    column: $table.textBlocksJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recognizerName => $composableBuilder(
    column: $table.recognizerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recognizerVersion => $composableBuilder(
    column: $table.recognizerVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScreenshotsTableOrderingComposer get screenshotId {
    final $$ScreenshotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableOrderingComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OcrResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OcrResultsTable> {
  $$OcrResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<String> get correctedText => $composableBuilder(
    column: $table.correctedText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textBlocksJson => $composableBuilder(
    column: $table.textBlocksJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recognizerName => $composableBuilder(
    column: $table.recognizerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recognizerVersion => $composableBuilder(
    column: $table.recognizerVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => column,
  );

  $$ScreenshotsTableAnnotationComposer get screenshotId {
    final $$ScreenshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OcrResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OcrResultsTable,
          OcrResultRow,
          $$OcrResultsTableFilterComposer,
          $$OcrResultsTableOrderingComposer,
          $$OcrResultsTableAnnotationComposer,
          $$OcrResultsTableCreateCompanionBuilder,
          $$OcrResultsTableUpdateCompanionBuilder,
          (OcrResultRow, $$OcrResultsTableReferences),
          OcrResultRow,
          PrefetchHooks Function({bool screenshotId})
        > {
  $$OcrResultsTableTableManager(_$AppDatabase db, $OcrResultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OcrResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OcrResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OcrResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> screenshotId = const Value.absent(),
                Value<String> rawText = const Value.absent(),
                Value<String?> correctedText = const Value.absent(),
                Value<String> textBlocksJson = const Value.absent(),
                Value<String> recognizerName = const Value.absent(),
                Value<String> recognizerVersion = const Value.absent(),
                Value<DateTime> processedAt = const Value.absent(),
              }) => OcrResultsCompanion(
                id: id,
                screenshotId: screenshotId,
                rawText: rawText,
                correctedText: correctedText,
                textBlocksJson: textBlocksJson,
                recognizerName: recognizerName,
                recognizerVersion: recognizerVersion,
                processedAt: processedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int screenshotId,
                required String rawText,
                Value<String?> correctedText = const Value.absent(),
                required String textBlocksJson,
                required String recognizerName,
                required String recognizerVersion,
                required DateTime processedAt,
              }) => OcrResultsCompanion.insert(
                id: id,
                screenshotId: screenshotId,
                rawText: rawText,
                correctedText: correctedText,
                textBlocksJson: textBlocksJson,
                recognizerName: recognizerName,
                recognizerVersion: recognizerVersion,
                processedAt: processedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OcrResultsTable, OcrResultRow>(table),
                  $$OcrResultsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({screenshotId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (screenshotId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.screenshotId,
                        referencedTable: $$OcrResultsTableReferences
                            ._screenshotIdTable(db),
                        referencedColumn: $$OcrResultsTableReferences
                            ._screenshotIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OcrResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OcrResultsTable,
      OcrResultRow,
      $$OcrResultsTableFilterComposer,
      $$OcrResultsTableOrderingComposer,
      $$OcrResultsTableAnnotationComposer,
      $$OcrResultsTableCreateCompanionBuilder,
      $$OcrResultsTableUpdateCompanionBuilder,
      (OcrResultRow, $$OcrResultsTableReferences),
      OcrResultRow,
      PrefetchHooks Function({bool screenshotId})
    >;
typedef $$ExtractedEntitiesTableCreateCompanionBuilder =
    ExtractedEntitiesCompanion Function({
      Value<int> id,
      required int screenshotId,
      required EntityType entityType,
      required String rawValue,
      Value<String?> normalizedValue,
      Value<String?> metadataJson,
      required ValidationStatus validationStatus,
      Value<DateTime> createdAt,
    });
typedef $$ExtractedEntitiesTableUpdateCompanionBuilder =
    ExtractedEntitiesCompanion Function({
      Value<int> id,
      Value<int> screenshotId,
      Value<EntityType> entityType,
      Value<String> rawValue,
      Value<String?> normalizedValue,
      Value<String?> metadataJson,
      Value<ValidationStatus> validationStatus,
      Value<DateTime> createdAt,
    });

final class $$ExtractedEntitiesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ExtractedEntitiesTable,
          ExtractedEntityRow
        > {
  $$ExtractedEntitiesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ScreenshotsTable _screenshotIdTable(_$AppDatabase db) => db
      .screenshots
      .createAlias('extracted_entities__screenshot_id__screenshots__id');

  $$ScreenshotsTableProcessedTableManager get screenshotId {
    final $_column = $_itemColumn<int>('screenshot_id')!;

    final manager = $$ScreenshotsTableTableManager(
      $_db,
      $_db.screenshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_screenshotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExtractedEntitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ExtractedEntitiesTable> {
  $$ExtractedEntitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EntityType, EntityType, String>
  get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get rawValue => $composableBuilder(
    column: $table.rawValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedValue => $composableBuilder(
    column: $table.normalizedValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ValidationStatus, ValidationStatus, String>
  get validationStatus => $composableBuilder(
    column: $table.validationStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ScreenshotsTableFilterComposer get screenshotId {
    final $$ScreenshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableFilterComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExtractedEntitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExtractedEntitiesTable> {
  $$ExtractedEntitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawValue => $composableBuilder(
    column: $table.rawValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedValue => $composableBuilder(
    column: $table.normalizedValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get validationStatus => $composableBuilder(
    column: $table.validationStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScreenshotsTableOrderingComposer get screenshotId {
    final $$ScreenshotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableOrderingComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExtractedEntitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExtractedEntitiesTable> {
  $$ExtractedEntitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EntityType, String> get entityType =>
      $composableBuilder(
        column: $table.entityType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get rawValue =>
      $composableBuilder(column: $table.rawValue, builder: (column) => column);

  GeneratedColumn<String> get normalizedValue => $composableBuilder(
    column: $table.normalizedValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ValidationStatus, String>
  get validationStatus => $composableBuilder(
    column: $table.validationStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ScreenshotsTableAnnotationComposer get screenshotId {
    final $$ScreenshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExtractedEntitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExtractedEntitiesTable,
          ExtractedEntityRow,
          $$ExtractedEntitiesTableFilterComposer,
          $$ExtractedEntitiesTableOrderingComposer,
          $$ExtractedEntitiesTableAnnotationComposer,
          $$ExtractedEntitiesTableCreateCompanionBuilder,
          $$ExtractedEntitiesTableUpdateCompanionBuilder,
          (ExtractedEntityRow, $$ExtractedEntitiesTableReferences),
          ExtractedEntityRow,
          PrefetchHooks Function({bool screenshotId})
        > {
  $$ExtractedEntitiesTableTableManager(
    _$AppDatabase db,
    $ExtractedEntitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExtractedEntitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExtractedEntitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExtractedEntitiesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> screenshotId = const Value.absent(),
                Value<EntityType> entityType = const Value.absent(),
                Value<String> rawValue = const Value.absent(),
                Value<String?> normalizedValue = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                Value<ValidationStatus> validationStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ExtractedEntitiesCompanion(
                id: id,
                screenshotId: screenshotId,
                entityType: entityType,
                rawValue: rawValue,
                normalizedValue: normalizedValue,
                metadataJson: metadataJson,
                validationStatus: validationStatus,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int screenshotId,
                required EntityType entityType,
                required String rawValue,
                Value<String?> normalizedValue = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                required ValidationStatus validationStatus,
                Value<DateTime> createdAt = const Value.absent(),
              }) => ExtractedEntitiesCompanion.insert(
                id: id,
                screenshotId: screenshotId,
                entityType: entityType,
                rawValue: rawValue,
                normalizedValue: normalizedValue,
                metadataJson: metadataJson,
                validationStatus: validationStatus,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExtractedEntitiesTable, ExtractedEntityRow>(
                    table,
                  ),
                  $$ExtractedEntitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({screenshotId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (screenshotId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.screenshotId,
                        referencedTable: $$ExtractedEntitiesTableReferences
                            ._screenshotIdTable(db),
                        referencedColumn: $$ExtractedEntitiesTableReferences
                            ._screenshotIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExtractedEntitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExtractedEntitiesTable,
      ExtractedEntityRow,
      $$ExtractedEntitiesTableFilterComposer,
      $$ExtractedEntitiesTableOrderingComposer,
      $$ExtractedEntitiesTableAnnotationComposer,
      $$ExtractedEntitiesTableCreateCompanionBuilder,
      $$ExtractedEntitiesTableUpdateCompanionBuilder,
      (ExtractedEntityRow, $$ExtractedEntitiesTableReferences),
      ExtractedEntityRow,
      PrefetchHooks Function({bool screenshotId})
    >;
typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> description,
      required String icon,
      required int color,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> description,
      Value<String> icon,
      Value<int> color,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$CollectionsTableReferences
    extends BaseReferences<_$AppDatabase, $CollectionsTable, CollectionRow> {
  $$CollectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CollectionItemsTable, List<CollectionItemRow>>
  _collectionItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.collectionItems,
    aliasName: 'collections__id__collection_items__collection_id',
  );

  $$CollectionItemsTableProcessedTableManager get collectionItemsRefs {
    final manager = $$CollectionItemsTableTableManager(
      $_db,
      $_db.collectionItems,
    ).filter((f) => f.collectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _collectionItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> collectionItemsRefs(
    Expression<bool> Function($$CollectionItemsTableFilterComposer f) f,
  ) {
    final $$CollectionItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionItems,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionItemsTableFilterComposer(
            $db: $db,
            $table: $db.collectionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> collectionItemsRefs<T extends Object>(
    Expression<T> Function($$CollectionItemsTableAnnotationComposer a) f,
  ) {
    final $$CollectionItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionItems,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.collectionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionsTable,
          CollectionRow,
          $$CollectionsTableFilterComposer,
          $$CollectionsTableOrderingComposer,
          $$CollectionsTableAnnotationComposer,
          $$CollectionsTableCreateCompanionBuilder,
          $$CollectionsTableUpdateCompanionBuilder,
          (CollectionRow, $$CollectionsTableReferences),
          CollectionRow,
          PrefetchHooks Function({bool collectionItemsRefs})
        > {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CollectionsCompanion(
                id: id,
                name: name,
                description: description,
                icon: icon,
                color: color,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                required String icon,
                required int color,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CollectionsCompanion.insert(
                id: id,
                name: name,
                description: description,
                icon: icon,
                color: color,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CollectionsTable, CollectionRow>(table),
                  $$CollectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({collectionItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (collectionItemsRefs) db.collectionItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (collectionItemsRefs)
                    await $_getPrefetchedDataByColumns<
                      CollectionRow,
                      $CollectionsTable,
                      CollectionItemRow,
                      $CollectionItemsTable
                    >(
                      currentTable: table,
                      referencedTable: $$CollectionsTableReferences
                          ._collectionItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CollectionsTableReferences(
                            db,
                            table,
                            p0,
                          ).collectionItemsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'collection_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionsTable,
      CollectionRow,
      $$CollectionsTableFilterComposer,
      $$CollectionsTableOrderingComposer,
      $$CollectionsTableAnnotationComposer,
      $$CollectionsTableCreateCompanionBuilder,
      $$CollectionsTableUpdateCompanionBuilder,
      (CollectionRow, $$CollectionsTableReferences),
      CollectionRow,
      PrefetchHooks Function({bool collectionItemsRefs})
    >;
typedef $$CollectionItemsTableCreateCompanionBuilder =
    CollectionItemsCompanion Function({
      required int collectionId,
      required int screenshotId,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });
typedef $$CollectionItemsTableUpdateCompanionBuilder =
    CollectionItemsCompanion Function({
      Value<int> collectionId,
      Value<int> screenshotId,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });

final class $$CollectionItemsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CollectionItemsTable,
          CollectionItemRow
        > {
  $$CollectionItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CollectionsTable _collectionIdTable(_$AppDatabase db) => db
      .collections
      .createAlias('collection_items__collection_id__collections__id');

  $$CollectionsTableProcessedTableManager get collectionId {
    final $_column = $_itemColumn<int>('collection_id')!;

    final manager = $$CollectionsTableTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ScreenshotsTable _screenshotIdTable(_$AppDatabase db) => db
      .screenshots
      .createAlias('collection_items__screenshot_id__screenshots__id');

  $$ScreenshotsTableProcessedTableManager get screenshotId {
    final $_column = $_itemColumn<int>('screenshot_id')!;

    final manager = $$ScreenshotsTableTableManager(
      $_db,
      $_db.screenshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_screenshotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CollectionItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionItemsTable> {
  $$CollectionItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScreenshotsTableFilterComposer get screenshotId {
    final $$ScreenshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableFilterComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionItemsTable> {
  $$CollectionItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScreenshotsTableOrderingComposer get screenshotId {
    final $$ScreenshotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableOrderingComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionItemsTable> {
  $$CollectionItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScreenshotsTableAnnotationComposer get screenshotId {
    final $$ScreenshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionItemsTable,
          CollectionItemRow,
          $$CollectionItemsTableFilterComposer,
          $$CollectionItemsTableOrderingComposer,
          $$CollectionItemsTableAnnotationComposer,
          $$CollectionItemsTableCreateCompanionBuilder,
          $$CollectionItemsTableUpdateCompanionBuilder,
          (CollectionItemRow, $$CollectionItemsTableReferences),
          CollectionItemRow,
          PrefetchHooks Function({bool collectionId, bool screenshotId})
        > {
  $$CollectionItemsTableTableManager(
    _$AppDatabase db,
    $CollectionItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> collectionId = const Value.absent(),
                Value<int> screenshotId = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionItemsCompanion(
                collectionId: collectionId,
                screenshotId: screenshotId,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int collectionId,
                required int screenshotId,
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionItemsCompanion.insert(
                collectionId: collectionId,
                screenshotId: screenshotId,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CollectionItemsTable, CollectionItemRow>(table),
                  $$CollectionItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({collectionId = false, screenshotId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (collectionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.collectionId,
                            referencedTable: $$CollectionItemsTableReferences
                                ._collectionIdTable(db),
                            referencedColumn: $$CollectionItemsTableReferences
                                ._collectionIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (screenshotId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.screenshotId,
                            referencedTable: $$CollectionItemsTableReferences
                                ._screenshotIdTable(db),
                            referencedColumn: $$CollectionItemsTableReferences
                                ._screenshotIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$CollectionItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionItemsTable,
      CollectionItemRow,
      $$CollectionItemsTableFilterComposer,
      $$CollectionItemsTableOrderingComposer,
      $$CollectionItemsTableAnnotationComposer,
      $$CollectionItemsTableCreateCompanionBuilder,
      $$CollectionItemsTableUpdateCompanionBuilder,
      (CollectionItemRow, $$CollectionItemsTableReferences),
      CollectionItemRow,
      PrefetchHooks Function({bool collectionId, bool screenshotId})
    >;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  required String name,
  Value<DateTime> createdAt,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<DateTime> createdAt,
});

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, TagRow> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ScreenshotTagsTable, List<ScreenshotTagRow>>
  _screenshotTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.screenshotTags,
    aliasName: 'tags__id__screenshot_tags__tag_id',
  );

  $$ScreenshotTagsTableProcessedTableManager get screenshotTagsRefs {
    final manager = $$ScreenshotTagsTableTableManager(
      $_db,
      $_db.screenshotTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_screenshotTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> screenshotTagsRefs(
    Expression<bool> Function($$ScreenshotTagsTableFilterComposer f) f,
  ) {
    final $$ScreenshotTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.screenshotTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotTagsTableFilterComposer(
            $db: $db,
            $table: $db.screenshotTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> screenshotTagsRefs<T extends Object>(
    Expression<T> Function($$ScreenshotTagsTableAnnotationComposer a) f,
  ) {
    final $$ScreenshotTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.screenshotTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.screenshotTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          TagRow,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (TagRow, $$TagsTableReferences),
          TagRow,
          PrefetchHooks Function({bool screenshotTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) => TagsCompanion(id: id, name: name, createdAt: createdAt),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<DateTime> createdAt = const Value.absent(),
          }) => TagsCompanion.insert(id: id, name: name, createdAt: createdAt),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TagsTable, TagRow>(table),
                  $$TagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({screenshotTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (screenshotTagsRefs) db.screenshotTags,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (screenshotTagsRefs)
                    await $_getPrefetchedDataByColumns<
                      TagRow,
                      $TagsTable,
                      ScreenshotTagRow,
                      $ScreenshotTagsTable
                    >(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences
                          ._screenshotTagsRefsTable(db),
                      managerFromTypedResult: (p0) => $$TagsTableReferences(
                        db,
                        table,
                        p0,
                      ).screenshotTagsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'tag_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      TagRow,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (TagRow, $$TagsTableReferences),
      TagRow,
      PrefetchHooks Function({bool screenshotTagsRefs})
    >;
typedef $$ScreenshotTagsTableCreateCompanionBuilder =
    ScreenshotTagsCompanion Function({
      required int screenshotId,
      required int tagId,
      Value<int> rowid,
    });
typedef $$ScreenshotTagsTableUpdateCompanionBuilder =
    ScreenshotTagsCompanion Function({
      Value<int> screenshotId,
      Value<int> tagId,
      Value<int> rowid,
    });

final class $$ScreenshotTagsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ScreenshotTagsTable, ScreenshotTagRow> {
  $$ScreenshotTagsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ScreenshotsTable _screenshotIdTable(_$AppDatabase db) => db
      .screenshots
      .createAlias('screenshot_tags__screenshot_id__screenshots__id');

  $$ScreenshotsTableProcessedTableManager get screenshotId {
    final $_column = $_itemColumn<int>('screenshot_id')!;

    final manager = $$ScreenshotsTableTableManager(
      $_db,
      $_db.screenshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_screenshotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('screenshot_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScreenshotTagsTableFilterComposer
    extends Composer<_$AppDatabase, $ScreenshotTagsTable> {
  $$ScreenshotTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ScreenshotsTableFilterComposer get screenshotId {
    final $$ScreenshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableFilterComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScreenshotTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScreenshotTagsTable> {
  $$ScreenshotTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ScreenshotsTableOrderingComposer get screenshotId {
    final $$ScreenshotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableOrderingComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScreenshotTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScreenshotTagsTable> {
  $$ScreenshotTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ScreenshotsTableAnnotationComposer get screenshotId {
    final $$ScreenshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScreenshotTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScreenshotTagsTable,
          ScreenshotTagRow,
          $$ScreenshotTagsTableFilterComposer,
          $$ScreenshotTagsTableOrderingComposer,
          $$ScreenshotTagsTableAnnotationComposer,
          $$ScreenshotTagsTableCreateCompanionBuilder,
          $$ScreenshotTagsTableUpdateCompanionBuilder,
          (ScreenshotTagRow, $$ScreenshotTagsTableReferences),
          ScreenshotTagRow,
          PrefetchHooks Function({bool screenshotId, bool tagId})
        > {
  $$ScreenshotTagsTableTableManager(
    _$AppDatabase db,
    $ScreenshotTagsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScreenshotTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScreenshotTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScreenshotTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> screenshotId = const Value.absent(),
                Value<int> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScreenshotTagsCompanion(
                screenshotId: screenshotId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int screenshotId,
                required int tagId,
                Value<int> rowid = const Value.absent(),
              }) => ScreenshotTagsCompanion.insert(
                screenshotId: screenshotId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScreenshotTagsTable, ScreenshotTagRow>(table),
                  $$ScreenshotTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({screenshotId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (screenshotId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.screenshotId,
                        referencedTable: $$ScreenshotTagsTableReferences
                            ._screenshotIdTable(db),
                        referencedColumn: $$ScreenshotTagsTableReferences
                            ._screenshotIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (tagId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tagId,
                        referencedTable: $$ScreenshotTagsTableReferences
                            ._tagIdTable(db),
                        referencedColumn: $$ScreenshotTagsTableReferences
                            ._tagIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ScreenshotTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScreenshotTagsTable,
      ScreenshotTagRow,
      $$ScreenshotTagsTableFilterComposer,
      $$ScreenshotTagsTableOrderingComposer,
      $$ScreenshotTagsTableAnnotationComposer,
      $$ScreenshotTagsTableCreateCompanionBuilder,
      $$ScreenshotTagsTableUpdateCompanionBuilder,
      (ScreenshotTagRow, $$ScreenshotTagsTableReferences),
      ScreenshotTagRow,
      PrefetchHooks Function({bool screenshotId, bool tagId})
    >;
typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  Value<int> id,
  required int screenshotId,
  required String content,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<int> id,
  Value<int> screenshotId,
  Value<String> content,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$NotesTableReferences
    extends BaseReferences<_$AppDatabase, $NotesTable, NoteRow> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ScreenshotsTable _screenshotIdTable(_$AppDatabase db) =>
      db.screenshots.createAlias('notes__screenshot_id__screenshots__id');

  $$ScreenshotsTableProcessedTableManager get screenshotId {
    final $_column = $_itemColumn<int>('screenshot_id')!;

    final manager = $$ScreenshotsTableTableManager(
      $_db,
      $_db.screenshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_screenshotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ScreenshotsTableFilterComposer get screenshotId {
    final $$ScreenshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableFilterComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScreenshotsTableOrderingComposer get screenshotId {
    final $$ScreenshotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableOrderingComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ScreenshotsTableAnnotationComposer get screenshotId {
    final $$ScreenshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          NoteRow,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (NoteRow, $$NotesTableReferences),
          NoteRow,
          PrefetchHooks Function({bool screenshotId})
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> screenshotId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                screenshotId: screenshotId,
                content: content,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int screenshotId,
                required String content,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                screenshotId: screenshotId,
                content: content,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotesTable, NoteRow>(table),
                  $$NotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({screenshotId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (screenshotId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.screenshotId,
                        referencedTable: $$NotesTableReferences
                            ._screenshotIdTable(db),
                        referencedColumn: $$NotesTableReferences
                            ._screenshotIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      NoteRow,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (NoteRow, $$NotesTableReferences),
      NoteRow,
      PrefetchHooks Function({bool screenshotId})
    >;
typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  Value<int> id,
  Value<int?> screenshotId,
  required String title,
  Value<String?> description,
  required DateTime scheduledAt,
  required String timezone,
  required int notificationId,
  Value<bool> notify,
  Value<RepeatRule> repeatRule,
  required ReminderStatus status,
  Value<DateTime?> completedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<int> id,
  Value<int?> screenshotId,
  Value<String> title,
  Value<String?> description,
  Value<DateTime> scheduledAt,
  Value<String> timezone,
  Value<int> notificationId,
  Value<bool> notify,
  Value<RepeatRule> repeatRule,
  Value<ReminderStatus> status,
  Value<DateTime?> completedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$RemindersTableReferences
    extends BaseReferences<_$AppDatabase, $RemindersTable, ReminderRow> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ScreenshotsTable _screenshotIdTable(_$AppDatabase db) =>
      db.screenshots.createAlias('reminders__screenshot_id__screenshots__id');

  $$ScreenshotsTableProcessedTableManager? get screenshotId {
    final $_column = $_itemColumn<int>('screenshot_id');
    if ($_column == null) return null;
    final manager = $$ScreenshotsTableTableManager(
      $_db,
      $_db.screenshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_screenshotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notify => $composableBuilder(
    column: $table.notify,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RepeatRule, RepeatRule, String>
  get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<ReminderStatus, ReminderStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ScreenshotsTableFilterComposer get screenshotId {
    final $$ScreenshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableFilterComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notify => $composableBuilder(
    column: $table.notify,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScreenshotsTableOrderingComposer get screenshotId {
    final $$ScreenshotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableOrderingComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notify =>
      $composableBuilder(column: $table.notify, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RepeatRule, String> get repeatRule =>
      $composableBuilder(
        column: $table.repeatRule,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<ReminderStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ScreenshotsTableAnnotationComposer get screenshotId {
    final $$ScreenshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          ReminderRow,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (ReminderRow, $$RemindersTableReferences),
          ReminderRow,
          PrefetchHooks Function({bool screenshotId})
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> screenshotId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> scheduledAt = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<int> notificationId = const Value.absent(),
                Value<bool> notify = const Value.absent(),
                Value<RepeatRule> repeatRule = const Value.absent(),
                Value<ReminderStatus> status = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                screenshotId: screenshotId,
                title: title,
                description: description,
                scheduledAt: scheduledAt,
                timezone: timezone,
                notificationId: notificationId,
                notify: notify,
                repeatRule: repeatRule,
                status: status,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> screenshotId = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                required DateTime scheduledAt,
                required String timezone,
                required int notificationId,
                Value<bool> notify = const Value.absent(),
                Value<RepeatRule> repeatRule = const Value.absent(),
                required ReminderStatus status,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                screenshotId: screenshotId,
                title: title,
                description: description,
                scheduledAt: scheduledAt,
                timezone: timezone,
                notificationId: notificationId,
                notify: notify,
                repeatRule: repeatRule,
                status: status,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RemindersTable, ReminderRow>(table),
                  $$RemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({screenshotId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (screenshotId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.screenshotId,
                        referencedTable: $$RemindersTableReferences
                            ._screenshotIdTable(db),
                        referencedColumn: $$RemindersTableReferences
                            ._screenshotIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      ReminderRow,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (ReminderRow, $$RemindersTableReferences),
      ReminderRow,
      PrefetchHooks Function({bool screenshotId})
    >;
typedef $$SuggestedActionsTableCreateCompanionBuilder =
    SuggestedActionsCompanion Function({
      Value<int> id,
      required int screenshotId,
      required ActionType actionType,
      required String title,
      required String payloadJson,
      required ActionStatus status,
      Value<DateTime?> postponedUntil,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$SuggestedActionsTableUpdateCompanionBuilder =
    SuggestedActionsCompanion Function({
      Value<int> id,
      Value<int> screenshotId,
      Value<ActionType> actionType,
      Value<String> title,
      Value<String> payloadJson,
      Value<ActionStatus> status,
      Value<DateTime?> postponedUntil,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$SuggestedActionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SuggestedActionsTable,
          SuggestedActionRow
        > {
  $$SuggestedActionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ScreenshotsTable _screenshotIdTable(_$AppDatabase db) => db
      .screenshots
      .createAlias('suggested_actions__screenshot_id__screenshots__id');

  $$ScreenshotsTableProcessedTableManager get screenshotId {
    final $_column = $_itemColumn<int>('screenshot_id')!;

    final manager = $$ScreenshotsTableTableManager(
      $_db,
      $_db.screenshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_screenshotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SuggestedActionsTableFilterComposer
    extends Composer<_$AppDatabase, $SuggestedActionsTable> {
  $$SuggestedActionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ActionType, ActionType, String>
  get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ActionStatus, ActionStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get postponedUntil => $composableBuilder(
    column: $table.postponedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ScreenshotsTableFilterComposer get screenshotId {
    final $$ScreenshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableFilterComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SuggestedActionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SuggestedActionsTable> {
  $$SuggestedActionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get postponedUntil => $composableBuilder(
    column: $table.postponedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScreenshotsTableOrderingComposer get screenshotId {
    final $$ScreenshotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableOrderingComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SuggestedActionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuggestedActionsTable> {
  $$SuggestedActionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActionType, String> get actionType =>
      $composableBuilder(
        column: $table.actionType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ActionStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get postponedUntil => $composableBuilder(
    column: $table.postponedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ScreenshotsTableAnnotationComposer get screenshotId {
    final $$ScreenshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SuggestedActionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuggestedActionsTable,
          SuggestedActionRow,
          $$SuggestedActionsTableFilterComposer,
          $$SuggestedActionsTableOrderingComposer,
          $$SuggestedActionsTableAnnotationComposer,
          $$SuggestedActionsTableCreateCompanionBuilder,
          $$SuggestedActionsTableUpdateCompanionBuilder,
          (SuggestedActionRow, $$SuggestedActionsTableReferences),
          SuggestedActionRow,
          PrefetchHooks Function({bool screenshotId})
        > {
  $$SuggestedActionsTableTableManager(
    _$AppDatabase db,
    $SuggestedActionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuggestedActionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuggestedActionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuggestedActionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> screenshotId = const Value.absent(),
                Value<ActionType> actionType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<ActionStatus> status = const Value.absent(),
                Value<DateTime?> postponedUntil = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SuggestedActionsCompanion(
                id: id,
                screenshotId: screenshotId,
                actionType: actionType,
                title: title,
                payloadJson: payloadJson,
                status: status,
                postponedUntil: postponedUntil,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int screenshotId,
                required ActionType actionType,
                required String title,
                required String payloadJson,
                required ActionStatus status,
                Value<DateTime?> postponedUntil = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SuggestedActionsCompanion.insert(
                id: id,
                screenshotId: screenshotId,
                actionType: actionType,
                title: title,
                payloadJson: payloadJson,
                status: status,
                postponedUntil: postponedUntil,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SuggestedActionsTable, SuggestedActionRow>(
                    table,
                  ),
                  $$SuggestedActionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({screenshotId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (screenshotId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.screenshotId,
                        referencedTable: $$SuggestedActionsTableReferences
                            ._screenshotIdTable(db),
                        referencedColumn: $$SuggestedActionsTableReferences
                            ._screenshotIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SuggestedActionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuggestedActionsTable,
      SuggestedActionRow,
      $$SuggestedActionsTableFilterComposer,
      $$SuggestedActionsTableOrderingComposer,
      $$SuggestedActionsTableAnnotationComposer,
      $$SuggestedActionsTableCreateCompanionBuilder,
      $$SuggestedActionsTableUpdateCompanionBuilder,
      (SuggestedActionRow, $$SuggestedActionsTableReferences),
      SuggestedActionRow,
      PrefetchHooks Function({bool screenshotId})
    >;
typedef $$WishlistItemsTableCreateCompanionBuilder =
    WishlistItemsCompanion Function({
      Value<int> id,
      Value<int?> screenshotId,
      Value<String?> productName,
      Value<int?> amountMinorUnits,
      Value<String?> currency,
      Value<String?> merchantName,
      Value<String?> productUrl,
      Value<String?> notes,
      Value<bool> purchased,
      Value<DateTime> createdAt,
    });
typedef $$WishlistItemsTableUpdateCompanionBuilder =
    WishlistItemsCompanion Function({
      Value<int> id,
      Value<int?> screenshotId,
      Value<String?> productName,
      Value<int?> amountMinorUnits,
      Value<String?> currency,
      Value<String?> merchantName,
      Value<String?> productUrl,
      Value<String?> notes,
      Value<bool> purchased,
      Value<DateTime> createdAt,
    });

final class $$WishlistItemsTableReferences
    extends
        BaseReferences<_$AppDatabase, $WishlistItemsTable, WishlistItemRow> {
  $$WishlistItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ScreenshotsTable _screenshotIdTable(_$AppDatabase db) => db
      .screenshots
      .createAlias('wishlist_items__screenshot_id__screenshots__id');

  $$ScreenshotsTableProcessedTableManager? get screenshotId {
    final $_column = $_itemColumn<int>('screenshot_id');
    if ($_column == null) return null;
    final manager = $$ScreenshotsTableTableManager(
      $_db,
      $_db.screenshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_screenshotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WishlistItemsTableFilterComposer
    extends Composer<_$AppDatabase, $WishlistItemsTable> {
  $$WishlistItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchantName => $composableBuilder(
    column: $table.merchantName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productUrl => $composableBuilder(
    column: $table.productUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get purchased => $composableBuilder(
    column: $table.purchased,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ScreenshotsTableFilterComposer get screenshotId {
    final $$ScreenshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableFilterComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WishlistItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $WishlistItemsTable> {
  $$WishlistItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchantName => $composableBuilder(
    column: $table.merchantName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productUrl => $composableBuilder(
    column: $table.productUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get purchased => $composableBuilder(
    column: $table.purchased,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScreenshotsTableOrderingComposer get screenshotId {
    final $$ScreenshotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableOrderingComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WishlistItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WishlistItemsTable> {
  $$WishlistItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get merchantName => $composableBuilder(
    column: $table.merchantName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productUrl => $composableBuilder(
    column: $table.productUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get purchased =>
      $composableBuilder(column: $table.purchased, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ScreenshotsTableAnnotationComposer get screenshotId {
    final $$ScreenshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WishlistItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WishlistItemsTable,
          WishlistItemRow,
          $$WishlistItemsTableFilterComposer,
          $$WishlistItemsTableOrderingComposer,
          $$WishlistItemsTableAnnotationComposer,
          $$WishlistItemsTableCreateCompanionBuilder,
          $$WishlistItemsTableUpdateCompanionBuilder,
          (WishlistItemRow, $$WishlistItemsTableReferences),
          WishlistItemRow,
          PrefetchHooks Function({bool screenshotId})
        > {
  $$WishlistItemsTableTableManager(_$AppDatabase db, $WishlistItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WishlistItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WishlistItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WishlistItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> screenshotId = const Value.absent(),
                Value<String?> productName = const Value.absent(),
                Value<int?> amountMinorUnits = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                Value<String?> merchantName = const Value.absent(),
                Value<String?> productUrl = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> purchased = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WishlistItemsCompanion(
                id: id,
                screenshotId: screenshotId,
                productName: productName,
                amountMinorUnits: amountMinorUnits,
                currency: currency,
                merchantName: merchantName,
                productUrl: productUrl,
                notes: notes,
                purchased: purchased,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> screenshotId = const Value.absent(),
                Value<String?> productName = const Value.absent(),
                Value<int?> amountMinorUnits = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                Value<String?> merchantName = const Value.absent(),
                Value<String?> productUrl = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> purchased = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WishlistItemsCompanion.insert(
                id: id,
                screenshotId: screenshotId,
                productName: productName,
                amountMinorUnits: amountMinorUnits,
                currency: currency,
                merchantName: merchantName,
                productUrl: productUrl,
                notes: notes,
                purchased: purchased,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WishlistItemsTable, WishlistItemRow>(table),
                  $$WishlistItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({screenshotId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (screenshotId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.screenshotId,
                        referencedTable: $$WishlistItemsTableReferences
                            ._screenshotIdTable(db),
                        referencedColumn: $$WishlistItemsTableReferences
                            ._screenshotIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WishlistItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WishlistItemsTable,
      WishlistItemRow,
      $$WishlistItemsTableFilterComposer,
      $$WishlistItemsTableOrderingComposer,
      $$WishlistItemsTableAnnotationComposer,
      $$WishlistItemsTableCreateCompanionBuilder,
      $$WishlistItemsTableUpdateCompanionBuilder,
      (WishlistItemRow, $$WishlistItemsTableReferences),
      WishlistItemRow,
      PrefetchHooks Function({bool screenshotId})
    >;
typedef $$ProcessingJobsTableCreateCompanionBuilder =
    ProcessingJobsCompanion Function({
      Value<int> id,
      required int screenshotId,
      required JobType jobType,
      required JobStatus status,
      Value<int> attemptCount,
      Value<String?> errorMessage,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> priority,
      Value<double?> progress,
      Value<String?> checkpointJson,
    });
typedef $$ProcessingJobsTableUpdateCompanionBuilder =
    ProcessingJobsCompanion Function({
      Value<int> id,
      Value<int> screenshotId,
      Value<JobType> jobType,
      Value<JobStatus> status,
      Value<int> attemptCount,
      Value<String?> errorMessage,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> priority,
      Value<double?> progress,
      Value<String?> checkpointJson,
    });

final class $$ProcessingJobsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ProcessingJobsTable, ProcessingJobRow> {
  $$ProcessingJobsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ScreenshotsTable _screenshotIdTable(_$AppDatabase db) => db
      .screenshots
      .createAlias('processing_jobs__screenshot_id__screenshots__id');

  $$ScreenshotsTableProcessedTableManager get screenshotId {
    final $_column = $_itemColumn<int>('screenshot_id')!;

    final manager = $$ScreenshotsTableTableManager(
      $_db,
      $_db.screenshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_screenshotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProcessingJobsTableFilterComposer
    extends Composer<_$AppDatabase, $ProcessingJobsTable> {
  $$ProcessingJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<JobType, JobType, String> get jobType =>
      $composableBuilder(
        column: $table.jobType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<JobStatus, JobStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checkpointJson => $composableBuilder(
    column: $table.checkpointJson,
    builder: (column) => ColumnFilters(column),
  );

  $$ScreenshotsTableFilterComposer get screenshotId {
    final $$ScreenshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableFilterComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProcessingJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProcessingJobsTable> {
  $$ProcessingJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jobType => $composableBuilder(
    column: $table.jobType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checkpointJson => $composableBuilder(
    column: $table.checkpointJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScreenshotsTableOrderingComposer get screenshotId {
    final $$ScreenshotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableOrderingComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProcessingJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProcessingJobsTable> {
  $$ProcessingJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JobType, String> get jobType =>
      $composableBuilder(column: $table.jobType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JobStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<String> get checkpointJson => $composableBuilder(
    column: $table.checkpointJson,
    builder: (column) => column,
  );

  $$ScreenshotsTableAnnotationComposer get screenshotId {
    final $$ScreenshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.screenshotId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProcessingJobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProcessingJobsTable,
          ProcessingJobRow,
          $$ProcessingJobsTableFilterComposer,
          $$ProcessingJobsTableOrderingComposer,
          $$ProcessingJobsTableAnnotationComposer,
          $$ProcessingJobsTableCreateCompanionBuilder,
          $$ProcessingJobsTableUpdateCompanionBuilder,
          (ProcessingJobRow, $$ProcessingJobsTableReferences),
          ProcessingJobRow,
          PrefetchHooks Function({bool screenshotId})
        > {
  $$ProcessingJobsTableTableManager(
    _$AppDatabase db,
    $ProcessingJobsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProcessingJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProcessingJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProcessingJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> screenshotId = const Value.absent(),
                Value<JobType> jobType = const Value.absent(),
                Value<JobStatus> status = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<double?> progress = const Value.absent(),
                Value<String?> checkpointJson = const Value.absent(),
              }) => ProcessingJobsCompanion(
                id: id,
                screenshotId: screenshotId,
                jobType: jobType,
                status: status,
                attemptCount: attemptCount,
                errorMessage: errorMessage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                priority: priority,
                progress: progress,
                checkpointJson: checkpointJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int screenshotId,
                required JobType jobType,
                required JobStatus status,
                Value<int> attemptCount = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<double?> progress = const Value.absent(),
                Value<String?> checkpointJson = const Value.absent(),
              }) => ProcessingJobsCompanion.insert(
                id: id,
                screenshotId: screenshotId,
                jobType: jobType,
                status: status,
                attemptCount: attemptCount,
                errorMessage: errorMessage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                priority: priority,
                progress: progress,
                checkpointJson: checkpointJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProcessingJobsTable, ProcessingJobRow>(table),
                  $$ProcessingJobsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({screenshotId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (screenshotId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.screenshotId,
                        referencedTable: $$ProcessingJobsTableReferences
                            ._screenshotIdTable(db),
                        referencedColumn: $$ProcessingJobsTableReferences
                            ._screenshotIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProcessingJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProcessingJobsTable,
      ProcessingJobRow,
      $$ProcessingJobsTableFilterComposer,
      $$ProcessingJobsTableOrderingComposer,
      $$ProcessingJobsTableAnnotationComposer,
      $$ProcessingJobsTableCreateCompanionBuilder,
      $$ProcessingJobsTableUpdateCompanionBuilder,
      (ProcessingJobRow, $$ProcessingJobsTableReferences),
      ProcessingJobRow,
      PrefetchHooks Function({bool screenshotId})
    >;
typedef $$SearchHistoryTableCreateCompanionBuilder =
    SearchHistoryCompanion Function({
      Value<int> id,
      required String query,
      required DateTime searchedAt,
    });
typedef $$SearchHistoryTableUpdateCompanionBuilder =
    SearchHistoryCompanion Function({
      Value<int> id,
      Value<String> query,
      Value<DateTime> searchedAt,
    });

class $$SearchHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $SearchHistoryTable> {
  $$SearchHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SearchHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchHistoryTable> {
  $$SearchHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SearchHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchHistoryTable> {
  $$SearchHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => column,
  );
}

class $$SearchHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SearchHistoryTable,
          SearchHistoryRow,
          $$SearchHistoryTableFilterComposer,
          $$SearchHistoryTableOrderingComposer,
          $$SearchHistoryTableAnnotationComposer,
          $$SearchHistoryTableCreateCompanionBuilder,
          $$SearchHistoryTableUpdateCompanionBuilder,
          (
            SearchHistoryRow,
            BaseReferences<
              _$AppDatabase,
              $SearchHistoryTable,
              SearchHistoryRow
            >,
          ),
          SearchHistoryRow,
          PrefetchHooks Function()
        > {
  $$SearchHistoryTableTableManager(_$AppDatabase db, $SearchHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> query = const Value.absent(),
                Value<DateTime> searchedAt = const Value.absent(),
              }) => SearchHistoryCompanion(
                id: id,
                query: query,
                searchedAt: searchedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String query,
                required DateTime searchedAt,
              }) => SearchHistoryCompanion.insert(
                id: id,
                query: query,
                searchedAt: searchedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SearchHistoryTable, SearchHistoryRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SearchHistoryTable,
                    SearchHistoryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SearchHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SearchHistoryTable,
      SearchHistoryRow,
      $$SearchHistoryTableFilterComposer,
      $$SearchHistoryTableOrderingComposer,
      $$SearchHistoryTableAnnotationComposer,
      $$SearchHistoryTableCreateCompanionBuilder,
      $$SearchHistoryTableUpdateCompanionBuilder,
      (
        SearchHistoryRow,
        BaseReferences<_$AppDatabase, $SearchHistoryTable, SearchHistoryRow>,
      ),
      SearchHistoryRow,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSettingRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
          ),
          AppSettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSettingRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppSettingsTable,
                    AppSettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSettingRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
      ),
      AppSettingRow,
      PrefetchHooks Function()
    >;
typedef $$ClassificationRulesTableCreateCompanionBuilder =
    ClassificationRulesCompanion Function({
      Value<int> id,
      required String keyword,
      required int categoryId,
      Value<DateTime> createdAt,
    });
typedef $$ClassificationRulesTableUpdateCompanionBuilder =
    ClassificationRulesCompanion Function({
      Value<int> id,
      Value<String> keyword,
      Value<int> categoryId,
      Value<DateTime> createdAt,
    });

final class $$ClassificationRulesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ClassificationRulesTable,
          ClassificationRuleRow
        > {
  $$ClassificationRulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) => db.categories
      .createAlias('classification_rules__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ClassificationRulesTableFilterComposer
    extends Composer<_$AppDatabase, $ClassificationRulesTable> {
  $$ClassificationRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keyword => $composableBuilder(
    column: $table.keyword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClassificationRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClassificationRulesTable> {
  $$ClassificationRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keyword => $composableBuilder(
    column: $table.keyword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClassificationRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClassificationRulesTable> {
  $$ClassificationRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get keyword =>
      $composableBuilder(column: $table.keyword, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClassificationRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClassificationRulesTable,
          ClassificationRuleRow,
          $$ClassificationRulesTableFilterComposer,
          $$ClassificationRulesTableOrderingComposer,
          $$ClassificationRulesTableAnnotationComposer,
          $$ClassificationRulesTableCreateCompanionBuilder,
          $$ClassificationRulesTableUpdateCompanionBuilder,
          (ClassificationRuleRow, $$ClassificationRulesTableReferences),
          ClassificationRuleRow,
          PrefetchHooks Function({bool categoryId})
        > {
  $$ClassificationRulesTableTableManager(
    _$AppDatabase db,
    $ClassificationRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClassificationRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClassificationRulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ClassificationRulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> keyword = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClassificationRulesCompanion(
                id: id,
                keyword: keyword,
                categoryId: categoryId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String keyword,
                required int categoryId,
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClassificationRulesCompanion.insert(
                id: id,
                keyword: keyword,
                categoryId: categoryId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClassificationRulesTable, ClassificationRuleRow>(
                    table,
                  ),
                  $$ClassificationRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoryId,
                        referencedTable: $$ClassificationRulesTableReferences
                            ._categoryIdTable(db),
                        referencedColumn: $$ClassificationRulesTableReferences
                            ._categoryIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ClassificationRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClassificationRulesTable,
      ClassificationRuleRow,
      $$ClassificationRulesTableFilterComposer,
      $$ClassificationRulesTableOrderingComposer,
      $$ClassificationRulesTableAnnotationComposer,
      $$ClassificationRulesTableCreateCompanionBuilder,
      $$ClassificationRulesTableUpdateCompanionBuilder,
      (ClassificationRuleRow, $$ClassificationRulesTableReferences),
      ClassificationRuleRow,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$MemoryChunksTableCreateCompanionBuilder =
    MemoryChunksCompanion Function({
      Value<int> id,
      required int memoryId,
      required int chunkIndex,
      required String textOriginal,
      required String textNormalized,
      Value<int?> page,
      Value<int?> startMs,
      Value<int?> endMs,
      Value<String?> regionJson,
      Value<int?> tokenCount,
      required String sourceChecksum,
    });
typedef $$MemoryChunksTableUpdateCompanionBuilder =
    MemoryChunksCompanion Function({
      Value<int> id,
      Value<int> memoryId,
      Value<int> chunkIndex,
      Value<String> textOriginal,
      Value<String> textNormalized,
      Value<int?> page,
      Value<int?> startMs,
      Value<int?> endMs,
      Value<String?> regionJson,
      Value<int?> tokenCount,
      Value<String> sourceChecksum,
    });

final class $$MemoryChunksTableReferences
    extends BaseReferences<_$AppDatabase, $MemoryChunksTable, MemoryChunkRow> {
  $$MemoryChunksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ScreenshotsTable _memoryIdTable(_$AppDatabase db) =>
      db.screenshots.createAlias('memory_chunks__memory_id__screenshots__id');

  $$ScreenshotsTableProcessedTableManager get memoryId {
    final $_column = $_itemColumn<int>('memory_id')!;

    final manager = $$ScreenshotsTableTableManager(
      $_db,
      $_db.screenshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EmbeddingsTable, List<EmbeddingRow>>
  _embeddingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.embeddings,
    aliasName: 'memory_chunks__id__embeddings__chunk_id',
  );

  $$EmbeddingsTableProcessedTableManager get embeddingsRefs {
    final manager = $$EmbeddingsTableTableManager(
      $_db,
      $_db.embeddings,
    ).filter((f) => f.chunkId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_embeddingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MemoryChunksTableFilterComposer
    extends Composer<_$AppDatabase, $MemoryChunksTable> {
  $$MemoryChunksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chunkIndex => $composableBuilder(
    column: $table.chunkIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textOriginal => $composableBuilder(
    column: $table.textOriginal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textNormalized => $composableBuilder(
    column: $table.textNormalized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regionJson => $composableBuilder(
    column: $table.regionJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tokenCount => $composableBuilder(
    column: $table.tokenCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceChecksum => $composableBuilder(
    column: $table.sourceChecksum,
    builder: (column) => ColumnFilters(column),
  );

  $$ScreenshotsTableFilterComposer get memoryId {
    final $$ScreenshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableFilterComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> embeddingsRefs(
    Expression<bool> Function($$EmbeddingsTableFilterComposer f) f,
  ) {
    final $$EmbeddingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.embeddings,
      getReferencedColumn: (t) => t.chunkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmbeddingsTableFilterComposer(
            $db: $db,
            $table: $db.embeddings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MemoryChunksTableOrderingComposer
    extends Composer<_$AppDatabase, $MemoryChunksTable> {
  $$MemoryChunksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chunkIndex => $composableBuilder(
    column: $table.chunkIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textOriginal => $composableBuilder(
    column: $table.textOriginal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textNormalized => $composableBuilder(
    column: $table.textNormalized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regionJson => $composableBuilder(
    column: $table.regionJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tokenCount => $composableBuilder(
    column: $table.tokenCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceChecksum => $composableBuilder(
    column: $table.sourceChecksum,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScreenshotsTableOrderingComposer get memoryId {
    final $$ScreenshotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableOrderingComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryChunksTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemoryChunksTable> {
  $$MemoryChunksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get chunkIndex => $composableBuilder(
    column: $table.chunkIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textOriginal => $composableBuilder(
    column: $table.textOriginal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textNormalized => $composableBuilder(
    column: $table.textNormalized,
    builder: (column) => column,
  );

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<int> get startMs =>
      $composableBuilder(column: $table.startMs, builder: (column) => column);

  GeneratedColumn<int> get endMs =>
      $composableBuilder(column: $table.endMs, builder: (column) => column);

  GeneratedColumn<String> get regionJson => $composableBuilder(
    column: $table.regionJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tokenCount => $composableBuilder(
    column: $table.tokenCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceChecksum => $composableBuilder(
    column: $table.sourceChecksum,
    builder: (column) => column,
  );

  $$ScreenshotsTableAnnotationComposer get memoryId {
    final $$ScreenshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> embeddingsRefs<T extends Object>(
    Expression<T> Function($$EmbeddingsTableAnnotationComposer a) f,
  ) {
    final $$EmbeddingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.embeddings,
      getReferencedColumn: (t) => t.chunkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmbeddingsTableAnnotationComposer(
            $db: $db,
            $table: $db.embeddings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MemoryChunksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemoryChunksTable,
          MemoryChunkRow,
          $$MemoryChunksTableFilterComposer,
          $$MemoryChunksTableOrderingComposer,
          $$MemoryChunksTableAnnotationComposer,
          $$MemoryChunksTableCreateCompanionBuilder,
          $$MemoryChunksTableUpdateCompanionBuilder,
          (MemoryChunkRow, $$MemoryChunksTableReferences),
          MemoryChunkRow,
          PrefetchHooks Function({bool memoryId, bool embeddingsRefs})
        > {
  $$MemoryChunksTableTableManager(_$AppDatabase db, $MemoryChunksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryChunksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryChunksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoryChunksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> memoryId = const Value.absent(),
                Value<int> chunkIndex = const Value.absent(),
                Value<String> textOriginal = const Value.absent(),
                Value<String> textNormalized = const Value.absent(),
                Value<int?> page = const Value.absent(),
                Value<int?> startMs = const Value.absent(),
                Value<int?> endMs = const Value.absent(),
                Value<String?> regionJson = const Value.absent(),
                Value<int?> tokenCount = const Value.absent(),
                Value<String> sourceChecksum = const Value.absent(),
              }) => MemoryChunksCompanion(
                id: id,
                memoryId: memoryId,
                chunkIndex: chunkIndex,
                textOriginal: textOriginal,
                textNormalized: textNormalized,
                page: page,
                startMs: startMs,
                endMs: endMs,
                regionJson: regionJson,
                tokenCount: tokenCount,
                sourceChecksum: sourceChecksum,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int memoryId,
                required int chunkIndex,
                required String textOriginal,
                required String textNormalized,
                Value<int?> page = const Value.absent(),
                Value<int?> startMs = const Value.absent(),
                Value<int?> endMs = const Value.absent(),
                Value<String?> regionJson = const Value.absent(),
                Value<int?> tokenCount = const Value.absent(),
                required String sourceChecksum,
              }) => MemoryChunksCompanion.insert(
                id: id,
                memoryId: memoryId,
                chunkIndex: chunkIndex,
                textOriginal: textOriginal,
                textNormalized: textNormalized,
                page: page,
                startMs: startMs,
                endMs: endMs,
                regionJson: regionJson,
                tokenCount: tokenCount,
                sourceChecksum: sourceChecksum,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MemoryChunksTable, MemoryChunkRow>(table),
                  $$MemoryChunksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({memoryId = false, embeddingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (embeddingsRefs) db.embeddings],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (memoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.memoryId,
                        referencedTable: $$MemoryChunksTableReferences
                            ._memoryIdTable(db),
                        referencedColumn: $$MemoryChunksTableReferences
                            ._memoryIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (embeddingsRefs)
                    await $_getPrefetchedDataByColumns<
                      MemoryChunkRow,
                      $MemoryChunksTable,
                      EmbeddingRow,
                      $EmbeddingsTable
                    >(
                      currentTable: table,
                      referencedTable: $$MemoryChunksTableReferences
                          ._embeddingsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MemoryChunksTableReferences(
                            db,
                            table,
                            p0,
                          ).embeddingsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'chunk_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MemoryChunksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemoryChunksTable,
      MemoryChunkRow,
      $$MemoryChunksTableFilterComposer,
      $$MemoryChunksTableOrderingComposer,
      $$MemoryChunksTableAnnotationComposer,
      $$MemoryChunksTableCreateCompanionBuilder,
      $$MemoryChunksTableUpdateCompanionBuilder,
      (MemoryChunkRow, $$MemoryChunksTableReferences),
      MemoryChunkRow,
      PrefetchHooks Function({bool memoryId, bool embeddingsRefs})
    >;
typedef $$EmbeddingsTableCreateCompanionBuilder = EmbeddingsCompanion Function({
  Value<int> id,
  required int chunkId,
  required int memoryId,
  required String modelId,
  required String modelVersion,
  required String spaceId,
  required int dimension,
  required Uint8List vector,
  required String sourceChecksum,
  Value<DateTime> createdAt,
});
typedef $$EmbeddingsTableUpdateCompanionBuilder = EmbeddingsCompanion Function({
  Value<int> id,
  Value<int> chunkId,
  Value<int> memoryId,
  Value<String> modelId,
  Value<String> modelVersion,
  Value<String> spaceId,
  Value<int> dimension,
  Value<Uint8List> vector,
  Value<String> sourceChecksum,
  Value<DateTime> createdAt,
});

final class $$EmbeddingsTableReferences
    extends BaseReferences<_$AppDatabase, $EmbeddingsTable, EmbeddingRow> {
  $$EmbeddingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MemoryChunksTable _chunkIdTable(_$AppDatabase db) =>
      db.memoryChunks.createAlias('embeddings__chunk_id__memory_chunks__id');

  $$MemoryChunksTableProcessedTableManager get chunkId {
    final $_column = $_itemColumn<int>('chunk_id')!;

    final manager = $$MemoryChunksTableTableManager(
      $_db,
      $_db.memoryChunks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chunkIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ScreenshotsTable _memoryIdTable(_$AppDatabase db) =>
      db.screenshots.createAlias('embeddings__memory_id__screenshots__id');

  $$ScreenshotsTableProcessedTableManager get memoryId {
    final $_column = $_itemColumn<int>('memory_id')!;

    final manager = $$ScreenshotsTableTableManager(
      $_db,
      $_db.screenshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EmbeddingsTableFilterComposer
    extends Composer<_$AppDatabase, $EmbeddingsTable> {
  $$EmbeddingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spaceId => $composableBuilder(
    column: $table.spaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dimension => $composableBuilder(
    column: $table.dimension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get vector => $composableBuilder(
    column: $table.vector,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceChecksum => $composableBuilder(
    column: $table.sourceChecksum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MemoryChunksTableFilterComposer get chunkId {
    final $$MemoryChunksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chunkId,
      referencedTable: $db.memoryChunks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryChunksTableFilterComposer(
            $db: $db,
            $table: $db.memoryChunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScreenshotsTableFilterComposer get memoryId {
    final $$ScreenshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableFilterComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmbeddingsTableOrderingComposer
    extends Composer<_$AppDatabase, $EmbeddingsTable> {
  $$EmbeddingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spaceId => $composableBuilder(
    column: $table.spaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dimension => $composableBuilder(
    column: $table.dimension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get vector => $composableBuilder(
    column: $table.vector,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceChecksum => $composableBuilder(
    column: $table.sourceChecksum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MemoryChunksTableOrderingComposer get chunkId {
    final $$MemoryChunksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chunkId,
      referencedTable: $db.memoryChunks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryChunksTableOrderingComposer(
            $db: $db,
            $table: $db.memoryChunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScreenshotsTableOrderingComposer get memoryId {
    final $$ScreenshotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableOrderingComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmbeddingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmbeddingsTable> {
  $$EmbeddingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get spaceId =>
      $composableBuilder(column: $table.spaceId, builder: (column) => column);

  GeneratedColumn<int> get dimension =>
      $composableBuilder(column: $table.dimension, builder: (column) => column);

  GeneratedColumn<Uint8List> get vector =>
      $composableBuilder(column: $table.vector, builder: (column) => column);

  GeneratedColumn<String> get sourceChecksum => $composableBuilder(
    column: $table.sourceChecksum,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MemoryChunksTableAnnotationComposer get chunkId {
    final $$MemoryChunksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chunkId,
      referencedTable: $db.memoryChunks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryChunksTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryChunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScreenshotsTableAnnotationComposer get memoryId {
    final $$ScreenshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmbeddingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmbeddingsTable,
          EmbeddingRow,
          $$EmbeddingsTableFilterComposer,
          $$EmbeddingsTableOrderingComposer,
          $$EmbeddingsTableAnnotationComposer,
          $$EmbeddingsTableCreateCompanionBuilder,
          $$EmbeddingsTableUpdateCompanionBuilder,
          (EmbeddingRow, $$EmbeddingsTableReferences),
          EmbeddingRow,
          PrefetchHooks Function({bool chunkId, bool memoryId})
        > {
  $$EmbeddingsTableTableManager(_$AppDatabase db, $EmbeddingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmbeddingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmbeddingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmbeddingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> chunkId = const Value.absent(),
                Value<int> memoryId = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<String> modelVersion = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<int> dimension = const Value.absent(),
                Value<Uint8List> vector = const Value.absent(),
                Value<String> sourceChecksum = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EmbeddingsCompanion(
                id: id,
                chunkId: chunkId,
                memoryId: memoryId,
                modelId: modelId,
                modelVersion: modelVersion,
                spaceId: spaceId,
                dimension: dimension,
                vector: vector,
                sourceChecksum: sourceChecksum,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int chunkId,
                required int memoryId,
                required String modelId,
                required String modelVersion,
                required String spaceId,
                required int dimension,
                required Uint8List vector,
                required String sourceChecksum,
                Value<DateTime> createdAt = const Value.absent(),
              }) => EmbeddingsCompanion.insert(
                id: id,
                chunkId: chunkId,
                memoryId: memoryId,
                modelId: modelId,
                modelVersion: modelVersion,
                spaceId: spaceId,
                dimension: dimension,
                vector: vector,
                sourceChecksum: sourceChecksum,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EmbeddingsTable, EmbeddingRow>(table),
                  $$EmbeddingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({chunkId = false, memoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (chunkId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.chunkId,
                        referencedTable: $$EmbeddingsTableReferences
                            ._chunkIdTable(db),
                        referencedColumn: $$EmbeddingsTableReferences
                            ._chunkIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (memoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.memoryId,
                        referencedTable: $$EmbeddingsTableReferences
                            ._memoryIdTable(db),
                        referencedColumn: $$EmbeddingsTableReferences
                            ._memoryIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EmbeddingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmbeddingsTable,
      EmbeddingRow,
      $$EmbeddingsTableFilterComposer,
      $$EmbeddingsTableOrderingComposer,
      $$EmbeddingsTableAnnotationComposer,
      $$EmbeddingsTableCreateCompanionBuilder,
      $$EmbeddingsTableUpdateCompanionBuilder,
      (EmbeddingRow, $$EmbeddingsTableReferences),
      EmbeddingRow,
      PrefetchHooks Function({bool chunkId, bool memoryId})
    >;
typedef $$SpacesTableCreateCompanionBuilder = SpacesCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> description,
  required String icon,
  required int color,
  Value<int?> coverMemoryId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$SpacesTableUpdateCompanionBuilder = SpacesCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> description,
  Value<String> icon,
  Value<int> color,
  Value<int?> coverMemoryId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$SpacesTableReferences
    extends BaseReferences<_$AppDatabase, $SpacesTable, SpaceRow> {
  $$SpacesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ScreenshotsTable _coverMemoryIdTable(_$AppDatabase db) =>
      db.screenshots.createAlias('spaces__cover_memory_id__screenshots__id');

  $$ScreenshotsTableProcessedTableManager? get coverMemoryId {
    final $_column = $_itemColumn<int>('cover_memory_id');
    if ($_column == null) return null;
    final manager = $$ScreenshotsTableTableManager(
      $_db,
      $_db.screenshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_coverMemoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SpaceMembershipsTable, List<SpaceMembershipRow>>
  _spaceMembershipsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.spaceMemberships,
    aliasName: 'spaces__id__space_memberships__space_id',
  );

  $$SpaceMembershipsTableProcessedTableManager get spaceMembershipsRefs {
    final manager = $$SpaceMembershipsTableTableManager(
      $_db,
      $_db.spaceMemberships,
    ).filter((f) => f.spaceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _spaceMembershipsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SpacesTableFilterComposer
    extends Composer<_$AppDatabase, $SpacesTable> {
  $$SpacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ScreenshotsTableFilterComposer get coverMemoryId {
    final $$ScreenshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.coverMemoryId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableFilterComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> spaceMembershipsRefs(
    Expression<bool> Function($$SpaceMembershipsTableFilterComposer f) f,
  ) {
    final $$SpaceMembershipsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.spaceMemberships,
      getReferencedColumn: (t) => t.spaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpaceMembershipsTableFilterComposer(
            $db: $db,
            $table: $db.spaceMemberships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SpacesTableOrderingComposer
    extends Composer<_$AppDatabase, $SpacesTable> {
  $$SpacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScreenshotsTableOrderingComposer get coverMemoryId {
    final $$ScreenshotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.coverMemoryId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableOrderingComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpacesTable> {
  $$SpacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ScreenshotsTableAnnotationComposer get coverMemoryId {
    final $$ScreenshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.coverMemoryId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> spaceMembershipsRefs<T extends Object>(
    Expression<T> Function($$SpaceMembershipsTableAnnotationComposer a) f,
  ) {
    final $$SpaceMembershipsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.spaceMemberships,
      getReferencedColumn: (t) => t.spaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpaceMembershipsTableAnnotationComposer(
            $db: $db,
            $table: $db.spaceMemberships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SpacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpacesTable,
          SpaceRow,
          $$SpacesTableFilterComposer,
          $$SpacesTableOrderingComposer,
          $$SpacesTableAnnotationComposer,
          $$SpacesTableCreateCompanionBuilder,
          $$SpacesTableUpdateCompanionBuilder,
          (SpaceRow, $$SpacesTableReferences),
          SpaceRow,
          PrefetchHooks Function({
            bool coverMemoryId,
            bool spaceMembershipsRefs,
          })
        > {
  $$SpacesTableTableManager(_$AppDatabase db, $SpacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int?> coverMemoryId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SpacesCompanion(
                id: id,
                title: title,
                description: description,
                icon: icon,
                color: color,
                coverMemoryId: coverMemoryId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                required String icon,
                required int color,
                Value<int?> coverMemoryId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SpacesCompanion.insert(
                id: id,
                title: title,
                description: description,
                icon: icon,
                color: color,
                coverMemoryId: coverMemoryId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SpacesTable, SpaceRow>(table),
                  $$SpacesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({coverMemoryId = false, spaceMembershipsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (spaceMembershipsRefs) db.spaceMemberships,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (coverMemoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.coverMemoryId,
                            referencedTable: $$SpacesTableReferences
                                ._coverMemoryIdTable(db),
                            referencedColumn: $$SpacesTableReferences
                                ._coverMemoryIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (spaceMembershipsRefs)
                        await $_getPrefetchedDataByColumns<
                          SpaceRow,
                          $SpacesTable,
                          SpaceMembershipRow,
                          $SpaceMembershipsTable
                        >(
                          currentTable: table,
                          referencedTable: $$SpacesTableReferences
                              ._spaceMembershipsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SpacesTableReferences(
                                db,
                                table,
                                p0,
                              ).spaceMembershipsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'space_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SpacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpacesTable,
      SpaceRow,
      $$SpacesTableFilterComposer,
      $$SpacesTableOrderingComposer,
      $$SpacesTableAnnotationComposer,
      $$SpacesTableCreateCompanionBuilder,
      $$SpacesTableUpdateCompanionBuilder,
      (SpaceRow, $$SpacesTableReferences),
      SpaceRow,
      PrefetchHooks Function({bool coverMemoryId, bool spaceMembershipsRefs})
    >;
typedef $$SpaceMembershipsTableCreateCompanionBuilder =
    SpaceMembershipsCompanion Function({
      required int spaceId,
      required int memoryId,
      required String source,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });
typedef $$SpaceMembershipsTableUpdateCompanionBuilder =
    SpaceMembershipsCompanion Function({
      Value<int> spaceId,
      Value<int> memoryId,
      Value<String> source,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });

final class $$SpaceMembershipsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SpaceMembershipsTable,
          SpaceMembershipRow
        > {
  $$SpaceMembershipsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SpacesTable _spaceIdTable(_$AppDatabase db) =>
      db.spaces.createAlias('space_memberships__space_id__spaces__id');

  $$SpacesTableProcessedTableManager get spaceId {
    final $_column = $_itemColumn<int>('space_id')!;

    final manager = $$SpacesTableTableManager(
      $_db,
      $_db.spaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_spaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ScreenshotsTable _memoryIdTable(_$AppDatabase db) => db.screenshots
      .createAlias('space_memberships__memory_id__screenshots__id');

  $$ScreenshotsTableProcessedTableManager get memoryId {
    final $_column = $_itemColumn<int>('memory_id')!;

    final manager = $$ScreenshotsTableTableManager(
      $_db,
      $_db.screenshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SpaceMembershipsTableFilterComposer
    extends Composer<_$AppDatabase, $SpaceMembershipsTable> {
  $$SpaceMembershipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SpacesTableFilterComposer get spaceId {
    final $$SpacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableFilterComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScreenshotsTableFilterComposer get memoryId {
    final $$ScreenshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableFilterComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpaceMembershipsTableOrderingComposer
    extends Composer<_$AppDatabase, $SpaceMembershipsTable> {
  $$SpaceMembershipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SpacesTableOrderingComposer get spaceId {
    final $$SpacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableOrderingComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScreenshotsTableOrderingComposer get memoryId {
    final $$ScreenshotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableOrderingComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpaceMembershipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpaceMembershipsTable> {
  $$SpaceMembershipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$SpacesTableAnnotationComposer get spaceId {
    final $$SpacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spaceId,
      referencedTable: $db.spaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpacesTableAnnotationComposer(
            $db: $db,
            $table: $db.spaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScreenshotsTableAnnotationComposer get memoryId {
    final $$ScreenshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpaceMembershipsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpaceMembershipsTable,
          SpaceMembershipRow,
          $$SpaceMembershipsTableFilterComposer,
          $$SpaceMembershipsTableOrderingComposer,
          $$SpaceMembershipsTableAnnotationComposer,
          $$SpaceMembershipsTableCreateCompanionBuilder,
          $$SpaceMembershipsTableUpdateCompanionBuilder,
          (SpaceMembershipRow, $$SpaceMembershipsTableReferences),
          SpaceMembershipRow,
          PrefetchHooks Function({bool spaceId, bool memoryId})
        > {
  $$SpaceMembershipsTableTableManager(
    _$AppDatabase db,
    $SpaceMembershipsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpaceMembershipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpaceMembershipsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpaceMembershipsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> spaceId = const Value.absent(),
                Value<int> memoryId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpaceMembershipsCompanion(
                spaceId: spaceId,
                memoryId: memoryId,
                source: source,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int spaceId,
                required int memoryId,
                required String source,
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpaceMembershipsCompanion.insert(
                spaceId: spaceId,
                memoryId: memoryId,
                source: source,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SpaceMembershipsTable, SpaceMembershipRow>(
                    table,
                  ),
                  $$SpaceMembershipsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({spaceId = false, memoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (spaceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.spaceId,
                        referencedTable: $$SpaceMembershipsTableReferences
                            ._spaceIdTable(db),
                        referencedColumn: $$SpaceMembershipsTableReferences
                            ._spaceIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (memoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.memoryId,
                        referencedTable: $$SpaceMembershipsTableReferences
                            ._memoryIdTable(db),
                        referencedColumn: $$SpaceMembershipsTableReferences
                            ._memoryIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SpaceMembershipsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpaceMembershipsTable,
      SpaceMembershipRow,
      $$SpaceMembershipsTableFilterComposer,
      $$SpaceMembershipsTableOrderingComposer,
      $$SpaceMembershipsTableAnnotationComposer,
      $$SpaceMembershipsTableCreateCompanionBuilder,
      $$SpaceMembershipsTableUpdateCompanionBuilder,
      (SpaceMembershipRow, $$SpaceMembershipsTableReferences),
      SpaceMembershipRow,
      PrefetchHooks Function({bool spaceId, bool memoryId})
    >;
typedef $$MemoryRelationshipsTableCreateCompanionBuilder =
    MemoryRelationshipsCompanion Function({
      Value<int> id,
      required int sourceMemoryId,
      required int targetMemoryId,
      required RelationshipType relationshipType,
      Value<double?> score,
      required String provenance,
      required String method,
      Value<bool> confirmed,
      Value<DateTime> createdAt,
    });
typedef $$MemoryRelationshipsTableUpdateCompanionBuilder =
    MemoryRelationshipsCompanion Function({
      Value<int> id,
      Value<int> sourceMemoryId,
      Value<int> targetMemoryId,
      Value<RelationshipType> relationshipType,
      Value<double?> score,
      Value<String> provenance,
      Value<String> method,
      Value<bool> confirmed,
      Value<DateTime> createdAt,
    });

final class $$MemoryRelationshipsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MemoryRelationshipsTable,
          MemoryRelationshipRow
        > {
  $$MemoryRelationshipsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ScreenshotsTable _sourceMemoryIdTable(_$AppDatabase db) => db
      .screenshots
      .createAlias('memory_relationships__source_memory_id__screenshots__id');

  $$ScreenshotsTableProcessedTableManager get sourceMemoryId {
    final $_column = $_itemColumn<int>('source_memory_id')!;

    final manager = $$ScreenshotsTableTableManager(
      $_db,
      $_db.screenshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceMemoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ScreenshotsTable _targetMemoryIdTable(_$AppDatabase db) => db
      .screenshots
      .createAlias('memory_relationships__target_memory_id__screenshots__id');

  $$ScreenshotsTableProcessedTableManager get targetMemoryId {
    final $_column = $_itemColumn<int>('target_memory_id')!;

    final manager = $$ScreenshotsTableTableManager(
      $_db,
      $_db.screenshots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_targetMemoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MemoryRelationshipsTableFilterComposer
    extends Composer<_$AppDatabase, $MemoryRelationshipsTable> {
  $$MemoryRelationshipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RelationshipType, RelationshipType, String>
  get relationshipType => $composableBuilder(
    column: $table.relationshipType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provenance => $composableBuilder(
    column: $table.provenance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get confirmed => $composableBuilder(
    column: $table.confirmed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ScreenshotsTableFilterComposer get sourceMemoryId {
    final $$ScreenshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceMemoryId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableFilterComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScreenshotsTableFilterComposer get targetMemoryId {
    final $$ScreenshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetMemoryId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableFilterComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryRelationshipsTableOrderingComposer
    extends Composer<_$AppDatabase, $MemoryRelationshipsTable> {
  $$MemoryRelationshipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationshipType => $composableBuilder(
    column: $table.relationshipType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provenance => $composableBuilder(
    column: $table.provenance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get confirmed => $composableBuilder(
    column: $table.confirmed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScreenshotsTableOrderingComposer get sourceMemoryId {
    final $$ScreenshotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceMemoryId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableOrderingComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScreenshotsTableOrderingComposer get targetMemoryId {
    final $$ScreenshotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetMemoryId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableOrderingComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryRelationshipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemoryRelationshipsTable> {
  $$MemoryRelationshipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RelationshipType, String>
  get relationshipType => $composableBuilder(
    column: $table.relationshipType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get provenance => $composableBuilder(
    column: $table.provenance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<bool> get confirmed =>
      $composableBuilder(column: $table.confirmed, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ScreenshotsTableAnnotationComposer get sourceMemoryId {
    final $$ScreenshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceMemoryId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScreenshotsTableAnnotationComposer get targetMemoryId {
    final $$ScreenshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetMemoryId,
      referencedTable: $db.screenshots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScreenshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.screenshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryRelationshipsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemoryRelationshipsTable,
          MemoryRelationshipRow,
          $$MemoryRelationshipsTableFilterComposer,
          $$MemoryRelationshipsTableOrderingComposer,
          $$MemoryRelationshipsTableAnnotationComposer,
          $$MemoryRelationshipsTableCreateCompanionBuilder,
          $$MemoryRelationshipsTableUpdateCompanionBuilder,
          (MemoryRelationshipRow, $$MemoryRelationshipsTableReferences),
          MemoryRelationshipRow,
          PrefetchHooks Function({bool sourceMemoryId, bool targetMemoryId})
        > {
  $$MemoryRelationshipsTableTableManager(
    _$AppDatabase db,
    $MemoryRelationshipsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryRelationshipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryRelationshipsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MemoryRelationshipsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sourceMemoryId = const Value.absent(),
                Value<int> targetMemoryId = const Value.absent(),
                Value<RelationshipType> relationshipType = const Value.absent(),
                Value<double?> score = const Value.absent(),
                Value<String> provenance = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<bool> confirmed = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MemoryRelationshipsCompanion(
                id: id,
                sourceMemoryId: sourceMemoryId,
                targetMemoryId: targetMemoryId,
                relationshipType: relationshipType,
                score: score,
                provenance: provenance,
                method: method,
                confirmed: confirmed,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sourceMemoryId,
                required int targetMemoryId,
                required RelationshipType relationshipType,
                Value<double?> score = const Value.absent(),
                required String provenance,
                required String method,
                Value<bool> confirmed = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MemoryRelationshipsCompanion.insert(
                id: id,
                sourceMemoryId: sourceMemoryId,
                targetMemoryId: targetMemoryId,
                relationshipType: relationshipType,
                score: score,
                provenance: provenance,
                method: method,
                confirmed: confirmed,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MemoryRelationshipsTable, MemoryRelationshipRow>(
                    table,
                  ),
                  $$MemoryRelationshipsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sourceMemoryId = false, targetMemoryId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sourceMemoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sourceMemoryId,
                            referencedTable:
                                $$MemoryRelationshipsTableReferences
                                    ._sourceMemoryIdTable(db),
                            referencedColumn:
                                $$MemoryRelationshipsTableReferences
                                    ._sourceMemoryIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (targetMemoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.targetMemoryId,
                            referencedTable:
                                $$MemoryRelationshipsTableReferences
                                    ._targetMemoryIdTable(db),
                            referencedColumn:
                                $$MemoryRelationshipsTableReferences
                                    ._targetMemoryIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$MemoryRelationshipsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemoryRelationshipsTable,
      MemoryRelationshipRow,
      $$MemoryRelationshipsTableFilterComposer,
      $$MemoryRelationshipsTableOrderingComposer,
      $$MemoryRelationshipsTableAnnotationComposer,
      $$MemoryRelationshipsTableCreateCompanionBuilder,
      $$MemoryRelationshipsTableUpdateCompanionBuilder,
      (MemoryRelationshipRow, $$MemoryRelationshipsTableReferences),
      MemoryRelationshipRow,
      PrefetchHooks Function({bool sourceMemoryId, bool targetMemoryId})
    >;
typedef $$ModelRegistryTableCreateCompanionBuilder =
    ModelRegistryCompanion Function({
      required String modelId,
      required String modelType,
      required String version,
      Value<String?> path,
      required ModelInstallState installState,
      required String sha256,
      required int sizeBytes,
      required String license,
      Value<String?> embeddingSpaceId,
      Value<DateTime?> installedAt,
      Value<int> rowid,
    });
typedef $$ModelRegistryTableUpdateCompanionBuilder =
    ModelRegistryCompanion Function({
      Value<String> modelId,
      Value<String> modelType,
      Value<String> version,
      Value<String?> path,
      Value<ModelInstallState> installState,
      Value<String> sha256,
      Value<int> sizeBytes,
      Value<String> license,
      Value<String?> embeddingSpaceId,
      Value<DateTime?> installedAt,
      Value<int> rowid,
    });

class $$ModelRegistryTableFilterComposer
    extends Composer<_$AppDatabase, $ModelRegistryTable> {
  $$ModelRegistryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelType => $composableBuilder(
    column: $table.modelType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ModelInstallState, ModelInstallState, String>
  get installState => $composableBuilder(
    column: $table.installState,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get license => $composableBuilder(
    column: $table.license,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get embeddingSpaceId => $composableBuilder(
    column: $table.embeddingSpaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ModelRegistryTableOrderingComposer
    extends Composer<_$AppDatabase, $ModelRegistryTable> {
  $$ModelRegistryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelType => $composableBuilder(
    column: $table.modelType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get installState => $composableBuilder(
    column: $table.installState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get license => $composableBuilder(
    column: $table.license,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get embeddingSpaceId => $composableBuilder(
    column: $table.embeddingSpaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ModelRegistryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ModelRegistryTable> {
  $$ModelRegistryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<String> get modelType =>
      $composableBuilder(column: $table.modelType, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ModelInstallState, String>
  get installState => $composableBuilder(
    column: $table.installState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get license =>
      $composableBuilder(column: $table.license, builder: (column) => column);

  GeneratedColumn<String> get embeddingSpaceId => $composableBuilder(
    column: $table.embeddingSpaceId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => column,
  );
}

class $$ModelRegistryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ModelRegistryTable,
          ModelRegistryRow,
          $$ModelRegistryTableFilterComposer,
          $$ModelRegistryTableOrderingComposer,
          $$ModelRegistryTableAnnotationComposer,
          $$ModelRegistryTableCreateCompanionBuilder,
          $$ModelRegistryTableUpdateCompanionBuilder,
          (
            ModelRegistryRow,
            BaseReferences<
              _$AppDatabase,
              $ModelRegistryTable,
              ModelRegistryRow
            >,
          ),
          ModelRegistryRow,
          PrefetchHooks Function()
        > {
  $$ModelRegistryTableTableManager(_$AppDatabase db, $ModelRegistryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModelRegistryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModelRegistryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModelRegistryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> modelId = const Value.absent(),
                Value<String> modelType = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<String?> path = const Value.absent(),
                Value<ModelInstallState> installState = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String> license = const Value.absent(),
                Value<String?> embeddingSpaceId = const Value.absent(),
                Value<DateTime?> installedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModelRegistryCompanion(
                modelId: modelId,
                modelType: modelType,
                version: version,
                path: path,
                installState: installState,
                sha256: sha256,
                sizeBytes: sizeBytes,
                license: license,
                embeddingSpaceId: embeddingSpaceId,
                installedAt: installedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String modelId,
                required String modelType,
                required String version,
                Value<String?> path = const Value.absent(),
                required ModelInstallState installState,
                required String sha256,
                required int sizeBytes,
                required String license,
                Value<String?> embeddingSpaceId = const Value.absent(),
                Value<DateTime?> installedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModelRegistryCompanion.insert(
                modelId: modelId,
                modelType: modelType,
                version: version,
                path: path,
                installState: installState,
                sha256: sha256,
                sizeBytes: sizeBytes,
                license: license,
                embeddingSpaceId: embeddingSpaceId,
                installedAt: installedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ModelRegistryTable, ModelRegistryRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ModelRegistryTable,
                    ModelRegistryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ModelRegistryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ModelRegistryTable,
      ModelRegistryRow,
      $$ModelRegistryTableFilterComposer,
      $$ModelRegistryTableOrderingComposer,
      $$ModelRegistryTableAnnotationComposer,
      $$ModelRegistryTableCreateCompanionBuilder,
      $$ModelRegistryTableUpdateCompanionBuilder,
      (
        ModelRegistryRow,
        BaseReferences<_$AppDatabase, $ModelRegistryTable, ModelRegistryRow>,
      ),
      ModelRegistryRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ScreenshotsTableTableManager get screenshots =>
      $$ScreenshotsTableTableManager(_db, _db.screenshots);
  $$OcrResultsTableTableManager get ocrResults =>
      $$OcrResultsTableTableManager(_db, _db.ocrResults);
  $$ExtractedEntitiesTableTableManager get extractedEntities =>
      $$ExtractedEntitiesTableTableManager(_db, _db.extractedEntities);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$CollectionItemsTableTableManager get collectionItems =>
      $$CollectionItemsTableTableManager(_db, _db.collectionItems);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$ScreenshotTagsTableTableManager get screenshotTags =>
      $$ScreenshotTagsTableTableManager(_db, _db.screenshotTags);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$SuggestedActionsTableTableManager get suggestedActions =>
      $$SuggestedActionsTableTableManager(_db, _db.suggestedActions);
  $$WishlistItemsTableTableManager get wishlistItems =>
      $$WishlistItemsTableTableManager(_db, _db.wishlistItems);
  $$ProcessingJobsTableTableManager get processingJobs =>
      $$ProcessingJobsTableTableManager(_db, _db.processingJobs);
  $$SearchHistoryTableTableManager get searchHistory =>
      $$SearchHistoryTableTableManager(_db, _db.searchHistory);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$ClassificationRulesTableTableManager get classificationRules =>
      $$ClassificationRulesTableTableManager(_db, _db.classificationRules);
  $$MemoryChunksTableTableManager get memoryChunks =>
      $$MemoryChunksTableTableManager(_db, _db.memoryChunks);
  $$EmbeddingsTableTableManager get embeddings =>
      $$EmbeddingsTableTableManager(_db, _db.embeddings);
  $$SpacesTableTableManager get spaces =>
      $$SpacesTableTableManager(_db, _db.spaces);
  $$SpaceMembershipsTableTableManager get spaceMemberships =>
      $$SpaceMembershipsTableTableManager(_db, _db.spaceMemberships);
  $$MemoryRelationshipsTableTableManager get memoryRelationships =>
      $$MemoryRelationshipsTableTableManager(_db, _db.memoryRelationships);
  $$ModelRegistryTableTableManager get modelRegistry =>
      $$ModelRegistryTableTableManager(_db, _db.modelRegistry);
}
