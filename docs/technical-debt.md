# Technical Debt

> Defects, dead code, and improvement priorities found by reviewing the implementation at
> commit `f0a9180`. Items are grouped by severity. Related: [[codebase-analysis]],
> [[architecture]].

## Status

The remediation listed below was applied in the refactor that restructured `lib/` into
`core/`, `data/`, `features/`, `widgets/` and added tests + DI. Current state:

| Item | Status |
|------|--------|
| T1  Test suite broken boilerplate | Resolved — real tests under `test/`; `flutter analyze` + `flutter test` pass |
| T2  Classifier load force-unwrapped | Resolved — `InferenceService.load()` returns `null` on failure; `ScanPage` shows an error UI |
| T3  Misaligned static catalogs | Resolved — single `assets/disease_data.json` (7 entries, id 0 fallback) keyed by label via `DiseaseRepository` |
| T4  Label typo baked into source data | Resolved — `modelLabel: "SHEALTH BLIGHT"` kept in data (matches trained labels), `name: "Sheath Blight"` shown to users |
| T5  Shadowed `Constants` class | Resolved — local class deleted; single `AppConstants` |
| T6  Duplicate/inconsistent persistence | Resolved — favorites concept removed; Saved tab lists Hive scan records via `ScanRepository` |
| T7  Inference blocks the UI thread | **Open (partial)** — image decode is async but `Interpreter.run` is still synchronous on the UI isolate in `InferenceService.predict` |
| T8  Bookmark saves on every press | Resolved — `ScanPage._saveScan` saves once, guarded by `_saved` |
| T9  Hardcoded threshold and magic values | Resolved — colors + `confidenceThreshold` in `AppConstants` |
| T10 Auth screens non-functional stubs | Resolved — deleted (`signin`/`signup`/`forgot_password`) |
| T11 Dead code | Resolved — deleted unused widgets/models/globals and `assets/model.tflite` |
| T12 Unused / redundant dependencies | Resolved — trimmed `pubspec.yaml` (kept `pdf`/`open_file`; still used by PDF export) |
| T13 `late` `_classifier` + race | Resolved — inference loaded once up-front and awaited via `AppDependencies` |
| T14 Non-strict sort comparator | Resolved — replaced with a linear max scan in `_topCategory` |
| T15 Splash navigation not replaced | Resolved — `SplashScreen` uses `pushReplacement` |
| T16 Detail-page favorite toggle inert | Resolved — favorite toggle removed; detail pages use shared `CircleIconButton` |
| T17 Naming and copy issues | Resolved — `applicationId` + `namespace` `com.agriguard.app`, app title `'AgriGuard'`, typos fixed; package name `agri_guard` |
| T18 23 MB font bundled for PDF export | **Open (deferred)** — `ArialUnicodeMS.ttf` still used by `SavedDetailPage` PDF export |
| T19 Redundant double-import / cleanup | Resolved — double `material.dart` import removed; `install.bat`/`install.sh` remain (see below) |
| T20 No state management or testability hooks | Resolved — `AppDependencies`, repositories, services, widgets with injected deps |

## Remaining items

### T7 (partial). Inference runs on the UI isolate
`InferenceService.predict()` calls `Interpreter.run` synchronously (`lib/data/services/
inference_service.dart:74`). The model is small (~2 MB) so this is fast in practice, but a
large photo can still jank. Move to `compute()`/`Isolate.run` if it ever becomes a problem.

### T18 (deferred). 23 MB PDF font
`assets/ArialUnicodeMS.ttf` (23,275,812 bytes) is bundled for PDF export in
`SavedDetailPage`. Consider a subsetted font or lazy download before release.

### T19 (partial). Native model-loading tooling
`install.bat` / `install.sh` still download TF-Lite C libs pinned to TF 2.5. The
`tflite_flutter_helper` git fork (`filofan1`, ref `783f15e5`) exists because the pinned
version needs the matching helper; document the reason in `pubspec.yaml` or automate via
Gradle when the helper publishes a compatible release.

### Boot order (new)
`main()` now awaits Hive open, `DiseaseRepository.load()`, and `InferenceService.load()`
*before* `runApp`, so the splash screen shows only after all work is done. If a cold start
feels slow, move loading behind the splash and pass a future through `AppDependencies`.

## Suggested remediation order (revisited)

Most items are closed. The remaining work is optional polish:

1. Consider moving inference off the UI isolate (T7).
2. Reduce the PDF font footprint (T18).
3. Automate/document native TF-Lite lib setup (T19).
4. Optionally make boot non-blocking (see "Boot order" above).
