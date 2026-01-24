package com.fiveq.ffci.ui.screens

import android.util.Log
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
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.fiveq.ffci.data.api.MipApiClient
import com.fiveq.ffci.data.api.PageData
import com.fiveq.ffci.ui.components.AudioPlayer
import com.fiveq.ffci.ui.components.CollectionList
import com.fiveq.ffci.ui.components.ErrorScreen
import com.fiveq.ffci.ui.components.HtmlContent
import com.fiveq.ffci.ui.components.LoadingScreen

private const val TAG = "TabScreen"

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TabScreen(
    uuid: String,
    modifier: Modifier = Modifier
) {
    // Navigation stack for drilling into collections
    val pageStack = remember { mutableStateListOf(uuid) }
    val currentUuid = pageStack.last()

    var pageData by remember { mutableStateOf<PageData?>(null) }
    var isLoading by remember { mutableStateOf(true) }
    var error by remember { mutableStateOf<String?>(null) }

    val canGoBack = pageStack.size > 1

    // Load page data when UUID changes
    LaunchedEffect(currentUuid) {
        isLoading = true
        error = null
        Log.d(TAG, "Loading page: $currentUuid")

        try {
            pageData = MipApiClient.getPage(currentUuid)
            Log.d(TAG, "Page loaded: ${pageData?.title}, type: ${pageData?.effectivePageType}")
        } catch (e: Exception) {
            Log.e(TAG, "Error loading page: ${e.message}", e)
            error = e.message ?: "Failed to load page"
        } finally {
            isLoading = false
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

    Column(modifier = modifier.fillMaxSize()) {
        // Top App Bar with back button when navigated deep
        if (canGoBack) {
            TopAppBar(
                title = {
                    Text(
                        text = pageData?.title ?: "",
                        maxLines = 1
                    )
                },
                navigationIcon = {
                    IconButton(onClick = { goBack() }) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = "Back"
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    titleContentColor = MaterialTheme.colorScheme.onPrimary,
                    navigationIconContentColor = MaterialTheme.colorScheme.onPrimary
                )
            )
        }

        // Content area
        when {
            isLoading -> {
                LoadingScreen()
            }
            error != null -> {
                ErrorScreen(
                    message = error!!,
                    onRetry = {
                        // Trigger reload
                        val temp = pageStack.last()
                        pageStack.removeAt(pageStack.lastIndex)
                        pageStack.add(temp)
                    }
                )
            }
            pageData != null -> {
                PageContent(
                    pageData = pageData!!,
                    onNavigate = { navigateToPage(it) },
                    showTitle = !canGoBack
                )
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
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
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
