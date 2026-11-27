import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/features/ngl_create/models/ngl_draft.dart';
import 'package:mobile/features/ngl_create/screens/pratinjau_screen.dart';
import 'package:mobile/features/ngl_create/state/ngl_create_controller.dart';
import 'package:mobile/features/ngl_create/widgets/back_header.dart';
import 'package:mobile/features/ngl_create/widgets/color_choices.dart';
import 'package:mobile/features/ngl_create/widgets/konfirmasi_bottom_sheet.dart';
import 'package:mobile/features/ngl_create/widgets/phone_preview.dart';
import 'package:mobile/features/ngl_create/widgets/position_segmented.dart';
import 'package:mobile/features/ngl_create/widgets/template_grid.dart';
import 'package:mobile/features/splash/widgets/fish_painter.dart';

class TemaScreen extends StatefulWidget {
  final NglCreateController controller;

  const TemaScreen({
    super.key,
    required this.controller,
  });

  @override
  State<TemaScreen> createState() => _TemaScreenState();
}

class _TemaScreenState extends State<TemaScreen> {
  Future<void> _handleGantiGambar() async {
    // // TODO(design): perilaku saat gradasi
    if (widget.controller.draftBackgroundType != BackgroundType.photo) {
      return;
    }

    try {
      final success = await widget.controller.replaceCurrentPhoto();
      if (!success) {
        // user cancelled
        return;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengganti foto, coba lagi'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _handleSimpan() async {
    final ctrl = widget.controller;

    if (ctrl.draftBackgroundType == BackgroundType.photo) {
      // Tampilkan bottom sheet konfirmasi (Layar 3)
      final confirmed = await KonfirmasiBottomSheet.show(context);
      if (confirmed != true || !mounted) {
        // User menutup dialog atau tap di luar -> kembali tanpa menerapkan
        return;
      }
    } else {
      // // TODO(design): konfirmasi untuk gradasi
    }

    // Terapkan draft background ke preview aktif
    ctrl.applyDraftToPreview();

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PratinjauScreen(controller: ctrl),
      ),
    );
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
                // 1. Grid pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: const _TemaGridPainter(),
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

                // 3. Main layout
                SafeArea(
                  child: Column(
                    children: [
                      // Header: diberi padding khusus agar judul "TEMA" tidak tertutup
                      NglBackHeader(
                        title: 'TEMA',
                        pill: 'ATUR POSISI!',
                        onBack: () => Navigator.of(context).pop(),
                      ),

                      // Scrollable content
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ── Phone Mockup Preview ──
                              ListenableBuilder(
                                listenable: widget.controller,
                                builder: (context, _) {
                                  final ctrl = widget.controller;

                                  return PhonePreview(
                                    backgroundType: ctrl.draftBackgroundType,
                                    photo: ctrl.draftPhoto,
                                    gradientKey: ctrl.gradientKey,
                                    bubblePosition: ctrl.bubblePosition,
                                    child: _buildAreaPesanBox(ctrl),
                                  );
                                },
                              ),

                              const SizedBox(height: 16),

                              // ── Template Saya Section Card ──
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: SplashColors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: SplashColors.magenta,
                                    width: 2.5,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x60541C68),
                                      offset: Offset(0, 5),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: TemplateGrid(
                                  controller: widget.controller,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // ── Color Choices ──
                              ColorChoices(controller: widget.controller),

                              const SizedBox(height: 12),

                              // ── Position Segmented ──
                              PositionSegmented(controller: widget.controller),

                              const SizedBox(height: 12),

                              // ── Sticky Note Card ──
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF9C3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFF59E0B),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  'Template polos, tanpa teks from/to/song. Ukuran 1080×1920.',
                                  style: TextStyle(
                                    fontFamily: SplashTypography.fontSpaceMono,
                                    fontFamilyFallback:
                                        SplashTypography.fontFallbackMono,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF78350F),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // ── Dual Buttons: [Ganti gambar] & [Simpan] ──
                              ListenableBuilder(
                                listenable: widget.controller,
                                builder: (context, _) {
                                  final isPhotoSelected = widget.controller
                                          .draftBackgroundType ==
                                      BackgroundType.photo;

                                  return Row(
                                    children: [
                                      // Tombol Ganti Gambar
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: isPhotoSelected
                                              ? _handleGantiGambar
                                              : null,
                                          child: Opacity(
                                            opacity: isPhotoSelected ? 1.0 : 0.5,
                                            child: Container(
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                                border: Border.all(
                                                  color: const Color(0xFF4C2A75),
                                                  width: 2.0,
                                                ),
                                                boxShadow: isPhotoSelected
                                                    ? const [
                                                        BoxShadow(
                                                          color: Color(0x355A5A7A),
                                                          offset: Offset(0, 3.5),
                                                          blurRadius: 0,
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 8),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      const Icon(
                                                        Icons.image_outlined,
                                                        size: 18,
                                                        color: SplashColors.ink,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        'Ganti gambar',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              SplashTypography
                                                                  .fontFredoka,
                                                          fontFamilyFallback:
                                                              SplashTypography
                                                                  .fontFallbackSans,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color:
                                                              SplashColors.ink,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      // Tombol Simpan
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: _handleSimpan,
                                          child: Container(
                                            height: 48,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFFA855F7),
                                                  Color(0xFF60A5FA),
                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              )                                              ,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2.0,
                                              ),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Color(0xFF4C2A75),
                                                  offset: Offset(0, 3.5),
                                                  blurRadius: 0,
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                'Simpan',
                                                style: TextStyle(
                                                  fontFamily:
                                                      SplashTypography
                                                          .fontFredoka,
                                                  fontFamilyFallback:
                                                      SplashTypography
                                                          .fontFallbackSans,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
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

  Widget _buildAreaPesanBox(NglCreateController ctrl) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Kotak putus-putus Area Pesan
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(6, 12, 6, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: SplashColors.yellow,
              width: 2.0,
            ),
          ),
          child: _buildSampleMessageBubble(ctrl),
        ),

        // Tag "Area pesan" kuning di kiri atas
        Positioned(
          top: -10,
          left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
            decoration: BoxDecoration(
              color: SplashColors.yellow,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              'Area pesan',
              style: TextStyle(
                fontFamily: SplashTypography.fontFredoka,
                fontFamilyFallback: SplashTypography.fontFallbackSans,
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: SplashColors.ink,
                height: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSampleMessageBubble(NglCreateController ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header bubble: avatar + @username + kirimi aku pesan anonim
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
                        '@${ctrl.username}',
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

          // Message content area (Pink)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF9A8D4),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(
              'pesanmu akan tampil di sini...',
              style: TextStyle(
                fontFamily: SplashTypography.fontSpaceMono,
                fontFamilyFallback: SplashTypography.fontFallbackMono,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4C0519),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TemaGridPainter extends CustomPainter {
  const _TemaGridPainter();

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
