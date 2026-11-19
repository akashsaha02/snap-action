import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'spacing.dart';

/// Snaptiq "Acid Pop" theme: paper background, ink outlines, hard offset
/// shadows, pill buttons, Space Grotesk headings and Inter text.
/// Tokens: assets/icons/developer/snaptiq_tokens.json.
abstract final class AppTheme {
  static const fontFamily = 'Inter';
  static const displayFamily = 'SpaceGrotesk';

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.hotPink,
      onPrimary: AppColors.ink,
      primaryContainer: AppColors.lightPrimaryContainer,
      onPrimaryContainer: AppColors.ink,
      secondary: AppColors.voltViolet,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.lightSecondaryContainer,
      onSecondaryContainer: AppColors.ink,
      tertiary: AppColors.acidLime,
      onTertiary: AppColors.ink,
      tertiaryContainer: AppColors.limeSoft,
      onTertiaryContainer: AppColors.ink,
      error: AppColors.lightError,
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD9),
      onErrorContainer: Color(0xFF5C0010),
      surface: AppColors.lightSurface,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.lightTextSecondary,
      surfaceContainerLowest: AppColors.lightSurface,
      surfaceContainerLow: Color(0xFFF6F9EC),
      surfaceContainer: AppColors.lightSurfaceVariant,
      surfaceContainerHigh: Color(0xFFE9EDDA),
      surfaceContainerHighest: Color(0xFFE2E7D0),
      outline: AppColors.ink,
      outlineVariant: AppColors.lightOutlineVariant,
      shadow: AppColors.ink,
      scrim: AppColors.ink,
      inverseSurface: AppColors.ink,
      onInverseSurface: AppColors.paper,
      inversePrimary: AppColors.darkPrimary,
    );
    return _build(scheme, AppColors.lightBackground, StatusColors.light);
  }

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.ink,
      primaryContainer: Color(0xFF5C0F35),
      onPrimaryContainer: Color(0xFFFFD1E6),
      secondary: AppColors.darkSecondary,
      onSecondary: AppColors.ink,
      secondaryContainer: Color(0xFF3B1F7A),
      onSecondaryContainer: Color(0xFFE9DDFF),
      tertiary: AppColors.acidLime,
      onTertiary: AppColors.ink,
      tertiaryContainer: Color(0xFF3A4710),
      onTertiaryContainer: AppColors.limeSoft,
      error: AppColors.darkError,
      onError: AppColors.ink,
      errorContainer: Color(0xFF5C0010),
      onErrorContainer: Color(0xFFFFDAD9),
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
      onSurfaceVariant: AppColors.darkTextSecondary,
      surfaceContainerLowest: AppColors.darkBackground,
      surfaceContainerLow: Color(0xFF121218),
      surfaceContainer: AppColors.darkSurface,
      surfaceContainerHigh: AppColors.darkElevated,
      surfaceContainerHighest: Color(0xFF2A2A34),
      outline: AppColors.darkText,
      outlineVariant: AppColors.darkBorder,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: AppColors.darkText,
      onInverseSurface: AppColors.ink,
      inversePrimary: AppColors.hotPink,
    );
    return _build(scheme, AppColors.darkBackground, StatusColors.dark);
  }

  static TextTheme _textTheme(Color main, Color secondary) {
    TextStyle display(double size, double height, double tracking) => TextStyle(
      fontFamily: displayFamily,
      fontSize: size,
      fontWeight: FontWeight.w700,
      height: height / size,
      letterSpacing: tracking,
      color: main,
    );
    return TextTheme(
      displayLarge: display(40, 44, -1.2),
      displayMedium: display(34, 38, -1),
      displaySmall: display(30, 34, -0.8),
      headlineLarge: display(32, 36, -0.8),
      headlineMedium: display(24, 30, -0.5),
      headlineSmall: display(22, 28, -0.4),
      titleLarge: display(20, 26, -0.2),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 22 / 16,
        color: main,
      ),
      titleSmall: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 20 / 15,
        color: main,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 24 / 16, color: main),
      bodyMedium: TextStyle(fontSize: 14, height: 20 / 14, color: main),
      bodySmall: TextStyle(fontSize: 13, height: 18 / 13, color: secondary),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        letterSpacing: 0.1,
        color: main,
      ),
      labelMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 18 / 13,
        color: secondary,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.3,
        color: secondary,
      ),
    );
  }

  static ThemeData _build(
    ColorScheme scheme,
    Color background,
    StatusColors status,
  ) {
    final text = _textTheme(scheme.onSurface, scheme.onSurfaceVariant);
    final isLight = scheme.brightness == Brightness.light;
    // Light theme: bold ink outlines. Dark theme: quiet outlines, the lime
    // hard shadow carries the brand instead.
    final ink = BorderSide(
      color: isLight ? status.outlineStrong : status.border,
      width: Spacing.outline,
    );
    final thinInk = BorderSide(
      color: isLight ? status.outlineStrong : status.border,
      width: Spacing.outlineThin,
    );
    RoundedRectangleBorder rounded(
      double r, [
      BorderSide side = BorderSide.none,
    ]) => RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(r),
      side: side,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      textTheme: text,
      scaffoldBackgroundColor: background,
      extensions: [status],
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: rounded(Spacing.radiusMd, ink),
        clipBehavior: Clip.antiAlias,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        // Acid lime pill under the selected tab, ink icon on it.
        indicatorColor: status.highlight,
        indicatorShape: StadiumBorder(side: thinInk),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? status.onHighlight
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        extendedTextStyle: text.labelLarge?.copyWith(fontSize: 15),
        shape: StadiumBorder(side: ink.copyWith(color: status.outlineStrong)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, Spacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          textStyle: text.labelLarge,
          shape: StadiumBorder(side: ink.copyWith(color: status.outlineStrong)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(64, Spacing.minTouchTarget),
          textStyle: text.labelLarge,
          shape: StadiumBorder(side: ink),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, Spacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          textStyle: text.labelLarge,
          foregroundColor: scheme.onSurface,
          backgroundColor: scheme.surface,
          side: ink.copyWith(color: status.outlineStrong),
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, Spacing.minTouchTarget),
          textStyle: text.labelLarge,
          // Pink text on paper is too faint; the link tone reads at 4.6:1.
          foregroundColor: isLight ? AppColors.lightTextLink : scheme.primary,
          shape: const StadiumBorder(),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: scheme.onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          borderSide: thinInk,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          borderSide: thinInk,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          borderSide: BorderSide(color: scheme.primary, width: Spacing.outline),
        ),
      ),
      chipTheme: ChipThemeData(
        side: thinInk,
        shape: const StadiumBorder(),
        backgroundColor: scheme.surface,
        selectedColor: status.highlight,
        checkmarkColor: status.onHighlight,
        // Selected chips sit on acid lime, so their label and icon switch to
        // ink in both themes (white on lime would be unreadable in dark).
        labelStyle: text.labelMedium?.copyWith(
          color: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? status.onHighlight
                : scheme.onSurface,
          ),
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          size: 18,
          color: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? status.onHighlight
                : scheme.onSurfaceVariant,
          ),
        ),
        secondaryLabelStyle: text.labelMedium?.copyWith(
          color: status.onHighlight,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: status.highlight,
          selectedForegroundColor: status.onHighlight,
          side: thinInk,
        ),
      ),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStateProperty.all(
          isLight ? status.outlineStrong : status.border,
        ),
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.ink
              : scheme.onSurfaceVariant,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? status.highlight
              : scheme.surfaceContainerHigh,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        side: thinInk,
        fillColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? scheme.primary : null,
        ),
        checkColor: WidgetStateProperty.all(AppColors.ink),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHigh,
      ),
      dividerTheme: DividerThemeData(color: status.border, space: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: scheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Spacing.radiusXl),
          ),
          side: ink,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: text.headlineSmall,
        shape: rounded(Spacing.radiusLg, ink),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: rounded(Spacing.radiusMd, thinInk),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: text.bodyMedium?.copyWith(color: AppColors.paper),
        actionTextColor: AppColors.acidLime,
        shape: rounded(
          Spacing.radiusMd,
          isLight
              ? BorderSide.none
              : const BorderSide(color: AppColors.acidLime, width: 1.5),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(Spacing.radiusSm),
        ),
        textStyle: text.labelSmall?.copyWith(color: AppColors.paper),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        minVerticalPadding: Spacing.sm,
        titleTextStyle: text.titleSmall,
        subtitleTextStyle: text.bodySmall,
      ),
    );
  }
}
