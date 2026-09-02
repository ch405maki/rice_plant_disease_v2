# PROJECT_CONTEXT

> Obsidian vault root note. Everything below is derived from the actual source in this repository.

## Project

- **Package name**: `agri_guard` (`pubspec.yaml`)
- **Description**: AgriGuard — plant disease recogniser in Flutter using TensorFlow Lite
- **Version**: `1.0.0+1`
- **Flutter / Dart**: SDK constraint `>=2.17.0 <4.0.0`
- **Platform targets**: Android (primary), iOS scaffold present
- **App title in code**: `'AgriGuard'` (`lib/main.dart:40`)
- **Android applicationId / namespace**: `com.agriguard.app` (`android/app/build.gradle`); iOS bundle ID `com.agriguard.app`

## Purpose

On-device mobile app for farmers that detects six rice conditions from a photo using a
TensorFlow Lite classifier, shows disease-specific causes/symptoms/treatment from bundled
static data, and lets the user save scans locally (Hive) and export them to PDF.

## Detection classes (from `assets/model/labels.txt`)

| Index | Label |
|-------|-------|
| 0     | BACTERIAL BLIGHT |
| 1     | BROWN SPOT |
| 2     | LEAF BLAST |
| 3     | NORMAL RICE PLANT |
| 4     | SHEALTH BLIGHT *(typo in source data; should be "SHEATH")* |
| 5     | TUNGRO |

- Model: `assets/model/rice_disease_v1.tflite`
- Labels: `assets/model/labels.txt`
- Inference threshold: `0.95` default (AppConstants.confidenceThreshold); runtime value
  is user-configurable 0.50–1.00 via `SettingsRepository` (SharedPreferences)
- Disease catalog (name/description/causes/symptoms/treatment): `assets/disease_data.json`
  (7 entries; id 0 = "Fail to recognise" fallback)

## Authors / Context

Capstone project, Kalinga State University, BS Computer Engineering:

- Clemente, Justine Joseph P.
- Codiam, Cheska P.
- Sullin, Alexis Jones L.
- Taluyan, Cheery Deyeah M.

## Tech stack

| Layer | Technology |
|-------|------------|
| UI | Flutter Material (`StatefulWidget` / `setState`, hand-rolled `AppDependencies` container) |
| On-device ML | `tflite_flutter` 0.9.0 + `tflite_flutter_helper` (git fork `filofan1`) |
| Image handling | `image` 3.2.2, `image_picker` 0.8.6, `image_picker`-adjacent `file_picker` 4.6.0 (model/labels upload) |
| Local storage | `hive` 2.2.3, `hive_flutter` 1.1.0, `shared_preferences` 2.1.2, `path_provider` 2.0.12 |
| Navigation | Navigator routes (push / pushReplacement, typed routes) |
| PDF export | `pdf` 3.8.4, `open_file` 3.1.0 |

## Directory map (source)

```
lib/
  main.dart                        # Bootstrap; Hive init, settings init, model restore, runApp
  app_dependencies.dart            # AppDependencies: repos + services injected into widgets
  core/
    constants/app_constants.dart   # palette, asset paths, default threshold, prefs keys, onboarding copy
    theme/app_styles.dart          # font + text styles
    utils/formatters.dart          # formatAccuracy, formatTimestamp
  data/
    models/disease.dart            # Disease (unified catalog entry)
    models/saved_scan.dart         # SavedScan (Hive + adapter target)
    models/saved_scan.g.dart       # SavedScanAdapter (hand-maintained)
    models/scan_result.dart        # ScanResult {label, confidence}
    repositories/disease_repository.dart  # loads JSON, all/fallback/byLabel
    repositories/scan_repository.dart     # Hive CRUD + listenable
    repositories/settings_repository.dart # ChangeNotifier threshold + custom model prefs
    services/inference_service.dart       # TFLite load/loadFromFile (null on fail) + predict
    services/image_service.dart           # pick + decode (compute)
  features/
    onboarding/splash_screen.dart  # 3s splash; pushReplacement routing
    onboarding/onboarding_screen.dart    # 3-page intro; sets 'repeat'
    shell/root_page.dart           # bottom-nav IndexedStack: Home/Scan/Saved/About (+ gear -> Settings)
    home/home_page.dart            # banner + healthy/diseases list
    home/disease_dialog.dart       # catalog-detail dialog (replaces detail_page.dart)
    home/widgets/plant_card.dart
    scan/scan_chooser_page.dart    # camera-or-gallery chooser
    scan/scan_page.dart            # pick -> classify -> result -> save to Hive
    scan/widgets/analyzing_overlay.dart  # thin glow scan line
    scan/widgets/result_view.dart  # recognised result hero + sections
    scan/widgets/unrecognized_panel.dart # unidentified panel ("Model confidence: X%")
    saved/saved_page.dart          # list/delete saved scans
    saved/saved_detail_page.dart   # saved-scan detail + PDF export
    settings/settings_page.dart    # threshold slider + custom model/labels upload
    about/about_page.dart          # centered logo, description, Developer & Adviser sections
  widgets/
    primary_button.dart            # reusable labeled/icon button
    circle_icon_button.dart        # reusable round icon button
assets/
  model/labels.txt                 # 6 class labels (indexed)
  model/rice_disease_v1.tflite     # TFLite model
  disease_data.json                # disease catalog (7 entries)
  ArialUnicodeMS.ttf               # 23 MB fallback font for PDF export
  *.ttf                            # SquadaOne, ContrailOne, Roboto-Light
  images/                          # bundled images
```

## Status

`flutter analyze` is clean and `flutter test` passes (4 test files). See
[[technical-debt]] for the itemised remediation status.

## Documentation index

- [[README|Vault Home]]
- [[detailed-documentation|Detailed documentation (per-module)]]
- [[architecture|Architecture summary]]
- [[codebase-analysis|Codebase analysis]]
- [[reusable-patterns|Reusable patterns]]
- [[technical-debt|Technical debt]]
- `business-rules.md` — behavioural rules (threshold, catalogue, custom model)
- `api-specification.md` — integrations + internal contracts
- `technical-decisions.md` — decision log (T1–T7)
- `ai-backend.md` / `ai-frontend.md` — inference and scan/settings UI
- `database.md` / `permissions.md` — persistence + OS permissions