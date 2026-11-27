import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/features/ngl_create/state/ngl_create_controller.dart';
import 'package:mobile/features/ngl_create/widgets/back_header.dart';
import 'package:mobile/features/ngl_create/widgets/phone_preview.dart';
import 'package:mobile/features/shell/main_shell.dart';
import 'package:mobile/features/splash/widgets/fish_painter.dart';

class PratinjauScreen extends StatelessWidget {
  final NglCreateController controller;

  const PratinjauScreen({
    super.key,
    required this.controller,
  });

  Future<void> _handleSimpanNgl(BuildContext context) async {
    // Buat NglItem baru dengan ID unik (tidak menimpa yang lama)
    final newItem = controller.buildNglItem();
    // Simpan ke repository bersama di posisi paling atas (index 0)
    await controller.repository.addNgl(newItem);
    controller.markSaved();

    if (!context.mounted) return;

    // Tutup seluruh alur Buat NGL dan kembali ke MainShell (tab Link aktif)
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.popUntil(
        (route) => route.settings.name == MainShell.routeName || route.isFirst,
      );
    } else {
      navigator.pushReplacement(
        MaterialPageRoute(
          settings: const RouteSettings(name: MainShell.routeName),
          builder: (context) => MainShell(
            username: controller.username,
            repository: controller.repository,
            initialTab: 1,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double screenWidth = size.width;
    final double compositionWidth = screenWidth > 430.0 ? 430.0 : screenWidth;

    return Scaffold(
      backgroundColor: const Color(0xFF0E4659),
      body: Center(
        child: SizedBox(
          width: compositionWidth,
          height: size.height,
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              color: SplashColors.teal,
            ),
            child: Stack(
              children: [
                // 1. Grid Background
                Positioned.fill(
                  child: CustomPaint(
                    painter: const _PratinjauGridPainter(),
                  ),
                ),

                // 2. Deco fish
                Positioned(
                  bottom: 16,
                  right: 14,
                  child: Transform.rotate(
                    angle: 0.1,
                    child: const SizedBox(
                      width: 52,
                      height: 32,
                      child: CustomPaint(
                        painter: FishPainter(),
                      ),
                    ),
                  ),
                ),

                // 3. Foreground
                SafeArea(
                  child: Column(
                    children: [
                      // Header
                      NglBackHeader(
                        title: 'PRATINJAU',
                        pill: 'BUBBLE OTOMATIS',
                        onBack: () => Navigator.of(context).pop(),
                      ),

                      // Scrollable Preview Layout
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 6, 20, 26),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Phone Mockup (9:16)
                              PhonePreview(
                                backgroundType: controller.draftBackgroundType,
                                photo: controller.draftPhoto,
                                gradientKey: controller.gradientKey,
                                bubblePosition: controller.bubblePosition,
                                child: _buildFullMessageBubble(),
                              ),

                              const SizedBox(height: 18),

                              // Info Box ("Siap dipakai!")
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D5E63).withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: SplashColors.mint.withValues(alpha: 0.45),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Text(
                                      '✦',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: SplashColors.mint,
                                        height: 1.0,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Siap dipakai!',
                                            style: TextStyle(
                                              fontFamily: SplashTypography.fontFredoka,
                                              fontFamilyFallback:
                                                  SplashTypography.fontFallbackSans,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: SplashColors.mint,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Bubble akan otomatis menyesuaikan pesan.',
                                            style: TextStyle(
                                              fontFamily: SplashTypography.fontFredoka,
                                              fontFamilyFallback:
                                                  SplashTypography.fontFallbackSans,
                                              fontSize: 10.5,
                                              color: Colors.white.withValues(alpha: 0.85),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Tombol "Simpan NGL"
                              GestureDetector(
                                onTap: () => _handleSimpanNgl(context),
                                child: Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFA855F7),
                                        Color(0xFF60A5FA),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xFF4C2A75),
                                        offset: Offset(0, 4),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Simpan NGL',
                                      style: TextStyle(
                                        fontFamily: SplashTypography.fontFredoka,
                                        fontFamilyFallback:
                                            SplashTypography.fontFallbackSans,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullMessageBubble() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Bubble Header
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD4D0E3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 14, color: Colors.white),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '@${controller.username}',
                        style: TextStyle(
                          fontFamily: SplashTypography.fontFredoka,
                          fontFamilyFallback: SplashTypography.fontFallbackSans,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: SplashColors.ink,
                        ),
                      ),
                      Text(
                        'kirimi aku pesan anonim!',
                        style: TextStyle(
                          fontFamily: SplashTypography.fontFredoka,
                          fontFamilyFallback: SplashTypography.fontFallbackSans,
                          fontSize: 7.5,
                          color: SplashColors.ink.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Pink Message Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            color: const Color(0xFFF9A8D4),
            child: Text(
              'semangat ujiannya ya! kamu pasti bisa.',
              style: TextStyle(
                fontFamily: SplashTypography.fontSpaceMono,
                fontFamilyFallback: SplashTypography.fontFallbackMono,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4C0519),
              ),
            ),
          ),

          // 3. Purple Song Strip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF8B5CF6),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  '♫',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Anything You Want — Reality Club',
                    style: TextStyle(
                      fontFamily: SplashTypography.fontSpaceMono,
                      fontFamilyFallback: SplashTypography.fontFallbackMono,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PratinjauGridPainter extends CustomPainter {
  const _PratinjauGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const double gridSize = 22.0;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
