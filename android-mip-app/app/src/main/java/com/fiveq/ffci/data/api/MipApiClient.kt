package com.fiveq.ffci.data.api

import android.util.Base64
import android.util.Log
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
    private const val BASE_URL = "https://ffci.fiveq.dev"
    private const val API_KEY = "777359235aecc10fdfb144041dfdacfc80ca0751c7bed7b14c96f935456fc4ce"
    private const val USERNAME = "fiveq"
    private const val PASSWORD = "demo"

    private val moshi: Moshi = Moshi.Builder()
        .addLast(KotlinJsonAdapterFactory())
        .build()

    private val client: OkHttpClient = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .addInterceptor(HttpLoggingInterceptor().apply {
            level = HttpLoggingInterceptor.Level.BODY
        })
        .addInterceptor { chain ->
            val credentials = "$USERNAME:$PASSWORD"
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
}
