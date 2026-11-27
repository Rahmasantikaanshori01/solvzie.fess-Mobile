import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/features/ngl_create/screens/tema_screen.dart';
import 'package:mobile/features/ngl_create/state/ngl_create_controller.dart';
import 'package:mobile/features/ngl_create/widgets/back_header.dart';
import 'package:mobile/features/ngl_create/widgets/template_grid.dart';
import 'package:mobile/features/splash/widgets/fish_painter.dart';

class BuatNglScreen extends StatefulWidget {
  final NglCreateController controller;

  const BuatNglScreen({
    super.key,
    required this.controller,
  });

  @override
  State<BuatNglScreen> createState() => _BuatNglScreenState();
}

class _BuatNglScreenState extends State<BuatNglScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _slugController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.controller.name);
    _slugController = TextEditingController(text: widget.controller.slug);

    _nameController.addListener(() {
      widget.controller.setName(_nameController.text);
      if (_slugController.text != widget.controller.slug) {
        _slugController.value = TextEditingValue(
          text: widget.controller.slug,
          selection: TextSelection.collapsed(offset: widget.controller.slug.length),
        );
      }
    });

    _slugController.addListener(() {
      if (_slugController.text != widget.controller.slug) {
        widget.controller.setSlug(_slugController.text);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  void _onLanjut() {
    if (!widget.controller.isCanProceed) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TemaScreen(
          controller: widget.controller,
        ),
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
                // 1. Grid Background
                Positioned.fill(
                  child: CustomPaint(
                    painter: const _BuatGridPainter(),
                  ),
                ),

                // 2. Fish Deco (bottom-right)
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

                // 3. Main Content
                SafeArea(
                  child: Column(
                    children: [
                      // Header
                      NglBackHeader(
                        title: 'BUAT',
                        pill: 'NGL BARU',
                        onBack: () => Navigator.of(context).maybePop(),
                      ),

                      // Form Body (Scrollable)
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ── Main Card ──
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: SplashColors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: SplashColors.magenta,
                                    width: 3.0,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x73541C68),
                                      offset: Offset(0, 6),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 1. Nama NGL
                                    Text(
                                      'Nama NGL',
                                      style: TextStyle(
                                        fontFamily: SplashTypography.fontFredoka,
                                        fontFamilyFallback:
                                            SplashTypography.fontFallbackSans,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: SplashColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: const Color(0xFFA855F7),
                                          width: 1.8,
                                        ),
                                      ),
                                      child: TextField(
                                        controller: _nameController,
                                        style: TextStyle(
                                          fontFamily: SplashTypography.fontFredoka,
                                          fontFamilyFallback:
                                              SplashTypography.fontFallbackSans,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: SplashColors.ink,
                                        ),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                          hintText: 'contoh: fess kelas 12',
                                          hintStyle: TextStyle(
                                            fontFamily:
                                                SplashTypography.fontFredoka,
                                            fontFamilyFallback:
                                                SplashTypography.fontFallbackSans,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: SplashColors.ink
                                                .withValues(alpha: 0.45),
                                          ),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    // 2. Link NGL
                                    Text(
                                      'Link NGL',
                                      style: TextStyle(
                                        fontFamily: SplashTypography.fontFredoka,
                                        fontFamilyFallback:
                                            SplashTypography.fontFallbackSans,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: SplashColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    ListenableBuilder(
                                      listenable: widget.controller,
                                      builder: (context, _) {
                                        return _buildLinkBox(widget.controller);
                                      },
                                    ),

                                    const SizedBox(height: 16),

                                    // 3. Template saya section
                                    TemplateGrid(controller: widget.controller),

                                    const SizedBox(height: 14),

                                    // 4. Strip kuning info
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF08A),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFFACC15),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Text(
                                            '✦',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF854D0E),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Satu NGL untuk semua: menfess + songfess.',
                                              style: TextStyle(
                                                fontFamily:
                                                    SplashTypography.fontSpaceMono,
                                                fontFamilyFallback:
                                                    SplashTypography.fontFallbackMono,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF713F12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 18),

                              // ── Tombol Lanjut ──
                              ListenableBuilder(
                                listenable: widget.controller,
                                builder: (context, _) {
                                  final canProceed = widget.controller.isCanProceed;

                                  return GestureDetector(
                                    onTap: canProceed ? _onLanjut : null,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      height: 52,
                                      decoration: BoxDecoration(
                                        gradient: canProceed
                                            ? const LinearGradient(
                                                colors: [
                                                  Color(0xFFA855F7),
                                                  Color(0xFF60A5FA),
                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              )
                                            : null,
                                        color: canProceed
                                            ? null
                                            : const Color(0xFF7B7293)
                                                .withValues(alpha: 0.65),
                                        borderRadius: BorderRadius.circular(999),
                                        border: Border.all(
                                          color: canProceed
                                              ? Colors.white
                                              : Colors.white
                                                  .withValues(alpha: 0.4),
                                          width: 2.0,
                                        ),
                                        boxShadow: canProceed
                                            ? const [
                                                BoxShadow(
                                                  color: Color(0xFF4C2A75),
                                                  offset: Offset(0, 4),
                                                  blurRadius: 0,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Lanjut',
                                          style: TextStyle(
                                            fontFamily:
                                                SplashTypography.fontFredoka,
                                            fontFamilyFallback:
                                                SplashTypography.fontFallbackSans,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: canProceed
                                                ? Colors.white
                                                : Colors.white
                                                    .withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ),
                                    ),
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

  Widget _buildLinkBox(NglCreateController ctrl) {
    Color borderColor = const Color(0xFFA855F7);
    if (ctrl.linkStatus == LinkStatus.available) {
      borderColor = const Color(0xFF28B87C);
    } else if (ctrl.linkStatus == LinkStatus.taken ||
        ctrl.linkStatus == LinkStatus.invalid) {
      borderColor = const Color(0xFFFF6EC7);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Text(
                'solvzie.fess/@',
                style: TextStyle(
                  fontFamily: SplashTypography.fontSpaceMono,
                  fontFamilyFallback: SplashTypography.fontFallbackMono,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: SplashColors.ink.withValues(alpha: 0.55),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _slugController,
                  style: TextStyle(
                    fontFamily: SplashTypography.fontSpaceMono,
                    fontFamilyFallback: SplashTypography.fontFallbackMono,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: SplashColors.ink,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'fess-kelas-12',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),

        // Status indicator
        if (ctrl.linkStatus == LinkStatus.available)
          Row(
            children: [
              const Icon(Icons.check, size: 15, color: Color(0xFF28B87C)),
              const SizedBox(width: 4),
              Text(
                '✓ Link tersedia',
                style: TextStyle(
                  fontFamily: SplashTypography.fontFredoka,
                  fontFamilyFallback: SplashTypography.fontFallbackSans,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF28B87C),
                ),
              ),
            ],
          )
        else if (ctrl.linkStatus == LinkStatus.taken)
          Row(
            children: [
              const Icon(Icons.close, size: 15, color: Color(0xFFFF6EC7)),
              const SizedBox(width: 4),
              Text(
                'Link sudah dipakai',
                style: TextStyle(
                  fontFamily: SplashTypography.fontFredoka,
                  fontFamilyFallback: SplashTypography.fontFallbackSans,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFF6EC7),
                ),
              ),
            ],
          )
        else if (ctrl.linkStatus == LinkStatus.invalid)
          Row(
            children: [
              const Icon(Icons.close, size: 15, color: Color(0xFFFF6EC7)),
              const SizedBox(width: 4),
              Text(
                'Format link tidak valid (3-24 karakter)',
                style: TextStyle(
                  fontFamily: SplashTypography.fontFredoka,
                  fontFamilyFallback: SplashTypography.fontFallbackSans,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFF6EC7),
                ),
              ),
            ],
          )
        else if (ctrl.linkStatus == LinkStatus.checking)
          Row(
            children: [
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFA855F7),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Mengecek ketersediaan...',
                style: TextStyle(
                  fontFamily: SplashTypography.fontFredoka,
                  fontFamilyFallback: SplashTypography.fontFallbackSans,
                  fontSize: 11,
                  color: SplashColors.ink.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _BuatGridPainter extends CustomPainter {
  const _BuatGridPainter();

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
