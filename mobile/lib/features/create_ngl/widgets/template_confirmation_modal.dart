import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';

/// Modal dialog matching Figma `.modal-backdrop` and `.modal-card`.
/// Used for template confirmation (Screenshot 3) and deletion confirmation.
class TemplateModalDialog extends StatelessWidget {
  final String title;
  final String? body;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final String? cancelLabel;
  final VoidCallback? onCancel;
  final bool isDanger;

  const TemplateModalDialog({
    super.key,
    required this.title,
    this.body,
    required this.confirmLabel,
    required this.onConfirm,
    this.cancelLabel,
    this.onCancel,
    this.isDanger = false,
  });

  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    String? body,
    required String confirmLabel,
    String? cancelLabel,
    bool isDanger = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: const Color(0xB8091B28), // rgba(9, 27, 40, 0.72)
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: TemplateModalDialog(
          title: title,
          body: body,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          isDanger: isDanger,
          onConfirm: () => Navigator.of(ctx).pop(true),
          onCancel: () => Navigator.of(ctx).pop(false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      alignment: Alignment.bottomCenter, // Appears smoothly from bottom
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 390),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // ── Main Card ──
            Container(
              margin: const EdgeInsets.only(top: 26),
              padding: const EdgeInsets.fromLTRB(22, 34, 22, 22),
              decoration: BoxDecoration(
                color: SplashColors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDanger ? const Color(0xFFB42318) : SplashColors.magenta,
                  width: 3.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDanger
                        ? const Color(0x605A5A7A)
                        : const Color(0xFF582659),
                    offset: const Offset(0, 8),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: SplashTypography.fontFredoka,
                      fontFamilyFallback: SplashTypography.fontFallbackSans,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDanger
                          ? const Color(0xFF1D2A4D)
                          : const Color(0xFF753AB2),
                      height: 1.25,
                    ),
                  ),

                  // Body
                  if (body != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      body!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: SplashTypography.fontFredoka,
                        fontFamilyFallback: SplashTypography.fontFallbackSans,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF746D7C),
                        height: 1.45,
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Actions
                  if (cancelLabel != null)
                    Row(
                      children: [
                        Expanded(
                          child: _buildButton(
                            label: confirmLabel,
                            isPrimary: true,
                            isDanger: isDanger,
                            onTap: onConfirm,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildButton(
                            label: cancelLabel!,
                            isPrimary: false,
                            isDanger: false,
                            onTap: onCancel ?? () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: _buildButton(
                        label: confirmLabel,
                        isPrimary: true,
                        isDanger: isDanger,
                        onTap: onConfirm,
                      ),
                    ),
                ],
              ),
            ),

            // ── Floating Badge Icon (Overhanging) ──
            Positioned(
              top: 0,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isDanger ? const Color(0xFFFDECEC) : const Color(0xFFFFE0F3),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: isDanger ? const Color(0xFFB42318) : SplashColors.magenta,
                    width: 3.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x301E1B3A),
                      offset: Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: isDanger
                      ? const Icon(
                          Icons.delete_outline_rounded,
                          size: 26,
                          color: Color(0xFFB42318),
                        )
                      : const Text(
                          '✦',
                          style: TextStyle(
                            fontSize: 26,
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
    );
  }

  Widget _buildButton({
    required String label,
    required bool isPrimary,
    required bool isDanger,
    required VoidCallback onTap,
  }) {
    if (!isPrimary) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F0FA),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFD8C9DF), width: 2),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: SplashTypography.fontFredoka,
                fontFamilyFallback: SplashTypography.fontFallbackSans,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: SplashColors.ink.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          gradient: isDanger
              ? const LinearGradient(colors: [Color(0xFFE53E3E), Color(0xFFB42318)])
              : const LinearGradient(
                  colors: [Color(0xFFA855F7), Color(0xFF60A5FA)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: isDanger ? const Color(0xFF7B1D1D) : const Color(0xFF4C2A75),
              offset: const Offset(0, 3.5),
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
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
