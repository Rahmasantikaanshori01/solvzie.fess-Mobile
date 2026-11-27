import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'burst_painter.dart';
import 'fish_painter.dart';

class StickersWidget extends StatelessWidget {
  final double scale;
  final bool isSmallHeight;

  const StickersWidget({
    super.key,
    this.scale = 1.0,
    this.isSmallHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    // In Figma CSS: .desk-fish, .desk-burst { top: 58% (small height 57%) }
    final double topPos = screenHeight * (isSmallHeight ? 0.57 : 0.58);

    return Positioned.fill(
      child: Stack(
        children: [
          // Desk Fish sticker on the left (rotate -9deg)
          Positioned(
            left: 18.0 * scale,
            top: topPos,
            child: Transform.rotate(
              angle: -9.0 * math.pi / 180.0,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF231B50).withValues(alpha: 0.35),
                      offset: Offset(0, 8.0 * scale),
                      blurRadius: 8.0 * scale,
                    ),
                  ],
                ),
                child: FishWidget(
                  width: (isSmallHeight ? 76.0 : 96.0) * scale,
                  height: (isSmallHeight ? 44.0 : 56.0) * scale,
                ),
              ),
            ),
          ),
          // Desk Burst sticker on the right ("2026")
          Positioned(
            right: 20.0 * scale,
            top: topPos,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF231B50).withValues(alpha: 0.35),
                    offset: Offset(0, 8.0 * scale),
                    blurRadius: 8.0 * scale,
                  ),
                ],
              ),
              child: StickerStarWidget(
                label: '2026',
                size: (isSmallHeight ? 58.0 : 72.0) * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
