import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agri_guard/core/utils/formatters.dart';
import 'package:agri_guard/widgets/primary_button.dart';

void main() {
  test('formatAccuracy renders percentage with two decimals', () {
    expect(formatAccuracy(0.9851), 'Accuracy: 98.51%');
    expect(formatAccuracy(0.0), 'Accuracy: 0.00%');
  });

  test('formatTimestamp truncates to date and time', () {
    expect(
      formatTimestamp('2026-08-05T12:34:56.789'),
      '2026-08-05 12:34',
    );
  });

  testWidgets('PrimaryButton renders label and fires callback', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            label: 'Camera',
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Camera'), findsOneWidget);
    await tester.tap(find.text('Camera'));
    expect(pressed, isTrue);
  });
}