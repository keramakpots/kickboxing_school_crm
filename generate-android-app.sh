#!/bin/bash

APP_NAME=android-app
PACKAGE=com.kickboxing.app

echo "📱 Tworzenie Android QR Scanner (FULL)..."

#################################
# STRUKTURA PROJEKTU
#################################
mkdir -p $APP_NAME/app/src/main/{java/com/kickboxing/app,res/layout,res/values}
cd $APP_NAME || exit 1

#################################
# settings.gradle
#################################
cat <<EOF > settings.gradle
rootProject.name = "KickboxingScanner"
include ':app'
EOF

#################################
# build.gradle (root)
#################################
cat <<EOF > build.gradle
buildscript {
    ext.kotlin_version = '1.9.0'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.2.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:\$kotlin_version"
    }
}
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
EOF

#################################
# app/build.gradle
#################################
cat <<EOF > app/build.gradle
plugins {
    id 'com.android.application'
    id 'kotlin-android'
}

android {
    namespace "$PACKAGE"
    compileSdk 34

    defaultConfig {
        applicationId "$PACKAGE"
        minSdk 26
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }

    buildFeatures {
        viewBinding true
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib:1.9.0"

    // CameraX
    implementation "androidx.camera:camera-camera2:1.3.1"
    implementation "androidx.camera:camera-lifecycle:1.3.1"
    implementation "androidx.camera:camera-view:1.3.1"

    // ML Kit QR
    implementation "com.google.mlkit:barcode-scanning:17.2.0"

    // HTTP
    implementation "com.squareup.okhttp3:okhttp:4.12.0"

    implementation "androidx.appcompat:appcompat:1.6.1"
}
EOF

#################################
# AndroidManifest.xml
#################################
cat <<EOF > app/src/main/AndroidManifest.xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.INTERNET"/>

    <application
        android:label="Kickboxing QR"
        android:theme="@style/Theme.Material3.DayNight.NoActionBar">

        <activity
            android:name=".ScannerActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

    </application>
</manifest>
EOF

#################################
# QrAnalyzer.kt
#################################
cat <<EOF > app/src/main/java/com/kickboxing/app/QrAnalyzer.kt
package com.kickboxing.app

import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.common.InputImage

class QrAnalyzer(
    private val onQrScanned: (String) -> Unit
) : ImageAnalysis.Analyzer {

    private var scanned = false

    override fun analyze(imageProxy: ImageProxy) {
        if (scanned) {
            imageProxy.close()
            return
        }

        val mediaImage = imageProxy.image ?: run {
            imageProxy.close()
            return
        }

        val image = InputImage.fromMediaImage(
            mediaImage,
            imageProxy.imageInfo.rotationDegrees
        )

        BarcodeScanning.getClient()
            .process(image)
            .addOnSuccessListener { barcodes ->
                barcodes.firstOrNull()?.rawValue?.let {
                    scanned = true
                    onQrScanned(it)
                }
            }
            .addOnCompleteListener {
                imageProxy.close()
            }
    }
}
EOF

#################################
# ApiClient.kt
#################################
cat <<EOF > app/src/main/java/com/kickboxing/app/ApiClient.kt
package com.kickboxing.app

import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody

object ApiClient {

    private const val URL = "http://10.0.2.2:8080/api/entries"

    fun sendEntry(participantId: String, passId: String, locationId: String) {
        val json = """
        {
          "participantId":"$participantId",
          "passId":"$passId",
          "locationId":"$locationId"
        }
        """

        val body = json.toRequestBody("application/json".toMediaType())

        val request = Request.Builder()
            .url(URL)
            .post(body)
            .build()

        OkHttpClient().newCall(request).execute()
    }
}
EOF

#################################
# ScannerActivity.kt
#################################
cat <<EOF > app/src/main/java/com/kickboxing/app/ScannerActivity.kt
package com.kickboxing.app

import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import com.kickboxing.app.databinding.ActivityScannerBinding
import java.util.concurrent.Executors

class ScannerActivity : AppCompatActivity() {

    private lateinit var binding: ActivityScannerBinding
    private val executor = Executors.newSingleThreadExecutor()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityScannerBinding.inflate(layoutInflater)
        setContentView(binding.root)
        startCamera()
    }

    private fun startCamera() {
        val providerFuture = ProcessCameraProvider.getInstance(this)

        providerFuture.addListener({
            val provider = providerFuture.get()

            val preview = Preview.Builder().build().also {
                it.setSurfaceProvider(binding.previewView.surfaceProvider)
            }

            val analysis = ImageAnalysis.Builder().build().also {
                it.setAnalyzer(
                    executor,
                    QrAnalyzer { qr -> handleQr(qr) }
                )
            }

            provider.unbindAll()
            provider.bindToLifecycle(
                this,
                CameraSelector.DEFAULT_BACK_CAMERA,
                preview,
                analysis
            )
        }, ContextCompat.getMainExecutor(this))
    }

    private fun handleQr(qr: String) {
        try {
            val parts = qr.split("|")
            val participantId = parts[0]
            val passId = parts[1]

            ApiClient.sendEntry(
                participantId,
                passId,
                "LOCATION_1"
            )

            runOnUiThread {
                Toast.makeText(this, "✅ Wejście zaliczone", Toast.LENGTH_LONG).show()
                finish()
            }
        } catch (e: Exception) {
            runOnUiThread {
                Toast.makeText(this, "❌ Błąd QR", Toast.LENGTH_LONG).show()
                finish()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        executor.shutdown()
    }
}
EOF

#################################
# activity_scanner.xml
#################################
cat <<EOF > app/src/main/res/layout/activity_scanner.xml
<androidx.camera.view.PreviewView
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/previewView"
    android:layout_width="match_parent"
    android:layout_height="match_parent"/>
EOF

#################################
# theme
#################################
cat <<EOF > app/src/main/res/values/themes.xml
<resources>
    <style name="Theme.Material3.DayNight.NoActionBar"
        parent="Theme.Material3.DayNight.NoActionBar"/>
</resources>
EOF

echo "✅ Android QR Scanner (FULL) wygenerowany w ./android-app"
