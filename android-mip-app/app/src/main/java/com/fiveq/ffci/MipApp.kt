package com.fiveq.ffci

import android.util.Log
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.automirrored.filled.LibraryBooks
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.navigation.compose.rememberNavController
import com.fiveq.ffci.data.api.MenuItem
import com.fiveq.ffci.data.api.MipApiClient
import com.fiveq.ffci.data.api.SiteData
import com.fiveq.ffci.ui.components.ErrorScreen
import com.fiveq.ffci.ui.components.LoadingScreen
import com.fiveq.ffci.ui.navigation.NavGraph
import com.fiveq.ffci.ui.navigation.Screen
import com.fiveq.ffci.ui.theme.MipAppTheme

private const val TAG = "MipApp"

@Composable
fun MipApp() {
    MipAppTheme {
        var siteData by remember { mutableStateOf<SiteData?>(null) }
        var isLoading by remember { mutableStateOf(true) }
        var error by remember { mutableStateOf<String?>(null) }

        // Load site data on launch
        LaunchedEffect(Unit) {
            Log.d(TAG, "Loading site data...")
            try {
                siteData = MipApiClient.getSiteData()
                Log.d(TAG, "Site data loaded: ${siteData?.menu?.size} menu items")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to load site data: ${e.message}", e)
                error = e.message ?: "Failed to load app data"
            } finally {
                isLoading = false
            }
        }

        when {
            isLoading -> {
                LoadingScreen()
            }
            error != null -> {
                ErrorScreen(
                    message = error!!,
                    onRetry = {
                        isLoading = true
                        error = null
                    }
                )
            }
            siteData != null -> {
                MainContent(siteData = siteData!!)
            }
        }
    }
}

@Composable
private fun MainContent(siteData: SiteData) {
    val navController = rememberNavController()
    var selectedTabIndex by rememberSaveable { mutableIntStateOf(0) }

    // Filter menu to non-home tabs and prepend home
    val menuItems = siteData.menu.filter { it.page.uuid != "__home__" }

    // Create tab items with icons
    val tabItems = buildList {
        add(TabItem("Home", Icons.Default.Home, Screen.Home.route))
        menuItems.forEachIndexed { index, item ->
            add(TabItem(
                label = item.label,
                icon = getIconForTab(item.icon, index),
                route = Screen.tabRoute(index)
            ))
        }
    }

    Scaffold(
        bottomBar = {
            NavigationBar(
                containerColor = MaterialTheme.colorScheme.surface,
                contentColor = MaterialTheme.colorScheme.onSurface
            ) {
                tabItems.forEachIndexed { index, item ->
                    NavigationBarItem(
                        selected = selectedTabIndex == index,
                        onClick = {
                            selectedTabIndex = index
                            navController.navigate(item.route) {
                                // Clear entire back stack and go to this tab
                                popUpTo(0) { inclusive = true }
                                launchSingleTop = true
                            }
                        },
                        icon = {
                            Icon(
                                imageVector = item.icon,
                                contentDescription = item.label
                            )
                        },
                        label = {
                            Text(
                                text = item.label,
                                maxLines = 1
                            )
                        },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = MaterialTheme.colorScheme.primary,
                            selectedTextColor = MaterialTheme.colorScheme.primary,
                            unselectedIconColor = MaterialTheme.colorScheme.onSurfaceVariant,
                            unselectedTextColor = MaterialTheme.colorScheme.onSurfaceVariant,
                            indicatorColor = MaterialTheme.colorScheme.primaryContainer
                        )
                    )
                }
            }
        }
    ) { paddingValues ->
        NavGraph(
            navController = navController,
            menuItems = menuItems,
            siteMeta = siteData.siteData,
            modifier = Modifier.padding(paddingValues)
        )
    }
}

private data class TabItem(
    val label: String,
    val icon: ImageVector,
    val route: String
)

private fun getIconForTab(iconName: String?, index: Int): ImageVector {
    // Map icon names from API to Material icons
    return when (iconName?.lowercase()) {
        "book-outline", "book" -> Icons.AutoMirrored.Filled.LibraryBooks
        "library-outline", "library" -> Icons.AutoMirrored.Filled.LibraryBooks
        "information-circle-outline", "info" -> Icons.Default.Info
        "heart-outline", "heart" -> Icons.Default.Favorite
        "menu-outline", "menu" -> Icons.Default.Menu
        else -> {
            // Default icons by position
            when (index) {
                0 -> Icons.AutoMirrored.Filled.LibraryBooks
                1 -> Icons.Default.Info
                2 -> Icons.Default.Favorite
                else -> Icons.Default.Menu
            }
        }
    }
}
