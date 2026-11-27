import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/features/inbox/models/message_item.dart';
import 'package:mobile/features/inbox/repository/message_repository.dart';
import 'package:mobile/features/inbox/screens/pesan_screen.dart';
import 'package:mobile/features/inbox/services/story_export_service.dart';
import 'package:mobile/features/inbox/widgets/inbox_empty_state.dart';
import 'package:mobile/features/inbox/widgets/inbox_header.dart';
import 'package:mobile/features/inbox/widgets/inbox_tab_bar.dart';
import 'package:mobile/features/inbox/widgets/message_row_card.dart';
import 'package:mobile/features/ngl_create/repository/ngl_repository.dart';
import 'package:mobile/features/splash/widgets/burst_painter.dart';
import 'package:mobile/features/splash/widgets/fish_painter.dart';

/// Main Inbox tab hosted inside [MainShell].
class InboxScreen extends StatefulWidget {
  final String username;
  final MessageRepository messageRepository;
  final NglRepository nglRepository;
  final StoryExportService? storyExportService;

  const InboxScreen({
    super.key,
    required this.username,
    required this.messageRepository,
    required this.nglRepository,
    this.storyExportService,
  });

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  InboxTab _selectedTab = InboxTab.semua;

  List<MessageItem> _messagesForTab(MessageRepository repo) {
    switch (_selectedTab) {
      case InboxTab.semua:
        return repo.allInboxMessages;
      case InboxTab.belumDibaca:
        return repo.unreadMessages;
      case InboxTab.arsip:
        return repo.archivedMessages;
    }
  }

  Future<void> _openPesan(MessageItem message) async {
    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(
        builder: (_) => PesanScreen(
          messageId: message.id,
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
    final repo = widget.messageRepository;

    return InboxGridBackground(
      child: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: repo,
          builder: (context, _) {
            final int unreadCount = repo.unreadCount;
            final List<MessageItem> items = _messagesForTab(repo);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header: INBOX + slanted N BARU badge ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Inbox3DTitle(text: 'INBOX', fontSize: 48),
                          if (unreadCount > 0) ...[
                            const SizedBox(width: 12),
                            InboxSlantedBadge(label: '$unreadCount BARU'),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // ── 3-tab segmented capsule ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: InboxTabBar(
                    selectedTab: _selectedTab,
                    onChanged: (tab) {
                      if (_selectedTab != tab) {
                        setState(() => _selectedTab = tab);
                      }
                    },
                  ),
                ),

                // ── Content body (loading / error / empty / list) ──
                Expanded(
                  child: repo.isLoading
                      ? _buildLoadingState()
                      : repo.errorMessage != null
                          ? _buildErrorState(repo)
                          : items.isEmpty
                              ? SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 14, 20, 116),
                                  child: const InboxEmptyState(),
                                )
                              : ListView.separated(
                                  physics: const BouncingScrollPhysics(),
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 14, 20, 116),
                                  itemCount: items.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final message = items[index];
                                    return MessageRowCard(
                                      key: ValueKey(message.id),
                                      message: message,
                                      onTap: () => _openPesan(message),
                                    );
                                  },
                                ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 96),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FishWidget(
              width: 64,
              height: 38,
              fillColor: SplashColors.orange,
            ),
            const SizedBox(height: 14),
            const CircularProgressIndicator(color: SplashColors.mint),
            const SizedBox(height: 14),
            Text(
              'Sebentar, ya...',
              style: TextStyle(
                fontFamily: SplashTypography.fontFredoka,
                fontFamilyFallback: SplashTypography.fontFallbackSans,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: SplashColors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'solvzie.fess lagi menyiapkan semuanya',
              style: TextStyle(
                fontFamily: SplashTypography.fontInter,
                fontFamilyFallback: SplashTypography.fontFallbackSans,
                fontSize: 12,
                color: SplashColors.white.withValues(alpha: 0.78),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(MessageRepository repo) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const StickerStarWidget(
              label: '!',
              size: 64,
              color: SplashColors.magenta,
            ),
            const SizedBox(height: 14),
            Text(
              'Oops, ada yang nyangkut',
              textAlign: TextAlign.center,
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
              repo.errorMessage ?? 'Coba lagi sebentar, ya.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: SplashTypography.fontInter,
                fontFamilyFallback: SplashTypography.fontFallbackSans,
                fontSize: 12.5,
                color: SplashColors.white.withValues(alpha: 0.78),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: repo.refresh,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: SplashColors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: SplashColors.white, width: 2),
                ),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    'Coba lagi',
                    style: TextStyle(
                      fontFamily: SplashTypography.fontFredoka,
                      fontFamilyFallback: SplashTypography.fontFallbackSans,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: SplashColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
