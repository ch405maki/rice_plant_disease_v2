import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_styles.dart';
import '../../../data/models/disease.dart';
import '../../../widgets/circle_icon_button.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({Key? key, required this.disease}) : super(key: key);

  final Disease disease;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _buildImage()),
          Positioned(
            top: 50,
            left: 20,
            child: CircleIconButton(
              icon: Icons.close,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * .6,
              width: size.width,
              padding: const EdgeInsets.only(top: 18, left: 30, right: 30),
              decoration: const BoxDecoration(
                color: AppConstants.panelColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(disease.name, style: kResultTextStyle),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        disease.description,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          height: 1.5,
                          fontSize: 18,
                          color: AppConstants.blackColor.withOpacity(.7),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final url = disease.imageUrl;
    if (url == null) {
      return Container(color: AppConstants.primaryColor);
    }
    return Image.asset(url, fit: BoxFit.cover);
  }
}