import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';

/// Modal dialog/bottom sheet with blurred background (Layar 3: Konfirmasi).
class KonfirmasiBottomSheet {
  static Future<bool?> show(BuildContext context) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Konfirmasi',
      barrierColor: Colors.black.withValues(alpha: 0.50),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return Stack(
          children: [
            // Backdrop Blur
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: const SizedBox.expand(),
            ),

            // Modal Card centered
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Material(
                  color: Colors.transparent,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      // Card Body
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 26),
                        padding: const EdgeInsets.fromLTRB(20, 36, 20, 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: SplashColors.magenta,
                            width: 2.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x60541C68),
                              offset: Offset(0, 10),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Template ini sudah polos tanpa teks?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: SplashTypography.fontFredoka,
                                fontFamilyFallback: SplashTypography.fontFallbackSans,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF6C2E9C),
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Bubble pesan, nama, dan lagu akan ditambahkan otomatis.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: SplashTypography.fontFredoka,
                                fontFamilyFallback: SplashTypography.fontFallbackSans,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                                color: SplashColors.ink.withValues(alpha: 0.65),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 18),
                            // Button "Sudah polos"
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(true),
                              child: Container(
                                width: double.infinity,
                                height: 46,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFA855F7),
                                      Color(0xFF60A5FA),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.8,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xFF4C2A75),
                                      offset: Offset(0, 3.5),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'Sudah polos',
                                    style: TextStyle(
                                      fontFamily: SplashTypography.fontFredoka,
                                      fontFamilyFallback:
                                          SplashTypography.fontFallbackSans,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Floating Top Sparkle Icon Badge
                      Positioned(
                        top: 0,
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCE7F3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: SplashColors.magenta,
                              width: 2.0,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x40541C68),
                                offset: Offset(0, 4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '✦',
                              style: TextStyle(
                                fontSize: 24,
                                color: SplashColors.magenta,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: anim1,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }
}
