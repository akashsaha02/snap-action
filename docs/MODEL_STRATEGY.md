# Model strategy

Status: **candidates selected for evaluation; nothing beyond ML Kit OCR is
integrated yet.** Every size, speed and licence below marked *to verify*
must be measured or read from the official model card before a model is
enabled. Sizes quoted from third-party articles are planning figures only.

## Principles

1. Imported content never leaves the device. Models are bundled or
   downloaded explicitly by the user, from an official source, with size,
   licence and purpose shown first.
2. One inference runtime where practical. Each extra native runtime adds
   APK size, ABI builds and failure modes.
3. A model is enabled by default only after it passes the retrieval
   evaluation below and the device benchmark on at least one low-end and one
   mid-range phone.
4. Devices that cannot run a model keep full OCR, keyword search,
   organisation, reminders and actions. Unsupported features are hidden or
   explained, never faked.
5. Vectors are stored with `model_id`, `model_version` and `space_id`.
   Vectors from different models are never compared.

## Capability tiers

Decided by running a short test inference at install time, not by reading
RAM size alone.

| Tier | Typical device | Features |
| --- | --- | --- |
| Base | any supported Android phone | ML Kit OCR, FTS5 keyword search, entities, actions, reminders |
| Semantic | about 3 GB RAM and up, arm64 | one text-embedding model, hybrid search, related memories |
| Assistant | flagship phones (8 GB RAM, NPU or recent GPU) | optional local LLM for grounded answers; or Gemini Nano through ML Kit GenAI where AICore offers it |

## Components and candidates

### OCR (in use)

- **ML Kit Text Recognition v2, bundled Latin model.** Verified offline on
  device (`TEST_REPORT.md`). Release builds need the R8 keep rules in
  `android/app/proguard-rules.pro`.
- **Non-Latin scripts:** ML Kit offers Chinese, Devanagari, Japanese and
  Korean models; **no Bengali**. For Bengali, evaluate Tesseract with the
  `ben` traineddata (Apache-2.0, downloaded on demand) or a PaddleOCR
  multilingual model (*to verify* Bengali coverage and licence).

### Text embeddings (Phase 2, V1)

| Candidate | Languages | Dimensions | Licence | Size (planning) |
| --- | --- | --- | --- | --- |
| all-MiniLM-L6-v2 | English | 384 | Apache-2.0 | about 22 MB int8 ONNX (*to verify*) |
| multilingual-e5-small | about 100, incl. Bengali | 384 | MIT | larger than MiniLM; third-party figures disagree (*measure*) |
| bge-small-en-v1.5 | English | 384 | MIT | about 33 MB int8 (*to verify*) |
| EmbeddingGemma (300M) / EmbeddingGemma 2 | multilingual; v2 adds image and audio | 768 (MRL truncation to smaller sizes) | Gemma terms (*read before adopting*) | about 180 MB LiteRT for 300M; 165 MB for the v2 text model (third-party figures) |

**Recommendation for the first evaluation:** all-MiniLM-L6-v2 as the small
English baseline and multilingual-e5-small as the multilingual option, both
on ONNX Runtime. Keep EmbeddingGemma 2 as the candidate for the later
cross-modal phase, because one shared text-image-audio space would remove
the need for a separate CLIP model; its licence and size decide whether it
can replace both.

Details that must be fixed per model before indexing: tokenizer (WordPiece
for MiniLM/BGE, SentencePiece for E5 multilingual), pooling (mean),
L2 normalisation, query/document prefixes (`query: ` / `passage: ` for E5),
maximum sequence length, and quantisation.

### Runtime

| Option | Pros | Cons |
| --- | --- | --- |
| ONNX Runtime, Android AAR called through the existing Kotlin platform channel | mature, maintained by Microsoft; runs every candidate above except the LiteRT-LM builds | adds about 10 to 15 MB per ABI (*measure*); tokenizer must be implemented |
| ONNX Runtime through a pub.dev FFI package (for example `onnx_runtime_dart`) | no Kotlin glue; some include verified tokenizers | young packages; pin versions and audit before use |
| LiteRT (TFLite) / LiteRT-LM | Google's path for EmbeddingGemma and Gemma LLMs; NPU support on some phones | fewer ready-made sentence-transformer conversions |

**Decision for Phase 2:** prototype with ONNX Runtime behind a small
`EmbeddingService` interface (Dart) with a native implementation, so the
runtime can be swapped without touching retrieval code. Revisit when the
assistant phase chooses its LLM runtime, to avoid shipping two runtimes.

### Speech (V2)

whisper.cpp (MIT) with quantised Whisper tiny or base (weights MIT).
Measure real-time factor, peak RAM and accuracy on mid-range phones before
choosing the default size.

### Local generation (V2)

- **Gemini Nano through ML Kit GenAI (AICore):** no download, but only on
  supported phones (Pixel 9 and later, some 2025-2026 flagships), quota
  limited, foreground only, APIs in beta. Good optional path where present.
- **LiteRT-LM with a small Gemma model:** works on more phones, but costs a
  1 to 3 GB download (*measure*) and Gemma terms apply.
- Never auto-download multi-gigabyte models. The assistant is optional;
  extractive answers with source cards work without any LLM.

### Visual retrieval (V3)

Text-to-image search needs a jointly trained image-text model in one
embedding space: SigLIP (Apache-2.0), MobileCLIP (*licence to verify*) or
EmbeddingGemma 2's vision variant. No face recognition and no sensitive
attribute inference.

## Model manifest (stored in `model_registry` and shipped as JSON)

```json
{
  "model_id": "all-minilm-l6-v2",
  "version": "onnx-int8-1",
  "type": "text_embedding",
  "source_url": "<official Hugging Face file URL>",
  "sha256": "<verified hash>",
  "size_bytes": 0,
  "runtime": "onnxruntime-android",
  "inputs": "input_ids, attention_mask, token_type_ids (int64, max 256)",
  "outputs": "last_hidden_state; mean-pooled, L2-normalised",
  "tokenizer": "wordpiece, uncased, vocab.txt sha256 <hash>",
  "dimension": 384,
  "embedding_space_id": "minilm-l6-v2",
  "min_requirements": { "abi": "arm64-v8a", "ram_mb": 3000 },
  "license": "Apache-2.0",
  "redistribution": "allowed with notice"
}
```

The app verifies the SHA-256 before loading, never executes code from a
model archive, and pins supported versions in the shipped manifest.

## Retrieval evaluation (gate for enabling semantic search)

1. **Corpus:** extend `test/fixtures/ocr_samples.dart` into a labelled set
   of about 200 synthetic memories: receipts, boarding passes, product pages,
   lecture notes, chats, Wi-Fi cards, PDFs (Phase 3) and unrelated
   distractors. No personal data.
2. **Queries:** about 100 labelled queries with expected memory ids,
   including paraphrases ("affordable headphones for studying" for a page
   saying "Bluetooth earbuds, EUR 29.99"), exact constraints ("under EUR
   100", "receipts from October"), negatives with no correct answer, and a
   few multilingual cases.
3. **Metrics:** Recall@5, Recall@10, MRR and nDCG@10 for keyword-only,
   semantic-only and hybrid (reciprocal rank fusion) retrieval, run as a
   host test so regressions fail CI.
4. **Gate:** hybrid must beat keyword-only on Recall@10 and MRR on the
   paraphrase subset without losing on exact-match queries. Thresholds are
   set from the measured baseline, not chosen in advance.

## Device benchmark protocol

Record device, Android version, RAM, ABI, model id and version. Measure
model load time, per-chunk embedding time, peak RAM, index build time and
query latency at 100, 500, 1,000 and 5,000 memories (the existing
`integration_test/large_library_test.dart` harness extends naturally), and
battery drain for a 1,000-memory index build. Publish results in
`TEST_REPORT.md`; unmeasured devices are listed as not measured.

## Sources consulted (2026-11-19)

- EmbeddingGemma on device with LiteRT: https://huggingface.co/litert-community/embeddinggemma-300m
- EmbeddingGemma 2 LiteRT-LM builds: https://huggingface.co/litert-community/embeddinggemma-2-740m-litert-lm
- EmbeddingGemma 2 phone latency review: https://thegenaimagazine.com/embeddinggemma-2-on-device-phone-latency-benchmarks
- Sentence embeddings on Android with ONNX Runtime: https://github.com/shubham0204/Sentence-Embeddings-Android
- `onnx_runtime_dart` package: https://pub.dev/packages/onnx_runtime_dart
- On-device embeddings for mobile search (sizes, third-party): https://blog.michaelsam94.com/on-device-embeddings-mobile-search/
- ML Kit GenAI and Gemini Nano: https://www.infoq.com/news/2025/06/google-mlkit-genai-gemini-nano
- Android on-device inference (Android Developers Blog): https://android-developers.googleblog.com/2026/07/android-on-device-inference.html
- PDFium-based Flutter PDF: https://pub.dev/documentation/pdfrx/2.6.4/
