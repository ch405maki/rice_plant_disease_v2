# API Specification — AgriGuard

There is **no server/API**; all behaviour is on-device. This document captures the only
external contracts the app depends on.

## External integrations

| Integration | Invocation points | Notes |
| --- | --- | --- |
| `tflite_flutter` `Interpreter` | `InferenceService` (load / predict) | Bundled asset via `fromAsset`, user file via `fromFile`; native libs bundled for all 4 ABIs |
| `image_picker` | `ImageService.pick` | Camera or gallery source; returns a cached file path |
| `file_picker` | `SettingsPage` | `.tflite` and `.txt` file selection |
| `pdf` + `open_file` | `SavedDetailPage._exportAsPdf` | Generates a temp PDF, opens it on device |
| `path_provider` | repo init + Settings file copies | App documents dir for Hive + uploaded files |

## Internal "contracts" (typed, library-local)

### `InferenceService`
- `Future<InferenceService?> load({modelAsset, labelsAsset, labelsFilePath?})` — bundled default engine, nullable on failure.
- `Future<InferenceService?> loadFromFile({required File modelFile, File? labelsFile})` — user model engine, nullable on failure.
- `ScanResult predict(img.Image image)` → `{label, confidence}` (top-1).
- `int get labelCount`.

### `ScanResult`
- `label` = cleaned class name (index prefix removed), `confidence` = `0..1` double.

### `DiseaseRepository`
- `all`, `fallback` (id 0 "Fail to recognise"), `byLabel(String)` → match on `modelLabel`.

### `SettingsRepository`
- `confidenceThreshold` (double), `customModelPath`, `customLabelsPath`, `hasCustomModel`.
- `saveCustomModel(String)`, `saveCustomLabels(String)`, `resetCustomModel()`, `setConfidenceThreshold(double)`.

### `ScanRepository`
- `scans`, `add(SavedScan)`, `deleteAt(int)`, `listenable` (`ValueListenable<Box<SavedScan>>`).