# Migration plan: screenshots to memories (schema 3)

Status: **design approved for implementation in Phase 1; not yet coded.**
Current schema: version 2 (Drift, `snapaction.sqlite`, WAL).

## Goals

1. Every existing screenshot, its OCR text, user corrections, entities,
   categories, tags, collections, notes, favourites, archive state,
   reminders (with notification ids), suggested actions, wishlist items,
   jobs and preferences survive the upgrade unchanged.
2. New memory types (document, note, link; later audio, video) share the
   same library, search, collections, reminders and actions.
3. No ML model is needed to migrate. Embeddings and chunks are produced
   afterwards by ordinary background jobs.
4. The upgrade is transactional, interruption-safe and idempotent, and can
   be rolled back from a local snapshot.

## Decision: generalise in place, do not copy

Two options were considered.

| | A. Generalise the `screenshots` table in place | B. New `memories` table, copy rows, repoint children |
| --- | --- | --- |
| Data movement | none: rows keep their ids | every row copied; 12 child tables repointed |
| Risk on interruption | low (additive `ALTER TABLE`) | high (multi-table rewrite) |
| Code churn | Dart-level rename only | every query rewritten |
| Backup compatibility | old backups map 1:1 | needs an id translation table |

**Option A is chosen.** The SQL table keeps the name `screenshots` (renaming
a SQLite table that 12 foreign keys reference is the riskiest step and buys
nothing). In Dart the table class is renamed `Memories` with
`@DataClassName('MemoryRow')` and `tableName => 'screenshots'`, so new code
reads naturally while the file on disk does not change.

## Schema 3 changes

### Altered: `screenshots` (Dart: `Memories`)

| New column | Type | Default for existing rows | Purpose |
| --- | --- | --- | --- |
| `memory_type` | text enum | `'screenshot'` | screenshot, image, document, note, link (audio, video later) |
| `mime_type` | text, nullable | `image/png` or `image/jpeg` from the stored file | rendering and validation |
| `description` | text, nullable | null | user-editable summary |
| `source_url` | text, nullable | null | for links and shared URLs |
| `page_count` | int, nullable | null | documents |
| `duration_ms` | int, nullable | null | audio and video (V2/V3) |
| `event_at` | datetime, nullable | null | user-confirmed event date for the timeline |

Existing columns keep their meaning. `captured_at`, `imported_at` and
`event_at` stay distinct; no date is invented when metadata is missing.

### New tables

| Table | Key columns | Notes |
| --- | --- | --- |
| `memory_chunks` | id, memory_id FK cascade, chunk_index, text_original, text_normalized, page, start_ms, end_ms, region_json, token_count, source_checksum | page-aware for PDFs, timestamped for audio |
| `embeddings` | id, chunk_id FK cascade, memory_id FK cascade, model_id, model_version, space_id, dimension, vector (blob, float32 little-endian), source_checksum, created_at | unique (chunk_id, model_id, model_version); never mix `space_id`s |
| `spaces` | id, title, description, icon, color, cover_memory_id, created_at, updated_at | projects, goals, interests |
| `space_memberships` | space_id FK, memory_id FK, source (`user`/`suggested_confirmed`), added_at | primary key (space_id, memory_id) |
| `memory_relationships` | id, source_memory_id, target_memory_id, type, score, provenance, method, confirmed, created_at | type from the brief's edge list; unique (source, target, type) |
| `model_registry` | model_id, type, version, path, install_state, sha256, size_bytes, license, embedding_space_id, installed_at | Model Center state |

`processing_jobs` gains `priority`, `progress`, `checkpoint_json` (nullable)
for long jobs. Existing jobs default to priority 0 and no checkpoint.

Collections stay as they are. Spaces are a separate, richer concept; a
collection is converted to a Space only if the user chooses to.

Assistant tables (conversations, messages, citations) are added in the
assistant phase, not in schema 3.

## Upgrade procedure (Drift `onUpgrade` from 2 to 3)

1. **Snapshot.** Before opening the migration transaction, if free space is
   at least twice the database size, run `VACUUM INTO
   '<app_support>/snapshots/pre_v3.sqlite'`. Record the snapshot path in
   `app_settings`. If space is insufficient, continue without a snapshot and
   record that fact (the migration is additive, so it remains safe).
2. **Transaction.** Inside one transaction:
   - `ALTER TABLE screenshots ADD COLUMN …` for each new column, guarded by
     a `PRAGMA table_info` check so a re-run skips columns already present
     (idempotent).
   - `UPDATE screenshots SET memory_type = 'screenshot' WHERE memory_type IS NULL`.
   - `UPDATE screenshots SET mime_type = …` from the stored file extension.
   - `CREATE TABLE IF NOT EXISTS` / `CREATE INDEX IF NOT EXISTS` for every
     new table and index.
   - Add the new `processing_jobs` columns, guarded the same way.
3. **Verify** (still inside the transaction): row counts of every legacy
   table equal their pre-migration counts captured in step 2's first
   statement; `PRAGMA foreign_key_check` returns no rows; every
   `memory_type` is set. Any mismatch throws and rolls back.
4. **Commit**, then `PRAGMA user_version = 3` (Drift does this after
   `onUpgrade` returns).
5. **After commit:** enqueue chunking jobs for every memory with text
   (cheap, no model). Embedding jobs are enqueued only once a text model is
   installed (Phase 2).
6. **Snapshot retention:** keep `pre_v3.sqlite` until the app has started
   successfully three times on schema 3, then delete it. Settings shows the
   snapshot and offers "restore previous version" while it exists.

### Interruption

- Killed before commit: SQLite rolls back; `user_version` is still 2; the
  next start re-runs the migration from scratch (guards make it safe).
- Killed after commit, before `user_version` is written: the next start
   re-runs `onUpgrade`; every step is guarded, so it converges.
- The first-time-creation path already uses `IF NOT EXISTS` everywhere (see
  `AppDatabase.migration`), so a fresh install and an upgraded install end
  with the same schema. A test asserts this (schema diff of both paths).

## Backup format

Backup schema goes from 2 to 3. Restoring a version 1 or 2 backup fills new
columns with the same defaults as the migration (`memory_type =
'screenshot'`), exactly like the existing `titleLocked` handling. Chunks and
embeddings are derived data: they are not exported; they are regenerated
after restore.

## Tests required before Phase 1 is "done"

1. Fixture databases at schema 1 and schema 2 (generated by the existing
   code, committed under `test/fixtures/db/`) upgrade to 3 with identical
   legacy row counts and identical values in every legacy column.
2. A migration interrupted after each step (simulated by throwing) leaves a
   database that the next open completes correctly.
3. Fresh-install schema equals upgraded schema (compare `sqlite_master`).
4. Notification ids and reminder deep links still resolve after upgrade.
5. Version 1, 2 and 3 backups restore into schema 3.
6. On-device: install the current release, import the 12 test screenshots,
   upgrade to the schema 3 build, verify counts, titles, reminders and a
   notification tap.

## Non-goals

- No change to `applicationId`, signing or the database file name.
- No deletion or recreation of the database.
- No dependency on any ML model during migration.
