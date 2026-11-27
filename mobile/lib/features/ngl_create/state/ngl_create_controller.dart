import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/features/ngl_create/models/ngl_draft.dart';
import 'package:mobile/features/ngl_create/repository/ngl_repository.dart';
import 'package:mobile/features/ngl_create/services/image_picker_service.dart';

enum LinkStatus {
  empty,
  checking,
  available,
  taken,
  invalid,
}

class NglCreateController extends ChangeNotifier {
  final NglRepository repository;
  final ImagePickerService imagePickerService;
  final String username;

  NglCreateController({
    required this.repository,
    required this.imagePickerService,
    required this.username,
  });

  String _name = '';
  String _slug = '';
  bool _manuallyEditedSlug = false;
  LinkStatus _linkStatus = LinkStatus.empty;
  Timer? _debounceTimer;

  // Uploaded template photos (max 5)
  final List<PickedTemplateImage> _photos = [];

  // Selected template (live for both gallery & preview)
  BackgroundType _draftBackgroundType = BackgroundType.gradient;
  int? _draftPhotoIndex;

  // Color preset & bubble position
  GradientPreset _gradientKey = GradientPreset.candySunset;
  BubblePosition _bubblePosition = BubblePosition.tengah;
  bool _isSaved = false;

  // Getters
  String get name => _name;
  String get slug => _slug;
  LinkStatus get linkStatus => _linkStatus;
  List<PickedTemplateImage> get photos => List.unmodifiable(_photos);
  BackgroundType get draftBackgroundType => _draftBackgroundType;
  int? get draftPhotoIndex => _draftPhotoIndex;
  GradientPreset get gradientKey => _gradientKey;
  BubblePosition get bubblePosition => _bubblePosition;
  bool get isSaved => _isSaved;

  void markSaved() {
    _isSaved = true;
  }

  bool get isCanProceed =>
      _name.trim().isNotEmpty &&
      _linkStatus == LinkStatus.available &&
      (_draftBackgroundType == BackgroundType.gradient ||
          (_draftPhotoIndex != null && _draftPhotoIndex! < _photos.length));

  PickedTemplateImage? get draftPhoto {
    if (_draftBackgroundType == BackgroundType.photo &&
        _draftPhotoIndex != null &&
        _draftPhotoIndex! < _photos.length) {
      return _photos[_draftPhotoIndex!];
    }
    return null;
  }

  void setName(String val) {
    _name = val;
    if (!_manuallyEditedSlug) {
      _slug = _slugify(val);
    }
    _triggerLinkCheck();
    notifyListeners();
  }

  void setSlug(String val) {
    _slug = val.trim().toLowerCase();
    _manuallyEditedSlug = true;
    _triggerLinkCheck();
    notifyListeners();
  }

  void _triggerLinkCheck() {
    _debounceTimer?.cancel();
    final candidate = _slug.trim();
    if (candidate.isEmpty) {
      _linkStatus = LinkStatus.empty;
      return;
    }

    // Format regex: huruf kecil, angka, dot, hyphen, underscore (3-24 karakter)
    final formatValid = RegExp(r'^[a-z0-9._-]{3,24}$').hasMatch(candidate);
    if (!formatValid) {
      _linkStatus = LinkStatus.invalid;
      return;
    }

    _linkStatus = LinkStatus.checking;
    // Debounce 400 ms sesuai spesifikasi
    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      try {
        final available = await repository.isSlugAvailable(candidate);
        _linkStatus = available ? LinkStatus.available : LinkStatus.taken;
      } catch (e) {
        _linkStatus = LinkStatus.invalid;
      }
      notifyListeners();
    });
  }

  String _slugify(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9\s-_]'), '')
        .replaceAll(RegExp(r'[\s_]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  void selectGradient() {
    _draftBackgroundType = BackgroundType.gradient;
    _draftPhotoIndex = null;
    notifyListeners();
  }

  void selectPhoto(int index) {
    if (index >= 0 && index < _photos.length) {
      _draftBackgroundType = BackgroundType.photo;
      _draftPhotoIndex = index;
      notifyListeners();
    }
  }

  Future<bool> pickAndAddPhoto() async {
    if (_photos.length >= 5) {
      return false;
    }
    final image = await imagePickerService.pickTemplateImage();
    if (image == null) return false;

    _photos.add(image);
    _draftBackgroundType = BackgroundType.photo;
    _draftPhotoIndex = _photos.length - 1;
    notifyListeners();
    return true;
  }

  Future<bool> replaceCurrentPhoto() async {
    if (_draftBackgroundType != BackgroundType.photo ||
        _draftPhotoIndex == null ||
        _draftPhotoIndex! >= _photos.length) {
      return false; // // TODO(design): perilaku saat gradasi
    }
    final image = await imagePickerService.pickTemplateImage();
    if (image == null) return false;

    _photos[_draftPhotoIndex!] = image;
    notifyListeners();
    return true;
  }

  bool deleteCurrentPhoto() {
    if (_draftBackgroundType != BackgroundType.photo ||
        _draftPhotoIndex == null ||
        _draftPhotoIndex! >= _photos.length) {
      return false;
    }

    final removedIndex = _draftPhotoIndex!;
    _photos.removeAt(removedIndex);

    // Reset pilihan ke Gradasi acak
    _draftBackgroundType = BackgroundType.gradient;
    _draftPhotoIndex = null;

    notifyListeners();
    return true;
  }

  bool setGradientPreset(GradientPreset preset) {
    // Pilihan warna HANYA berfungsi jika template terpilih adalah Gradasi acak/warna bawaan.
    // Jika template terpilih adalah FOTO: tidak mengubah apa pun.
    if (_draftBackgroundType == BackgroundType.photo) {
      return false;
    }
    _gradientKey = preset;
    notifyListeners();
    return true;
  }

  void setBubblePosition(BubblePosition pos) {
    _bubblePosition = pos;
    notifyListeners();
  }

  void applyDraftToPreview() {
    notifyListeners();
  }

  NglItem buildNglItem() {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final photo = draftPhoto;
    final cleanSlug = _slug.trim();

    return NglItem(
      id: id,
      name: _name.trim(),
      slug: cleanSlug,
      link: 'https://solvzie.fess/@$cleanSlug',
      type: 'Menfess',
      backgroundType: _draftBackgroundType,
      photoPath: photo?.path,
      photoBytes: photo?.bytes,
      gradientKey: _gradientKey,
      bubblePosition: _bubblePosition,
      active: true,
      deleted: false,
      messageCount: 0,
      newMessageCount: 0,
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
