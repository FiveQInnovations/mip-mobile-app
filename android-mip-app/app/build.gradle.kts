import java.util.Properties

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
}

val localProperties = Properties().apply {
    val localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        localPropertiesFile.inputStream().use(::load)
    }
}

val googleServicesFile = file("google-services.json")
val requestedReleaseBuild = gradle.startParameter.taskNames.any {
    it.contains("Release", ignoreCase = true)
}

if (googleServicesFile.exists()) {
    apply(plugin = "com.google.gms.google-services")
} else if (requestedReleaseBuild) {
    throw GradleException(
        "Missing app/google-services.json. Add the Firebase Android config for " +
            "com.subsplashconsulting.s_F52C3B before building a release."
    )
}

val hasReleaseSigning = listOf(
    "ffciReleaseStoreFile",
    "ffciReleaseStorePassword",
    "ffciReleaseKeyAlias",
    "ffciReleaseKeyPassword"
).all { !localProperties.getProperty(it).isNullOrBlank() }

android {
    namespace = "com.fiveq.ffci"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.subsplashconsulting.s_F52C3B"
        minSdk = 26
        targetSdk = 35
        versionCode = 2026062702
        versionName = "2.0.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(localProperties.getProperty("ffciReleaseStoreFile"))
                storePassword = localProperties.getProperty("ffciReleaseStorePassword")
                keyAlias = localProperties.getProperty("ffciReleaseKeyAlias")
                keyPassword = localProperties.getProperty("ffciReleaseKeyPassword")
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            }
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
    buildFeatures {
        compose = true
    }
}

dependencies {
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.core.splashscreen)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.androidx.activity.compose)

    // Compose
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.ui)
    implementation(libs.androidx.ui.graphics)
    implementation(libs.androidx.ui.tooling.preview)
    implementation(libs.androidx.material3)
    implementation(libs.androidx.material.icons.extended)
    implementation(libs.androidx.navigation.compose)

    // ExoPlayer (Media3)
    implementation(libs.androidx.media3.exoplayer)
    implementation(libs.androidx.media3.ui)

    // Networking
    implementation(libs.okhttp)
    implementation(libs.okhttp.logging)
    implementation(libs.moshi)
    implementation(libs.moshi.kotlin)

    // Image loading
    implementation(libs.coil.compose)
    implementation(libs.coil.svg)

    // Firebase
    implementation(platform(libs.firebase.bom))
    implementation(libs.firebase.analytics)

    // Debug
    debugImplementation(libs.androidx.ui.tooling)
}
