import 'package:flutter/material.dart';

import '../../../data/models/disease.dart';
import '../../../data/repositories/disease_repository.dart';
import 'detail_page.dart';
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
    Navigator.of(context).push<DetailPage>(
      MaterialPageRoute<DetailPage>(
        builder: (_) => DetailPage(disease: disease),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final healthy = widget.diseases.byLabel(_healthyLabel);
    final diseases = widget.diseases.all.where(
      (d) => d.modelLabel != null && d.modelLabel != _healthyLabel,
    ).toList();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            SizedBox(height: size.height * .2),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return SizedBox(
      height: 150.0,
      child: Image.asset(
        'assets/images/banner.jpg',
        fit: BoxFit.cover,
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