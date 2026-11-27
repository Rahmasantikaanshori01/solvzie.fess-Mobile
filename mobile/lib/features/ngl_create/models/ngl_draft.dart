import 'dart:typed_data';

enum BackgroundType { photo, gradient }

enum GradientPreset {
  candySunset, // #FF6EC7 -> #FF9A3D
  purplePop,   // #A855F7 -> #60A5FA
  mintySky,    // #5EEAA8 -> #60A5FA
}

enum BubblePosition {
  atas,
  tengah,
  bawah,
}

/// NglItem represents an individual NGL instance with its own unique id and configuration.
class NglItem {
  final String id;
  final String name;
  final String slug;
  final String link;
  final String type;
  final BackgroundType backgroundType;
  final String? photoPath;
  final Uint8List? photoBytes;
  final GradientPreset gradientKey;
  final BubblePosition bubblePosition;
  final bool active;
  final bool deleted;
  final int messageCount;
  final int newMessageCount;

  const NglItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.link,
    this.type = 'Menfess',
    this.backgroundType = BackgroundType.gradient,
    this.photoPath,
    this.photoBytes,
    this.gradientKey = GradientPreset.candySunset,
    this.bubblePosition = BubblePosition.tengah,
    this.active = true,
    this.deleted = false,
    this.messageCount = 0,
    this.newMessageCount = 0,
  });

  /// Display URL without protocol, e.g. `solvzie.fess/@slug`.
  String get displayLink => 'solvzie.fess/@$slug';

  /// Shareable URL with protocol, e.g. `https://solvzie.fess/@slug`.
  String get shareUrl => link.startsWith('http') ? link : 'https://solvzie.fess/@$slug';

  int get messages => messageCount;

  NglItem copyWith({
    String? id,
    String? name,
    String? slug,
    String? link,
    String? type,
    BackgroundType? backgroundType,
    String? photoPath,
    Uint8List? photoBytes,
    GradientPreset? gradientKey,
    BubblePosition? bubblePosition,
    bool? active,
    bool? deleted,
    int? messageCount,
    int? newMessageCount,
  }) {
    return NglItem(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      link: link ?? this.link,
      type: type ?? this.type,
      backgroundType: backgroundType ?? this.backgroundType,
      photoPath: photoPath ?? this.photoPath,
      photoBytes: photoBytes ?? this.photoBytes,
      gradientKey: gradientKey ?? this.gradientKey,
      bubblePosition: bubblePosition ?? this.bubblePosition,
      active: active ?? this.active,
      deleted: deleted ?? this.deleted,
      messageCount: messageCount ?? this.messageCount,
      newMessageCount: newMessageCount ?? this.newMessageCount,
    );
  }
}

/// Mock message entry for calculating inbox counts & Home stats.
class NglMessageRecord {
  final String id;
  final String nglId;
  final String body;
  final String? song;
  final bool read;
  final bool archived;
  final DateTime createdAt;

  const NglMessageRecord({
    required this.id,
    required this.nglId,
    required this.body,
    this.song,
    this.read = false,
    this.archived = false,
    required this.createdAt,
  });
}

/// Activity item displayed in Home's "Aktivitas terbaru".
class NglActivityRecord {
  final String title;
  final String subtitle;
  final String timeLabel;
  final NglActivityKind kind;

  const NglActivityRecord({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.kind,
  });
}

enum NglActivityKind {
  newMessage,
  linkShared,
  storyCreated,
}
