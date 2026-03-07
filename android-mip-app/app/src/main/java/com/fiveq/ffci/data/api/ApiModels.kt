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
    @Json(name = "external_url") val externalUrl: String? = null,
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
    @Json(name = "homepage_featured") @FlexibleList val homepageFeatured: List<HomepageFeatured>? = null
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

data class CategoryDefinition(
    val name: String,
    val slug: String,
    val description: String? = null,
    val count: Int? = null
)

@JsonClass(generateAdapter = true)
data class PageDataContent(
    @Json(name = "page_content") val pageContent: String? = null,
    val audio: AudioData? = null,
    @Json(name = "audio_url") val audioUrl: String? = null,
    @Json(name = "audio_name") val audioName: String? = null,
    @Json(name = "audio_credit") val audioCredit: String? = null,
    val categories: String? = null,
    val content: PageDataContent? = null
)

@JsonClass(generateAdapter = true)
data class CollectionChild(
    val uuid: String,
    val title: String,
    val cover: String? = null,
    val type: String? = null,
    @Json(name = "category_slug") val categorySlug: String? = null
)

@JsonClass(generateAdapter = true)
data class PageData(
    @Json(name = "page_type") val pageType: String? = null,
    val type: String? = null,
    val title: String,
    val cover: String? = null,
    @Json(name = "page_content") val pageContent: String? = null,
    val children: List<CollectionChild>? = null,
    val categories: List<CategoryDefinition>? = null,
    val data: PageDataContent? = null,
    val content: PageDataContent? = null,
    @Json(name = "has_form") val hasForm: Boolean? = null
) {
    private val primaryContent: PageDataContent?
        get() = data ?: content

    private val nestedContent: PageDataContent?
        get() {
            return primaryContent?.content
        }

    companion object {
        private val CATEGORY_BLOCK_REGEX = Regex(
            "name:\\s*([^\\n]+?)\\s*\\n\\s*slug:\\s*([a-z0-9-]+)",
            setOf(RegexOption.IGNORE_CASE)
        )
    }

    // Helper to get effective page type
    val effectivePageType: String
        get() = pageType ?: type ?: "content"

    // Helper to check if this is an audio item
    val isAudioItem: Boolean
        get() = effectivePageType == "collection-item" && type == "audio"

    // Helper to get audio URL from various locations
    val audioUrl: String?
        get() = primaryContent?.audio?.audioUrl
            ?: primaryContent?.audioUrl
            ?: nestedContent?.audio?.audioUrl
            ?: nestedContent?.audioUrl

    // Helper to get audio title
    val audioTitle: String?
        get() = primaryContent?.audio?.audioName
            ?: primaryContent?.audioName
            ?: nestedContent?.audio?.audioName
            ?: nestedContent?.audioName
            ?: title

    // Helper to get audio artist/credit
    val audioArtist: String?
        get() = primaryContent?.audio?.audioCredit
            ?: primaryContent?.audioCredit
            ?: nestedContent?.audio?.audioCredit
            ?: nestedContent?.audioCredit

    // Helper to get HTML content
    val htmlContent: String?
        get() = when (effectivePageType) {
            "content" -> pageContent
            "collection-item" -> primaryContent?.pageContent ?: nestedContent?.pageContent
            else -> null
        }

    // Individual media items currently store a single category slug in data.categories.
    val categorySlug: String?
        get() = (nestedContent?.categories ?: primaryContent?.categories)
            ?.lineSequence()
            ?.map { it.trim() }
            ?.firstOrNull { line ->
                line.isNotBlank() &&
                    !line.startsWith("-") &&
                    !line.startsWith("name:") &&
                    !line.startsWith("slug:")
            }
            ?.substringBefore(",")
            ?.trim()
            ?.takeIf { it.isNotBlank() }

    // Media collection currently returns categories as a YAML-like serialized block.
    val categoryDefinitions: List<CategoryDefinition>
        get() {
            val structured = categories
                ?.filter { it.slug.isNotBlank() }
                ?.map {
                    it.copy(
                        name = it.name.trim('\'', '"')
                    )
                }
                ?: emptyList()
            if (structured.isNotEmpty()) return structured

            val raw = primaryContent?.categories ?: return emptyList()
            if (!raw.contains("slug:", ignoreCase = true)) return emptyList()

            return CATEGORY_BLOCK_REGEX.findAll(raw)
                .map { match ->
                    val rawName = match.groupValues[1].trim()
                    val name = rawName.trim('\'', '"')
                    val slug = match.groupValues[2].trim()
                    CategoryDefinition(name = name, slug = slug)
                }
                .toList()
        }
}

@JsonClass(generateAdapter = true)
data class SearchResult(
    val uuid: String,
    val title: String,
    val description: String?,
    val url: String
)
