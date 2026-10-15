# The Flutter ML Kit plugin contains optional branches for these recognizers.
# Receipt Trail ships only the Chinese model, so the absent optional classes
# are expected and must not block R8 release builds.
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
