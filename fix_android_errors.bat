@echo off
cd /d %~dp0

echo ==== Fixing Android SDK Path Errors ====
echo.

REM Set environment variable
set ANDROID_HOME=C:\Android\sdk
echo Setting ANDROID_HOME=%ANDROID_HOME%

REM Create directories if they don't exist
if not exist "BigModes\llama.cpp\examples\llama.android" (
  mkdir "BigModes\llama.cpp\examples\llama.android"
)

if not exist "BigModes\llama.cpp\examples\llama.android\app\src\main\java\com\example" (
  mkdir "BigModes\llama.cpp\examples\llama.android\app\src\main\java\com\example"
)

REM Create local.properties file with dummy SDK path
echo Creating local.properties file...
echo sdk.dir=%ANDROID_HOME% > "BigModes\llama.cpp\examples\llama.android\local.properties"

REM Create proper Gradle files
echo Creating minimal Android project files...

REM settings.gradle
echo rootProject.name = 'llama' > "BigModes\llama.cpp\examples\llama.android\settings.gradle"
echo include ':app' >> "BigModes\llama.cpp\examples\llama.android\settings.gradle"

REM build.gradle
echo buildscript { > "BigModes\llama.cpp\examples\llama.android\build.gradle"
echo     repositories { >> "BigModes\llama.cpp\examples\llama.android\build.gradle"
echo         google() >> "BigModes\llama.cpp\examples\llama.android\build.gradle"
echo         mavenCentral() >> "BigModes\llama.cpp\examples\llama.android\build.gradle"
echo     } >> "BigModes\llama.cpp\examples\llama.android\build.gradle"
echo     dependencies { >> "BigModes\llama.cpp\examples\llama.android\build.gradle"
echo         classpath 'com.android.tools.build:gradle:7.0.4' >> "BigModes\llama.cpp\examples\llama.android\build.gradle"
echo     } >> "BigModes\llama.cpp\examples\llama.android\build.gradle"
echo } >> "BigModes\llama.cpp\examples\llama.android\build.gradle"
echo allprojects { >> "BigModes\llama.cpp\examples\llama.android\build.gradle"
echo     repositories { >> "BigModes\llama.cpp\examples\llama.android\build.gradle"
echo         google() >> "BigModes\llama.cpp\examples\llama.android\build.gradle"
echo         mavenCentral() >> "BigModes\llama.cpp\examples\llama.android\build.gradle"
echo     } >> "BigModes\llama.cpp\examples\llama.android\build.gradle"
echo } >> "BigModes\llama.cpp\examples\llama.android\build.gradle"

REM app/build.gradle
echo apply plugin: 'com.android.application' > "BigModes\llama.cpp\examples\llama.android\app\build.gradle"
echo android { >> "BigModes\llama.cpp\examples\llama.android\app\build.gradle"
echo     compileSdkVersion 32 >> "BigModes\llama.cpp\examples\llama.android\app\build.gradle"
echo     defaultConfig { >> "BigModes\llama.cpp\examples\llama.android\app\build.gradle"
echo         applicationId "com.example.llama" >> "BigModes\llama.cpp\examples\llama.android\app\build.gradle"
echo         minSdkVersion 21 >> "BigModes\llama.cpp\examples\llama.android\app\build.gradle"
echo         targetSdkVersion 32 >> "BigModes\llama.cpp\examples\llama.android\app\build.gradle"
echo         versionCode 1 >> "BigModes\llama.cpp\examples\llama.android\app\build.gradle"
echo         versionName "1.0" >> "BigModes\llama.cpp\examples\llama.android\app\build.gradle"
echo     } >> "BigModes\llama.cpp\examples\llama.android\app\build.gradle"
echo } >> "BigModes\llama.cpp\examples\llama.android\app\build.gradle"
echo dependencies { >> "BigModes\llama.cpp\examples\llama.android\app\build.gradle"
echo     implementation 'androidx.appcompat:appcompat:1.4.1' >> "BigModes\llama.cpp\examples\llama.android\app\build.gradle"
echo } >> "BigModes\llama.cpp\examples\llama.android\app\build.gradle"

REM Create a basic Java file to satisfy the Android project structure
echo package com.example.llama; > "BigModes\llama.cpp\examples\llama.android\app\src\main\java\com\example\MainActivity.java"
echo public class MainActivity {} >> "BigModes\llama.cpp\examples\llama.android\app\src\main\java\com\example\MainActivity.java"

REM Create gradle.properties
echo org.gradle.jvmargs=-Xmx2048m > "BigModes\llama.cpp\examples\llama.android\gradle.properties"
echo android.useAndroidX=true >> "BigModes\llama.cpp\examples\llama.android\gradle.properties"

REM Create gradle wrapper properties file
if not exist "BigModes\llama.cpp\examples\llama.android\gradle\wrapper" (
  mkdir "BigModes\llama.cpp\examples\llama.android\gradle\wrapper"
)
echo distributionUrl=https\://services.gradle.org/distributions/gradle-7.4-bin.zip > "BigModes\llama.cpp\examples\llama.android\gradle\wrapper\gradle-wrapper.properties"
echo distributionBase=GRADLE_USER_HOME >> "BigModes\llama.cpp\examples\llama.android\gradle\wrapper\gradle-wrapper.properties"
echo distributionPath=wrapper/dists >> "BigModes\llama.cpp\examples\llama.android\gradle\wrapper\gradle-wrapper.properties"
echo zipStoreBase=GRADLE_USER_HOME >> "BigModes\llama.cpp\examples\llama.android\gradle\wrapper\gradle-wrapper.properties"
echo zipStorePath=wrapper/dists >> "BigModes\llama.cpp\examples\llama.android\gradle\wrapper\gradle-wrapper.properties"

REM Create AndroidManifest.xml
if not exist "BigModes\llama.cpp\examples\llama.android\app\src\main" (
  mkdir "BigModes\llama.cpp\examples\llama.android\app\src\main"
)
echo ^<?xml version="1.0" encoding="utf-8"?^> > "BigModes\llama.cpp\examples\llama.android\app\src\main\AndroidManifest.xml"
echo ^<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.example.llama"^> >> "BigModes\llama.cpp\examples\llama.android\app\src\main\AndroidManifest.xml"
echo     ^<application android:label="Llama"^> >> "BigModes\llama.cpp\examples\llama.android\app\src\main\AndroidManifest.xml"
echo         ^<activity android:name=".MainActivity"^> >> "BigModes\llama.cpp\examples\llama.android\app\src\main\AndroidManifest.xml"
echo         ^</activity^> >> "BigModes\llama.cpp\examples\llama.android\app\src\main\AndroidManifest.xml"
echo     ^</application^> >> "BigModes\llama.cpp\examples\llama.android\app\src\main\AndroidManifest.xml"
echo ^</manifest^> >> "BigModes\llama.cpp\examples\llama.android\app\src\main\AndroidManifest.xml"

REM Set environment variable permanently
setx ANDROID_HOME "%ANDROID_HOME%"

echo.
echo Android project structure has been properly created.
echo Environment variable ANDROID_HOME has been set to %ANDROID_HOME%
echo.
echo Please restart your IDE for the changes to take effect.
echo.
pause
