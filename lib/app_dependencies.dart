import 'data/repositories/disease_repository.dart';
import 'data/repositories/scan_repository.dart';
import 'data/services/image_service.dart';
import 'data/services/inference_service.dart';

/// Wires the data layer together once in `main` and hands it to the UI.
class AppDependencies {
  const AppDependencies({
    required this.diseases,
    required this.scans,
    required this.imageService,
    this.inference,
  });

  final DiseaseRepository diseases;
  final ScanRepository scans;
  final ImageService imageService;

  /// `null` when the model failed to load; the scan feature degrades to an
  /// error state instead of crashing.
  final InferenceService? inference;
}