# PortalixMx Resident Admin

Flutter admin app for PortalixMx community management (residents, payments, maintenance, access, fund reports).

## Toolchain versions (required to compile)

Use these versions (or compatible newer patch releases) so the project builds without forced upgrades:

| Tool | Version |
|------|---------|
| Flutter | **3.44.8** (stable) |
| Dart | **3.12.2** (bundled with Flutter above) |
| Android Gradle Plugin | **8.9.1** (`android/settings.gradle.kts`) |
| Gradle | **8.11.1** (`android/gradle/wrapper/gradle-wrapper.properties`) |
| Kotlin | **2.2.0** (`org.jetbrains.kotlin.android` in `android/settings.gradle.kts`) |
| Java / JVM target | **11** (`android/app/build.gradle.kts`) |

```bash
flutter --version
flutter pub get
flutter run
```

## Getting started

1. Clone the repo and open it in Android Studio / VS Code / Cursor.
2. Ensure Flutter 3.44.8+ is on your `PATH`.
3. Run `flutter pub get`.
4. Configure Firebase (`google-services.json` / `GoogleService-Info.plist`) for your environment.
5. For debug builds, complete App Check setup below before signing in.

## Firebase App Check (QA process)

App Check runs at startup in `lib/main.dart`. Debug builds use debug providers; release builds use Play Integrity / DeviceCheck.

### Register a debug token (Android / iOS)

1. Run the app once in **debug**.
2. In Logcat (Android) or Xcode console (iOS), find the line that prints the **Firebase App Check debug token**.
3. Open [Firebase Console](https://console.firebase.google.com) → **App Check** → your Android/iOS app → **Manage debug tokens**.
4. Add the token from the device/emulator log.
5. Keep `AppConstants.debugTokenIOS` / `AppConstants.debugTokenAndroid` registered in Firebase Console so debug builds keep working across reinstalls.
6. Restart the app. Startup should acquire a token without freezing; if App Check fails, the app continues and shows a recoverable splash error instead of hanging.

### Firestore and App Check enforcement

- Confirm in Firebase Console → **App Check** whether **Cloud Firestore** (and Storage, if used) have enforcement **enabled**.
- If enforcement is on, every client (and tools like Postman) must present a valid App Check token; a normal Auth ID token alone can return **403**.
- For QA API testing without the app: either disable enforcement in non-prod, or obtain an App Check token the same way the mobile app does.
- Ask the project owner to document the current enforcement setting for Firestore in the team wiki when environments change.

## Tablet layout

On screens ≥ **600dp** wide, primary content is horizontally constrained (max ~720dp) and centered so phone layouts do not stretch edge-to-edge on tablets.
