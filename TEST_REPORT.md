# Test report

Recorded 18 November 2026. Only numbers from a finished run are listed.
Anything not run is marked as not measured.

All device numbers come from the `snapaction_api_36` emulator (x86_64,
3 GB RAM, software GPU) on a 16 GB Windows laptop. Expect different numbers
on a phone.

## Host

`flutter analyze`: no issues.

`flutter test`: 154 tests passed (about 11 seconds on this machine).

That covers parsers, entity extraction, classification, the job queue,
search and organisation, reminders, the action center, wishlist, backup
round-trip and validation (unsafe paths, newer schema, damaged images,
duplicates, CSV quoting), delete-all, the app lock, the main screens, WAL
mode on a file database, and recovery from an interrupted first-time schema
creation.

## On-device OCR (`integration_test/offline_pipeline_test.dart`)

Two tests: import four rendered screenshots and read them with ML Kit, then
open the app, search and show details. Both passed in every run below.

| Run | Network | OCR + analysis per screenshot |
| --- | --- | --- |
| Before the database changes | on (`network_reachable=true`) | 1,164 ms |
| Before the database changes | airplane mode (`network_reachable=false`) | 962 ms |
| WAL mode and index rebuild change | airplane mode | 681 ms |
| Final code (schema creation fix) | airplane mode | 789 ms |

Each figure is total time divided by 4 screenshots, from one run, so expect
run-to-run noise. The test checks that the recognised text contains "payment
successful", "boarding pass" and "submission deadline", that the amount is
stored as `EUR 23.50` (2350 minor units), that the finance, travel and
education categories are assigned, that a search for "lisbon" finds one
result through FTS5, and that the original files are left in place.

The first run in this session failed before any test ran: the APK built by
`flutter test` was missing `libsqlite3.so`. The next build packaged it, and
it has been present in every build since, including the release APK (all
three ABIs). The cause was not found.

## Large libraries (`integration_test/large_library_test.dart`)

Stored text for N screenshots is analysed with OCR switched off, then search
and library queries are timed. Search and page timings are the median of 7
runs. Every size passed in both runs.

Final code (WAL mode, single-transaction index rebuild):

| Screenshots | Insert | Analysis total | Per screenshot | Search, one word | Search, prefix | Search, two words | First library page | Stats | Index rebuild | Database |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 100 | 1.1 s | 5.4 s | 54 ms | 6 ms | 3 ms | 5 ms | 3 ms | 46 ms | 1.0 s | 324 KB |
| 500 | 3.6 s | 22.2 s | 44 ms | 6 ms | 5 ms | 5 ms | 1 ms | 8 ms | 4.1 s | 952 KB |
| 1,000 | 5.9 s | 43.2 s | 43 ms | 8 ms | 8 ms | 7 ms | 2 ms | 6 ms | 7.9 s | 1.6 MB |
| 5,000 | 27.5 s | 206.5 s | 41 ms | 14 ms | 15 ms | 16 ms | 2 ms | 7 ms | 38.4 s | 8.1 MB |

First run, before the change (default rollback journal, one transaction per
re-indexed screenshot):

| Screenshots | Analysis total | Per screenshot | Search, one word | Index rebuild |
| ---: | ---: | ---: | ---: | ---: |
| 100 | 13.6 s | 136 ms | 5 ms | 2.2 s |
| 500 | 64.1 s | 128 ms | 7 ms | 13.4 s |
| 1,000 | 138.3 s | 138 ms | 12 ms | 26.2 s |
| 5,000 | 573.6 s | 115 ms | 16 ms | 106.7 s |

Search and the first library page stay under 20 ms at 5,000 screenshots.
Bulk analysis is about 41 ms per screenshot without OCR, so with OCR on
(about 0.7 to 1.2 s per screenshot above), recognition dominates.

## Debug APK on the emulator

The debug APK was installed and walked with the accessibility tree: Home
empty state and Import, Collections with Wishlist, Search filters and the
empty search state, Reminders tabs (all at 0), Settings with backup,
restore and delete-all, and the Privacy policy with the on-device summary.

## Release APK

`flutter build apk --release`: `build\app\outputs\flutter-apk\app-release.apk`,
**103.6 MB**, a single APK holding arm64-v8a, armeabi-v7a and x86_64.
Signed with the Android debug key (`CN=Android Debug`).

Requested permissions: `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`,
`VIBRATE`, `USE_BIOMETRIC`, `USE_FINGERPRINT`, `ACCESS_NETWORK_STATE` (merged
in by ML Kit) and the app's own receiver permission. There is no internet,
storage, media or exact-alarm permission.

On the emulator, from a clean install:

- `adb install`: 35 s.
- Cold start (`am start -W`, TotalTime): 4,548, 4,855 and 4,050 ms.
- Walked: onboarding (Skip), Home empty state, Collections, Search,
  Reminders (notifications-off banner, all tabs at 0) and Settings, down to
  Storage ("database 220 KB") and Backup and export. No errors in logcat.

The first launch of the first release APK showed "Mindtiq could not open
its local database." With the startup error now logged, a reinstall that
kept the app's data showed the cause: `index idx_screenshots_status already
exists`. The first launch had stopped part-way through creating the schema.
The emulator's System UI was not responding at that moment, and why
creation stopped was not found. Schema creation is now one transaction with
`IF NOT EXISTS`. A host test resets the schema version on a created database
and reopens it; that test fails on the old code with the same error and
passes on the new code.

## Phase 8: release build walkthrough (19 November 2026)

Twelve realistic phone screenshots (receipts, boarding pass, assignment,
job post, conference poster, product page twice, Wi-Fi card, chat, recipe,
code) were imported through the Android photo picker into the release
build on the emulator, then every feature was used through the UI.

Host: `flutter analyze` no issues; `flutter test` **241 tests passed**.
On-device OCR test (airplane mode, final code): both tests passed,
1,360 ms per screenshot on a cold emulator.

Found and fixed during the walkthrough (each fix re-checked on the device):

| Problem | Result before | After |
| --- | --- | --- |
| R8 stripped ML Kit classes | every release import failed, stack trace shown | 12 of 12 read |
| Status bar read as text | title "Flight 5G87" | "Flight LH1234" |
| Past and receipt dates | "Remind me on 12 Nov" (past) | not suggested |
| False addresses | "Show on map: Paid with Visa 4821" | not suggested |
| OCR split a link | opened `https://example.com` | `https://flutter.example.com` |
| Body text chosen as title | "Submit your report via…" | "Machine Learning - Assignment 3" |
| Similar screenshots | two different receipts paired | only the re-taken product page |
| Day-before reminder | 11:59 PM | default reminder time |
| Notification | Flutter icon, no buttons | Mindtiq icon, Done and Snooze |
| App icon | Flutter template | Mindtiq logo (adaptive, themed) |

Checked and working in the release build:

- Upgrade over an installed build (schema 1 to 2) keeps all data.
- Hand-off to other apps, each opened with the details filled in and
  nothing sent or saved automatically: Google Calendar (flight with route),
  Dialer (+43 660 1234567), Contacts (number, and the name for chats),
  Maps (Herrengasse 14), Gmail (draft to jobs@acme.example), Chrome (link),
  and Android's "Save this network?" sheet for Wi-Fi.
- Reminder created from a deadline suggestion, alarm registered, completed
  and alarm cancelled. A reminder notification arrived 1.5 minutes after
  its time (inexact scheduling); tapping it opened Reminders; its Done
  button completed the reminder.
- Search for text, amounts ("23.50") and a password; empty result state.
- New collection, "Add screenshots" picker, sensitive preview hidden.
- Wishlist item from a suggestion with the exact price (EUR 49.99).
- Re-analyse all with progress; Re-import of the same 12 images:
  "Nothing new to import, 12 were already in your library".
- Full ZIP backup saved to Downloads through the system picker (1.09 MB),
  delete all data (typed DELETE; gallery originals untouched), restore of
  12 screenshots, collection, reminder and wishlist item.
- App lock with a device PIN: turning it on, unlock on cold start; with the
  screen lock removed the app turns its lock off instead of locking out.
- Dark theme on Home and the Action Center.

APK sizes (release, per ABI): arm64-v8a 36.5 MB, armeabi-v7a 30.9 MB,
x86_64 38.4 MB. The universal APK was 103.6 MB.

Not checked on a device: Google Calendar's own save screen (the emulator
asks for a Google account first), a physical phone for this build.

## Schema 3 upgrade on the emulator (19 November 2026)

The installed schema-2 release (versionCode 4001, the 12-screenshot test
library) was replaced with `adb install -r` by the schema-3 x86_64 release
build, then started.

| Check | Result |
| --- | --- |
| Home screen (counts, upcoming items, recent) | identical to before, apart from the new name |
| Library list (11 items in the default view) | identical |
| `user_version` | 2 → 3 |
| Rows: screenshots, OCR results, entities, suggested actions | 12, 12, 28, 21 before and after |
| `memory_type` | `screenshot` for all 12 |
| New tables | all 6 present, empty |
| `foreign_key_check` / `integrity_check` | 0 violations / ok |
| Snapshot `files/snapshots/pre_v3.sqlite` | present, `user_version` 2, same row counts |
| Errors in logcat | none |

Databases were read by pulling them with `adb root` (emulator only).
Not checked on the device: reminders and a notification tap, because the
library had no reminders; these are covered by host tests.

Host suite after the migration: 254 passed, 1 skipped (the fixture
generator).

## Not measured

- A physical phone. Every device number above is from the emulator.
- Photo-picker and share-intent import on a device (covered on the host with
  fakes).
- Install and run of a release APK signed with a real keystore.

## How to repeat the device runs

Start the emulator, then:

```powershell
flutter test integration_test/offline_pipeline_test.dart -d emulator-5554
adb shell cmd connectivity airplane-mode enable
flutter test integration_test/offline_pipeline_test.dart -d emulator-5554
adb shell cmd connectivity airplane-mode disable
flutter test integration_test/large_library_test.dart -d emulator-5554
adb emu kill                       # free memory before the release build
flutter build apk --release
```
