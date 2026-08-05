# Reusable Patterns

> Idioms present in the codebase that are worth extracting, keeping, or generalising.
> Each entry cites the concrete implementation it was observed in.

## 1. Self-contained TFLite classifier wrapper

**Where**: `lib/classifier/classifier.dart`

`Classifier` encapsulates everything an on-device ML consumer needs:

- private constructor + `static Future<Classifier?> loadWith(labelsFileName, modelFileName)`
  factory — callers never touch `Interpreter` directly;
- defensive `null`-return on load failure with `debugPrint` + stack trace;
- a `predict(Image) -> ClassifierCategory` API that hides preprocessing, inference, and
  post-processing;
- `close()` for interpreter teardown.

**Extract as**: a template for any TFLite image-classification feature. The preprocessing
pipeline (center-crop → `ResizeOp(inputShape[1])` → `NormalizeOp(127.5, 127.5)`) is already
generic; only the asset file names are app-specific. Consider pushing `labelsFileName` /
`modelFileName` into a config object.

## 2. Enum-driven result state machine

**Where**: `lib/ui/scan_page.dart:32-36`

```dart
enum _ResultStatus { notStarted, notFound, found }
```

A 3-state UI model (not-started / not-found / found) makes rendering logic a simple
`switch`/`if` over one variable instead of several booleans. Reusable for any async-result
screen (scan, upload, verify).

## 3. Static catalog + filter helpers

**Where**: `lib/models/plants.dart:124-133`, `lib/models/disease_description.dart:177-180`

Domain data lives as `static List<X>` on the model class with derived lists via
`.where(...)`:

```dart
static List<Plant> getFavoritedPlants() =>
    Plant.plantList.where((e) => e.isFavorated == true).toList();
```

Good pattern for small, read-only, offline content (dictionaries, disease sheets, help
entries). **Caveat**: it is only reusable if the data is actually immutable and the catalog
is not duplicated (see the `Plant`/`Disease` mismatch in [[technical-debt]]).

## 4. Custom widget composition with named constructors

**Where**: `lib/ui/screens/widgets/custom_textfield.dart`,
`lib/ui/screens/widgets/plant_photo_view.dart`

Reusable `StatelessWidget`s expose a small set of typed params (`icon`, `obscureText`,
`hintText`; `file`) and internally own all decoration. Auth screens reuse
`CustomTextfield` three times per form — a clean way to standardise inputs.

## 5. Consistent page transitions

**Where**: `page_transition` used across `root_page.dart`, `scan_page_gallery.dart`,
`home_page.dart`, `signin_page.dart`, `signup_page.dart`, `forgot_password.dart`

All content navigation uses `PageTransition(child: ..., type: PageTransitionType.bottomToTop)`.
A single app-wide transition style keeps UX consistent and is trivially centralisable into a
helper like `AppNavigator.push(context, widget)`.

## 6. Hive + TypeAdapter codegen persistence

**Where**: `lib/models/plant_disease_model.dart` + `.g.dart`, `lib/main.dart:13-21`

- Annotate a plain class with `@HiveType`/`@HiveField`, extend `HiveObject` to get a `key`
  (used for deletion in `favorite_page.dart:47`);
- regenerate the adapter with `build_runner`;
- initialise once (`Hive.init` + `registerAdapter` + `openBox`) in `main()`.

The box is reopened safely in `favorite_page.dart:13-16` via `await Hive.openBox` (idempotent),
so screens can fetch the box on demand. Reusable template for any local, structured store.

## 7. PDF export with bundled Unicode fallback font

**Where**: `lib/ui/screens/plant_description_page.dart:19-163`

- `pw.Document` → single `pw.Page` → label/value rows with `pw.Divider()`;
- `rootBundle.load('assets/ArialUnicodeMS.ttf')` gives a TTF that handles the bullet/Unicode
  glyphs in the disease copy;
- write to `getTemporaryDirectory()` then `OpenFile.open` after an alert dialog.

Reusable for reports/records. Note: bundling a 23 MB font is heavy — see [[technical-debt]].

## 8. Splash → onboarding gate via a flag

**Where**: `lib/splashScreen/splash_screen.dart:20-33`, `lib/ui/onboarding_screen.dart`

A single SharedPreferences boolean (`'repeat'`) records "onboarding completed", letting the
splash choose the entry point on each launch. Simple, robust first-run gating that needs no
extra packages.

## 9. Tab shell with `IndexedStack`

**Where**: `lib/ui/root_page.dart:67-70`

Keeping all four tab pages alive in an `IndexedStack` preserves per-tab scroll/state on tab
switches — a good default for a small fixed set of tabs.

## 10. Typed result value objects

**Where**: `lib/classifier/classifier_category.dart`, `lib/models/plant_disease_model.dart`

Small immutable DTOs with `toString()` overrides (`Category{label: ..., score: ...}`) make
debug output readable (`scan_page.dart` prints `'Top category: $topResult'`). Adopt for any
boundary between compute and UI.

---

**Summary of candidates to promote to shared code**: the `Classifier` pipeline (1), a
`AppNavigator` transition helper (5), a `Hive` box-access helper (6), and a reusable
`ResultView` widget for the found/not-found pattern (2). See [[architecture]] for how these
fit together.
