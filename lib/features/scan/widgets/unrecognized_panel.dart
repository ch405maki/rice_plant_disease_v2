import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../widgets/primary_button.dart';

/// Panel shown when the scan could not be confidently matched to a disease.
/// Offers photo tips and retry/save actions instead of a fake result.
class UnrecognizedPanel extends StatelessWidget {
  const UnrecognizedPanel({
    Key? key,
    required this.confidenceLabel,
    required this.onRetry,
    required this.onChangePhoto,
    required this.onSave,
    this.saved = false,
  }) : super(key: key);

  final String confidenceLabel;
  final VoidCallback onRetry;
  final VoidCallback onChangePhoto;
  final VoidCallback onSave;
  final bool saved;

  static const _tips = <String>[
    'Use a clear, well-lit photo of the affected leaf.',
    'Fill the frame with the leaf and avoid blur.',
    'Hold the camera steady, close to the plant.',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.search_off,
            size: 46,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(height: 10),
          const Text(
            'We couldn\'t identify this one',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'The model wasn\'t confident enough to match this photo '
            'to a known disease.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Model confidence: $confidenceLabel',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Divider(height: 28),
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
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(fontSize: 13, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: saved ? null : onSave,
            icon: const Icon(Icons.bookmark_add_outlined, size: 18),
            label: Text(saved ? 'Saved' : 'Save as Unidentified'),
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