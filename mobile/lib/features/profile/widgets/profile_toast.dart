import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';

/// Shows a floating toast matching the Inbox/Links snackbar style.
void showProfileToast(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      backgroundColor:
          isError ? SplashColors.dangerDark : SplashColors.tealDark,
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_outline,
            color: isError ? SplashColors.dangerBg : SplashColors.mint,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: SplashTypography.fontFredoka,
                fontFamilyFallback: SplashTypography.fontFallbackSans,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: SplashColors.white,
              ),
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
