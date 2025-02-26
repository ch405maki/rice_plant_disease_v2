// ignore_for_file: lines_longer_than_80_chars, use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../style/styles.dart';
import '../../models/plant_disease_model.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'dart:typed_data' show Uint8List;

class PlantDescriptionPage extends StatelessWidget {
  final PlantDisease plantDisease;

  const PlantDescriptionPage({required this.plantDisease});

  Future<void> _exportAsPdf(BuildContext context) async {
    final pdf = pw.Document();

    // Define a fallback font for Unicode characters
    final fallbackFont = await rootBundle.load('assets/ArialUnicodeMS.ttf');
    final ttf = pw.Font.ttf(fallbackFont);
    final ttfBold = pw.Font.ttf(fallbackFont);

    // Add content to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.ListView.builder(
              itemCount: 1,
              itemBuilder: (pw.Context context, int index) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            plantDisease.plantName,
                            style: pw.TextStyle(font: ttfBold),
                          ),
                        ),
                        if (plantDisease.imageBytes != null)
                          pw.Container(
                            width: 100,
                            height: 100,
                            child: pw.Image(
                              pw.MemoryImage(
                                plantDisease.imageBytes as Uint8List,
                              ),
                            ),
                          ),
                      ],
                    ),
                    pw.Divider(),
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 60,
                          child: pw.Text(
                            'Causes',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green,
                              font: ttfBold,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            plantDisease.causes,
                            style: pw.TextStyle(font: ttf),
                          ),
                        ),
                      ],
                    ),
                    pw.Divider(),
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 60,
                          child: pw.Text(
                            'Symptoms',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green,
                              font: ttfBold,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            plantDisease.symptoms,
                            style: pw.TextStyle(font: ttf),
                          ),
                        ),
                      ],
                    ),
                    pw.Divider(),
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 60,
                          child: pw.Text(
                            'Treatment',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green,
                              font: ttfBold,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            plantDisease.treatment,
                            style: pw.TextStyle(font: ttf),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );

    // Save the PDF file
    final outputDir = await getTemporaryDirectory();
    final outputFile = File('${outputDir.path}/plant_description.pdf');
    await outputFile.writeAsBytes(await pdf.save());

    // Display a dialog
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('PDF Exported'),
          content: Text('The PDF file has been exported successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                // Open the saved PDF file
                OpenFile.open(outputFile.path);
              },
              child: Text('Open File'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFA7C1B4),
      body: Stack(
        children: [
          if (plantDisease.imageBytes != null)
            Container(
              alignment: Alignment.topCenter,
              child: Image.memory(
                plantDisease.imageBytes!,
                width: MediaQuery.of(context).size.width,
              ),
            ),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: const Color(0xFFA7C1B4),
                      ),
                      child: Icon(
                        Icons.close,
                        color: Constants.primaryColor,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    height: 40,
                    width: 40,
                    child: IconButton(
                      onPressed: () {
                        _exportAsPdf(context);
                      },
                      icon: Icon(
                        Icons.print,
                        color: Constants.primaryColor,
                      ),
                      iconSize: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 300.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      top: 0,
                      left: 5,
                      right: 5,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFA7C1B4),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 530,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0), // Add padding from the top
                                  child: Text(
                                    plantDisease.plantName,
                                    style: kResultTextStyle,
                                  ),
                                ),
                                const Divider(),
                                ListTile(
                                  title: const Text(
                                    'Causes',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff296e48),
                                    ),
                                  ),
                                  subtitle: Text(
                                    plantDisease.causes,
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                                const Divider(),
                                ListTile(
                                  title: const Text(
                                    'Symptoms',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff296e48),
                                    ),
                                  ),
                                  subtitle: Text(
                                    plantDisease.symptoms,
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                                const Divider(),
                                ListTile(
                                  title: const Text(
                                    'Treatment',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff296e48),
                                    ),
                                  ),
                                  subtitle: Text(
                                    plantDisease.treatment,
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
}

class Constants {
  static const Color primaryColor = Color(0xff296e48);
}
