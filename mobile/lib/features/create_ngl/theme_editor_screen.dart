import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/core/models/models.dart';
import 'widgets/back_header.dart';
import 'widgets/message_bubble_widget.dart';
import 'widgets/phone_preview_widget.dart';
import 'widgets/template_confirmation_modal.dart';
import 'widgets/template_manager_widget.dart';
import 'preview_ngl_screen.dart';

/// ThemeEditorScreen — allows the user to adjust the position ("Atas", "Tengah", "Bawah"),
/// change theme preset ("Candy sunset", "Purple pop", "Minty sky"), or manage background images.
/// Matches Figma ThemeScreen (Screenshot 5).
class ThemeEditorScreen extends StatefulWidget {
  final String username;
  final String name;
  final String slug;
  final String initialTheme;
  final String initialPosition;
  final String initialSelectedTemplate;
  final List<String> initialImages;

  const ThemeEditorScreen({
    super.key,
    required this.username,
    required this.name,
    required this.slug,
    this.initialTheme = 'sunset',
    this.initialPosition = 'middle',
    this.initialSelectedTemplate = 'gradient',
    this.initialImages = const [],
  });

  @override
  State<ThemeEditorScreen> createState() => _ThemeEditorScreenState();
}

class _ThemeEditorScreenState extends State<ThemeEditorScreen> {
  late String _theme;
  late String _position; // 'top', 'middle', 'bottom'
  late String _selectedTemplate;
  late List<String> _images;

  static const List<Map<String, dynamic>> _themePresets = [
    {
      'id': 'sunset',
      'name': 'Candy sunset',
      'colors': [Color(0xFFFF6EC7), Color(0xFFFF9A3D)],
    },
    {
      'id': 'violet',
      'name': 'Purple pop',
      'colors': [Color(0xFFA855F7), Color(0xFF60A5FA)],
    },
    {
      'id': 'aqua',
      'name': 'Minty sky',
      'colors': [Color(0xFF5EEAA8), Color(0xFF60A5FA)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _theme = widget.initialTheme;
    _position = widget.initialPosition;
    _selectedTemplate = widget.initialSelectedTemplate;
    _images = List.from(widget.initialImages);
  }

  Future<void> _pickNewImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 88,
      );

      if (file != null) {
        setState(() {
          if (!_images.contains(file.path)) {
            if (_images.length >= 5) {
              _images.removeLast();
            }
            _images.add(file.path);
          }
          _selectedTemplate = file.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  void _onSave() async {
    // Show confirmation modal for polos template (Figma App.tsx:655 & Screenshot 3)
    final confirmed = await TemplateModalDialog.showConfirmation(
      context: context,
      title: 'Template ini sudah polos tanpa teks?',
      body: 'Bubble pesan, nama, dan lagu akan ditambahkan otomatis.',
      confirmLabel: 'Sudah polos',
    );
    if (confirmed != true || !mounted) return;

    final result = await Navigator.of(context).push<NglItem>(
      MaterialPageRoute(
        builder: (context) => PreviewNglScreen(
          username: widget.username,
          name: widget.name,
          slug: widget.slug,
          theme: _theme,
          position: _position,
          selectedTemplate: _selectedTemplate,
          images: _images,
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
                // 1. Grid background
                Positioned.fill(
                  child: CustomPaint(
                    painter: const _ThemeGridPainter(),
                  ),
                ),

                // 2. Foreground scrollable layout
                SafeArea(
                  child: Column(
                    children: [
                      // Header
                      BackHeader(
                        title: 'TEMA',
                        pill: 'ATUR POSISI!',
                        onBack: () => Navigator.of(context).pop(),
                      ),

                      // Scrollable content
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ── Phone Preview Mockup with "Area pesan" ──
                              PhonePreviewWidget(
                                imagePath: _selectedTemplate != 'gradient'
                                    ? _selectedTemplate
                                    : null,
                                theme: _theme,
                                position: _position,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Dashed yellow Area pesan box
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
                                      child: MessageBubbleWidget(
                                        username: widget.username,
                                        message: 'pesanmu akan tampil di sini...',
                                      ),
                                    ),

                                    // Yellow Tag: "Area pesan"
                                    Positioned(
                                      top: -10,
                                      left: 14,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: SplashColors.yellow,
                                          borderRadius: BorderRadius.circular(99),
                                        ),
                                        child: Text(
                                          'Area pesan',
                                          style: TextStyle(
                                            fontFamily: SplashTypography.fontFredoka,
                                            fontFamilyFallback:
                                                SplashTypography.fontFallbackSans,
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w700,
                                            color: SplashColors.ink,
                                            height: 1.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // ── Template Manager Gallery ──
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
                                child: TemplateManagerWidget(
                                  images: _images,
                                  selected: _selectedTemplate,
                                  onSelect: (val) {
                                    setState(() => _selectedTemplate = val);
                                  },
                                  onImagesChanged: (nextList) {
                                    setState(() => _images = nextList);
                                  },
                                ),
                              ),

                              const SizedBox(height: 12),

                              // ── Theme Presets Strip ──
                              SizedBox(
                                height: 42,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  children: [
                                    for (final item in _themePresets) ...[
                                      _ThemePresetButton(
                                        name: item['name'] as String,
                                        colors: item['colors'] as List<Color>,
                                        isSelected: _theme == item['id'],
                                        onTap: () {
                                          setState(() => _theme = item['id'] as String);
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              // ── Position Tabs: [Atas] [Tengah] [Bawah] ──
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(
                                    color: const Color(0xFFD8C9DF),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _PositionTabButton(
                                      label: 'Atas',
                                      isActive: _position == 'top',
                                      onTap: () => setState(() => _position = 'top'),
                                    ),
                                    _PositionTabButton(
                                      label: 'Tengah',
                                      isActive: _position == 'middle',
                                      onTap: () => setState(() => _position = 'middle'),
                                    ),
                                    _PositionTabButton(
                                      label: 'Bawah',
                                      isActive: _position == 'bottom',
                                      onTap: () => setState(() => _position = 'bottom'),
                                    ),
                                  ],
                                ),
                              ),

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
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: SplashTypography.fontSpaceMono,
                                    fontFamilyFallback:
                                        SplashTypography.fontFallbackMono,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: SplashColors.ink,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // ── Dual Action Buttons: [Ganti gambar] & [Simpan] ──
                              Row(
                                children: [
                                  // Ganti gambar outline button
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _pickNewImage,
                                      child: Container(
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(
                                            color: SplashColors.magenta,
                                            width: 2.0,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x50541C68),
                                              offset: Offset(0, 3.5),
                                              blurRadius: 0,
                                            ),
                                          ],
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
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
                                                    fontFamily: SplashTypography.fontFredoka,
                                                    fontFamilyFallback:
                                                        SplashTypography.fontFallbackSans,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: SplashColors.ink,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // Simpan button
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _onSave,
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
                                          ),
                                          borderRadius: BorderRadius.circular(999),
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
                                              fontFamily: SplashTypography.fontFredoka,
                                              fontFamilyFallback:
                                                  SplashTypography.fontFallbackSans,
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

class _PositionTabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _PositionTabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFFA855F7), Color(0xFF60A5FA)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: SplashTypography.fontFredoka,
                fontFamilyFallback: SplashTypography.fontFallbackSans,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : const Color(0xFF6C6376),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemePresetButton extends StatelessWidget {
  final String name;
  final List<Color> colors;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemePresetButton({
    required this.name,
    required this.colors,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? SplashColors.yellow : const Color(0xFFD8C9DF),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
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
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                fontFamily: SplashTypography.fontFredoka,
                fontFamilyFallback: SplashTypography.fontFallbackSans,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: SplashColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeGridPainter extends CustomPainter {
  const _ThemeGridPainter();

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
