import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app_dependencies.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/primary_button.dart';
import 'scan_page.dart';

/// Entry point for the Scan tab: lets the user choose camera or gallery.
class ScanChooserPage extends StatelessWidget {
  const ScanChooserPage({Key? key, required this.dependencies})
      : super(key: key);

  final AppDependencies dependencies;

  void _openScan(BuildContext context, ImageSource source) {
    Navigator.of(context).push<ScanPage>(
      MaterialPageRoute<ScanPage>(
        builder: (_) => ScanPage(source: source, dependencies: dependencies),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                      child: Image.asset('assets/images/code-scan.png'),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Please choose an option',
                      style: TextStyle(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.w300,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PrimaryButton(
                label: 'Camera',
                icon: Icons.camera_alt,
                onPressed: () => _openScan(context, ImageSource.camera),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PrimaryButton(
                label: 'Pick from Gallery',
                onPressed: () => _openScan(context, ImageSource.gallery),
              ),
            ),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}