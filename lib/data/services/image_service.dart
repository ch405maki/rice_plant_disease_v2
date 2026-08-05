import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

/// Captures or picks a photo and decodes it off the UI isolate.
class ImageService {
  ImageService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Picks an image from the camera or gallery. Returns `null` if the user
  /// cancels.
  Future<XFile?> pick(ImageSource source) {
    return _picker.pickImage(source: source);
  }

  /// Reads and decodes a picked file. Decoding runs via `compute` so large
  /// photos do not block the UI isolate.
  Future<img.Image?> decode(File file) async {
    final bytes = await file.readAsBytes();
    return compute(_decodeBytes, bytes);
  }
}

img.Image? _decodeBytes(Uint8List bytes) => img.decodeImage(bytes);