# Architecture Summary

> High-level picture of how `agri_guard` is structured. Derived from the
> implementation. Details in [[detailed-documentation]] and [[codebase-analysis]].

## Layers

The app is a single-package Flutter app using plain `StatefulWidget`/`setState` with a
small hand-rolled `AppDependencies` container for testability — no third-party state-management
or DI library. The code organises into four folders plus a shared widget folder:

```
lib/
  main.dart                     # Bootstrap: Hive init, settings init, model restore, runApp
  app_dependencies.dart         # AppDependencies container (repo/services; mutable inference)
  core/
    constants/app_constants.dart   # palette, asset paths, default threshold, copy
    theme/app_styles.dart          # font + text styles
    utils/formatters.dart          # formatAccuracy, formatTimestamp
  data/
    models/                      # disease.dart, saved_scan.dart (+ .g.dart adapter), scan_result.dart
    repositories/                # disease_repository, scan_repository, settings_repository
    services/                    # inference_service, image_service
  features/                     # feature-scoped screens, one folder per feature
    onboarding/  shell/  home/  scan/  saved/  settings/  about/
  widgets/                      # shared UI: primary_button, circle_icon_button
```

## Runtime flow (startup)

1. `main()` (`lib/main.dart`) initialises Hive against the documents dir, registers
   `SavedScanAdapter`, opens box `'plantDiseases'`.
2. `SettingsRepository.init()` loads the persisted threshold + custom model/labels paths.
3. Model loading (`_loadPersistedOrBundledModel`): restore a previously uploaded `.tflite`
   when present and loadable, otherwise the bundled `assets/model/rice_disease_v1.tflite`.
4. Builds a **non-const** `AppDependencies` (awaits `DiseaseRepository.load()` and the
   inference engine first) and calls `runApp`.
5. `MyApp` → `SplashScreen`, which after ~3 s reads SharedPreferences `'repeat'`
   and `pushReplacement`s to `OnboardingScreen` (first run, sets `'repeat' = true`)
   or `RootPage`.
6. `RootPage` is an `IndexedStack` tab shell: Home / Scan / Saved / About, with a gear
   action that opens `SettingsPage`.

## Runtime flow (scanning) — the core feature

```
ScanChooserPage ──(ImageSource.camera|gallery)──▶ ScanPage
                                                  │ initState → _pickAndAnalyze
                                                  ▼
                                   ImageService.pick      (cancel → pop)
                                                  │
                                                  ▼
                        ImageService.decode (off-isolate via compute)
                                                  │
                                                  ▼  (>=3 s analysing animation)
                            InferenceService.predict(decoded)
                                   └─ preprocess (crop → resize → normalize)
                                      → interpreter.run → top {label, score}
                                                  │
                                                  ▼
               confidence >= settings.confidenceThreshold ?
                       │ yes                          │ no
                       ▼                              ▼
           DiseaseRepository.byLabel(label)  disease fallback (id 0)
                       │ (null → fallback)
                       ▼
        ResultView (recognised) OR UnrecognizedPanel (unidentified)
        user taps save (guarded once) → ScanRepository.add(SavedScan) → Hive
```

The confidence threshold is **runtime-configurable** (0.50–1.00, default 0.95) and read from
`SettingsRepository` at scan time, not from a constant.

## Data ownership

| Concern | Owner | Notes |
|---------|-------|-------|
| Disease reference content | `assets/disease_data.json` → `DiseaseRepository` | 7 entries; id 0 = "Fail to recognise" fallback (`modelLabel: null`) |
| Saved scans | Hive `Box<SavedScan>` → `ScanRepository` | image bytes + text + timestamp; `listenable()` for live UI |
| First-run flag | SharedPreferences `'repeat'` | gates onboarding |
| Settings | SharedPreferences → `SettingsRepository` | threshold, custom model/labels paths; ChangeNotifier |
| ML assets | `assets/model/rice_disease_v1.tflite`, `assets/model/labels.txt` + native `.so` | bundled, hot-swappable via upload |
| Image picking | `ImageService` wrapping `image_picker` | camera or gallery |

**Label resolution**: model labels (6, from `labels.txt`) are mapped to catalog entries via
the `modelLabel` field. `SHEALTH BLIGHT` (typo, kept as-is to match the model) resolves to
the display name "Sheath Blight".

## Component responsibilities (key files)

| File | Responsibility |
|------|----------------|
| `lib/main.dart` | Bootstrap: Hive init/register/open, settings init, model restore, `runApp` |
| `lib/app_dependencies.dart` | Owns shared repos/services; **mutable** `inference` for hot-swap |
| `lib/core/constants/app_constants.dart` | Palette, asset paths, default threshold, keys, copy |
| `lib/core/theme/app_styles.dart` | Font + text styles |
| `lib/core/utils/formatters.dart` | Accuracy/timestamp formatting |
| `lib/data/models/*` | `Disease`, `SavedScan` (+ hand-maintained adapter), `ScanResult` |
| `lib/data/repositories/disease_repository.dart` | Loads catalog from JSON; `all`, `fallback`, `byLabel` |
| `lib/data/repositories/scan_repository.dart` | Hive-backed saved-scan CRUD + `listenable` |
| `lib/data/repositories/settings_repository.dart` | ChangeNotifier: threshold, custom model/labels persistence |
| `lib/data/services/inference_service.dart` | TFLite load/loadFromFile (null on failure) + predict |
| `lib/data/services/image_service.dart` | Pick + decode (off-isolate) |
| `lib/features/onboarding/*` | Splash + 3-page intro, first-run routing |
| `lib/features/shell/root_page.dart` | Bottom-nav `IndexedStack` shell + gear → Settings |
| `lib/features/home/*` | Catalog browse + disease detail dialog |
| `lib/features/scan/*` | Chooser, scan page, result/unidentified/analyzing overlays |
| `lib/features/saved/*` | Saved-scan list/detail + PDF export |
| `lib/features/settings/*` | Threshold slider + custom model/labels upload |
| `lib/features/about/*` | About placeholder (WIP) |
| `lib/widgets/*` | `PrimaryButton`, `CircleIconButton` |

## Navigation model

- **Push-based** navigation with `Navigator.push` typed routes (no named routes).
- Detail presentation for home uses an in-app `Dialog` (`DiseaseDialog`), not a route — the
  standalone `detail_page.dart` was removed.
- Tab switching uses `IndexedStack` (keeps tabs alive).
- Settings is pushed from the shell app bar gear icon; `ScanPage` is pushed from the chooser;
  `SavedDetailPage` is pushed from the saved list.

## Dependency graph (package level)

```
features  ──▶ core, data, widgets, app_dependencies
data       ──▶ tflite_flutter, tflite_flutter_helper, image, image_picker, hive_flutter
saved flow ──▶ hive_flutter, pdf, open_file, path_provider
settings   ──▶ file_picker, shared_preferences, path_provider
root/main  ──▶ shared_preferences, hive, path_provider
```

## Strengths of the current shape

- Single source of truth for disease data (JSON) with label-based lookup — removes the old
  6-vs-7 catalog misalignment and the fallback ambiguity.
- `InferenceService` is self-contained and returns `null` on load failure instead of
  crashing, so `ScanPage` can render an error state.
- Repositories + `AppDependencies` provide testability and a path to real state management.
- On-device inference means no network dependency for the core feature.
- Runtime-configurable threshold + hot-swappable model give the tool longevity without a server.

Open items and caveats are tracked in [[technical-debt]].