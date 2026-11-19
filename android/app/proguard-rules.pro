# google_mlkit_text_recognition references the optional Chinese, Devanagari,
# Japanese and Korean recognizers. SnapAction ships only the bundled Latin
# model, so those classes are intentionally absent from the APK.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# ML Kit creates its components and internal loggers by reflection. With R8
# full mode (the AGP default) those classes were stripped or renamed, and
# every recognition call failed in release builds with a NullPointerException
# in InputImage.fromFilePath. Debug builds were unaffected.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_** { *; }
-keep class com.google_mlkit_commons.** { *; }
-keep class com.google_mlkit_text_recognition.** { *; }
-keep class * implements com.google.firebase.components.ComponentRegistrar { *; }
