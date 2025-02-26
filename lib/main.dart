
import 'models/plant_disease_model.dart';
import 'package:flutter/material.dart';
import 'splashScreen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;


Future<void> main() async {

    // Initialize Hive
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await pathProvider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

   // Register the PlantDiseaseAdapter
  Hive.registerAdapter(PlantDiseaseAdapter());

  // Open the box
  await Hive.openBox<PlantDisease>('plantDiseases');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Coffee Diagnostic',
      home: MySplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
