import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';

/// Animated inline accordion section with rotating chevron and optional bottom divider.
class ExpandableSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isOpen;
  final VoidCallback onTap;
  final Widget child;
  final bool showDivider;

  const ExpandableSection({
    super.key,
    required this.icon,
    required this.title,
    required this.isOpen,
    required this.onTap,
    required this.child,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          expanded: isOpen,
          label: title,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Row(
                  children: [
                    Icon(icon, color: SplashColors.purple, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: SplashTypography.fontFredoka,
                          fontFamilyFallback: SplashTypography.fontFallbackSans,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: SplashColors.ink,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isOpen ? 0.25 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: SplashColors.purple,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isOpen ? child : const SizedBox.shrink(),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: SplashColors.dividerSoft),
      ],
    );
  }
}
