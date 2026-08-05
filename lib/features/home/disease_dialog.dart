import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/disease.dart';

/// Modal that shows a disease's details (image, name, description) without
/// leaving the home page. Green gradient header with a rounded, padded image.
class DiseaseDialog extends StatelessWidget {
  const DiseaseDialog({Key? key, required this.disease}) : super(key: key);

  final Disease disease;

  Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: size.height * .75),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  disease.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                child: Text(
                  _cleanText(disease.description),
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    height: 1.5,
                    fontSize: 16,
                    color: AppConstants.blackColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    const height = 200.0;
    return Stack(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: _buildImage(),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black38,
                  Colors.transparent,
                  Colors.black26,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 14,
          right: 14,
          child: Material(
            color: Colors.black26,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(context).pop(),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.close, size: 20, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    final url = disease.imageUrl;
    if (url == null) {
      return Container(
        color: AppConstants.primaryColor,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_outlined,
          size: 48,
          color: Colors.white70,
        ),
      );
    }
    return Image.asset(url, fit: BoxFit.cover);
  }

  /// Strips bullet markers so the description reads as clean, flowing text.
  String _cleanText(String text) {
    return text
        .replaceAll('•', '')
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}