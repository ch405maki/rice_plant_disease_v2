import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_styles.dart';

/// Full-screen overlay shown while the image is being analysed. Renders a
/// QR-scanner-style bracket frame with a glowing scan line sweeping through it.
class AnalyzingOverlay extends StatefulWidget {
  const AnalyzingOverlay({Key? key}) : super(key: key);

  @override
  State<AnalyzingOverlay> createState() => _AnalyzingOverlayState();
}

class _AnalyzingOverlayState extends State<AnalyzingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Dim the image so the frame stays readable.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black54, Colors.black26],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 240,
                  height: 240,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) => CustomPaint(
                      painter: _ScanFramePainter(t: _controller.value),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
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
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  _ScanFramePainter({required this.t});

  /// Animation progress 0..1.
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final frame = size.shortestSide;
    final inset = frame * 0.05;
    final weight = frame * 0.035;
    final cornerLen = frame * 0.17;
    const color = AppConstants.primaryColor;

    final crisp = Paint()
      ..color = color
      ..strokeWidth = weight
      ..strokeCap = StrokeCap.round;

    void drawCorner(Offset corner, double dirX, double dirY) {
      canvas.drawLine(corner, corner + Offset(cornerLen * dirX, 0), crisp);
      canvas.drawLine(corner, corner + Offset(0, cornerLen * dirY), crisp);
    }

    drawCorner(Offset(inset, inset), 1, 1);
    drawCorner(Offset(frame - inset, inset), -1, 1);
    drawCorner(Offset(inset, frame - inset), 1, -1);
    drawCorner(Offset(frame - inset, frame - inset), -1, -1);

    // Scan line sweeping top -> bottom inside the frame. A thin core line with
    // a soft, fading glow that ramps up near the middle of the sweep and fades
    // out toward the frame edges.
    final sweepY = inset + t * (frame - inset * 2);
    final start = Offset(inset, sweepY);
    final end = Offset(frame - inset, sweepY);

    // Fade envelope: brightest in the middle of the travel (t=0.5), dim at the
    // top/bottom extremes (t=0 and t=1) where the sweep turns around.
    final brightness = (math.sin(t * math.pi)).clamp(0.0, 1.0).toDouble();
    final glowOpacity = 0.45 * brightness;
    final coreOpacity = 0.35 + 0.65 * brightness;

    final outerGlow = Paint()
      ..color = AppConstants.primaryColor.withOpacity(glowOpacity)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..style = PaintingStyle.stroke;
    canvas.drawLine(start, end, outerGlow);

    final innerGlow = Paint()
      ..color = AppConstants.primaryColor.withOpacity(glowOpacity * 1.5)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawLine(start, end, innerGlow);

    final core = Paint()
      ..color = AppConstants.primaryColor.withOpacity(coreOpacity)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, core);
  }

  @override
  bool shouldRepaint(_ScanFramePainter oldDelegate) => oldDelegate.t != t;
}