import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_styles.dart';

class LifeOsMark extends StatelessWidget {
  const LifeOsMark({super.key, this.size = 64, this.onDarkBackground = false});

  final double size;
  final bool onDarkBackground;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _LifeOsMarkPainter(onDarkBackground: onDarkBackground),
      ),
    );
  }
}

class _LifeOsMarkPainter extends CustomPainter {
  const _LifeOsMarkPainter({required this.onDarkBackground});

  final bool onDarkBackground;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 120;
    canvas.save();
    canvas.scale(scale);

    final indigo = onDarkBackground
        ? AppColors.softIndigo
        : AppColors.midnightIndigo;
    final teal = onDarkBackground ? AppColors.mistTeal : AppColors.deepTeal;
    final amber = AppColors.softAmber;
    final center = onDarkBackground
        ? AppColors.softIndigo
        : AppColors.midnightIndigo;

    _arc(canvas, 50, 0, 270, indigo, 3.5);
    _dot(canvas, _point(50, 270), 4.5, teal);
    _dot(canvas, _point(50, 0), 3, indigo);

    _arc(canvas, 31, 15, 215, teal, 2.5);
    _dot(canvas, _point(31, 230), 3.5, amber);

    _arc(canvas, 19, 28, 150, amber, 2);
    _dot(canvas, _point(19, 178), 3, teal);

    _dot(canvas, const Offset(60, 60), 5.5, center);
    canvas.restore();
  }

  Offset _point(double radius, double degrees) {
    final radians = degrees * math.pi / 180;
    return Offset(
      60 + radius * math.cos(radians),
      60 + radius * math.sin(radians),
    );
  }

  void _arc(
    Canvas canvas,
    double radius,
    double startDegrees,
    double sweepDegrees,
    Color color,
    double strokeWidth,
  ) {
    final rect = Rect.fromCircle(center: const Offset(60, 60), radius: radius);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      startDegrees * math.pi / 180,
      sweepDegrees * math.pi / 180,
      false,
      paint,
    );
  }

  void _dot(Canvas canvas, Offset center, double radius, Color color) {
    canvas.drawCircle(center, radius, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _LifeOsMarkPainter oldDelegate) {
    return oldDelegate.onDarkBackground != onDarkBackground;
  }
}
