# Security and privacy

Engineering view of how personal data is handled. The user-facing policy is
`PRIVACY.md` (also shown in the app); this document must stay consistent
with it.

## Data inventory

| Data | Where | Leaves the device? |
| --- | --- | --- |
| Imported screenshots (copies) and thumbnails | app-private storage (`getApplicationSupportDirectory`) | only in a backup the user exports |
| OCR text, user corrections, entities, notes, tags, categories, collections | `snapaction.sqlite` (app-private, WAL) | only in exports |
| Reminders and notification ids | database + Android alarm manager | no |
| Settings (theme, lock, preferences, dismissed groups) | `app_settings` table | no |
| Planned: chunks, embeddings, model files | database / app-private files | never exported as vectors; models never uploaded |

The release build declares no `INTERNET` permission (verified with `aapt
dump permissions`). `ACCESS_NETWORK_STATE` is merged in by ML Kit and cannot
transmit data. Android cloud backup and device transfer are disabled
(`allowBackup=false`, `fullBackupContent=false`, `dataExtractionRules`).

**Model downloads (planned)** will be the first network use. They must go
through a separate, explicit flow: show source, size, licence and purpose;
download only the model file; verify SHA-256; never send user content. If
the `INTERNET` permission is added for this, state it in `PRIVACY.md` and
the store listing, and keep every other code path offline.

## Threat model

| Threat | Current control | Gap / planned control |
| --- | --- | --- |
| Someone picks up an unlocked phone | optional app lock (biometric or device credential, 30 s grace), hide in recents (`FLAG_SECURE`), sensitive-preview blur | lock is access control, not encryption (stated in the app) |
| Phone theft with forensic access | Android file-based encryption of app-private storage | optional SQLCipher-style database encryption with a Keystore-held key, only with documented key-loss behaviour and tests |
| Other apps reading Mindtiq data | app-private storage; no exported providers; share and document flows use system pickers | none known |
| Malicious shared or imported file | size limits, type checks, decoding in the image library, restore validation (path traversal, entry counts, sizes, schema, hashes) | PDF parser (Phase 3) must be fuzzed with corrupt files; render in a bounded process if the library crashes |
| Prompt injection through OCR or document text (assistant phase) | no LLM yet; actions always need a user tap and confirmation | treat imported text as data; tool registry with strict schemas; validate citations against retrieved ids; never let content trigger actions |
| Data leaking through logs | release logs only startup and recognition failures, without screenshot text | keep a lint/test that no `debugPrint` includes OCR text, notes or entity values |
| Unsafe external hand-off | every external action is confirmed; URLs restricted to http/https with a real host; phone/email validated | keep the allowlist when the assistant can suggest actions |
| Losing the ability to update | release currently signed with the debug key | create an upload keystore, store it offline with a backup, enrol in Play App Signing before the first public release |
| Unencrypted exports | every export warns that it can contain sensitive information | optional password-protected backups (authenticated encryption), only after implementation review and restore tests |

## Sensitive memories

Already: screenshots that look like passwords, banking or IDs are flagged
`is_sensitive` and blurred in lists when the setting is on.

Required as features arrive:

- Excluded by default from rediscovery, notification previews, broad
  assistant retrieval and default export selections.
- Included in a scoped query only when the user opens that memory or
  explicitly allows it.

## Permissions policy

Request in context, never at first launch. Allowed today:
`POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `VIBRATE`, `USE_BIOMETRIC`.
Not allowed: broad photo or file access (`READ_MEDIA_*`,
`MANAGE_EXTERNAL_STORAGE`), accessibility services, background location,
background microphone, exact alarms. Microphone (V2) only while the user
holds a visible record control. Camera through the system intent or an
in-app capture screen with a visible preview.

Google Play has required the photo picker instead of `READ_MEDIA_IMAGES`
unless broad access is core functionality (enforced since May 2025). If
automatic screenshot import is ever considered, it needs a declaration and
an explicit opt-in, and it changes the product's privacy promise; decide it
as a product question, not a convenience.

## Deletion

Deleting a memory removes the private copy, thumbnail, OCR, entities, tags,
notes, collection links, actions, jobs, FTS rows (and, when added, chunks,
embeddings, relationships and Space memberships) and cancels its reminders'
notifications. Gallery originals are never touched. "Delete all data"
requires typing DELETE. Forensic erasure is not promised.
