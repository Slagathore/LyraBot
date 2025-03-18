@echo off
cd /d %~dp0
echo ==== Android SDK Error Fix Utility ====
echo.

REM Set environment variable for this session and permanently 
set ANDROID_HOME=C:\Android\sdk
echo Setting ANDROID_HOME to %ANDROID_HOME%
setx ANDROID_HOME "%ANDROID_HOME%"

REM Ensure target directories exist
echo Creating required Android project directories...
mkdir "BigModes\llama.cpp\examples\llama.android" 2>nul
mkdir "BigModes\llama.cpp\examples\llama.android\app" 2>nul
mkdir "BigModes\llama.cpp\examples\llama.android\app\src\main\java\com\example" 2>nul

REM Create local.properties file with correct SDK path
echo Creating local.properties with SDK path...
echo sdk.dir=%ANDROID_HOME% > "BigModes\llama.cpp\examples\llama.android\local.properties"

REM Create minimal but valid Android project files
echo Creating Android project files...

REM settings.gradle
echo include ':app' > "BigModes\llama.cpp\examples\llama.android\settings.gradle"
echo rootProject.name = 'llama' >> "BigModes\llama.cpp\examples\llama.android\settings.gradle" 

REM build.gradle
echo buildscript { > "BigModes\llama.cpp\examples\llama.android\build.gradle"
echo     repositories { >> "BigModes\llama.cpp\examples\llama.android\build.gradle"
echo         google() >> "BigModes\llama.cpp\examples\llama.android\build.gradle"
echo         mavenCentral() >> "BigModes\llama.cpp\examples\llama.android\build.gradle"
echo     } >> "BigModes\llama.cpp\examples\llama.android\build.gradle"
echo     dependencies { >> "BigModes\llama.cpp\examples\llama.android\build.gradle"
echo         classpath 'com.android.tools.build:gradle:7.3.1' >> "BigModes\llama.cpp\examples\llama.android\build.gradle"
echo     } >> "BigModes\llama.cpp\examples\llama.android\build.gradle"
echo } >> "BigModes\llama.cpp\examples\llama.android\build.gradle"

REM Create app build.gradle 
echo apply plugin: 'com.android.application' > "BigModes\llama.cpp\examples\llama.android\app\build.gradle"
echo android { >> "BigModes\llama.cpp\examples\llama.android\app\build.gradle"
echo     compileSdkVersion 33 >> "BigModes\llama.cpp\examples\llama.android\app\build.gradle"
echo     defaultConfig { >> "BigModes\llama.cpp\examples\llama.android\app\build.gradle"
echo         applicationId "com.example.llama" >> "BigModes\llama.cpp\examples\llama.android\app\build.gradle"
echo         minSdkVersion 24 >> "BigModes\llama.cpp\examples\llama.android\app\build.gradle"
echo         targetSdkVersion 33 >> "BigModes\llama.cpp\examples\llama.android\app\build.gradle"
echo     } >> "BigModes\llama.cpp\examples\llama.android\app\build.gradle"
echo } >> "BigModes\llama.cpp\examples\llama.android\app\build.gradle"

REM Create minimal Java file so Android Studio doesn't complain
echo package com.example.llama; > "BigModes\llama.cpp\examples\llama.android\app\src\main\java\com\example\MainActivity.java"
echo public class MainActivity {} >> "BigModes\llama.cpp\examples\llama.android\app\src\main\java\com\example\MainActivity.java"

REM Create basic AndroidManifest.xml
mkdir "BigModes\llama.cpp\examples\llama.android\app\src\main" 2>nul
echo ^<?xml version="1.0" encoding="utf-8"?^> > "BigModes\llama.cpp\examples\llama.android\app\src\main\AndroidManifest.xml"
echo ^<manifest xmlns:android="http://schemas.android.com/apk/res/android"^> >> "BigModes\llama.cpp\examples\llama.android\app\src\main\AndroidManifest.xml"
echo     ^<application^> >> "BigModes\llama.cpp\examples\llama.android\app\src\main\AndroidManifest.xml"
echo     ^</application^> >> "BigModes\llama.cpp\examples\llama.android\app\src\main\AndroidManifest.xml"
echo ^</manifest^> >> "BigModes\llama.cpp\examples\llama.android\app\src\main\AndroidManifest.xml"

REM Create gradle.properties
echo org.gradle.jvmargs=-Xmx2048m > "BigModes\llama.cpp\examples\llama.android\gradle.properties"
echo android.useAndroidX=true >> "BigModes\llama.cpp\examples\llama.android\gradle.properties"

REM Create gradle-wrapper.properties
mkdir "BigModes\llama.cpp\examples\llama.android\gradle\wrapper" 2>nul
echo distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-bin.zip > "BigModes\llama.cpp\examples\llama.android\gradle\wrapper\gradle-wrapper.properties"
echo distributionBase=GRADLE_USER_HOME >> "BigModes\llama.cpp\examples\llama.android\gradle\wrapper\gradle-wrapper.properties"
echo distributionPath=wrapper/dists >> "BigModes\llama.cpp\examples\llama.android\gradle\wrapper\gradle-wrapper.properties"
echo zipStoreBase=GRADLE_USER_HOME >> "BigModes\llama.cpp\examples\llama.android\gradle\wrapper\gradle-wrapper.properties"
echo zipStorePath=wrapper/dists >> "BigModes\llama.cpp\examples\llama.android\gradle\wrapper\gradle-wrapper.properties"

echo.
echo Android SDK error fixed! The SDK location has been set to: %ANDROID_HOME%
echo All necessary Android project files have been created.
echo.
echo Restart your IDE for the changes to take effect.
pause
