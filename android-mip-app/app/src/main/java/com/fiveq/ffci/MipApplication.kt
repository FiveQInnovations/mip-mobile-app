package com.fiveq.ffci

import android.app.Application
import android.util.Base64
import coil.ImageLoader
import coil.ImageLoaderFactory
import coil.decode.SvgDecoder
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import java.util.concurrent.TimeUnit

class MipApplication : Application(), ImageLoaderFactory {
    override fun onCreate() {
        super.onCreate()
    }

    override fun newImageLoader(): ImageLoader {
        val client = OkHttpClient.Builder()
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .addInterceptor(HttpLoggingInterceptor().apply {
                level = HttpLoggingInterceptor.Level.BODY
            })
            .addInterceptor { chain ->
                val credentials = "fiveq:demo"
                val basicAuth = "Basic " + Base64.encodeToString(
                    credentials.toByteArray(Charsets.UTF_8),
                    Base64.NO_WRAP
                )

                val request = chain.request().newBuilder()
                    .addHeader("Authorization", basicAuth)
                    .build()

                chain.proceed(request)
            }
            .build()

        return ImageLoader.Builder(this)
            .okHttpClient(client)
            .components {
                add(SvgDecoder.Factory())
            }
            .build()
    }
}
