# Detailed Documentation

> Derived from the implementation. Every statement links to a specific file in this
> repository. Related: [[architecture]], [[codebase-analysis]], [[reusable-patterns]],
> [[technical-debt]], [[business-rules]], [[api-specification]], [[technical-decisions]].

---

## 1. Application entry (`lib/main.dart`)

`main()` is fully async:

1. `WidgetsFlutterBinding.ensureInitialized()`.
2. `path_provider.getApplicationDocumentsDirectory()` → `Hive.init`.
3. `Hive.registerAdapter(SavedScanAdapter())`.
4. `await Hive.openBox<SavedScan>(AppConstants.hiveBoxName)`.
5. `final settings = SettingsRepository(); await settings.init();` — loads threshold +
   custom model/labels paths from SharedPreferences.
6. `_loadPersistedOrBundledModel(settings)`:
   - if `customModelPath` is set → `InferenceService.loadFromFile(modelFile, labelsFile?)`;
     if that returns non-null, use it;
   - else → `InferenceService.load()` (bundled).
7. Build a **non-const** `AppDependencies` (settings + `inference` are required by design —
   `inference` is deliberately a mutable field for hot-swapping).
8. `runApp(MyApp(dependencies: ...))`.

`MyApp` (`StatelessWidget`): `MaterialApp(title: 'AgriGuard',
debugShowCheckedModeBanner: false, home: SplashScreen(dependencies))`.

## 2. Splash + onboarding gating (`lib/features/onboarding/`)

- `splash_screen.dart`: solid `AppConstants.primaryColor` screen; a 3-second `Timer` reads
  SharedPreferences `'repeat'` (`AppConstants.prefsOnboardingKey`).
  - `null` → `pushReplacement(OnboardingScreen(dependencies))`
  - else → `pushReplacement(RootPage(dependencies))`
- `onboarding_screen.dart`: 3-page `PageController` intro, copy from `AppConstants`
  (titles/descriptions T1–T3). Skip and next-on-last set `'repeat' = true` then replace to
  `RootPage`.

## 3. Root shell (`lib/features/shell/root_page.dart`)

`RootPage` (`StatefulWidget`, deps injected):

- `_pages = [HomePage, ScanChooserPage, SavedPage, const AboutPage()]` over an `IndexedStack`.
- 4-tab `BottomNavigationBar` (fixed): Home / Scan / Saved / About.
- `AppBar` title = active tab label (bold, black54, 24) and an `actions` gear
  (`Icons.settings_outlined`, primary colour) that pushes `SettingsPage`.
- `HomePage` receives `diseases`; `ScanChooserPage`/`SavedPage` receive the full dependencies.

## 4. Home (`lib/features/home/`)

`home_page.dart`:

- `ListView` inside `SafeArea` (no fixed bottom spacer), padding top 4 / bottom 32.
- `_buildBanner()`: `assets/images/banner.jpg` inside `ClipRRect(radius 12)`, height 160,
  margins `LTRB(20,12,20,16)`.
- Sections: "Healthy Rice plant" (entry whose `modelLabel == 'NORMAL RICE PLANT'`) then
  "Rice Plant Diseases" (all entries with a `modelLabel` except healthy).
- Each disease rendered as `PlantCard` → tap calls `DiseaseDialog(disease).show(context)`.

**`widgets/plant_card.dart`**: white card, radius 14, padding 12, shadow; 84×84 rounded
thumbnail (radius 12) padded; name (black87 bold 16) + cleaned description preview
(`_cleanText`, maxLines 3).

**`disease_dialog.dart`**: `Dialog` radius 14 / `ConstrainedBox maxHeight 75%`; header = fullbleed image 200 px with `LinearGradient` overlay (top black38 → bottom black26) + close circle
(top-right, `Colors.black26`); title = `disease.name` in **normal** bold 24 primary; body =
`SingleChildScrollView` with `_cleanText(description)` (strips `•`, newlines → space, collapse
whitespace), justified, black54. The standalone `detail_page.dart` was removed — dialogs replaced it.

## 5. Scan flow (`lib/features/scan/`)

**`scan_chooser_page.dart`** — bottom-aligned button column: "Camera" / "Pick from Gallery"
(`PrimaryButton`s) → `Navigator.push(ScanPage(source: ...))`.

**`scan_page.dart`**:

- `enum _ScanStatus { idle, analyzing, success, error }`; `const _minDisplayDuration =
  Duration(milliseconds: 3000)`.
- `initState` → `_pickAndScan()`: checks `inference == null` (→ error), picks an image via
  `ImageService.pick(source)` (null → pop), sets `analyzing` + `_imageFile`, records
  `startedAt`.
- `ensureMinDisplay()` awaits any remaining time so the analysing animation is shown for at
  least 3 s.
- Decodes off-isolate (`imageService.decode` → `compute`); on `null` → error.
- `inference.predict(decoded)` → `_resolveDisease(result)`.
- `_resolveDisease`: `result.confidence >= settings.confidenceThreshold` and
  `diseases.byLabel(result.label)` → that disease, else `diseases.fallback` (id 0).
- Success → result concrete view: `_recognized` (modelLabel != null) → `ResultView` else
  `UnrecognizedPanel`.
- Save: guarded by `_saved`; builds `SavedScan` — `plantName` = disease name or
  `'Unidentified'`, `causes/symptoms/treatment` empty when unrecognised, `imageBytes`, and
  ISO-8601 `dateCreated`. SnackBar "Scan saved".
- Error overlay: red icon `Icons.error_outline` + message "Unable to analyse this image."
  + `PrimaryButton label: 'Try again'`.
- UI: full-screen dark photo (`ColoredBox`) while not success; success background =
  `Color.lerp(lightGreenLeaves, Colors.white, .5)`; top `Positioned` row = close + save
  buttons.

## 6. Result views (`lib/features/scan/widgets/`)

**`result_view.dart`**:

- `Column`: fixed `_HeroCard` + `Expanded(SingleChildScrollView)`.
- Hero: margin `LTRB(20,18,20,14)`, padding 14, radius 16, `primaryColor`; 92×92 rounded
  (12) photo (placeholder `Icons.image_outlined` when `imageFile == null`); right column:
  name (bold 21 white) + accuracy chip (`Icons.verified_outlined`, "Accuracy: "
  `formatAccuracy`), white .18 background, radius 16.
- Sections: bold primary title ("Description", "Symptoms", "Control / Interventions"),
  then `_bodyBody` rendered line-by-line: lines starting with `•` → paragraph; lines matching
  `^[A-Za-z][^:]?:\s*$` → bold primary label; otherwise paragraph (black54, height 1.4).

**`unrecognized_panel.dart`**: same hero shell but name `'Unidentified'` + chip shows
**"Model confidence: X%"** (`_toModelConfidence` replaces "Accuracy" prefix). Body: circular
`Icons.search_off` badge, "We couldn't identify this one", "For a more reliable result:" tips
(3 static tips), buttons `PrimaryButton 'Try again'` + `OutlinedButton 'Another photo'`
(switches to the other ImageSource).
Full-height (Column + Expanded) so it doesn't slide up like a sheet.

**`analyzing_overlay.dart`**: dark overlay with the photo, a thin (2 px) glow line animated
with opacity — implemented with `TweenAnimationBuilder`-style paint layers.

## 7. Data facilities (`lib/data/`)

- `models/disease.dart`: used by all features; `name` is the user-facing corrected disease
  name, `modelLabel` keeps the raw model token (including "SHEALTH BLIGHT" typo).
- `models/scan_result.dart`: `ScanResult { String label; double confidence; }`.
- `models/saved_scan.dart` + `saved_scan.g.dart`: Hive `SavedScan` adapter (typeId 0), 6 fields.
- `repositories/disease_repository.dart`: `load()` (async, reads the bundled JSON asset),
  `all`, `fallback`,
  `byLabel` (case-insensitive). `matchByLabel`.
- `repositories/scan_repository.dart`: wraps the open `Box<SavedScan>`; `scans`
  (`_box.values.toList()`), `listenable` (ValueListenable), `add`, `deleteAt`.
- `repositories/settings_repository.dart` (see [[technical-decisions]] T2): SharedPreferences
  keys; `setConfidenceThreshold` clamps 0.5–1.0; `saveCustomModel` copies with a unique epoch
  name; `resetCustomModel` deletes copied files + removes keys.
- `services/inference_service.dart` (see [[ai-backend]]): `load` / `loadFromFile`;
  `_cleanLabels` strips "index" prefixes; `predict` uses `ResizeWithCropOrPadOp(minLength) →
  `ResizeOp(shapeLength, shapeLength, BILINEAR) → NormalizeOp(127.5, 127.5)`; `_topCategory`
  uses `TensorLabel.getMapWithFloatValue()` (linear max, no reliance on sort order).
- `services/image_service.dart`: `pick(source:Source) -> XFile?`, `decode(File) -> Image?` via
  `compute(_decodeBytes)`.

## 8. Saved (`lib/features/saved/`)

**`saved_page.dart`**:
- `ValueListenableBuilder` on `scans.listenable`; empty → "No plant diseases found."
- Card: white (radius 14, shadow), leading 52×52 `ClipRRect` thumbnail, title `plantName`,
  subtitle `formatTimestamp(dateCreated)`, trailing delete `IconButton`.
- Delete dialog: radius 16, title 'Delete scan?', content confirmation, actions aligned end:
  `TextButton 'Cancel'` + `FilledButton.icon` red 'Delete' with `Icons.delete_outlined`.
- Tap a card → `SavedDetailPage(scan)`.

**`saved_detail_page.dart`**:
- `Scaffold` background = `Color.lerp(lightGreenLeaves, white, .5)`.
- Top row: close `CircleIconButton` (left), print (`Icons.print`) (right).
- Hero card same shape as result view but with date chip `formatTimestamp`.
- Sections (Causes/Symptoms/Treatment) via `_detailSection` → `_cleanText`.
- PDF export (`_exportAsPdf`): 1 page with header row (name + optional 100×100 image), then
  label/value rows with `pw.Divider()`; writes to `getTemporaryDirectory()/plant_description.pdf`;
  shows a dialog with "OK" / "Open File" (`OpenFile.open`). Uses bundled font
  `assets/ArialUnicodeMS.ttf` for both normal+bold.

## 9. Settings (`lib/features/settings/settings_page.dart`)

- Background `lightGreenLeaves`-blend; AppBar white with title "Settings".
- `ThresholdCard`: slider `min 0.50 max 1.00 divisions 50`; % readout on the right.
- `ModelCard`:
  - shows current model filename (or "default model") + number of classes;
  - `OutlinedButton.icon` "Upload model (.tflite)" → `FilePicker.platform.pickFiles(
    allowedExtensions: ['tflite'])`; validates via loadFromFile then saveCustomModel + swap;
  - red "Reset to default model" → loads bundled defaults, `settings.resetCustomModel()`.
- Amber "Model requirements" note: square input (usually 224/256), one label per line,
  labels in model output order, mismatch → unrecognised. All async ops gated with `_busy`.

## 10. Dependencies (`pubspec.yaml`)

- Runtime deps as listed in [[PROJECT_CONTEXT]]#Tech stack, plus `file_picker ^4.6.0`
  (see [[technical-decisions]] T1). No `build_runner` in dev deps (adapter is hand-maintained).
- `flutter_lints` + `flutter_test` in dev. Assets list includes `assets/model/`,
  `assets/disease_data.json`, `assets/ArialUnicodeMS.ttf`, `assets/images/`, and the font files.

## 11. Assets / platform config

- `assets/model/` — `rice_disease_v1.tflite` + `labels.txt` (6 indexed labels); see
  [[PROJECT_CONTEXT]] and [[ai-backend]].
- `assets/disease_data.json` — catalog (id 0 = fallback "Fail to recognize").
- `android/app/build.gradle` — namespace/applicationId `com.agriguard.app`; jniLibs bundled
  for all 4 ABIs (see T19 in [[technical-debt]]).
- iOS scaffold provides `Info.plist` usage strings for `image_picker` (see
  [[permissions]]).

## 12. About (`lib/features/about/about_page.dart`)

Centered screen showing the app identity and team:

- `assets/images/rnsat_logo.png` (100×100) centered at the top.
- Centered description paragraph: AgriGuard is an AI-assisted mobile application
  designed to help farmers quickly identify common rice diseases using
  leaf images, supporting timely and informed crop-management decisions.
- "Developer" heading followed by three team members (Lahaina G. Anggaboy,
  Jay-em B. Delacruz, John Rey Lalic).
- "Adviser" heading followed by Ripple Jane H. Bato.
- Matches the `Icons.info_outline` tab icon in the shell's About tab.