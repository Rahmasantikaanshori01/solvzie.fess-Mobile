import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

/// Result of saving or sharing a rendered story card.
class StoryExportResult {
  final bool success;
  final String message;

  const StoryExportResult({
    required this.success,
    required this.message,
  });
}

/// Abstract service wrapping story capture, gallery saving, and share sheet actions
/// so widget tests can supply a fake implementation and web has a safe fallback.
abstract class StoryExportService {
  Future<Uint8List> capturePreview(GlobalKey boundaryKey);

  Future<StoryExportResult> saveToGallery(
    Uint8List pngBytes, {
    required String fileName,
  });

  Future<StoryExportResult> shareStory(
    Uint8List pngBytes, {
    required String fileName,
    String? caption,
  });
}

/// Production implementation backed by `gal` (Android/iOS) and `share_plus`
/// with graceful fallbacks on Flutter Web.
class DefaultStoryExportService implements StoryExportService {
  const DefaultStoryExportService();

  @override
  Future<Uint8List> capturePreview(GlobalKey boundaryKey) async {
    try {
      final renderObject = boundaryKey.currentContext?.findRenderObject();
      if (renderObject is RenderRepaintBoundary) {
        final ui.Image image = await renderObject.toImage(pixelRatio: 2.5);
        final byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          return byteData.buffer.asUint8List();
        }
      }
    } catch (_) {
      // Fall back to empty payload when rasterization is unavailable.
    }
    return Uint8List(0);
  }

  @override
  Future<StoryExportResult> saveToGallery(
    Uint8List pngBytes, {
    required String fileName,
  }) async {
    if (kIsWeb) {
      // Web fallback: offer native share sheet or inform user cleanly.
      try {
        await SharePlus.instance.share(
          ShareParams(
            files: [
              XFile.fromData(
                pngBytes,
                mimeType: 'image/png',
                name: '$fileName.png',
              ),
            ],
            text: 'Story solvzie.fess',
          ),
        );
        return const StoryExportResult(
          success: true,
          message: 'Siap disimpan atau dibagikan',
        );
      } catch (_) {
        return const StoryExportResult(
          success: true,
          message: 'Pratinjau story siap (simpan galeri tersedia di Android/iOS)',
        );
      }
    }

    try {
      await Gal.putImageBytes(pngBytes, name: fileName);
      return const StoryExportResult(
        success: true,
        message: 'Tersimpan di galeri',
      );
    } catch (_) {
      return const StoryExportResult(
        success: false,
        message: 'Gagal menyimpan ke galeri. Pastikan izin galeri aktif.',
      );
    }
  }

  @override
  Future<StoryExportResult> shareStory(
    Uint8List pngBytes, {
    required String fileName,
    String? caption,
  }) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              pngBytes,
              mimeType: 'image/png',
              name: '$fileName.png',
            ),
          ],
          text: caption,
        ),
      );
      return const StoryExportResult(
        success: true,
        message: 'Membuka bagikan story...',
      );
    } catch (_) {
      return const StoryExportResult(
        success: false,
        message: 'Fitur bagikan tidak tersedia di perangkat ini.',
      );
    }
  }
}

/// Fake service for unit and widget testing without platform plugins.
class FakeStoryExportService implements StoryExportService {
  int saveCallCount = 0;
  int shareCallCount = 0;
  Uint8List? lastSavedBytes;
  Uint8List? lastSharedBytes;
  bool shouldSucceed = true;

  @override
  Future<Uint8List> capturePreview(GlobalKey boundaryKey) async {
    return Uint8List.fromList(const [1, 2, 3]);
  }

  @override
  Future<StoryExportResult> saveToGallery(
    Uint8List pngBytes, {
    required String fileName,
  }) async {
    saveCallCount++;
    lastSavedBytes = pngBytes;
    return StoryExportResult(
      success: shouldSucceed,
      message: shouldSucceed ? 'Tersimpan di galeri' : 'Gagal menyimpan',
    );
  }

  @override
  Future<StoryExportResult> shareStory(
    Uint8List pngBytes, {
    required String fileName,
    String? caption,
  }) async {
    shareCallCount++;
    lastSharedBytes = pngBytes;
    return StoryExportResult(
      success: shouldSucceed,
      message: shouldSucceed ? 'Membuka bagikan story...' : 'Gagal membagikan',
    );
  }
}
