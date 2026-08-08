# Permissions

No user accounts, roles or server auth exist — the app is a single-user on-device tool.
Permissions below are the **OS-level** runtime/platform requirements.

## Android (`android/app/src/main/AndroidManifest.xml`)

- `android.permission.CAMERA` — `image_picker` camera capture (`ImageSource.camera`).
- `android.permission.READ_EXTERNAL_STORAGE` — gallery access on older APIs.
- **No internet permission is used**; inference is on-device. (Some plugins may add it in
  merged manifests; it is not required by the app's own code.)

## iOS

- `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` keys required by
  `image_picker` in `Info.plist`.
- `NSDocumentsFolderUsageDescription`-style keys may be surfaced by `file_picker`/`path_provider`
  when opening the picker — keep the usage strings meaningful.

## Runtime flows

- Picking images (scan + retry / "Another photo") and picking `.tflite`/`.txt` (Settings) both
  trigger OS permission prompts on first use.
- Cancel or denial simply returns `null` from the picker; the scan page pops / Settings page
  stays put — no crash path.