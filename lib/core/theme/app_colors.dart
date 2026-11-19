import 'package:material_ui/material_ui.dart';

/// Snaptiq "Acid Pop" palette. Source of truth:
/// assets/icons/developer/snaptiq_tokens.json.
abstract final class AppColors {
  // Brand
  static const acidLime = Color(0xFFD4FF3A);
  static const hotPink = Color(0xFFFF2E93);
  static const voltViolet = Color(0xFF7C3AED);
  static const ink = Color(0xFF0A0A0F);
  static const limeSoft = Color(0xFFE9FF94);
  static const paper = Color(0xFFFAFCF2);

  /// Kept for callers that ask for "the" brand colour: primary actions.
  static const primary = hotPink;
  static const secondary = voltViolet;

  // Light
  static const lightBackground = paper;
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF0F3E4);
  static const lightText = ink;
  static const lightTextSecondary = Color(0xFF4B4B57);
  static const lightOutlineVariant = Color(0xFFDDE1CF);
  static const lightPrimaryContainer = Color(0xFFFFD1E6);
  static const lightSecondaryContainer = Color(0xFFE9DDFF);
  static const lightError = Color(0xFFC4001E);
  static const lightSuccess = Color(0xFF15803D);
  static const lightTextLink = Color(0xFFD61F7A);

  // Status fills (used as 12 % tints) and readable foregrounds. Every
  // foreground reaches WCAG AA (4.5:1) on a 12 % tint over white and over
  // [paper] (checked in test/widget/design_widgets_test.dart).
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const lightOnSuccess = Color(0xFF166534); // 6.2:1 on a tint
  static const lightOnWarning = Color(0xFF92400E); // 6.2:1
  static const lightOnInfo = voltViolet; // 5.7:1
  static const lightOnDanger = lightError; // 6.3:1
  static const lightOnAccent = Color(0xFFC2186E); // 4.7:1 on a pink tint

  /// Favourite star: a graphic, so it needs 3:1 (WCAG 1.4.11) on white.
  static const lightFavorite = Color(0xFFE0157A); // 4.3:1

  // Dark
  static const darkBackground = ink;
  static const darkSurface = Color(0xFF16161D);
  static const darkElevated = Color(0xFF22222B);
  static const darkPrimary = Color(0xFFFF4FA3);
  static const darkSecondary = Color(0xFFA78BFA);
  static const darkText = Color(0xFFF5F5F7);
  static const darkTextSecondary = Color(0xFFA1A1AE);
  static const darkBorder = Color(0xFF33333D);
  static const darkError = Color(0xFFFF6B6B);
  static const darkOnSuccess = Color(0xFF4ADE80);
  static const darkOnWarning = Color(0xFFFBBF24);
  static const darkOnInfo = darkSecondary;
  static const darkOnDanger = darkError;
  static const darkOnAccent = darkPrimary;
  static const darkFavorite = darkPrimary;
}

/// Semantic colours that Material's [ColorScheme] has no slot for.
///
/// [success] and [warning] are fill/tint colours. They are too light for
/// text on light surfaces, so use [onSuccess] / [onWarning] (and [onInfo],
/// [onDanger], [onAccent]) for text and icons placed on a surface or on a
/// tint of the status colour.
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
    this.outlineStrong = AppColors.ink,
    this.shadowHard = AppColors.ink,
    this.highlight = AppColors.acidLime,
    this.onHighlight = AppColors.ink,
  });

  final Color success;
  final Color warning;

  /// Subtle divider and hairline colour.
  final Color border;
  final Color textSecondary;
  final Color elevated;

  /// Text/icon colour for success states (e.g. "Reviewed").
  final Color onSuccess;

  /// Text/icon colour for warning states (e.g. "Queued", "Please check").
  final Color onWarning;

  /// Text/icon colour for neutral-informational states (e.g. "Needs review").
  final Color onInfo;

  /// Text/icon colour for error states on a tinted background.
  final Color onDanger;

  /// Text/icon colour for primary-tinted states (e.g. "Processing").
  final Color onAccent;

  /// Colour of the filled favourite star.
  final Color favorite;

  /// The brand's bold outline: ink on light, near-white on dark.
  final Color outlineStrong;

  /// Hard, unblurred brand shadow: ink on light, acid lime on dark.
  final Color shadowHard;

  /// Acid lime brand surface for highlights, and its readable foreground.
  final Color highlight;
  final Color onHighlight;

  static const light = StatusColors(
    success: AppColors.success,
    warning: AppColors.warning,
    border: AppColors.lightOutlineVariant,
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
    outlineStrong: AppColors.darkText,
    shadowHard: AppColors.acidLime,
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
    Color? outlineStrong,
    Color? shadowHard,
    Color? highlight,
    Color? onHighlight,
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
    outlineStrong: outlineStrong ?? this.outlineStrong,
    shadowHard: shadowHard ?? this.shadowHard,
    highlight: highlight ?? this.highlight,
    onHighlight: onHighlight ?? this.onHighlight,
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
      outlineStrong: l(outlineStrong, other.outlineStrong),
      shadowHard: l(shadowHard, other.shadowHard),
      highlight: l(highlight, other.highlight),
      onHighlight: l(onHighlight, other.onHighlight),
    );
  }
}

extension StatusColorsX on BuildContext {
  StatusColors get statusColors =>
      Theme.of(this).extension<StatusColors>() ?? StatusColors.light;
}
