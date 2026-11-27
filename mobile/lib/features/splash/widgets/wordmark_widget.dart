import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';

/// WordmarkWidget — renders the "SOLVZIE / .FESS" logo on the laptop screen.
///
/// Design reference (Figma): uppercase, chunky Fredoka font, 3D extrusion,
/// mint-green body with darker depth layers, L and I in pink with selection box.
///
/// NOTE on negative spacing: Flutter forbids negative Container.margin.
/// Letter tightening is done via TextStyle.letterSpacing (applied in typography.dart)
/// and Transform.translate for per-letter horizontal shift when needed.
class WordmarkWidget extends StatelessWidget {
  final double scale;
  final bool isSmallHeight;

  /// 12 animation values (0.0→1.0):
  ///   indices 0-6  = S, O, L, V, Z, I, E  (SOLVZIE row)
  ///   index   7    = dot '.'
  ///   indices 8-11 = F, E, S, S            (FESS row)
  /// Pass null to show fully-visible static state.
  final List<double>? letterPopValues;

  const WordmarkWidget({
    super.key,
    this.scale = 1.0,
    this.isSmallHeight = false,
    this.letterPopValues,
  });

  @override
  Widget build(BuildContext context) {
    // Font sizes tuned to match Figma's clamp(62px,20.5vw,84px) / clamp(78px,24.5vw,102px)
    // at 390px design width with scale factor applied.
    final double solvzieFontSize = (isSmallHeight ? 60.0 : 76.0) * scale;
    final double fessFontSize    = (isSmallHeight ? 72.0 : 92.0) * scale;

    // Uppercase letters — matches Figma visual (Fredoka renders chunky in uppercase).
    const solvzieLetters = ['S', 'O', 'L', 'V', 'Z', 'I', 'E'];
    const fessLetters    = ['F', 'E', 'S', 'S'];

    return Transform.rotate(
      angle: -3.0 * math.pi / 180.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Row 1: "SOLVZIE" ───────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(solvzieLetters.length, (i) {
              final letter     = solvzieLetters[i];
              final isSelected = (i == 2 || i == 5); // L and I

              // Alternating micro-tilt to give playful wobble (Figma: ±4°)
              final double tiltAngle = (i % 2 == 1)
                  ? -4.0 * math.pi / 180.0
                  : 4.0 * math.pi / 180.0;
              // Alternating vertical offset (Figma: odd +3px, even -4px)
              final double yOffset = (i % 2 == 1) ? 3.0 * scale : -4.0 * scale;

              // Animation values
              final popVal             = letterPopValues != null ? letterPopValues![i] : 1.0;
              final double opacity     = popVal.clamp(0.0, 1.0);
              final double letterScale = 0.4 + 0.6 * popVal;
              final double letterY     = (1.0 - popVal) * 28.0 * scale;

              return Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: Offset(0, letterY),
                  child: Transform.scale(
                    scale: letterScale,
                    child: Transform.translate(
                      offset: Offset(0, yOffset),
                      child: Transform.rotate(
                        angle: tiltAngle,
                        child: _buildLetter(
                          letter: letter,
                          isSelected: isSelected,
                          fontSize: solvzieFontSize,
                          scale: scale,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          SizedBox(height: (isSmallHeight ? 2.0 : 6.0) * scale),

          // ── Row 2: ".FESS" ─────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dot '.' — index 7 (after all 7 SOLVZIE letters)
              () {
                final popVal         = letterPopValues != null ? letterPopValues![7] : 1.0;
                final double opacity = popVal.clamp(0.0, 1.0);
                final double dScale  = 0.4 + 0.6 * popVal;
                final double dotY    = (1.0 - popVal) * 28.0 * scale;

                return Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(0, dotY),
                    child: Transform.scale(
                      scale: dScale,
                      child: _Extrude3DText(
                        text: '.',
                        style: SplashTypography.wordmarkDot(fontSize: fessFontSize * 0.95),
                        depthColor: SplashColors.pinkDark,
                        deepColor: SplashColors.pinkDeep,
                        scale: scale,
                        extraRightPad: 2.0 * scale,
                      ),
                    ),
                  ),
                );
              }(),

              // Letters F, E, S, S — indices 8, 9, 10, 11
              ...List.generate(fessLetters.length, (i) {
                final letter      = fessLetters[i];
                final letterIndex = 8 + i;  // 8, 9, 10, 11
                final popVal      = letterPopValues != null ? letterPopValues![letterIndex] : 1.0;
                final double opacity     = popVal.clamp(0.0, 1.0);
                final double letterScale = 0.4 + 0.6 * popVal;
                final double letterY     = (1.0 - popVal) * 28.0 * scale;

                return Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(0, letterY),
                    child: Transform.scale(
                      scale: letterScale,
                      child: _Extrude3DText(
                        text: letter,
                        style: SplashTypography.wordmarkFess(fontSize: fessFontSize),
                        depthColor: SplashColors.mintDark,
                        deepColor: SplashColors.mintDeep,
                        scale: scale,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a single letter, applying 3D extrusion via stacked Text widgets.
  /// Selected letters (L, I) get a pink selection box + rotation handle (Figma detail).
  Widget _buildLetter({
    required String letter,
    required bool isSelected,
    required double fontSize,
    required double scale,
  }) {
    final TextStyle style = isSelected
        ? SplashTypography.wordmarkSolvzieSelected(fontSize: fontSize)
        : SplashTypography.wordmarkSolvzie(fontSize: fontSize);

    final depthColor = isSelected ? SplashColors.pinkDark  : SplashColors.mintDark;
    final deepColor  = isSelected ? SplashColors.pinkDeep  : SplashColors.mintDeep;

    final extruded = _Extrude3DText(
      text: letter,
      style: style,
      depthColor: depthColor,
      deepColor: deepColor,
      scale: scale,
    );

    if (!isSelected) return extruded;

    // ── Pink selection box + rotation handle (Figma detail) ──────────────
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Pink dashed-border selection box
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 4.0 * scale,
            vertical: 2.0 * scale,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: SplashColors.pink,
              width: 2.0 * scale,
            ),
            borderRadius: BorderRadius.circular(4.0 * scale),
          ),
          child: extruded,
        ),
        // Rotation handle circle at top-right
        Positioned(
          top: -13.0 * scale,
          right: -11.0 * scale,
          child: Container(
            width: 20.0 * scale,
            height: 20.0 * scale,
            decoration: BoxDecoration(
              color: SplashColors.purple,
              shape: BoxShape.circle,
              border: Border.all(
                color: SplashColors.white,
                width: 2.0 * scale,
              ),
              boxShadow: [
                BoxShadow(
                  color: SplashColors.ink.withValues(alpha: 0.35),
                  offset: Offset(0, 2.0 * scale),
                  blurRadius: 3.0 * scale,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '↻',
                style: TextStyle(
                  fontSize: 12.0 * scale,
                  fontWeight: FontWeight.w700,
                  color: SplashColors.white,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// _Extrude3DText — simulates the Figma 3D extrusion by stacking
/// multiple Text layers at increasing Y offsets with darker colours,
/// then placing the face (top) layer last.
///
/// This avoids using TextStyle.shadows for depth (which are blurry) and instead
/// produces crisp pixel-offset stacking — matching the Figma "chunky 3D" look.
class _Extrude3DText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color depthColor;  // mid-depth layer colour
  final Color deepColor;   // bottom layer colour
  final double scale;
  final double extraRightPad;

  const _Extrude3DText({
    required this.text,
    required this.style,
    required this.depthColor,
    required this.deepColor,
    required this.scale,
    this.extraRightPad = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    // Number of extrusion steps — more = deeper 3D look.
    // Each step shifts 2px further down-right to build up the chunky depth.
    const int steps = 6;
    final double stepSize = 2.0 * scale;

    return Padding(
      padding: EdgeInsets.only(right: extraRightPad),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Deep shadow layer (darkest, furthest)
          for (int s = steps; s >= 1; s--)
            Transform.translate(
              offset: Offset(
                (s * stepSize * 0.4),   // slight right offset for angled depth
                (s * stepSize),
              ),
              child: Text(
                text,
                style: style.copyWith(
                  color: s > steps ~/ 2 ? deepColor : depthColor,
                  shadows: null,  // no shadows on depth layers — crisp only
                ),
              ),
            ),
          // Face layer (front, full colour + ambient shadow)
          Text(
            text,
            style: style.copyWith(
              shadows: [
                // Subtle top highlight
                Shadow(
                  offset: Offset(0, -1.5 * scale),
                  blurRadius: 0,
                  color: style.color!.withValues(alpha: 0.6),
                ),
                // Drop shadow below the whole letter block
                Shadow(
                  offset: Offset(2.0 * scale, (steps + 2) * stepSize),
                  blurRadius: 10.0 * scale,
                  color: const Color(0xFF0A2535).withValues(alpha: 0.55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
