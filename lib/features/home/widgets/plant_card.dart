import 'package:flutter/material.dart';

import '../../../data/models/disease.dart';

/// Reusable disease card used on the home page.
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
        height: 100,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
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
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
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
                    const SizedBox(height: 4),
                    Text(
                      disease.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    final url = disease.imageUrl;
    if (url == null) {
      return SizedBox(
        width: 80,
        height: 80,
        child: Center(child: Text(disease.name)),
      );
    }
    return SizedBox(
      width: 80,
      height: 80,
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: ClipRRect(
          child: Image.asset(url, fit: BoxFit.cover),
        ),
      ),
    );
  }
}