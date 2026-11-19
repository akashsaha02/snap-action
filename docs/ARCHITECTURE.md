# Architecture

Snaptiq is a single Flutter app with no backend. Everything (storage,
text recognition, analysis, search, notifications) runs on the device.

## Layers

```
lib/
  app/         bootstrap, root widget, router, Riverpod providers
  core/        database (Drift), repositories, settings, theme, shared widgets, utils
  services/    platform-facing and pure logic, independent of UI
  features/    one folder per feature: application/ (state, use cases) and presentation/ (widgets)
  l10n/        ARB strings and generated localizations
```

- **Riverpod 3** wires everything. `appBootstrapProvider` opens the database,
  loads settings into memory and prepares private storage; every other service
  provider is built from it. Tests override it with an in-memory database.
- **go_router** owns navigation. The five tabs (Home, Collections, Search,
  Reminders, Settings) are a `StatefulShellRoute`; details, inbox, action
  center, wishlist, similar screenshots and the privacy policy are pushed
  above the shell.
- **Material 3** UI from `material_ui`, with the Inter font bundled (no font
  downloads).

## Data model (Drift / SQLite)

| Table | Purpose |
| --- | --- |
| `screenshots` | Private copy path, thumbnail, SHA-256 content hash, perceptual hash, status, category (user-chosen and suggested), flags |
| `ocr_results` | Recognised text, optional user-corrected text, text blocks |
| `extracted_entities` | Typed details with raw and normalised values and a validation status |
| `categories` | 15 system categories plus user categories |
| `classification_rules` | User keyword rules that take priority over built-in rules |
| `collections`, `collection_items` | Manual and smart collections |
| `tags`, `screenshot_tags`, `notes` | Organisation |
| `reminders` | Schedule, repeat rule, time zone, notification id, status |
| `suggested_actions` | Generated actions with a JSON payload and a review status |
| `wishlist_items` | Product, price as integer minor units plus currency |
| `processing_jobs` | Durable OCR and analysis queue |
| `search_history`, `app_settings` | Search history and key-value settings |

Dates are stored as Unix seconds. Money is never stored as floating point.
A standalone FTS5 table indexes title, text, notes, tags, extracted details,
collection names and category (diacritics-insensitive); if the SQLite
build lacks FTS5, search falls back to `LIKE` queries.

Schema version 2 added `screenshots.title_locked`: set when the user names
a screenshot, so re-analysis may replace generated titles but never typed
ones. Upgrades and version 1 backups treat existing titles as generated.

The database runs in WAL mode with `synchronous = NORMAL`: committed data
survives an app crash, and only a power loss can drop the most recent
commits. First-time schema creation runs in one transaction and uses
`IF NOT EXISTS` for every table and index, so an interrupted first launch
recovers on the next start. A full search-index rebuild (for example after
a restore) runs in a single transaction.

## Import and processing pipeline

1. **Import** (`features/screenshot_import`): the photo picker or a share
   intent hands over files, which are copied into app-private storage
   (`services/file_storage`). The content hash rejects exact duplicates; a
   64-bit perceptual hash flags similar images. A thumbnail is generated off
   the UI thread. Originals are only read, never changed or deleted.
2. **Queue** (`services/processing/job_runner.dart`): each import adds a
   `processing_jobs` row. Workers (1 or 2, configurable) claim jobs in a
   transaction, so work survives app restarts; jobs left `running` by a crash
   are re-queued at startup. Failures are recorded and can be retried.
3. **OCR** (`services/ocr`): Google ML Kit text recognition with the bundled
   Latin model. Host tests use a fake.
4. **Analysis** (`services/processing/screenshot_analyzer.dart`), all pure Dart
   and unit tested:
   - text normalisation;
   - entity extraction (`services/entity_extraction`): emails, phones, URLs,
     dates, times, amounts, deadlines, flight and order references, addresses,
     product names, event titles, Wi-Fi credentials and code. Dates follow the
     configured order (day, month or year first); ambiguous or year-less dates
     are flagged and never completed with a guessed year. Amounts are parsed
     into minor units per currency;
   - classification (`services/classification`): weighted keyword and entity
     rules, with user rules first. A category chosen by the user is never
     overwritten; low-confidence results are marked for confirmation;
   - action generation (`services/action_generation`): suggestions built only
     from extracted values;
   - title generation and search index update.

## Actions, reminders and notifications

- Suggested actions are only ever run by the user. `ActionExecutor` shows a
  confirmation or an editor first, and validates URLs (http/https with a
  real host), phone numbers and email addresses before handing them to
  another app via `url_launcher` or Android intents (calendar, contacts).
- `ReminderService` stores reminders and schedules notifications through
  `NotificationService` (flutter_local_notifications), using inexact
  `allowWhileIdle` scheduling. Repeats advance on completion; all reminders
  are re-registered at startup and after a restore. A notification tap
  deep-links to the screenshot or the reminders list.

## Settings, security and backup

- **Settings** are cached in memory (`SettingsRepository`) and persisted in
  `app_settings`.
- **App lock** (`features/security`): `AppLockGate` sits in
  `MaterialApp.router(builder:)` and covers the whole app, dialogs included,
  until `local_auth` succeeds (biometrics or the device credential). It locks
  again after 30 seconds in the background. It restricts access only; files
  and the database are not encrypted.
- **Hide in recent apps** sets `FLAG_SECURE` through the platform channel.
- **Export** (`features/backup`): JSON (all records, no images), CSV
  (extracted details, RFC 4180 quoting with spreadsheet-formula
  neutralising) or a ZIP backup. The file is written to a temporary folder and
  then saved with the system document picker or shared.
- **Restore** validates before anything changes: archive size, entry count,
  per-entry and total uncompressed size, entry names (no absolute paths,
  `..`, backslashes, drive letters or unknown files), manifest format and
  schema version (newer versions are refused), and typed parsing of every
  record. Images are extracted in a background isolate to a staging folder
  and checked against their SHA-256 hash. The merge runs in one database
  transaction: screenshots already present (same hash) are skipped, nothing
  local is overwritten, collections and tags merge by name, and reminders get
  fresh notification ids. A marker file lets the next start clean up after an
  interrupted restore.
- **Delete all data** cancels notifications, clears every user table and
  Snaptiq's private files, and keeps only theme, onboarding, app lock and
  hide-in-recents settings.

## Android integration

`MainActivity.kt` (a `FlutterFragmentActivity`, required by `local_auth`)
implements the `snapaction/platform` method channel: share intents, calendar
and contact insert intents, `ACTION_CREATE_DOCUMENT` / `ACTION_OPEN_DOCUMENT`
for export and restore, and `FLAG_SECURE`.

The manifest declares only `POST_NOTIFICATIONS` and `RECEIVE_BOOT_COMPLETED`
(plus `USE_BIOMETRIC` from `local_auth`) and explicitly removes storage, media,
exact-alarm and internet permissions that plugins would otherwise merge in.
`allowBackup="false"` and data-extraction rules keep app data out of cloud
backup and device transfer.

## Testing

- `test/unit`: parsers, entity extraction, classifier, action generation,
  database, job runner, search and organisation, reminders, actions, backup
  and data deletion.
- `test/widget`: the full app with an in-memory database and fake platform,
  OCR and notification services; seeded before pumping.
- `integration_test`: runs on a device or emulator, including airplane mode,
  and the large-library measurements reported in TEST_REPORT.md.

## Next: RecallOS target architecture

The planned evolution into a personal memory system keeps this structure
and extends it rather than replacing it:

- **Data:** the `screenshots` table is generalised in place into memories
  (schema 3, `docs/MIGRATION_PLAN.md`), with new tables for chunks,
  embeddings, Spaces, relationships and the model registry.
- **Processing:** the durable job queue gains job types, priorities and
  checkpoints, a WorkManager host for long work, and a background isolate
  for CPU-heavy analysis.
- **Intelligence:** an `EmbeddingService` interface with a native ONNX
  Runtime implementation, chosen and gated by the evaluation in
  `docs/MODEL_STRATEGY.md`. Keyword search (FTS5) stays as the always
  available half of hybrid retrieval.
- **Experiments** are gated by `FeatureFlag`s
  (`lib/core/services/feature_flags.dart`), all off by default.

Phases, gates and open owner decisions: `docs/IMPLEMENTATION_ROADMAP.md`,
`docs/RECALLOS_PRODUCT_SPEC.md`, `docs/REPOSITORY_AUDIT.md`.
