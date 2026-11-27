import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/features/ngl_create/models/ngl_draft.dart';
import 'package:mobile/features/ngl_create/services/image_picker_service.dart';

class PhonePreview extends StatelessWidget {
  final BackgroundType backgroundType;
  final PickedTemplateImage? photo;
  final GradientPreset gradientKey;
  final BubblePosition bubblePosition;
  final Widget child;
  final bool showLogo;

  const PhonePreview({
    super.key,
    required this.backgroundType,
    this.photo,
    required this.gradientKey,
    required this.bubblePosition,
    required this.child,
    this.showLogo = true,
  });

  List<Color> get _gradientColors {
    switch (gradientKey) {
      case GradientPreset.candySunset:
        return const [Color(0xFFFF6EC7), Color(0xFFFF9A3D)];
      case GradientPreset.purplePop:
        return const [Color(0xFFA855F7), Color(0xFF60A5FA)];
      case GradientPreset.mintySky:
        return const [Color(0xFF5EEAA8), Color(0xFF60A5FA)];
    }
  }

  Alignment get _alignment {
    switch (bubblePosition) {
      case BubblePosition.atas:
        return const Alignment(0, -0.60);
      case BubblePosition.tengah:
        return const Alignment(0, -0.05);
      case BubblePosition.bawah:
        return const Alignment(0, 0.50);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 196,
        height: 348, // 9:16 aspect ratio
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white, width: 4.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x60000000),
              offset: Offset(0, 10),
              blurRadius: 18,
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Background layer (Photo or Gradient)
            if (backgroundType == BackgroundType.photo && photo != null) ...[
              Image.memory(
                photo!.bytes,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              Container(
                color: Colors.black.withValues(alpha: 0.18),
              ),
            ] else ...[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              // Radial glare
              Positioned(
                top: -30,
                left: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.40),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],

            // 2. Decorative sparkles
            const Positioned(
              top: 24,
              right: 18,
              child: Text(
                '✦',
                style: TextStyle(
                  color: SplashColors.yellow,
                  fontSize: 16,
                  height: 1.0,
                ),
              ),
            ),
            const Positioned(
              bottom: 48,
              right: 18,
              child: Text(
                '•',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 18,
                  height: 1.0,
                ),
              ),
            ),

            // 3. Positioned Bubble Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Align(
                alignment: _alignment,
                child: child,
              ),
            ),

            // 4. Solvzie.fess compact footer logo
            if (showLogo)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: SplashColors.mint,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_bubble,
                          color: SplashColors.teal,
                          size: 9,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'solvzie.fess',
                        style: TextStyle(
                          fontFamily: SplashTypography.fontFredoka,
                          fontFamilyFallback: SplashTypography.fontFallbackSans,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              color: Color(0x80000000),
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
