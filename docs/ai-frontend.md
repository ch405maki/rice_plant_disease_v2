# AI Frontend — Scan & Settings UI

UI that drives inference: `scan_chooser_page` → `scan_page` → `result_view` /
`unrecognized_panel`, plus the Settings page that controls the model.

## Scan flow (`features/scan/scan_page.dart`)

1. `ScanPage(source, dependencies)` → `_pickAndAnalyze()`:
   `ImageService.pick(source)` → decode → `inference.predict(decoded)` → resolve disease.
2. States (`_ScanStatus`): `idle` → `analyzing` → `success` | `error`.
   - Pick cancelled pops the page.
   - `inference == null` or decode failure → full-screen `error` overlay with a **Try again**.
3. **Min display time**: result/error transition waits so the scanning animation shows
   ≥ `3000 ms` from when analysis started.
4. Result rendering:
   - recognised → `ResultView` (fixed rounded hero card w/ photo + name + "Accuracy: X%",
     scrollable sections below; body bullets stripped to paragraphs, bold green labels).
   - unrecognised → `UnrecognizedPanel` (hero card w/ photo, name `Unidentified`,
     chip "Model confidence: X%", tips + retry buttons, full page height).

## Settings page (`features/settings/settings_page.dart`)

- Opened from the **gear** in the shell app bar (`root_page.dart` AppBar `actions`).
- Controls:
  - **Accuracy threshold** slider (`0.50–1.00`, 50 divisions) → `SettingsRepository.setConfidenceThreshold`.
  - **Upload model (.tflite)** → pick → `loadFromFile` (validate) → copy to docs → swap engine.
  - **Upload labels (.txt, optional)** → copy → reload the active engine with new labels
    (bundled engine reloads via `load(labelsFilePath: ...)` when no custom model exists).
  - **Reset to default** (red button) → delete custom files → reload bundled engine.
  - **Model requirements** note (amber box) documents tflite format/labels order/warnings.
- `_busy` disables all controls during async ops. Ups blending uses `AnimatedBuilder` on the settings.

## Shell (`root_page.dart`)

- `IndexedStack` tabs: Home / Scan / Saved / About.
- App bar title = active tab label; gear action on the right opens Settings.
- About tab is a "Work in progress" placeholder (icon `info_outline` in tab, `info_outline`
  icon on page).