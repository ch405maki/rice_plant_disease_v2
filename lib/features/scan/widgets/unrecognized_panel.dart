import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../widgets/primary_button.dart';

/// Panel shown when the scan could not be confidently matched to a disease.
/// Shows the scanned image and offers photo tips and retry actions instead of
/// a fake result.
class UnrecognizedPanel extends StatelessWidget {
  const UnrecognizedPanel({
    Key? key,
    required this.confidenceLabel,
    required this.onRetry,
    required this.onChangePhoto,
    this.imageFile,
  }) : super(key: key);

  final String confidenceLabel;
  final VoidCallback onRetry;
  final VoidCallback onChangePhoto;
  final File? imageFile;

  static const _tips = <String>[
    'Use a clear, well-lit photo of the affected leaf.',
    'Fill the frame with the leaf and avoid blur.',
    'Hold the camera steady, close to the plant.',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeroCard(imageFile: imageFile, confidenceLabel: confidenceLabel),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 54,
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppConstants.primaryColor.withOpacity(.12),
                    ),
                    child: const Icon(
                      Icons.search_off,
                      size: 28,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'We couldn\'t identify this one',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'For a more reliable result:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                for (final tip in _tips)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            tip,
                            style: const TextStyle(fontSize: 14, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: 'Try again',
                        icon: Icons.refresh,
                        width: double.infinity,
                        onPressed: onRetry,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SecondaryButton(
                        label: 'Another photo',
                        onPressed: onChangePhoto,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.imageFile, required this.confidenceLabel});

  final File? imageFile;
  final String confidenceLabel;

  /// Renders the label as "Model confidence: X%" instead of "Accuracy: X%".
  String _toModelConfidence(String label) {
    const prefix = 'Accuracy';
    return label.startsWith(prefix)
        ? 'Model confidence${label.substring(prefix.length)}'
        : label;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 92,
              height: 92,
              child: imageFile == null
                  ? Container(
                      color: Colors.white.withOpacity(.15),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_outlined,
                        size: 30,
                        color: Colors.white70,
                      ),
                    )
                  : Image.file(
                      imageFile!,
                      fit: BoxFit.cover,
                      cacheWidth: 184,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Unidentified',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                if (confidenceLabel.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _toModelConfidence(confidenceLabel),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          side: BorderSide(color: AppConstants.primaryColor.withOpacity(0.6)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}