# Implementation roadmap (RecallOS programme)

Each phase ends only when its gate is met with evidence: format, analyze,
tests, a release build, and the listed device checks recorded in
`TEST_REPORT.md`. Untested work is not marked done. Estimates are rough
single-developer ranges, not commitments; native integration and device
testing often take longer.

| Phase | Deliverable | Gate | Estimate |
| --- | --- | --- | --- |
| **0 Audit** (done) | baseline, audit, product spec, migration plan, model strategy, security doc, feature flags | docs reviewed by the owner; open decisions answered | — |
| **1 Foundation** | schema 3 migration; `Memories` model; feature-flagged navigation; Capture Hub (photo picker, share, note, paste, link); unified library with type filters; WorkManager host for jobs; analysis on a background isolate | migration tests 1-6 in `MIGRATION_PLAN.md` pass; upgrade verified on device with the 12-screenshot library; existing 241 tests still pass | 1.5-2.5 weeks |
| **2 Semantic Recall** | Model Center; one embedding model (ONNX Runtime); chunking; vector store; hybrid retrieval (FTS + cosine, reciprocal rank fusion); structured query parser; evaluation harness | hybrid beats keyword-only on the labelled set; benchmarks at 100-5,000 memories on emulator and one physical phone | 2-3 weeks |
| **3 Documents** | PDF import (pdfrx/PDFium), text layer extraction, OCR of image-only pages, page-aware chunks, viewer with page navigation and highlighted citations | digital and scanned PDF searchable offline; citations open the right page; corrupt and password PDFs fail gracefully | 1.5-2 weeks |
| **4 Connections** | normalised entities across memories; explainable related memories; Spaces; timeline | relationships show their reason; Spaces CRUD and scoped search tested; timeline never invents dates | 1.5-2 weeks |
| **5 Voice** (V2) | record and import audio; whisper.cpp transcription; timestamped transcript search; playback at match | transcription speed and accuracy measured on a mid-range phone; no recording without visible control | 2-3 weeks |
| **6 Assistant** (V2) | device capability check; local RAG with citations validated against retrieved ids; extractive fallback | no citation outside the retrieved set in the evaluation; works or degrades cleanly with no LLM | 2-4 weeks |
| **7 Visual / video** (V3) | shared image-text embedding model; reference-image and text-to-image search; keyframe sampling, frame OCR, timestamps | evaluation on a labelled image set; thermal and battery limits respected | 4-8 weeks |
| **8 Hardening** | security review, accessibility pass, migration regression, release keystore and Play App Signing, store listing | release checklist complete; physical-device pass | 1-2 weeks |

## Feature flags

Defined in `lib/core/services/feature_flags.dart`. Each flag defaults to
off, can be turned on per device (stored in `app_settings`, so it is
private and survives restarts), and must not change data on its own: data
migrations happen through schema versions, never through flags.

| Flag | Phase | Controls |
| --- | --- | --- |
| `unifiedMemories` | 1 | new memory types in import and library |
| `newNavigation` | 1 | Home / Memories / Recall / Connections / Profile |
| `semanticSearch` | 2 | hybrid retrieval in Search (falls back to keyword) |
| `modelCenter` | 2 | Model Center in Settings |
| `pdfImport` | 3 | PDF capture and viewer |
| `spaces` | 4 | Spaces, related memories, timeline |

## Workflow per phase

1. Re-read the relevant code; write acceptance tests first where practical.
2. Implement in small commits; run format, analyze and the full test suite
   after each meaningful change.
3. Build the release APK; check the change on the emulator (and on a phone
   for gates marked "device").
4. Update `TASKS.md`, `TEST_REPORT.md` (measured numbers only) and
   `CHANGELOG.md`.
5. Proceed only when the gate is met. If a dependency or model fails,
   record the error and keep the working fallback.
