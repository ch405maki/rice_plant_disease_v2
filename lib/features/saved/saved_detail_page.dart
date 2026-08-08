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
import '../../core/utils/formatters.dart';
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'PDF Exported',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'The PDF file has been exported successfully.',
          textAlign: TextAlign.start,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppConstants.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
          const SizedBox(width: 6),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => OpenFile.open(outputFile.path),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Open File'),
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
    final background = Color.lerp(lightGreenLeaves, Colors.white, .5)!;
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleIconButton(
                    icon: Icons.close,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  CircleIconButton(
                    icon: Icons.print,
                    onTap: () => _exportAsPdf(context),
                    backgroundColor: Colors.white,
                    iconColor: AppConstants.primaryColor,
                  ),
                ],
              ),
            ),
            _buildHeroCard(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _detailSection('Causes', scan.causes),
                    const SizedBox(height: 16),
                    _detailSection('Symptoms', scan.symptoms),
                    const SizedBox(height: 16),
                    _detailSection('Treatment', scan.treatment),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    final bytes = scan.imageBytes;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 14),
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
              child: bytes == null
                  ? const ColoredBox(
                      color: Colors.white12,
                      child: Icon(Icons.image_outlined, color: Colors.white70),
                    )
                  : Image.memory(bytes, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  scan.plantName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
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
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formatTimestamp(scan.dateCreated),
                        style: const TextStyle(
                          fontSize: 13,
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

  Widget _detailSection(String title, String body) {
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
        Text(
          _cleanText(body),
          style: const TextStyle(
            fontSize: 14,
            height: 1.4,
            letterSpacing: 0.2,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  /// Strips bullet markers so saved text reads as clean, flowing text.
  String _cleanText(String text) {
    return text
        .replaceAll('•', '')
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}