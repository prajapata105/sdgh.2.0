# Flutter and basic setup
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# Gson or other JSON libraries
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**
# Razorpay required rules
-keep class com.razorpay.** {*;}
-dontwarn com.razorpay.**
-keep class proguard.annotation.Keep
-keep class proguard.annotation.KeepClassMembers
