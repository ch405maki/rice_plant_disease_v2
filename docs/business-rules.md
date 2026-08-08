# Business Rules — AgriGuard

Project-specific rules, thresholds and user-facing behaviour. These are enforced in `lib/`.

## Scan / classification

| Rule | Value | Source |
|------|-------|--------|
| Minimum model confidence to recognise a disease | Default `0.95`, user-configurable `0.50–1.00` | `AppConstants.confidenceThreshold`, `SettingsRepository.confidenceThreshold` |
| Rules below threshold | Treated as "unidentified" (fallback disease `id 0` = "Fail to recognise") | `scan_page.dart` `_resolveDisease` |
| Minimum duration the analysing animation is shown | `3000 ms` (delays the result even if inference finishes faster) | `scan_page.dart` `_minAnalyzingDuration` |

- A scan is **recognised** only when `result.confidence >= configured threshold` **and** the predicted label exists in the disease catalog. Any miss renders the user-facing `Unidentified` panel (photo + "Model confidence: X%"), never a fabricated result.
- The user-facing confidence chip for unrecognised scans reads **"Model confidence: 98.51%"**; recognised scans read **"Accuracy: 98.51%"** (prefix differs by state).

## Disease catalog

- `assets/disease_data.json` holds 7 entries; `id 0` is the "Fail to recognise" fallback with `modelLabel = null`.
- `modelLabel` values intentionally mirror the raw model output and keep known typos (e.g. `"SHEALTH BLIGHT"`), while `name` holds the corrected display string ("Sheath Blight").
- `labels.txt` prefixes (`"0 LEAF BLAST"`) are stripped at load time by `InferenceService._cleanLabels`.

## Custom model upload (Settings)

- Uploaded model must be a TensorFlow Lite **classification** model with a square input (typically `224×224` or `256×256`). Input type/shape is read from the interpreter at load, so compatible models load without code changes.
- Labels `.txt` are **optional**. When provided they must list **one label per line in the model's output order**; a leading index like `"0 Leaf Blast"` is stripped automatically. When absent, the bundled default labels are reused.
- If an uploaded label does **not** match a disease name in the catalog, scans for that class show as unidentified.
- Failed uploads never replace the working engine: the current model is kept and a snackbar is shown.
- Uploaded model/labels are **persisted** (copied to app documents dir, path stored in SharedPreferences) and restored on next launch; "Reset to default model" deletes them.

## Onboarding

- 3-page intro; a single SharedPreferences flag (`repeat`) records completion.
- Splash shows ~3 s before routing (splash → onboarding if fresh, else the shell).

## Saving scans

- Scans are stored in Hive box `plantDiseases` as `SavedScan` (image bytes + name + causes/symptoms/treatment + ISO-8601 timestamp).
- The saved record uses `plantName: 'Unidentified'` for unrecognised scans and omits medical fields (`''`).
- Saving is idempotent per result (`_saved` guard disables the bookmark button).

## UI copy / behaviour edges

- About tab is a **"Work in progress"** placeholder (no credits content).
- Scan result / saved detail / home disease details share one visual language: rounded cards, no header icons, no bullet dots, `black54` body text, green bold labels; descriptive headers like `Pathogen Name:` and `Damage of X:` are rendered as bold green labels.