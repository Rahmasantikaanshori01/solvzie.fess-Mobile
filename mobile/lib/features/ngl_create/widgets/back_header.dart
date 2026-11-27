import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';

class NglBackHeader extends StatelessWidget {
  final String title;
  final String pill;
  final VoidCallback onBack;

  const NglBackHeader({
    super.key,
    required this.title,
    required this.pill,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Memberi jarak atas dan bawah yang cukup agar judul seperti "TEMA"
      // tidak tertutup oleh frame pratinjau.
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Tombol Kembali melingkar di kiri
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.55),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),

          // Judul Tengah + Kicker Pill Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 44),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 3D Extruded Mint Title
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      for (int i = 5; i >= 1; i--)
                        Transform.translate(
                          offset: Offset(0, i * 1.5),
                          child: Text(
                            title,
                            style: TextStyle(
                              fontFamily: SplashTypography.fontFredoka,
                              fontFamilyFallback: SplashTypography.fontFallbackSans,
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1.0,
                              height: 1.0,
                              color: i > 3
                                  ? const Color(0xFF258667)
                                  : const Color(0xFF38BD83),
                            ),
                          ),
                        ),
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: SplashTypography.fontFredoka,
                          fontFamilyFallback: SplashTypography.fontFallbackSans,
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.0,
                          height: 1.0,
                          color: SplashColors.mint,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 4),

                  // Sparkle icon
                  const Text(
                    '✦',
                    style: TextStyle(
                      color: SplashColors.yellow,
                      fontSize: 16,
                      height: 1.0,
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Slanted Pink/Orange Badge
                  Transform.rotate(
                    angle: -0.06,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9A3D), Color(0xFFFF6EC7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white, width: 1.8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x60541C68),
                            offset: Offset(0, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        pill,
                        style: TextStyle(
                          fontFamily: SplashTypography.fontFredoka,
                          fontFamilyFallback: SplashTypography.fontFallbackSans,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                    ),
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
