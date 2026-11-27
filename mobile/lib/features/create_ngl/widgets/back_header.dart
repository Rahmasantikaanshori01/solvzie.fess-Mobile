import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';

/// Reusable BackHeader with circular back button, 3D extruded title, and slant pill kicker.
/// Matching Figma `.back-header`, `.page-title-wrap`, and `.slant-pill`.
class BackHeader extends StatelessWidget {
  final String title;
  final String? pill;
  final VoidCallback? onBack;

  const BackHeader({
    super.key,
    required this.title,
    this.pill,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Circular Back Button ──
          GestureDetector(
            onTap: onBack ?? () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: SplashColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: SplashColors.magenta, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x60541C68),
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: SplashColors.ink,
                ),
              ),
            ),
          ),

          // ── Centered 3D Extruded Title & Kicker Pill ──
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // 3D Extruded Title
              _ExtrudedTitleText(text: title),

              // Sparkle ✦ at top right
              Positioned(
                top: -8,
                right: pill != null ? -30 : -14,
                child: Transform.rotate(
                  angle: 0.2,
                  child: const Text(
                    '✦',
                    style: TextStyle(
                      fontSize: 18,
                      color: SplashColors.yellow,
                      shadows: [
                        Shadow(
                          color: Color(0xFFC78C1E),
                          offset: Offset(0, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Slant pill kicker
              if (pill != null)
                Positioned(
                  right: -36,
                  top: 26,
                  child: Transform.rotate(
                    angle: -0.06,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9A3D), Color(0xFFFF6EC7)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: SplashColors.white,
                          width: 2.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF9E4B18),
                            offset: Offset(0, 2.5),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        pill!,
                        style: TextStyle(
                          fontFamily: SplashTypography.fontFredoka,
                          fontFamilyFallback: SplashTypography.fontFallbackSans,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: SplashColors.white,
                          letterSpacing: 0.3,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Empty balance box
          const SizedBox(width: 38),
        ],
      ),
    );
  }
}

class _ExtrudedTitleText extends StatelessWidget {
  final String text;

  const _ExtrudedTitleText({required this.text});

  @override
  Widget build(BuildContext context) {
    const double fontSize = 36.0;
    const int steps = 5;
    const double stepSize = 1.6;

    final baseStyle = TextStyle(
      fontFamily: SplashTypography.fontFredoka,
      fontFamilyFallback: SplashTypography.fontFallbackSans,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.0,
      height: 1.0,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        // Extrusion layers
        for (int s = steps; s >= 1; s--)
          Transform.translate(
            offset: Offset(s * stepSize * 0.3, s * stepSize),
            child: Text(
              text,
              style: baseStyle.copyWith(
                color: s > steps ~/ 2
                    ? SplashColors.mintDeep
                    : SplashColors.mintDark,
              ),
            ),
          ),

        // Face layer
        Text(
          text,
          style: baseStyle.copyWith(
            color: SplashColors.mint,
            shadows: [
              Shadow(
                color: SplashColors.mintLight.withValues(alpha: 0.6),
                offset: const Offset(0, -1),
                blurRadius: 0,
              ),
              Shadow(
                color: const Color(0xFF0E4659).withValues(alpha: 0.4),
                offset: const Offset(1, steps * stepSize + 3),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
