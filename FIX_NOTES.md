# Android v2 embedding repair

The Android launcher has been migrated to Flutter Android embedding v2. `MainActivity` now uses `io.flutter.embedding.android.FlutterActivity`, the main manifest declares `flutterEmbedding` version `2`, and the Flutter plugin loader is configured in `android/settings.gradle`.

The Android build tooling is aligned with the current Flutter project format: Android Gradle Plugin 9.1.0, Gradle 9.1.0, and Kotlin 2.4.0. This baseline supports Java 25 on Windows. Generated build folders and machine-specific `android/local.properties` are intentionally excluded from the source archive.

Run these commands from the project root:

```bash
flutter pub get
flutter clean
flutter build apk --release
flutter build appbundle --release
```
