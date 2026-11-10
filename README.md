# Expense tracker (working name: "Expenses")

An automatic expense tracker for India. It records UPI, card and bank payments
without typing and groups trip and wedding spending into **Rooms**. Built in
Flutter for Android and iPhone. All data stays on the phone: there is no server
and no login.

> The app has no final name yet. "Expenses" and `com.example.expenses` are
> placeholders. To rename, change these three files together:
> `lib/core/app_identity.dart`, `android/app/build.gradle.kts`,
> `ios/Flutter/AppIdentity.xcconfig`.

## Run

Android has two flavors:

- `play`: the Play Store build, with no SMS permissions.
- `sideload`: the APK build, which can also read SMS directly.

```bash
flutter pub get
flutter run --flavor play        # Android
flutter run --flavor sideload    # Android, sideload build
flutter run                      # iPhone (no flavors on iOS)
```

Minimum versions: Android 8.0 (API 26) and iOS 17.

## Checks

Run before every push:

```bash
tool/ci.sh
```

The script checks formatting, runs the analyzer (infos count as errors) and runs
the tests in random order. It also checks the Android manifests:

- The `play` flavor must not ask for SMS permissions.
- No release build may ask for internet access.

## Status

| Phase | What | Status |
|---|---|---|
| 0 | Project setup, flavors, App Group, lints, CI | done |
| 1 | Core money tracking (manual) | next |
| 2 | Parser + paste/share capture | |
| 3 | Android auto-capture | |
| 4 | iOS auto-capture | |
| 5 | Rooms | |
| 6 | Budgets | |
| 7 | Learning & polish | |
| 8 | Privacy, backup, store readiness | |
