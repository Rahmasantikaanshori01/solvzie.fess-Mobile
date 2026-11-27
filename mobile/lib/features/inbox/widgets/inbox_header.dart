import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';

/// Shared teal grid backdrop used across Inbox, Pesan, Story, and Arsip screens.
class InboxGridBackground extends StatelessWidget {
  final Widget child;

  const InboxGridBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double screenWidth = size.width;
    final double compositionWidth = screenWidth > 430.0 ? 430.0 : screenWidth;

    return Container(
      color: SplashColors.tealDeep,
      child: Center(
        child: SizedBox(
          width: compositionWidth,
          height: size.height,
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: SplashColors.teal,
              boxShadow: screenWidth > 430.0
                  ? [
                      BoxShadow(
                        color: SplashColors.tealDeep.withValues(alpha: 0.7),
                        blurRadius: 60,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: CustomPaint(
                    painter: _InboxGridPainter(),
                  ),
                ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InboxGridPainter extends CustomPainter {
  const _InboxGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const double cellSize = 26.0;
    final paint = Paint()
      ..color = SplashColors.white.withValues(alpha: 0.06)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    for (double x = 0; x <= size.width; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _InboxGridPainter oldDelegate) => false;
}

/// Mint Fredoka Bold title matching "HALO," on [HomeScreen].
class Inbox3DTitle extends StatelessWidget {
  final String text;
  final double fontSize;

  const Inbox3DTitle({
    super.key,
    required this.text,
    this.fontSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.017,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: SplashTypography.fontFredoka,
          fontFamilyFallback: SplashTypography.fontFallbackSans,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: SplashColors.mint,
          height: 1.0,
          letterSpacing: -1.0,
          shadows: const [
            Shadow(
              color: SplashColors.mintDeep,
              offset: Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
      ),
    );
  }
}

/// Slanted gradient pill badge (e.g., "2 BARU", "ANONIM", "PRATINJAU", "1 PESAN").
class InboxSlantedBadge extends StatelessWidget {
  final String label;
  final double angle;
  final Color textColor;

  const InboxSlantedBadge({
    super.key,
    required this.label,
    this.angle = 0.10,
    this.textColor = SplashColors.inboxBadgeDarkText,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [SplashColors.inboxOrangeGrad, SplashColors.inboxPinkGrad],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: SplashColors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: SplashColors.inboxCardDropShadow,
              offset: Offset(0, 2.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: SplashTypography.fontFredoka,
            fontFamilyFallback: SplashTypography.fontFallbackSans,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textColor,
            height: 1.0,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

/// Top navigation bar for screens pushed above the shell (PESAN, STORY, ARSIP).
class InboxBackHeader extends StatelessWidget {
  final String title;
  final String pill;
  final VoidCallback onBack;

  const InboxBackHeader({
    super.key,
    required this.title,
    required this.pill,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              button: true,
              label: 'Kembali',
              child: GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: SplashColors.white.withValues(alpha: 0.12),
                    border: Border.all(
                      color: SplashColors.white.withValues(alpha: 0.65),
                      width: 1.8,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: SplashColors.white,
                    size: 17,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Inbox3DTitle(text: title, fontSize: 34),
                  const SizedBox(width: 6),
                  const Text(
                    '✦',
                    style: TextStyle(
                      color: SplashColors.yellow,
                      fontSize: 16,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 6),
                  InboxSlantedBadge(
                    label: pill,
                    angle: -0.06,
                    textColor: SplashColors.white,
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
