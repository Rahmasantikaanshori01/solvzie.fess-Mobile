import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';

enum InboxTab {
  semua('Semua'),
  belumDibaca('Belum dibaca'),
  arsip('Arsip');

  final String label;
  const InboxTab(this.label);
}

/// Segmented capsule tab bar for Inbox ("Semua", "Belum dibaca", "Arsip").
class InboxTabBar extends StatelessWidget {
  final InboxTab selectedTab;
  final ValueChanged<InboxTab> onChanged;

  const InboxTabBar({
    super.key,
    required this.selectedTab,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: SplashColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: SplashColors.inboxMagentaBorder,
          width: 3.0,
        ),
      ),
      child: Row(
        children: InboxTab.values.map((tab) {
          final isActive = tab == selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(tab),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                constraints: const BoxConstraints(minHeight: 42),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: isActive
                    ? BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            SplashColors.inboxPurple,
                            SplashColors.inboxBlueDeep,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      )
                    : null,
                child: Center(
                  child: Text(
                    tab.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: SplashTypography.fontFredoka,
                      fontFamilyFallback: SplashTypography.fontFallbackSans,
                      fontSize: 13.5,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      color: isActive ? SplashColors.white : SplashColors.ink,
                      height: 1.05,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
