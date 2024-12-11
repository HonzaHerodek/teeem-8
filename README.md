# MyApp

A Flutter application with Firebase integration for social interactions and user engagement.

## Prerequisites

Required installations with minimum versions:
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Git (2.0 or higher)
- Android Studio (2022.1 or higher) or VS Code (1.70 or higher)
  - For VS Code: Flutter and Dart extensions
  - For Android Studio: Flutter and Dart plugins
- Firebase CLI (latest version)
- Android SDK (API level 21 or higher)

## Detailed Setup Instructions

1. Environment Setup:
```bash
# Check Flutter installation and dependencies
flutter doctor -v

# Enable desktop development (optional)
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop
```

2. Clone and Setup Repository:
```bash
# Clone repository
git clone <repository-url>
cd myapp

# Get dependencies
flutter pub get

# Run build runner for generated files
flutter pub run build_runner build --delete-conflicting-outputs
```

3. Firebase Setup:
a) Console Configuration:
- Go to console.firebase.google.com
- Create new project named "MyApp"
- Enable Authentication with Email/Password sign-in
- Create Cloud Firestore database in test mode
- Add Android app:
  * Package name: com.example.myapp (or check android/app/build.gradle)
  * App nickname: MyApp
  * Download google-services.json

b) Local Configuration:
- Place google-services.json in android/app/
- Update android/build.gradle with:
  ```gradle
  buildscript {
    dependencies {
      classpath "com.google.gms:google-services:4.3.15"
    }
  }
  ```
- Verify android/app/build.gradle has:
  ```gradle
  apply plugin: "com.google.gms.google-services"
  ```

4. Development Options:

a) Using Firebase:
```bash
# Ensure device/emulator is connected
flutter devices

# Run in debug mode
flutter run

# Run in release mode
flutter run --release
```

b) Using Mock Data:
The app includes mock implementations for development without Firebase:

1. Configure mock repositories in lib/core/di/injection.dart:
```dart
// Replace Firebase implementations with mock ones
sl.registerLazySingleton<AuthRepository>(() => MockAuthRepository());
sl.registerLazySingleton<PostRepository>(() => MockPostRepository());
sl.registerLazySingleton<RatingService>(() => MockRatingService());
sl.registerLazySingleton<UserRepository>(() => MockUserRepository());
```

2. Available mock data files:
- lib/data/repositories/mock_auth_repository.dart
- lib/data/repositories/mock_post_repository.dart
- lib/data/repositories/mock_rating_service.dart
- lib/data/repositories/mock_user_repository.dart

3. Test data service:
- lib/core/services/test_data_service.dart provides sample data

## Common Issues & Solutions

Firebase Issues:
1. SHA-1 mismatch:
```bash
# Generate SHA-1
cd android
./gradlew signingReport
# Add the debug SHA-1 to Firebase console
```

2. Google Services JSON:
- Verify path: android/app/google-services.json
- Check package name matches in:
  * google-services.json
  * android/app/build.gradle
  * Firebase console

Flutter Issues:
1. Dependency conflicts:
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

2. Build errors:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## Project Structure

```
lib/
├── core/           # Core functionality
│   ├── di/         # Dependency injection
│   ├── navigation/ # Navigation service
│   └── services/   # Core services
├── data/           # Data layer
│   ├── models/     # Data models
│   └── repositories/ # Data repositories
├── domain/         # Business logic
└── presentation/   # UI layer
    ├── screens/    # App screens
    └── widgets/    # Reusable widgets
```

## Development Resources

- Flutter: flutter.dev/docs
- Firebase Flutter: firebase.google.com/docs/flutter/setup
- Cloud Firestore: firebase.google.com/docs/firestore
- Firebase Auth: firebase.google.com/docs/auth
