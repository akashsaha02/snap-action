package com.snaptiq.ui.theme

import androidx.compose.foundation.border
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Shapes
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

val SnaptiqShapes = Shapes(
    extraSmall = RoundedCornerShape(6.dp),
    small = RoundedCornerShape(10.dp),
    medium = RoundedCornerShape(16.dp),
    large = RoundedCornerShape(24.dp),
    extraLarge = RoundedCornerShape(32.dp),
)

@Composable
fun SnaptiqTheme(darkTheme: Boolean = isSystemInDarkTheme(), content: @Composable () -> Unit) {
    // Dynamic colour is deliberately off: the brand look depends on these exact colours.
    val colors = if (darkTheme) SnaptiqDarkColors else SnaptiqLightColors
    val extra = if (darkTheme) SnaptiqDarkExtra else SnaptiqLightExtra
    CompositionLocalProvider(LocalSnaptiqExtra provides extra) {
        MaterialTheme(colorScheme = colors, typography = SnaptiqTypography, shapes = SnaptiqShapes, content = content)
    }
}

object SnaptiqTheme {
    val extra: SnaptiqExtraColors
        @Composable @ReadOnlyComposable get() = LocalSnaptiqExtra.current
}

/**
 * The Acid Pop "sticker" look: a solid offset shadow with no blur, plus a bold outline.
 * Usage: Modifier.stickerShadow(16.dp).border(2.dp, MaterialTheme.colorScheme.outline, RoundedCornerShape(16.dp))
 */
@Composable
fun Modifier.stickerShadow(cornerRadius: Dp, offset: Dp = 4.dp): Modifier {
    val color = SnaptiqTheme.extra.shadowHard
    return this.drawBehind {
        val o = offset.toPx()
        drawRoundRect(
            color = color,
            topLeft = Offset(o, o),
            size = size,
            cornerRadius = CornerRadius(cornerRadius.toPx()),
        )
    }
}
