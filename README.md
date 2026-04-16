# puzzle

Sliding number puzzle game built with Flutter.

## Android Deployment (Play Store)

1. Copy `android/key.properties.example` to `android/key.properties`.
2. Fill in your real keystore values in `android/key.properties`.
3. Ensure `applicationId` in `android/app/build.gradle.kts` matches your Play Console package.
4. Increase app version in `pubspec.yaml` (for example from `1.0.0+1` to `1.0.1+2`).
5. Build app bundle:

```bash
flutter build appbundle --release
```

Generated file:

- `build/app/outputs/bundle/release/app-release.aab`

Notes:

- Release minification and resource shrinking are enabled.
- `android/key.properties`, `.jks`, and `.keystore` files are ignored from git.
# puzzle
