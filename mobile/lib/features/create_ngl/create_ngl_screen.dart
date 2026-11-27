import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/core/models/models.dart';
import 'package:mobile/features/splash/widgets/fish_painter.dart';
import 'widgets/back_header.dart';
import 'widgets/template_confirmation_modal.dart';
import 'widgets/template_manager_widget.dart';
import 'preview_ngl_screen.dart';
import 'theme_editor_screen.dart';

/// CreateNglScreen — allows the user to name their NGL, customize the link,
/// and choose/upload background templates (max 5).
/// Matches Figma CreateScreen (Screenshot 1 & 4).
class CreateNglScreen extends StatefulWidget {
  final String username;
  final List<String>? initialImages;

  const CreateNglScreen({
    super.key,
    required this.username,
    this.initialImages,
  });

  @override
  State<CreateNglScreen> createState() => _CreateNglScreenState();
}

class _CreateNglScreenState extends State<CreateNglScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _slugController = TextEditingController();

  List<String> _images = [];
  String _selectedTemplate = 'gradient';
  String _activeTheme = 'sunset';
  String _position = 'middle';

  // Link state
  String _linkState = 'empty'; // 'empty', 'checking', 'available', 'taken', 'invalid'
  Timer? _debounceTimer;
  bool _manuallyEditedSlug = false;

  static const List<String> _takenSlugs = ['kelas12', 'angkatan', 'solvzie'];

  @override
  void initState() {
    super.initState();
    if (widget.initialImages != null) {
      _images = List.from(widget.initialImages!);
    }
    _nameController.addListener(_onNameChanged);
    _slugController.addListener(_onSlugChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nameController.removeListener(_onNameChanged);
    _slugController.removeListener(_onSlugChanged);
    _nameController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    if (!_manuallyEditedSlug) {
      final slug = _slugify(_nameController.text);
      _slugController.value = TextEditingValue(
        text: slug,
        selection: TextSelection.collapsed(offset: slug.length),
      );
    }
  }

  void _onSlugChanged() {
    final slug = _slugController.text.trim().toLowerCase();
    _debounceTimer?.cancel();

    if (slug.isEmpty) {
      setState(() => _linkState = 'empty');
      return;
    }

    final formatValid = RegExp(r'^[a-z0-9._-]{3,24}$').hasMatch(slug);
    if (!formatValid) {
      setState(() => _linkState = 'invalid');
      return;
    }

    setState(() => _linkState = 'checking');
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        if (_takenSlugs.contains(slug)) {
          _linkState = 'taken';
        } else {
          _linkState = 'available';
        }
      });
    });
  }

  String _slugify(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9\s-_]'), '')
        .replaceAll(RegExp(r'[\s_]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  void _onProceed() async {
    final name = _nameController.text.trim();
    final slug = _slugController.text.trim().toLowerCase();
    if (name.isEmpty || _linkState != 'available') return;

    // Navigate to Theme Editor Screen (Figma App.tsx:575 & Screenshot 5)
    final result = await Navigator.of(context).push<NglItem>(
      MaterialPageRoute(
        builder: (context) => ThemeEditorScreen(
          username: widget.username,
          name: name,
          slug: slug,
          initialSelectedTemplate: _selectedTemplate,
          initialImages: _images,
          initialTheme: _activeTheme,
          initialPosition: _position,
        ),
      ),
    );

    if (result != null && mounted) {
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double screenWidth = size.width;
    final double compositionWidth = screenWidth > 430.0 ? 430.0 : screenWidth;

    final name = _nameController.text.trim();
    final bool canProceed = name.isNotEmpty && _linkState == 'available';

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
                    painter: const _CreateGridPainter(),
                  ),
                ),

                // 2. Little fish deco (bottom-right)
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

                // 3. Foreground scrollable layout
                SafeArea(
                  child: Column(
                    children: [
                      // Header
                      BackHeader(
                        title: 'BUAT',
                        pill: 'NGL BARU',
                        onBack: () => Navigator.of(context).pop(),
                      ),

                      // Scrollable form card
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
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
                                    // ── 1. Nama NGL ──
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
                                          color: const Color(0xFFD8C9DF),
                                          width: 2.0,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 2,
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
                                          border: InputBorder.none,
                                          hintText: 'contoh: fess kelas 12',
                                          hintStyle: TextStyle(
                                            fontFamily: SplashTypography.fontFredoka,
                                            fontFamilyFallback:
                                                SplashTypography.fontFallbackSans,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: SplashColors.ink
                                                .withValues(alpha: 0.38),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // ── 2. Link NGL ──
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
                                    _buildLinkInputBox(),

                                    // Feedback line
                                    const SizedBox(height: 6),
                                    _buildLinkFeedback(),

                                    const SizedBox(height: 18),

                                    // ── 3. Template Saya ──
                                    TemplateManagerWidget(
                                      images: _images,
                                      selected: _selectedTemplate,
                                      onSelect: (val) {
                                        setState(() => _selectedTemplate = val);
                                      },
                                      onImagesChanged: (nextList) {
                                        setState(() => _images = nextList);
                                      },
                                    ),

                                    const SizedBox(height: 16),

                                    // ── 4. Tip Note Card ──
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF9C3),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: const Color(0xFFF59E0B),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Text(
                                            '✦',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFFD97706),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Satu NGL untuk semua: menfess + songfess.',
                                              style: TextStyle(
                                                fontFamily: SplashTypography.fontSpaceMono,
                                                fontFamilyFallback:
                                                    SplashTypography.fontFallbackMono,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: SplashColors.ink,
                                                height: 1.3,
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

                              // ── Primary Button: "Lanjut" ──
                              GestureDetector(
                                onTap: canProceed ? _onProceed : null,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
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
                                        : const Color(0xFF50788C).withValues(alpha: 0.45),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: canProceed
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.3),
                                      width: 2.5,
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
                                        fontFamily: SplashTypography.fontFredoka,
                                        fontFamilyFallback:
                                            SplashTypography.fontFallbackSans,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: canProceed
                                            ? Colors.white
                                            : Colors.white.withValues(alpha: 0.5),
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

  Widget _buildLinkInputBox() {
    Color borderColor = const Color(0xFFD8C9DF);
    List<BoxShadow>? shadows;

    if (_linkState == 'available') {
      borderColor = const Color(0xFF28B87C);
      shadows = [
        BoxShadow(
          color: const Color(0xFF5EEAA8).withValues(alpha: 0.28),
          blurRadius: 0,
          spreadRadius: 3,
        ),
      ];
    } else if (_linkState == 'taken' || _linkState == 'invalid') {
      borderColor = const Color(0xFFFF6EC7);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 2.0),
        boxShadow: shadows,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        children: [
          Text(
            'solvzie.fess/@',
            style: TextStyle(
              fontFamily: SplashTypography.fontSpaceMono,
              fontFamilyFallback: SplashTypography.fontFallbackMono,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF7139AC),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _slugController,
              onChanged: (_) {
                _manuallyEditedSlug = true;
              },
              maxLength: 24,
              style: TextStyle(
                fontFamily: SplashTypography.fontSpaceMono,
                fontFamilyFallback: SplashTypography.fontFallbackMono,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: SplashColors.ink,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                counterText: '',
                hintText: 'fess-kelas-12',
                hintStyle: TextStyle(
                  fontFamily: SplashTypography.fontSpaceMono,
                  fontFamilyFallback: SplashTypography.fontFallbackMono,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: SplashColors.ink.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkFeedback() {
    if (_linkState == 'empty') {
      return const SizedBox.shrink();
    }

    if (_linkState == 'checking') {
      return Row(
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2, color: SplashColors.mint),
          ),
          const SizedBox(width: 6),
          Text(
            'Mengecek link...',
            style: TextStyle(
              fontFamily: SplashTypography.fontFredoka,
              fontFamilyFallback: SplashTypography.fontFallbackSans,
              fontSize: 11,
              color: SplashColors.ink.withValues(alpha: 0.6),
            ),
          ),
        ],
      );
    }

    if (_linkState == 'available') {
      return Row(
        children: [
          const Icon(Icons.check, size: 15, color: Color(0xFF28B87C)),
          const SizedBox(width: 4),
          Text(
            'Link tersedia',
            style: TextStyle(
              fontFamily: SplashTypography.fontFredoka,
              fontFamilyFallback: SplashTypography.fontFallbackSans,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF28B87C),
            ),
          ),
        ],
      );
    }

    if (_linkState == 'taken') {
      final slug = _slugController.text.trim();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: [
              for (final suggestion in ['${slug}.12', '${slug}_fess'])
                GestureDetector(
                  onTap: () {
                    _slugController.text = suggestion;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7EDFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      suggestion,
                      style: TextStyle(
                        fontFamily: SplashTypography.fontSpaceMono,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF7139AC),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
    }

    return Text(
      'Gunakan 3–24 karakter: huruf kecil, angka, strip, titik, atau underscore.',
      style: TextStyle(
        fontFamily: SplashTypography.fontFredoka,
        fontFamilyFallback: SplashTypography.fontFallbackSans,
        fontSize: 10.5,
        color: const Color(0xFFFF6EC7),
      ),
    );
  }
}

class _CreateGridPainter extends CustomPainter {
  const _CreateGridPainter();

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
