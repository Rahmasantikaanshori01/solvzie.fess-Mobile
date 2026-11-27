/// Data models for solvzie.fess app.
///
/// These are in-memory models only — no backend connection yet.
/// Matching the data shape from Figma Make's mockData.ts.

class NglItem {
  final String id;
  final String name;
  final String slug;
  final bool active;
  final String theme; // color theme key: 'sunset','violet','aqua','purple', etc.
  final String? imagePath;
  final String position; // 'top', 'middle', 'bottom'

  const NglItem({
    required this.id,
    required this.name,
    required this.slug,
    this.active = true,
    this.theme = 'sunset',
    this.imagePath,
    this.position = 'middle',
  });
}

class MessageItem {
  final String id;
  final String nglId;
  final String body;
  final String? song;
  final bool read;
  final bool archived;
  final DateTime createdAt;

  const MessageItem({
    required this.id,
    required this.nglId,
    required this.body,
    this.song,
    this.read = false,
    this.archived = false,
    required this.createdAt,
  });
}

/// Derived activity type for display in "Aktivitas terbaru".
enum ActivityType { newMessage, linkShared, storyCreated, linkCreated }

class ActivityItem {
  final ActivityType type;
  final String title;
  final String subtitle;
  final DateTime timestamp;

  const ActivityItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });
}
