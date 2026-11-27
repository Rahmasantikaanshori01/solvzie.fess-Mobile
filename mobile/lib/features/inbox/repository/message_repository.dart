import 'package:flutter/foundation.dart';
import 'package:mobile/features/inbox/models/message_item.dart';

/// Shared single-source-of-truth repository interface for anonymous messages.
///
/// Used concurrently by Inbox, Pesan, Story, Arsip, Home, Link, and BottomNav.
abstract class MessageRepository extends ChangeNotifier {
  List<MessageItem> get messages;
  List<MessageItem> get allInboxMessages;
  List<MessageItem> get unreadMessages;
  List<MessageItem> get archivedMessages;

  int get unreadCount;
  int get inboxMessageCount;

  bool get isLoading;
  String? get errorMessage;

  List<MessageItem> messagesByNglId(String nglId);
  int messageCountForNgl(String nglId);
  int unreadCountForNgl(String nglId);
  MessageItem? getById(String id);

  Future<void> markRead(String id);
  Future<void> archive(String id);
  Future<void> unarchive(String id);
  Future<void> addMessage(MessageItem item);
  Future<void> refresh();
}

/// In-memory mock implementation of [MessageRepository] until Laravel API is wired.
class MockMessageRepository extends MessageRepository {
  static final MockMessageRepository instance = MockMessageRepository._();

  MockMessageRepository._({bool empty = false}) {
    if (!empty) {
      _initSeed();
    }
  }

  /// Returns the shared singleton repository used across the app.
  factory MockMessageRepository() => instance;

  /// Creates an isolated empty repository for unit and widget tests.
  MockMessageRepository.empty() : this._(empty: true);

  final List<MessageItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  void _initSeed() {
    if (_items.isNotEmpty) return;
    final now = DateTime.now();
    _items.addAll([
      MessageItem(
        id: 'msg-1',
        nglId: 'mock-1',
        nglName: 'fess kelas 12',
        text: 'semangat ujiannya ya! kamu pasti bisa, jangan lupa istirahat.',
        createdAt: now.subtract(const Duration(seconds: 20)),
        isRead: false,
        isArchived: false,
      ),
      MessageItem(
        id: 'msg-2',
        nglId: 'mock-1',
        nglName: 'fess kelas 12',
        text: 'lagu ini ngingetin aku sama waktu class meeting kemarin',
        createdAt: now.subtract(const Duration(minutes: 12)),
        isRead: false,
        isArchived: false,
        songTitle: 'Bergema Sampai Selamanya',
        songArtist: 'Nadhif',
      ),
      MessageItem(
        id: 'msg-3',
        nglId: 'mock-2',
        nglName: 'fess angkatan',
        text: 'makasih sudah jadi teman seangkatan yang seru banget!',
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
        isArchived: false,
      ),
      MessageItem(
        id: 'msg-4',
        nglId: 'mock-3',
        nglName: 'songfess malam',
        text: 'kapan bikin konten baru lagi?',
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
        isArchived: false,
        songTitle: 'Anything You Want',
        songArtist: 'Reality Club',
      ),
      MessageItem(
        id: 'msg-5',
        nglId: 'mock-4',
        nglName: 'NGL lama (nonaktif)',
        text: 'pesan lama tetap tersimpan di sini',
        createdAt: now.subtract(const Duration(days: 3)),
        isRead: true,
        isArchived: false,
      ),
    ]);
    _sortDescending();
  }

  void _sortDescending() {
    _items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void resetToDefaults() {
    _items.clear();
    _isLoading = false;
    _errorMessage = null;
    _initSeed();
    notifyListeners();
  }

  void clearAll() {
    _items.clear();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Test helper to simulate loading/error states in [InboxScreen].
  void setSimulatedState({bool? loading, String? error}) {
    if (loading != null) _isLoading = loading;
    _errorMessage = error;
    notifyListeners();
  }

  @override
  bool get isLoading => _isLoading;

  @override
  String? get errorMessage => _errorMessage;

  @override
  List<MessageItem> get messages => List.unmodifiable(_items);

  @override
  List<MessageItem> get allInboxMessages => List.unmodifiable(
        _items.where((m) => !m.isArchived),
      );

  @override
  List<MessageItem> get unreadMessages => List.unmodifiable(
        _items.where((m) => !m.isRead && !m.isArchived),
      );

  @override
  List<MessageItem> get archivedMessages => List.unmodifiable(
        _items.where((m) => m.isArchived),
      );

  @override
  int get unreadCount =>
      _items.where((m) => !m.isRead && !m.isArchived).length;

  /// Single formula for Home "Pesan masuk": all non-archived messages in Inbox.
  @override
  int get inboxMessageCount =>
      _items.where((m) => !m.isArchived).length;

  @override
  List<MessageItem> messagesByNglId(String nglId) => List.unmodifiable(
        _items.where((m) => m.nglId == nglId),
      );

  @override
  int messageCountForNgl(String nglId) =>
      _items.where((m) => m.nglId == nglId).length;

  @override
  int unreadCountForNgl(String nglId) =>
      _items.where((m) => m.nglId == nglId && !m.isRead && !m.isArchived).length;

  @override
  MessageItem? getById(String id) {
    final idx = _items.indexWhere((m) => m.id == id);
    return idx == -1 ? null : _items[idx];
  }

  @override
  Future<void> markRead(String id) async {
    final idx = _items.indexWhere((m) => m.id == id);
    if (idx == -1 || _items[idx].isRead) return;
    _items[idx] = _items[idx].copyWith(isRead: true);
    notifyListeners();
  }

  @override
  Future<void> archive(String id) async {
    final idx = _items.indexWhere((m) => m.id == id);
    if (idx == -1) return;
    if (_items[idx].isArchived && _items[idx].isRead) return;
    _items[idx] = _items[idx].copyWith(isArchived: true, isRead: true);
    notifyListeners();
  }

  @override
  Future<void> unarchive(String id) async {
    final idx = _items.indexWhere((m) => m.id == id);
    if (idx == -1 || !_items[idx].isArchived) return;
    _items[idx] = _items[idx].copyWith(isArchived: false, isRead: true);
    notifyListeners();
  }

  @override
  Future<void> addMessage(MessageItem item) async {
    _items.add(item);
    _sortDescending();
    notifyListeners();
  }

  @override
  Future<void> refresh() async {
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
