import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'wordmark_widget.dart';

class LaptopWidget extends StatelessWidget {
  final double scale;
  final bool isSmallHeight;
  final List<double>? letterPopValues;
  final double? pillsLeftSlide;
  final double? pillsRightSlide;
  final double? starPopValue;
  final double screenFlashOpacity;

  const LaptopWidget({
    super.key,
    this.scale = 1.0,
    this.isSmallHeight = false,
    this.letterPopValues,
    this.pillsLeftSlide,
    this.pillsRightSlide,
    this.starPopValue,
    this.screenFlashOpacity = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    // In Figma: laptop-screen 210px (small 155px), keyboard 138px (small 96px)
    final double screenHeight = (isSmallHeight ? 155.0 : 210.0) * scale;
    final double keyboardHeight = (isSmallHeight ? 96.0 : 138.0) * scale;
    final double totalHeight = screenHeight + keyboardHeight - (5.0 * scale);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double laptopWidth = constraints.maxWidth;

        return SizedBox(
          width: laptopWidth,
          height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Laptop Screen
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: screenHeight,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        SplashColors.laptopScreenBg1,
                        SplashColors.laptopScreenBg2,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.0 * scale),
                      topRight: Radius.circular(24.0 * scale),
                      bottomLeft: Radius.circular(8.0 * scale),
                      bottomRight: Radius.circular(8.0 * scale),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: SplashColors.laptopBezel,
                        width: 12.0 * scale,
                      ),
                      left: BorderSide(
                        color: SplashColors.laptopBezel,
                        width: 12.0 * scale,
                      ),
                      right: BorderSide(
                        color: SplashColors.laptopBezel,
                        width: 12.0 * scale,
                      ),
                      bottom: BorderSide(
                        color: SplashColors.laptopBezel,
                        width: 17.0 * scale,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF141C46).withValues(alpha: 0.28),
                        offset: Offset(0, 20.0 * scale),
                        blurRadius: 30.0 * scale,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.0 * scale),
                      topRight: Radius.circular(12.0 * scale),
                    ),
                    child: Stack(
                      children: [
                        // Radial glow inside screen
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: const Alignment(-0.5, -0.7),
                                radius: 0.75,
                                colors: [
                                  SplashColors.mint.withValues(alpha: 0.20),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Screen flash overlay
                        if (screenFlashOpacity > 0.0)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Container(
                                color: screenFlashOpacity > 0.5
                                    ? const Color(0xFF08181F).withValues(
                                        alpha: screenFlashOpacity,
                                      )
                                    : Colors.white.withValues(
                                        alpha: screenFlashOpacity * 2.0,
                                      ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Keyboard (tapered perspective base)
              Positioned(
                top: screenHeight - (5.0 * scale),
                left: -laptopWidth * 0.08,
                right: -laptopWidth * 0.08,
                height: keyboardHeight,
                child: ClipPath(
                  clipper: _KeyboardClipper(),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF8DD3E6),
                          Color(0xFF5B9FC0),
                          Color(0xFF5776AE),
                        ],
                        stops: [0.0, 0.7, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF151943).withValues(alpha: 0.42),
                          offset: Offset(0, 18.0 * scale),
                          blurRadius: 24.0 * scale,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.only(
                      top: (isSmallHeight ? 14.0 : 22.0) * scale,
                      left: (isSmallHeight ? 24.0 : 38.0) * scale,
                      right: (isSmallHeight ? 24.0 : 38.0) * scale,
                      bottom: (isSmallHeight ? 32.0 : 54.0) * scale,
                    ),
                    child: Column(
                      children: [
                        // 6 Keyboard keys in a row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            6,
                            (index) => Container(
                              width: (isSmallHeight ? 28.0 : 36.0) * scale,
                              height: (isSmallHeight ? 7.0 : 10.0) * scale,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    SplashColors.keyboardKey1,
                                    SplashColors.keyboardKey2,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(3.0 * scale),
                                boxShadow: [
                                  BoxShadow(
                                    color: SplashColors.keyboardKeyShadow,
                                    offset: Offset(1.0 * scale, 2.0 * scale),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Trackpad
                        Container(
                          width: (laptopWidth * 1.16) * 0.42,
                          height: (isSmallHeight ? 24.0 : 36.0) * scale,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                SplashColors.trackpadBg1,
                                SplashColors.trackpadBg2,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8.0 * scale),
                            border: Border.all(
                              color: const Color(0xFF1B6B85).withValues(alpha: 0.24),
                              width: 2.0 * scale,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. 3D Wordmark overlay (sits over the screen, rotated -3deg)
              Positioned(
                top: (isSmallHeight ? 24.0 : 38.0) * scale,
                left: -laptopWidth * 0.04,
                right: -laptopWidth * 0.04,
                child: WordmarkWidget(
                  scale: scale,
                  isSmallHeight: isSmallHeight,
                  letterPopValues: letterPopValues,
                ),
              ),

              // 4. 2 Pills overlay (ANONYMOUS & MENFESS + SONGFESS)
              Positioned(
                bottom: (isSmallHeight ? 0.0 : 12.0) * scale,
                left: -laptopWidth * 0.04,
                right: -laptopWidth * 0.04,
                child: _buildPillsRow(scale: scale, isSmall: isSmallHeight),
              ),

              // 5. Selected Star with 4 corner selection handles
              Positioned(
                top: 2.0 * scale,
                right: -5.0 * scale,
                child: _buildSelectedStar(scale: scale),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPillsRow({required double scale, required bool isSmall}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Pill 1: ANONYMOUS
        _buildPill(
          label: 'ANONYMOUS',
          gradient: const LinearGradient(
            colors: [SplashColors.orange, SplashColors.pink],
          ),
          slideVal: pillsLeftSlide ?? 1.0,
          isLeft: true,
          scale: scale,
          isSmall: isSmall,
        ),
        // Pill 2: MENFESS + SONGFESS
        _buildPill(
          label: 'MENFESS + SONGFESS',
          gradient: const LinearGradient(
            colors: [SplashColors.purple, SplashColors.blue],
          ),
          slideVal: pillsRightSlide ?? 1.0,
          isLeft: false,
          scale: scale,
          isSmall: isSmall,
        ),
      ],
    );
  }

  Widget _buildPill({
    required String label,
    required Gradient gradient,
    required double slideVal,
    required bool isLeft,
    required double scale,
    required bool isSmall,
  }) {
    final double opacity = slideVal.clamp(0.0, 1.0);
    final double xOffset = isLeft
        ? (1.0 - slideVal) * -50.0 * scale
        : (1.0 - slideVal) * 50.0 * scale;
    final double rotateAngle = isLeft
        ? -8.0 * math.pi / 180.0
        : 5.0 * math.pi / 180.0;

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(xOffset, 0),
        child: Transform.rotate(
          angle: rotateAngle,
          child: Container(
            constraints: BoxConstraints(
              minHeight: (isSmall ? 36.0 : 44.0) * scale,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: (isSmall ? 10.0 : 16.0) * scale,
              vertical: (isSmall ? 4.0 : 6.0) * scale,
            ),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: SplashColors.white,
                width: 3.0 * scale,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF301B52).withValues(alpha: 0.38),
                  offset: Offset(0, 6.0 * scale),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                label,
                style: SplashTypography.pillText(
                  fontSize: (isSmall ? 11.0 : 15.0) * scale,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedStar({required double scale}) {
    final pop = starPopValue ?? 1.0;
    final starSize = 44.0 * scale;

    return Opacity(
      opacity: pop.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: 0.4 + 0.6 * pop,
        child: SizedBox(
          width: starSize + 10.0 * scale,
          height: starSize + 10.0 * scale,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Purple 4-point star '✦'
              Text(
                '✦',
                style: TextStyle(
                  fontSize: starSize,
                  color: SplashColors.purpleLight,
                  height: 1.0,
                  shadows: [
                    Shadow(
                      color: SplashColors.purpleDark,
                      offset: Offset(0, 5.0 * scale),
                      blurRadius: 0,
                    ),
                  ],
                ),
              ),
              // 4 Selection handle squares at corners
              ..._buildStarHandles(size: starSize, scale: scale),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStarHandles({required double size, required double scale}) {
    final handleSize = 6.0 * scale;
    final handleWidget = Container(
      width: handleSize,
      height: handleSize,
      decoration: BoxDecoration(
        color: SplashColors.pink,
        border: Border.all(color: SplashColors.white, width: 1.0 * scale),
      ),
    );

    return [
      Positioned(top: 0, left: 0, child: handleWidget),
      Positioned(top: 0, right: 0, child: handleWidget),
      Positioned(bottom: 0, left: 0, child: handleWidget),
      Positioned(bottom: 0, right: 0, child: handleWidget),
    ];
  }
}

class _KeyboardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // In Figma CSS: clip-path: polygon(7% 0, 93% 0, 100% 82%, 96% 100%, 4% 100%, 0 82%)
    final path = Path()
      ..moveTo(size.width * 0.07, 0)
      ..lineTo(size.width * 0.93, 0)
      ..lineTo(size.width, size.height * 0.82)
      ..lineTo(size.width * 0.96, size.height)
      ..lineTo(size.width * 0.04, size.height)
      ..lineTo(0, size.height * 0.82)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
