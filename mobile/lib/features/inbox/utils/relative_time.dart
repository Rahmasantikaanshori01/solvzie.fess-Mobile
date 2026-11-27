/// Formats a [createdAt] timestamp into an Indonesian relative time label.
///
/// Output rules:
/// - Less than 1 minute: "Baru saja"
/// - 1..59 minutes: "N menit lalu"
/// - 1..23 hours: "N jam lalu"
/// - 1 day: "Kemarin"
/// - 2+ days: "N hari lalu"
String formatRelativeTime(DateTime createdAt, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final diff = reference.difference(createdAt);

  if (diff.isNegative || diff.inSeconds < 60) {
    return 'Baru saja';
  }
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes} menit lalu';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours} jam lalu';
  }
  final days = diff.inDays;
  if (days == 1) {
    return 'Kemarin';
  }
  return '$days hari lalu';
}
