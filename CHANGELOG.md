# Changelog

## 1.0.0 (unreleased)

First complete version, built in phases (see TASKS.md).

### Foundation
- Flutter 3.50 / Dart 3.14 app with Riverpod 3, go_router, Drift and
  Material 3 (Inter font bundled), light, dark and system themes.
- Drift schema for screenshots, OCR results, extracted details, categories,
  rules, collections, tags, notes, reminders, suggested actions, wishlist,
  processing jobs, search history and settings; 15 system categories seeded.
- FTS5 search index with a `LIKE` fallback when FTS5 is unavailable.
- Onboarding, five-tab shell and shared empty, error and loading states.
- Android manifest without storage, media, exact-alarm or internet
  permissions; app data excluded from cloud backup and device transfer.

### Import and processing
- Import with the Android photo picker and the share sheet into
  app-private storage; thumbnails; exact-duplicate and similar-image
  detection; inbox, details, favourite, archive and delete (the app's own
  copy only).
- On-device OCR with ML Kit, a durable job queue with retry, text
  normalisation, extraction of 14 kinds of details, rule-based
  classification that never overrides a user-chosen category, and suggested
  actions.

### Organisation and search
- Smart and custom collections, tags, notes, user keyword rules.
- Full-text search with filters, highlighted snippets and history.

### Actions
- Reminders with local notifications (inexact), repeats, snooze, deep links
  and re-registration at startup.
- Action center with accept, edit, dismiss (with undo) and postpone; every
  external action is confirmed and validated first.
- Wishlist with exact prices stored as integer minor units.

### Settings, privacy and backup
- Settings for theme, text recognition (on/off, date format, parallel
  processing, re-analyse all), similar-image detection, notifications and
  default reminder time, sensitive-preview blurring, storage usage and search
  history.
- Optional app lock (biometrics or screen lock) that covers the whole app and
  relocks after 30 seconds in the background. It restricts access and does
  not encrypt data.
- Hide in recent apps (`FLAG_SECURE`).
- Export as JSON, CSV (formula-safe) or a full ZIP backup, saved through the
  system document picker or shared. Every export warns that it can contain
  sensitive information.
- Restore from ZIP with validation of paths, sizes, entry counts, schema
  version, record types and image hashes; merges without overwriting, skips
  duplicates and cleans up after an interrupted restore.
- Delete all data, with typed confirmation and a clear note that gallery
  originals are not affected.
- In-app privacy policy and open-source licences.

### Brand: Acid Pop
- New visual identity from the brand kit in `assets/icons` (source files,
  tokens and guide). Acid lime, hot pink and volt violet on paper; ink
  outlines and hard offset shadows (lime in dark mode); pill buttons;
  Space Grotesk headings with Inter body text.
- Tiq the mascot in onboarding and in every empty, error and all-done
  state (nine illustrations, resized to 540 px, 119 KB in total).
- New launcher icon (adaptive, round, themed monochrome), notification
  icon, splash screens (Android 12+ and older) and in-app logo.
- Accessibility kept: text colours on tinted surfaces stay at WCAG AA,
  selected chips use ink on lime in both themes; snack bars with an action
  close after 6 seconds unless a screen reader is on.

### Name
- Renamed again, to **Mindtiq** (19 November 2026): the app is growing from
  screenshots into a private memory for documents, notes and more, and
  "RecallOS" was not unique. The mascot Tiq, the icon and the Acid Pop
  brand stay. New exports are named `mindtiq-<date>.zip`; older `snaptiq-`
  and `snapaction-` backups still restore.
- The app is now called **Snaptiq** (was SnapAction). The package id
  `com.snapaction.snapaction`, database and backup format are unchanged, so
  installed copies update in place and older backups still restore. New
  exports are named `snaptiq-<date>.zip`.

### Review and polish (phase 8)
- Release builds: ML Kit keep rules (text recognition failed in every
  release build before), readable error messages instead of stack traces.
- Better suggestions: no past or payment-date reminders, status bar ignored,
  fewer false addresses, OCR-split links repaired, heading-based titles.
- Hand-off to other apps: flight and deadline calendar entries with details,
  contact name from chats, Wi-Fi "Save network" sheet with a copy fallback.
- Home dashboard with "Coming up"; Action Center grouped by screenshot;
  confirm, edit or reject detected values; tappable links, numbers and
  addresses; full-screen text editor.
- Library: smooth paging, true select-all, add existing screenshots to a
  collection, retry all failed. Search: autofocus, "100+" with load more.
- Reminders: opens on the first tab with items, minute-precise default
  time, title-only edits, notification Done and Snooze buttons.
- Similar screenshots compare recognized text as well as the image.
- Accessible status colours (WCAG AA), 48 dp tap targets, consistent blur.
- App and notification icons from the Snaptiq logo.
- Schema 2: `titleLocked`; generated titles can improve on re-analysis.
- Smaller app: per-ABI APKs, subset fonts, unused dependency removed.

### Device testing and release (phase 7)
- The database uses WAL mode with `synchronous = NORMAL`. On the emulator,
  analysing 5,000 stored screenshots went from 574 s to 207 s.
- A full search-index rebuild runs in one transaction (107 s to 38 s for
  5,000 screenshots).
- First-time schema creation is atomic and repeatable. Before this, a first
  launch that stopped part-way left the app showing "could not open its
  local database" on every start until its data was cleared.
- The reason for a startup failure is written to the device log.
- Storage usage includes the database's WAL file.
- Release build: R8 rules for the optional ML Kit language recognizers, and
  the release lint-vital pass is switched off (lint crashes on JDK 17).
