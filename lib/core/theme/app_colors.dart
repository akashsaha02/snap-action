import 'package:material_ui/material_ui.dart';

abstract final class AppColors {
  // Light
  static const lightBackground = Color(0xFFF8F9FC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const primary = Color(0xFF635BFF);
  static const primaryDark = Color(0xFF4F46E5);
  static const secondary = Color(0xFF14B8A6);
  static const lightText = Color(0xFF111827);
  static const lightTextSecondary = Color(0xFF6B7280);
  static const lightBorder = Color(0xFFE5E7EB);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  /// Error color used by the light theme. Darker than [error] so white text
  /// on it (snack bars, destructive buttons) and red text on white surfaces
  /// reach WCAG AA (4.8:1).
  static const lightError = Color(0xFFDC2626);

  // Readable foregrounds for text and icons on light surfaces or on a 12 %
  // tint of the matching status color. Each one reaches at least 4.5:1
  // (WCAG AA for small text) on white and on [lightBackground].
  static const lightOnSuccess = Color(0xFF166534); // 6.1:1 or better
  static const lightOnWarning = Color(0xFF92400E); // 6.2:1 or better
  static const lightOnInfo = Color(0xFF0F766E); // 4.7:1 or better
  static const lightOnDanger = Color(0xFFB91C1C); // 5.3:1 or better
  static const lightOnAccent = primaryDark; // 5.1:1 or better

  /// Favourite star. A graphic, so it needs 3:1 (WCAG 1.4.11) on white.
  static const lightFavorite = Color(0xFFD97706);

  // Dark
  static const darkBackground = Color(0xFF0F1117);
  static const darkSurface = Color(0xFF181B24);
  static const darkElevated = Color(0xFF222632);
  static const darkPrimary = Color(0xFF8B83FF);
  static const darkText = Color(0xFFF9FAFB);
  static const darkTextSecondary = Color(0xFF9CA3AF);
  static const darkBorder = Color(0xFF303542);
  static const darkError = Color(0xFFF87171);

  // Dark-theme counterparts; each reaches at least 5.5:1 on [darkSurface]
  // and on a 12 % tint of the matching status color.
  static const darkOnSuccess = Color(0xFF4ADE80);
  static const darkOnWarning = Color(0xFFFBBF24);
  static const darkOnInfo = Color(0xFF2DD4BF);
  static const darkOnDanger = Color(0xFFF87171);
  static const darkOnAccent = Color(0xFFA5A0FF);
  static const darkFavorite = Color(0xFFFBBF24);
}

/// Semantic colors that Material's [ColorScheme] has no slot for.
///
/// [success] and [warning] are fill/tint colors. They are too light for text
/// on light surfaces, so use [onSuccess] / [onWarning] (and [onInfo],
/// [onDanger], [onAccent]) for text and icons placed on a surface or on a
/// tint of the status color.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.success,
    required this.warning,
    required this.border,
    required this.textSecondary,
    required this.elevated,
    this.onSuccess = AppColors.lightOnSuccess,
    this.onWarning = AppColors.lightOnWarning,
    this.onInfo = AppColors.lightOnInfo,
    this.onDanger = AppColors.lightOnDanger,
    this.onAccent = AppColors.lightOnAccent,
    this.favorite = AppColors.lightFavorite,
  });

  final Color success;
  final Color warning;
  final Color border;
  final Color textSecondary;
  final Color elevated;

  /// Text/icon color for success states (e.g. "Reviewed").
  final Color onSuccess;

  /// Text/icon color for warning states (e.g. "Queued", "Please check").
  final Color onWarning;

  /// Text/icon color for neutral-informational states (e.g. "Needs review").
  final Color onInfo;

  /// Text/icon color for error states on a tinted background.
  final Color onDanger;

  /// Text/icon color for primary-tinted states (e.g. "Processing").
  final Color onAccent;

  /// Color of the filled favourite star.
  final Color favorite;

  static const light = StatusColors(
    success: AppColors.success,
    warning: AppColors.warning,
    border: AppColors.lightBorder,
    textSecondary: AppColors.lightTextSecondary,
    elevated: AppColors.lightSurface,
  );

  static const dark = StatusColors(
    success: AppColors.success,
    warning: AppColors.warning,
    border: AppColors.darkBorder,
    textSecondary: AppColors.darkTextSecondary,
    elevated: AppColors.darkElevated,
    onSuccess: AppColors.darkOnSuccess,
    onWarning: AppColors.darkOnWarning,
    onInfo: AppColors.darkOnInfo,
    onDanger: AppColors.darkOnDanger,
    onAccent: AppColors.darkOnAccent,
    favorite: AppColors.darkFavorite,
  );

  @override
  StatusColors copyWith({
    Color? success,
    Color? warning,
    Color? border,
    Color? textSecondary,
    Color? elevated,
    Color? onSuccess,
    Color? onWarning,
    Color? onInfo,
    Color? onDanger,
    Color? onAccent,
    Color? favorite,
  }) => StatusColors(
    success: success ?? this.success,
    warning: warning ?? this.warning,
    border: border ?? this.border,
    textSecondary: textSecondary ?? this.textSecondary,
    elevated: elevated ?? this.elevated,
    onSuccess: onSuccess ?? this.onSuccess,
    onWarning: onWarning ?? this.onWarning,
    onInfo: onInfo ?? this.onInfo,
    onDanger: onDanger ?? this.onDanger,
    onAccent: onAccent ?? this.onAccent,
    favorite: favorite ?? this.favorite,
  );

  @override
  StatusColors lerp(StatusColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return StatusColors(
      success: l(success, other.success),
      warning: l(warning, other.warning),
      border: l(border, other.border),
      textSecondary: l(textSecondary, other.textSecondary),
      elevated: l(elevated, other.elevated),
      onSuccess: l(onSuccess, other.onSuccess),
      onWarning: l(onWarning, other.onWarning),
      onInfo: l(onInfo, other.onInfo),
      onDanger: l(onDanger, other.onDanger),
      onAccent: l(onAccent, other.onAccent),
      favorite: l(favorite, other.favorite),
    );
  }
}

extension StatusColorsX on BuildContext {
  StatusColors get statusColors =>
      Theme.of(this).extension<StatusColors>() ?? StatusColors.light;
}
