package com.fiveq.ffci.data.api

import com.squareup.moshi.Json
import com.squareup.moshi.JsonClass

@JsonClass(generateAdapter = true)
data class MenuPage(
    val uuid: String,
    val type: String,
    val url: String
)

@JsonClass(generateAdapter = true)
data class MenuItem(
    val label: String,
    val icon: String? = null,
    val page: MenuPage
)

@JsonClass(generateAdapter = true)
data class HomepageQuickTask(
    val uuid: String?,
    val label: String?,
    val description: String?,
    @Json(name = "image_url") val imageUrl: String?,
    @Json(name = "external_url") val externalUrl: String?
)

@JsonClass(generateAdapter = true)
data class HomepageFeatured(
    val uuid: String?,
    val title: String?,
    val description: String?,
    @Json(name = "image_url") val imageUrl: String?,
    @Json(name = "badge_text") val badgeText: String?,
    @Json(name = "external_url") val externalUrl: String?
)

@JsonClass(generateAdapter = true)
data class SiteMeta(
    val title: String,
    val social: List<SocialLink>? = null,
    val logo: String?,
    @Json(name = "homepage_quick_tasks") val homepageQuickTasks: List<HomepageQuickTask>? = null,
    @Json(name = "homepage_featured") val homepageFeatured: List<HomepageFeatured>? = null
)

@JsonClass(generateAdapter = true)
data class SocialLink(
    val platform: String,
    val url: String
)

@JsonClass(generateAdapter = true)
data class SiteData(
    val menu: List<MenuItem>,
    @Json(name = "site_data") val siteData: SiteMeta
)

@JsonClass(generateAdapter = true)
data class AudioData(
    @Json(name = "audio_url") val audioUrl: String?,
    @Json(name = "audio_name") val audioName: String?,
    @Json(name = "audio_credit") val audioCredit: String?
)

@JsonClass(generateAdapter = true)
data class PageDataContent(
    @Json(name = "page_content") val pageContent: String? = null,
    val audio: AudioData? = null,
    @Json(name = "audio_url") val audioUrl: String? = null,
    @Json(name = "audio_name") val audioName: String? = null,
    @Json(name = "audio_credit") val audioCredit: String? = null
)

@JsonClass(generateAdapter = true)
data class CollectionChild(
    val uuid: String,
    val title: String,
    val cover: String? = null,
    val type: String? = null
)

@JsonClass(generateAdapter = true)
data class PageData(
    @Json(name = "page_type") val pageType: String? = null,
    val type: String? = null,
    val title: String,
    val cover: String? = null,
    @Json(name = "page_content") val pageContent: String? = null,
    val children: List<CollectionChild>? = null,
    val data: PageDataContent? = null,
    @Json(name = "has_form") val hasForm: Boolean? = null
) {
    // Helper to get effective page type
    val effectivePageType: String
        get() = pageType ?: type ?: "content"

    // Helper to check if this is an audio item
    val isAudioItem: Boolean
        get() = effectivePageType == "collection-item" && type == "audio"

    // Helper to get audio URL from various locations
    val audioUrl: String?
        get() = data?.audio?.audioUrl ?: data?.audioUrl

    // Helper to get audio title
    val audioTitle: String?
        get() = data?.audio?.audioName ?: data?.audioName ?: title

    // Helper to get audio artist/credit
    val audioArtist: String?
        get() = data?.audio?.audioCredit ?: data?.audioCredit

    // Helper to get HTML content
    val htmlContent: String?
        get() = when (effectivePageType) {
            "content" -> pageContent
            "collection-item" -> data?.pageContent
            else -> null
        }
}

@JsonClass(generateAdapter = true)
data class SearchResult(
    val uuid: String,
    val title: String,
    val description: String?,
    val url: String
)
