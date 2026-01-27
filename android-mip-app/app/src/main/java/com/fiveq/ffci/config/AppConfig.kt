package com.fiveq.ffci.config

import android.content.Context
import android.util.Log
import com.squareup.moshi.Moshi
import com.squareup.moshi.kotlin.reflect.KotlinJsonAdapterFactory

/**
 * Site-specific configuration loaded from assets/config.json.
 * Enables multi-site deployment by externalizing all FFCI-specific values.
 */
data class SiteConfig(
    val siteId: String,
    val apiBaseUrl: String,
    val apiKey: String,
    val username: String,
    val password: String,
    val appName: String,
    val primaryColor: String,
    val secondaryColor: String,
    val textColor: String,
    val backgroundColor: String
)

/**
 * Global configuration singleton.
 * Must be initialized in Application.onCreate() before any other components access it.
 */
object AppConfig {
    private const val TAG = "AppConfig"
    private lateinit var config: SiteConfig
    
    /**
     * Initialize configuration from assets/config.json.
     * Call this in Application.onCreate().
     */
    fun initialize(context: Context) {
        val json = context.assets.open("config.json")
            .bufferedReader().use { it.readText() }
        val moshi = Moshi.Builder()
            .addLast(KotlinJsonAdapterFactory())
            .build()
        config = moshi.adapter(SiteConfig::class.java).fromJson(json)
            ?: throw IllegalStateException("Failed to parse config.json")
        Log.d(TAG, "Loaded config for site: ${config.siteId}")
    }
    
    /**
     * Get the current site configuration.
     * @throws UninitializedPropertyAccessException if initialize() hasn't been called
     */
    fun get(): SiteConfig = config
}
