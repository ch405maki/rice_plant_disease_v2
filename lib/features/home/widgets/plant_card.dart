import 'package:flutter/material.dart';

import '../../../data/models/disease.dart';

/// Reusable disease card used on the home page. Mirrors the result-page hero:
/// a rounded thumbnail with padding inside a softly-rounded card.
class PlantCard extends StatelessWidget {
  const PlantCard({Key? key, required this.disease, required this.onTap})
      : super(key: key);

  final Disease disease;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildThumbnail(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    disease.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _cleanText(disease.description),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.35,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    final url = disease.imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 84,
        height: 84,
        child: url == null
            ? Container(
                color: Colors.black12,
                alignment: Alignment.center,
                child: const Icon(Icons.image_outlined, color: Colors.black38),
              )
            : Image.asset(url, fit: BoxFit.cover),
      ),
    );
  }

  /// Strips bullet markers so subtitles read as clean text.
  String _cleanText(String text) {
    return text
        .replaceAll('•', '')
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
