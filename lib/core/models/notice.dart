import 'package:meta/meta.dart';

/// What a notice is about.
enum NoticeKind {
  /// A budget threshold was reached.
  budget,

  /// The Sunday weekly review.
  weekly,

  /// A captured payment that may belong to a Room.
  room,
}

/// One entry in the in-app notification inbox.
@immutable
final class Notice {
  /// Creates the notice.
  const new({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    this.route,
    this.readAt,
  });

  /// Stable id.
  final String id;

  /// What it is about.
  final NoticeKind kind;

  /// Its title.
  final String title;

  /// Its text.
  final String body;

  /// The screen it opens, or null.
  final String? route;

  /// When it was sent (UTC).
  final DateTime createdAt;

  /// When it was seen in the inbox; null while unread.
  final DateTime? readAt;

  /// Whether it has not been seen yet.
  bool get isUnread => readAt == null;

  @override
  bool operator ==(Object other) =>
      other is Notice &&
      other.id == id &&
      other.kind == kind &&
      other.title == title &&
      other.body == body &&
      other.route == route &&
      other.createdAt == createdAt &&
      other.readAt == readAt;

  @override
  int get hashCode =>
      Object.hash(id, kind, title, body, route, createdAt, readAt);
}
