# Module: Scan Result

> Folder: `docs/vault/Modules/`

**Files:** `lib/features/scan/scan_page.dart`, `widgets/result_view.dart`,
`widgets/unrecognized_panel.dart`, `widgets/analyzing_overlay.dart`, `widgets/scan_chooser_page.dart`

## Purpose
Photo → classify → present result (recognised or unidentified) → save to Hive.

## Behaviour summary
- 4 states: `idle`/`analyzing`/`success`/`error` (private enum `_ScanStatus`).
- Scanning animation shown **≥ 3 s** (`Duration(milliseconds: 3000)`); result transition waits
  out any remaining time.
- Recognised: fixed rounded **hero card** (92×92 rounded photo, name, "Accuracy: X%" chip) with
  scrollable Description/Symptoms/Control sections (bullets stripped, bold green labels).
- Unrecognised: same hero style with name **"Unidentified"** + chip **"Model confidence: X%"**
  and tips/"Another photo" actions; full page height (not a bottom sheet).
- Error: black overlay "Unable to analyse this image." + Try again (`PrimaryButton`), shown when
  inference is `null` or the image failed to decode.

## Notable details
- `_resolveDisease`: above **dynamic threshold** (`settings.confidenceThreshold`) AND label in
  catalog → disease; else fallback disease `id 0`.
- Save is idempotent (`_saved` guard); unrecognised scans store `plantName: 'Unidentified'` and
  empty medical fields.
- Custom model label mismatch → naturally surfaces as the unrecognised panel (no fake result).

## Relationships
- Reads `dependencies.inference`, `dependencies.settings`, `dependencies.diseases`,
  `dependencies.scans`.