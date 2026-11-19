import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/screenshot_summary.dart';

class CategoryRepository {
  CategoryRepository(this._db);

  final AppDatabase _db;

  static CategoryInfo toInfo(CategoryRow r) => CategoryInfo(
    id: r.id,
    slug: r.slug,
    name: r.name,
    icon: r.icon,
    color: r.color,
    isSystem: r.isSystem,
  );

  Stream<List<CategoryInfo>> watchAll() =>
      (_db.select(_db.categories)..orderBy([(c) => OrderingTerm.asc(c.id)]))
          .watch()
          .map((rows) => rows.map(toInfo).toList());

  Future<List<CategoryInfo>> getAll() async =>
      (await _db.select(_db.categories).get()).map(toInfo).toList();

  Future<Map<String, int>> idsBySlug() async => {
    for (final c in await _db.select(_db.categories).get()) c.slug: c.id,
  };

  Future<Map<int, int>> counts() async {
    final rows = await _db
        .customSelect(
          'SELECT coalesce(primary_category_id, suggested_category_id) AS cid, '
          'count(*) AS n FROM screenshots WHERE is_archived = 0 '
          'GROUP BY cid',
          readsFrom: {_db.screenshots},
        )
        .get();
    return {
      for (final r in rows)
        if (r.read<int?>('cid') != null) r.read<int>('cid'): r.read<int>('n'),
    };
  }

  Stream<List<CategoryCount>> watchWithCounts({int previewCount = 3}) {
    return _db
        .customSelect(
          'SELECT c.id, c.slug, c.name, c.icon, c.color, c.is_system, '
          '(SELECT count(*) FROM screenshots s WHERE s.is_archived = 0 AND '
          'coalesce(s.primary_category_id, s.suggested_category_id) = c.id) AS n, '
          '(SELECT group_concat(p, char(31)) FROM (SELECT coalesce(s.thumbnail_path, s.local_file_path) AS p '
          'FROM screenshots s WHERE s.is_archived = 0 AND '
          'coalesce(s.primary_category_id, s.suggested_category_id) = c.id '
          'ORDER BY s.imported_at DESC LIMIT ?)) AS previews '
          'FROM categories c ORDER BY c.id',
          variables: [Variable.withInt(previewCount)],
          readsFrom: {_db.categories, _db.screenshots},
        )
        .watch()
        .map(
          (rows) => [
            for (final r in rows)
              CategoryCount(
                category: CategoryInfo(
                  id: r.read<int>('id'),
                  slug: r.read<String>('slug'),
                  name: r.read<String>('name'),
                  icon: r.read<String>('icon'),
                  color: r.read<int>('color'),
                  isSystem: r.read<bool>('is_system'),
                ),
                count: r.read<int>('n'),
                previewPaths:
                    r.read<String?>('previews')?.split('\u001f') ?? const [],
              ),
          ],
        );
  }
}

class CategoryCount {
  const CategoryCount({
    required this.category,
    required this.count,
    required this.previewPaths,
  });

  final CategoryInfo category;
  final int count;
  final List<String> previewPaths;
}
