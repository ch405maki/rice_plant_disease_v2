import 'data/repositories/disease_repository.dart';
import 'data/repositories/scan_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/services/image_service.dart';
import 'data/services/inference_service.dart';

/// Wires the data layer together once in `main` and hands it to the UI.
class AppDependencies {
  AppDependencies({
    required this.diseases,
    required this.scans,
    required this.imageService,
    required this.settings,
    this.inference,
  });

  final DiseaseRepository diseases;
  final ScanRepository scans;
  final ImageService imageService;
  final SettingsRepository settings;

  /// Current inference engine. Swap this value to hot-swap the model (e.g. an
  /// uploaded `.tflite`). `null` when no model is loaded; the scan feature
  /// degrades to an error state instead of crashing.
  InferenceService? inference;
}