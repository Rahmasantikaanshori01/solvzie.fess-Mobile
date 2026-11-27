/// Data model for a single anonymous message in Inbox, Pesan, Story, and Arsip.
class MessageItem {
  final String id;
  final String nglId;
  final String nglName;
  final String text;
  final DateTime createdAt;
  final bool isRead;
  final bool isArchived;
  final String? songTitle;
  final String? songArtist;

  const MessageItem({
    required this.id,
    required this.nglId,
    required this.nglName,
    required this.text,
    required this.createdAt,
    this.isRead = false,
    this.isArchived = false,
    this.songTitle,
    this.songArtist,
  });

  /// Returns true when the message includes a song attachment (songfess).
  bool get isSongfess =>
      (songTitle != null && songTitle!.trim().isNotEmpty) ||
      (songArtist != null && songArtist!.trim().isNotEmpty);

  /// Formats song metadata as "{title} — {artist}", or null if not songfess.
  String? get songDisplay {
    final title = songTitle?.trim() ?? '';
    final artist = songArtist?.trim() ?? '';
    if (title.isEmpty && artist.isEmpty) return null;
    if (title.isNotEmpty && artist.isNotEmpty) return '$title — $artist';
    return title.isNotEmpty ? title : artist;
  }

  MessageItem copyWith({
    String? id,
    String? nglId,
    String? nglName,
    String? text,
    DateTime? createdAt,
    bool? isRead,
    bool? isArchived,
    String? songTitle,
    String? songArtist,
  }) {
    return MessageItem(
      id: id ?? this.id,
      nglId: nglId ?? this.nglId,
      nglName: nglName ?? this.nglName,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isArchived: isArchived ?? this.isArchived,
      songTitle: songTitle ?? this.songTitle,
      songArtist: songArtist ?? this.songArtist,
    );
  }
}
