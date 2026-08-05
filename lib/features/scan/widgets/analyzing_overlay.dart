import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_styles.dart';

/// Full-screen overlay shown while the image is being analysed. Renders a
/// sweeping scan line plus a rotating radar and a status text.
class AnalyzingOverlay extends StatefulWidget {
  const AnalyzingOverlay({Key? key}) : super(key: key);

  @override
  State<AnalyzingOverlay> createState() => _AnalyzingOverlayState();
}

class _AnalyzingOverlayState extends State<AnalyzingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final scanLineY = -1.0 + t * 2.0;
          final radarAngle = t * 6.2832;
          return Stack(
            fit: StackFit.expand,
            children: [
              // Dim the image so the content stays readable.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black54, Colors.black26],
                  ),
                ),
              ),
              // Sweeping scan line.
              Align(
                alignment: Alignment(0, scanLineY),
                child: Container(
                  width: double.infinity,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryColor.withOpacity(0.7),
                        blurRadius: 14,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
              // Center radar + status.
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 96,
                      height: 96,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.35),
                              border: Border.all(
                                color: AppConstants.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          Transform.rotate(
                            angle: radarAngle,
                            child: Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: SweepGradient(
                                  startAngle: 0,
                                  endAngle: 3.14159,
                                  colors: [
                                    Colors.transparent,
                                    AppConstants.primaryColor.withOpacity(0.85),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.photo_camera,
                            color: Colors.white,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Analyzing image...',
                      style: TextStyle(
                        fontFamily: kMainFont,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Scanning for disease indicators',
                      style: TextStyle(
                        fontFamily: kMainFont,
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}