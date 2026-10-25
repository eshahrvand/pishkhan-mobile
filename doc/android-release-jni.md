# Android Release: shared-preferences JNI lookup

The Android adapter locked in this project is `shared_preferences_android 2.5.0`.
It uses Pigeon JNI, including Kotlin suspend methods. App startup awaits
`RouterSession.restorePrototype()` before `runApp`, so a failed preferences read
prevents the first Flutter screen from appearing.

## Diagnosed failure

The failing Release mapping retained `SharedPreferencesApiRegistrar.getAll`, but
renamed `kotlin.coroutines.Continuation` to `pd`. Its residual descriptor became
`(Ljava/lang/String;Ljava/util/List;Lpd;)Ljava/lang/Object;`.
The Dart JNI binding looks up the original descriptor with
`Lkotlin/coroutines/Continuation;`, producing `NoSuchMethodError` despite the
method name itself being retained by the plugin's `@Keep` annotation.

For the UI/UX review release, `android/app/build.gradle.kts` temporarily sets
`isMinifyEnabled = false` and `isShrinkResources = false`. R8 optimization,
shrinking and obfuscation are disabled. No package downgrade, pub-cache patch
or session-data reset is involved.

`android/app/proguard-rules.pro` retains candidate rules for a future minified
release. Besides Continuation, JNI resolves CoroutineSingletons, IntrinsicsKt,
Result, Result.Failure and Unit by their original JVM names. A device run with
only Continuation preserved passed the original getAll lookup but then failed
to resolve CoroutineSingletons. The expanded rules still require full device
verification before re-enabling R8; they are inactive while minification is off.

## Verification

Build the UI/UX APK using `flutter build apk --release` and cold-start/restart
it on a device. To verify a future minified release, re-enable both Gradle flags
and rebuild. In the new
`build/app/outputs/mapping/release/mapping.txt`, Continuation must map to its own
fully qualified name and the registrar's `getAll` descriptor must retain that
parameter type. Installing/updating with `adb install -r` preserves app data.
Cold-start and restart on a device, confirm Flutter content renders, and inspect
that process's logs for JNI lookup or unhandled startup exceptions.

Debug/widget tests alone do not exercise Release R8 processing. Recheck a
minified APK when changing the Android preferences/JNI dependencies or these rules.

Sources: [adapter changelog](https://pub.dev/packages/shared_preferences_android/changelog),
[Android keep-rule and Kotlin suspend signatures](https://developer.android.com/topic/performance/app-optimization/add-keep-rules).
