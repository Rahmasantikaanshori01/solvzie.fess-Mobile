import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/features/inbox/models/message_item.dart';
import 'package:mobile/features/inbox/repository/message_repository.dart';
import 'package:mobile/features/inbox/screens/arsip_screen.dart';
import 'package:mobile/features/inbox/screens/story_screen.dart';
import 'package:mobile/features/inbox/services/story_export_service.dart';
import 'package:mobile/features/inbox/utils/relative_time.dart';
import 'package:mobile/features/inbox/widgets/inbox_header.dart';
import 'package:mobile/features/ngl_create/repository/ngl_repository.dart';
import 'package:mobile/features/splash/widgets/fish_painter.dart';

/// Full-screen message detail ("PESAN") rendered above [MainShell] without bottom nav.
class PesanScreen extends StatefulWidget {
  final String messageId;
  final String username;
  final MessageRepository messageRepository;
  final NglRepository nglRepository;
  final StoryExportService? storyExportService;

  const PesanScreen({
    super.key,
    required this.messageId,
    required this.username,
    required this.messageRepository,
    required this.nglRepository,
    this.storyExportService,
  });

  @override
  State<PesanScreen> createState() => _PesanScreenState();
}

class _PesanScreenState extends State<PesanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.messageRepository.markRead(widget.messageId);
    });
  }

  void _showToast(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SplashColors.tealDark,
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: SplashColors.mint,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: SplashTypography.fontFredoka,
                  fontFamilyFallback: SplashTypography.fontFallbackSans,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: SplashColors.white,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      ),
    );
  }

  Future<void> _openStory() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => StoryScreen(
          messageId: widget.messageId,
          username: widget.username,
          messageRepository: widget.messageRepository,
          nglRepository: widget.nglRepository,
          storyExportService: widget.storyExportService,
        ),
      ),
    );
  }

  Future<void> _openArsip() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ArsipScreen(
          username: widget.username,
          messageRepository: widget.messageRepository,
          nglRepository: widget.nglRepository,
          storyExportService: widget.storyExportService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SplashColors.tealDeep,
      body: InboxGridBackground(
        child: Stack(
          children: [
            Positioned(
              bottom: 16,
              right: 14,
              child: Transform.rotate(
                angle: -0.08,
                child: const SizedBox(
                  width: 56,
                  height: 34,
                  child: CustomPaint(painter: FishPainter()),
                ),
              ),
            ),
            SafeArea(
              child: ListenableBuilder(
                listenable: widget.messageRepository,
                builder: (context, _) {
                  final MessageItem? message =
                      widget.messageRepository.getById(widget.messageId);

                  return Column(
                    children: [
                      InboxBackHeader(
                        title: 'PESAN',
                        pill: 'ANONIM',
                        onBack: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: message == null
                            ? Center(
                                child: Text(
                                  'Pesan tidak ditemukan.',
                                  style: TextStyle(
                                    fontFamily: SplashTypography.fontFredoka,
                                    fontFamilyFallback:
                                        SplashTypography.fontFallbackSans,
                                    fontSize: 15,
                                    color: SplashColors.white,
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding:
                                    const EdgeInsets.fromLTRB(20, 8, 20, 32),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // ── Info row: NGL pink pill + relative time ──
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: SplashColors.pink,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                              border: Border.all(
                                                color: SplashColors.white,
                                                width: 2.0,
                                              ),
                                            ),
                                            child: Text(
                                              message.nglName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily:
                                                    SplashTypography.fontFredoka,
                                                fontFamilyFallback:
                                                    SplashTypography
                                                        .fontFallbackSans,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: SplashColors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          formatRelativeTime(message.createdAt),
                                          style: TextStyle(
                                            fontFamily:
                                                SplashTypography.fontInter,
                                            fontFamilyFallback: SplashTypography
                                                .fontFallbackSans,
                                            fontSize: 12,
                                            color: SplashColors.white
                                                .withValues(alpha: 0.78),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    // ── Message Card ──
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        28,
                                        20,
                                        20,
                                      ),
                                      decoration: BoxDecoration(
                                        color: SplashColors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: SplashColors.magenta,
                                          width: 3.0,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: SplashColors.cardShadow,
                                            offset: Offset(0, 6),
                                            blurRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Positioned(
                                            top: -16,
                                            left: -6,
                                            child: Text(
                                              '“',
                                              style: TextStyle(
                                                fontFamily:
                                                    SplashTypography.fontFredoka,
                                                fontFamilyFallback:
                                                    SplashTypography
                                                        .fontFallbackSans,
                                                fontSize: 66,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    SplashColors.inboxQuotePink,
                                                height: 0.7,
                                              ),
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                  4,
                                                  12,
                                                  4,
                                                  6,
                                                ),
                                                child: Text(
                                                  message.text,
                                                  style: TextStyle(
                                                    fontFamily: SplashTypography
                                                        .fontSpaceMono,
                                                    fontFamilyFallback:
                                                        SplashTypography
                                                            .fontFallbackMono,
                                                    fontSize: 16.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: SplashColors.ink,
                                                    height: 1.65,
                                                  ),
                                                ),
                                              ),
                                              if (message.isSongfess &&
                                                  message.songDisplay !=
                                                      null) ...[
                                                const SizedBox(height: 14),
                                                _SongfessDetailCard(
                                                  songDisplay:
                                                      message.songDisplay!,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    // ── Anonymous strip ──
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 13,
                                        vertical: 11,
                                      ),
                                      decoration: BoxDecoration(
                                        color: SplashColors.white
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.auto_awesome_rounded,
                                            color: SplashColors.yellow,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Pengirim tetap anonim. Identitas mereka tidak disimpan.',
                                              style: TextStyle(
                                                fontFamily:
                                                    SplashTypography.fontInter,
                                                fontFamilyFallback:
                                                    SplashTypography
                                                        .fontFallbackSans,
                                                fontSize: 12,
                                                height: 1.4,
                                                color: SplashColors.white
                                                    .withValues(alpha: 0.92),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 18),

                                    // ── Primary CTA: Buat story ──
                                    _PesanPrimaryButton(
                                      label: 'Buat story',
                                      icon: Icons.auto_awesome_rounded,
                                      onTap: _openStory,
                                    ),

                                    const SizedBox(height: 10),

                                    // ── Archive / Unarchive secondary action ──
                                    if (!message.isArchived)
                                      _PesanOutlineButton(
                                        label: 'Arsipkan',
                                        icon: Icons.archive_outlined,
                                        onTap: () async {
                                          await widget.messageRepository
                                              .archive(message.id);
                                          if (!mounted) return;
                                          _showToast('Dipindahkan ke Arsip');
                                        },
                                      )
                                    else
                                      _PesanOutlineButton(
                                        label: 'Kembalikan ke Inbox',
                                        icon: Icons.inbox_rounded,
                                        onTap: () async {
                                          await widget.messageRepository
                                              .unarchive(message.id);
                                          if (!mounted) return;
                                          _showToast('Dikembalikan ke Inbox');
                                        },
                                      ),

                                    const SizedBox(height: 8),

                                    // ── Ghost button: Lihat arsip ──
                                    Center(
                                      child: TextButton.icon(
                                        onPressed: _openArsip,
                                        icon: const Icon(
                                          Icons.inventory_2_outlined,
                                          size: 18,
                                          color: SplashColors.white,
                                        ),
                                        label: Text(
                                          'Lihat arsip',
                                          style: TextStyle(
                                            fontFamily:
                                                SplashTypography.fontFredoka,
                                            fontFamilyFallback: SplashTypography
                                                .fontFallbackSans,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: SplashColors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
    );
  }
}

class _SongfessDetailCard extends StatelessWidget {
  final String songDisplay;

  const _SongfessDetailCard({required this.songDisplay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: SplashColors.inboxSongSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [SplashColors.purple, SplashColors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.music_note_rounded,
              color: SplashColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lagu buat kamu',
                  style: TextStyle(
                    fontFamily: SplashTypography.fontInter,
                    fontFamilyFallback: SplashTypography.fontFallbackSans,
                    fontSize: 11,
                    color: SplashColors.inboxMetaText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  songDisplay,
                  style: TextStyle(
                    fontFamily: SplashTypography.fontFredoka,
                    fontFamilyFallback: SplashTypography.fontFallbackSans,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: SplashColors.ink,
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

class _PesanPrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PesanPrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [SplashColors.purple, SplashColors.blue],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: SplashColors.white, width: 2.0),
          boxShadow: const [
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
            Icon(icon, color: SplashColors.white, size: 19),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: SplashTypography.fontFredoka,
                fontFamilyFallback: SplashTypography.fontFallbackSans,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: SplashColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PesanOutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PesanOutlineButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: SplashColors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: SplashColors.white.withValues(alpha: 0.85),
            width: 2.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: SplashColors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
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
    );
  }
}
