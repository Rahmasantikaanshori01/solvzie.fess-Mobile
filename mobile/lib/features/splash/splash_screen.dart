import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'widgets/desk_scene.dart';
import 'widgets/fish_progress_bar.dart';
import 'widgets/laptop_widget.dart';
import 'widgets/logo_compact.dart';
import 'widgets/stickers_widget.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const SplashScreen({
    super.key,
    required this.onFinished,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _swingController;

  Timer? _readyTimer;
  Timer? _doneTimer;

  bool _isReady = false;
  bool _finished = false;
  bool _initialized = false;

  // Animations driven by _mainController (5200ms total)
  late final Animation<double> _screenFlash;
  late final List<Animation<double>> _letterPops;
  late final Animation<double> _pillsLeftSlide;
  late final Animation<double> _pillsRightSlide;
  late final Animation<double> _starPop;
  late final Animation<double> _fishProgress;

  // Sticky note swing animation (-7deg to 4deg)
  late final Animation<double> _stickySwing;

  @override
  void initState() {
    super.initState();

    // 1. Swing controller (2.6s infinite alternate)
    _swingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _stickySwing = Tween<double>(
      begin: -2.0 * math.pi / 180.0,
      end: 9.0 * math.pi / 180.0,
    ).animate(
      CurvedAnimation(
        parent: _swingController,
        curve: Curves.easeInOut,
      ),
    );

    // 2. Main timeline controller (5200ms total)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    );

    // Screen flash: 50ms - 1000ms (0.0096 to 0.1923)
    _screenFlash = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 45.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.3),
        weight: 15.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 0.0),
        weight: 40.0,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0096, 0.1923, curve: Curves.easeOut),
      ),
    );

    // ── Letter pop animations ──────────────────────────────────────────────
    // 12 elements total (left → right, top row then bottom row):
    //   SOLVZIE = indices 0-6  (7 letters)
    //   .FESS   = indices 7-11 (dot + 4 letters)
    //
    // Figma Make video (00:11+): letters pop in one by one left-to-right,
    // starting around t=1000ms, staggered ~80ms apart.
    // Curve: cubic-bezier(0.2, 1.6, 0.5, 1) — overshoot spring pop.
    // Duration per letter: ~400ms.
    const letterPopCurve = Cubic(0.2, 1.6, 0.5, 1.0);
    _letterPops = List.generate(12, (i) {
      final double startMs = 1000.0 + (i * 80.0);
      final double endMs   = (startMs + 400.0).clamp(0.0, 5200.0);

      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _mainController,
          curve: Interval(
            startMs / 5200.0,
            endMs   / 5200.0,
            curve: letterPopCurve,
          ),
        ),
      );
    });

    // Pills slide in: 2100ms - 2500ms
    _pillsLeftSlide = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4038, 0.4808, curve: Curves.easeOutBack),
      ),
    );
    _pillsRightSlide = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4231, 0.5000, curve: Curves.easeOutBack),
      ),
    );

    // Selected star pop: 2350ms - 2750ms
    _starPop = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4519, 0.5288, curve: letterPopCurve),
      ),
    );

    // Fish progress linear: 2000ms to 4400ms (linear swim and water fill)
    _fishProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3846, 0.8462, curve: Curves.linear),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;

      // Always play our own Flutter animations regardless of system animation
      // scale setting. Many Xiaomi/Redmi/MIUI devices report
      // disableAnimations=true (system animation scale 0x or accessibility
      // "Remove animations") which would skip the entire splash sequence.
      // Our splash is a core UX experience, not a system transition, so we
      // drive it ourselves.
      _startAnimations();
    }
  }

  void _startAnimations() {
    _swingController.repeat(reverse: true);
    _mainController.forward();

    // Status becomes "Siap!" at 4.4 seconds
    _readyTimer = Timer(const Duration(milliseconds: 4400), () {
      if (mounted) {
        setState(() {
          _isReady = true;
        });
      }
    });

    // onFinished called at 5.2 seconds
    _doneTimer = Timer(const Duration(milliseconds: 5200), () {
      _finishOnce();
    });
  }

  void _finishOnce() {
    if (!_finished && mounted) {
      _finished = true;
      widget.onFinished();
    }
  }

  @override
  void dispose() {
    _readyTimer?.cancel();
    _doneTimer?.cancel();
    _mainController.dispose();
    _swingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    // Tablet/desktop responsive design:
    // When width > 430px (tablet/desktop), cap composition width at 430px and center it,
    // keeping the portrait phone aspect ratio intact without stretching into landscape.
    final double compositionWidth = screenWidth > 430.0 ? 430.0 : screenWidth;
    final bool isSmallHeight = screenHeight < 700;

    // Responsive scale based on 390px design width, safely clamped
    final double scale = (compositionWidth / 390.0).clamp(0.80, 1.10);
    // Laptop width: 74% on small height, 88% on normal height
    final double laptopWidth = compositionWidth * (isSmallHeight ? 0.74 : 0.88);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0E4659), // outer background matching tablet viewport
        body: Center(
          child: SizedBox(
            width: compositionWidth,
            height: screenHeight,
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment(-0.8, -0.9),
                  end: Alignment(0.8, 0.9),
                  colors: [
                    SplashColors.tealGradientStart,
                    SplashColors.teal,
                    SplashColors.purpleGradientEnd,
                  ],
                  stops: [0.0, 0.52, 1.0],
                ),
                boxShadow: screenWidth > 430.0
                    ? [
                        BoxShadow(
                          color: const Color(0xFF082D3D).withValues(alpha: 0.60),
                          blurRadius: 50,
                          spreadRadius: 5,
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Desk background (table grid, hanging rope, sticky notes, cup)
                  ExcludeSemantics(
                    child: AnimatedBuilder(
                      animation: _swingController,
                      builder: (context, child) {
                        return DeskScene(
                          scale: scale,
                          isSmallHeight: isSmallHeight,
                          swingAngle: _stickySwing.value,
                        );
                      },
                    ),
                  ),

                  // 2. Desk stickers (desk fish and '2026' burst)
                  ExcludeSemantics(
                    child: StickersWidget(
                      scale: scale,
                      isSmallHeight: isSmallHeight,
                    ),
                  ),

                  // 3. Foreground content: Laptop & Bottom section in a responsive Column
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Top spacing (responsive margin-top)
                          SizedBox(
                            height: (isSmallHeight ? 24.0 : 48.0) * scale,
                          ),

                          // Laptop (screen, 3D wordmark, pills, star, keyboard, trackpad)
                          ExcludeSemantics(
                            child: RepaintBoundary(
                              child: AnimatedBuilder(
                                animation: _mainController,
                                builder: (context, child) {
                                  return SizedBox(
                                    width: laptopWidth,
                                    child: LaptopWidget(
                                      scale: scale,
                                      isSmallHeight: isSmallHeight,
                                      letterPopValues: _letterPops
                                          .map((a) => a.value)
                                          .toList(),
                                      pillsLeftSlide: _pillsLeftSlide.value,
                                      pillsRightSlide: _pillsRightSlide.value,
                                      starPopValue: _starPop.value,
                                      screenFlashOpacity: _screenFlash.value,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // Spacer absorbs all remaining vertical height dynamically
                          const Spacer(),

                          // Bottom section: LogoCompact, Tagline, FishProgressBar, Status
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Compact Logo
                              ExcludeSemantics(
                                child: LogoCompact(scale: scale),
                              ),
                              SizedBox(height: 6.0 * scale),

                              // Subtitle tagline
                              Text(
                                'kirim dan terima pesan anonim',
                                style: SplashTypography.subtitle(
                                  fontSize: (isSmallHeight ? 11.5 : 13.0) * scale,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: (isSmallHeight ? 8.0 : 12.0) * scale),

                              // Fish Progress Bar (linear swim from 2.0s to 4.4s)
                              ExcludeSemantics(
                                child: RepaintBoundary(
                                  child: AnimatedBuilder(
                                    animation: _mainController,
                                    builder: (context, child) {
                                      return FishProgressBar(
                                        scale: scale,
                                        progress: _fishProgress.value,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: (isSmallHeight ? 6.0 : 8.0) * scale),

                              // Status text ("Memuat..." -> "Siap!", live region)
                              Semantics(
                                liveRegion: true,
                                label: _isReady ? 'Siap!' : 'Memuat...',
                                child: Text(
                                  _isReady ? 'Siap!' : 'Memuat...',
                                  style: SplashTypography.statusText(
                                    fontSize: (isSmallHeight ? 11.0 : 12.0) * scale,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Bottom padding
                          SizedBox(height: (isSmallHeight ? 8.0 : 16.0) * scale),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
