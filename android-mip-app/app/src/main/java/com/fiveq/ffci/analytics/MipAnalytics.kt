package com.fiveq.ffci.analytics

import android.content.Context
import android.net.Uri
import android.os.Bundle
import com.google.firebase.analytics.FirebaseAnalytics

object MipAnalytics {
    const val HOME_PAGE_UUID = "__home__"

    fun logAppOpen(context: Context) {
        analytics(context)?.logEvent(FirebaseAnalytics.Event.APP_OPEN, null)
    }

    fun setAnalyticsCollectionEnabled(context: Context, enabled: Boolean) {
        analytics(context)?.setAnalyticsCollectionEnabled(enabled)
    }

    fun logScreenView(
        context: Context,
        screenName: String,
        screenClass: String? = null
    ) {
        val params = Bundle().apply {
            putString(FirebaseAnalytics.Param.SCREEN_NAME, truncate(screenName))
            screenClass?.let {
                putString(FirebaseAnalytics.Param.SCREEN_CLASS, truncate(it))
            }
        }
        analytics(context)?.logEvent(FirebaseAnalytics.Event.SCREEN_VIEW, params)
    }

    fun logContentView(
        context: Context,
        pageUuid: String,
        title: String,
        contentType: String
    ) {
        val params = Bundle().apply {
            putString("page_uuid", truncate(pageUuid))
            putString("page_title", truncate(title))
            putString("content_type", truncate(contentType))
        }
        analytics(context)?.logEvent("content_view", params)
    }

    fun logExternalLink(
        context: Context,
        url: String,
        pageUuid: String? = null,
        pageTitle: String? = null,
        linkLabel: String? = null,
        linkSource: String
    ) {
        val params = Bundle().apply {
            putString("link_url", truncate(url))
            putString("link_source", truncate(linkSource))

            val host = runCatching { Uri.parse(url).host.orEmpty() }.getOrDefault("")
            if (host.isNotBlank()) {
                putString("link_domain", truncate(host))
            }
            if (!pageUuid.isNullOrBlank()) {
                putString("page_uuid", truncate(pageUuid))
            }
            if (!pageTitle.isNullOrBlank()) {
                putString("page_title", truncate(pageTitle))
            }
            if (!linkLabel.isNullOrBlank()) {
                putString("link_label", truncate(linkLabel))
            }
        }
        analytics(context)?.logEvent("external_link", params)
    }

    private fun analytics(context: Context): FirebaseAnalytics? {
        if (!isFirebaseConfigured(context)) return null
        return FirebaseAnalytics.getInstance(context.applicationContext)
    }

    private fun isFirebaseConfigured(context: Context): Boolean {
        return context.resources.getIdentifier(
            "google_app_id",
            "string",
            context.packageName
        ) != 0
    }

    private fun truncate(value: String, maxLen: Int = 100): String {
        return if (value.length <= maxLen) value else value.take(maxLen)
    }
}
