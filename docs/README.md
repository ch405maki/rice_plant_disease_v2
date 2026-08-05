# Vault Home

> Obsidian documentation vault for **Rice Plant Disease Detection**, a Flutter app that
> classifies rice plant photos on-device with TensorFlow Lit
>
> All notes are generated from the actual implementation in `lib/`, `assets/`, and
> `pubspec.yaml`. No placeholders.

## Notes

- [[PROJECT_CONTEXT|Project context]] — root context note at the vault root
- [[detailed-documentation|Detailed documentation]] — full per-module walkthrough of the implementation
- [[architecture|Architecture summary]] — layers, data flow, component responsibilities
- [[codebase-analysis|Codebase analysis]] — what the code does today, module by module
- [[reusable-patterns|Reusable patterns]] — idioms worth extracting and reusing
- [[technical-debt|Technical debt]] — defects, dead code, and improvement priorities

## How to navigate

1. Start with [[PROJECT_CONTEXT|PROJECT_CONTEXT]] for a 60-second overview.
2. Read [[codebase-analysis|Codebase analysis]] to understand each source file.
3. Read [[architecture|Architecture summary]] for the big picture.
4. Read [[detailed-documentation|Detailed documentation]] for the implementation specifics.
5. Reference [[technical-debt|Technical debt]] before making changes.

## Key facts

- **Model**: `assets/model_unquant.tflite`, 6 classes, unquantized, loaded via
  `tflite_flutter`. The quantized `assets/model.tflite` is not referenced anywhere in code.
- **Data**: two separate hardcoded static catalogs (`Plant` with 6 entries and `Disease`
  with 7 entries) plus a Hive box `plantDiseases` for saved scans.
- **Persistence**: Hive (scans), SharedPreferences (onboarding flag `repeat`).
- **Auth**: `signin_page.dart`/`signup_page.dart`/`forgot_password.dart` are UI-only;
  no authentication logic exists and they are unreachable in the shipped flow.
- **Tests**: `test/widget_test.dart` is broken boilerplate that imports
  `package:starter/main.dart` (wrong package name) and asserts on a counter that does not exist.
