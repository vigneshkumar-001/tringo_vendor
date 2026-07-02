import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

fun readSigningValue(key: String, envKey: String): String {
    val fromFile = keystoreProperties.getProperty(key)?.trim().orEmpty()
    if (fromFile.isNotBlank()) return fromFile

    val fromEnv = System.getenv(envKey)?.trim().orEmpty()
    if (fromEnv.isNotBlank()) return fromEnv

    return ""
}

val signingKeyAlias = readSigningValue("keyAlias", "ANDROID_KEY_ALIAS")
val signingKeyPassword = readSigningValue("keyPassword", "ANDROID_KEY_PASSWORD")
val signingStorePassword = readSigningValue("storePassword", "ANDROID_STORE_PASSWORD")
val signingStoreFilePath = readSigningValue("storeFile", "ANDROID_STORE_FILE")

val hasReleaseSigningConfig = listOf(
    signingKeyAlias,
    signingKeyPassword,
    signingStoreFilePath,
    signingStorePassword,
).all { it.isNotBlank() }
android {
    namespace = "com.feni.tringo_vendor_new"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.feni.tringo_vendor_new"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    signingConfigs {
        create("release") {
            if (hasReleaseSigningConfig) {
                keyAlias = signingKeyAlias
                keyPassword = signingKeyPassword
                storeFile = rootProject.file(signingStoreFilePath).let {
                    if (it.exists()) it else file(signingStoreFilePath)
                }
                storePassword = signingStorePassword
            }
        }
    }
    buildTypes {
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
        release {
            if (hasReleaseSigningConfig) {
                signingConfig = signingConfigs.getByName("release")
            }
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    // Material UI
    implementation("com.google.android.material:material:1.11.0")
    implementation("androidx.cardview:cardview:1.0.0")

    // ✅ Gson
    implementation("com.google.code.gson:gson:2.11.0")

    // ✅ Retrofit + Gson converter
    implementation("com.squareup.retrofit2:retrofit:2.11.0")
    implementation("com.squareup.retrofit2:converter-gson:2.11.0")

    // ✅ OkHttp
    implementation("com.squareup.okhttp3:okhttp:4.12.0")

    // ✅ Coil (for ImageView.load)
    implementation("io.coil-kt:coil:2.6.0")
//    implementation(platform("com.google.firebase:firebase-bom:34.9.0"))
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}


flutter {
    source = "../.."
}



//plugins {
//    id("com.android.application")
//    id("kotlin-android")
//    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
//    id("dev.flutter.flutter-gradle-plugin")
//}
//
//android {
//    namespace = "com.feni.tringo_vendor_new"
//    compileSdk = flutter.compileSdkVersion
//    ndkVersion = flutter.ndkVersion
//
//    compileOptions {
//        sourceCompatibility = JavaVersion.VERSION_11
//        targetCompatibility = JavaVersion.VERSION_11
//    }
//
//    kotlinOptions {
//        jvmTarget = JavaVersion.VERSION_11.toString()
//    }
//
//    defaultConfig {
//        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
//        applicationId = "com.feni.tringo_vendor_new"
//        // You can update the following values to match your application needs.
//        // For more information, see: https://flutter.dev/to/review-gradle-config.
//        minSdk = flutter.minSdkVersion
//        targetSdk = flutter.targetSdkVersion
//        versionCode = flutter.versionCode
//        versionName = flutter.versionName
//    }
//
//    buildTypes {
//        release {
//            // TODO: Add your own signing config for the release build.
//            // Signing with the debug keys for now, so `flutter run --release` works.
//            signingConfig = signingConfigs.getByName("debug")
//        }
//    }
//}
//
//flutter {
//    source = "../.."
//}
