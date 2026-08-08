import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

/// Persists user-controlled scan settings (accuracy threshold and a custom
/// uploaded model/labels) using SharedPreferences, and exposes them as a
/// [ChangeNotifier] so the UI stays in sync.
class SettingsRepository extends ChangeNotifier {
  static const _keyThreshold = 'confidence_threshold';
  static const _keyModelPath = 'custom_model_path';
  static const _keyLabelsPath = 'custom_labels_path';

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  double _threshold = AppConstants.confidenceThreshold;
  String? _customModelPath;
  String? _customLabelsPath;

  /// Confidence required for a match; range 0.50-1.00.
  double get confidenceThreshold => _threshold;

  /// Absolute path to the user-uploaded `.tflite` model, when set.
  String? get customModelPath => _customModelPath;

  /// Absolute path to the user uploaded `labels.txt` file, when set.
  String? get customLabelsPath => _customLabelsPath;

  bool get hasCustomModel => _customModelPath != null;

  /// Loads persisted values. Call once before first use.
  Future<void> init() async {
    final prefs = await _prefs;
    _threshold = (prefs.getDouble(_keyThreshold) ??
            AppConstants.confidenceThreshold)
        .clamp(0.50, 1.00)
        .toDouble();
    _customModelPath = prefs.getString(_keyModelPath);
    _customLabelsPath = prefs.getString(_keyLabelsPath);
    notifyListeners();
  }

  Future<void> setConfidenceThreshold(double value) async {
    _threshold = value.clamp(0.50, 1.00).toDouble();
    notifyListeners();
    final prefs = await _prefs;
    await prefs.setDouble(_keyThreshold, _threshold);
  }

  /// Copies the picked model file into the app documents dir and remembers it.
  /// Returns the new destination path, or `null` on failure.
  Future<String?> saveCustomModel(String sourcePath) async {
    final dest = await _copyIntoDocs(
      sourcePath,
      'agriguard_model_${DateTime.now().millisecondsSinceEpoch}.tflite',
    );
    if (dest == null) return null;
    _customModelPath = dest.path;
    notifyListeners();
    final prefs = await _prefs;
    await prefs.setString(_keyModelPath, _customModelPath!);
    return _customModelPath;
  }

  /// Copies the picked labels file into the app documents dir and persists it.
  /// Returns the new file path, or `null` on failure.
  Future<String?> saveCustomLabels(String sourcePath) async {
    final dest = await _copyIntoDocs(
      sourcePath,
      'custom_labels_${DateTime.now().millisecondsSinceEpoch}.txt',
    );
    if (dest == null) return null;
    _customLabelsPath = dest.path;
    notifyListeners();
    final prefs = await _prefs;
    await prefs.setString(_keyLabelsPath, _customLabelsPath!);
    return _customLabelsPath;
  }

  /// Removes the uploaded model and labels, reverting to the bundled defaults.
  Future<void> resetCustomModel() async {
    for (final path in [_customModelPath, _customLabelsPath]) {
      if (path == null) continue;
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
    _customModelPath = null;
    _customLabelsPath = null;
    notifyListeners();
    final prefs = await _prefs;
    await prefs.remove(_keyModelPath);
    await prefs.remove(_keyLabelsPath);
  }

  Future<File?> _copyIntoDocs(String sourcePath, String fileName) async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dest = File('${docs.path}${Platform.pathSeparator}$fileName');
      if (await dest.exists()) await dest.delete();
      return File(sourcePath).copy(dest.path);
    } catch (_) {
      return null;
    }
  }
}