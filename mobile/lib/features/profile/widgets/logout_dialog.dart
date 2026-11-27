import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';

/// Centered logout confirmation modal with dimmed + blurred backdrop,
/// pink top logout icon box, purple bold title, and "Batal" / "Ya, logout" buttons.
class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  /// Shows the dialog and returns `true` only if "Ya, logout" is tapped.
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (_) => const LogoutDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        key: const Key('logout-dialog-backdrop'),
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(false),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: SplashColors.modalBarrierDark,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GestureDetector(
              onTap: () {},
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                  decoration: BoxDecoration(
                    color: SplashColors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: SplashColors.magenta, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: SplashColors.cardShadow,
                        offset: Offset(0, 8),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pink icon box with logout icon
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: SplashColors.modalIconPinkBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: SplashColors.magenta,
                            width: 2.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: SplashColors.magenta,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Yakin mau logout?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: SplashTypography.fontFredoka,
                          fontFamilyFallback: SplashTypography.fontFallbackSans,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: SplashColors.purpleDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Kamu perlu masuk lagi untuk melihat pesan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: SplashTypography.fontInter,
                          fontFamilyFallback: SplashTypography.fontFallbackSans,
                          fontSize: 13,
                          color: SplashColors.muted,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: Semantics(
                              button: true,
                              label: 'Batal',
                              child: SizedBox(
                                height: 46,
                                child: OutlinedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: SplashColors.white,
                                    side: const BorderSide(
                                      color: SplashColors.purple,
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Batal',
                                      style: TextStyle(
                                        fontFamily:
                                            SplashTypography.fontFredoka,
                                        fontFamilyFallback:
                                            SplashTypography.fontFallbackSans,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: SplashColors.purpleDark,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Semantics(
                              button: true,
                              label: 'Ya, logout',
                              child: Container(
                                height: 46,
                                decoration: BoxDecoration(
                                  color: SplashColors.magenta,
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: SplashColors.pillBadgeShadow,
                                      offset: Offset(0, 3.5),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Ya, logout',
                                      style: TextStyle(
                                        fontFamily:
                                            SplashTypography.fontFredoka,
                                        fontFamilyFallback:
                                            SplashTypography.fontFallbackSans,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: SplashColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
