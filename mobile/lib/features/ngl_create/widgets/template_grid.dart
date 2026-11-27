import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/features/ngl_create/models/ngl_draft.dart';
import 'package:mobile/features/ngl_create/state/ngl_create_controller.dart';

class TemplateGrid extends StatelessWidget {
  final NglCreateController controller;

  const TemplateGrid({
    super.key,
    required this.controller,
  });

  Future<void> _handlePickImage(BuildContext context) async {
    if (controller.photos.length >= 5) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maksimal 5 foto'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final success = await controller.pickAndAddPhoto();
      if (!success) {
        // User membatalkan pemilihan -> tidak ada perubahan, tidak ada error
        return;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menambah foto, coba lagi'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteImage(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          decoration: BoxDecoration(
            color: SplashColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: SplashColors.danger,
              width: 2.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: SplashColors.cardShadow,
                offset: Offset(0, 8),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: SplashColors.dangerBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: SplashColors.danger, width: 2),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: SplashColors.danger,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Hapus foto ini dari template?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: SplashTypography.fontFredoka,
                  fontFamilyFallback: SplashTypography.fontFallbackSans,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: SplashColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Foto akan dihapus dari daftar Template saya. Pilihan kembali ke Gradasi acak, dan NGL lain tidak berubah.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: SplashTypography.fontInter,
                  fontFamilyFallback: SplashTypography.fontFallbackSans,
                  fontSize: 12.5,
                  color: SplashColors.ink.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: SplashColors.white,
                          foregroundColor: SplashColors.ink,
                          side: const BorderSide(
                            color: SplashColors.borderSoft,
                            width: 1.8,
                          ),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            fontFamily: SplashTypography.fontFredoka,
                            fontFamilyFallback:
                                SplashTypography.fontFallbackSans,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SplashColors.danger,
                          foregroundColor: SplashColors.white,
                          elevation: 0,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          'Hapus',
                          style: TextStyle(
                            fontFamily: SplashTypography.fontFredoka,
                            fontFamilyFallback:
                                SplashTypography.fontFallbackSans,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
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
    );

    if (confirmed == true && context.mounted) {
      controller.deleteCurrentPhoto();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final photos = controller.photos;
        final isPhotoSelected =
            controller.draftBackgroundType == BackgroundType.photo;
        final selectedPhotoIndex = controller.draftPhotoIndex;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: "Template saya" [n/5] ... "Foto polos tanpa teks" ──
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
                        '${photos.length}/5',
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
                    disabled: photos.length >= 5,
                    onTap: () => _handlePickImage(context),
                  ),

                  const SizedBox(width: 10),

                  // 2. User uploaded images
                  for (int i = 0; i < photos.length; i++) ...[
                    _PhotoTile(
                      bytes: photos[i].bytes,
                      isSelected: isPhotoSelected && selectedPhotoIndex == i,
                      onTap: () => controller.selectPhoto(i),
                    ),
                    const SizedBox(width: 10),
                  ],

                  // 3. Default "Gradasi acak" tile
                  _GradientTile(
                    isSelected: controller.draftBackgroundType == BackgroundType.gradient,
                    onTap: () => controller.selectGradient(),
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
                    onTap: () => _handlePickImage(context),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9A3D), Color(0xFFFF6EC7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
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
                                '+ Add image',
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
                    onTap: isPhotoSelected ? () => _handleDeleteImage(context) : null,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: isPhotoSelected ? Colors.white : const Color(0xFFF3F0FB),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isPhotoSelected
                              ? const Color(0xFFB42318)
                              : const Color(0xFF767694),
                          width: 2,
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
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                color: isPhotoSelected
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
                                  color: isPhotoSelected
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
      },
    );
  }
}

class _AddImageTile extends StatelessWidget {
  final bool disabled;
  final VoidCallback onTap;

  const _AddImageTile({
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        height: 104,
        decoration: BoxDecoration(
          color: disabled ? const Color(0xFFF3EEF9) : const Color(0xFFFBF8FD),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: disabled
                ? const Color(0xFFC7B8D6)
                : const Color(0xFFA855F7).withValues(alpha: 0.65),
            width: 1.8,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: disabled
                    ? const Color(0xFFB0A0C0)
                    : const Color(0xFFA855F7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add image',
              style: TextStyle(
                fontFamily: SplashTypography.fontFredoka,
                fontFamilyFallback: SplashTypography.fontFallbackSans,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: disabled
                    ? const Color(0xFF8B7B9B)
                    : const Color(0xFFA855F7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final dynamic bytes;
  final bool isSelected;
  final VoidCallback onTap;

  const _PhotoTile({
    required this.bytes,
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
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFA855F7) : Colors.transparent,
            width: isSelected ? 3.0 : 0.0,
          ),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Color(0x60A855F7),
                    offset: Offset(0, 4),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(
              bytes,
              fit: BoxFit.cover,
            ),
            if (isSelected)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFFA855F7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 13,
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
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6EC7), Color(0xFFFF9A3D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFA855F7) : Colors.transparent,
            width: isSelected ? 3.0 : 0.0,
          ),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Color(0x60A855F7),
                    offset: Offset(0, 4),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Radial glare overlay
            Positioned(
              top: -10,
              left: -10,
              child: Container(
                width: 50,
                height: 50,
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

            if (isSelected)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFFA855F7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
              ),

            // Bottom label
            Positioned(
              bottom: 8,
              left: 4,
              right: 4,
              child: Text(
                'Gradasi acak',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: SplashTypography.fontFredoka,
                  fontFamilyFallback: SplashTypography.fontFallbackSans,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
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
