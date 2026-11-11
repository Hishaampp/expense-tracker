import 'package:expense_tracker/core/models/transaction_item.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';
import 'package:meta/meta.dart';

/// What Activity is narrowed to (spec §11 screen 4): a search, and
/// filters by category, Room, account, kind and source.
@immutable
final class TransactionFilter {
  /// Creates the filter; the default matches everything.
  const new({
    this.query = '',
    this.categoryId,
    this.roomId,
    this.accountId,
    this.kind,
    this.origin,
  });

  /// Text typed in the search field.
  final String query;

  /// Only this category.
  final String? categoryId;

  /// Only this Room.
  final String? roomId;

  /// Only this account.
  final String? accountId;

  /// Only this kind.
  final TransactionKind? kind;

  /// Only typed-in or only captured payments.
  final TransactionOrigin? origin;

  /// Whether a search is typed.
  bool get searches => query.trim().isNotEmpty;

  /// How many filters (not counting the search) are set.
  int get filterCount => [
    categoryId,
    roomId,
    accountId,
    kind,
    origin,
  ].where((f) => f != null).length;

  /// Whether anything narrows the list.
  bool get isActive => searches || filterCount > 0;

  /// Whether [item] passes. The search matches the payee, the UPI id, the
  /// note, the category and the account by words, and an amount by its
  /// leading digits ("24" finds ₹240).
  bool matches(TransactionItem item) {
    final txn = item.transaction;
    if (categoryId != null && txn.categoryId != categoryId) return false;
    if (roomId != null && txn.roomId != roomId) return false;
    if (accountId != null && txn.accountId != accountId) return false;
    if (kind != null && txn.kind != kind) return false;
    if (origin != null && txn.origin != origin) return false;
    final text = query.trim().toLowerCase();
    if (text.isEmpty) return true;
    final digits = text.replaceAll(RegExp(r'[₹,\s]'), '');
    if (RegExp(r'^\d+(\.\d+)?$').hasMatch(digits)) {
      final rupees = '${txn.amount.wholeRupees}';
      final exact = txn.amount.paisePart == 0
          ? rupees
          : '$rupees.${txn.amount.paisePart.toString().padLeft(2, '0')}';
      return exact.startsWith(digits);
    }
    final haystack = [
      txn.payeeDisplay,
      txn.payeeKey,
      txn.note,
      item.category?.name,
      item.account?.name,
    ].whereType<String>().join(' ').toLowerCase();
    return text.split(RegExp(r'\s+')).every(haystack.contains);
  }

  /// A copy with the given fields replaced; `clear` names fields to unset.
  TransactionFilter copyWith({
    String? query,
    String? categoryId,
    String? roomId,
    String? accountId,
    TransactionKind? kind,
    TransactionOrigin? origin,
    Set<FilterField> clear = const {},
  }) => TransactionFilter(
    query: query ?? this.query,
    categoryId: clear.contains(FilterField.category)
        ? null
        : categoryId ?? this.categoryId,
    roomId: clear.contains(FilterField.room) ? null : roomId ?? this.roomId,
    accountId: clear.contains(FilterField.account)
        ? null
        : accountId ?? this.accountId,
    kind: clear.contains(FilterField.kind) ? null : kind ?? this.kind,
    origin: clear.contains(FilterField.origin) ? null : origin ?? this.origin,
  );

  @override
  bool operator ==(Object other) =>
      other is TransactionFilter &&
      other.query == query &&
      other.categoryId == categoryId &&
      other.roomId == roomId &&
      other.accountId == accountId &&
      other.kind == kind &&
      other.origin == origin;

  @override
  int get hashCode =>
      Object.hash(query, categoryId, roomId, accountId, kind, origin);
}

/// A filter that can be cleared on its own.
enum FilterField {
  /// The category filter.
  category,

  /// The Room filter.
  room,

  /// The account filter.
  account,

  /// The kind filter.
  kind,

  /// The source filter.
  origin,
}
