# Repository audit (RecallOS Phase 0)

Audited 19 November 2026 against the "RecallOS — Product & Engineering
Specification" brief. The brief was written without seeing this repository;
this document records what the repository actually contains so later phases
build on facts.

## 1. Baseline (commands and results)

| Check | Command | Result |
| --- | --- | --- |
| Toolchain | `flutter --version` | Flutter 3.50.0 stable, Dart 3.14.0 |
| Format | `dart format --output=none --set-exit-if-changed lib test integration_test` | 126 files, 0 changed |
| Static analysis | `flutter analyze` | No issues |
| Host tests | `flutter test` | 241 passed, 0 failed |
| Release build | `flutter build apk --release --split-per-abi --split-debug-info=build/symbols` | arm64-v8a 37.0 MB, armeabi-v7a 31.4 MB, x86_64 38.8 MB |
| Device run | release x86_64 APK on the `snapaction_api_36` emulator | installs over existing data, launches to Home |

Size: about 20,800 lines of application Dart (excluding generated code) and
6,200 lines of tests (30 test files plus 2 on-device integration tests).
Git history: 4 commits on `main`, pushed to
`github.com/akashsaha02/snap-action`.

On-device evidence from earlier phases is in `TEST_REPORT.md` (OCR in
airplane mode, 100 to 5,000-item libraries, a full release-build
walkthrough including every external hand-off). Not verified on any
physical phone for the current build.

## 2. Identity and naming

| Item | Value | Note |
| --- | --- | --- |
| User-visible name | **Mindtiq** | renamed 2026-11-19 (was Snaptiq, originally SnapAction); "RecallOS" is the programme name |
| Android package / applicationId | `com.snapaction.snapaction` | must not change: updates and data depend on it |
| Dart package | `snapaction` | internal |
| Database file | `snapaction.sqlite` (app-private) | internal |
| Backup format id | `snapaction-backup`, schema 2 | old backups must keep restoring |
| Signing | Android **debug key** | release keystore still to be created (see security doc) |

## 3. Stack as it exists

The brief assumes a Flutter stack; that assumption holds.

- **UI:** Flutter, Material 3 via `material_ui`, Riverpod 3, go_router 18,
  feature-first folders under `lib/features`, shared widgets in
  `lib/core/widgets`, brand theme ("Acid Pop") in `lib/core/theme`.
- **Persistence:** Drift 2.35 on SQLite (sqlite3 3.x native-asset build),
  WAL mode, FTS5 index with a `LIKE` fallback, schema version 2 with tested
  v1 to v2 migration, atomic and repeatable first-time creation.
- **Native Android:** a single `MainActivity.kt` method channel
  (`snapaction/platform`) for share intents, document save/open, calendar
  and contact inserts, Wi-Fi suggestions and `FLAG_SECURE`.
- **Intelligence:** ML Kit text recognition (bundled Latin model), a
  rule-based entity extractor (14 types), a keyword classifier with user
  rules, a deterministic action generator. No embeddings, no generative
  model.
- **Processing:** a durable `processing_jobs` table drained by `JobRunner`
  inside the app process (re-queues interrupted jobs at start). No
  WorkManager: processing happens only while the app is running.

## 4. Feature inventory (verified)

"Verified" means covered by host tests and checked on the emulator with a
release build (see `TEST_REPORT.md`, phase 8).

| Area | What works |
| --- | --- |
| Capture | Android photo picker (multi-select), share intent (single and multiple), SHA-256 exact-duplicate detection, perceptual-hash plus text check for similar screenshots, private copies and thumbnails |
| Understanding | Offline OCR (Latin), status-bar removal, 14 entity types, categories with user lock, heading-based titles, line-size heuristics |
| Organisation | Library (paging, true select-all, bulk actions), categories, collections (add existing screenshots), tags, notes, favourites, archive, similar-screenshot review |
| Search | FTS5 over title, text, notes, tags, entities, collections, category; filters; highlighted snippets; history; "100+" with load more |
| Act | Action Center grouped by screenshot; confirmed hand-off to Calendar (flight route/gate/seat, deadlines), Maps, Dialer, Contacts (name from chats), Email, Browser, Wi-Fi "Save network" sheet; wishlist with exact prices |
| Reminders | Inexact local notifications with Done and Snooze buttons, repeats, tabs, deep links, default time with minutes |
| Protect | App lock (biometric or device credential, falls back safely when the credential is removed), hide in recents, sensitive-preview blur, cloud backup disabled, typed DELETE for delete-all |
| Data ownership | ZIP/JSON/CSV export through the system picker, validated restore (paths, sizes, schema, hashes), merge without overwrite |

## 5. Gaps against the brief

| Brief pillar | Present | Missing |
| --- | --- | --- |
| Capture | images via picker and share | camera, document scan, PDF, audio, video, notes as standalone items, pasted text, links |
| Understand | OCR, entities, classification | document parsing, chunking, embeddings, transcription, local LLM |
| Connect | collections, tags, categories, similar images | entity normalisation across items, relationships, Spaces, timeline, graph |
| Recall | keyword FTS with filters | semantic retrieval, hybrid ranking, structured query parsing ("under EUR 100", "last week"), cited answers |
| Act | full action engine | tasks, study notes, Space membership |
| Protect | lock, blur, backups, delete | Model Center, sensitive exclusion from assistant retrieval (no assistant yet), database encryption |

## 6. Defects, risks and technical debt

Ordered by impact on the next phases.

1. **Data model is screenshot-shaped.** Every child table points at
   `screenshots.id`. Generalising to "memories" is the central migration
   (see `MIGRATION_PLAN.md`).
2. **No background execution.** Imports are processed only while the app is
   alive. Acceptable for screenshots (about 0.7 to 1.4 s each on the
   emulator), not for multi-page PDFs, transcription or embeddings. Needs
   WorkManager or a foreground service with user-visible progress.
3. **Analysis runs on the UI isolate.** Entity extraction and indexing are
   synchronous Dart on the main isolate. Fine at 41 ms per screenshot; long
   PDF text or chunking will jank. Move CPU work to a background isolate.
4. **English-only rules, Latin-only OCR.** Entity rules, titles and
   categories assume English. Most UI strings are hard-coded instead of
   living in the ARB files, which blocks translation.
5. **Release signing uses the debug key.** Updates must be signed with the
   same key forever; losing this machine's debug keystore would strand
   sideloaded users. Create a release upload key before any public build.
6. **Physical-device coverage is zero for the current build.** All device
   numbers come from an x86_64 emulator.
7. **Large files:** `screenshot_details_screen.dart` (about 900 lines) and
   `library_screen.dart` mix several concerns; split before adding PDF,
   audio and note variants.
8. **Duplicated naming:** brand Mindtiq, internal identifiers snapaction,
   brief RecallOS. Harmless for users, confusing for contributors; this
   document fixes the rule (user-visible name only, never identifiers).

No mocks, random vectors or fake statistics were found in shipped code
paths; tests use explicit fakes (`FakeOcrService`, `FakePlatformService`,
`FakeNotificationService`).

## 7. Reuse assessment

| Component | Reuse for RecallOS |
| --- | --- |
| Import pipeline (hashing, private copies, thumbnails, duplicate checks) | reuse; generalise the file-type gate |
| `processing_jobs` + `JobRunner` | reuse the durable queue; add job types, priorities, checkpoints, progress, and a WorkManager host |
| Entity extractor, classifier, action generator | reuse unchanged for every text-bearing memory type |
| FTS5 indexer and search repository | reuse as the keyword half of hybrid search; add chunk-level rows |
| Reminders, notifications, Action Center, ActionExecutor | reuse unchanged; the brief requires preserving them |
| Backup codec | reuse; extend the manifest for new tables and asset types |
| Theme and brand widgets | reuse (see open decision on tokens) |
| Collections | keep; Spaces are a new, richer concept (see migration plan) |

## 8. Dependency assessment

All direct dependencies are current (`flutter pub outdated`, 2026-11-18)
and each is imported by application code. New dependencies the brief
implies, with the open question for each:

| Need | Candidate | Question to settle in its phase |
| --- | --- | --- |
| PDF text and rendering | `pdfrx` (PDFium, bundled) | text-extraction API and APK size impact |
| Text embeddings | ONNX Runtime (Android AAR via the platform channel) or LiteRT | one runtime only; see `MODEL_STRATEGY.md` |
| Background work | `workmanager` plugin or native WorkManager in Kotlin | Drift access from the background isolate |
| Speech (V2) | whisper.cpp via native code | model size and speed on mid-range phones |
| Local LLM (V2) | LiteRT-LM, or ML Kit GenAI (Gemini Nano) where available | device coverage and licence terms |

## 9. Owner decisions (resolved 19 November 2026)

1. **Name:** the product is renamed **Mindtiq** (unique; keeps the "-tiq"
   brand and the mascot). "RecallOS" stays the programme name.
2. **Design tokens:** keep Acid Pop.
3. **Navigation:** adopt the brief's structure behind the `newNavigation`
   flag.
4. **Models:** bundle one small embedding model for V1; no `INTERNET`
   permission.
