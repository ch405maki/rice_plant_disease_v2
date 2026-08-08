# Codebase Analysis

> What the code actually does today — module by module, with cross-references.
> Derived from the implementation. See also [[detailed-documentation]] and
> [[technical-debt]].

## Inventory

- **Dart sources**: 28 under `lib/` (27 Dart + 1 generated Hive adapter `*.g.dart`)
- **Tests**: 4 files under `test/` (`data/disease_repository_test.dart`,
  `data/scan_repository_test.dart`, `widgets/primary_button_test.dart`,
  `widgets/result_view_test.dart`) — all pass; `flutter analyze` is clean.
- **Assets**: `assets/model/` (model + labels), `assets/disease_data.json`,
  `assets/images/`, fonts (incl. 23 MB `ArialUnicodeMS.ttf` for PDF export).

## Module-by-module

### `lib/main.dart` — bootstrap
- Awaits in order: `Hive.init` (docs dir) → `registerAdapter(SavedScanAdapter())` →
  open box `plantDiseases` → `SettingsRepository.init()` → load inference (persisted
  custom model via `loadFromFile` if present, else bundled `load`) →
  `DiseaseRepository.load()` → `ScanRepository` → `ImageService`.
- Builds a **non-const** `AppDependencies` and calls `runApp(MyApp(...))`.
- `MyApp.title` is `'AgriGuard'`; `home` = `SplashScreen(dependencies)`.

### `lib/app_dependencies.dart` — DI container
- `diseases`, `scans`, `imageService`, `settings` are `final`; `inference` is a **mutable**
  `InferenceService?` so the app-dependencies engine can be hot-swapped after upload.

### `lib/core/constants/app_constants.dart`
- Palette: `primaryColor` 0xff296e48, `panelColor` 0xFFA7C1B4, `blackColor` Colors.black54.
- Inference: `confidenceThreshold` 0.95 (factory default; runtime value lives in
  `SettingsRepository`), `modelAsset` `'model/rice_disease_v1.tflite'` (no `assets/` prefix —
  `Interpreter.fromAsset` prepends it), `labelsAsset` `'assets/model/labels.txt'`,
  `diseaseDataAsset` `'assets/disease_data.json'`.
- Persistence: prefs key `'repeat'` (onboarding), Hive box `'plantDiseases'`; onboarding copy.

### `lib/core/theme/app_styles.dart` + `lib/core/utils/formatters.dart`
- Text/typography styles; `formatAccuracy`, `formatTimestamp` helpers.

### `lib/data/models/*`
- `disease.dart` — unified catalog model: `id, name, modelLabel?, imageUrl?, description,
  causes, symptoms, treatment`; `Disease.fromJson`.
- `saved_scan.dart` + `saved_scan.g.dart` — Hive entity `SavedScan` (`plantName`, `causes`,
  `symptoms`, `treatment`, `imageBytes` Uint8List?, `dateCreated` ISO-8601) +
  hand-maintained `SavedScanAdapter` (typeId 0).
- `scan_result.dart` — `{label, confidence}`.

### `lib/data/repositories/*`
- `disease_repository.dart` — loads `assets/disease_data.json`; `all`, `fallback` (id 0 =
  "Fail to recognise", `modelName == null`), `byLabel` (case-insensitive), `matchByLabel`.
- `scan_repository.dart` — thin wrapper over `Box<SavedScan>`: `scans`, `listenable`,
  `add`, `deleteAt`.
- `settings_repository.dart` — `ChangeNotifier` over SharedPreferences keys
  `confidence_threshold` / `custom_model_path` / `custom_labels_path`; `confidenceThreshold`,
  `customModelPath`, `customLabelsPath`, `hasCustomModel`; `setConfidenceThreshold` (0.50–1.00),
  `saveCustomModel`/`saveCustomLabels` (copy into app docs dir), `resetCustomModel`
  (delete copied files + clear keys).

### `lib/data/services/*`
- `inference_service.dart` — `load()` (bundled asset) and `loadFromPath(modelFile,
  labelsFile)` (user file). Both return `null` on failure, never throw. `predict(img)` via
  crop → resize `inputShape[1]` → `NormalizeOp(127.5,127.5)` → top‑1. `labelCount`, `dispose`.
  `_loadingLabels` strips the leading `"0 "` index.
- `image_service.dart` — `pick(source)` via `image_picker`; `decode(file)` runs `img.decodeImage`
  in `compute` (off the UI isolate).

### `lib/features/onboarding/*`
- `splash_screen.dart` — 3 s splash → `pushReplacement` to onboarding (first run, `'repeat'`
  null) or `RootPage`.
- `onboarding_screen.dart` — 3-page intro (skip + next), sets `'repeat' = true`.

### `lib/features/shell/root_page.dart`
- `IndexedStack` + fixed `BottomNavigationBar`, 4 tabs: Home / Scan / Saved / About.
- Title = active tab label (default-txt 24); **gear** action pushes `SettingsPage`.

### `lib/features/home/*`
- `home_page.dart` — `ListView` + `SafeArea`, banner (`assets/images/banner.jpg`, radius 12,
  height 160), "Healthy Rice plant" section (label `NORMAL RICE PLANT`) + "Rice Plant
  Diseases" section.
- `widgets/plant_card.dart` — white rounded card (radius 14), 84×84 rounded thumb (radius 12),
  name + cleaned 3-line description snippet.
- `disease_dialog.dart` — `Dialog` (radius 14, max height 75%) with full-bleed 200 px cover
  image + dark gradient + top-close; disease **name in normal font** (primary bold);
  scrollable cleaned description. (`detail_page.dart` was deleted.)

### `lib/features/scan/*`
- `scan_chooser_page.dart` — "Camera" / "Pick from Gallery" full-width `PrimaryButton`s.
- `scan_page.dart` — `enum _ScanStatus { idle, analyzing, success, error }`; `_pickAndAnalyze`
  → pick, decode (off-isolate), **≥3 s analysing animation** (`minDuration` `Duration(milliseconds: 3000)`),
  `inference.predict` → `_resolveDisease` (threshold from `settings.confidenceThreshold`,
  then `diseases.byLabel` or `fallback`) → `ResultView` (recognised, `modelName != null`) or
  `UnrecognizedPanel`. `_saveScan` guarded by `_saved`; unrecognised scans store
  `plantName: 'Unidentified'` + empty fields.
- `widgets/analyzing_overlay.dart` — 2 px glow bar over the full-screen dark photo.
- `widgets/result_view.dart` — hero card (92×92 rounded photo, name, accuracy chip) + sections
  Description/Symptoms/Control-Interventions (bullets stripped, bold green labels).
- `widgets/unrecognized_panel.dart` — full-height panel: hero card ("Unidentified" + chip
  "Model confidence: X%"), tips list, "Try again"/"Another photo" buttons.

### `lib/features/saved/*`
- `saved_page.dart` — `ValueListenableBuilder<Box<SavedScan>>`; white rounded cards (radius 14)
  with 52×52 thumbnails, delete dialog (radius 16, red delete button, aligned end), tap →
  `SavedDetailPage`.
- `saved_detail_page.dart` — result-style hero (photo, name, `calendar_today` date chip),
  sections with `_cleanText` (strip bullets), print button → 1-page PDF
  (`ArialUnicodeMS.ttf` fallback) → `getTemporaryDirectory()/plant_description.pdf` → dialog
  with "OK"/"Open File" (`open_file`).

### `lib/features/settings/settings_page.dart`
- Threshold slider (`0.50–1.00`, 50 divisions) with live %; upload `.tflite`
  (validate-with-reload then swap `AppDependencies.inference`), optional `.txt` labels
  (copy + reload engine), **Reset to default model**; amber "Model requirements" note.

### `lib/features/about/about_page.dart`
- "Work in progress" placeholder with `Icons.info_outline` (matches tab icon).

### `lib/widgets/*`
- `primary_button.dart`, `circle_icon_button.dart` — shared labeled/icon + round-icon buttons.

## Tests

`test/` has 4 real test files: `disease_repository_test.dart` (JSON→catalog, fallback,
match), `scan_repository_test.dart` (Hive CRUD), `primary_button_test.dart`,
`result_view_test.dart` (renders disease+sections). No test covers `InferenceService`
(native lib) or `SettingsRepository` (platform plugin).

## Verification commands

```powershell
flutter pub get
flutter analyze
flutter test
```

## Cross-references

- Data flow diagrams: [[architecture]]
- Per-module detail: [[detailed-documentation]]
- Things to fix: [[technical-debt]]