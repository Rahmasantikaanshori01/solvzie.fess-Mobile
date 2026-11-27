import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';

class DeskScene extends StatelessWidget {
  final double scale;
  final bool isSmallHeight;
  final double swingAngle; // in radians, for animated green sticky note

  const DeskScene({
    super.key,
    this.scale = 1.0,
    this.isSmallHeight = false,
    this.swingAngle = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double deskSurfaceTop = isSmallHeight
        ? screenHeight * 0.61
        : screenHeight * 0.70;

    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Table surface (grid with #0E5368 to #123F64)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: deskSurfaceTop,
            child: CustomPaint(
              painter: _DeskSurfaceGridPainter(),
            ),
          ),
          // Hanging rope across the top (rotate -3deg)
          Positioned(
            top: (isSmallHeight ? 26.0 : 34.0) * scale,
            left: -35.0 * scale,
            right: -35.0 * scale,
            child: Transform.rotate(
              angle: -3.0 * math.pi / 180.0,
              child: Container(
                height: 3.0 * scale,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [SplashColors.rope1, SplashColors.rope2],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      offset: Offset(0, 2.0 * scale),
                      blurRadius: 2.0 * scale,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Green sticky note (swings between -7deg and 4deg)
          Positioned(
            top: (isSmallHeight ? 26.0 : 34.0) * scale,
            left: 48.0 * scale,
            child: Transform.rotate(
              angle: (-7.0 * math.pi / 180.0) + swingAngle,
              alignment: const Alignment(0.0, -1.2),
              child: _buildStickyNote(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [SplashColors.greenSticky, SplashColors.greenStickyDark],
                ),
                scale: scale,
              ),
            ),
          ),
          // Yellow sticky note (rotate 9deg)
          Positioned(
            top: (isSmallHeight ? 34.0 : 43.0) * scale,
            left: 140.0 * scale,
            child: Transform.rotate(
              angle: 9.0 * math.pi / 180.0,
              child: _buildStickyNote(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [SplashColors.yellow, SplashColors.yellowDark],
                ),
                scale: scale,
              ),
            ),
          ),
          // Drink cup on the right side (rotate 3deg)
          Positioned(
            top: (isSmallHeight ? 52.0 : 70.0) * scale,
            right: -25.0 * scale,
            child: Transform.rotate(
              angle: 3.0 * math.pi / 180.0,
              child: _buildCup(scale: scale, isSmall: isSmallHeight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyNote({
    required Gradient gradient,
    required double scale,
  }) {
    final double noteWidth = 64.0 * scale;
    final double noteHeight = 54.0 * scale;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Note body
        Container(
          width: noteWidth,
          height: noteHeight,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(1.5 * scale),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF112835).withValues(alpha: 0.25),
                offset: Offset(0, 10.0 * scale),
                blurRadius: 20.0 * scale,
              ),
            ],
          ),
        ),
        // Pink circular pin on rope
        Positioned(
          top: -4.0 * scale,
          child: Container(
            width: 7.0 * scale,
            height: 7.0 * scale,
            decoration: BoxDecoration(
              color: SplashColors.pink,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  offset: Offset(0, 1.0 * scale),
                  blurRadius: 1.5 * scale,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCup({required double scale, required bool isSmall}) {
    final double cupWidth = (isSmall ? 82.0 : 104.0) * scale;
    final double cupHeight = (isSmall ? 132.0 : 168.0) * scale;
    final double strawHeight = (isSmall ? 74.0 : 94.0) * scale;

    return SizedBox(
      width: cupWidth + 20.0 * scale,
      height: cupHeight + 60.0 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Mint straw (rotate 10deg)
          Positioned(
            top: 0,
            left: 63.0 * scale * (isSmall ? 0.8 : 1.0),
            child: Transform.rotate(
              angle: 10.0 * math.pi / 180.0,
              child: Container(
                width: 12.0 * scale,
                height: strawHeight,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [SplashColors.straw1, SplashColors.straw2],
                  ),
                  borderRadius: BorderRadius.circular(8.0 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      offset: Offset(2.0 * scale, 2.0 * scale),
                      blurRadius: 3.0 * scale,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Cup body (purple gradient with highlight)
          Positioned(
            top: 60.0 * scale,
            left: 10.0 * scale,
            child: Container(
              width: cupWidth,
              height: cupHeight,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    SplashColors.cupBody1,
                    SplashColors.cupBody2,
                    SplashColors.cupBody3,
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(42.0 * scale),
                  topRight: Radius.circular(22.0 * scale),
                  bottomRight: Radius.circular(34.0 * scale),
                  bottomLeft: Radius.circular(38.0 * scale),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22184C).withValues(alpha: 0.35),
                    offset: Offset(0, 18.0 * scale),
                    blurRadius: 30.0 * scale,
                  ),
                ],
              ),
            ),
          ),
          // Cup lid (oval)
          Positioned(
            top: 50.0 * scale,
            left: 6.0 * scale,
            child: Container(
              width: cupWidth + 8.0 * scale,
              height: 34.0 * scale,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [SplashColors.cupLid1, SplashColors.cupLid2],
                ),
                borderRadius: BorderRadius.all(
                  Radius.elliptical(cupWidth + 8.0 * scale, 34.0 * scale),
                ),
                boxShadow: [
                  BoxShadow(
                    color: SplashColors.cupLidShadow,
                    offset: Offset(0, 5.0 * scale),
                    blurRadius: 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeskSurfaceGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Fill surface gradient (#0E5368 to #123F64)
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0E5368), Color(0xFF123F64)],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Draw grid lines (20px spacing with mint 0.16)
    final gridPaint = Paint()
      ..color = SplashColors.mint.withValues(alpha: 0.16)
      ..strokeWidth = 1.0;

    const double step = 20.0;
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DeskSurfaceGridPainter oldDelegate) => false;
}
