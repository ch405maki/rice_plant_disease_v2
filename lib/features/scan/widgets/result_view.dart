import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_styles.dart';
import '../../../data/models/disease.dart';

/// Scrollable scan result: disease name, accuracy, and the
/// description/symptoms/treatment sections.
class ResultView extends StatelessWidget {
  const ResultView({
    Key? key,
    required this.disease,
    required this.accuracyLabel,
  }) : super(key: key);

  final Disease disease;
  final String accuracyLabel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(disease.name, style: kResultTextStyle),
          const SizedBox(height: 10),
          if (accuracyLabel.isNotEmpty)
            Text(accuracyLabel, style: kResultRatingTextStyle),
          const Divider(),
          _InfoSection(title: 'Description', body: disease.causes),
          const Divider(),
          _InfoSection(title: 'Symptoms', body: disease.symptoms),
          const Divider(),
          _InfoSection(title: 'Control / Interventions', body: disease.treatment),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppConstants.primaryColor,
        ),
      ),
      subtitle: Text(body, textAlign: TextAlign.justify),
    );
  }
}