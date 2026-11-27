import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';

/// Shared app-styled input field with bold top label, magenta/green/red border,
/// and inline error message underneath.
class ProfileInputField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? error;
  final bool isValid;
  final bool obscureText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final Widget? rightAction;

  const ProfileInputField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.focusNode,
    this.error,
    this.isValid = false,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.rightAction,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasError = error != null;
    final bool isFocused = focusNode.hasFocus;

    final Color borderColor = hasError
        ? SplashColors.danger
        : isValid
            ? SplashColors.fieldBorderValid
            : isFocused
                ? SplashColors.teal
                : SplashColors.fieldBorderPurple;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: SplashTypography.fontInter,
            fontFamilyFallback: SplashTypography.fontFallbackSans,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: SplashColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          constraints: const BoxConstraints(minHeight: 46),
          decoration: BoxDecoration(
            color: SplashColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: isFocused && !hasError
                ? const [
                    BoxShadow(
                      color: SplashColors.fieldFocusRingMint,
                      spreadRadius: 3,
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          padding: EdgeInsets.only(
            left: 13,
            right: rightAction != null ? 4 : 13,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    fontFamily: SplashTypography.fontInter,
                    fontFamilyFallback: SplashTypography.fontFallbackSans,
                    fontSize: 14,
                    color: SplashColors.ink,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 11),
                    hintText: placeholder,
                    hintStyle: const TextStyle(
                      fontFamily: SplashTypography.fontInter,
                      fontFamilyFallback: SplashTypography.fontFallbackSans,
                      fontSize: 14,
                      color: SplashColors.hintMuted,
                    ),
                  ),
                  onChanged: onChanged,
                ),
              ),
              if (rightAction != null) rightAction!,
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Text(
            error!,
            style: const TextStyle(
              fontFamily: SplashTypography.fontInter,
              fontFamilyFallback: SplashTypography.fontFallbackSans,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: SplashColors.dangerDark,
            ),
          ),
        ],
      ],
    );
  }
}
