import 'package:meta/meta.dart';

/// Where money sits.
enum AccountType {
  /// A bank account.
  bank,

  /// A credit card.
  creditCard,

  /// Physical cash.
  cash,

  /// A wallet balance (Paytm, UPI Lite…).
  wallet,
}

/// An account the user pays from.
@immutable
final class Account {
  /// Creates an account.
  const new({
    required this.id,
    required this.name,
    required this.type,
    this.isArchived = false,
  });

  /// Id of the built-in Cash account, created with the database.
  static const String cashId = 'account_cash';

  /// Stable unique id.
  final String id;

  /// Display name, for example "Cash" or "HDFC ••1234".
  final String name;

  /// What kind of account this is.
  final AccountType type;

  /// Whether the user has hidden the account from pickers.
  final bool isArchived;

  @override
  bool operator ==(Object other) =>
      other is Account &&
      other.id == id &&
      other.name == name &&
      other.type == type &&
      other.isArchived == isArchived;

  @override
  int get hashCode => Object.hash(id, name, type, isArchived);
}
