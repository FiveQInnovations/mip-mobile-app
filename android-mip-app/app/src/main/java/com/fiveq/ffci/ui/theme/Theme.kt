package com.fiveq.ffci.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.graphics.Color
import com.fiveq.ffci.config.AppConfig

// Default colors (used before config is loaded, e.g., in previews)
val DefaultPrimaryColor = Color(0xFFD9232A)
val DefaultSecondaryColor = Color(0xFF024D91)
val DefaultTextColor = Color(0xFF0F172A)
val DefaultBackgroundColor = Color(0xFFF8FAFC)
val SurfaceColor = Color(0xFFFFFFFF)
val OnPrimaryColor = Color(0xFFFFFFFF)

/**
 * Parse a hex color string to Compose Color.
 * Supports formats: #RRGGBB or #AARRGGBB
 */
private fun parseColor(hexColor: String): Color {
    return Color(android.graphics.Color.parseColor(hexColor))
}

@Composable
fun MipAppTheme(content: @Composable () -> Unit) {
    // Load colors from config at runtime
    val config = remember { AppConfig.get() }
    
    val primaryColor = remember(config) { parseColor(config.primaryColor) }
    val secondaryColor = remember(config) { parseColor(config.secondaryColor) }
    val textColor = remember(config) { parseColor(config.textColor) }
    val backgroundColor = remember(config) { parseColor(config.backgroundColor) }
    
    val colorScheme = remember(primaryColor, secondaryColor, textColor, backgroundColor) {
        lightColorScheme(
            primary = primaryColor,
            onPrimary = OnPrimaryColor,
            secondary = secondaryColor,
            onSecondary = OnPrimaryColor,
            background = backgroundColor,
            surface = SurfaceColor,
            onBackground = textColor,
            onSurface = textColor
        )
    }
    
    MaterialTheme(
        colorScheme = colorScheme,
        content = content
    )
}
