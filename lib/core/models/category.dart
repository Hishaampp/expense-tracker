import 'package:meta/meta.dart';

/// What a category is used for.
enum CategoryKind {
  /// Spending categories the user can edit.
  expense,

  /// Income categories.
  income,

  /// Built-in categories excluded from spending (Transfer, Refund…).
  system,
}

/// What money was for.
@immutable
final class Category {
  /// Creates a category.
  const new({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.kind,
    required this.sortOrder,
    this.isArchived = false,
  });

  /// Stable unique id.
  final String id;

  /// Display name, for example "Food & Dining".
  final String name;

  /// Key of the icon, resolved to a glyph by the UI.
  final String iconKey;

  /// What the category is used for.
  final CategoryKind kind;

  /// Position in pickers, ascending.
  final int sortOrder;

  /// Whether the user has hidden the category from pickers.
  final bool isArchived;

  @override
  bool operator ==(Object other) =>
      other is Category &&
      other.id == id &&
      other.name == name &&
      other.iconKey == iconKey &&
      other.kind == kind &&
      other.sortOrder == sortOrder &&
      other.isArchived == isArchived;

  @override
  int get hashCode =>
      Object.hash(id, name, iconKey, kind, sortOrder, isArchived);
}
