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
                  title: 'Developers',
                  members: const [
                    _TeamMember(
                      'Lahaina G. Anggaboy',
                      'assets/images/lahaina.jpg',
                    ),
                    _TeamMember('Jay-em B. Delacruz', 'assets/images/jay.jpg'),
                    _TeamMember('John Rey Lalic', 'assets/images/jhon.jpg'),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTeamSection(
                  title: 'Adviser',
                  members: const [_TeamMember('Ripple Jane H. Bato')],
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
    required List<_TeamMember> members,
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
        const SizedBox(height: 12),
        if (members.length == 1)
          _buildMember(members.first)
        else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final m in members.take(2))
                Expanded(child: Center(child: _buildMember(m))),
            ],
          ),
          for (final m in members.skip(2))
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _buildMember(m),
            ),
        ],
      ],
    );
  }

  Widget _buildMember(_TeamMember member) {
    return Column(
      children: [
        if (member.imageAsset != null) ...[
          _buildAvatar(member.imageAsset!),
          const SizedBox(height: 6),
        ],
        Text(
          member.name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildAvatar(String assetPath) {
    return ClipOval(
      child: Image.asset(
        assetPath,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
      ),
    );
  }
}

/// A team member with an optional profile photo shown above the name.
class _TeamMember {
  const _TeamMember(this.name, [this.imageAsset]);

  final String name;
  final String? imageAsset;
}