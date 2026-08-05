# Codebase Analysis

> What the code actually does today — file by file, with counts and cross-references.
> Derived from the implementation. See also [[detailed-documentation]] and
> [[technical-debt]].

## Inventory

- **Dart sources**: 28 files under `lib/` (26 Dart + 1 generated adapter `*.g.dart`)
- **Tests**: 1 file (`test/widget_test.dart`) — broken boilerplate (see below)
- **Assets**: 6 labels/model files, 20 images, 4 fonts
- **Single commit** on `master`: `f0a9180` "Final Fine Tuned" (Feb 2025)

## Module-by-module

### `lib/main.dart` — bootstrap
- Initialises Hive, registers `PlantDiseaseAdapter` (typeId 0), opens box `plantDiseases`,
  runs `MyApp`.
- `MyApp` title is `'Coffee Diagnostic'` — inconsistent with the repo purpose.
- Imports `material.dart` twice.

### `lib/splashScreen/splash_screen.dart` — startup gate
- 3 s timer → SharedPreferences `'repeat'` decides onboarding vs `RootPage`.
- Uses `push`, not `pushReplacement`; splash stays in the back stack.

### `lib/ui/onboarding_screen.dart` — intro
- 3 identical-image pages fed by `Constants` copy.
- Sets `'repeat' = true` then `pushReplacement` to `RootPage`.
- Imports `global/global.dart` but never uses `id`.

### `lib/ui/root_page.dart` — shell
- `IndexedStack` + fixed 4-item `BottomNavigationBar`.
- Tab 2 refresh assigns `favorites = Plant.getFavoritedPlants()` but nothing renders it.

### `lib/ui/scan_page_gallery.dart` — chooser
- Two buttons that push `ScanPage(value: 1 | 2)`.

### `lib/ui/scan_page.dart` — core screen
- The only place that touches the classifier, image picker, `image` decode, and the Hive save.
- Hardcoded model/labels asset names (lines 18-19).
- Force-unwraps the classifier result (line 91) — app would crash if model fails to load.
- Threshold `0.95` hardcoded (line 358).
- Label→catalog mapping is an `if/else` chain against uppercase strings (lines 380-391),
  including the `'SHEALTH BLIGHT'` typo that matches the labels file.
- `_saveData()` runs on every bookmark press even when un-bookmarking.
- Synchronous `readAsBytesSync()` + `decodeImage` run on the UI isolate (jank risk).
- 472 lines — the largest and most entangled file in the app.

### `lib/classifier/*` — inference
- `Classifier`: `loadWith` factory, `predict`, pre/post-processing, `close`.
- Clean separation: preprocessing chain (crop → bilinear resize → normalize 127.5/127.5),
  output as sorted `List<ClassifierCategory>`.
- Sort comparator is a non-strict ordering `(b.score > a.score ? 1 : -1)`.
- `ClassifierCategory` and `ClassifierModel` are simple value/holder types.

### `lib/models/*` — data
- `Plant`: 6-entry static catalog, filtered by `getFavoritedPlants()`/`addedToCartPlants()`.
- `Disease`: 7-entry static catalog with causes/symptoms/treatment copy; index 0 is the
  "Fail to recognise" fallback.
- `PlantDisease` + generated adapter: Hive entity for saved scans (text + `Uint8List?` image + date).
- The two catalogs are **not aligned** (6 vs 7 entries; differing index→name maps) — the
  biggest data-model hazard.

### `lib/ui/screens/home_page.dart` — browsing
- Banner + first catalog item + vertical list; toggles `isFavorated` in memory only.

### `lib/ui/screens/detail_page.dart` — plant detail
- Reads `Plant.plantList` by `plantId`.
- Favorite toggle is visually dead (the `onTap` pops instead of toggling; see lines 58-79).
- Unused `PlantFeature` widget defined in the same file.

### `lib/ui/screens/favorite_page.dart` — saved scans
- Lists Hive `PlantDisease` rows; delete with confirm dialog; `FutureBuilder` on
  re-opened box. `_truncateText` unused.

### `lib/ui/screens/plant_description_page.dart` — saved detail + PDF
- Full detail view of a saved scan; exports to PDF with `ArialUnicodeMS.ttf` fallback.
- **Defines its own `Constants` class** (line 322) shadowing the global one.

### `lib/ui/screens/profile_page.dart` — credits
- Static capstone credit screen; no logic.

### `lib/ui/screens/signin_page.dart` / `signup_page.dart` / `forgot_password.dart` — auth stubs
- No validation, no state, no backend. Sign In just goes to `RootPage`. Unreachable in the
  shipped flow (only a commented-out reference exists in onboarding).

### `lib/ui/screens/widgets/*`
- `custom_textfield.dart`: used by auth screens.
- `plant_photo_view.dart`: used by `ScanPage` (photo preview + empty state).
- `plant_widget.dart`: **unused** (duplicates home list item UI).
- `profile_widget.dart`: **unused**.

### `lib/style/styles.dart` / `lib/constants.dart`
- Design tokens (colors, fonts, text styles) and onboarding copy.
- Many screens still hardcode `Color(0xff296e48)` / `Color(0xFFA7C1B4)` inline.

### `lib/global/global.dart`
- Single global `int id = 0`; imported by 3 files, read by none.

## Tests

`test/widget_test.dart` cannot pass:

- Imports `package:starter/main.dart` — the package is `RicePlantDiseaseDetection`, so the
  import fails to resolve.
- Asserts on a counter app (`Icons.add`, text `'0'`/`'1'`) that does not exist in `MyApp`.
- No test files exist for the classifier, models, or any widget.

## Verification commands

From repo root:

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # regenerate hive adapter
flutter analyze
flutter test
```

(Not executed here — the analysis in [[technical-debt]] is based on static review of the
source as committed at `f0a9180`.)

## Cross-references

- Data flow diagrams: [[architecture]]
- Per-module detail: [[detailed-documentation]]
- Things to fix: [[technical-debt]]
