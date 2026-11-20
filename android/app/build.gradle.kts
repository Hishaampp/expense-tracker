import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ---------------------------------------------------------------------------
// App identity (chosen 2026-11-15). The applicationId can never change
// after the first Play Store upload.
// Android: these two values. iOS: ios/Flutter/AppIdentity.xcconfig.
// Dart: lib/core/app_identity.dart.
// ---------------------------------------------------------------------------
val appApplicationId = "com.hishaam.ample"
val appDisplayName = "Ample"

// The owner's upload key, if this machine has one (android/key.properties).
val uploadKey: Properties? =
    rootProject.file("key.properties").takeIf { it.exists() }?.let { f ->
        Properties().apply { f.inputStream().use { stream -> load(stream) } }
    }

android {
    // Kotlin source package. Independent of applicationId; does not need to
    // change when the app is renamed.
    namespace = "com.example.expenses"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications needs java.time on older Android.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = appApplicationId
        // Spec §14: minSdk 26 (Android 8.0).
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["appDisplayName"] = appDisplayName
    }

    // Spec §6.2: `play` must never carry SMS permissions; `sideload` adds the
    // SMS receiver + history import (src/sideload/AndroidManifest.xml).
    flavorDimensions += "distribution"
    productFlavors {
        create("play") {
            dimension = "distribution"
        }
        create("sideload") {
            dimension = "distribution"
        }
    }

    // Release signing: the owner's upload key, described in
    // android/key.properties (never committed; see docs/RELEASING.md).
    // Without it, release builds fall back to the debug key so
    // `flutter run --release` keeps working, but a store bundle refuses to
    // build (below).
    signingConfigs {
        if (uploadKey != null) {
            create("upload") {
                storeFile = file(uploadKey.getProperty("storeFile"))
                storePassword = uploadKey.getProperty("storePassword")
                keyAlias = uploadKey.getProperty("keyAlias")
                keyPassword = uploadKey.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig =
                if (uploadKey != null) signingConfigs.getByName("upload")
                else signingConfigs.getByName("debug")
        }
    }
}

// A bundle for Google Play must be signed with the upload key: Play rejects
// debug-signed bundles, and a bundle signed with the wrong key can never
// update the app.
gradle.taskGraph.whenReady {
    val bundlingRelease = allTasks.any { it.name.startsWith("bundle") && it.name.endsWith("Release") }
    if (bundlingRelease && uploadKey == null) {
        throw GradleException(
            "No upload key: create android/key.properties first (docs/RELEASING.md).",
        )
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // NotificationCompat.MessagingStyle and NotificationManagerCompat.
    implementation("androidx.core:core-ktx:1.17.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
