import 'package:drift/drift.dart';
import 'package:expense_tracker/core/models/account.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/room.dart';
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

/// A trip, wedding or event bucket (spec §9.1). Its tile colour follows
/// its type, so no colour is stored.
@DataClassName('RoomRow')
class Rooms extends Table {
  /// Stable unique id.
  TextColumn get id => text()();

  /// Display name.
  TextColumn get name => text().withLength(min: 1)();

  /// `trip`, `wedding`, `event` or `custom`.
  TextColumn get type => textEnum<RoomType>()();

  /// Emoji shown with the name.
  TextColumn get emoji => text().nullable()();

  /// First local day, as days since 1970-01-01.
  IntColumn get startDay => integer().nullable()();

  /// Last local day (inclusive), as days since 1970-01-01.
  IntColumn get endDay => integer().nullable()();

  /// The Room's own budget in paise.
  IntColumn get budgetPaise => integer().nullable()();

  /// `dateWindow`, `suggest` or `manual`.
  TextColumn get autoTagMode => textEnum<AutoTagMode>()();

  /// Whether Room spending counts toward the monthly budget (spec §5.2).
  BoolColumn get countsTowardMonthlyBudget =>
      boolean().withDefault(const Constant(false))();

  /// `active` or `archived`.
  TextColumn get status =>
      textEnum<RoomStatus>().withDefault(const Constant('active'))();

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

/// Raw text received from a capture source, before parsing (spec §12).
/// Holds no message text: only what is needed to de-duplicate and to say
/// what happened to it.
@DataClassName('RawCaptureRow')
class RawCaptures extends Table {
  /// Stable unique id (the native queue's id when it came from there).
  TextColumn get id => text()();

  /// Hash of origin + text + minute received; the de-duplication key.
  TextColumn get contentHash => text().unique()();

  /// Where it came from.
  TextColumn get source => text()();

  /// App package or SMS sender ID, if known.
  TextColumn get origin => text().nullable()();

  /// When the device received it, UTC epoch milliseconds.
  IntColumn get receivedAt => integer()();

  /// What became of it.
  TextColumn get status => text()();

  /// Why it was dropped, for dropped captures (the message class).
  TextColumn get dropReason => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  bool get isStrict => true;

  @override
  List<String> get customConstraints => const [
    // One SQL literal; splitting it would read as two list items.
    // ignore: lines_longer_than_80_chars
    "CHECK (source IN ('android_notification', 'android_sms', 'ios_shortcut', 'share', 'paste'))",
    "CHECK (status IN ('parsed', 'dropped', 'unparsed', 'duplicate'))",
  ];
}

/// Links a transaction to every capture that described it (spec §7.6).
@DataClassName('TransactionSourceRow')
@TableIndex(name: 'transaction_sources_transaction', columns: {#transactionId})
class TransactionSources extends Table {
  /// Stable unique id.
  TextColumn get id => text()();

  /// The transaction.
  TextColumn get transactionId =>
      text().references(Transactions, #id, onDelete: KeyAction.cascade)();

  /// The capture.
  TextColumn get rawCaptureId =>
      text().references(RawCaptures, #id, onDelete: KeyAction.cascade)();

  /// Copy of the capture's source.
  TextColumn get source => text()();

  /// Copy of the capture's origin.
  TextColumn get origin => text().nullable()();

  /// When the capture was received, UTC epoch milliseconds.
  IntColumn get receivedAt => integer()();

  /// The original message, kept for re-parsing until the retention purge
  /// (Phase 8). Never logged.
  TextColumn get rawText => text().nullable()();

  /// The parser template that read it.
  TextColumn get parserTemplateId => text().nullable()();

  /// The parser's confidence, 0–1.
  RealColumn get confidence => real().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  bool get isStrict => true;
}

/// Messages with an amount that could not be understood (spec §7.8).
@DataClassName('UnparsedRow')
class UnparsedMessages extends Table {
  @override
  String get tableName => 'unparsed';

  /// Stable unique id.
  TextColumn get id => text()();

  /// The capture it came from.
  TextColumn get rawCaptureId =>
      text().references(RawCaptures, #id, onDelete: KeyAction.cascade)();

  /// The message with UPI ids, account and reference numbers masked.
  TextColumn get maskedText => text()();

  /// When it was received, UTC epoch milliseconds.
  IntColumn get receivedAt => integer()();

  /// The transaction the user made from it, once resolved.
  TextColumn get resolvedTransactionId => text().nullable().references(
    Transactions,
    #id,
    onDelete: KeyAction.setNull,
  )();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  bool get isStrict => true;
}
