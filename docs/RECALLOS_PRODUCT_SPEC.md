# RecallOS product specification (adapted to this repository)

Source brief: "RecallOS — Product & Engineering Specification" (Cursor
agent brief, 15 pages). This version adapts it to the real codebase
audited in `REPOSITORY_AUDIT.md`. Where the brief and earlier owner
decisions conflict, the conflict is listed under *Open decisions* and the
current behaviour stays until the owner decides.

## Positioning

A private personal search engine for information the user intentionally
captures: capture anything, understand it on the device, connect related
items, retrieve evidence with sources, and turn it into action. Not a
general chatbot and not a continuous recorder.

"RecallOS" is used here as the programme name. The product name in the app
stays **Snaptiq** unless the owner decides otherwise.

## Non-negotiable constraints

- Android first; keep the Flutter app; no backend, account, cloud storage,
  remote vector database, paid AI API, cloud OCR or transcription, ads or
  default telemetry.
- Imported personal content never goes to a remote AI service. Optional
  model downloads are disclosed (size, licence, purpose) and explicit.
- Import only through system pickers, share intents and visible in-app
  capture. No accessibility scraping, screen monitoring, background
  microphone or broad file access.
- Phones that cannot run models keep OCR, keyword search, organisation,
  reminders and actions. No mock intelligence, random vectors or invented
  statistics.
- Existing data, package id, signing and backups are preserved
  (`MIGRATION_PLAN.md`).

## Release boundaries

| Release | Scope |
| --- | --- |
| **V1** | everything Snaptiq does today; unified memories (screenshot, image, document, note, link); PDF and note import; offline OCR; hybrid keyword + semantic retrieval with source links; related memories; Spaces; timeline; Model Center |
| **V2** | offline voice recording and transcription; source-grounded local assistant; focused knowledge graph |
| **V3** | cross-modal image search; video indexing; advanced model options |

The first milestone after the foundation is **semantic search plus PDF
intelligence**, not a chatbot.

## V1 acceptance criteria

Each criterion needs a test (host or integration) and, where marked,
on-device evidence in `TEST_REPORT.md`.

1. **Upgrade safety (device).** A phone running the current release keeps
   every screenshot, OCR text, correction, tag, collection, note, reminder,
   wishlist item and setting after installing V1. Notification taps still
   open the right item.
2. **Unified library.** Screenshots, PDFs, notes and links appear in one
   library with type filters, the existing bulk actions, and the existing
   detail actions.
3. **PDF (device).** A digital PDF and a scanned PDF are searchable
   offline; a search hit opens the document at the cited page with the
   passage highlighted.
4. **Notes and links.** A note can be written, edited, tagged and
   searched; a shared URL is saved as a link memory without fetching the
   page.
5. **Hybrid retrieval.** On the labelled evaluation set, hybrid search
   beats keyword-only on Recall@10 and MRR for paraphrased queries and does
   not lose on exact queries (`MODEL_STRATEGY.md`).
6. **Structured queries.** "receipts from October", "products under EUR
   100" and "PDFs about computer vision" apply exact date, amount and type
   filters; amounts compare in minor units within one currency only.
7. **Model Center.** Shows every installed model with source, size,
   licence and purpose; installs only after explicit consent; verifies the
   hash; can remove a model; search keeps working with no model installed.
8. **Related memories and Spaces.** A detail screen lists related
   memories with the reason (shared entity, same Space, semantic
   neighbour). Spaces can be created, filled, searched within, and deleted
   without deleting their memories.
9. **Timeline.** Groups memories by day, week or month using a stated
   date type (captured, imported or user-set event date); never invents a
   date.
10. **Offline (device).** All of the above works in airplane mode after
    models are installed.
11. **Deletion.** Deleting any memory removes all derived rows (chunks,
    embeddings, relationships, FTS) and cancels its reminders.

## Open decisions (owner)

1. **Product name:** keep Snaptiq (recommended) or rename to RecallOS.
2. **Visual tokens:** keep the approved Acid Pop kit (recommended) instead
   of the brief's earlier violet/teal palette.
3. **Navigation:** move to Home / Memories / Recall / Connections / Profile
   (recommended, behind a feature flag) with Reminders reachable from Home
   and Collections inside Memories.
4. **Model downloads:** adding model downloads means adding the `INTERNET`
   permission for that flow only. Alternatively, bundle one small embedding
   model in the APK (about +25 MB for MiniLM, to be measured) and keep the
   app permission-free.

## Commercial direction (not in V1)

No billing in the first release. Hypothesis for later: free core
(screenshots, OCR, keyword and basic semantic search, notes, reminders) and
a one-time unlock for advanced documents, voice, larger models and the
graph. Export and deletion are never paywalled.
