# Vault Home

> Obsidian documentation vault for **AgriGuard** (Rice Plant Disease Detection), a Flutter
> app that classifies rice plant photos on-device with TensorFlow Lite.
>
> All notes are generated from the actual implementation in `lib/`, `assets/`, and
> `pubspec.yaml`. No placeholders.

## Notes

- [[PROJECT_CONTEXT|Project context]] — root context note at the vault root
- [[detailed-documentation|Detailed documentation]] — full per-module walkthrough of the implementation
- [[architecture|Architecture summary]] — layers, data flow, component responsibilities
- [[codebase-analysis|Codebase analysis]] — what the code does today, module by module
- [[reusable-patterns|Reusable patterns]] — idioms worth extracting and reusing
- [[technical-debt|Technical debt]] — defects, dead code, and improvement priorities
- `business-rules.md` — non-negotiable behavioural rules (threshold, catalogue, custom model)
- `api-specification.md` — external integrations + internal contracts
- `technical-decisions.md` — decision log (T1–T7)
- `ai-backend.md` / `ai-frontend.md` — inference stack and scan/settings UI
- `database.md` / `permissions.md` — persistence layer and OS permissions

## How to navigate

1. Start with `PROJECT_CONTEXT` for a 60-second overview.
2. Read `codebase-analysis.md` to understand each layer.
3. Read `architecture.md` for the big picture.
4. Read `detailed-documentation.md` for the implementation specifics.
5. Reference `technical-debt.md` before making changes.

## Key facts

- **Package**: `agri_guard`; app title `'AgriGuard'`; version `1.0.0+1`.
- **Model**: `assets/model/rice_disease_v1.tflite`, 6 classes, loaded via `tflite_flutter`;
  hot-swappable with an uploaded `.tflite` (Settings). Labels in `assets/model/labels.txt`.
- **Data**: single unified catalogue `assets/disease_data.json` (7 entries; id 0 =
  "Fail to recognise" fallback) keyed to model labels via `modelLabel`.
- **Persistence**: Hive box `plantDiseases` (saved scans), SharedPreferences (onboarding flag
  `'repeat'`, settings keys `confidence_threshold`, `custom_model_path`, `custom_labels_path`).
- **Inference**: on-device only; no network, no auth. Threshold is user-configurable
  (0.50–1.00, default 0.95). Minimum analysing animation 3 s.
- **Tests**: 4 real test files pass; `flutter analyze` clean. Release APK
  is named `AgriGuard.apk` (`android/app/build.gradle`).