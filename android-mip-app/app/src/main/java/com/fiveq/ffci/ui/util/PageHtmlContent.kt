package com.fiveq.ffci.ui.util

import android.os.Build
import android.text.Html
import com.fiveq.ffci.data.api.PageData

/**
 * Returns [PageData.htmlContent] for rendering, or null when it is blank or only Kirby’s default
 * description placeholder (same idea as hiding “Write your description here...” in the Panel).
 */
fun PageData.htmlContentForDisplay(): String? {
    val raw = htmlContent?.trim() ?: return null
    if (raw.isBlank()) return null
    val plain = raw.toPlainTextFromHtml()
    if (plain.isBlank()) return null
    val normalized = plain.replace(Regex("\\s+"), " ").trim().lowercase()
    if (normalized.isKirbyDescriptionPlaceholder()) return null
    return htmlContent
}

private fun String.isKirbyDescriptionPlaceholder(): Boolean =
    this == "write your description here..." ||
        this == "write your description here…"

private fun String.toPlainTextFromHtml(): String {
    val spanned = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        Html.fromHtml(this, Html.FROM_HTML_MODE_LEGACY)
    } else {
        @Suppress("DEPRECATION")
        Html.fromHtml(this)
    }
    return spanned.toString()
        .replace('\u00a0', ' ')
        .trim()
}
