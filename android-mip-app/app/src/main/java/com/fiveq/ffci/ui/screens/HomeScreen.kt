package com.fiveq.ffci.ui.screens

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ChevronLeft
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshotFlow
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.launch
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.res.painterResource
import androidx.compose.foundation.Image
import coil.compose.AsyncImage
import coil.compose.AsyncImagePainter
import coil.compose.SubcomposeAsyncImage
import coil.compose.SubcomposeAsyncImageContent
import com.fiveq.ffci.R
import com.fiveq.ffci.config.AppConfig
import com.fiveq.ffci.data.api.HomepageFeatured
import com.fiveq.ffci.data.api.HomepageQuickTask
import com.fiveq.ffci.data.api.SiteMeta

@Composable
fun HomeScreen(
    siteMeta: SiteMeta,
    onQuickTaskClick: (String) -> Unit,
    onFeaturedClick: (String) -> Unit,
    onSearchClick: () -> Unit = {},
    modifier: Modifier = Modifier
) {
    LazyColumn(
        modifier = modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
        contentPadding = PaddingValues(bottom = 16.dp)
    ) {
        // Header (iOS-style: white background, app icon top-left, search top-right)
        item {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color.White)
                    .padding(horizontal = 16.dp, vertical = 12.dp)
            ) {
                // App icon (Maltese cross) top-left - matches RN assets/adaptive-icon.png
                Image(
                    painter = painterResource(id = R.drawable.header_logo),
                    contentDescription = "Firefighters for Christ Logo",
                    modifier = Modifier
                        .size(32.dp)
                        .align(Alignment.TopStart),
                    contentScale = ContentScale.Fit
                )
                
                // Search icon top-right
                IconButton(
                    onClick = onSearchClick,
                    modifier = Modifier.align(Alignment.TopEnd)
                ) {
                    Icon(
                        imageVector = Icons.Default.Search,
                        contentDescription = "Search",
                        tint = Color(0xFF0F172A)
                    )
                }
            }
        }

        // Logo section (iOS-style: light gray background, centered responsive logo)
        item {
            val configuration = LocalConfiguration.current
            val screenWidthDp = configuration.screenWidthDp.dp
            
            // Responsive logo size: 60% of screen width, max 280dp, min 200dp
            val logoWidth = remember(screenWidthDp) {
                val calculatedWidth = screenWidthDp * 0.6f
                calculatedWidth.coerceIn(200.dp, 280.dp)
            }
            // Maintain 5:3 aspect ratio (like iOS)
            val logoHeight = logoWidth * 0.6f
            
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color(0xFFF8FAFC)) // Light gray background matching iOS
                    .padding(vertical = 20.dp, horizontal = 20.dp),
                contentAlignment = Alignment.Center
            ) {
                if (siteMeta.logo != null) {
                    val logoUrl = if (siteMeta.logo.startsWith("http://") || siteMeta.logo.startsWith("https://")) {
                        siteMeta.logo
                    } else {
                        "${AppConfig.get().apiBaseUrl}${siteMeta.logo}"
                    }
                    
                    // Use SubcomposeAsyncImage for better error handling
                    SubcomposeAsyncImage(
                        model = logoUrl,
                        contentDescription = siteMeta.title,
                        modifier = Modifier
                            .width(logoWidth)
                            .height(logoHeight),
                        contentScale = ContentScale.Fit // Equivalent to resizeMode="contain"
                    ) {
                        when (painter.state) {
                            is AsyncImagePainter.State.Loading -> {
                                // Show nothing while loading (no placeholder to avoid red background)
                            }
                            is AsyncImagePainter.State.Error -> {
                                // Fallback to site title if logo fails to load
                                Text(
                                    text = siteMeta.title,
                                    style = MaterialTheme.typography.headlineMedium,
                                    color = Color(0xFF0F172A),
                                    fontWeight = FontWeight.Bold,
                                    textAlign = TextAlign.Center
                                )
                            }
                            else -> {
                                SubcomposeAsyncImageContent()
                            }
                        }
                    }
                } else {
                    // No logo URL - show site title
                    Text(
                        text = siteMeta.title,
                        style = MaterialTheme.typography.headlineMedium,
                        color = Color(0xFF0F172A),
                        fontWeight = FontWeight.Bold,
                        textAlign = TextAlign.Center
                    )
                }
            }
        }

        // Featured section
        if (!siteMeta.homepageFeatured.isNullOrEmpty()) {
            item {
                Spacer(modifier = Modifier.height(24.dp))
                Text(
                    text = "Featured",
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(horizontal = 16.dp)
                )
                Spacer(modifier = Modifier.height(12.dp))
            }

            items(siteMeta.homepageFeatured!!) { featured ->
                FeaturedCard(
                    featured = featured,
                    onClick = {
                        featured.uuid?.let { onFeaturedClick(it) }
                    },
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 6.dp)
                )
            }
        }

        // Resources section (formerly Quick Actions)
        if (!siteMeta.homepageQuickTasks.isNullOrEmpty()) {
            item {
                Spacer(modifier = Modifier.height(24.dp))
            }
            
            item {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(Color(0xFFF1F5F9))
                        .padding(vertical = 16.dp)
                ) {
                    Text(
                        text = "Resources",
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(horizontal = 16.dp)
                    )
                    Spacer(modifier = Modifier.height(16.dp))
                    
                    Box(modifier = Modifier.fillMaxWidth()) {
                        val scrollState = rememberLazyListState()
                        val coroutineScope = rememberCoroutineScope()
                        var canScrollLeft by remember { mutableStateOf(false) }
                        var canScrollRight by remember { mutableStateOf(false) }
                        
                        // Update scroll indicators based on scroll state
                        LaunchedEffect(scrollState) {
                            snapshotFlow {
                                scrollState.firstVisibleItemIndex to scrollState.firstVisibleItemScrollOffset
                            }
                            .distinctUntilChanged()
                            .collect {
                                val (firstVisibleIndex, firstVisibleOffset) = it
                                val layoutInfo = scrollState.layoutInfo
                                val totalItems = siteMeta.homepageQuickTasks!!.size
                                
                                canScrollLeft = firstVisibleIndex > 0 || firstVisibleOffset > 0
                                
                                val lastVisibleIndex = layoutInfo.visibleItemsInfo.lastOrNull()?.index ?: -1
                                val canScrollMore = lastVisibleIndex < totalItems - 1
                                val isAtEnd = lastVisibleIndex == totalItems - 1 && 
                                    layoutInfo.visibleItemsInfo.lastOrNull()?.offset?.let { 
                                        it + (layoutInfo.visibleItemsInfo.lastOrNull()?.size ?: 0) <= layoutInfo.viewportEndOffset
                                    } ?: false
                                
                                canScrollRight = canScrollMore && !isAtEnd
                            }
                        }
                        
                        LazyRow(
                            state = scrollState,
                            contentPadding = PaddingValues(horizontal = 16.dp),
                            horizontalArrangement = Arrangement.spacedBy(16.dp),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            items(siteMeta.homepageQuickTasks!!) { task ->
                                ResourcesCard(
                                    task = task,
                                    onClick = {
                                        task.uuid?.let { onQuickTaskClick(it) }
                                    }
                                )
                            }
                        }
                        
                        // Left scroll arrow
                        if (canScrollLeft) {
                            IconButton(
                                onClick = {
                                    coroutineScope.launch {
                                        val cardWidth = 280 + 16 // card width + spacing
                                        val currentOffset = scrollState.firstVisibleItemScrollOffset
                                        val targetIndex = scrollState.firstVisibleItemIndex
                                        val targetOffset = (currentOffset - cardWidth).coerceAtLeast(0)
                                        
                                        if (targetOffset == 0 && targetIndex > 0) {
                                            scrollState.animateScrollToItem(targetIndex - 1)
                                        } else {
                                            scrollState.animateScrollToItem(targetIndex, targetOffset)
                                        }
                                    }
                                },
                                modifier = Modifier
                                    .align(Alignment.CenterStart)
                                    .offset(x = 8.dp)
                            ) {
                                Surface(
                                    shape = CircleShape,
                                    color = Color.White.copy(alpha = 0.95f),
                                    modifier = Modifier.size(40.dp),
                                    shadowElevation = 4.dp
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.ChevronLeft,
                                        contentDescription = "Scroll left",
                                        modifier = Modifier.padding(8.dp)
                                    )
                                }
                            }
                        }
                        
                        // Right scroll arrow
                        if (canScrollRight) {
                            IconButton(
                                onClick = {
                                    coroutineScope.launch {
                                        val cardWidth = 280 + 16 // card width + spacing
                                        val currentIndex = scrollState.firstVisibleItemIndex
                                        val currentOffset = scrollState.firstVisibleItemScrollOffset
                                        
                                        scrollState.animateScrollToItem(
                                            (currentIndex + 1).coerceAtMost(siteMeta.homepageQuickTasks!!.size - 1),
                                            currentOffset + cardWidth
                                        )
                                    }
                                },
                                modifier = Modifier
                                    .align(Alignment.CenterEnd)
                                    .offset(x = (-8).dp)
                            ) {
                                Surface(
                                    shape = CircleShape,
                                    color = Color.White.copy(alpha = 0.95f),
                                    modifier = Modifier.size(40.dp),
                                    shadowElevation = 4.dp
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.ChevronRight,
                                        contentDescription = "Scroll right",
                                        modifier = Modifier.padding(8.dp)
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }

        // Welcome message if no dynamic content
        if (siteMeta.homepageQuickTasks.isNullOrEmpty() && siteMeta.homepageFeatured.isNullOrEmpty()) {
            item {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(32.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        text = "Welcome to",
                        style = MaterialTheme.typography.titleMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = siteMeta.title,
                        style = MaterialTheme.typography.headlineMedium,
                        fontWeight = FontWeight.Bold
                    )
                    Spacer(modifier = Modifier.height(16.dp))
                    Text(
                        text = "Explore resources and content using the tabs below.",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        textAlign = TextAlign.Center
                    )
                }
            }
        }
    }
}

@Composable
private fun ResourcesCard(
    task: HomepageQuickTask,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier
            .width(280.dp)
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        border = BorderStroke(1.dp, Color(0xFFE2E8F0))
    ) {
        Column(
            modifier = Modifier.fillMaxWidth()
        ) {
            if (task.imageUrl != null) {
                AsyncImage(
                    model = task.imageUrl,
                    contentDescription = null,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(158.dp)
                        .clip(RoundedCornerShape(topStart = 12.dp, topEnd = 12.dp)),
                    contentScale = ContentScale.Crop
                )
            }
            
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp)
            ) {
                Text(
                    text = task.label ?: "",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )

                if (!task.description.isNullOrEmpty()) {
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = task.description!!,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }
        }
    }
}

@Composable
private fun FeaturedCard(
    featured: HomepageFeatured,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(12.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Box {
            if (featured.imageUrl != null) {
                AsyncImage(
                    model = featured.imageUrl,
                    contentDescription = null,
                    modifier = Modifier
                        .fillMaxWidth()
                        .aspectRatio(16f / 9f),
                    contentScale = ContentScale.Crop
                )
                // Gradient overlay
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .aspectRatio(16f / 9f)
                        .background(
                            Brush.verticalGradient(
                                colors = listOf(
                                    Color.Transparent,
                                    Color.Black.copy(alpha = 0.7f)
                                )
                            )
                        )
                )
                // Content overlay
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .aspectRatio(16f / 9f)
                        .padding(16.dp),
                    verticalArrangement = Arrangement.Bottom
                ) {
                    if (featured.badgeText != null) {
                        Surface(
                            shape = RoundedCornerShape(4.dp),
                            color = MaterialTheme.colorScheme.secondary
                        ) {
                            Text(
                                text = featured.badgeText.uppercase(),
                                style = MaterialTheme.typography.labelSmall,
                                color = Color.White,
                                modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                            )
                        }
                        Spacer(modifier = Modifier.height(8.dp))
                    }
                    Text(
                        text = featured.title ?: "",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                    if (!featured.description.isNullOrEmpty()) {
                        Text(
                            text = featured.description!!,
                            style = MaterialTheme.typography.bodySmall,
                            color = Color.White.copy(alpha = 0.9f),
                            maxLines = 2,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                }
            } else {
                // No image - simple card
                Column(
                    modifier = Modifier.padding(16.dp)
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            text = featured.title ?: "",
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.weight(1f)
                        )
                        if (featured.badgeText != null) {
                            Surface(
                                shape = RoundedCornerShape(4.dp),
                                color = Color(0xFF2563EB) // Blue badge like iOS
                            ) {
                                Text(
                                    text = featured.badgeText.uppercase(),
                                    style = MaterialTheme.typography.labelSmall,
                                    color = Color.White,
                                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                                )
                            }
                        }
                    }
                    if (!featured.description.isNullOrEmpty()) {
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = featured.description!!,
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }
        }
    }
}
