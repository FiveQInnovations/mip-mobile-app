package com.fiveq.ffci.ui.screens

import android.util.Log
import androidx.compose.foundation.clickable
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.fiveq.ffci.data.api.MipApiClient
import com.fiveq.ffci.data.api.CategoryDefinition
import com.fiveq.ffci.data.api.CollectionChild
import com.fiveq.ffci.data.api.PageData
import com.fiveq.ffci.data.cache.PageCache
import com.fiveq.ffci.ui.components.AudioPlayer
import com.fiveq.ffci.ui.components.CollectionList
import com.fiveq.ffci.ui.components.ErrorScreen
import com.fiveq.ffci.ui.components.HtmlContent
import com.fiveq.ffci.ui.components.LoadingScreen
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope

private const val TAG = "TabScreen"
private const val CATEGORY_PREVIEW_COUNT = 3

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TabScreen(
    uuid: String,
    modifier: Modifier = Modifier
) {
    // Navigation stack for drilling into collections
    val pageStack = remember { mutableStateListOf(uuid) }
    val currentUuid = pageStack.last()

    // Check cache SYNCHRONOUSLY before any async work (RN pattern: instant return)
    // This happens immediately on composition, not in LaunchedEffect
    val initialCachedData = remember(currentUuid) {
        if (PageCache.hasCache(currentUuid)) {
            PageCache.getAnyCache(currentUuid)
        } else {
            null
        }
    }

    var pageData by remember(currentUuid) { mutableStateOf<PageData?>(initialCachedData) }
    var isLoading by remember(currentUuid) { 
        mutableStateOf(initialCachedData == null) // Only show loading if no cache
    }
    var isRefreshing by remember { mutableStateOf(false) }
    var error by remember(currentUuid) { mutableStateOf<String?>(null) }
    var mediaSections by remember(currentUuid) { mutableStateOf<List<MediaCategorySection>>(emptyList()) }
    var isLoadingMediaSections by remember(currentUuid) { mutableStateOf(false) }
    var expandedCategorySlugs by remember(currentUuid) { mutableStateOf<Set<String>>(emptySet()) }

    val canGoBack = pageStack.size > 1

    // Background refresh when UUID changes (RN pattern: stale-while-revalidate)
    LaunchedEffect(currentUuid) {
        error = null
        
        if (initialCachedData != null) {
            // Cache exists: silent background refresh
            Log.d(TAG, "Cache hit - showing instantly: ${initialCachedData.title}, refreshing in background")
            isRefreshing = true
        } else {
            // No cache: blocking fetch
            Log.d(TAG, "No cache - fetching: $currentUuid")
        }

        // Fetch fresh data from API
        try {
            val freshData = MipApiClient.getPage(currentUuid)
            Log.d(TAG, "Fresh data loaded: ${freshData.title}, type: ${freshData.effectivePageType}")
            
            // Update cache
            PageCache.put(currentUuid, freshData)
            
            // Update UI with fresh data
            pageData = freshData
            error = null
        } catch (e: Exception) {
            Log.e(TAG, "Error loading page: ${e.message}", e)
            
            // If we have cached data, don't show error - just log it
            if (initialCachedData == null) {
                error = e.message ?: "Failed to load page"
            } else {
                Log.d(TAG, "Using cached data due to network error")
            }
        } finally {
            isLoading = false
            isRefreshing = false
        }
    }

    // Build category sections for Media Resources (app-only enhancement using existing API fields).
    LaunchedEffect(pageData?.title, pageData?.children?.size) {
        val currentPage = pageData
        if (currentPage == null || !shouldGroupMediaByCategory(currentPage)) {
            mediaSections = emptyList()
            isLoadingMediaSections = false
            expandedCategorySlugs = emptySet()
            return@LaunchedEffect
        }

        isLoadingMediaSections = true
        mediaSections = try {
            buildMediaCategorySections(currentPage)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to build media category sections: ${e.message}", e)
            emptyList()
        } finally {
            isLoadingMediaSections = false
        }
    }

    fun navigateToPage(pageUuid: String) {
        Log.d(TAG, "Navigating to page: $pageUuid")
        pageStack.add(pageUuid)
    }

    fun goBack() {
        if (pageStack.size > 1) {
            pageStack.removeAt(pageStack.lastIndex)
        }
    }

    Scaffold(
        modifier = modifier.fillMaxSize(),
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = pageData?.title ?: "",
                        maxLines = 1
                    )
                },
                navigationIcon = {
                    if (canGoBack) {
                        IconButton(onClick = { goBack() }) {
                            Icon(
                                imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                                contentDescription = "Back"
                            )
                        }
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    titleContentColor = MaterialTheme.colorScheme.onPrimary,
                    navigationIconContentColor = MaterialTheme.colorScheme.onPrimary
                )
            )
        }
    ) { innerPadding ->
        // Content area
        Log.d(TAG, "Rendering content area: isLoading=$isLoading, error=$error, pageData=${pageData?.title}")

        when {
            isLoading -> {
                LoadingScreen(modifier = Modifier.fillMaxSize().padding(innerPadding))
            }
            error != null -> {
                ErrorScreen(
                    message = error!!,
                    onRetry = {
                        val temp = pageStack.last()
                        pageStack.removeAt(pageStack.lastIndex)
                        pageStack.add(temp)
                    },
                    modifier = Modifier.fillMaxSize().padding(innerPadding)
                )
            }
            pageData != null -> {
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(innerPadding)
                        .verticalScroll(rememberScrollState())
                        .background(MaterialTheme.colorScheme.background)
                ) {
                    // Title now shown in TopAppBar for all pages

                    // Audio player for audio items
                    if (pageData!!.isAudioItem && pageData!!.audioUrl != null) {
                        AudioPlayer(
                            url = pageData!!.audioUrl!!,
                            title = pageData!!.audioTitle,
                            artist = pageData!!.audioArtist,
                            modifier = Modifier.padding(horizontal = 16.dp)
                        )
                    }

                    // HTML content
                    val htmlContent = pageData!!.htmlContent
                    if (!htmlContent.isNullOrBlank()) {
                        HtmlContent(
                            html = htmlContent,
                            onNavigate = { navigateToPage(it) },
                            modifier = Modifier.fillMaxWidth()
                        )
                    }

                    // Collection children
                    if (pageData!!.effectivePageType == "collection" && !pageData!!.children.isNullOrEmpty()) {
                        val shouldGroup = shouldGroupMediaByCategory(pageData!!)
                        when {
                            shouldGroup && mediaSections.isNotEmpty() -> {
                                Text(
                                    text = "Categories",
                                    style = MaterialTheme.typography.titleLarge,
                                    fontWeight = FontWeight.SemiBold,
                                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp)
                                )

                                mediaSections.forEach { section ->
                                    val isExpanded = expandedCategorySlugs.contains(section.category.slug)
                                    val visibleItems = if (isExpanded) {
                                        section.items
                                    } else {
                                        section.items.take(CATEGORY_PREVIEW_COUNT)
                                    }

                                    Text(
                                        text = section.category.name,
                                        style = MaterialTheme.typography.titleMedium,
                                        fontWeight = FontWeight.SemiBold,
                                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
                                    )
                                    CollectionList(
                                        items = visibleItems,
                                        onItemClick = { navigateToPage(it) }
                                    )

                                    if (section.items.size > CATEGORY_PREVIEW_COUNT) {
                                        val remainingCount = section.items.size - CATEGORY_PREVIEW_COUNT
                                        val actionLabel = if (isExpanded) {
                                            "Show less"
                                        } else {
                                            "Show all ($remainingCount more)"
                                        }

                                        Text(
                                            text = actionLabel,
                                            style = MaterialTheme.typography.bodyMedium,
                                            color = MaterialTheme.colorScheme.primary,
                                            fontWeight = FontWeight.SemiBold,
                                            modifier = Modifier
                                                .padding(horizontal = 16.dp, vertical = 8.dp)
                                                .clickable {
                                                    expandedCategorySlugs = if (isExpanded) {
                                                        expandedCategorySlugs - section.category.slug
                                                    } else {
                                                        expandedCategorySlugs + section.category.slug
                                                    }
                                                }
                                        )
                                    }
                                }
                            }

                            else -> {
                                if (shouldGroup && isLoadingMediaSections) {
                                    LinearProgressIndicator(
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .padding(horizontal = 16.dp, vertical = 8.dp)
                                    )
                                }

                                CollectionList(
                                    items = pageData!!.children!!,
                                    onItemClick = { navigateToPage(it) }
                                )
                            }
                        }
                    }

                    Spacer(modifier = Modifier.height(32.dp))
                }
            }
        }
    }
}

@Composable
private fun PageContent(
    pageData: PageData,
    onNavigate: (String) -> Unit,
    showTitle: Boolean,
    modifier: Modifier = Modifier
) {
    val scrollState = rememberScrollState()
    val pageType = pageData.effectivePageType

    Log.d(TAG, "Rendering page type: $pageType, isAudioItem: ${pageData.isAudioItem}, audioUrl: ${pageData.audioUrl}")

    Column(
        modifier = modifier
            .fillMaxWidth()
            .verticalScroll(scrollState)
    ) {
        // Cover image
        if (pageData.cover != null) {
            AsyncImage(
                model = pageData.cover,
                contentDescription = null,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(200.dp),
                contentScale = ContentScale.Crop
            )
        }

        // Title
        if (showTitle) {
            // Primary color bar
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(4.dp)
                    .background(MaterialTheme.colorScheme.primary)
            )
        }

        Text(
            text = pageData.title,
            style = MaterialTheme.typography.headlineSmall,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 16.dp)
        )

        // Audio player for audio items
        if (pageData.isAudioItem && pageData.audioUrl != null) {
            AudioPlayer(
                url = pageData.audioUrl!!,
                title = pageData.audioTitle,
                artist = pageData.audioArtist,
                modifier = Modifier.padding(horizontal = 16.dp)
            )
        }

        // HTML content
        val htmlContent = pageData.htmlContent
        if (htmlContent != null) {
            HtmlContent(
                html = htmlContent,
                onNavigate = onNavigate,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 16.dp)
            )
        }

        // Collection children
        if (pageType == "collection" && !pageData.children.isNullOrEmpty()) {
            CollectionList(
                items = pageData.children!!,
                onItemClick = onNavigate
            )
        }

        Spacer(modifier = Modifier.height(32.dp))
    }
}

private data class MediaCategorySection(
    val category: CategoryDefinition,
    val items: List<CollectionChild>
)

private fun shouldGroupMediaByCategory(pageData: PageData): Boolean {
    return pageData.effectivePageType == "collection" &&
        pageData.type == "audio" &&
        pageData.categoryDefinitions.isNotEmpty() &&
        !pageData.children.isNullOrEmpty()
}

private suspend fun buildMediaCategorySections(collectionPage: PageData): List<MediaCategorySection> = coroutineScope {
    val categories = collectionPage.categoryDefinitions
    val children = collectionPage.children.orEmpty()
    if (categories.isEmpty() || children.isEmpty()) return@coroutineScope emptyList()

    val categoryByChildUuid = children
        .map { child ->
            async {
                val childPage = PageCache.getAnyCache(child.uuid)
                    ?: MipApiClient.getPage(child.uuid).also { fetched ->
                        PageCache.put(child.uuid, fetched)
                    }
                child.uuid to childPage.categorySlug
            }
        }
        .awaitAll()
        .toMap()

    val groupedSections = categories.mapNotNull { category ->
        val items = children.filter { categoryByChildUuid[it.uuid] == category.slug }
        if (items.isEmpty()) null else MediaCategorySection(category = category, items = items)
    }

    val categorizedIds = groupedSections
        .flatMap { section -> section.items.map { it.uuid } }
        .toSet()
    val uncategorizedItems = children.filter { it.uuid !in categorizedIds }

    if (uncategorizedItems.isEmpty()) {
        groupedSections
    } else {
        groupedSections + MediaCategorySection(
            category = CategoryDefinition(name = "Other Messages", slug = "other"),
            items = uncategorizedItems
        )
    }
}
