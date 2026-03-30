// lib/widgets/progress_ring.dart
// Circular progress indicator showing daily completion %

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme.dart';

class ProgressRing extends StatelessWidget {
  final double percent;     // 0 to 100
  final int completed;
  final int total;
  final double size;

  const ProgressRing({
    super.key,
    required this.percent,
    required this.completed,
    required this.total,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(percent: percent / 100),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${percent.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              Text(
                '$completed / $total',
                style: const TextStyle(
                  color: AppTheme.textSecond,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent; // 0.0 to 1.0

  _RingPainter({required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 12;
    const strokeWidth = 12.0;

    // Background ring
    final bgPaint = Paint()
      ..color = AppTheme.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    if (percent > 0) {
      final progressPaint = Paint()
        ..color = _progressColor(percent)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,              // Start from top
        2 * math.pi * percent,     // Sweep angle
        false,
        progressPaint,
      );
    }
  }

  Color _progressColor(double p) {
    if (p >= 0.8) return AppTheme.accent;         // Green for 80%+
    if (p >= 0.5) return AppTheme.accentBlue;     // Blue for 50-80%
    return AppTheme.accentRed;                    // Red below 50%
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.percent != percent;
}
