# Decisions — AgriGuard Engineering Log

> Folder: `docs/vault/Decisions/`

Short, dated entries recording why the code is the way it is.

## D-001 · Use Hive over shared_preferences for scans
- **When**: initial architecture.
- **Why**: boxed typed objects with listenable boxes (`ValueListenable`) → reactive Saved list
  without a state-management lib; on-device only, no server.

## D-002 · Own disease catalogue in JSON, not hard-coded
- `assets/disease_data.json` holds name/causes/symptoms/treatment plus `modelLabel` mapping.
  Labels are **project-known constants**, not user-configurable. Enables hot edits.

## D-003 · tflite_flutter (not tflite)
- tflite_flutter gives TensorFlow Lite 2.x interpreter, `fromAsset`/`fromFile`, typed I/O.
  Chosen after the older `tflite` package stopped matching AlphaPoint's shape contract.

## D-004 · Pin `file_picker ^4.6.0`
- 5.x/5.0+ requires `ffi ^2.0.1`; our git-pinned `tflite_flutter_helper` needs `ffi ^1.0.0`.
  Version solver rejects the combo → stay on 4.x.

## D-005 · Custom-model upload instead of bundling secondaries
- Layout (T4): Settings UI validates + copies model into app documents
  and only then swaps `AppDependencies.inference`. Live-swap without app restart.

## D-006 · Confidence threshold runtime-configurable
- Default 0.95; slider 0.50–1.00; stored per session (SharedPreferences). Read at scan time
  (not const) so a late model swap still uses the live threshold.

## D-007 · Fixed analysing duration (≥3 s)
- Avoids a "blink" instant result on fast devices; gives the scan line animation weight.