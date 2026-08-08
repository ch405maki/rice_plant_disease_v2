# Workflow: Scan / Analyse

> Folder: `docs/vault/Workflows/`

## Entry
User taps the **Scan** tab → `ScanChooserPage` (radio-type choice) → camera or gallery
via `ImageService.pick(source)`.

## Steps
1. `ScanPage(source)` initialised; `_pickAndAnalyze()` invoked.
2. Picker returns `null` (cancel/denied) → pop the page. Non-null → decode image.
3. If decode fails or `inference == null` → **error** overlay; "Try again" loops back to the picker.
4. Else transition to `analyzing` — overlay with animated scan line (radius 22, `startColor`
   border) and spinner caption; measurement clock started (`_analyzingStarted`).
5. `predict(decoded)` returns `{label, confidence}` (top‑1, synchronous on‑device).
6. `_resolveDisease(label, confidence)`:
   - threshold = `dependencies.settings.confidenceThreshold`
   - label found in catalogue AND `confidence >= threshold` → disease match
   - otherwise → `fallback` disease (`id 0`)
7. If `usedTime < minDuration` (3000 ms) → await the remainder with a `Future.delayed`.
8. `setState` success → animate in `ResultView` (or `UnrecognizedPanel` when `id 0`).

## Save (success only)
- Saving is manual (`SAVE THE RESULT` button); an idempotent guard (`_saved`) prevents duplicates.
- Un-recognised scans are saved as `plantName: 'Unidentified'` with image only, empty medical fields;
  recognised scans store the full record.