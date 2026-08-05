import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/disease.dart';

/// Scrollable scan result: a hero card with the scanned photo, disease name and
/// accuracy, followed by the description/symptoms/treatment sections.
class ResultView extends StatelessWidget {
  const ResultView({
    Key? key,
    required this.disease,
    required this.accuracyLabel,
    this.imageFile,
  }) : super(key: key);

  final Disease disease;
  final String accuracyLabel;
  final File? imageFile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeroCard(
          imageFile: imageFile,
          name: disease.name,
          accuracyLabel: accuracyLabel,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _InfoSection(
                  title: 'Description',
                  body: disease.causes,
                ),
                const SizedBox(height: 16),
                _InfoSection(
                  title: 'Symptoms',
                  body: disease.symptoms,
                ),
                const SizedBox(height: 16),
                _InfoSection(
                  title: 'Control / Interventions',
                  body: disease.treatment,
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
  const _HeroCard({
    required this.imageFile,
    required this.name,
    required this.accuracyLabel,
  });

  final File? imageFile;
  final String name;
  final String accuracyLabel;

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
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                if (accuracyLabel.isNotEmpty)
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
                          accuracyLabel,
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

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  static const _bodyStyle = TextStyle(
    fontSize: 14,
    height: 1.4,
    letterSpacing: 0.2,
    color: Colors.black54,
  );

  static final _labelRegExp = RegExp(r'^[A-Za-z][^:]*:\s*$');

  List<Widget> _renderedBody() {
    final widgets = <Widget>[];
    for (final rawLine in body.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;
      if (line.startsWith('•')) {
        widgets.add(_paragraph(line.replaceFirst('•', '').trim()));
      } else if (_labelRegExp.hasMatch(line)) {
        widgets.add(_label(line));
      } else {
        widgets.add(_paragraph(line));
      }
    }
    return widgets;
  }

  Widget _paragraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: _bodyStyle),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 0.3,
          color: AppConstants.primaryColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        ..._renderedBody(),
      ],
    );
  }
}