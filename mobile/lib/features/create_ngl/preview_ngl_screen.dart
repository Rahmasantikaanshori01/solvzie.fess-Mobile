import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/core/models/models.dart';
import 'widgets/back_header.dart';
import 'widgets/message_bubble_widget.dart';
import 'widgets/phone_preview_widget.dart';

/// PreviewNglScreen — shows the final preview of the NGL link with auto-bubble and song bar.
/// Matches Figma PreviewScreen (Screenshot 2).
class PreviewNglScreen extends StatelessWidget {
  final String username;
  final String name;
  final String slug;
  final String theme;
  final String position;
  final String selectedTemplate;
  final List<String> images;

  const PreviewNglScreen({
    super.key,
    required this.username,
    required this.name,
    required this.slug,
    this.theme = 'sunset',
    this.position = 'middle',
    this.selectedTemplate = 'gradient',
    this.images = const [],
  });

  void _onSave(BuildContext context) {
    // Generate unique ID based on timestamp
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final newNgl = NglItem(
      id: id,
      name: name,
      slug: slug,
      active: true,
      theme: theme,
      position: position,
      imagePath: selectedTemplate != 'gradient' ? selectedTemplate : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SplashColors.tealDark,
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: SplashColors.mint),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Link NGL @$slug berhasil dibuat!',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );

    // Pop back returning the newly created NGL
    Navigator.of(context).pop(newNgl);
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
                // 1. Grid background pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: const _PreviewGridPainter(),
                  ),
                ),

                // 2. Foreground content
                SafeArea(
                  child: Column(
                    children: [
                      // Header
                      BackHeader(
                        title: 'PRATINJAU',
                        pill: 'BUBBLE OTOMATIS',
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
                              // ── Phone Preview Mockup with Message Bubble ──
                              PhonePreviewWidget(
                                imagePath: selectedTemplate != 'gradient'
                                    ? selectedTemplate
                                    : null,
                                theme: theme,
                                position: position,
                                child: MessageBubbleWidget(
                                  username: username,
                                  message: 'semangat ujiannya ya! kamu pasti bisa.',
                                  song: 'Anything You Want — Reality Club',
                                ),
                              ),

                              const SizedBox(height: 18),

                              // ── Preview Caption Card ──
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: SplashColors.mint.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: SplashColors.mint,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Text(
                                      '✦',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: SplashColors.mint,
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
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            'Bubble akan otomatis menyesuaikan pesan.',
                                            style: TextStyle(
                                              fontFamily: SplashTypography.fontFredoka,
                                              fontFamilyFallback:
                                                  SplashTypography.fontFallbackSans,
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white.withValues(alpha: 0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // ── Primary Action Button: "Simpan NGL" ──
                              GestureDetector(
                                onTap: () => _onSave(context),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                                    border: Border.all(color: Colors.white, width: 2.5),
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
                                        letterSpacing: -0.2,
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
}

class _PreviewGridPainter extends CustomPainter {
  const _PreviewGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const double cellSize = 22.0;
    final paint = Paint()
      ..color = const Color(0xFF0E4659).withValues(alpha: 0.35)
      ..strokeWidth = 0.75
      ..style = PaintingStyle.stroke;

    for (double x = 0; x <= size.width; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
