package com.fiveq.ffci.ui.navigation

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import com.fiveq.ffci.data.api.MenuItem
import com.fiveq.ffci.data.api.SiteMeta
import com.fiveq.ffci.ui.screens.HomeScreen
import com.fiveq.ffci.ui.screens.TabScreen

sealed class Screen(val route: String) {
    data object Home : Screen("home")
    data class Tab(val index: Int) : Screen("tab/$index")

    companion object {
        fun tabRoute(index: Int) = "tab/$index"
    }
}

@Composable
fun NavGraph(
    navController: NavHostController,
    menuItems: List<MenuItem>,
    siteMeta: SiteMeta,
    modifier: Modifier = Modifier
) {
    NavHost(
        navController = navController,
        startDestination = Screen.Home.route,
        modifier = modifier
    ) {
        // Home screen
        composable(Screen.Home.route) {
            HomeScreen(
                siteMeta = siteMeta,
                onQuickTaskClick = { uuid ->
                    // Could navigate to a specific page - for now just log
                },
                onFeaturedClick = { uuid ->
                    // Could navigate to a specific page - for now just log
                }
            )
        }

        // Tab screens for each menu item
        menuItems.forEachIndexed { index, menuItem ->
            composable(Screen.tabRoute(index)) {
                TabScreen(uuid = menuItem.page.uuid)
            }
        }
    }
}
