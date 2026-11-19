package com.snaptiq.ui.theme

import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color

// Brand palette (Acid Pop)
val AcidLime = Color(0xFFD4FF3A)
val HotPink = Color(0xFFFF2E93)
val VoltViolet = Color(0xFF7C3AED)
val Ink = Color(0xFF0A0A0F)
val LimeSoft = Color(0xFFE9FF94)
val Paper = Color(0xFFFAFCF2)

val SnaptiqLightColors = lightColorScheme(
    primary = Color(0xFFFF2E93),
    onPrimary = Color(0xFF0A0A0F),
    primaryContainer = Color(0xFFFFD1E6),
    onPrimaryContainer = Color(0xFF0A0A0F),
    secondary = Color(0xFF7C3AED),
    onSecondary = Color(0xFFFFFFFF),
    secondaryContainer = Color(0xFFE9DDFF),
    onSecondaryContainer = Color(0xFF0A0A0F),
    tertiary = Color(0xFFD4FF3A),
    onTertiary = Color(0xFF0A0A0F),
    tertiaryContainer = Color(0xFFE9FF94),
    onTertiaryContainer = Color(0xFF0A0A0F),
    background = Color(0xFFFAFCF2),
    onBackground = Color(0xFF0A0A0F),
    surface = Color(0xFFFFFFFF),
    onSurface = Color(0xFF0A0A0F),
    surfaceVariant = Color(0xFFF0F3E4),
    onSurfaceVariant = Color(0xFF4B4B57),
    outline = Color(0xFF0A0A0F),
    outlineVariant = Color(0xFFDDE1CF),
    error = Color(0xFFC4001E),
    onError = Color(0xFFFFFFFF),
    scrim = Color(0xFF0A0A0F),
)

val SnaptiqDarkColors = darkColorScheme(
    primary = Color(0xFFFF4FA3),
    onPrimary = Color(0xFF0A0A0F),
    primaryContainer = Color(0xFF5C0F35),
    onPrimaryContainer = Color(0xFFFFD1E6),
    secondary = Color(0xFFA78BFA),
    onSecondary = Color(0xFF0A0A0F),
    secondaryContainer = Color(0xFF3B1F7A),
    onSecondaryContainer = Color(0xFFE9DDFF),
    tertiary = Color(0xFFD4FF3A),
    onTertiary = Color(0xFF0A0A0F),
    tertiaryContainer = Color(0xFF3A4710),
    onTertiaryContainer = Color(0xFFE9FF94),
    background = Color(0xFF0A0A0F),
    onBackground = Color(0xFFF5F5F7),
    surface = Color(0xFF16161D),
    onSurface = Color(0xFFF5F5F7),
    surfaceVariant = Color(0xFF22222B),
    onSurfaceVariant = Color(0xFFA1A1AE),
    outline = Color(0xFFF5F5F7),
    outlineVariant = Color(0xFF33333D),
    error = Color(0xFFFF6B6B),
    onError = Color(0xFF0A0A0F),
    scrim = Color(0xFF000000),
)

/** Colours Material 3 has no slot for. Read with SnaptiqTheme.extra. */
@Immutable
data class SnaptiqExtraColors(
    val success: Color,
    val onSuccess: Color,
    val textLink: Color,
    val shadowHard: Color,
)

val SnaptiqLightExtra = SnaptiqExtraColors(success = Color(0xFF15803D), onSuccess = Color(0xFFFFFFFF), textLink = Color(0xFFD61F7A), shadowHard = Color(0xFF0A0A0F))
val SnaptiqDarkExtra = SnaptiqExtraColors(success = Color(0xFF4ADE80), onSuccess = Color(0xFF0A0A0F), textLink = Color(0xFFFF4FA3), shadowHard = Color(0xFFD4FF3A))

val LocalSnaptiqExtra = staticCompositionLocalOf { SnaptiqLightExtra }
