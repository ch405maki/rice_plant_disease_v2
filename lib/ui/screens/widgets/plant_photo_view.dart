// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';
import 'package:flutter/material.dart';
import '../../../style/styles.dart';

class PlantPhotoView extends StatelessWidget {
  final File? file;
  const PlantPhotoView({super.key, this.file});

@override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;

  return Container(
    width: (file == null) ? 150 : screenWidth,
    height: (file == null) ? 150 : 450,
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/code-scan.png'),
        fit: BoxFit.cover,
      ),
    ),
    child: (file == null) ? _buildEmptyView() : Image.file(file!, fit: BoxFit.cover),
  );
}
  Widget _buildEmptyView() {
    return const Center(
        child: Text(
      '',
      style: kAnalyzingTextStyle,
    ));
  }
}
