package com.fiveq.ffci.ui.navigation

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.navArgument
import com.fiveq.ffci.data.api.MenuItem
import com.fiveq.ffci.data.api.SiteMeta
import com.fiveq.ffci.ui.screens.HomeScreen
import com.fiveq.ffci.ui.screens.SearchScreen
import com.fiveq.ffci.ui.screens.TabScreen

sealed class Screen(val route: String) {
    data object Home : Screen("home")
    data class Tab(val index: Int) : Screen("tab/$index")
    data object Page : Screen("page/{uuid}") {
        fun createRoute(uuid: String) = "page/$uuid"
    }
    data object Search : Screen("search")

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
                    navController.navigate(Screen.Page.createRoute(uuid))
                },
                onFeaturedClick = { uuid ->
                    navController.navigate(Screen.Page.createRoute(uuid))
                },
                onSearchClick = {
                    navController.navigate(Screen.Search.route)
                }
            )
        }

        // Tab screens for each menu item
        menuItems.forEachIndexed { index, menuItem ->
            composable(Screen.tabRoute(index)) {
                TabScreen(uuid = menuItem.page.uuid)
            }
        }

        // Page screen for direct navigation (Quick Actions, Featured)
        composable(
            route = Screen.Page.route,
            arguments = listOf(navArgument("uuid") { type = NavType.StringType })
        ) { backStackEntry ->
            val uuid = backStackEntry.arguments?.getString("uuid") ?: return@composable
            TabScreen(uuid = uuid)
        }

        // Search screen
        composable(Screen.Search.route) {
            SearchScreen(
                onResultClick = { uuid ->
                    navController.navigate(Screen.Page.createRoute(uuid))
                },
                onBackClick = {
                    navController.popBackStack()
                }
            )
        }
    }
}
