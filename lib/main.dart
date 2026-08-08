import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'app_dependencies.dart';
import 'core/constants/app_constants.dart';
import 'data/models/saved_scan.dart';
import 'data/repositories/disease_repository.dart';
import 'data/repositories/scan_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/services/image_service.dart';
import 'data/services/inference_service.dart';
import 'features/onboarding/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(SavedScanAdapter());
  await Hive.openBox<SavedScan>(AppConstants.hiveBoxName);

  final settings = SettingsRepository();
  await settings.init();

  final inference = await _loadPersistedOrBundledModel(settings);
  final dependencies = AppDependencies(
    diseases: await DiseaseRepository.load(),
    scans: ScanRepository(Hive.box<SavedScan>(AppConstants.hiveBoxName)),
    imageService: ImageService(),
    settings: settings,
    inference: inference,
  );

  runApp(MyApp(dependencies: dependencies));
}

/// Loads the user's previously uploaded model when available and valid,
/// otherwise falls back to the bundled default.
Future<InferenceService?> _loadPersistedOrBundledModel(
  SettingsRepository settings,
) async {
  final modelPath = settings.customModelPath;
  if (modelPath != null) {
    final labelsPath = settings.customLabelsPath;
    final service = await InferenceService.loadFromFile(
      modelFile: File(modelPath),
      labelsFile: labelsPath != null ? File(labelsPath) : null,
    );
    if (service != null) return service;
  }
  return InferenceService.load();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.dependencies}) : super(key: key);

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriGuard',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(dependencies: dependencies),
    );
  }
}