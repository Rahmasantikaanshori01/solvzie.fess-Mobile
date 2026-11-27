import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/features/ngl_create/models/ngl_draft.dart';

/// Bottom sheet opened from the three-dot button on a LinkCard.
class LinkMenuSheet {
  const LinkMenuSheet._();

  static Future<void> show({
    required BuildContext context,
    required NglItem ngl,
    required Future<void> Function() onSoftDelete,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: SplashColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: SplashColors.magenta, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: SplashColors.cardShadow,
                offset: Offset(0, 6),
                blurRadius: 0,
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: SplashColors.borderSoft,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  ngl.name,
                  style: TextStyle(
                    fontFamily: SplashTypography.fontFredoka,
                    fontFamilyFallback: SplashTypography.fontFallbackSans,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: SplashColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                _SheetOptionTile(
                  icon: Icons.palette_outlined,
                  label: 'Edit desain',
                  color: SplashColors.ink,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    // // TODO(step-6): implement edit desain flow
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Segera hadir'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                _SheetOptionTile(
                  icon: Icons.link_rounded,
                  label: 'Edit link',
                  color: SplashColors.ink,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    // // TODO(step-6): implement edit link flow
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Segera hadir'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: SplashColors.borderSoft, height: 1),
                ),
                _SheetOptionTile(
                  icon: Icons.delete_outline_rounded,
                  label: 'Hapus NGL',
                  color: SplashColors.danger,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final confirmed = await _confirmDeleteNgl(context, ngl);
                    if (confirmed == true) {
                      await onSoftDelete();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<bool?> _confirmDeleteNgl(BuildContext context, NglItem ngl) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          decoration: BoxDecoration(
            color: SplashColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: SplashColors.danger, width: 2.5),
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
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: SplashColors.dangerBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: SplashColors.danger, width: 2),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: SplashColors.danger,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Hapus NGL "${ngl.name}"?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: SplashTypography.fontFredoka,
                  fontFamilyFallback: SplashTypography.fontFallbackSans,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: SplashColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Riwayat pesan tetap tersimpan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: SplashTypography.fontInter,
                  fontFamilyFallback: SplashTypography.fontFallbackSans,
                  fontSize: 13,
                  color: SplashColors.ink.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: SplashColors.white,
                          foregroundColor: SplashColors.ink,
                          side: const BorderSide(
                            color: SplashColors.borderSoft,
                            width: 1.8,
                          ),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            fontFamily: SplashTypography.fontFredoka,
                            fontFamilyFallback:
                                SplashTypography.fontFallbackSans,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SplashColors.danger,
                          foregroundColor: SplashColors.white,
                          elevation: 0,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          'Hapus NGL',
                          style: TextStyle(
                            fontFamily: SplashTypography.fontFredoka,
                            fontFamilyFallback:
                                SplashTypography.fontFallbackSans,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
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
    );
  }
}

class _SheetOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SheetOptionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 46),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: SplashTypography.fontFredoka,
                    fontFamilyFallback: SplashTypography.fontFallbackSans,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
