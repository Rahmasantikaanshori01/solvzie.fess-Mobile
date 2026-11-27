import 'package:flutter/material.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/features/ngl_create/models/ngl_draft.dart';
import 'package:mobile/features/ngl_create/state/ngl_create_controller.dart';

class PositionSegmented extends StatelessWidget {
  final NglCreateController controller;

  const PositionSegmented({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final currentPos = controller.bubblePosition;

        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: const Color(0xFFD8C9DF),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              _PositionTab(
                label: 'Atas',
                isActive: currentPos == BubblePosition.atas,
                onTap: () => controller.setBubblePosition(BubblePosition.atas),
              ),
              _PositionTab(
                label: 'Tengah',
                isActive: currentPos == BubblePosition.tengah,
                onTap: () => controller.setBubblePosition(BubblePosition.tengah),
              ),
              _PositionTab(
                label: 'Bawah',
                isActive: currentPos == BubblePosition.bawah,
                onTap: () => controller.setBubblePosition(BubblePosition.bawah),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PositionTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _PositionTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFFA855F7), Color(0xFF60A5FA)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: SplashTypography.fontFredoka,
                fontFamilyFallback: SplashTypography.fontFallbackSans,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : const Color(0xFF6C6376),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
