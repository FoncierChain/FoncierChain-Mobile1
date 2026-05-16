plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.africhain.fancierchain"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    defaultConfig {
        applicationId = "com.africhain.fancierchain"
        // Utilise la version minimale de Flutter ou forcez à 21 si nécessaire
        minSdk = flutter.minSdkVersion 
        
        // CORRECTION : Aligné sur le SDK 36 exigé par vos dépendances
        targetSdk = 36 
        
        versionCode = 1
        versionName = "1.0.0"

        ndk {
            abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a", "x86_64"))
        }
    }

    // CORRECTION : Force le compilateur Java natif à cibler Java 21
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    // CORRECTION : Force le compilateur Kotlin interne à cibler Java 21
    kotlinOptions {
        jvmTarget = "21"
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        getByName("debug") {
            isMinifyEnabled = false
        }
    }
}

dependencies {
    // Vos dépendances natives si requises
}

// =============================================================================
// CORRECTION CRITIQUE : Aligne l'ensemble de la Toolchain Gradle sur Java 21
// Cela résout définitivement le conflit (1.8 vs 21) en téléchargeant le bon JDK.
// =============================================================================
kotlin {
    jvmToolchain {
        languageVersion.set(JavaLanguageVersion.of(21))
    }
}