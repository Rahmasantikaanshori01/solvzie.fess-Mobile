import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';

/// Reusable Message Bubble widget used in PhonePreview.
/// Matches Figma `.message-bubble`.
class MessageBubbleWidget extends StatelessWidget {
  final String username;
  final String message;
  final String? song;

  const MessageBubbleWidget({
    super.key,
    required this.username,
    required this.message,
    this.song,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: SplashColors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: SplashColors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x401E1B3A),
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header: Avatar + Username + Subtitle ──
          Container(
            color: SplashColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                // Avatar circle with silhouette
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFD9D9E1), Color(0xFFF4F3F7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      size: 16,
                      color: Color(0xFFAAA4B5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // User & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '@$username',
                        style: TextStyle(
                          fontFamily: SplashTypography.fontFredoka,
                          fontFamilyFallback: SplashTypography.fontFallbackSans,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: SplashColors.ink,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'kirimi aku pesan anonim!',
                        style: TextStyle(
                          fontFamily: SplashTypography.fontFredoka,
                          fontFamilyFallback: SplashTypography.fontFallbackSans,
                          fontSize: 7.5,
                          fontWeight: FontWeight.w400,
                          color: SplashColors.ink.withValues(alpha: 0.6),
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Body: Pink Message Container ──
          Container(
            color: const Color(0xFFFF9FC9),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            constraints: const BoxConstraints(minHeight: 65),
            child: Text(
              message,
              style: TextStyle(
                fontFamily: SplashTypography.fontSpaceMono,
                fontFamilyFallback: SplashTypography.fontFallbackMono,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: SplashColors.ink,
                height: 1.45,
              ),
            ),
          ),

          // ── Optional Song Bar ──
          if (song != null && song!.isNotEmpty)
            Container(
              color: const Color(0xFF873F91),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Row(
                children: [
                  const Icon(
                    Icons.music_note_rounded,
                    size: 13,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      song!,
                      style: TextStyle(
                        fontFamily: SplashTypography.fontSpaceMono,
                        fontFamilyFallback: SplashTypography.fontFallbackMono,
                        fontSize: 7.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
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
