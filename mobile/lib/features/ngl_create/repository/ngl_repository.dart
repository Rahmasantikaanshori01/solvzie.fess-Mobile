import 'package:flutter/foundation.dart';
import 'package:mobile/features/inbox/repository/message_repository.dart';
import 'package:mobile/features/ngl_create/models/ngl_draft.dart';

/// Sample 8x14 raster PNG bytes for seeded photo NGL (Web & Mobile compatible).
final Uint8List _kSeedSamplePhotoBytes = Uint8List.fromList(<int>[
  137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 8, 0,
  0, 0, 14, 8, 6, 0, 0, 0, 18, 86, 93, 150, 0, 0, 0, 208, 73, 68, 65, 84, 120,
  156, 21, 202, 161, 78, 134, 33, 0, 0, 64, 159, 248, 47, 110, 68, 108, 20, 55,
  34, 54, 138, 27, 17, 27, 197, 141, 136, 141, 200, 235, 124, 30, 225, 218, 189,
  61, 175, 191, 231, 121, 253, 242, 195, 55, 95, 124, 242, 193, 251, 243, 246,
  4, 33, 8, 65, 8, 66, 16, 130, 16, 132, 112, 67, 20, 162, 16, 133, 40, 68, 33,
  10, 81, 136, 55, 36, 33, 9, 73, 72, 66, 18, 146, 144, 132, 116, 67, 22, 178,
  144, 133, 44, 100, 33, 11, 89, 200, 55, 20, 161, 8, 69, 40, 66, 17, 138, 80,
  132, 114, 67, 21, 170, 80, 133, 42, 84, 161, 10, 85, 168, 55, 52, 161, 9, 77,
  104, 66, 19, 154, 208, 132, 118, 67, 23, 186, 208, 133, 46, 116, 161, 11, 93,
  232, 55, 12, 97, 8, 67, 24, 194, 16, 134, 48, 132, 113, 195, 20, 166, 48, 133,
  41, 76, 97, 10, 83, 152, 55, 44, 97, 9, 75, 88, 194, 18, 150, 176, 132, 117,
  195, 22, 182, 176, 133, 45, 108, 97, 11, 91, 216, 55, 28, 225, 8, 71, 56, 194,
  17, 142, 112, 132, 243, 254, 252, 3, 115, 214, 106, 192, 39, 56, 46, 60, 0, 0,
  0, 0, 73, 69, 78, 68, 174, 66, 96, 130,
]);

/// Shared reactive repository interface for NGL links, messages, and recent activities.
abstract class NglRepository extends ChangeNotifier {
  List<NglItem> get ngls;
  List<NglMessageRecord> get messages;
  List<NglActivityRecord> get activities;

  int get activeNglCount;
  int get totalMessageCount;
  int get unreadMessageCount;

  Future<List<NglItem>> getNgls();
  Future<bool> isSlugAvailable(String slug);
  Future<void> addNgl(NglItem item);
  Future<void> toggleActive(String id);
  Future<void> softDelete(String id);
}

class MockNglRepository extends NglRepository {
  static final MockNglRepository instance = MockNglRepository._(
    messageRepo: MockMessageRepository.instance,
  );

  MockNglRepository._({
    bool empty = false,
    MockMessageRepository? messageRepo,
  }) : _messageRepo = messageRepo ?? MockMessageRepository.empty() {
    _messageRepo.addListener(_onMessagesChanged);
    if (!empty) {
      _initDefaults();
    }
  }

  /// Returns the shared singleton repository used across Home, Link, and Buat NGL.
  factory MockNglRepository() => instance;

  /// Creates an isolated empty repository instance for widget testing.
  MockNglRepository.empty()
      : this._(empty: true, messageRepo: MockMessageRepository.empty());

  final MockMessageRepository _messageRepo;
  final List<NglItem> _items = [];
  final List<NglActivityRecord> _activities = [];

  void _onMessagesChanged() {
    notifyListeners();
  }

  /// Exposes the paired [MockMessageRepository] for callers that do not pass
  /// a custom [MessageRepository] explicitly (e.g., isolated widget tests).
  MockMessageRepository get defaultMessageRepository => _messageRepo;

  static const List<String> _reservedSlugs = [
    'kelas12',
    'angkatan',
    'solvzie',
  ];

  void _initDefaults() {
    if (_items.isEmpty) {
      _items.addAll([
        const NglItem(
          id: 'mock-1',
          name: 'fess kelas 12',
          slug: 'fess-kelas-12',
          link: 'https://solvzie.fess/@fess-kelas-12',
          type: 'Menfess',
          backgroundType: BackgroundType.gradient,
          gradientKey: GradientPreset.candySunset,
          bubblePosition: BubblePosition.tengah,
          active: true,
          messageCount: 2,
          newMessageCount: 2,
        ),
        NglItem(
          id: 'mock-2',
          name: 'fess angkatan',
          slug: 'fess-angkatan',
          link: 'https://solvzie.fess/@fess-angkatan',
          type: 'Menfess',
          backgroundType: BackgroundType.photo,
          photoBytes: _kSeedSamplePhotoBytes,
          bubblePosition: BubblePosition.tengah,
          active: true,
          messageCount: 1,
          newMessageCount: 0,
        ),
        const NglItem(
          id: 'mock-3',
          name: 'songfess malam',
          slug: 'songfess-malam',
          link: 'https://solvzie.fess/@songfess-malam',
          type: 'Songfess',
          backgroundType: BackgroundType.gradient,
          gradientKey: GradientPreset.candySunset,
          bubblePosition: BubblePosition.atas,
          active: true,
          messageCount: 1,
          newMessageCount: 0,
        ),
        const NglItem(
          id: 'mock-4',
          name: 'NGL lama (nonaktif)',
          slug: 'ngl-lama-nonaktif',
          link: 'https://solvzie.fess/@ngl-lama-nonaktif',
          type: 'Menfess',
          backgroundType: BackgroundType.gradient,
          gradientKey: GradientPreset.purplePop,
          bubblePosition: BubblePosition.bawah,
          active: false,
          messageCount: 1,
          newMessageCount: 0,
        ),
      ]);
    }

    if (_activities.isEmpty) {
      _activities.addAll(const [
        NglActivityRecord(
          title: 'Pesan baru masuk',
          subtitle: 'fess kelas 12',
          timeLabel: 'Baru saja',
          kind: NglActivityKind.newMessage,
        ),
        NglActivityRecord(
          title: 'Link dibagikan',
          subtitle: 'songfess malam',
          timeLabel: '1 jam',
          kind: NglActivityKind.linkShared,
        ),
        NglActivityRecord(
          title: 'Story berhasil dibuat',
          subtitle: 'fess kelas 12',
          timeLabel: 'Kemarin',
          kind: NglActivityKind.storyCreated,
        ),
      ]);
    }
  }

  void resetToDefaults() {
    _items.clear();
    _activities.clear();
    _messageRepo.resetToDefaults();
    _initDefaults();
    notifyListeners();
  }

  void clearAll() {
    _items.clear();
    _activities.clear();
    _messageRepo.clearAll();
    notifyListeners();
  }

  @override
  List<NglItem> get ngls =>
      List.unmodifiable(_items.where((item) => !item.deleted));

  @override
  List<NglMessageRecord> get messages => List.unmodifiable(
        _messageRepo.messages.map(
          (m) => NglMessageRecord(
            id: m.id,
            nglId: m.nglId,
            body: m.text,
            song: m.songDisplay,
            read: m.isRead,
            archived: m.isArchived,
            createdAt: m.createdAt,
          ),
        ),
      );

  @override
  List<NglActivityRecord> get activities => List.unmodifiable(_activities);

  @override
  int get activeNglCount =>
      _items.where((item) => !item.deleted && item.active).length;

  @override
  int get totalMessageCount => _messageRepo.inboxMessageCount;

  @override
  int get unreadMessageCount => _messageRepo.unreadCount;

  @override
  Future<List<NglItem>> getNgls() async => ngls;

  @override
  Future<bool> isSlugAvailable(String slug) async {
    final normalized = slug.trim().toLowerCase();
    if (_reservedSlugs.contains(normalized)) {
      return false;
    }
    final exists = _items.any(
      (item) => !item.deleted && item.slug.toLowerCase() == normalized,
    );
    return !exists;
  }

  @override
  Future<void> addNgl(NglItem item) async {
    _items.insert(0, item);
    notifyListeners();
  }

  @override
  Future<void> toggleActive(String id) async {
    final idx = _items.indexWhere((item) => item.id == id && !item.deleted);
    if (idx == -1) return;
    _items[idx] = _items[idx].copyWith(active: !_items[idx].active);
    notifyListeners();
  }

  @override
  Future<void> softDelete(String id) async {
    final idx = _items.indexWhere((item) => item.id == id && !item.deleted);
    if (idx == -1) return;
    _items[idx] = _items[idx].copyWith(deleted: true, active: false);
    notifyListeners();
  }
}
