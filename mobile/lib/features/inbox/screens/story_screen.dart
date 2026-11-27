import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/features/inbox/models/message_item.dart';
import 'package:mobile/features/inbox/repository/message_repository.dart';
import 'package:mobile/features/inbox/screens/arsip_screen.dart';
import 'package:mobile/features/inbox/services/story_export_service.dart';
import 'package:mobile/features/inbox/widgets/inbox_header.dart';
import 'package:mobile/features/inbox/widgets/story_message_bubble.dart';
import 'package:mobile/features/ngl_create/models/ngl_draft.dart';
import 'package:mobile/features/ngl_create/repository/ngl_repository.dart';
import 'package:mobile/features/ngl_create/services/image_picker_service.dart';
import 'package:mobile/features/ngl_create/widgets/phone_preview.dart';

/// 9:16 Story preview screen reusing [PhonePreview] from NGL Create flow.
class StoryScreen extends StatefulWidget {
  final String messageId;
  final String username;
  final MessageRepository messageRepository;
  final NglRepository nglRepository;
  final StoryExportService? storyExportService;

  const StoryScreen({
    super.key,
    required this.messageId,
    required this.username,
    required this.messageRepository,
    required this.nglRepository,
    this.storyExportService,
  });

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final GlobalKey _previewBoundaryKey = GlobalKey();
  bool _isExporting = false;

  StoryExportService get _exportService =>
      widget.storyExportService ?? const DefaultStoryExportService();

  NglItem? _resolveNgl(String nglId) {
    for (final ngl in widget.nglRepository.ngls) {
      if (ngl.id == nglId) return ngl;
    }
    return null;
  }

  void _showToast(String message) {
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
                message,
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

  Future<void> _handleShare(MessageItem message) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    final pngBytes = await _exportService.capturePreview(_previewBoundaryKey);
    final result = await _exportService.shareStory(
      pngBytes,
      fileName: 'solvzie-story-${message.id}',
      caption: message.text,
    );
    if (!mounted) return;
    setState(() => _isExporting = false);
    _showToast(result.message);
  }

  Future<void> _handleSaveToGallery(MessageItem message) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    final pngBytes = await _exportService.capturePreview(_previewBoundaryKey);
    final result = await _exportService.saveToGallery(
      pngBytes,
      fileName: 'solvzie-story-${message.id}',
    );
    if (!mounted) return;
    setState(() => _isExporting = false);
    _showToast(result.message);
  }

  Future<void> _confirmMoveToArchive(MessageItem message) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: SplashColors.tealDeep.withValues(alpha: 0.72),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          decoration: BoxDecoration(
            color: SplashColors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: SplashColors.magenta, width: 3.0),
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
                  color: SplashColors.lavenderCardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SplashColors.magenta, width: 2.0),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: SplashColors.magenta,
                  size: 26,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Pindahkan ke Arsip?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: SplashTypography.fontFredoka,
                  fontFamilyFallback: SplashTypography.fontFallbackSans,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: SplashColors.purpleDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pesan tetap bisa kamu buka dan kembalikan nanti.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: SplashTypography.fontInter,
                  fontFamilyFallback: SplashTypography.fontFallbackSans,
                  fontSize: 12.5,
                  height: 1.45,
                  color: SplashColors.inboxEmptyBody,
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => Navigator.of(dialogContext).pop(true),
                child: Container(
                  height: 48,
                  width: double.infinity,
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
                        offset: Offset(0, 3.5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Pindahkan',
                      style: TextStyle(
                        fontFamily: SplashTypography.fontFredoka,
                        fontFamilyFallback: SplashTypography.fontFallbackSans,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: SplashColors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(
                  'Nanti',
                  style: TextStyle(
                    fontFamily: SplashTypography.fontFredoka,
                    fontFamilyFallback: SplashTypography.fontFallbackSans,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: SplashColors.ink.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await widget.messageRepository.archive(message.id);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
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
  }

  @override
  Widget build(BuildContext context) {
    final MessageItem? message =
        widget.messageRepository.getById(widget.messageId);

    if (message == null) {
      return Scaffold(
        backgroundColor: SplashColors.tealDeep,
        body: InboxGridBackground(
          child: SafeArea(
            child: Column(
              children: [
                InboxBackHeader(
                  title: 'STORY',
                  pill: 'PRATINJAU',
                  onBack: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Pesan tidak ditemukan.',
                      style: TextStyle(
                        fontFamily: SplashTypography.fontFredoka,
                        fontFamilyFallback: SplashTypography.fontFallbackSans,
                        fontSize: 15,
                        color: SplashColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final NglItem? ngl = _resolveNgl(message.nglId);
    final BackgroundType backgroundType = ngl != null &&
            ngl.backgroundType == BackgroundType.photo &&
            ngl.photoBytes != null
        ? BackgroundType.photo
        : BackgroundType.gradient;
    final PickedTemplateImage? photo =
        backgroundType == BackgroundType.photo && ngl?.photoBytes != null
            ? PickedTemplateImage(
                id: ngl!.id,
                bytes: ngl.photoBytes!,
                path: ngl.photoPath,
                name: ngl.name,
              )
            : null;
    final GradientPreset gradientKey =
        ngl?.gradientKey ?? GradientPreset.candySunset;
    final BubblePosition bubblePosition =
        ngl?.bubblePosition ?? BubblePosition.tengah;

    return Scaffold(
      backgroundColor: SplashColors.tealDeep,
      body: InboxGridBackground(
        child: SafeArea(
          child: Column(
            children: [
              InboxBackHeader(
                title: 'STORY',
                pill: 'PRATINJAU',
                onBack: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RepaintBoundary(
                        key: _previewBoundaryKey,
                        child: PhonePreview(
                          backgroundType: backgroundType,
                          photo: photo,
                          gradientKey: gradientKey,
                          bubblePosition: bubblePosition,
                          child: StoryMessageBubble(
                            username: widget.username,
                            messageText: message.text,
                            songDisplay: message.songDisplay,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Primary share button
                      GestureDetector(
                        onTap: () => _handleShare(message),
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [SplashColors.purple, SplashColors.blue],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: SplashColors.white,
                              width: 2.0,
                            ),
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
                              const Icon(
                                Icons.share_rounded,
                                color: SplashColors.white,
                                size: 19,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Bagikan ke Instagram Story',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: SplashTypography.fontFredoka,
                                    fontFamilyFallback:
                                        SplashTypography.fontFallbackSans,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: SplashColors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Dual secondary row: Simpan ke galeri & Sudah dipost
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _handleSaveToGallery(message),
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: SplashColors.white
                                      .withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: SplashColors.white,
                                    width: 2.0,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: SplashColors.inboxCardDropShadow,
                                      offset: Offset(0, 3.5),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.image_outlined,
                                        color: SplashColors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'Simpan',
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontFamily:
                                                  SplashTypography.fontFredoka,
                                              fontFamilyFallback:
                                                  SplashTypography
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
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _confirmMoveToArchive(message),
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: SplashColors.mint,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: SplashColors.white,
                                    width: 2.0,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: SplashColors.mintDeep,
                                      offset: Offset(0, 3.5),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.check_rounded,
                                        color: SplashColors.ink,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'Sudah dipost',
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontFamily:
                                                  SplashTypography.fontFredoka,
                                              fontFamilyFallback:
                                                  SplashTypography
                                                      .fontFallbackSans,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: SplashColors.ink,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
      ),
    );
  }
}
