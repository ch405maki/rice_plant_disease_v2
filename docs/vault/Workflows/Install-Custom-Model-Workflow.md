# Workflow: Install Custom Model

> Folder: `docs/vault/Workflows/`

## Entry
SettingsPage (gear in shell AppBar) → "Upload model".

## Steps
1. Tap upload → `FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['tflite'])` (file_picker 4.x API).
2. Null → cancel, no change.
3. Path → call `InferenceService.loadFromFile(modelFile: File(path))` to **validate**; any load
   error → snackbar "Invalid model", keep current engine, `_busy` reset.
4. On success:
   - copy into `getApplicationDocumentsDirectory()` named
     `agriguard_model_<epochMs>.tflite`;
   - `settings.saveCustomModel(copy.path)` (persist path in `custom_model_path`);
   - hot-swap `AppDependencies.inference = newEngine` (old disposed).
5. Threshold/labels unaffected; scan page uses the live settings immediately.

## Labels (optional)
- "Upload labels (optional)": same copy flow → `custom_labels_path`;
- labelled model is reloaded with the user labels; otherwise bundled labels used.

## Reset
- Red "Reset to default" → delete copied files → clear prefs → reload bundle engine
  (`InferenceService.load()`), restore `0.95` threshold.