package com.fiveq.ffci.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

// FFCI Brand Colors
val PrimaryColor = Color(0xFFD9232A)
val SecondaryColor = Color(0xFF024D91)
val TextColor = Color(0xFF0F172A)
val BackgroundColor = Color(0xFFF8FAFC)
val SurfaceColor = Color(0xFFFFFFFF)
val OnPrimaryColor = Color(0xFFFFFFFF)

private val LightColorScheme = lightColorScheme(
    primary = PrimaryColor,
    onPrimary = OnPrimaryColor,
    secondary = SecondaryColor,
    onSecondary = OnPrimaryColor,
    background = BackgroundColor,
    surface = SurfaceColor,
    onBackground = TextColor,
    onSurface = TextColor
)

@Composable
fun MipAppTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = LightColorScheme,
        content = content
    )
}
