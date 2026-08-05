import 'package:flutter/material.dart';

/// App-wide constants. Single source of truth for colors, asset paths,
/// storage keys and confidence thresholds.
class AppConstants {
  AppConstants._();

  // Palette
  static const Color primaryColor = Color(0xff296e48);
  static const Color panelColor = Color(0xFFA7C1B4);
  static const Color blackColor = Colors.black54;

  // Inference
  static const double confidenceThreshold = 0.95;
  // Paths exclude "assets/" for the model because Interpreter.fromAsset prepends it.
  static const String modelAsset = 'model/rice_disease_v1.tflite';
  static const String labelsAsset = 'assets/model/labels.txt';
  static const String diseaseDataAsset = 'assets/disease_data.json';

  // Persistence
  static const String prefsOnboardingKey = 'repeat';
  static const String hiveBoxName = 'plantDiseases';

  // Onboarding copy
  static const String titleOne = 'Early Detection for Healthier Harvests';
  static const String descriptionOne =
      'Stay ahead of potential threats to your rice crops. Our app helps you '
      'quickly identify and manage diseases to protect your yield.';
  static const String titleTwo = 'Reliable Disease Analysis';
  static const String descriptionTwo =
      'Simply upload photos of your rice plants, and our advanced detection '
      'system will pinpoint any diseases with precision.';
  static const String titleThree = 'Actionable Insights for Farmers';
  static const String descriptionThree =
      'Get tailored recommendations for treatment and prevention based on '
      'detected diseases, ensuring your fields remain productive and healthy.';
}
