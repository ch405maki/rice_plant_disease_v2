# Module: Saved

> Folder: `docs/vault/Modules/`

**Files:** `lib/features/saved/saved_page.dart`, `saved_detail_page.dart`

## Purpose
Hive-persisted scan history: list, detail viewer, PDF export, delete.

## Behaviour
- List: Big intention rounded cards (white, radius 14) with 52×52 rounded thumbnail, disease
  name + date; delete via trailing icon or swipe; for PDF rows the leading icon is a PDF chip.
- **Delete dialog**: radius 16, `textAlign.start`, red `Icons.delete_outline`-leading, buttons
  sized to content and aligned end (`Cancel` first, then `Delete`).
- **PDF dialog**: same styling, green on-tap, `Icons.file_open_outlined`.
- **Detail page** reuses Result-page language: fixed hero card (rounded photo, name chip with
  `Icons.calendar_today_outlined` + date), sections Causes/Symptoms/Treatment, rounded buttons
  "Export as PDF" + "Close" above scroll, light `lightGreenLeaves`‑blend background.

## Contracts
- `ScanRepository`: `ValueListenable<Box<SavedScan>>`, `add`, `deleteAt`, list of `SavedScan`.
- `SavedScan`: `plantName, causes, symptoms, treatment, imageBytes (Uint8List), dateCreated`.
- `_exportAsPdf` writes a 1-page PDF to `getTemporaryDirectory()` and opens via `open_file`.

## Notable details
- Delete is from history only; images are discarded with the record (no garbage collection).
- Clearing all uses a `showDialog` barrier, then `Hive.box<SavedScan>().clear()`.
- `dateCreated` stored as ISO-8601 string; rendered via `format(savedDate)`.