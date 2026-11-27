import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';

/// Reusable yellow notice strip for shared-account explanations in Profile.
class SharedAccountNote extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color iconColor;
  final bool compactMono;

  const SharedAccountNote({
    super.key,
    this.text =
        'Akun ini bisa dipakai bersama. Bagikan username dan password ke temanmu agar mereka bisa ikut mengelola pesan.',
    this.icon = Icons.person_outline_rounded,
    this.iconColor = SplashColors.purple,
    this.compactMono = false,
  });

  /// Compact variant displayed inside the "Ubah password" accordion.
  const SharedAccountNote.passwordHint({super.key})
      : text = 'Password baru berlaku untuk semua orang yang memakai akun ini.',
        icon = Icons.auto_awesome_rounded,
        iconColor = SplashColors.warningText,
        compactMono = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compactMono ? 12 : 16,
        vertical: compactMono ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: compactMono ? SplashColors.warningStripBg : SplashColors.warningBg,
        borderRadius: BorderRadius.circular(compactMono ? 12 : 20),
        border: Border.all(
          color: compactMono
              ? SplashColors.warningDashedBorder
              : SplashColors.yellow,
          width: compactMono ? 1.5 : 2.5,
        ),
        boxShadow: compactMono
            ? null
            : const [
                BoxShadow(
                  color: SplashColors.cardShadow,
                  offset: Offset(0, 5),
                  blurRadius: 0,
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: compactMono ? 16 : 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: compactMono
                    ? SplashTypography.fontSpaceMono
                    : SplashTypography.fontInter,
                fontFamilyFallback: compactMono
                    ? SplashTypography.fontFallbackMono
                    : SplashTypography.fontFallbackSans,
                fontSize: compactMono ? 10.5 : 11.5,
                fontWeight: compactMono ? FontWeight.w700 : FontWeight.w500,
                color: compactMono ? SplashColors.warningText : SplashColors.ink,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
