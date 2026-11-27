import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/features/inbox/models/message_item.dart';
import 'package:mobile/features/inbox/utils/relative_time.dart';

/// Individual message row card displayed inside [InboxScreen] tabs.
class MessageRowCard extends StatelessWidget {
  final MessageItem message;
  final VoidCallback onTap;

  const MessageRowCard({
    super.key,
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !message.isRead;
    final String relativeTime = formatRelativeTime(message.createdAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: SplashColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: SplashColors.inboxMagentaBorder,
            width: 3.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isUnread
                  ? SplashColors.inboxMagentaBorder
                  : SplashColors.inboxMagentaShadowSoft,
              offset: const Offset(0, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. 54px envelope circle (+ optional songfess badge)
                _EnvelopeBadge(
                  isUnread: isUnread,
                  isSongfess: message.isSongfess,
                ),
                const SizedBox(width: 12),

                // 2. Content block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isUnread) ...[
                        Text(
                          'Pesan baru!',
                          style: TextStyle(
                            fontFamily: SplashTypography.fontFredoka,
                            fontFamilyFallback:
                                SplashTypography.fontFallbackSans,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: SplashColors.inboxMagentaText,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _MetaLine(
                          nglName: message.nglName,
                          relativeTime: relativeTime,
                        ),
                      ] else ...[
                        _MetaLine(
                          nglName: message.nglName,
                          relativeTime: relativeTime,
                        ),
                        const SizedBox(height: 6),
                        CustomPaint(
                          painter: const _DashedRoundedRectPainter(
                            color: SplashColors.inboxDashedPurple,
                            strokeWidth: 2.0,
                            radius: 10.0,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            child: Text(
                              message.text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: SplashTypography.fontSpaceMono,
                                fontFamilyFallback:
                                    SplashTypography.fontFallbackMono,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: SplashColors.ink,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // 3. Purple chevron
                const Icon(
                  Icons.chevron_right_rounded,
                  color: SplashColors.inboxPurple,
                  size: 26,
                ),
              ],
            ),

            // Unread pink dot at top-right corner
            if (isUnread)
              Positioned(
                top: -2,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: SplashColors.inboxPinkDot,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EnvelopeBadge extends StatelessWidget {
  final bool isUnread;
  final bool isSongfess;

  const _EnvelopeBadge({
    required this.isUnread,
    required this.isSongfess,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 54,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isUnread
                  ? const LinearGradient(
                      colors: [
                        SplashColors.inboxPurpleDeep,
                        SplashColors.inboxBlueDeep,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isUnread ? null : SplashColors.inboxEnvelopeLavender,
            ),
            child: Center(
              child: CustomPaint(
                size: const Size(32, 23),
                painter: _EnvelopeIconPainter(isUnread: isUnread),
              ),
            ),
          ),
          if (isSongfess)
            Positioned(
              right: -3,
              bottom: -2,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: SplashColors.inboxPurple,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: SplashColors.white,
                    width: 2.0,
                  ),
                ),
                child: const Icon(
                  Icons.music_note_rounded,
                  color: SplashColors.white,
                  size: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EnvelopeIconPainter extends CustomPainter {
  final bool isUnread;

  const _EnvelopeIconPainter({required this.isUnread});

  @override
  void paint(Canvas canvas, Size size) {
    final Color bodyColor =
        isUnread ? SplashColors.white : SplashColors.lavenderMuted;
    final Color accentColor = isUnread
        ? SplashColors.inboxEnvelopeAccent
        : SplashColors.inboxEnvelopeBorder;

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(6.5),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = bodyColor
        ..style = PaintingStyle.fill,
    );

    // Envelope flap V
    final flapPath = Path()
      ..moveTo(2, 2.5)
      ..lineTo(size.width / 2, size.height * 0.56)
      ..lineTo(size.width - 2, 2.5);

    canvas.drawPath(
      flapPath,
      Paint()
        ..color = accentColor.withValues(alpha: isUnread ? 0.9 : 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // Small heart icon in center
    final cx = size.width / 2;
    final cy = size.height * 0.63;
    const r = 3.2;
    final heartPath = Path()
      ..moveTo(cx, cy + r)
      ..cubicTo(cx - r * 1.4, cy + r * 0.1, cx - r * 1.3, cy - r * 1.1, cx,
          cy - r * 0.25)
      ..cubicTo(cx + r * 1.3, cy - r * 1.1, cx + r * 1.4, cy + r * 0.1, cx,
          cy + r)
      ..close();

    canvas.drawPath(
      heartPath,
      Paint()
        ..color = accentColor
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _EnvelopeIconPainter oldDelegate) =>
      oldDelegate.isUnread != isUnread;
}

class _MetaLine extends StatelessWidget {
  final String nglName;
  final String relativeTime;

  const _MetaLine({
    required this.nglName,
    required this.relativeTime,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 155),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
            decoration: BoxDecoration(
              color: SplashColors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: SplashColors.inboxMagentaBorder,
                width: 2.0,
              ),
            ),
            child: Text(
              nglName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: SplashTypography.fontFredoka,
                fontFamilyFallback: SplashTypography.fontFallbackSans,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: SplashColors.ink,
                height: 1.15,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            relativeTime,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: SplashTypography.fontFredoka,
              fontFamilyFallback: SplashTypography.fontFallbackSans,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: SplashColors.inboxMetaText,
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedRoundedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;

  const _DashedRoundedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset(strokeWidth / 2, strokeWidth / 2) &
          Size(size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const double dashLength = 5.0;
    const double gapLength = 3.5;

    for (final ui.PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double next = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedRectPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.radius != radius;
}
