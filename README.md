# BeissAb Mobile

Native Flutter/Dart migration of the BeissAb React frontend. This repository intentionally contains **no React, WebView, Capacitor or Node backend**.

## Backend
The existing BeissAb Node/Express/MySQL backend remains the source of truth. Configure its URL at build/run time:

```bash
flutter run --dart-define=API_BASE_URL=https://example.org/api
```

For Android emulator + local backend use e.g. `http://10.0.2.2:3000/api`; iOS simulator commonly uses `http://127.0.0.1:3000/api`.

## First checkout
This export contains the migrated Dart application source and assets. If Android/iOS runner folders are absent, generate only Flutter's platform runner boilerplate once with `flutter create . --platforms android,ios`; do not replace `lib/`, `assets/` or `pubspec.yaml`.

Then:
```bash
flutter pub get
flutter test
flutter run --dart-define=API_BASE_URL=https://YOUR-BEISSAB-HOST/api
```

## Migrated feature surface
- Login, registration, email verification/resend
- Forgot/reset password
- Per-user onboarding state
- Today meal suggestions, filters, swipe/accept/reject, week creation
- Recipe detail, ingredients and steps
- Weekly plan and recipe day reordering
- Shopping list check/edit/delete
- Household/family preferences
- Notification preference
- More, privacy and changelog screens
- Secure token storage and authenticated API client
- Existing BeissAb recipe/brand assets
