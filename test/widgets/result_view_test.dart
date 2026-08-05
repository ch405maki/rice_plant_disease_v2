import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agri_guard/data/models/disease.dart';
import 'package:agri_guard/features/scan/widgets/result_view.dart';

void main() {
  const disease = Disease(
    id: 1,
    name: 'Bacterial Blight',
    description: 'Caused by Xanthomonas',
    causes: 'Cause text',
    symptoms: 'Symptom text',
    treatment: 'Treatment text',
  );

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders disease name, accuracy and sections', (tester) async {
    await tester.pumpWidget(
      wrap(
        const ResultView(disease: disease, accuracyLabel: 'Accuracy: 98.50%'),
      ),
    );

    expect(find.text('Bacterial Blight'), findsOneWidget);
    expect(find.text('Accuracy: 98.50%'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Cause text'), findsOneWidget);
    expect(find.text('Symptoms'), findsOneWidget);
    expect(find.text('Control / Interventions'), findsOneWidget);
    expect(find.text('Treatment text'), findsOneWidget);
  });

  testWidgets('hides accuracy label when empty', (tester) async {
    await tester.pumpWidget(
      wrap(const ResultView(disease: disease, accuracyLabel: '')),
    );
    expect(find.textContaining('Accuracy'), findsNothing);
  });
}