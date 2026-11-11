import 'package:meta/meta.dart';

/// What the user taught the app about one payee (spec §8).
@immutable
final class PayeeRule {
  /// Creates the rule.
  const new({
    required this.payeeKey,
    this.categoryId,
    this.roomId,
    this.displayName,
  });

  /// The payee key it matches exactly.
  final String payeeKey;

  /// The category its payments always get, or null to ask.
  final String? categoryId;

  /// The Room its payments go to while that Room is active, or null.
  final String? roomId;

  /// The name to show instead of the bank's, or null.
  final String? displayName;

  /// Whether the rule says nothing at all (and can be forgotten).
  bool get isEmpty =>
      categoryId == null && roomId == null && displayName == null;

  /// A copy with the given fields replaced; pass null through the
  /// `clear…` flags to remove one.
  PayeeRule copyWith({
    String? categoryId,
    String? roomId,
    String? displayName,
    bool clearCategory = false,
    bool clearRoom = false,
    bool clearName = false,
  }) => PayeeRule(
    payeeKey: payeeKey,
    categoryId: clearCategory ? null : categoryId ?? this.categoryId,
    roomId: clearRoom ? null : roomId ?? this.roomId,
    displayName: clearName ? null : displayName ?? this.displayName,
  );

  @override
  bool operator ==(Object other) =>
      other is PayeeRule &&
      other.payeeKey == payeeKey &&
      other.categoryId == categoryId &&
      other.roomId == roomId &&
      other.displayName == displayName;

  @override
  int get hashCode => Object.hash(payeeKey, categoryId, roomId, displayName);
}

/// A payee seen in the user's transactions, with its rule if any: one row
/// of the merchant book.
typedef PayeeEntry = ({
  String payeeKey,
  String name,
  int count,
  PayeeRule? rule,
});
