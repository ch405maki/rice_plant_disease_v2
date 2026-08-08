# Module: Home

> Folder: `docs/vault/Modules/`

**Files:** `lib/features/home/home_page.dart`, `widgets/plant_card.dart`, `disease_dialog.dart`

## Purpose
Bundled disease catalogue browser: card grid → disease detail dialog.

## Behaviour
- `ListView` + `SafeArea` (no hard-coded bottom spacer); banner `ListTile`-styled image
  (margins `LTRB(20,12,20,16)`, radius 12, height 160).
- `PlantCard` (grid half-width): padded, rounded 84×84 image (radius 16), name normal font,
  subtitle = cleaned description snippet; card radius 14 on `panelColor`, soft shadow.
- Tap → `DiseaseDialog` (a `Dialog`, radius 14, width ~min(480, 92%)); full-bleed rounded cover
  image 200px with dark gradient overlay + top-close circle; disease **name** set in the **normal**
  font (bold, primary colour); scrollable, cleaned description with section labels; close button.

## Notable details
- `Disease` model fields: `name`, `causes`, `symptoms`, `treatment`, `modelLabel`, `diseaseIndex`.
- Description text cleaned: strips prefixes, "…more about these below", trailing `.` handling.
- `detail_page.dart` was **deleted** — dialog replaced it.