// ignore_for_file: lines_longer_than_80_chars, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_styles.dart';
import '../../data/models/saved_scan.dart';
import '../../widgets/circle_icon_button.dart';

/// Detail view of a saved scan, with PDF export.
class SavedDetailPage extends StatelessWidget {
  const SavedDetailPage({Key? key, required this.scan}) : super(key: key);

  final SavedScan scan;

  Future<void> _exportAsPdf(BuildContext context) async {
    final pdf = pw.Document();
    final fallbackFont = await rootBundle.load('assets/ArialUnicodeMS.ttf');
    final ttf = pw.Font.ttf(fallbackFont);
    final ttfBold = pw.Font.ttf(fallbackFont);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        scan.plantName,
                        style: pw.TextStyle(font: ttfBold),
                      ),
                    ),
                    if (scan.imageBytes != null)
                      pw.Container(
                        width: 100,
                        height: 100,
                        child: pw.Image(
                          pw.MemoryImage(scan.imageBytes as Uint8List),
                        ),
                      ),
                  ],
                ),
                pw.Divider(),
                _pdfSection(ttfBold, ttf, 'Causes', scan.causes),
                pw.Divider(),
                _pdfSection(ttfBold, ttf, 'Symptoms', scan.symptoms),
                pw.Divider(),
                _pdfSection(ttfBold, ttf, 'Treatment', scan.treatment),
              ],
            ),
          );
        },
      ),
    );

    final outputDir = await getTemporaryDirectory();
    final outputFile = File('${outputDir.path}/plant_description.pdf');
    await outputFile.writeAsBytes(await pdf.save());

    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('PDF Exported'),
        content: const Text('The PDF file has been exported successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () => OpenFile.open(outputFile.path),
            child: const Text('Open File'),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfSection(
    pw.Font boldFont,
    pw.Font font,
    String title,
    String body,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 70,
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green,
              font: boldFont,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(body, style: pw.TextStyle(font: font)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppConstants.panelColor,
      body: Stack(
        children: [
          if (scan.imageBytes != null)
            Container(
              alignment: Alignment.topCenter,
              child: Image.memory(
                scan.imageBytes!,
                width: size.width,
                cacheWidth: (size.width * MediaQuery.devicePixelRatioOf(context))
                    .round(),
              ),
            ),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleIconButton(
                  icon: Icons.close,
                  onTap: () => Navigator.of(context).pop(),
                  backgroundColor: AppConstants.panelColor,
                ),
                CircleIconButton(
                  icon: Icons.print,
                  onTap: () => _exportAsPdf(context),
                  backgroundColor: Colors.white,
                ),
              ],
            ),
          ),
          Positioned(
            top: 300,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppConstants.panelColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(scan.plantName, style: kResultTextStyle),
                    ),
                    const Divider(),
                    _detailSection('Causes', scan.causes),
                    const Divider(),
                    _detailSection('Symptoms', scan.symptoms),
                    const Divider(),
                    _detailSection('Treatment', scan.treatment),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailSection(String title, String body) {
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