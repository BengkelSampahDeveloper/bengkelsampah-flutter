# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# JANGAN obfuscate MainActivity dan FlutterActivity
-keep class io.flutter.app.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class com.bengkelsampah.app.MainActivity { *; }
-keep class com.bengkelsampah.app.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Suppress warnings for Google Play Core (generated automatically)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# Flutter & Dart
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep R classes
-keep class **.R$* {
    public static <fields>;
}

# HTTP (okhttp, retrofit, http)
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-keep class okio.** { *; }
-keep interface okio.** { *; }
-keep class retrofit2.** { *; }
-keep interface retrofit2.** { *; }

# provider (state management)
-keep class androidx.lifecycle.** { *; }
-keep class androidx.savedstate.** { *; }
-keep class androidx.arch.core.** { *; }

# flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keep class com.ryanheise.audioservice.** { *; }

# flutter_svg
-keep class com.bumptech.glide.** { *; }
-keep class com.caverock.androidsvg.** { *; }
-keep class com.caverock.** { *; }

# intl
-keep class org.threeten.bp.** { *; }

# pin_code_fields (no native code, but keep for safety)
-keep class **.pin_code_fields.** { *; }

# Prevent obfuscation of model classes (if you use reflection)
-keep class com.bengkelsampah.app.model.** { *; }

# General: keep all Flutter plugin registrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Keep HTTP client classes
-keep class com.bengkelsampah.app.** { *; } 