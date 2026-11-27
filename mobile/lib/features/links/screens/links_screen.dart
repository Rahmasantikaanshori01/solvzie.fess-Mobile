import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/features/inbox/repository/message_repository.dart';
import 'package:mobile/features/links/widgets/link_card.dart';
import 'package:mobile/features/ngl_create/repository/ngl_repository.dart';

/// Real Links management page ("LINK") connected to the shared [NglRepository] and [MessageRepository].
class LinksScreen extends StatelessWidget {
  final NglRepository repository;
  final MessageRepository? messageRepository;
  final VoidCallback onCreateNgl;
  final bool isLoading;

  const LinksScreen({
    super.key,
    required this.repository,
    this.messageRepository,
    required this.onCreateNgl,
    this.isLoading = false,
  });

  MessageRepository get _msgRepo {
    if (messageRepository != null) return messageRepository!;
    final repo = repository;
    if (repo is MockNglRepository) {
      return repo.defaultMessageRepository;
    }
    return MockMessageRepository.instance;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double screenWidth = size.width;
    final double compositionWidth = screenWidth > 430.0 ? 430.0 : screenWidth;

    return Container(
      color: SplashColors.tealDeep,
      child: Center(
        child: SizedBox(
          width: compositionWidth,
          height: size.height,
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: SplashColors.teal,
              boxShadow: screenWidth > 430.0
                  ? [
                      BoxShadow(
                        color: const Color(0xFF082D3D).withValues(alpha: 0.60),
                        blurRadius: 60,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: const _LinksGridPainter(),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: ListenableBuilder(
                    listenable: Listenable.merge([repository, _msgRepo]),
                    builder: (context, _) {
                      final items = repository.ngls;
                      final activeCount = repository.activeNglCount;
                      final msgRepo = _msgRepo;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Header row ──
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _Link3DTitle(),
                                        const SizedBox(width: 8),
                                        Transform.rotate(
                                          angle: -0.05,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  SplashColors.orange,
                                                  SplashColors.pink,
                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                              border: Border.all(
                                                color: SplashColors.white,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Text(
                                              '$activeCount AKTIF',
                                              style: TextStyle(
                                                fontFamily: SplashTypography
                                                    .fontFredoka,
                                                fontFamilyFallback:
                                                    SplashTypography
                                                        .fontFallbackSans,
                                                fontSize: 10.5,
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
                                ),
                                const SizedBox(width: 8),
                                _NewLinkButton(onTap: onCreateNgl),
                              ],
                            ),
                          ),

                          // Subtitle
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 2, 20, 14),
                            child: Text(
                              'Atur semua ruang anonim kamu di sini.',
                              style: TextStyle(
                                fontFamily: SplashTypography.fontInter,
                                fontFamilyFallback:
                                    SplashTypography.fontFallbackSans,
                                fontSize: 13,
                                color:
                                    SplashColors.white.withValues(alpha: 0.88),
                              ),
                            ),
                          ),

                          // Body
                          Expanded(
                            child: isLoading
                                ? _buildLoadingState()
                                : items.isEmpty
                                    ? _buildEmptyState()
                                    : ListView.separated(
                                        physics:
                                            const BouncingScrollPhysics(),
                                        padding: const EdgeInsets.fromLTRB(
                                          18,
                                          2,
                                          18,
                                          116,
                                        ),
                                        itemCount: items.length,
                                        separatorBuilder: (_, _) =>
                                            const SizedBox(height: 12),
                                        itemBuilder: (context, index) {
                                          final ngl = items[index];
                                          return LinkCard(
                                            key: ValueKey(ngl.id),
                                            ngl: ngl,
                                            messageCount:
                                                msgRepo.messageCountForNgl(ngl.id),
                                            newMessageCount:
                                                msgRepo.unreadCountForNgl(ngl.id),
                                            onToggleActive: () =>
                                                repository.toggleActive(ngl.id),
                                            onSoftDelete: () =>
                                                repository.softDelete(ngl.id),
                                          );
                                        },
                                      ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: SplashColors.mint),
          const SizedBox(height: 12),
          Text(
            'Sebentar, ya...',
            style: TextStyle(
              fontFamily: SplashTypography.fontFredoka,
              fontFamilyFallback: SplashTypography.fontFallbackSans,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: SplashColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          decoration: BoxDecoration(
            color: SplashColors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: SplashColors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.link_off_rounded,
                color: SplashColors.mint,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                'Belum ada link',
                style: TextStyle(
                  fontFamily: SplashTypography.fontFredoka,
                  fontFamilyFallback: SplashTypography.fontFallbackSans,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: SplashColors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Buat ruang anonim pertamamu untuk mulai menerima pesan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: SplashTypography.fontInter,
                  fontFamilyFallback: SplashTypography.fontFallbackSans,
                  fontSize: 12.5,
                  color: SplashColors.white.withValues(alpha: 0.78),
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: onCreateNgl,
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [SplashColors.purple, SplashColors.blue],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: SplashColors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: SplashColors.buttonPurpleShadow,
                        offset: Offset(0, 3.5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add,
                        color: SplashColors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Buat NGL baru',
                        style: TextStyle(
                          fontFamily: SplashTypography.fontFredoka,
                          fontFamilyFallback: SplashTypography.fontFallbackSans,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: SplashColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Link3DTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.017,
      child: Text(
        'LINK',
        style: TextStyle(
          fontFamily: SplashTypography.fontFredoka,
          fontFamilyFallback: SplashTypography.fontFallbackSans,
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: SplashColors.mint,
          height: 1.0,
          letterSpacing: -1.0,
          shadows: const [
            Shadow(
              color: SplashColors.mintDeep,
              offset: Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
      ),
    );
  }
}

class _NewLinkButton extends StatelessWidget {
  final VoidCallback onTap;

  const _NewLinkButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [SplashColors.orange, SplashColors.pink],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: SplashColors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: SplashColors.buttonOrangeShadow,
              offset: Offset(0, 3.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          '+ Baru',
          style: TextStyle(
            fontFamily: SplashTypography.fontFredoka,
            fontFamilyFallback: SplashTypography.fontFallbackSans,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: SplashColors.white,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}

class _LinksGridPainter extends CustomPainter {
  const _LinksGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const double cellSize = 22.0;
    final paint = Paint()
      ..color = SplashColors.tealDeep.withValues(alpha: 0.35)
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
  bool shouldRepaint(covariant _LinksGridPainter oldDelegate) => false;
}
