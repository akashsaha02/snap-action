import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'spacing.dart';

abstract final class AppTheme {
  static const fontFamily = 'Inter';

  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFE8E6FF),
          onPrimaryContainer: AppColors.primaryDark,
          secondary: AppColors.secondary,
          onSecondary: Colors.white,
          error: AppColors.lightError,
          onError: Colors.white,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightText,
          onSurfaceVariant: AppColors.lightTextSecondary,
          outline: AppColors.lightBorder,
          outlineVariant: AppColors.lightBorder,
          surfaceContainerLowest: AppColors.lightSurface,
          surfaceContainerLow: const Color(0xFFF3F4F8),
          surfaceContainer: const Color(0xFFF1F2F7),
          surfaceContainerHigh: const Color(0xFFECEDF3),
        );
    return _build(scheme, AppColors.lightBackground, StatusColors.light);
  }

  static ThemeData dark() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.darkPrimary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.darkPrimary,
          onPrimary: const Color(0xFF0F1117),
          primaryContainer: const Color(0xFF2E2A66),
          onPrimaryContainer: const Color(0xFFDCD9FF),
          secondary: AppColors.secondary,
          error: AppColors.darkError,
          onError: AppColors.darkBackground,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkText,
          onSurfaceVariant: AppColors.darkTextSecondary,
          outline: AppColors.darkBorder,
          outlineVariant: AppColors.darkBorder,
          surfaceContainerLowest: AppColors.darkBackground,
          surfaceContainerLow: AppColors.darkSurface,
          surfaceContainer: AppColors.darkSurface,
          surfaceContainerHigh: AppColors.darkElevated,
          surfaceContainerHighest: AppColors.darkElevated,
        );
    return _build(scheme, AppColors.darkBackground, StatusColors.dark);
  }

  static TextTheme _textTheme(Color main, Color secondary) {
    return TextTheme(
      displaySmall: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.6,
        color: main,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
        color: main,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.3,
        color: main,
      ),
      titleLarge: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: main,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: main,
      ),
      titleSmall: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: main,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: main),
      bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: main),
      bodySmall: TextStyle(fontSize: 13, height: 1.4, color: secondary),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: main,
      ),
      labelMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
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
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Spacing.radiusMd),
      side: BorderSide(color: status.border),
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
        shape: cardShape,
        clipBehavior: Clip.antiAlias,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, Spacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.radiusSm + 4),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, Spacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          textStyle: text.labelLarge,
          side: BorderSide(color: status.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.radiusSm + 4),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, Spacing.minTouchTarget),
          textStyle: text.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusSm + 4),
          borderSide: BorderSide(color: status.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusSm + 4),
          borderSide: BorderSide(color: status.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusSm + 4),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(color: status.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusSm),
        ),
        labelStyle: text.labelMedium?.copyWith(color: scheme.onSurface),
      ),
      dividerTheme: DividerThemeData(color: status.border, space: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Spacing.radiusLg),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusLg),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusSm + 4),
        ),
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
