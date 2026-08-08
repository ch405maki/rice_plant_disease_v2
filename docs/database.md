# Database — AgriGuard

This app has **no remote database**. Persistence is entirely on-device.

## Layers

| Store | Library | Purpose | Key location |
|-------|---------|---------|--------------|
| Hive box `plantDiseases` | `hive` + `hive_flutter` | Saved scans (`SavedScan<T>`) | `main.dart` init; `ScanRepository` |
| SharedPreferences | `shared_preferences` | Scan settings + model upload persistence | `SettingsRepository` |
| Filesystem (app documents dir) | `dart:io` / `path_provider` | Uploaded `.tflite` model + `labels.txt` copies | `SettingsRepository._copyIntoDocs` |

## Hive (`saved_scan.dart`)

- `SavedScan` fields: `plantName`, `causes`, `symptoms`, `treatment`, `imageBytes` (`Uint8List`), `dateCreated` (ISO-8601 string).
- Adapter `SavedScanAdapter` in `saved_scan.g.dart` is **hand-maintained** (fields written in constructor order) — keep the type id and field order in sync if the model changes.
- Box opened once in `main()`: `Hive.openBox<SavedScan>(AppConstants.hiveBoxName)`.

## SharedPreferences keys (`SettingsRepository`)

| Key | Type | Meaning |
| --- | --- | --- |
| `confidence_threshold` | double | Slider value 0.50–1.00, default 0.95 |
| `custom_model_path` | string | Absolute path of uploaded `.tflite` in documents dir |
| `custom_labels_path` | string | Absolute path of uploaded `.txt` labels in documents dir |

- Values are loaded in `SettingsRepository.init()` (called in `main()`) and exposed via `ChangeNotifier`.
- On reset, the copied files are deleted from disk and keys removed.

## Filesystem

- Uploaded files are **copied** into `getApplicationDocumentsDirectory()` with unique names
  (`agriguard_model_<epochMs>.tflite`, `custom_labels_<epochMs>.txt`) so they survive app restarts and remain resolvable by `Interpreter.fromFile`.

## Rationale

- No auth or server sync (capstone scope); PDF export writes only a temporary file under `getTemporaryDirectory()`.