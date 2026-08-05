import 'package:flutter/material.dart';

import '../../../data/models/disease.dart';
import '../../../data/repositories/disease_repository.dart';
import 'disease_dialog.dart';
import 'widgets/plant_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.diseases}) : super(key: key);

  final DiseaseRepository diseases;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _healthyLabel = 'NORMAL RICE PLANT';

  void _openDetail(Disease disease) {
    DiseaseDialog(disease: disease).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final healthy = widget.diseases.byLabel(_healthyLabel);
    final diseases = widget.diseases.all.where(
      (d) => d.modelLabel != null && d.modelLabel != _healthyLabel,
    ).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 4, bottom: 32),
          children: [
            _buildBanner(),
            _buildSectionTitle('Healthy Rice plant'),
            if (healthy != null)
              PlantCard(
                disease: healthy,
                onTap: () => _openDetail(healthy),
              ),
            _buildSectionTitle('Rice Plant Diseases'),
            for (final disease in diseases)
              PlantCard(
                disease: disease,
                onTap: () => _openDetail(disease),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    // Margin on all sides so the hero breathes away from the screen edges,
    // with a generous-but-not-excessive rounding.
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 160.0,
          width: double.infinity,
          child: Image.asset(
            'assets/images/banner.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 20, top: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24.0,
        ),
      ),
    );
  }
}