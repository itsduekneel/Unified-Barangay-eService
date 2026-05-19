import 'dart:math' as math;

import 'package:flutter/material.dart';

// ─── SHARED CONSTANT ─────────────────────────────────────────────────────────
// Use this in EVERY screen that shows the landscape so height is always consistent.
// Example:
//   LandscapeBackground(height: MediaQuery.of(context).size.height * kLandscapeHeightFraction)
const double kLandscapeHeightFraction = 0.30;

// ─── LANDSCAPE BACKGROUND ────────────────────────────────────────────────────

/// Decorative mountain + tree illustration shown at the bottom of screens.
/// The painter is fully transparent at the top — it paints NO background rect —
/// so it blends seamlessly with whatever Scaffold color is behind it.
class LandscapeBackground extends StatelessWidget {
  final double height;

  const LandscapeBackground({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _LandscapePainter(),
      ),
    );
  }
}

class _LandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── NO background rect here ──────────────────────────────────────────────
    // The Scaffold's bgColor shows through above the mountains, giving a
    // seamless look on both the login page and the splash/loading screen.

    _drawSun(canvas, w, h);

    // Back mountain layer – lightest purple
    _drawMountain(canvas, color: const Color(0xFFD3B6FA), peaks: [
      Offset(0,        h * 0.70),
      Offset(w * 0.20, h * 0.35),
      Offset(w * 0.45, h * 0.60),
      Offset(w * 0.70, h * 0.30),
      Offset(w,        h * 0.55),
      Offset(w,        h),
      Offset(0,        h),
    ]);

    // Mid mountain layer
    _drawMountain(canvas, color: const Color(0xFFBB91F7), peaks: [
      Offset(0,        h * 0.75),
      Offset(w * 0.15, h * 0.50),
      Offset(w * 0.35, h * 0.65),
      Offset(w * 0.55, h * 0.40),
      Offset(w * 0.80, h * 0.60),
      Offset(w,        h * 0.50),
      Offset(w,        h),
      Offset(0,        h),
    ]);

    // Front mountain layer – darkest purple
    _drawMountain(canvas, color: const Color(0xFFA56EF4), peaks: [
      Offset(0,        h * 0.85),
      Offset(w * 0.25, h * 0.65),
      Offset(w * 0.50, h * 0.75),
      Offset(w * 0.75, h * 0.60),
      Offset(w,        h * 0.70),
      Offset(w,        h),
      Offset(0,        h),
    ]);

    _drawTrees(canvas, w, h);
  }

  // ── Sun ───────────────────────────────────────────────────────────────────

  void _drawSun(Canvas canvas, double w, double h) {
    const cx_frac = 0.60;
    const cy_frac = 0.28;
    final cx = w * cx_frac;
    final cy = h * cy_frac;

    // Body
    canvas.drawCircle(
      Offset(cx, cy),
      h * 0.075,
      Paint()..color = const Color(0xFFFBBF24),
    );

    // Rays
    final rayPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..strokeWidth = h * 0.012
      ..strokeCap = StrokeCap.round;

    final innerR = h * 0.085;
    final outerR = h * 0.115;

    for (int i = 0; i < 8; i++) {
      final angle = i * 45 * math.pi / 180;
      canvas.drawLine(
        Offset(cx + innerR * math.cos(angle), cy + innerR * math.sin(angle)),
        Offset(cx + outerR * math.cos(angle), cy + outerR * math.sin(angle)),
        rayPaint,
      );
    }
  }

  // ── Mountain helper ───────────────────────────────────────────────────────

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

  // ── Trees ─────────────────────────────────────────────────────────────────

  void _drawTrees(Canvas canvas, double w, double h) {
    final paint = Paint()..color = const Color(0xFF6B20C0);

    // (dx, dy) as fractions of canvas dimensions
    const positions = [
      (dx: 0.05, dy: 0.82),
      (dx: 0.12, dy: 0.78),
      (dx: 0.20, dy: 0.84),
      (dx: 0.85, dy: 0.78),
      (dx: 0.92, dy: 0.82),
    ];

    for (final pos in positions) {
      final x  = w * pos.dx;
      final y  = h * pos.dy;
      final th = h * 0.06;  // tree height, scales with canvas

      // Trunk
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, y + th * 0.55),
          width:  w * 0.008,
          height: th * 0.55,
        ),
        paint,
      );

      // Canopy (triangle)
      canvas.drawPath(
        Path()
          ..moveTo(x,            y - th * 0.55)
          ..lineTo(x - th * 0.6, y + th * 0.20)
          ..lineTo(x + th * 0.6, y + th * 0.20)
          ..close(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}