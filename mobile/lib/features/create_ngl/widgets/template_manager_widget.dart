import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'template_confirmation_modal.dart';

/// TemplateManager widget for managing user background templates (max 5)
/// and the default "Gradasi acak" template.
/// Matches Figma `.template-manager`, `.template-gallery`, and `.template-actions`.
class TemplateManagerWidget extends StatelessWidget {
  final List<String> images;
  final String selected;
  final ValueChanged<String> onSelect;
  final ValueChanged<List<String>> onImagesChanged;

  const TemplateManagerWidget({
    super.key,
    required this.images,
    required this.selected,
    required this.onSelect,
    required this.onImagesChanged,
  });

  Future<void> _pickImage(BuildContext context) async {
    if (images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Maksimal 5 template foto.'),
          backgroundColor: SplashColors.tealDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 88,
      );

      if (file != null) {
        final nextList = List<String>.from(images)..add(file.path);
        onImagesChanged(nextList);
        onSelect(file.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: const Color(0xFFB42318),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context) async {
    final bool isUserImage = selected != 'gradient' && images.contains(selected);
    if (!isUserImage) return;

    final confirmed = await TemplateModalDialog.showConfirmation(
      context: context,
      title: 'Hapus foto ini dari template?',
      body:
          'Foto akan dihapus dari daftar Template saya. Pilihan kembali ke Gradasi acak, dan NGL lain tidak berubah.',
      confirmLabel: 'Hapus',
      cancelLabel: 'Batal',
      isDanger: true,
    );

    if (confirmed == true) {
      final nextList = List<String>.from(images)..remove(selected);
      onImagesChanged(nextList);
      onSelect('gradient');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canDelete = selected != 'gradient' && images.contains(selected);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header: "Template saya" [0/5] ... "Foto polos tanpa teks" ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Template saya',
                  style: TextStyle(
                    fontFamily: SplashTypography.fontFredoka,
                    fontFamilyFallback: SplashTypography.fontFallbackSans,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: SplashColors.ink,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7EDFF),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${images.length}/5',
                    style: TextStyle(
                      fontFamily: SplashTypography.fontSpaceMono,
                      fontFamilyFallback: SplashTypography.fontFallbackMono,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF7139AC),
                    ),
                  ),
                ),
              ],
            ),
            Flexible(
              child: Text(
                'Foto polos tanpa teks',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: SplashTypography.fontFredoka,
                  fontFamilyFallback: SplashTypography.fontFallbackSans,
                  fontSize: 10,
                  color: SplashColors.ink.withValues(alpha: 0.55),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ── Horizontal Gallery (76×104px tiles) ──
        SizedBox(
          height: 106,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              // 1. [+ Add image] dashed card
              _AddImageTile(
                disabled: images.length >= 5,
                onTap: () => _pickImage(context),
              ),

              const SizedBox(width: 10),

              // 2. User uploaded images
              for (final imgPath in images) ...[
                _PhotoTile(
                  imagePath: imgPath,
                  isSelected: selected == imgPath,
                  onTap: () => onSelect(imgPath),
                ),
                const SizedBox(width: 10),
              ],

              // 3. Default "Gradasi acak" tile
              _GradientTile(
                isSelected: selected == 'gradient',
                onTap: () => onSelect('gradient'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Dual Action Buttons: [+ Add image] & [Delete image] ──
        Row(
          children: [
            // Add image button
            Expanded(
              child: GestureDetector(
                onTap: () => _pickImage(context),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9A3D), Color(0xFFFF6EC7)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFB55C1A),
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
                          const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            'Add image',
                            style: TextStyle(
                              fontFamily: SplashTypography.fontFredoka,
                              fontFamilyFallback: SplashTypography.fontFallbackSans,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Delete image button
            Expanded(
              child: GestureDetector(
                onTap: canDelete ? () => _confirmDelete(context) : null,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: canDelete ? Colors.white : const Color(0xFFF3F0FB),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: canDelete
                          ? const Color(0xFFB42318)
                          : const Color(0xFF767694),
                      width: 2,
                    ),
                    boxShadow: canDelete
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
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            color: canDelete
                                ? const Color(0xFFB42318)
                                : const Color(0xFF767694),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Delete image',
                            style: TextStyle(
                              fontFamily: SplashTypography.fontFredoka,
                              fontFamilyFallback: SplashTypography.fontFallbackSans,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: canDelete
                                  ? const Color(0xFFB42318)
                                  : const Color(0xFF767694),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Tiles
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _AddImageTile extends StatelessWidget {
  final bool disabled;
  final VoidCallback onTap;

  const _AddImageTile({required this.disabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        width: 76,
        height: 104,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F2FB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD8C9DF),
            width: 2,
            strokeAlign: BorderSide.strokeAlignCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFFD946EF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 7),
            Text(
              'Add image',
              style: TextStyle(
                fontFamily: SplashTypography.fontFredoka,
                fontFamilyFallback: SplashTypography.fontFallbackSans,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF8439C5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _PhotoTile({
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        height: 104,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? SplashColors.magenta : const Color(0xFFD8C9DF),
            width: isSelected ? 3.0 : 2.0,
          ),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Color(0x60D946EF),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image, size: 24, color: Colors.grey),
              ),
            ),

            // Checkmark in top-right corner if selected
            if (isSelected)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: SplashColors.magenta,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GradientTile extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _GradientTile({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        height: 104,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6EC7), Color(0xFFFF9A3D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isSelected ? SplashColors.magenta : const Color(0xFFD8C9DF),
            width: isSelected ? 3.0 : 2.0,
          ),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Color(0x60D946EF),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Radial light highlight
            Positioned(
              left: -15,
              top: -15,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Checkmark in top-right corner if selected
            if (isSelected)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: SplashColors.magenta,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),

            // Bottom label
            Positioned(
              left: 6,
              right: 6,
              bottom: 8,
              child: Text(
                'Gradasi acak',
                style: TextStyle(
                  fontFamily: SplashTypography.fontFredoka,
                  fontFamilyFallback: SplashTypography.fontFallbackSans,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.1,
                  shadows: const [
                    Shadow(
                      color: Color(0x60000000),
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
