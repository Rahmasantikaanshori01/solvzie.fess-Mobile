import 'package:flutter/material.dart';
import 'colors.dart';

/// Typography tokens for Solvzie.fess splash screen.
class SplashTypography {
  const SplashTypography._();

  // Font family name — must match the 'family:' key in pubspec.yaml fonts section.
  // Fredoka .ttf files are in mobile/assets/fonts/ and registered in pubspec.yaml.
  static const String fontFredoka = 'Fredoka';
  static const String fontLilitaOne = 'Lilita One';
  static const String fontInter = 'Inter';
  static const String fontSpaceMono = 'Space Mono';

  static const List<String> fontFallbackSans = ['sans-serif', 'Roboto', 'Arial'];
  static const List<String> fontFallbackDisplay = [fontFredoka, 'sans-serif', 'Roboto', 'Arial'];
  static const List<String> fontFallbackMono = ['monospace', 'Courier New'];

  // ── Wordmark styles ────────────────────────────────────────────────────────
  // The 3D extrusion effect is handled by _Extrude3DText in wordmark_widget.dart
  // (stacked crisp Text layers). TextStyle here provides only the face colour +
  // tight letter-spacing. No shadows here — they'd blur the crisp depth layers.
  //
  // Fredoka font metrics:
  // - Rounded, chunky display font — no extra letter-spacing adjustments needed beyond Figma value.
  // - Figma CSS: letter-spacing: -7px at ~84px font → approximately -8.3% of em.
  //   In Flutter logical px at 76px: -7.0 * (76/84) ≈ -6.3. We use -6.5 as a good fit.
  // - height: null lets Fredoka use its natural line-height (compact by design).

  static TextStyle wordmarkSolvzie({required double fontSize}) => TextStyle(
    fontFamily: fontFredoka,
    fontFamilyFallback: fontFallbackSans,
    fontSize: fontSize,
    // w700 = Bold. Fredoka-Bold.ttf is registered as weight 700.
    fontWeight: FontWeight.w700,
    // Tight letter spacing matching Figma CSS -7px scaled to Flutter logical pixels.
    letterSpacing: -6.5,
    // height: null — use Fredoka's natural compact line-height.
    color: SplashColors.mint,
  );

  static TextStyle wordmarkSolvzieSelected({required double fontSize}) => TextStyle(
    fontFamily: fontFredoka,
    fontFamilyFallback: fontFallbackSans,
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    letterSpacing: -6.5,
    // Pink face colour for the selected letters (L and I in Figma).
    color: SplashColors.pinkLetter,
  );

  static TextStyle wordmarkFess({required double fontSize}) => TextStyle(
    fontFamily: fontFredoka,
    fontFamilyFallback: fontFallbackSans,
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    letterSpacing: -6.5,
    color: SplashColors.mint,
  );

  static TextStyle wordmarkDot({required double fontSize}) => TextStyle(
    fontFamily: fontFredoka,
    fontFamilyFallback: fontFallbackSans,
    fontSize: fontSize,
    // Dot is bolder/heavier to look like a filled circle (Figma: pink accent dot).
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: SplashColors.pink,
  );

  // Pill badge text
  static TextStyle pillText({required double fontSize}) => TextStyle(
    fontFamily: fontFredoka,
    fontFamilyFallback: fontFallbackSans,
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    color: SplashColors.white,
    letterSpacing: 0.2,
  );

  // Bottom section text
  static TextStyle subtitle({required double fontSize}) => TextStyle(
    fontFamily: fontFredoka,
    fontFamilyFallback: fontFallbackSans,
    fontSize: fontSize,
    fontWeight: FontWeight.w600,
    color: SplashColors.white,
  );

  static TextStyle statusText({required double fontSize}) => TextStyle(
    fontFamily: fontFredoka,
    fontFamilyFallback: fontFallbackSans,
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    color: SplashColors.mint,
  );

  // Sticker text
  static TextStyle stickerStarText({required double fontSize}) => TextStyle(
    fontFamily: fontFredoka,
    fontFamilyFallback: fontFallbackSans,
    fontSize: fontSize,
    fontWeight: FontWeight.w800,
    color: SplashColors.white,
  );

  static TextStyle stickyNoteText({required double fontSize}) => TextStyle(
    fontFamily: fontSpaceMono,
    fontFamilyFallback: fontFallbackMono,
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    color: SplashColors.ink,
  );
}
