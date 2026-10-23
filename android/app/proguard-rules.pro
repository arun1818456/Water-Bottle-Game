# Flutter Wrapper / Engine keep rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class io.flutter.plugin.editing.** { *; }
-dontwarn io.flutter.embedding.**

# Generated Flutter Plugin Registrant
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.plugins.**

# Google Mobile Ads (AdMob)
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# Audio & Media plugins
-keep class xyz.luan.audioplayers.** { *; }
-dontwarn xyz.luan.audioplayers.**
