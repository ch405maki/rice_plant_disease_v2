import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'app_dependencies.dart';
import 'core/constants/app_constants.dart';
import 'data/models/saved_scan.dart';
import 'data/repositories/disease_repository.dart';
import 'data/repositories/scan_repository.dart';
import 'data/services/image_service.dart';
import 'data/services/inference_service.dart';
import 'features/onboarding/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(SavedScanAdapter());
  await Hive.openBox<SavedScan>(AppConstants.hiveBoxName);

  final dependencies = AppDependencies(
    diseases: await DiseaseRepository.load(),
    scans: ScanRepository(Hive.box<SavedScan>(AppConstants.hiveBoxName)),
    imageService: ImageService(),
    inference: await InferenceService.load(),
  );

  runApp(MyApp(dependencies: dependencies));
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