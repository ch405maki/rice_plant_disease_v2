# Detailed Documentation

> Derived from the implementation. Every statement below traces to a specific file/line in
> this repository. Related: [[architecture]], [[codebase-analysis]], [[reusable-patterns]],
> [[technical-debt]].

---

## 1. Application entry (`lib/main.dart`)

`main()` is fully async:

1. `WidgetsFlutterBinding.ensureInitialized()` — line 13
2. Resolves the app documents directory via `path_provider` and calls `Hive.init(...)` — lines 14-15
3. Registers `PlantDiseaseAdapter()` — line 18
4. Opens the Hive box named `'plantDiseases'` typed as `Box<PlantDisease>` — line 21
5. `runApp(MyApp())` — line 23

`MyApp` is a `StatelessWidget` that builds a `MaterialApp` (lines 26-36):

- `title: 'Coffee Diagnostic'` (mismatched with the project name)
- `home: MySplashScreen()`
- `debugShowCheckedModeBanner: false`

Note: `package:flutter/material.dart` is imported twice (lines 3 and 5).

## 2. Splash and first-run gating (`lib/splashScreen/splash_screen.dart`)

- Renders a solid `Constants.primaryColor` screen with `assets/images/code-scan-two.png` centered (lines 43-55).
- `startTimer()` (lines 20-33) fires a 3-second `Timer` that reads SharedPreferences key
  `'repeat'` (a `bool?`):
  - `null` → `Navigator.push` to `OnboardingScreen`
  - otherwise → `Navigator.push` to `RootPage`
- The navigation uses plain `MaterialPageRoute`; no `pushReplacement`, so back behavior
  can re-enter the splash.

## 3. Onboarding (`lib/ui/onboarding_screen.dart`)

- `PageController` with 3 pages (lines 18, 60-84); each page reuses `assets/images/plant.png`
  with title/description from `Constants` (`constants.dart:10-15`).
- Skip button (lines 31-43): sets `'repeat' = true` in SharedPreferences then
  `pushReplacement` to `RootPage`.
- Next arrow button (lines 96-115): advances the `PageController`; on the last page it sets
  `'repeat' = true` and replaces with `RootPage`.
- Animated page indicators: `AnimatedContainer` (active 20 px wide, inactive 8 px, lines 136-162).
- The `createPage` widget (lines 165-218) is a stateless layout: image (350 px), bold title
  (`fontSize: 30`), grey description (`fontSize: 20`).
- `global/global.dart` is imported (line 6) but its `id` variable is never read here.
- The commented-out route in the Skip handler (`signin_page.dart`) indicates auth screens
  were intended but the app navigates to `RootPage` instead.

## 4. Root shell (`lib/ui/root_page.dart`)

`RootPage` is a `StatefulWidget` hosting a 4-tab `BottomNavigationBar` (type `fixed`) over an
`IndexedStack` (lines 67-70):

| Index | Tab | Widget | File |
|-------|-----|--------|------|
| 0 | Home | `HomePage` | `screens/home_page.dart` |
| 1 | Scan | `ScanPageGallery` | `scan_page_gallery.dart` |
| 2 | Saved | `PlantListPage` | `screens/favorite_page.dart` |
| 3 | Profile | `ProfilePage` | `screens/profile_page.dart` |

- App bar shows the active tab label, bold black54 24 pt (lines 51-66).
- On tab tap (lines 78-85): `_currentIndex` is set; for index 2 it refreshes
  `favorites = Plant.getFavoritedPlants()` — but `favorites` is never rendered anywhere.
- `FloatingActionButtonLocation.centerDocked` is set with no FAB (line 87).

## 5. Home (`lib/ui/screens/home_page.dart`)

- Reads the static `Plant.plantList` (line 19).
- Banner: `assets/images/banner.jpg`, `Colors.green[100]` backdrop, 150 px tall (lines 67-93).
- "Healthy Rice plant" section renders `_plantList[0]` (`_buildFirstPlantItem`, lines 95-193):
  a 100 px row with 80x80 image, name, `decription` clamped to 3 lines, and a bookmark
  `IconButton` that toggles `plant.isFavorated` in place.
- "Rice Plant Diseases" section (`_buildVerticalPlantList`, lines 195-301) is a
  `ListView.builder` with `itemCount = _plantList.length - 1` and `index + 1` so it skips the
  healthy plant.
- Both sections navigate with `PageTransition<DetailPage>(type: bottomToTop)` to
  `DetailPage(plantId: plant.plantId)`.
- Two private toggle helpers (`toggleIsFavorited`, line 21) duplicate `DetailPage`'s helpers.

## 6. Scan chooser (`lib/ui/scan_page_gallery.dart`)

- Landing tab for Scan (lines 16-135): shows `assets/images/code-scan.png` and
  "Please choose an option".
- "Camera" button → `ScanPage(value: 1)`; "Pick from Gallery" button → `ScanPage(value: 2)`,
  both via `PageTransitionType.bottomToTop`.
- Buttons are 250x50 `TextButton` containers with `Constants.primaryColor` fill.

## 7. Classification screen (`lib/ui/scan_page.dart`)

Constants (lines 18-19):

```dart
const _labelsFileName = 'assets/labels.txt';
const _modelFileName = 'model_unquant.tflite';
```

State (lines 38-57): `_deseaseList` from `Disease.plantList`, `selectedIndex`,
`_isAnalyzing`, `ImagePicker`, `_selectedImageFile`, `plantIdSelector`, `_ResultStatus`
enum (`notStarted`/`notFound`/`found`), `_plantLabel`, `_accuracy`, a lazily-assigned
`late Classifier _classifier`, and `isBookmarked`.

Lifecycle (lines 60-92):

- `initState` dispatches on `widget.value`: `1` → camera pick, `2` → gallery pick, then
  starts `_loadClassifier()`.
- `_loadClassifier()` calls `Classifier.loadWith(labelsFileName, modelFileName)` and
  assigns with force-unwrap `_classifier = classifier!` (line 91).

Photo picking (`_onPickPhoto`, lines 336-349):

- `picker.pickImage(source: source)`; if null the flow stops.
- Sets `_selectedImageFile`, then `_analyzeImage(file)`.

Inference (`_analyzeImage`, lines 351-371):

- `img.decodeImage(file.readAsBytesSync())!` (synchronous read on the UI isolate).
- `_classifier.predict(imageInput)` → `ClassifierCategory`.
- `score >= 0.95` → `found`, else `notFound` (line 358).
- Captures `label` and `score`.

Label→catalog mapping (`_buildResultView`, lines 373-395): hardcoded string matching,
e.g. `'BACTERIAL BLIGHT'` → `plantIdSelector = 1`, `'SHEALTH BLIGHT'` → `5`. The matched
strings mirror `assets/labels.txt` verbatim (including the `SHEALTH` typo).

Result rendering (lines 403-469):

- Title = `Disease.plantList[plantIdSelector].plantName`.
- Accuracy label: `'Accuracy: ${(_accuracy * 100).toStringAsFixed(2)}%'`.
- Three `ListTile`s separated by dividers: Description (`causes`), Symptoms (`symptompts`),
  Control / Interventions (`treatment`), all `TextAlign.justify`.
- On `notFound`, `plantIdSelector` stays 0 → "Fail to recognise" is shown.

Saving to Hive (`_saveData`, lines 95-114):

- Writes a new `PlantDisease` from `Disease.plantList[plantIdSelector]` into the
  `'plantDiseases'` box.
- If `_selectedImageFile != null`, reads bytes into `Uint8List` and stores on `imageBytes`.
- `dateCreated` is `DateTime.now().toString()`.
- The bookmark button in the top-right (lines 157-181) toggles `isBookmarked` and calls
  `_saveData()` on every press, regardless of bookmark state.

UI layout (lines 116-249): `Stack` with

- photo preview `_buildPhotolView` positioned either centered-empty or full-screen,
- top-right bookmark button + top-left close button,
- a bottom sheet `Color(0xFFA7C1B4)` (60% of screen height) hosting the result,
- a bottom control bar with camera button (white circle, `_buildPickPhotoButton`) and
  gallery button (primary fill, `_buildPickPhotoButtonGalery`).

## 8. Classifier (`lib/classifier/`)

### 8.1 `classifier.dart`

`Classifier` is a private-constructor class (`Classifier._`) holding `_labels` and `_model`.

Factory `loadWith` (lines 23-38):

- Loads labels via `FileUtil.loadLabels(labelsFileName)`.
- Loads model via `Interpreter.fromAsset(modelFileName)`.
- Returns `null` on any error (logged with `debugPrint` + stack).
- Labels are normalized by dropping the numeric prefix: `label.substring(label.indexOf(' ')).trim()`
  (lines 66-76).

`_loadModel` (lines 40-64) reads tensor 0 shapes and `TfLiteType`s from the interpreter and
wraps them in `ClassifierModel`.

`predict(Image)` (lines 82-114):

1. `_preProcessInput(image)` → `TensorImage`.
2. `TensorBuffer.createFixedSize(_model.outputShape, _model.outputType)`.
3. `interpreter.run(inputImage.buffer, outputBuffer.buffer)`.
4. `_postProcessOutput(...)` returns sorted `List<ClassifierCategory>`.
5. Returns the top (highest score) category.

`_postProcessOutput` (lines 116-132): builds a `TensorProcessorBuilder`, applies it, maps
scores to labels via `TensorLabel.getMapWithFloatValue()`, then sorts descending by score.
The sort comparator `(b.score > a.score ? 1 : -1)` is not a strict total order, but the
result happens to order by score.

`_preProcessInput` (lines 134-161) builds an `ImageProcessorBuilder` chain:

1. `TensorImage(inputType)` + `loadImage`
2. `ResizeWithCropOrPadOp(minLength, minLength)` — center-square crop
3. `ResizeOp(inputShape[1], inputShape[1], BILINEAR)` — square resize to model input
4. `NormalizeOp(127.5, 127.5)` — normalize to `[-1, 1]`
5. build + process.

`close()` (lines 78-80) closes the interpreter.

### 8.2 `classifier_category.dart`

Immutable `{label: String, score: double}` with `toString()` override (11 lines).

### 8.3 `classifier_model.dart`

Plain holder for `Interpreter`, `inputShape`, `outputShape`, `inputType`, `outputType`
(19 lines). No lifecycle management.

## 9. Models / data layer

### 9.1 `Plant` (`lib/models/plants.dart`)

Immutable catalog record with `plantId`, `category`, `plantName`, `imageURL`, `imageURL2`,
`isFavorated`, `decription` (typo for "description"), `isSelected`.

Static `plantList` (6 entries, indices 0-5):

| ID | Name | Image |
|----|------|-------|
| 0 | Normal and Healthy Rice plant | `assets/images/normal.jpg` |
| 1 | Bacterial Blight | `bacterialblight.jpg` |
| 2 | Brown Spot | `brownspot.jpg` |
| 3 | Leaf Blast | `leafblast.jpeg` |
| 4 | Sheath Blight | `shielthblight.jpg` |
| 5 | Tungro | `tungro.jpg` |

Static helpers: `getFavoritedPlants()` (lines 124-127) and `addedToCartPlants()` (lines
130-133) filter the static list. `addedToCartPlants` is unused.

### 9.2 `Disease` (`lib/models/disease_description.dart`)

Mirror catalog with `plantId`, `plantName`, `causes`, `symptompts` (typo), `treatment`,
`isFavorated`, `isSelected`.

Static `plantList` (7 entries, indices 0-6):

| ID | Name |
|----|------|
| 0 | Fail to recognise (fallback / unknown) |
| 1 | Bacterial Blight |
| 2 | Brown Spot |
| 3 | Leaf Blast |
| 4 | Normal and Healthy Rice plant |
| 5 | Sheath Blight |
| 6 | Tungro |

Each entry carries full agronomic copy: pathogen name, causes, damage/yield-loss notes, and
treatment bullets (e.g. Xanthomonas for blight, Bipolaris oryzae for brown spot,
Pyricularia oryzae for leaf blast, Rhizoctonia solani for sheath blight, RTBV for tungro).

`getFavoritedPlants()` (lines 177-180) returns all entries where `isFavorated == true`
(currently all 7, since every entry is initialized to `true`).

### 9.3 `PlantDisease` (`lib/models/plant_disease_model.dart` + `.g.dart`)

Hive model, `typeId: 0`, extends `HiveObject` (gives a `key` used for deletion):

| Field | Hive index | Type |
|-------|-----------|------|
| `plantName` | 0 | String |
| `causes` | 1 | String |
| `symptoms` | 2 | String |
| `treatment` | 3 | String |
| `imageBytes` | 4 | `Uint8List?` |
| `dateCreated` | 5 | String |

`plant_disease_model.g.dart` is the generated `PlantDiseaseAdapter` (read/write, 6 fields,
`typeId 0`). Regenerate with `dart run build_runner build`.

## 10. Saved scans (`lib/ui/screens/favorite_page.dart`)

`PlantListPage` (registered as the "Saved" tab):

- `_openBox()` re-opens `'plantDiseases'` and returns the box (lines 13-16).
- `FutureBuilder<Box<PlantDisease>>` renders: spinner while waiting, error text, "No plant
  diseases found." when empty, else a `ListView.builder` of `ListTile`s (lines 67-111).
- Each tile: title = `plantName`, subtitle = `dateCreated.substring(0, 16)` (first 16 chars
  of the full `DateTime.toString()`).
- Delete button opens a confirmation `AlertDialog`; on confirm it deletes by
  `plantDiseases[index].key` and calls `setState` (lines 18-50).
- Tap navigates to `PlantDescriptionPage(plantDisease: ...)`.
- `_truncateText` helper (lines 53-59) is defined but never called.
- The `appBar` is commented out; the tab title comes from `RootPage`'s app bar.

## 11. Saved scan detail + PDF export (`lib/ui/screens/plant_description_page.dart`)

- `StatelessWidget` over a single `PlantDisease` (line 14).
- Top-left close button, top-right print button.
- Shows the captured `imageBytes` with `Image.memory` at full width (lines 171-178).
- Content: name (`kResultTextStyle`) + Causes / Symptoms / Treatment `ListTile`s inside a
  530 px scroll area on `Color(0xFFA7C1B4)` (lines 229-315).

`_exportAsPdf` (lines 19-163):

- Builds a `pw.Document`.
- Loads `assets/ArialUnicodeMS.ttf` via `rootBundle` as a fallback font; reuses the same
  TTF for normal and "bold" weights (lines 23-25).
- One page: header row (name + optional 100x100 image), then `Causes`/`Symptoms`/`Treatment`
  label-column + value rows with dividers, green label text (`PdfColors.green`).
- Writes to `${getTemporaryDirectory()}/plant_description.pdf`.
- Shows a dialog with **OK** and **Open File** (`OpenFile.open`).

**Important**: this file redefines `class Constants { static const Color primaryColor = Color(0xff296e48); }`
at lines 322-324, shadowing `lib/constants.dart` within this file (import of `../../constants.dart`
is absent here).

## 12. Plant detail (`lib/ui/screens/detail_page.dart`)

- `DetailPage(plantId)` reads `Plant.plantList` by index (line 30).
- `Stack` layout: close + favorite toggles at top (lines 34-83), full-bleed
  `imageURL2` in a 0.2x0.8 sized container (lines 84-98), a bottom `Color(0xFFA7C1B4)` panel
  (60% height) with the plant name and `decription` (lines 99-152).
- The favorite icon reflects `_plantList[widget.plantId].isFavorated` but the `onTap`
  wrapper also pops the page (lines 58-79); the favorite state is never toggled here.
- A floating action row (lines 155-186) contains a 50 px circle with a back arrow that only
  calls `Navigator.pop`; the empty sibling `SizedBox(width: 20)` leaves the row half-empty.
- `PlantFeature` (lines 191-221) is a small title/feature text widget that is **not used**
  by any screen.

## 13. Auth screens (`lib/ui/screens/signin_page.dart`, `signup_page.dart`, `forgot_password.dart`)

- `CustomTextfield` inputs (`custom_textfield.dart`: borderless `TextField` with prefix icon,
  hint, and cursor color) — no controllers, no validation, no state.
- Sign In button navigates straight to `RootPage` (lines 48-74) — no credentials check.
- Forgot Password button → `ForgotPassword`; "Register" → `SignUp`.
- `SignUp`'s Sign Up button and `ForgotPassword`'s Reset button have empty `onTap` (no-op).
- Google buttons are static images (`assets/images/google.png`) with no auth handler.
- All transitions use `PageTransitionType.bottomToTop`.
- These screens are unreachable in the current flow: `OnboardingScreen` navigates to
  `RootPage`, and the only reference to `SignIn` is in a commented-out line
  (`onboarding_screen.dart:39`).

## 14. Profile (`lib/ui/screens/profile_page.dart`)

- Static, non-interactive credit screen for the capstone:
  - University logos (`logo1.png`, `logo2.png`) and "Kalinga State University / Bulanao,
    Tabuk City, Kalinga" header (lines 26-50).
  - Title "Rice Plant Disease Detector App: With Drone Integration" (lines 60-67).
  - Capstone boilerplate and author list (lines 69-86).

## 15. Styling (`lib/style/styles.dart` and `lib/constants.dart`)

`styles.dart`:

- Font names: `kMainFont = 'Roboto'`, `kButtonFont = 'Roboto'`,
  `kDisplayFont = 'SquadaOne'` (lines 3-5).
- Color constants: three palettes (green/light-green/brown/cream; red family; a second
  green set) plus named `lightGreenLeaves`, `matureGreenLeaves`, `riceGrainBeige`,
  `soilBrown`, `waterReflectionBlue` (lines 7-26).
- `kTitleTextStyle`, `kAnalyzingTextStyle`, `kResultTextStyle`, `kResultRatingTextStyle`
  (lines 30-53).
- Font families used are declared in `pubspec.yaml` (`SquadaOne`, `ContrailOne`, `Roboto`).

`constants.dart`:

- `Constants.primaryColor = Color(0xff296e48)`, `blackColor = Colors.black54` (lines 6-7).
- Onboarding copy: three title/description pairs (lines 10-15).
- Hardcoded `Color(0xff296e48)` and `Color(0xFFA7C1B4)` also appear inline in several
  screens instead of referencing `Constants`.

## 16. Assets

- `assets/labels.txt` — 6 labels, indexed 0-5 (see [[PROJECT_CONTEXT]]).
- `assets/model.tflite` — quantized model, **not referenced** in any Dart source.
- `assets/model_unquant.tflite` — the model loaded by `scan_page.dart`.
- `assets/ArialUnicodeMS.ttf` — 23 MB, used only by the PDF exporter.
- `assets/SquadaOne-Regular.ttf`, `assets/ContrailOne-Regular.ttf`, `assets/Roboto-Light.ttf`
  — declared fonts.
- `assets/images/` — 20 images (catalog photos, banners, icons, auth illustrations).
- Model weights are downloaded into `android/app/src/main/jniLibs/` by `install.bat` /
  `install.sh` (TensorFlow Lite C shared libraries, TF 2.5, x86/arm/arm64).

## 17. Platform config (`android/app/build.gradle`)

- `compileSdkVersion 34`, `minSdkVersion 21`, Kotlin/JVM 1.8.
- `applicationId "com.dev.mark"` (placeholder; flagged with a TODO in the file).
- Release builds sign with debug keys (`signingConfigs.debug`).
- `flutter.ndkVersion` is used for NDK; `build_runner` and `hive_generator` are dev deps.

## 18. Dependencies (`pubspec.yaml`)

Used in code:

- `flutter` (SDK), `image_picker`, `image`, `tflite_flutter`, `tflite_flutter_helper`
  (git ref `783f15e5...`), `page_transition`, `shared_preferences`, `hive`, `hive_flutter`,
  `path_provider`, `pdf`, `open_file`, `cupertino_icons` (standard template dep),
  `intl` (not imported anywhere, but listed).

Declared but not imported anywhere under `lib/`:

- `collection`, `animated_bottom_navigation_bar`, `onboarding`, `flutter_onboarding`,
  `get`, `json_annotation` (the `json_annotation` import belongs to `tflite_flutter_helper`
  in practice; not used in this repo's Dart).

Dev: `flutter_lints`, `flutter_test`, `build_runner`, `hive_generator`.

See also [[technical-debt]] for the consequences.
