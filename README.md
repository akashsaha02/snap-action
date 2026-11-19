# SnapAction

Screenshot anything. Find everything. Turn it into action.

SnapAction is an offline-first Flutter app that turns screenshots into
searchable, actionable information. It reads the text in each screenshot on
the device, sorts it into a category, finds useful details (dates, amounts,
links, phone numbers, codes and more) and suggests actions such as creating a
reminder or adding a calendar event. Nothing leaves the phone: there is no
account, no server, no analytics and no cloud AI.

Android is the primary platform. iOS builds are not set up yet; see
[Known limitations](#known-limitations).

## Features

- **Import** through the Android photo picker (no gallery permission) or by
  sharing images to SnapAction from any app. Exact duplicates are skipped and
  visually similar screenshots are flagged.
- **On-device text recognition** with Google ML Kit (bundled Latin-script
  model), run by a durable background queue that survives restarts and
  retries failures.
- **Rule-based understanding**: 14 kinds of details, 15 built-in categories, and
  suggested actions. Uncertain results are marked for confirmation, and dates
  without a year are never completed with a guessed year.
- **Search** across text, titles, notes and tags with SQLite FTS5 (with a
  slower fallback when FTS5 is unavailable), filters, highlighted snippets and
  search history.
- **Organise** with smart collections, your own collections, tags, notes,
  favourites and archive. Categories you choose are never overwritten.
- **Reminders** with local notifications, repeats, snooze and deep links back
  to the screenshot. No exact-alarm permission is used.
- **Action center** to review suggestions; every external action (opening a
  link, calling, emailing, maps, calendar, contacts) asks first.
- **Wishlist** with exact prices stored as integer minor units.
- **Settings**: theme, text recognition, import, notifications, an optional
  app lock, hide in recent apps, storage, JSON/CSV/ZIP export, validated
  restore, delete all data, privacy policy and licences.

## Privacy in short

- Works in airplane mode. The release build has no internet permission.
- Original gallery images are never modified or deleted.
- App data is excluded from Android cloud backup and device transfer.
- The app lock restricts access to the app. It does **not** encrypt data.
- Exports are plain files that can contain sensitive information.

See [PRIVACY.md](PRIVACY.md) for details.

## Building

Requirements: Flutter 3.50 (Dart 3.14), JDK 17, Android SDK 36.

```powershell
flutter pub get
dart run build_runner build      # regenerates Drift code after schema changes
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release      # see the release signing note below
```

For phones, build one APK per CPU type. Each holds only the native code
that phone needs, so it is about a third of the universal APK:

```powershell
flutter build apk --release --split-per-abi --split-debug-info=build/symbols
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk    almost every phone from 2017 on
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk  older 32-bit phones
# build/app/outputs/flutter-apk/app-x86_64-release.apk       emulators
flutter build appbundle --release --split-debug-info=build/symbols  # Play Store
```

Keep `build/symbols` for each release: it is needed to read Dart crash
stack traces (`flutter symbolize`). Do not add `--obfuscate`: it renames
enum values, and the app stores enum names in its database, settings and
backups, so data written by earlier builds would no longer be readable.

On Windows, when the pub cache and the project are on different drives,
`android/gradle.properties` sets `kotlin.incremental=false`, which avoids
Kotlin's "Could not close incremental caches" failure.

Release builds use R8. `android/app/proguard-rules.pro` silences the optional
Chinese, Devanagari, Japanese and Korean ML Kit recognizers, which are not
bundled. The release lint-vital pass is switched off because the bundled lint
crashes on JDK 17 (it calls the JDK 21 `List.removeLast()`); `flutter analyze`
still runs. On a machine with 16 GB of RAM, stop the emulator before a
release build: Gradle and R8 have failed with native out-of-memory errors
when both were running.

**Release signing:** the release build type is signed with the debug key so
that a test APK can be built without secrets. Configure your own keystore
before publishing; no signing secrets are stored in the repository.

## Project documents

- [ARCHITECTURE.md](ARCHITECTURE.md): layers, data model, processing pipeline
- [TASKS.md](TASKS.md): phase-by-phase status
- [PRIVACY.md](PRIVACY.md): what is stored and why
- [TEST_REPORT.md](TEST_REPORT.md): automated and device test results, measured timings
- [CHANGELOG.md](CHANGELOG.md)

## Known limitations

- **iOS** is not configured or tested. The code avoids Android-only
  assumptions where possible, but share import, document saving and the
  platform channel in `MainActivity.kt` have no iOS counterpart yet.
- **Languages**: ML Kit's bundled model reads Latin-script text only.
  Bengali and other non-Latin scripts are not recognised (ML Kit has no
  Bengali model), and the detail rules are written for English text.
- **Reminder timing** is inexact by design (no exact-alarm permission), so
  Android may deliver notifications a few minutes late.
- **The app lock** is an access restriction, not encryption.
- **Similar-screenshot detection** uses a 64-bit perceptual hash and can miss
  near-duplicates that were cropped or heavily edited.
