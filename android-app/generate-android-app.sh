#!/bin/bash

APP_NAME=android-app
PACKAGE=com.kickboxing.app

echo "📱 Tworzenie projektu Android..."

mkdir -p $APP_NAME
cd $APP_NAME || exit 1

cat <<EOF > settings.gradle
rootProject.name = "KickboxingApp"
include ':app'
EOF

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

mkdir -p app/src/main/java/com/kickboxing/app
mkdir -p app/src/main/res/layout
mkdir -p app/src/main/res/values

#################### app/build.gradle ####################
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
}
EOF

#################### AndroidManifest ####################
cat <<EOF > app/src/main/AndroidManifest.xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.INTERNET"/>

    <application
        android:label="Kickboxing Scanner"
        android:theme="@style/Theme.Material3.DayNight.NoActionBar">

        <activity android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

    </application>
</manifest>
EOF

#################### MainActivity ####################
cat <<EOF > app/src/main/java/com/kickboxing/app/MainActivity.kt
package com.kickboxing.app

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.kickboxing.app.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.scanButton.setOnClickListener {
            startActivity(ScannerActivity.newIntent(this))
        }
    }
}
EOF

#################### ScannerActivity ####################
cat <<EOF > app/src/main/java/com/kickboxing/app/ScannerActivity.kt
package com.kickboxing.app

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.common.InputImage

class ScannerActivity : AppCompatActivity() {

    companion object {
        fun newIntent(ctx: Context) = Intent(ctx, ScannerActivity::class.java)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_scanner)

        // MVP: tutaj podłączysz CameraX + ML Kit
        // Po zeskanowaniu QR:
        // sendEntry(participantId, passId)
    }
}
EOF

#################### API CLIENT ####################
cat <<EOF > app/src/main/java/com/kickboxing/app/ApiClient.kt
package com.kickboxing.app

import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody

object ApiClient {

    private const val BASE_URL = "http://10.0.2.2:8080/api/entries"

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
            .url(BASE_URL)
            .post(body)
            .build()

        OkHttpClient().newCall(request).execute()
    }
}
EOF

#################### LAYOUTS ####################
cat <<EOF > app/src/main/res/layout/activity_main.xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical"
    android:gravity="center"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <Button
        android:id="@+id/scanButton"
        android:text="Skanuj QR"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"/>
</LinearLayout>
EOF

cat <<EOF > app/src/main/res/layout/activity_scanner.xml
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <!-- Podgląd kamery CameraX -->
</FrameLayout>
EOF

#################### styles ####################
cat <<EOF > app/src/main/res/values/themes.xml
<resources>
    <style name="Theme.Material3.DayNight.NoActionBar" parent="Theme.Material3.DayNight.NoActionBar"/>
</resources>
EOF

echo "✅ Android MVP wygenerowany w ./android-app"
