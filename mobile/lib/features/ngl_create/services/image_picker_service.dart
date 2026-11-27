import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Representation of a template image chosen by the user.
/// Supports both Uint8List (works in Web & Mobile) and optional file path (mobile only).
class PickedTemplateImage {
  final String id;
  final Uint8List bytes;
  final String? path;
  final String name;

  const PickedTemplateImage({
    required this.id,
    required this.bytes,
    this.path,
    required this.name,
  });
}

/// Interface for picking images to enable unit/widget test mocking.
abstract class ImagePickerService {
  Future<PickedTemplateImage?> pickTemplateImage();
}

/// Default implementation using image_picker package.
class DefaultImagePickerService implements ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<PickedTemplateImage?> pickTemplateImage() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (file == null) return null;

      final bytes = await file.readAsBytes();
      // Maximum 5 MB check
      if (bytes.lengthInBytes > 5 * 1024 * 1024) {
        throw Exception('Ukuran file melebihi 5 MB');
      }

      return PickedTemplateImage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        bytes: bytes,
        path: kIsWeb ? null : file.path,
        name: file.name,
      );
    } catch (e) {
      debugPrint('DefaultImagePickerService error: $e');
      rethrow;
    }
  }
}

/// Fake implementation for automated testing.
class FakeImagePickerService implements ImagePickerService {
  PickedTemplateImage? nextResult;
  bool shouldThrow = false;
  int pickCallCount = 0;

  FakeImagePickerService({this.nextResult, this.shouldThrow = false});

  @override
  Future<PickedTemplateImage?> pickTemplateImage() async {
    pickCallCount++;
    if (shouldThrow) {
      throw Exception('Simulated picker error');
    }
    return nextResult;
  }
}
