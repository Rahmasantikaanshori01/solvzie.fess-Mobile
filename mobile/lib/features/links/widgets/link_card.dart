import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/features/links/widgets/link_menu_sheet.dart';
import 'package:mobile/features/links/widgets/ngl_thumbnail.dart';
import 'package:mobile/features/ngl_create/models/ngl_draft.dart';
import 'package:share_plus/share_plus.dart';

/// Card displaying a single NGL link on the Links page.
class LinkCard extends StatelessWidget {
  final NglItem ngl;
  final int? messageCount;
  final int? newMessageCount;
  final VoidCallback onToggleActive;
  final Future<void> Function() onSoftDelete;

  const LinkCard({
    super.key,
    required this.ngl,
    this.messageCount,
    this.newMessageCount,
    required this.onToggleActive,
    required this.onSoftDelete,
  });

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: ngl.shareUrl));
    if (!context.mounted) return;
    _showToast(context, 'Link disalin');
  }

  Future<void> _shareLink(BuildContext context) async {
    if (kIsWeb) {
      await _copyLink(context);
      return;
    }
    try {
      await SharePlus.instance.share(
        ShareParams(text: ngl.shareUrl, subject: ngl.name),
      );
    } catch (_) {
      if (context.mounted) {
        await _copyLink(context);
      }
    }
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SplashColors.tealDark,
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: SplashColors.mint,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              message,
              style: TextStyle(
                fontFamily: SplashTypography.fontFredoka,
                fontFamilyFallback: SplashTypography.fontFallbackSans,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: SplashColors.white,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = ngl.active;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive ? SplashColors.white : SplashColors.lavenderMuted,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isActive
              ? SplashColors.magenta
              : SplashColors.magenta.withValues(alpha: 0.55),
          width: 3.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? SplashColors.cardShadow
                : SplashColors.cardShadow.withValues(alpha: 0.25),
            offset: const Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top main info row: Thumbnail + details + toggle
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 9:16 pure photo/gradient thumbnail
              NglThumbnail(
                ngl: ngl,
                width: 60,
                height: 106,
                borderRadius: 10,
                dimmed: !isActive,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Toggle
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            ngl.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: SplashTypography.fontFredoka,
                              fontFamilyFallback:
                                  SplashTypography.fontFallbackSans,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isActive
                                  ? SplashColors.ink
                                  : SplashColors.ink.withValues(alpha: 0.65),
                              height: 1.15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _ActiveSwitch(
                          active: isActive,
                          label: ngl.name,
                          onTap: onToggleActive,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Type pill chip ("Menfess")
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: SplashColors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: SplashColors.magenta,
                          width: 1.3,
                        ),
                      ),
                      child: Text(
                        ngl.type,
                        style: TextStyle(
                          fontFamily: SplashTypography.fontFredoka,
                          fontFamilyFallback: SplashTypography.fontFallbackSans,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: SplashColors.magenta,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // URL row (tap to copy)
                    InkWell(
                      onTap: () => _copyLink(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                ngl.displayLink,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: SplashTypography.fontSpaceMono,
                                  fontFamilyFallback:
                                      SplashTypography.fontFallbackMono,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: SplashColors.purpleDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.copy_rounded,
                              size: 13,
                              color: SplashColors.purpleDark,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 2),

                    // Receive status line
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: isActive
                                ? SplashColors.success
                                : SplashColors.mutedLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: isActive ? 'Aktif' : 'Nonaktif',
                                  style: TextStyle(
                                    fontFamily: SplashTypography.fontFredoka,
                                    fontFamilyFallback:
                                        SplashTypography.fontFallbackSans,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: isActive
                                        ? SplashColors.successDark
                                        : SplashColors.muted,
                                  ),
                                ),
                                TextSpan(
                                  text: isActive
                                      ? ' · menerima pesan'
                                      : ' · tidak menerima pesan',
                                  style: TextStyle(
                                    fontFamily: SplashTypography.fontInter,
                                    fontFamilyFallback:
                                        SplashTypography.fontFallbackSans,
                                    fontSize: 11,
                                    color:
                                        SplashColors.ink.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Message count line
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${messageCount ?? ngl.messageCount} pesan · ',
                            style: TextStyle(
                              fontFamily: SplashTypography.fontInter,
                              fontFamilyFallback:
                                  SplashTypography.fontFallbackSans,
                              fontSize: 11.5,
                              color: SplashColors.ink.withValues(alpha: 0.7),
                            ),
                          ),
                          if ((newMessageCount ?? ngl.newMessageCount) > 0)
                            TextSpan(
                              text: '${newMessageCount ?? ngl.newMessageCount} baru',
                              style: TextStyle(
                                fontFamily: SplashTypography.fontFredoka,
                                fontFamilyFallback:
                                    SplashTypography.fontFallbackSans,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: SplashColors.magenta,
                              ),
                            )
                          else
                            TextSpan(
                              text: 'semua sudah dibaca',
                              style: TextStyle(
                                fontFamily: SplashTypography.fontInter,
                                fontFamilyFallback:
                                    SplashTypography.fontFallbackSans,
                                fontSize: 11.5,
                                color: SplashColors.ink.withValues(alpha: 0.55),
                              ),
                            ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action buttons row (min height 44)
          Row(
            children: [
              // Salin
              Expanded(
                child: _GradientActionButton(
                  label: 'Salin',
                  colors: const [SplashColors.purple, SplashColors.blue],
                  shadowColor: SplashColors.buttonPurpleShadow,
                  onTap: () => _copyLink(context),
                ),
              ),
              const SizedBox(width: 8),
              // Bagikan
              Expanded(
                child: _GradientActionButton(
                  label: 'Bagikan',
                  colors: const [SplashColors.orange, SplashColors.rope1],
                  shadowColor: SplashColors.buttonOrangeShadow,
                  onTap: () => _shareLink(context),
                ),
              ),
              const SizedBox(width: 8),
              // Three-dot menu button
              Semantics(
                button: true,
                label: 'Opsi ${ngl.name}',
                child: GestureDetector(
                  onTap: () => LinkMenuSheet.show(
                    context: context,
                    ngl: ngl,
                    onSoftDelete: onSoftDelete,
                  ),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: SplashColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: SplashColors.purple,
                        width: 2.0,
                      ),
                    ),
                    child: const Icon(
                      Icons.more_horiz_rounded,
                      color: SplashColors.purple,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveSwitch extends StatelessWidget {
  final bool active;
  final String label;
  final VoidCallback onTap;

  const _ActiveSwitch({
    required this.active,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: active,
      label: '${active ? 'Nonaktifkan' : 'Aktifkan'} $label',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 44),
          alignment: Alignment.topCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 46,
            height: 26,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: active ? SplashColors.purple : const Color(0xFFC4B5D6),
              borderRadius: BorderRadius.circular(999),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 180),
              alignment:
                  active ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: SplashColors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  final String label;
  final List<Color> colors;
  final Color shadowColor;
  final VoidCallback onTap;

  const _GradientActionButton({
    required this.label,
    required this.colors,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: SplashColors.white, width: 1.8),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: SplashTypography.fontFredoka,
              fontFamilyFallback: SplashTypography.fontFallbackSans,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: SplashColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
