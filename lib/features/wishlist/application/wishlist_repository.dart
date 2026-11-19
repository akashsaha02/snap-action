import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class WishlistDraft {
  const WishlistDraft({
    this.productName,
    this.minorUnits,
    this.currency,
    this.merchantName,
    this.productUrl,
    this.notes,
    this.screenshotId,
  });

  final String? productName;
  final int? minorUnits;
  final String? currency;
  final String? merchantName;
  final String? productUrl;
  final String? notes;
  final int? screenshotId;
}

class WishlistEntry {
  const WishlistEntry({required this.item, this.thumbnailPath});

  final WishlistItemRow item;
  final String? thumbnailPath;
}

class WishlistRepository {
  WishlistRepository(this._db);

  final AppDatabase _db;

  Stream<List<WishlistEntry>> watchAll() {
    final q =
        _db.select(_db.wishlistItems).join([
          leftOuterJoin(
            _db.screenshots,
            _db.screenshots.id.equalsExp(_db.wishlistItems.screenshotId),
          ),
        ])..orderBy([
          OrderingTerm.asc(_db.wishlistItems.purchased),
          OrderingTerm.desc(_db.wishlistItems.createdAt),
        ]);
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          WishlistEntry(
            item: r.readTable(_db.wishlistItems),
            thumbnailPath:
                r.readTableOrNull(_db.screenshots)?.thumbnailPath ??
                r.readTableOrNull(_db.screenshots)?.localFilePath,
          ),
      ],
    );
  }

  Future<int> add(WishlistDraft d) {
    _validate(d);
    return _db
        .into(_db.wishlistItems)
        .insert(
          WishlistItemsCompanion.insert(
            screenshotId: Value(d.screenshotId),
            productName: Value(_clean(d.productName)),
            amountMinorUnits: Value(d.minorUnits),
            currency: Value(d.minorUnits == null ? null : _clean(d.currency)),
            merchantName: Value(_clean(d.merchantName)),
            productUrl: Value(_clean(d.productUrl)),
            notes: Value(_clean(d.notes)),
          ),
        );
  }

  Future<void> update(int id, WishlistDraft d) {
    _validate(d);
    return (_db.update(_db.wishlistItems)..where((w) => w.id.equals(id))).write(
      WishlistItemsCompanion(
        productName: Value(_clean(d.productName)),
        amountMinorUnits: Value(d.minorUnits),
        currency: Value(d.minorUnits == null ? null : _clean(d.currency)),
        merchantName: Value(_clean(d.merchantName)),
        productUrl: Value(_clean(d.productUrl)),
        notes: Value(_clean(d.notes)),
      ),
    );
  }

  Future<void> setPurchased(int id, {required bool purchased}) =>
      (_db.update(_db.wishlistItems)..where((w) => w.id.equals(id))).write(
        WishlistItemsCompanion(purchased: Value(purchased)),
      );

  Future<void> delete(int id) =>
      (_db.delete(_db.wishlistItems)..where((w) => w.id.equals(id))).go();

  /// Totals of items not yet bought, per currency (never mixed).
  static Map<String, int> openTotals(List<WishlistEntry> entries) {
    final totals = <String, int>{};
    for (final e in entries) {
      final i = e.item;
      if (i.purchased || i.amountMinorUnits == null || i.currency == null) {
        continue;
      }
      totals[i.currency!] = (totals[i.currency!] ?? 0) + i.amountMinorUnits!;
    }
    return totals;
  }

  static void _validate(WishlistDraft d) {
    if (_clean(d.productName) == null && d.screenshotId == null) {
      throw ArgumentError('Please enter a product name.');
    }
    if (d.minorUnits != null && d.minorUnits! < 0) {
      throw ArgumentError('Price cannot be negative.');
    }
    if (d.minorUnits != null && _clean(d.currency) == null) {
      throw ArgumentError('Please enter a currency for the price.');
    }
  }

  static String? _clean(String? s) {
    final t = s?.trim();
    return t == null || t.isEmpty ? null : t;
  }
}
