package com.fiveq.ffci.data.api

import android.net.Uri
import android.util.Base64
import android.util.Log
import com.fiveq.ffci.config.AppConfig
import com.squareup.moshi.Moshi
import com.squareup.moshi.kotlin.reflect.KotlinJsonAdapterFactory
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.coroutines.isActive
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Call
import okhttp3.logging.HttpLoggingInterceptor
import java.io.IOException
import java.net.URLEncoder
import java.util.concurrent.TimeUnit

class ApiException(message: String, val statusCode: Int, val url: String) : Exception(message)

object MipApiClient {
    private const val TAG = "MipApiClient"
    private val resolvedPathCache = mutableMapOf<String, String>()
    
    // Load configuration from AppConfig singleton
    private val config get() = AppConfig.get()
    private val BASE_URL get() = config.apiBaseUrl
    private val API_KEY get() = config.apiKey

    private val moshi: Moshi = Moshi.Builder()
        .add(FlexibleListAdapterFactory())
        .addLast(KotlinJsonAdapterFactory())
        .build()

    private val client: OkHttpClient by lazy {
        OkHttpClient.Builder()
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .addInterceptor(HttpLoggingInterceptor().apply {
                level = HttpLoggingInterceptor.Level.BODY
            })
            .addInterceptor { chain ->
                val credentials = "${config.username}:${config.password}"
                val basicAuth = "Basic " + Base64.encodeToString(
                    credentials.toByteArray(Charsets.UTF_8),
                    Base64.NO_WRAP
                )

                val request = chain.request().newBuilder()
                    .addHeader("Authorization", basicAuth)
                    .addHeader("X-API-Key", API_KEY)
                    .addHeader("Content-Type", "application/json")
                    .build()

                chain.proceed(request)
            }
            .build()
    }

    private suspend fun <T> fetchJson(url: String, adapter: com.squareup.moshi.JsonAdapter<T>): T {
        return withContext(Dispatchers.IO) {
            val startTime = System.currentTimeMillis()
            Log.d(TAG, "Fetching: $url")

            val request = Request.Builder()
                .url(url)
                .get()
                .build()

            try {
                client.newCall(request).execute().use { response ->
                    val duration = System.currentTimeMillis() - startTime
                    Log.d(TAG, "Response: ${response.code} in ${duration}ms")

                    if (!response.isSuccessful) {
                        throw ApiException(
                            "Failed to fetch (${response.code})",
                            response.code,
                            url
                        )
                    }

                    val body = response.body?.string()
                        ?: throw ApiException("Empty response body", response.code, url)

                    adapter.fromJson(body)
                        ?: throw ApiException("Failed to parse response", response.code, url)
                }
            } catch (e: IOException) {
                Log.e(TAG, "Network error: ${e.message}", e)
                throw e
            }
        }
    }

    suspend fun getSiteData(): SiteData {
        val adapter = moshi.adapter(SiteData::class.java)
        return fetchJson("$BASE_URL/mobile-api", adapter)
    }

    suspend fun getPage(uuid: String): PageData {
        val adapter = moshi.adapter(PageData::class.java)
        return fetchJson("$BASE_URL/mobile-api/page/$uuid", adapter)
    }

    suspend fun searchSite(query: String): List<SearchResult> {
        val encodedQuery = URLEncoder.encode(query.trim(), "UTF-8")
        val adapter = moshi.adapter<List<SearchResult>>(
            com.squareup.moshi.Types.newParameterizedType(
                List::class.java,
                SearchResult::class.java
            )
        )
        return fetchJson("$BASE_URL/mobile-api/search?q=$encodedQuery", adapter)
    }

    /**
     * Resolves a public page URL/path to a Kirby page UUID using mobile search.
     * This keeps internal-page links in-app even when HTML links are not pre-converted to /page/{uuid}.
     */
    suspend fun resolvePageUuidByUrl(url: String): String? {
        val normalizedPath = normalizePath(url) ?: return null
        resolvedPathCache[normalizedPath]?.let { return it }

        val candidateQueries = buildResolutionQueries(normalizedPath)
        if (candidateQueries.isEmpty()) return null

        for (query in candidateQueries) {
            val results = runCatching { searchSite(query) }.getOrNull() ?: continue
            val exactMatch = results.firstOrNull { result ->
                normalizePath(result.url) == normalizedPath
            }
            if (exactMatch != null) {
                resolvedPathCache[normalizedPath] = exactMatch.uuid
                return exactMatch.uuid
            }
        }

        return null
    }

    private fun normalizePath(urlOrPath: String): String? {
        val rawPath = try {
            Uri.parse(urlOrPath).path
        } catch (_: Exception) {
            null
        } ?: if (urlOrPath.startsWith("/")) {
            urlOrPath
        } else {
            return null
        }

        val trimmed = rawPath.trim()
        if (trimmed.isBlank() || trimmed == "/") return null
        return trimmed.trimEnd('/').lowercase()
    }

    private fun buildResolutionQueries(normalizedPath: String): List<String> {
        val segments = normalizedPath
            .trim('/')
            .split("/")
            .filter { it.isNotBlank() }
        if (segments.isEmpty()) return emptyList()

        val queries = linkedSetOf<String>()

        val lastSegment = segments.last()
            .replace("-", " ")
            .replace("_", " ")
            .trim()
        if (lastSegment.length >= 3) {
            queries.add(lastSegment)
        }

        val joined = segments
            .joinToString(" ")
            .replace("-", " ")
            .replace("_", " ")
            .trim()
        if (joined.length >= 3) {
            queries.add(joined)
        }

        return queries.toList()
    }
}
