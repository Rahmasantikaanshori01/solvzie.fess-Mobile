import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';

class LogoCompact extends StatelessWidget {
  final double scale;

  const LogoCompact({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    final double baseFontSize = 17.0 * scale;
    final double bubbleWidth = 23.0 * scale;
    final double bubbleHeight = 18.0 * scale;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Speech bubble icon
        SizedBox(
          width: bubbleWidth,
          height: bubbleHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Bubble body
              Container(
                width: bubbleWidth,
                height: bubbleHeight,
                decoration: BoxDecoration(
                  color: SplashColors.mint,
                  borderRadius: BorderRadius.circular(7.0 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: SplashColors.teal.withValues(alpha: 0.3),
                      offset: Offset(-2 * scale, -2 * scale),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 1.2 * scale),
                        width: 3.0 * scale,
                        height: 3.0 * scale,
                        decoration: const BoxDecoration(
                          color: SplashColors.ink,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Bubble tail
              Positioned(
                bottom: -3.0 * scale,
                left: 4.5 * scale,
                child: CustomPaint(
                  size: Size(5.0 * scale, 4.0 * scale),
                  painter: _BubbleTailPainter(color: SplashColors.mint),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 7.0 * scale),
        // Logo text: solvzie.fess
        Text(
          'solvzie',
          style: TextStyle(
            fontFamily: SplashTypography.fontFredoka,
            fontFamilyFallback: SplashTypography.fontFallbackSans,
            fontSize: baseFontSize,
            fontWeight: FontWeight.w700,
            color: SplashColors.white,
            letterSpacing: -0.6 * scale,
            height: 1.0,
          ),
        ),
        Text(
          '.',
          style: TextStyle(
            fontFamily: SplashTypography.fontFredoka,
            fontFamilyFallback: SplashTypography.fontFallbackSans,
            fontSize: baseFontSize * 1.35,
            fontWeight: FontWeight.w900,
            color: SplashColors.pink,
            letterSpacing: -0.6 * scale,
            height: 1.0,
          ),
        ),
        Text(
          'fess',
          style: TextStyle(
            fontFamily: SplashTypography.fontFredoka,
            fontFamilyFallback: SplashTypography.fontFallbackSans,
            fontSize: baseFontSize,
            fontWeight: FontWeight.w700,
            color: SplashColors.white,
            letterSpacing: -0.6 * scale,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  final Color color;

  const _BubbleTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) =>
      oldDelegate.color != color;
}
