# Technical Decisions

Record of project-specific decisions and the reasons behind them.

## T1 — Pin `file_picker ^4.6.0` (NOT 5.x)

- **Decision**: `pubspec.yaml` uses `file_picker: ^4.6.0`.
- **Why**: `file_picker >= 5.0.0 < 8.1.0` requires `ffi ^2.0.1`, which conflicts with the pinned
  `tflite_flutter_helper` git fork that requires `ffi ^1.0.0`. Version resolution fails otherwise.
- **Impact**: model/labels upload uses the older `FilePicker.platform.pickFiles(...)` API, which is unchanged.

## T2. `SettingsRepository` over a static constant threshold

- Previously `AppConstants.confidenceThreshold = 0.95` was `const` and read directly in
  `scan_page._resolveDisease`.
- Now a `ChangeNotifier` (`SettingsRepository`) holds the threshold (default 0.95, range 0.50–1.00),
  persisted in SharedPreferences, and the scan page reads it at scan time. The constant remains as
  the factory default only.

## T3. `AppDependencies` loses its `const` constructor

- `inference` is now a **mutable** field so the model can be hot-swapped after an upload
  (`dependencies.inference = newEngine`). A `const` constructor is impossible with a non-final field,
  so the constructor is a plain (non-const) constructor. Only `main.dart` constructs it.

## T4. Custom model engine: load → validate → persist → swap

- Upload flow validates the picked file by actually constructing an `Interpreter` (`loadFromFile`)
  **before** persisting the copy. On any failure the old engine stays active and the user is told.
- On success the old engine is disposed (`old?.dispose()`) to release the native interpreter.

## T5. Analysis/result pacing is a fixed minimum, not a progress bar

- The analysing overlay always shows ≥ 3 seconds (`_minAnalyzingDuration`), regardless of how
  quickly on-device inference actually returns, so fast devices don't flash the result.

## T6. Hero/info visual language (post-refactor)

- Result page, saved detail page and the home disease dialog share: rounded thumbnails with padding,
  no header icons, no bullet dots (data bullets are stripped), `black54` body, bold green labels, and
  light `lightGreenLeaves`‑blend page backgrounds. Rounded card radii kept intentionally moderate.

## T7. Disease name uses the normal font

- The home `DiseaseDialog` displays the disease name in the standard font (bold, primary green)
  rather than the display font (`SquadaOne`), per latest UI direction.

## T8. Release APK named `AgriGuard.apk`

- The release build output is renamed from `app-release.apk` to `AgriGuard.apk`
  via `android/app/build.gradle` (`archivesBaseName = "AgriGuard"`), so the
  delivered file carries the app's brand name.