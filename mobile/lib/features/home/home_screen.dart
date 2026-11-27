import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/features/inbox/repository/message_repository.dart';
import 'package:mobile/features/links/widgets/ngl_thumbnail.dart';
import 'package:mobile/features/ngl_create/models/ngl_draft.dart';
import 'package:mobile/features/ngl_create/repository/ngl_repository.dart';
import 'package:mobile/features/ngl_create/screens/buat_ngl_screen.dart';
import 'package:mobile/features/ngl_create/services/image_picker_service.dart';
import 'package:mobile/features/ngl_create/state/ngl_create_controller.dart';
import 'package:mobile/features/shell/widgets/app_bottom_nav.dart';
import 'package:mobile/features/splash/widgets/fish_painter.dart';

/// HomeScreen for solvzie.fess.
///
/// Connected dynamically to [NglRepository] and [MessageRepository] so stats,
/// "Link kamu" (2 newest NGLs), and "Aktivitas terbaru" always reflect the shared source of truth.
class HomeScreen extends StatelessWidget {
  final String username;
  final NglRepository? repository;
  final MessageRepository? messageRepository;
  final VoidCallback? onCreateNgl;
  final VoidCallback? onOpenLinksTab;
  final VoidCallback? onOpenProfileTab;
  final ValueChanged<int>? onNavTap;
  final bool showBottomNav;

  const HomeScreen({
    super.key,
    required this.username,
    this.repository,
    this.messageRepository,
    this.onCreateNgl,
    this.onOpenLinksTab,
    this.onOpenProfileTab,
    this.onNavTap,
    this.showBottomNav = true,
  });

  NglRepository get _repo => repository ?? MockNglRepository.instance;

  MessageRepository get _msgRepo {
    if (messageRepository != null) return messageRepository!;
    final repo = _repo;
    if (repo is MockNglRepository) {
      return repo.defaultMessageRepository;
    }
    return MockMessageRepository.instance;
  }

  Future<void> _defaultCreateNgl(BuildContext context) async {
    final controller = NglCreateController(
      repository: _repo,
      imagePickerService: DefaultImagePickerService(),
      username: username,
    );

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => BuatNglScreen(controller: controller),
      ),
    );
    controller.dispose();
  }

  void _handleNavTap(BuildContext context, int index) {
    if (onNavTap != null) {
      onNavTap!(index);
      return;
    }
    if (index == 0) return;
    if (index == 1 && onOpenLinksTab != null) {
      onOpenLinksTab!();
      return;
    }
    final labels = ['Beranda', 'Link', 'Inbox', 'Profil'];
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SplashColors.tealDark,
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: SplashColors.mint, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Halaman ${labels[index]} belum tersedia.',
                style: TextStyle(
                  color: SplashColors.white,
                  fontFamily: SplashTypography.fontInter,
                  fontFamilyFallback: SplashTypography.fontFallbackSans,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double screenWidth = size.width;
    final double screenHeight = size.height;
    final double compositionWidth = screenWidth > 430.0 ? 430.0 : screenWidth;
    final bool isSmallHeight = screenHeight < 700;
    final repo = _repo;
    final msgRepo = _msgRepo;

    return Scaffold(
      backgroundColor: SplashColors.tealDeep,
      body: Center(
        child: SizedBox(
          width: compositionWidth,
          height: screenHeight,
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
            child: ListenableBuilder(
              listenable: Listenable.merge([repo, msgRepo]),
              builder: (context, _) {
                final ngls = repo.ngls;
                final activities = repo.activities;
                final messages = msgRepo.messages;
                final int activeNgls = repo.activeNglCount;
                final int totalMessages = msgRepo.inboxMessageCount;
                final int unreadMessages = msgRepo.unreadCount;

                return Stack(
                  children: [
                    // 1. Grid background
                    Positioned.fill(
                      child: CustomPaint(
                        painter: const _HomeGridPainter(),
                      ),
                    ),

                    // 2. Fish deco (bottom-right)
                    Positioned(
                      bottom: isSmallHeight ? 85 : 100,
                      right: -8,
                      child: Transform.rotate(
                        angle: 0.15,
                        child: const SizedBox(
                          width: 56,
                          height: 34,
                          child: CustomPaint(
                            painter: FishPainter(),
                          ),
                        ),
                      ),
                    ),

                    // 3. Main scrollable content
                    SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          // ── Header ──
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Flexible(child: _LogoCompact()),
                                _AvatarButton(
                                  username: username,
                                  onTap: onOpenProfileTab,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 4),

                          // ── Scrollable body ──
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding:
                                  const EdgeInsets.fromLTRB(20, 12, 20, 110),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Greeting
                                  _GreetingSection(username: username),
                                  const SizedBox(height: 14),

                                  // Stats card
                                  _StatsCard(
                                    activeNgls: activeNgls,
                                    totalMessages: totalMessages,
                                    unreadMessages: unreadMessages,
                                  ),
                                  const SizedBox(height: 20),

                                  // Link kamu section (2 newest NGLs)
                                  _SectionHeader(
                                    title: 'Link kamu',
                                    action: 'Lihat semua',
                                    onAction: onOpenLinksTab ??
                                        () => _handleNavTap(context, 1),
                                  ),
                                  const SizedBox(height: 10),

                                  if (ngls.isEmpty)
                                    const _EmptyLinksState()
                                  else
                                    ...ngls.take(2).map(
                                          (ngl) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10),
                                            child: _NglCard(
                                              ngl: ngl,
                                              onTap: onOpenLinksTab,
                                            ),
                                          ),
                                        ),

                                  const SizedBox(height: 14),

                                  // Buat NGL button
                                  _CreateNglButton(
                                    onTap: onCreateNgl ??
                                        () => _defaultCreateNgl(context),
                                  ),

                                  const SizedBox(height: 22),

                                  // Aktivitas terbaru
                                  const _SectionHeader(
                                    title: 'Aktivitas terbaru',
                                  ),
                                  const SizedBox(height: 10),

                                  if (activities.isEmpty &&
                                      messages.isEmpty &&
                                      ngls.isEmpty)
                                    const _EmptyActivityState()
                                  else
                                    Column(
                                      children: activities
                                          .take(3)
                                          .map(
                                            (a) => Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10),
                                              child: _ActivityCard(activity: a),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 4. Bottom Navigation (when rendered standalone)
                    if (showBottomNav)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                            child: AppBottomNav(
                              selected: 0,
                              unreadCount: unreadMessages,
                              onTap: (index) => _handleNavTap(context, index),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION: Logo Compact
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _LogoCompact extends StatelessWidget {
  const _LogoCompact();

  @override
  Widget build(BuildContext context) {
    const double scale = 0.82;
    const double baseFontSize = 15.0 * scale;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 22 * scale,
          height: 20 * scale,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 22 * scale,
                height: 17 * scale,
                decoration: BoxDecoration(
                  color: SplashColors.mint,
                  borderRadius: BorderRadius.circular(5 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: SplashColors.mintDeep.withValues(alpha: 0.6),
                      offset: Offset(0, 1.5 * scale),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 1.0 * scale),
                        width: 2.5 * scale,
                        height: 2.5 * scale,
                        decoration: const BoxDecoration(
                          color: SplashColors.ink,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 4 * scale,
                child: CustomPaint(
                  size: Size(4 * scale, 3 * scale),
                  painter: _BubbleTail(color: SplashColors.mint),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 5 * scale),
        Text(
          'solvzie',
          style: TextStyle(
            fontFamily: SplashTypography.fontFredoka,
            fontFamilyFallback: SplashTypography.fontFallbackSans,
            fontSize: baseFontSize,
            fontWeight: FontWeight.w700,
            color: SplashColors.white,
            letterSpacing: -0.4 * scale,
            height: 1.0,
          ),
        ),
        Text(
          '.',
          style: TextStyle(
            fontFamily: SplashTypography.fontFredoka,
            fontFamilyFallback: SplashTypography.fontFallbackSans,
            fontSize: baseFontSize * 1.3,
            fontWeight: FontWeight.w900,
            color: SplashColors.pink,
            letterSpacing: -0.4 * scale,
            height: 1.0,
          ),
        ),
        Text(
          'fess',
          style: TextStyle(
            fontFamily: SplashTypography.fontFredoka,
            fontFamilyFallback: SplashTypography.fontFallbackSans,
            fontSize: baseFontSize,
            fontWeight: FontWeight.w700,
            color: SplashColors.white,
            letterSpacing: -0.4 * scale,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

class _BubbleTail extends CustomPainter {
  final Color color;
  const _BubbleTail({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _BubbleTail old) => old.color != color;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION: Avatar Button
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _AvatarButton extends StatelessWidget {
  final String username;
  final VoidCallback? onTap;

  const _AvatarButton({required this.username, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String letter =
        username.isNotEmpty ? username[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: SplashColors.tealDark,
                content: Text(
                  'Halaman Profil belum tersedia.',
                  style: TextStyle(
                    fontFamily: SplashTypography.fontInter,
                    fontFamilyFallback: SplashTypography.fontFallbackSans,
                    color: SplashColors.white,
                    fontSize: 13,
                  ),
                ),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
              ),
            );
          },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: SplashColors.yellow,
          shape: BoxShape.circle,
          border: Border.all(color: SplashColors.white, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF9E6B1F),
              offset: Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              fontFamily: SplashTypography.fontFredoka,
              fontFamilyFallback: SplashTypography.fontFallbackSans,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: SplashColors.ink,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION: Greeting
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _GreetingSection extends StatelessWidget {
  final String username;
  const _GreetingSection({required this.username});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.rotate(
              angle: -0.017,
              child: Text(
                'HALO,',
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
            ),
            const SizedBox(height: 6),
            _UsernameBadge(username: username),
          ],
        ),
        Positioned(
          top: -4,
          right: 10,
          child: Transform.rotate(
            angle: 0.2,
            child: Text(
              '✦',
              style: TextStyle(
                fontSize: 20,
                color: SplashColors.yellow,
                shadows: [
                  Shadow(
                    color: SplashColors.yellowDark.withValues(alpha: 0.7),
                    offset: const Offset(0, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UsernameBadge extends StatelessWidget {
  final String username;
  const _UsernameBadge({required this.username});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.03,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [SplashColors.orange, SplashColors.pink],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: SplashColors.white, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: SplashColors.buttonOrangeShadow,
              offset: Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          '@${username.isNotEmpty ? username : 'kamu'}',
          style: TextStyle(
            fontFamily: SplashTypography.fontFredoka,
            fontFamilyFallback: SplashTypography.fontFallbackSans,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: SplashColors.white,
            height: 1.0,
            letterSpacing: -0.3,
            shadows: const [
              Shadow(
                color: SplashColors.buttonOrangeShadow,
                offset: Offset(0, 1),
                blurRadius: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION: Stats Card
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _StatsCard extends StatelessWidget {
  final int activeNgls;
  final int totalMessages;
  final int unreadMessages;

  const _StatsCard({
    required this.activeNgls,
    required this.totalMessages,
    required this.unreadMessages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: SplashColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SplashColors.magenta, width: 3),
        boxShadow: const [
          BoxShadow(
            color: SplashColors.cardShadow,
            offset: Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatCell(
                value: activeNgls,
                label: 'NGL aktif',
                hasDivider: true,
              ),
            ),
            Expanded(
              child: _StatCell(
                value: totalMessages,
                label: 'Pesan masuk',
                hasDivider: true,
              ),
            ),
            Expanded(
              child: _StatCell(
                value: unreadMessages,
                label: 'Belum dibaca',
                hasDivider: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final int value;
  final String label;
  final bool hasDivider;

  const _StatCell({
    required this.value,
    required this.label,
    required this.hasDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: hasDivider
          ? const BoxDecoration(
              border: Border(
                right: BorderSide(color: Color(0xFFD4A6E5), width: 1),
              ),
            )
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontFamily: SplashTypography.fontFredoka,
              fontFamilyFallback: SplashTypography.fontFallbackSans,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: SplashColors.purple,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: SplashTypography.fontFredoka,
              fontFamilyFallback: SplashTypography.fontFallbackSans,
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: SplashColors.ink.withValues(alpha: 0.65),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION: Section Header
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: SplashTypography.fontFredoka,
              fontFamilyFallback: SplashTypography.fontFallbackSans,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: SplashColors.white,
              letterSpacing: -0.2,
            ),
          ),
        ),
        if (action != null) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onAction,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                action!,
                style: TextStyle(
                  fontFamily: SplashTypography.fontFredoka,
                  fontFamilyFallback: SplashTypography.fontFallbackSans,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: SplashColors.mint,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION: NGL Card
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _NglCard extends StatelessWidget {
  final NglItem ngl;
  final VoidCallback? onTap;

  const _NglCard({required this.ngl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: SplashColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: SplashColors.magenta, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: SplashColors.cardShadow,
              offset: Offset(0, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail (photo or gradient, Web & Mobile safe via NglThumbnail)
            NglThumbnail(
              ngl: ngl,
              width: 46,
              height: 46,
              borderRadius: 12,
              borderWidth: 0,
            ),
            const SizedBox(width: 12),
            // Name + slug
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ngl.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: SplashTypography.fontFredoka,
                      fontFamilyFallback: SplashTypography.fontFallbackSans,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: SplashColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ngl.displayLink,
                    style: TextStyle(
                      fontFamily: SplashTypography.fontSpaceMono,
                      fontFamilyFallback: SplashTypography.fontFallbackMono,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: SplashColors.ink.withValues(alpha: 0.5),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _StatusBadge(active: ngl.active),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool active;
  const _StatusBadge({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active ? SplashColors.successBg : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: active ? SplashColors.success : SplashColors.mutedLight,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            active ? 'AKTIF' : 'NONAKTIF',
            style: TextStyle(
              fontFamily: SplashTypography.fontFredoka,
              fontFamilyFallback: SplashTypography.fontFallbackSans,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: active ? SplashColors.successDark : SplashColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION: Create NGL Button
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _CreateNglButton extends StatefulWidget {
  final VoidCallback? onTap;
  const _CreateNglButton({this.onTap});

  @override
  State<_CreateNglButton> createState() => _CreateNglButtonState();
}

class _CreateNglButtonState extends State<_CreateNglButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [SplashColors.purple, SplashColors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: SplashColors.white, width: 2.5),
          boxShadow: _pressed
              ? []
              : const [
                  BoxShadow(
                    color: SplashColors.buttonPurpleShadow,
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: SplashColors.white, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Buat NGL baru',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: SplashTypography.fontFredoka,
                  fontFamilyFallback: SplashTypography.fontFallbackSans,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: SplashColors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION: Activity Card
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _ActivityCard extends StatelessWidget {
  final NglActivityRecord activity;
  const _ActivityCard({required this.activity});

  IconData get _icon {
    switch (activity.kind) {
      case NglActivityKind.newMessage:
        return Icons.inbox_outlined;
      case NglActivityKind.linkShared:
        return Icons.share_outlined;
      case NglActivityKind.storyCreated:
        return Icons.auto_stories_outlined;
    }
  }

  List<Color> get _gradColors {
    switch (activity.kind) {
      case NglActivityKind.newMessage:
        return const [SplashColors.purple, Color(0xFF7C3AED)];
      case NglActivityKind.linkShared:
        return const [SplashColors.pink, SplashColors.orange];
      case NglActivityKind.storyCreated:
        return const [SplashColors.blue, Color(0xFF818CF8)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SplashColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SplashColors.magenta, width: 2),
        boxShadow: const [
          BoxShadow(
            color: SplashColors.cardShadow,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _gradColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, color: SplashColors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontFamily: SplashTypography.fontFredoka,
                    fontFamilyFallback: SplashTypography.fontFallbackSans,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: SplashColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.subtitle,
                  style: TextStyle(
                    fontFamily: SplashTypography.fontInter,
                    fontFamilyFallback: SplashTypography.fontFallbackSans,
                    fontSize: 11,
                    color: SplashColors.ink.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity.timeLabel,
            style: TextStyle(
              fontFamily: SplashTypography.fontFredoka,
              fontFamilyFallback: SplashTypography.fontFallbackSans,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: SplashColors.mint,
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION: Empty States
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _EmptyLinksState extends StatelessWidget {
  const _EmptyLinksState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: SplashColors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SplashColors.white.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          const Text('🔗', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            'Belum ada link',
            style: TextStyle(
              fontFamily: SplashTypography.fontFredoka,
              fontFamilyFallback: SplashTypography.fontFallbackSans,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: SplashColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Buat link NGL pertamamu!',
            style: TextStyle(
              fontFamily: SplashTypography.fontInter,
              fontFamilyFallback: SplashTypography.fontFallbackSans,
              fontSize: 12,
              color: SplashColors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyActivityState extends StatelessWidget {
  const _EmptyActivityState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: SplashColors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SplashColors.white.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          const Text('📭', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            'Belum ada aktivitas',
            style: TextStyle(
              fontFamily: SplashTypography.fontFredoka,
              fontFamilyFallback: SplashTypography.fontFallbackSans,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: SplashColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Aktivitas akan muncul di sini.',
            style: TextStyle(
              fontFamily: SplashTypography.fontInter,
              fontFamilyFallback: SplashTypography.fontFallbackSans,
              fontSize: 12,
              color: SplashColors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION: Grid Painter
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _HomeGridPainter extends CustomPainter {
  const _HomeGridPainter();

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
  bool shouldRepaint(covariant _HomeGridPainter oldDelegate) => false;
}
