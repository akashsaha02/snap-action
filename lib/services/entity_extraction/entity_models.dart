import '../../core/database/enums.dart';

enum DateOrder { dmy, mdy, ymd }

class Entity {
  const Entity({
    required this.type,
    required this.raw,
    this.normalized,
    this.metadata = const {},
    this.needsConfirmation = false,
  });

  final EntityType type;

  /// Exactly as it appeared in the text.
  final String raw;

  /// Canonical form (ISO date, E.164-like phone, lower-case email, ...).
  final String? normalized;
  final Map<String, Object?> metadata;

  /// The value was inferred with ambiguity and must be confirmed by the user.
  final bool needsConfirmation;

  ValidationStatus get validationStatus => needsConfirmation
      ? ValidationStatus.needsConfirmation
      : ValidationStatus.valid;

  @override
  String toString() =>
      'Entity(${type.name}, "$raw" -> $normalized${needsConfirmation ? ', ?' : ''})';
}

/// A calendar date that may be missing its year. Never filled in with a
/// guessed value.
class PartialDate {
  const PartialDate({required this.month, required this.day, this.year});

  final int? year;
  final int month;
  final int day;

  bool get hasYear => year != null;

  /// ISO 8601 date, or `--MM-DD` when the year is unknown.
  String get iso {
    final mm = month.toString().padLeft(2, '0');
    final dd = day.toString().padLeft(2, '0');
    return year == null
        ? '--$mm-$dd'
        : '${year!.toString().padLeft(4, '0')}-$mm-$dd';
  }

  static PartialDate? parseIso(String? value) {
    if (value == null) return null;
    final full = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (full != null) {
      return PartialDate(
        year: int.parse(full[1]!),
        month: int.parse(full[2]!),
        day: int.parse(full[3]!),
      );
    }
    final partial = RegExp(r'^--(\d{2})-(\d{2})$').firstMatch(value);
    if (partial != null) {
      return PartialDate(
        month: int.parse(partial[1]!),
        day: int.parse(partial[2]!),
      );
    }
    return null;
  }

  DateTime? toDateTime() => year == null ? null : DateTime(year!, month, day);
}

class MoneyAmount {
  const MoneyAmount({
    required this.minorUnits,
    required this.currency,
    required this.decimals,
    this.currencyAmbiguous = false,
  });

  /// Value in the currency's smallest unit; never a floating-point number.
  final int minorUnits;

  /// ISO 4217 code.
  final String currency;
  final int decimals;
  final bool currencyAmbiguous;

  String get formatted {
    if (decimals == 0) return '$currency $minorUnits';
    final factor = _pow10(decimals);
    final major = minorUnits ~/ factor;
    final minor = (minorUnits % factor).toString().padLeft(decimals, '0');
    return '$currency $major.$minor';
  }

  static int _pow10(int n) {
    var r = 1;
    for (var i = 0; i < n; i++) {
      r *= 10;
    }
    return r;
  }
}
