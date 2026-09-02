# Module: Settings

> Folder: `docs/vault/Modules/`

**File:** `lib/features/settings/settings_page.dart`
**Repository:** `lib/data/repositories/settings_repository.dart`

## Purpose
User-controlled scan accuracy threshold and optional custom `.tflite` model upload
(plus optional labels `.txt`), hot-swappable without restart.

## Entry point
Gear icon (`Icons.settings_outlined`) in the shell AppBar actions → pushes `SettingsPage(dependencies)`.

## What it does
- **Threshold slider** 0.50–1.00 (50 divisions), persisted to SharedPreferences key
  `confidence_threshold`; live % readout. Wired into `scan_page._resolveDisease`.
- **Upload model (.tflite)**: pick → `InferenceService.loadFromFile` (validates by building the
  interpreter) → `SettingsRepository.saveCustomModel` (copies file into app documents dir,
  persists path) → swap `AppDependencies.inference` (dispose old).
- **Reset to default**: delete copied files, clear prefs, reload bundled engine.
- **Model requirements** amber note: tflite classification format, square input, label ordering,
  and the "unidentified" warning.

## Contracts
- `SettingsRepository extends ChangeNotifier`; page wraps UI in `AnimatedBuilder(animation: settings)`.
- `_busy` flag disables all controls while async upload/load runs.
- Failed loads keep the previous engine (no destructive swap).

## Relationships
- Depends on `InferenceService` (static loaders) and `AppDependencies` (to mutate `inference`).
- Feeds `scan_page` via `dependencies.settings.confidenceThreshold`.
- `main.dart` calls `SettingsRepository.init()` and restores persisted model at startup.