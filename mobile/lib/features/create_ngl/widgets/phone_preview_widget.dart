import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/features/splash/widgets/logo_compact.dart';

/// PhonePreviewWidget — renders the mobile mockup with custom background or gradient
/// and message bubble.
/// Matches Figma `.phone-preview`, `.preview-stage`, and `.preview-tall`.
class PhonePreviewWidget extends StatelessWidget {
  final String? imagePath;
  final String theme; // 'sunset', 'violet', 'aqua'
  final String position; // 'top', 'middle', 'bottom'
  final Widget child;

  const PhonePreviewWidget({
    super.key,
    this.imagePath,
    this.theme = 'sunset',
    this.position = 'middle',
    required this.child,
  });

  static const _themeGradients = <String, List<Color>>{
    'sunset': [Color(0xFFFF6EC7), Color(0xFFFF9A3D)],
    'violet': [Color(0xFFA855F7), Color(0xFF60A5FA)],
    'aqua': [Color(0xFF5EEAA8), Color(0xFF60A5FA)],
  };

  @override
  Widget build(BuildContext context) {
    final gradientColors =
        _themeGradients[theme] ?? _themeGradients['sunset']!;

    return Center(
      child: Container(
        width: 216,
        height: 384, // 9:16 aspect ratio
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(27),
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: const [
            BoxShadow(
              color: Color(0x731E1B3A), // rgba(30, 27, 58, 0.45)
              offset: Offset(0, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Background Layer ──
            if (imagePath != null && imagePath!.isNotEmpty)
              Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(imagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: const Alignment(-0.8, -0.9),
                          end: const Alignment(0.8, 0.9),
                        ),
                      ),
                    ),
                  ),
                  // Dark contrast overlay matching Figma
                  Container(
                    color: const Color(0xFF081822).withValues(alpha: 0.25),
                  ),
                ],
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: const Alignment(-0.8, -0.9),
                    end: const Alignment(0.8, 0.9),
                  ),
                ),
                child: CustomPaint(
                  painter: _RadialGlowPainter(),
                ),
              ),

            // ── Decorative Top-Right Sparkle ──
            const Positioned(
              top: 14,
              right: 14,
              child: Text(
                '✦',
                style: TextStyle(
                  fontSize: 26,
                  color: SplashColors.yellow,
                  shadows: [
                    Shadow(
                      color: Color(0x60000000),
                      offset: Offset(0, 1.5),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),

            // ── Decorative Bottom-Right White Dot ──
            Positioned(
              bottom: 34,
              right: 18,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // ── Main Content at Chosen Position ──
            Padding(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: position == 'top'
                    ? 54
                    : position == 'bottom'
                        ? 100
                        : 20,
                bottom: position == 'bottom'
                    ? 44
                    : position == 'top'
                        ? 100
                        : 20,
              ),
              child: Align(
                alignment: position == 'top'
                    ? Alignment.topCenter
                    : position == 'bottom'
                        ? Alignment.bottomCenter
                        : Alignment.center,
                child: child,
              ),
            ),

            // ── Bottom Solvzie.fess Compact Logo ──
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Center(
                child: const LogoCompact(scale: 0.62),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadialGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.6),
        radius: 0.8,
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
