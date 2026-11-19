# SnapAction tasks

Status of the implementation plan. A phase is complete only when its behaviour
is implemented and checked. Device timings are recorded in TEST_REPORT.md.

## Phase 0 — Toolchain

Done. Flutter 3.50 (Dart 3.14), Temurin JDK 17 and Android SDK 36 with the
`snapaction_api_36` emulator are installed on `D:`.

## Phase 1 — App skeleton, theme and database

Done.

- Material 3 theme (light, dark, system) with the Inter font bundled.
- Drift schema, 15 system categories, FTS5 index with a `LIKE` fallback.
- Splash, onboarding, five-tab shell and shared empty states.
- Android manifest strips storage, media, exact-alarm and internet
  permissions. App data is excluded from cloud backup and device transfer.
- Host tests, analyzer and a debug APK. The debug APK launches on the
  emulator and shows onboarding, then the five tabs.

## Phase 2 — Import and library

Done on the host (unit and widget tests) and present in the debug APK.

- Photo picker and share-intent import into private storage.
- Thumbnails, SHA-256 duplicate detection and perceptual-hash similarity.
- Inbox, details, favourite, archive and delete of SnapAction's copy only.
- Checked on the emulator: empty Home, Collections, Search and Reminders
  states, including the note that gallery originals are never deleted.

## Phase 3 — OCR and understanding

Done on the host. On-device OCR is covered by
`integration_test/offline_pipeline_test.dart` (see TEST_REPORT.md).

- ML Kit OCR behind `OcrService`, with a fake for host tests.
- Durable job queue: claim in a transaction, retry, re-queue jobs left
  running after a crash.
- Normaliser, 14 entity types, rule classifier that keeps a user-chosen
  category, and suggested actions. Year-less dates are never completed.

## Phase 4 — Organisation and search

Done on the host.

- Smart and custom collections, tags, notes and user keyword rules.
- FTS5 search with filters, highlighted snippets and history.
- Checked on the emulator: Search filters and the empty search state render.

## Phase 5 — Reminders, actions and wishlist

Done on the host (115 tests at the end of the phase; the suite is larger now).

- Reminders with inexact local notifications, repeats, snooze and deep links.
- Action center. External actions are confirmed and validated first.
- Wishlist with prices stored as integer minor units.
- Checked on the emulator: reminder tabs show zero counts and the empty state.

## Phase 6 — Settings, lock, backup and privacy

Done.

- Settings for theme, OCR, date order, similar-image detection, notifications,
  default reminder time, sensitive previews, storage and search history.
- App lock (access restriction, not encryption) with a 30-second grace period.
- Hide in recent apps via `FLAG_SECURE`.
- JSON, CSV and ZIP export. CSV quoting neutralises spreadsheet formulas.
- Restore validates paths, sizes, counts, schema version, record types and
  image hashes, then merges without overwriting.
- Delete all data keeps theme, onboarding, app lock and hide-in-recents, and
  asks the user to type DELETE.
- In-app privacy policy matches PRIVACY.md.
- Host coverage: `test/unit/backup_test.dart`, `test/widget/app_lock_test.dart`
  and the settings widget test.
- Checked on the emulator: Settings lists backup, restore and delete, and
  Privacy policy opens with the on-device summary.

## Phase 7 — Device tests, measurements and release

Done on the emulator. Timings are in TEST_REPORT.md.

- Debug APK built, installed and walked on the emulator.
- `integration_test/offline_pipeline_test.dart` passes with the network on
  and with airplane mode on (both tests, final code).
- `integration_test/large_library_test.dart` passes at 100, 500, 1,000 and
  5,000 screenshots. The first run showed slow bulk work, fixed by WAL mode
  and a single-transaction index rebuild. Both runs are recorded.
- Release APK built (103.6 MB, R8), installed on a clean emulator, cold
  started three times and walked through onboarding, the five tabs and
  Settings. It is signed with the debug key until a release keystore is
  added. No signing secrets are in the repository.
- Found and fixed on the release walk: an interrupted first launch left a
  half-created schema, and every later start then failed. Schema creation is
  now atomic and repeatable, with a host test that reproduces the failure.
- Not done: a physical phone, and photo-picker or share-sheet import on a
  device (both covered on the host with fakes).

## Phase 8 — Review, release fixes and polish

Done (19 November 2026). Found by using the release APK with real
screenshots on the emulator and on a phone; details in TEST_REPORT.md.

- Release builds could not read any text: R8 stripped classes ML Kit loads
  by reflection. Fixed with keep rules; raw stack traces are no longer shown.
- Suggestions: no reminders or calendar entries for past dates or payment
  dates; status-bar text ("5G 87%") no longer read as a flight; false
  addresses ("Paid with Visa 4821", "CS 4410") removed; OCR-split links
  joined; titles use the largest heading (OCR line sizes).
- Other apps: flights go to the calendar with route, gate and seat;
  deadlines can go to the calendar; events carry their link; contacts from
  chats carry the name; Wi-Fi opens Android's "Save network" sheet.
- Screens: compact Home with "Coming up"; Action Center grouped by
  screenshot; confirm/edit/reject detected values; library paging and
  select-all fixed; "Add screenshots" to a collection; retry all failed;
  search focus and 100+ results; reminders open on the right tab and use the
  default time; accessible status colours; consistent blurring.
- Similar screenshots also compare text, so different receipts from one app
  are no longer offered for deletion.
- Notifications: SnapAction icon, Done and Snooze buttons. App icon replaces
  the Flutter template icon (adaptive and themed).
- Database schema 2 (`titleLocked`): re-analysis refreshes generated titles
  and keeps the user's. Version 1 databases and backups still open.
- Size: per-ABI APKs (arm64 36.5 MB instead of 103.6 MB universal), fonts
  subset (1.67 MB to 0.72 MB), unused package removed.

## Not in this version

- iOS project, share extension and document picker.
- Non-Latin OCR, including Bengali. ML Kit's bundled model is Latin only.
- Encryption of the database or image files.
- Exact-alarm reminder delivery.
