import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';

/// Header for ProfileScreen: 3D mint "PROFIL" title + slanted "KAMU" gradient badge.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Transform.rotate(
                  angle: -0.017,
                  child: const Text(
                    'PROFIL',
                    style: TextStyle(
                      fontFamily: SplashTypography.fontLilitaOne,
                      fontFamilyFallback: SplashTypography.fontFallbackDisplay,
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: SplashColors.mint,
                      height: 1.0,
                      letterSpacing: -1.0,
                      shadows: [
                        Shadow(
                          color: SplashColors.mintShadowDeep,
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                        Shadow(
                          color: SplashColors.inboxCardDropShadow,
                          offset: Offset(0, 7),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Transform.rotate(
                  angle: -5.0 * math.pi / 180.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [SplashColors.orange, SplashColors.pink],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: SplashColors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: SplashColors.pillBadgeShadow,
                          offset: Offset(0, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Text(
                      'KAMU',
                      style: TextStyle(
                        fontFamily: SplashTypography.fontFredoka,
                        fontFamilyFallback: SplashTypography.fontFallbackSans,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: SplashColors.inboxBadgeDarkText,
                        letterSpacing: 0.5,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: -4,
              right: -14,
              child: Transform.rotate(
                angle: 20.0 * math.pi / 180.0,
                child: const Text(
                  '✦',
                  style: TextStyle(
                    color: SplashColors.yellow,
                    fontSize: 18,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
