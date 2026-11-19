import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

/// The next screenshot waiting in the inbox after [current] (newest first,
/// wrapping around), or null when the inbox is otherwise empty.
Future<int?> nextInboxScreenshot(AppDatabase db, ScreenshotRow current) async {
  Future<int?> first(Expression<bool> extra) async {
    final row =
        await (db.select(db.screenshots)
              ..where(
                (s) =>
                    s.isArchived.equals(false) &
                    s.isReviewed.equals(false) &
                    s.id.equals(current.id).not() &
                    extra,
              )
              ..orderBy([
                (s) => OrderingTerm.desc(s.importedAt),
                (s) => OrderingTerm.desc(s.id),
              ])
              ..limit(1))
            .getSingleOrNull();
    return row?.id;
  }

  return await first(
        db.screenshots.importedAt.isSmallerThanValue(current.importedAt) |
            (db.screenshots.importedAt.equals(current.importedAt) &
                db.screenshots.id.isSmallerThanValue(current.id)),
      ) ??
      await first(const Constant(true));
}
