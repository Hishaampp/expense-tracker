import 'package:drift/drift.dart';
import 'package:expense_tracker/core/models/account.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/transaction_kind.dart';

/// Where money sits (spec §12).
@DataClassName('AccountRow')
class Accounts extends Table {
  /// Stable unique id.
  TextColumn get id => text()();

  /// Display name.
  TextColumn get name => text().withLength(min: 1)();

  /// Account type.
  TextColumn get type => textEnum<AccountType>()();

  /// Bank code hint from captured messages.
  TextColumn get bankCode => text().nullable()();

  /// Last digits of the account or card number.
  TextColumn get last4 => text().nullable()();

  /// Hidden from pickers.
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  /// Creation instant, UTC epoch milliseconds.
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  bool get isStrict => true;

  @override
  List<String> get customConstraints => const [
    "CHECK (type IN ('bank', 'creditCard', 'cash', 'wallet'))",
  ];
}

/// What money was for (spec §12).
@DataClassName('CategoryRow')
class Categories extends Table {
  /// Stable unique id.
  TextColumn get id => text()();

  /// Display name.
  TextColumn get name => text().withLength(min: 1)();

  /// Icon key, resolved by the UI.
  TextColumn get icon => text()();

  /// Category kind.
  TextColumn get kind => textEnum<CategoryKind>()();

  /// Hidden from pickers.
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  /// Position in pickers.
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  bool get isStrict => true;

  @override
  List<String> get customConstraints => const [
    "CHECK (kind IN ('expense', 'income', 'system'))",
  ];
}

/// A trip, wedding or event bucket (spec §9.1). Used from Phase 5; defined
/// now because transactions reference it.
@DataClassName('RoomRow')
class Rooms extends Table {
  /// Stable unique id.
  TextColumn get id => text()();

  /// Display name.
  TextColumn get name => text().withLength(min: 1)();

  /// `trip`, `wedding`, `event` or `custom`.
  TextColumn get type => text()();

  /// Emoji shown with the name.
  TextColumn get emoji => text().nullable()();

  /// First local day, as days since 1970-01-01.
  IntColumn get startDay => integer().nullable()();

  /// Last local day (inclusive), as days since 1970-01-01.
  IntColumn get endDay => integer().nullable()();

  /// The Room's own budget in paise.
  IntColumn get budgetPaise => integer().nullable()();

  /// `dateWindow`, `suggest` or `manual`.
  TextColumn get autoTagMode => text()();

  /// Whether Room spending counts toward the monthly budget (spec §5.2).
  BoolColumn get countsTowardMonthlyBudget =>
      boolean().withDefault(const Constant(false))();

  /// `active` or `archived`.
  TextColumn get status => text().withDefault(const Constant('active'))();

  /// Creation instant, UTC epoch milliseconds.
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  bool get isStrict => true;

  @override
  List<String> get customConstraints => const [
    "CHECK (type IN ('trip', 'wedding', 'event', 'custom'))",
    "CHECK (auto_tag_mode IN ('dateWindow', 'suggest', 'manual'))",
    "CHECK (status IN ('active', 'archived'))",
    'CHECK (budget_paise IS NULL OR budget_paise >= 0)',
  ];
}

/// One money movement — the only place amounts live (spec §5.1, §12).
@DataClassName('TransactionRow')
@TableIndex(name: 'transactions_occurred_at', columns: {#occurredAt})
@TableIndex(name: 'transactions_room_id', columns: {#roomId})
@TableIndex(name: 'transactions_category_id', columns: {#categoryId})
@TableIndex(name: 'transactions_ref_no', columns: {#refNo})
@TableIndex(name: 'transactions_payee_key', columns: {#payeeKey})
class Transactions extends Table {
  /// Stable unique id.
  TextColumn get id => text()();

  /// Movement kind.
  TextColumn get kind => textEnum<TransactionKind>()();

  /// Amount in paise, always positive.
  IntColumn get amountPaise => integer()();

  /// ISO-4217 currency code.
  TextColumn get currency =>
      text().withLength(min: 3, max: 3).withDefault(const Constant('INR'))();

  /// When the money moved, UTC epoch milliseconds.
  IntColumn get occurredAt => integer()();

  /// Source account.
  TextColumn get accountId =>
      text().references(Accounts, #id, onDelete: KeyAction.restrict)();

  /// Destination account of a transfer.
  TextColumn get toAccountId => text().nullable().references(
    Accounts,
    #id,
    onDelete: KeyAction.restrict,
  )();

  /// Category; null is uncategorised.
  TextColumn get categoryId => text().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// Room; null is none.
  TextColumn get roomId =>
      text().nullable().references(Rooms, #id, onDelete: KeyAction.setNull)();

  /// Normalised payee identifier.
  TextColumn get payeeKey => text().nullable()();

  /// Payee as shown.
  TextColumn get payeeDisplay => text().nullable()();

  /// Payment instrument.
  TextColumn get instrument => textEnum<Instrument>()();

  /// Bank or UPI reference number.
  TextColumn get refNo => text().nullable()();

  /// User note.
  TextColumn get note => text().nullable()();

  /// Review state.
  TextColumn get reviewStatus => textEnum<ReviewStatus>()();

  /// Hidden from lists by default.
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();

  /// For a refund, the expense it reverses.
  TextColumn get linkedTransactionId => text().nullable()();

  /// How the transaction entered the app.
  TextColumn get origin => textEnum<TransactionOrigin>()();

  /// Creation instant, UTC epoch milliseconds.
  IntColumn get createdAt => integer()();

  /// Last change instant, UTC epoch milliseconds.
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  bool get isStrict => true;

  @override
  List<String> get customConstraints => const [
    'CHECK (amount_paise > 0)',
    "CHECK (kind IN ('expense', 'income', 'transfer', 'refund'))",
    "CHECK (review_status IN ('confirmed', 'needsReview'))",
    "CHECK (origin IN ('manual', 'auto'))",
  ];
}

/// Key–value app settings (spec §12).
@DataClassName('SettingRow')
class Settings extends Table {
  /// Setting name.
  TextColumn get key => text()();

  /// Setting value, as text.
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};

  @override
  bool get isStrict => true;
}
