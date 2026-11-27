import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'fish_painter.dart';

class FishProgressBar extends StatelessWidget {
  final double scale;
  final double progress; // 0.0 to 1.0

  const FishProgressBar({
    super.key,
    this.scale = 1.0,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final double barHeight = 48.0 * scale;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final double clampedProgress = progress.clamp(0.0, 1.0);
        // In Figma CSS: fill-progress to width 93%
        final double currentFillWidth = clampedProgress * (totalWidth * 0.93);

        // In Figma CSS: fish-swim to calc(100% - 58px), fish width 54px
        final double fishWidth = 54.0 * scale;
        final double fishHeight = 30.0 * scale;
        final double fishStartX = 2.0 * scale;
        final double fishEndX = totalWidth - (58.0 * scale);
        final double fishX = fishStartX + clampedProgress * (fishEndX - fishStartX);

        // In Figma CSS: bubble-move to left 70%, opacity 0
        final double bubblesStartX = 10.0 * scale;
        final double bubblesEndX = totalWidth * 0.70;
        final double bubblesX = bubblesStartX + clampedProgress * (bubblesEndX - bubblesStartX);
        final double bubblesOpacity = (1.0 - clampedProgress * 0.9).clamp(0.0, 1.0);

        return Container(
          width: totalWidth,
          height: barHeight,
          decoration: BoxDecoration(
            color: SplashColors.progressBg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: SplashColors.white,
              width: 3.0 * scale,
            ),
            boxShadow: [
              BoxShadow(
                color: SplashColors.blue.withValues(alpha: 0.20),
                offset: Offset(0, -8.0 * scale),
                blurRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Water fill (#5eeaa8 with opacity 0.70)
                Container(
                  width: currentFillWidth,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: SplashColors.mint.withValues(alpha: 0.70),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                // Bubbles "· ° ·" (letter-spacing 9px)
                Positioned(
                  left: bubblesX,
                  child: Opacity(
                    opacity: bubblesOpacity,
                    child: Text(
                      '· ° ·',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16.0 * scale,
                        fontWeight: FontWeight.w700,
                        color: SplashColors.white,
                        letterSpacing: 9.0 * scale,
                      ),
                    ),
                  ),
                ),
                // Swimming fish
                Positioned(
                  left: fishX,
                  top: (barHeight - fishHeight) / 2.0,
                  child: FishWidget(
                    width: fishWidth,
                    height: fishHeight,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
