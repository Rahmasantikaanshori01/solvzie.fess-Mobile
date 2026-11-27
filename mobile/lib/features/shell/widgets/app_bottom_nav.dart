import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';

/// Shared floating capsule bottom navigation used by [MainShell] (and standalone [HomeScreen]).
class AppBottomNav extends StatelessWidget {
  final int selected;
  final int unreadCount;
  final void Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.selected,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.home_rounded, label: 'Beranda'),
      _NavItem(icon: Icons.link_rounded, label: 'Link'),
      _NavItem(icon: Icons.inbox_rounded, label: 'Inbox', badge: unreadCount),
      _NavItem(icon: Icons.person_rounded, label: 'Profil'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: SplashColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: SplashColors.magenta, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80541C68),
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          items.length,
          (i) => Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: _NavItemWidget(
                item: items[i],
                isSelected: i == selected,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final int badge;

  const _NavItem({
    required this.icon,
    required this.label,
    this.badge = 0,
  });
}

class _NavItemWidget extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;

  const _NavItemWidget({
    required this.item,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final Color fgColor =
        isSelected ? SplashColors.white : SplashColors.mutedLight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: isSelected
          ? BoxDecoration(
              gradient: const LinearGradient(
                colors: [SplashColors.purple, SplashColors.blue],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(999),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(item.icon, color: fgColor, size: 22),
              if (item.badge > 0)
                Positioned(
                  top: -3,
                  right: -6,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: SplashColors.pink,
                      shape: BoxShape.circle,
                      border: Border.all(color: SplashColors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: SplashTypography.fontFredoka,
              fontFamilyFallback: SplashTypography.fontFallbackSans,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }
}
