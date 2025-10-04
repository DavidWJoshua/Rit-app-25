plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Firebase plugin
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter plugin must come last
}

android {
    namespace = "com.example.civil_project"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Firebase requires Java 11+
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.civil_project"
        // Firebase Auth requires at least SDK 23
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // For now, use debug keys — replace with release keys before publishing
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BoM (keeps all Firebase libs in sync)
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))

    // Firebase Auth
    implementation("com.google.firebase:firebase-auth")

    // (Optional) Firebase Analytics
    implementation("com.google.firebase:firebase-analytics")
}
