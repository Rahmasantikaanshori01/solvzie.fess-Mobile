import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/features/splash/widgets/burst_painter.dart';
import 'package:mobile/features/splash/widgets/fish_painter.dart';

/// Shared empty state card for Inbox (used identically across all 3 tabs)
/// and optionally customized for the standalone Arsip screen.
class InboxEmptyState extends StatelessWidget {
  final String title;
  final String body;

  const InboxEmptyState({
    super.key,
    this.title = 'Masih sepi di sini',
    this.body = 'Bagikan link-mu biar pesan rahasia mulai berdatangan.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: SplashColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: SplashColors.magenta,
          width: 3.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: SplashColors.inboxCardDropShadow,
            offset: Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Transform.rotate(
                angle: 0.12,
                child: const StickerStarWidget(
                  label: '✦',
                  size: 62,
                  color: SplashColors.purple,
                ),
              ),
              Transform.translate(
                offset: const Offset(-10, 6),
                child: const FishWidget(
                  width: 72,
                  height: 42,
                  fillColor: SplashColors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: SplashTypography.fontFredoka,
              fontFamilyFallback: SplashTypography.fontFallbackSans,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: SplashColors.inboxEmptyTitle,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: SplashTypography.fontInter,
              fontFamilyFallback: SplashTypography.fontFallbackSans,
              fontSize: 12.5,
              height: 1.45,
              color: SplashColors.inboxEmptyBody,
            ),
          ),
        ],
      ),
    );
  }
}
