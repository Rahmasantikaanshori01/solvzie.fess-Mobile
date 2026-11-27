import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';

/// Message bubble rendered inside [PhonePreview] on [StoryScreen].
class StoryMessageBubble extends StatelessWidget {
  final String username;
  final String messageText;
  final String? songDisplay;

  const StoryMessageBubble({
    super.key,
    required this.username,
    required this.messageText,
    this.songDisplay,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSong = songDisplay != null && songDisplay!.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: SplashColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SplashColors.white, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: SplashColors.inboxCardDropShadow,
            offset: Offset(0, 5),
            blurRadius: 10,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: SplashColors.inboxBubbleAvatar,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 14,
                    color: SplashColors.white,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '@$username',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: SplashTypography.fontFredoka,
                          fontFamilyFallback: SplashTypography.fontFallbackSans,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: SplashColors.ink,
                        ),
                      ),
                      Text(
                        'kirimi aku pesan anonim!',
                        style: TextStyle(
                          fontFamily: SplashTypography.fontFredoka,
                          fontFamilyFallback: SplashTypography.fontFallbackSans,
                          fontSize: 7.5,
                          color: SplashColors.ink.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            color: SplashColors.inboxBubblePink,
            child: Text(
              messageText,
              style: TextStyle(
                fontFamily: SplashTypography.fontSpaceMono,
                fontFamilyFallback: SplashTypography.fontFallbackMono,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: SplashColors.inboxBubbleInk,
                height: 1.4,
              ),
            ),
          ),
          if (hasSong)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: SplashColors.inboxBubbleSongBg,
              child: Row(
                children: [
                  const Text(
                    '♫',
                    style: TextStyle(
                      color: SplashColors.white,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      songDisplay!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: SplashTypography.fontSpaceMono,
                        fontFamilyFallback: SplashTypography.fontFallbackMono,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: SplashColors.white,
                      ),
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
