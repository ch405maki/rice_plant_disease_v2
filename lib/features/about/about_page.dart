import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// About screen describing AgriGuard and its team.
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
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                _buildLogo(),
                const SizedBox(height: 24),
                const Text(
                  'AgriGuard is an AI-assisted mobile application designed to '
                  'help farmers quickly identify common rice diseases '
                  'using leaf images. By providing an accessible way to detect '
                  'possible diseases, AgriGuard supports farmers in making '
                  'timely and informed crop-management decisions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 32),
                _buildTeamSection(
                  title: 'Developer',
                  members: const [
                    'Lahaina G. Anggaboy',
                    'Jay-em B. Delacruz',
                    'John Rey Lalic',
                  ],
                ),
                const SizedBox(height: 16),
                _buildTeamSection(
                  title: 'Adviser',
                  members: const ['Ripple Jane H. Bato'],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/rnsat_logo.png',
      width: 100,
      height: 100,
    );
  }

  Widget _buildTeamSection({
    required String title,
    required List<String> members,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        for (final m in members)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              m,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
      ],
    );
  }
}