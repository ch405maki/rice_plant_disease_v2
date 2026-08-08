import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Placeholder screen for the About tab while the content is in progress.
class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppConstants.primaryColor.withOpacity(.12),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 44,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Work in progress',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'This page is under development.\nPlease check back soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}