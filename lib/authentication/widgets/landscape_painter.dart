import 'dart:math' as math;

import 'package:flutter/material.dart';

// ─── LANDSCAPE BACKGROUND ────────────────────────────────────────────────────

/// Decorative mountain + tree illustration shown at the bottom of the login page.
class LandscapeBackground extends StatelessWidget {
  final double height;

  const LandscapeBackground({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _LandscapePainter(),
        size: Size(double.infinity, height),
      ),
    );
  }
}

class _LandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background wash
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFE8DEFA).withOpacity(0.5),
    );

    _drawSun(canvas, w, h);

    _drawMountain(canvas, color: const Color(0xFFD3B6FA), peaks: [
      Offset(0, h * 0.70), Offset(w * 0.20, h * 0.35),
      Offset(w * 0.45, h * 0.60), Offset(w * 0.70, h * 0.30),
      Offset(w, h * 0.55), Offset(w, h), Offset(0, h),
    ]);

    _drawMountain(canvas, color: const Color(0xFFBB91F7), peaks: [
      Offset(0, h * 0.75), Offset(w * 0.15, h * 0.50),
      Offset(w * 0.35, h * 0.65), Offset(w * 0.55, h * 0.40),
      Offset(w * 0.80, h * 0.60), Offset(w, h * 0.50),
      Offset(w, h), Offset(0, h),
    ]);

    _drawMountain(canvas, color: const Color(0xFFA56EF4), peaks: [
      Offset(0, h * 0.85), Offset(w * 0.25, h * 0.65),
      Offset(w * 0.50, h * 0.75), Offset(w * 0.75, h * 0.60),
      Offset(w, h * 0.70), Offset(w, h), Offset(0, h),
    ]);

    _drawTrees(canvas, w, h);
  }

  void _drawSun(Canvas canvas, double w, double h) {
    final cx = w * 0.6;
    final cy = h * 0.3;

    canvas.drawCircle(
      Offset(cx, cy),
      16,
      Paint()..color = const Color(0xFFFBBF24),
    );

    final rayPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final angle = i * 45 * math.pi / 180;
      canvas.drawLine(
        Offset(cx + 20 * math.cos(angle), cy + 20 * math.sin(angle)),
        Offset(cx + 28 * math.cos(angle), cy + 28 * math.sin(angle)),
        rayPaint,
      );
    }
  }

  void _drawMountain(
    Canvas canvas, {
    required Color color,
    required List<Offset> peaks,
  }) {
    final path = Path()..moveTo(peaks.first.dx, peaks.first.dy);
    for (final p in peaks.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawTrees(Canvas canvas, double w, double h) {
    final paint = Paint()..color = const Color(0xFF6B20C0);

    const positions = [
      (dx: 0.05, dy: 0.82), (dx: 0.12, dy: 0.78),
      (dx: 0.20, dy: 0.84), (dx: 0.85, dy: 0.78),
      (dx: 0.92, dy: 0.82),
    ];

    for (final pos in positions) {
      final x = w * pos.dx;
      final y = h * pos.dy;

      // Trunk
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y + 10), width: 4, height: 12),
        paint,
      );

      // Canopy
      canvas.drawPath(
        Path()
          ..moveTo(x, y - 20)
          ..lineTo(x - 12, y + 5)
          ..lineTo(x + 12, y + 5)
          ..close(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
