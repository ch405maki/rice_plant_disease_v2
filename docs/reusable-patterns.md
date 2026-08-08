# Reusable Patterns

> Idioms present in the codebase that are worth extracting, keeping, or generalising.
> Each entry cites the concrete implementation it was observed in.

## 1. Self-contained TFLite classifier wrapper

**Where**: `lib/data/services/inference_service.dart`

`InferenceService` encapsulates everything an on-device ML consumer needs:

- private constructor + `static Future<InferenceService?> load(...)` factory — callers never
  touch `Interpreter` directly;
- defensive `null`-return on load failure (never throws) so the scan flow degrades to an
  error state instead of crashing;
- `predict(Image) -> ScanResult` hides preprocessing, inference, and post-processing;
- `dispose()` for interpreter teardown.

**Extract as**: a template for any TFLite image-classification feature. The preprocessing
pipeline (center-crop → `ResizeOp(inputShape[1])` → `NormalizeOp(127.5, 127.5)`) is already
generic; only the asset/type names are app-specific. The `loadFromFile` variant (user-supplied
tflite + optional labels) makes the wrapper reusable for model uploads.

## 2. Enum-driven result state machine

**Where**: `lib/features/scan/scan_page.dart`

```dart
enum _ScanStatus { idle, analyzing, success, error }
```

A 4-state UI model makes rendering logic a simple `switch`/`if` over one variable instead of
several booleans. Reusable for any async-result screen (scan, upload, verify).

## 3. ChangeNotifier over SharedPreferences for settings

**Where**: `lib/data/repositories/settings_repository.dart`

Persisted user settings (threshold, custom model/labels) are exposed as a `ChangeNotifier`;
the UI subscribes via `AnimatedBuilder` and the change is written back to prefs on each
setter. Combine with a `clamp` guard so persisted values stay in a valid range.

## 4. Single source-of-truth catalog + label lookup

**Where**: `lib/data/repositories/disease_repository.dart`, `lib/data/models/disease.dart`

Domain content (diseases) lives in one JSON asset that is parsed into typed records; all
UI/decision code looks it up by `modelLabel` (case-insensitive). This removes duplicated
static catalogs and index-mapping bugs.

## 5. Reusable widget composition with rounded, padded thumbnails

**Where**: `lib/features/home/widgets/plant_card.dart`,
`lib/features/scan/widgets/result_view.dart`, `lib/features/saved/saved_detail_page.dart`

The "hero card" idiom — rounded image in a padded, softly-rounded card — is repeated across
home, results, and saved detail. Extract a shared `RoundedThumb` / `HeroCard` widget if a
fourth use appears.

## 6. Hive + hand-maintained TypeAdapter codegen

**Where**: `lib/data/models/saved_scan.dart` + `saved_scan.g.dart`,
`lib/data/repositories/scan_repository.dart`

- A plain class with an adapter registered once in `main()` and a `Box` opened by name;
- a tiny repository exposes `listenable()` (`ValueListenable<Box>`) so the Saved tab updates
  live through `ValueListenableBuilder`, plus small `add`/`deleteAt` methods.

## 7. PDF export with bundled Unicode fallback font

**Where**: `lib/features/saved/saved_detail_page.dart`

- `pw.Document` → single `pw.Page` → `rootBundle.load('assets/ArialUnicodeMS.ttf')` for
  bullet/Unicode glyphs in the disease copy;
- write to `getTemporaryDirectory()` then `OpenFile.open`, with a dialog confirm.
- Note: the 23 MB font is heavy — see [[technical-debt]] T18.

## 8. Off-UI-isolate image decode

**Where**: `lib/data/services/image_service.dart`

`img.decodeImage` runs inside `compute()` so a large photo doesn't block the UI isolate. The
synchronous `Interpreter.run` call in `InferenceService.predict` is the remaining hot-path
(see T7 in [[technical-debt]]).

## 9. Splash → onboarding gate via a flag

**Where**: `lib/features/onboarding/splash_screen.dart`, `onboarding_screen.dart`

A single SharedPreferences boolean (`'repeat'`) records "onboarding completed", letting the
splash choose the entry point on each launch. Simple, robust first-run gating; `pushReplacement`
avoids re-entering the splash via back.

## 10. Tab shell with `IndexedStack`

**Where**: `lib/features/shell/root_page.dart`

Keeping all four tab pages alive in an `IndexedStack` preserves per-tab state on tab
switches — a good default for a small fixed set of tabs.

## 11. Typed result value objects

**Where**: `lib/data/models/scan_result.dart`

Small immutable DTOs (`ScanResult { label, confidence }`) keep the boundary between compute
and UI explicit.

---

**Summary of candidates to promote to shared code**: `AppDependencies`-style DI container (any
larger project), the `ScanResult`/`_ScanStatus` async-screen pattern (2), a shared
`RoundedThumbnail` widget (5), a `Boxed` repo pattern (6), and the TFLite classifier
wrapper (1).