# Architecture Summary

> High-level picture of how `agri_guard` is structured. Derived from the
> implementation. Details in [[detailed-documentation]] and [[codebase-analysis]].

## Layers

The app is a single-package Flutter app using plain `StatefulWidget`/`setState` with a
small hand-rolled dependency container for testability — no third-party state-management
or DI library. The code organises into four folders plus a shared widget folder:

```
lib/
  main.dart                     # Bootstrap: Hive init, dependency build, runApp
  app_dependencies.dart         # AppDependencies container (repo/services)
  core/
    constants/app_constants.dart   # palette, asset paths, threshold, keys, copy
    theme/app_styles.dart          # font + text styles
    utils/formatters.dart          # formatAccuracy, formatTimestamp
  data/
    models/                      # disease.dart, saved_scan.dart (+ .g.dart adapter), scan_result.dart
    repositories/                # disease_repository.dart, scan_repository.dart
    services/                    # inference_service.dart, image_service.dart
  features/                     # feature-scoped screens, one folder per feature
    onboarding/  shell/  home/  scan/  saved/  about/
  widgets/                      # shared UI: primary_button, circle_icon_button
```

## Runtime flow (startup)

1. `main()` (`lib/main.dart`) initialises Hive against the documents dir, registers
   `SavedScanAdapter`, opens box `'plantDiseases'`.
2. Builds `AppDependencies` (awaits `DiseaseRepository.load()` and
   `InferenceService.load()` before UI) and calls `runApp`.
3. `MyApp` → `SplashScreen`, which after ~3 s reads SharedPreferences `'repeat'`
   and `pushReplacement`s to `OnboardingScreen` (first run, sets `'repeat' = true`)
   or `RootPage`.
4. `RootPage` is the `IndexedStack` tab shell: Home / Scan / Saved / About.

## Runtime flow (scanning) — the core feature

```
ScanChooserPage ──(ImageSource.camera|gallery)──▶ ScanPage
                                                  │ initState → _pickAndAnalyze
                                                  ▼
                                   ImageService.pick → ImageService.decode
                                                  │
                                                  ▼
                              InferenceService.predict(decoded)
                                  └─ preprocess (resize-crop → resize → normalize)
                                     → interpreter.run → top {label, score}
                                                  │
                                                  ▼
                    confidence >= 0.95 ? resolve label : fallback
                    DiseaseRepository.byLabel(label) ?? fallback
                                                  │
                                                  ▼
                        ResultView: name / accuracy / causes / symptoms / treatment
        user taps save → _saveScan() once → ScanRepository.add(SavedScan) → Hive
```

## Data ownership

| Concern | Owner | Notes |
|---------|-------|-------|
| Disease reference content | `assets/disease_data.json` → `DiseaseRepository` | 7 entries; id 0 = "Fail to recognise" fallback (`modelLabel: null`) |
| Saved scans | Hive `Box<SavedScan>` → `ScanRepository` | image bytes + text + timestamp; `listenable()` for live UI |
| First-run flag | SharedPreferences `'repeat'` | gates onboarding |
| ML assets | `assets/model/rice_disease_v1.tflite`, `assets/model/labels.txt` + native `.so` |
| Image picking | `ImageService` wrapping `image_picker` | camera or gallery |

**Label resolution**: model labels (6, from `labels.txt`) are mapped to catalog entries via
the `modelLabel` field. The trained label `SHEALTH BLIGHT` (typo, kept as-is to match the
model) resolves to a display name of "Sheath Blight".

## Component responsibilities (key files)

| File | Responsibility |
|------|----------------|
| `lib/main.dart` | Bootstrap: Hive init/register/open, build deps, `runApp` |
| `lib/app_dependencies.dart` | Owns shared repos/services injected into widgets |
| `lib/core/constants/app_constants.dart` | Palette, asset paths, threshold, keys, copy |
| `lib/core/theme/app_styles.dart` | Font + text styles |
| `lib/core/utils/formatters.dart` | Accuracy/timestamp formatting |
| `lib/data/models/*` | `Disease`, `SavedScan` (+ adapter), `ScanResult` |
| `lib/data/repositories/disease_repository.dart` | Loads catalog from JSON; `all`, `fallback`, `byLabel` |
| `lib/data/repositories/scan_repository.dart` | Hive-backed saved-scan CRUD + `listenable` |
| `lib/data/services/inference_service.dart` | TFLite load (null on failure) + predict pipeline |
| `lib/data/services/image_service.dart` | Pick + decode images |
| `lib/features/onboarding/*` | Splash + 3-page intro, first-run routing |
| `lib/features/shell/root_page.dart` | Bottom-nav `IndexedStack` shell |
| `lib/features/home/*` | Catalog browse + plant detail |
| `lib/features/scan/*` | Chooser, scan page, result + photo views |
| `lib/features/saved/*` | Saved-scan list/detail + PDF export |
| `lib/features/about/*` | About screen |
| `lib/widgets/*` | `PrimaryButton`, `CircleIconButton` |

## Navigation model

- **Push-based** navigation with `Navigator.push` / `pushReplacement`, typed route args
  (e.g. `MaterialPageRoute<DetailPage>`). No named routes.
- Tab switching uses `IndexedStack` (keeps tabs alive).
- Dependencies are passed through constructors from `AppDependencies`.

## Dependency graph (package level)

```
features  ──▶ core, data, widgets, app_dependencies
data       ──▶ tflite_flutter, tflite_flutter_helper, image, image_picker, hive_flutter
saved flow ──▶ hive_flutter, pdf, open_file, path_provider
root/main  ──▶ shared_preferences, hive, path_provider
```

## Strengths of the current shape

- Single source of truth for disease data (JSON) with label-based lookup — removes the old
  6-vs-7 catalog misalignment.
- `InferenceService` is self-contained and returns `null` on load failure instead of
  crashing, so `ScanPage` can render an error state. See [[reusable-patterns]].
- Repositories + `AppDependencies` provide testability and a path to real state management.
- On-device inference means no network dependency for the core feature.

Open items and caveats are tracked in [[technical-debt]].