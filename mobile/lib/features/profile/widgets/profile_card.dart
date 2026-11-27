import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';

/// Hero card showing circular 56px mint-to-blue avatar with dark initial letter,
/// green online dot, "@username", "Akun bersama", and email.
class ProfileCard extends StatelessWidget {
  final String username;
  final String email;

  const ProfileCard({
    super.key,
    required this.username,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final displayUsername = username.isNotEmpty ? username : 'kamu';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SplashColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SplashColors.magenta, width: 3),
        boxShadow: const [
          BoxShadow(
            color: SplashColors.cardShadow,
            offset: Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          _ProfileAvatar(username: displayUsername),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@$displayUsername',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: SplashTypography.fontFredoka,
                    fontFamilyFallback: SplashTypography.fontFallbackSans,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: SplashColors.ink,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Akun bersama',
                  style: TextStyle(
                    fontFamily: SplashTypography.fontSpaceMono,
                    fontFamilyFallback: SplashTypography.fontFallbackMono,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: SplashColors.purple,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: SplashTypography.fontInter,
                    fontFamilyFallback: SplashTypography.fontFallbackSans,
                    fontSize: 12,
                    color: SplashColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String username;

  const _ProfileAvatar({required this.username});

  @override
  Widget build(BuildContext context) {
    final String initial =
        username.isNotEmpty ? username[0].toUpperCase() : '?';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [SplashColors.mint, SplashColors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: const TextStyle(
              fontFamily: SplashTypography.fontFredoka,
              fontFamilyFallback: SplashTypography.fontFallbackSans,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: SplashColors.ink,
              height: 1.0,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: SplashColors.successBright,
              shape: BoxShape.circle,
              border: Border.all(color: SplashColors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
