plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ---------------------------------------------------------------------------
// App identity — PLACEHOLDERS until the owner picks a name (spec §15, Phase 8).
// Android: change these two values only. iOS: ios/Flutter/AppIdentity.xcconfig.
// Dart: lib/core/app_identity.dart.
// ---------------------------------------------------------------------------
val appApplicationId = "com.example.expenses"
val appDisplayName = "Expenses"

android {
    // Kotlin source package. Independent of applicationId; does not need to
    // change when the app is renamed.
    namespace = "com.example.expenses"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
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

    buildTypes {
        release {
            // TODO(phase-8): real signing config. Debug keys keep
            // `flutter run --release` working until then.
            signingConfig = signingConfigs.getByName("debug")
        }
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
}
