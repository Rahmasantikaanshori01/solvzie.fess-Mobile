import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/features/ngl_create/models/ngl_draft.dart';
import 'package:mobile/features/ngl_create/state/ngl_create_controller.dart';

class ColorChoices extends StatelessWidget {
  final NglCreateController controller;

  const ColorChoices({
    super.key,
    required this.controller,
  });

  static const List<Map<String, dynamic>> _presets = [
    {
      'preset': GradientPreset.candySunset,
      'name': 'Candy sunset',
      'colors': [Color(0xFFFF6EC7), Color(0xFFFF9A3D)],
    },
    {
      'preset': GradientPreset.purplePop,
      'name': 'Purple pop',
      'colors': [Color(0xFFA855F7), Color(0xFF60A5FA)],
    },
    {
      'preset': GradientPreset.mintySky,
      'name': 'Minty sky',
      'colors': [Color(0xFF5EEAA8), Color(0xFF60A5FA)],
    },
  ];

  void _onSelectPreset(BuildContext context, GradientPreset preset) {
    final success = controller.setGradientPreset(preset);
    if (!success) {
      // Jika template terpilih adalah FOTO: tampilkan "Hanya untuk gradasi"
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hanya untuk gradasi'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final isPhoto =
            controller.draftBackgroundType == BackgroundType.photo;
        final selectedPreset = controller.gradientKey;

        return SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              for (final item in _presets) ...[
                _PresetButton(
                  name: item['name'] as String,
                  colors: item['colors'] as List<Color>,
                  isSelected: selectedPreset == item['preset'],
                  isDimmed: isPhoto,
                  onTap: () => _onSelectPreset(context, item['preset'] as GradientPreset),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String name;
  final List<Color> colors;
  final bool isSelected;
  final bool isDimmed;
  final VoidCallback onTap;

  const _PresetButton({
    required this.name,
    required this.colors,
    required this.isSelected,
    required this.isDimmed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isDimmed ? 0.55 : 1.0,
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected && !isDimmed
                  ? SplashColors.yellow
                  : const Color(0xFFD8C9DF),
              width: isSelected && !isDimmed ? 2.5 : 1.5,
            ),
            boxShadow: isSelected && !isDimmed
                ? const [
                    BoxShadow(
                      color: Color(0x50FFD25A),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                name,
                style: TextStyle(
                  fontFamily: SplashTypography.fontFredoka,
                  fontFamilyFallback: SplashTypography.fontFallbackSans,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: SplashColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
