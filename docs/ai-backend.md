# AI Backend — On‑device TensorFlow Lite

The "AI backend" is a bundled mobile classifier, not a server. Implemented in
`lib/data/services/inference_service.dart`.

## Model

- File: `assets/model/rice_disease_v1.tflite`
- Labels: `assets/model/labels.txt` (6 classes, indexed):
  0 `BACTERIAL BLIGHT`, 1 `BROWN SPOT`, 2 `LEAF BLAST`, 3 `NORMAL RICE PLANT`,
  4 `SHEALTH BLIGHT`, 5 `TUNGRO`.

## Loading paths

1. **Bundled**: `InferenceService.load()` → `Interpreter.fromAsset(modelAsset)`.
   - **Asset-path quirk:** `tflite_flutter` `0.9.1` `fromAsset` *prepends* `assets/`, so
     `modelAsset = 'model/rice_disease_v1.tflite'` (no `assets/` prefix), while
     `FileUtil.loadLabels()` does *not*, so `labelsAsset = 'assets/model/labels.txt'`.
2. **User-uploaded**: `InferenceService.loadFromFile()` → `Interpreter.fromFile(File)`
   (a static factory, not `async`).
   - Labels come from the user's `.txt` when provided, else fall back to the bundled list.

## Preprocessing contract

- Input tensor shape/type is read from the interpreter at load time.
- Pipeline (`_preProcessInput`): center-crop to square → resize to `inputShape[1]` ×
  `inputShape[1]` (bilinear) → `NormalizeOp(127.5, 127.5)`.
- Output: `TensorLabel` top‑1 argmax over the label list.

## Failure behaviour

- Any load error returns `null` (never throws) so callers degrade gracefully:
  - startup (`main.dart`) → falls back to the bundled engine;
  - Settings upload → keeps the current engine and shows a snackbar.
- Native lib: `DynamicLibrary.open('libtensorflowlite_c.so')`; jniLibs bundled for all 4 ABIs.
  Not a source of startup failures currently.

## Model swap semantics

- `AppDependencies.inference` is a **mutable** field hot‑swapped after upload; the old engine is
  `dispose()`d. Startup restores the last persisted custom model.
- Persisted custom models that fail to load at startup are ignored (bundled engine used).