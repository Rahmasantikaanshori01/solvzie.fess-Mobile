import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/features/ngl_create/models/ngl_draft.dart';

/// Reusable 9:16 (or custom size) thumbnail displaying ONLY the NGL's photo or gradient.
/// Never renders icons, bubbles, or text overlays on top.
class NglThumbnail extends StatelessWidget {
  final NglItem ngl;
  final double width;
  final double height;
  final double borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final bool dimmed;

  const NglThumbnail({
    super.key,
    required this.ngl,
    this.width = 60,
    this.height = 106,
    this.borderRadius = 10,
    this.borderColor,
    this.borderWidth = 1.2,
    this.dimmed = false,
  });

  static List<Color> gradientColorsFor(GradientPreset preset) {
    switch (preset) {
      case GradientPreset.candySunset:
        return const [SplashColors.pink, SplashColors.orange];
      case GradientPreset.purplePop:
        return const [SplashColors.purple, SplashColors.blue];
      case GradientPreset.mintySky:
        return const [SplashColors.mint, SplashColors.blue];
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPhotoBytes =
        ngl.backgroundType == BackgroundType.photo && ngl.photoBytes != null;
    final gradColors = gradientColorsFor(ngl.gradientKey);

    Widget content;
    if (hasPhotoBytes) {
      content = Image.memory(
        ngl.photoBytes!,
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      );
    } else {
      content = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      );
    }

    if (dimmed) {
      content = Opacity(opacity: 0.6, child: content);
    }

    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? SplashColors.ink.withValues(alpha: 0.3),
          width: borderWidth,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          (borderRadius - borderWidth).clamp(0.0, borderRadius),
        ),
        child: content,
      ),
    );
  }
}
