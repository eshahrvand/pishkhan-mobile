# shared_preferences_android 2.5.0 invokes Kotlin suspend methods through JNI.
# Its @Keep registrars retain method names, but R8 can still rename Continuation
# in their descriptors, breaking getAll/setBool/remove lookup in release builds.
# Keep this JNI-facing interface without disabling optimization for the app.
-keep,allowoptimization interface kotlin.coroutines.Continuation {
    *;
}

# package:jni's Kotlin bridge also resolves these runtime classes and members
# by their original JVM names (jni 1.1.0, lib/src/kotlin.dart). They are not
# covered by the generated shared-preferences registrars' @Keep annotations.
-keep class kotlin.coroutines.intrinsics.CoroutineSingletons { *; }
-keep class kotlin.coroutines.intrinsics.IntrinsicsKt* {
    public static java.lang.Object getCOROUTINE_SUSPENDED();
}
-keep class kotlin.Result { *; }
-keep class kotlin.Result$Failure { *; }
-keep class kotlin.Unit { *; }
