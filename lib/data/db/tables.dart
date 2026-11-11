import 'package:drift/drift.dart';
import 'package:expense_tracker/core/models/account.dart';
import 'package:expense_tracker/core/models/category.dart';
import 'package:expense_tracker/core/models/notice.dart';
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

/// Spending limits (spec §10): the monthly budget has the id `month` and
/// no category; a category budget's id is `category:` + its category id.
@DataClassName('BudgetRow')
class Budgets extends Table {
  /// `month`, or `category:<categoryId>`.
  TextColumn get id => text()();

  /// The category limited; null for the monthly budget.
  TextColumn get categoryId => text().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// The limit in paise, every month.
  IntColumn get amountPaise => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  bool get isStrict => true;

  @override
  List<String> get customConstraints => const [
    'CHECK (amount_paise > 0)',
    // One monthly budget, and at most one per category. One SQL literal.
    // ignore: lines_longer_than_80_chars
    "CHECK ((id = 'month' AND category_id IS NULL) OR (category_id IS NOT NULL AND id = 'category:' || category_id))",
  ];
}

/// Budget alerts already shown, so each threshold fires once (spec §10).
@DataClassName('FiredAlertRow')
class FiredAlerts extends Table {
  /// The alert key, for example `month:20393:80`.
  TextColumn get key => text()();

  /// When it fired, UTC epoch milliseconds.
  IntColumn get firedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {key};

  @override
  bool get isStrict => true;
}

/// The in-app notification inbox: a copy of every notification the app
/// sent (spec §10). Holds only the app's own words, never message text.
@DataClassName('NoticeRow')
@TableIndex(name: 'notices_created_at', columns: {#createdAt})
class Notices extends Table {
  /// Stable id from what it is about, so the same notice is kept once.
  TextColumn get id => text()();

  /// `budget`, `weekly` or `room`.
  TextColumn get kind => textEnum<NoticeKind>()();

  /// The notification's title.
  TextColumn get title => text()();

  /// The notification's text.
  TextColumn get body => text()();

  /// The screen it opens, or null.
  TextColumn get route => text().nullable()();

  /// When it was sent, UTC epoch milliseconds.
  IntColumn get createdAt => integer()();

  /// When the user saw it in the inbox; null while unread.
  IntColumn get readAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  bool get isStrict => true;

  @override
  List<String> get customConstraints => const [
    "CHECK (kind IN ('budget', 'weekly', 'room'))",
  ];
}

/// What the user taught the app about one payee (spec §8, §12): its
/// category, its Room, and the name to show. Matched by exact payee key.
@DataClassName('PayeeRuleRow')
class PayeeRules extends Table {
  /// The normalised payee key, for example a UPI id.
  TextColumn get payeeKey => text()();

  /// The category its payments always get; null asks each time.
  TextColumn get categoryId => text().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// The Room its payments go to while that Room is active; null for none.
  TextColumn get roomId =>
      text().nullable().references(Rooms, #id, onDelete: KeyAction.setNull)();

  /// The name the user gave it ("Sharma Dairy"); null keeps the bank's.
  TextColumn get displayName => text().nullable()();

  /// Last change, UTC epoch milliseconds.
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {payeeKey};

  @override
  bool get isStrict => true;
}

/// Sync's own state on this phone (Phase 9): whether sync is on, where
/// the last pull ended, and a flag while remote changes are applied.
/// Never synced.
@DataClassName('SyncMetaRow')
class SyncMeta extends Table {
  @override
  String get tableName => 'sync_meta';

  /// `enabled`, `cursor` or `applying`.
  TextColumn get key => text()();

  /// Its value.
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};

  @override
  bool get isStrict => true;
}

/// Local changes waiting to be uploaded, one row per record (Phase 9).
/// Filled by triggers (sync.drift) only while sync is on.
@DataClassName('SyncOutboxRow')
class SyncOutbox extends Table {
  @override
  String get tableName => 'sync_outbox';

  /// The table changed, for example `transactions`.
  TextColumn get recordTable => text()();

  /// The changed row's key in that table.
  TextColumn get recordKey => text()();

  /// When it changed, UTC epoch milliseconds.
  IntColumn get changedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {recordTable, recordKey};

  @override
  bool get isStrict => true;
}

/// The time of the newest version of each synced record this phone has
/// seen, for last-edit-wins (Phase 9). Keyed by the opaque record id.
@DataClassName('SyncStateRow')
class SyncState extends Table {
  @override
  String get tableName => 'sync_state';

  /// The opaque record id the server knows.
  TextColumn get recordId => text()();

  /// When that version was made, UTC epoch milliseconds.
  IntColumn get changedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {recordId};

  @override
  bool get isStrict => true;
}
