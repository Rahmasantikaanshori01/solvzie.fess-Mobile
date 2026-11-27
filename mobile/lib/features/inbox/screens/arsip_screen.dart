import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/features/inbox/models/message_item.dart';
import 'package:mobile/features/inbox/repository/message_repository.dart';
import 'package:mobile/features/inbox/screens/pesan_screen.dart';
import 'package:mobile/features/inbox/services/story_export_service.dart';
import 'package:mobile/features/inbox/utils/relative_time.dart';
import 'package:mobile/features/inbox/widgets/inbox_empty_state.dart';
import 'package:mobile/features/inbox/widgets/inbox_header.dart';
import 'package:mobile/features/ngl_create/repository/ngl_repository.dart';

/// Standalone Archive screen ("ARSIP") pushed above [MainShell] without bottom nav.
class ArsipScreen extends StatelessWidget {
  final String username;
  final MessageRepository messageRepository;
  final NglRepository nglRepository;
  final StoryExportService? storyExportService;

  const ArsipScreen({
    super.key,
    required this.username,
    required this.messageRepository,
    required this.nglRepository,
    this.storyExportService,
  });

  void _showToast(BuildContext context, String message) {
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
            Text(
              message,
              style: TextStyle(
                fontFamily: SplashTypography.fontFredoka,
                fontFamilyFallback: SplashTypography.fontFallbackSans,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: SplashColors.white,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SplashColors.tealDeep,
      body: InboxGridBackground(
        child: SafeArea(
          child: ListenableBuilder(
            listenable: messageRepository,
            builder: (context, _) {
              final List<MessageItem> archived =
                  messageRepository.archivedMessages;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InboxBackHeader(
                    title: 'ARSIP',
                    pill: '${archived.length} PESAN',
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                    child: Text(
                      'Kenangan rahasiamu tersimpan rapi di sini.',
                      style: TextStyle(
                        fontFamily: SplashTypography.fontInter,
                        fontFamilyFallback: SplashTypography.fontFallbackSans,
                        fontSize: 13,
                        color: SplashColors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ),
                  Expanded(
                    child: archived.isEmpty
                        ? SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                            child: const InboxEmptyState(
                              title: 'Arsip masih kosong',
                              body:
                                  'Pesan yang sudah dipost bisa dipindahkan ke sini.',
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                            itemCount: archived.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = archived[index];
                              return _ArchiveCard(
                                key: ValueKey(item.id),
                                message: item,
                                onOpen: () {
                                  Navigator.of(context).push<void>(
                                    MaterialPageRoute(
                                      builder: (_) => PesanScreen(
                                        messageId: item.id,
                                        username: username,
                                        messageRepository: messageRepository,
                                        nglRepository: nglRepository,
                                        storyExportService: storyExportService,
                                      ),
                                    ),
                                  );
                                },
                                onRestore: () async {
                                  await messageRepository.unarchive(item.id);
                                  if (context.mounted) {
                                    _showToast(
                                      context,
                                      'Dikembalikan ke Inbox',
                                    );
                                  }
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ArchiveCard extends StatelessWidget {
  final MessageItem message;
  final VoidCallback onOpen;
  final VoidCallback onRestore;

  const _ArchiveCard({
    super.key,
    required this.message,
    required this.onOpen,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SplashColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: SplashColors.magenta, width: 3.0),
          boxShadow: const [
            BoxShadow(
              color: SplashColors.cardShadow,
              offset: Offset(0, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    message.nglName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: SplashTypography.fontFredoka,
                      fontFamilyFallback: SplashTypography.fontFallbackSans,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: SplashColors.inboxPurple,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatRelativeTime(message.createdAt),
                  style: TextStyle(
                    fontFamily: SplashTypography.fontFredoka,
                    fontFamilyFallback: SplashTypography.fontFallbackSans,
                    fontSize: 12,
                    color: SplashColors.inboxMetaText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SplashColors.lavenderMuted,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: SplashColors.purple,
                  width: 1.8,
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontFamily: SplashTypography.fontSpaceMono,
                  fontFamilyFallback: SplashTypography.fontFallbackMono,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: SplashColors.ink,
                  height: 1.5,
                ),
              ),
            ),
            if (message.isSongfess && message.songDisplay != null) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: SplashColors.inboxSongSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.music_note_rounded,
                      size: 15,
                      color: SplashColors.inboxPurple,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        message.songDisplay!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: SplashTypography.fontSpaceMono,
                          fontFamilyFallback: SplashTypography.fontFallbackMono,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: SplashColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onRestore,
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: SplashColors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: SplashColors.purple,
                    width: 2.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.inbox_rounded,
                      size: 17,
                      color: SplashColors.inboxPurple,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Kembalikan ke Inbox',
                      style: TextStyle(
                        fontFamily: SplashTypography.fontFredoka,
                        fontFamilyFallback: SplashTypography.fontFallbackSans,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: SplashColors.inboxPurple,
                      ),
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
