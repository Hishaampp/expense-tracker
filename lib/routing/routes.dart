/// Every location in the app. Call sites use these, never a path literal.
abstract final class Routes {
  /// Home (month view).
  static const String home = '/';

  /// Activity: every transaction in a month.
  static const String activity = '/activity';

  /// Rooms.
  static const String rooms = '/rooms';

  /// Settings.
  static const String settings = '/settings';

  /// Quick Add, for a new expense.
  static const String addExpense = '/add';

  /// Quick Add for shared text, by pending-capture id.
  static const String sharedPattern = '/add/shared/:id';

  /// Quick Add for the shared text held under [id].
  static String shared(String id) => '/add/shared/$id';

  /// Settings → Auto-capture.
  static const String autoCapture = '/settings/auto-capture';

  /// The iPhone auto-capture setup guide.
  static const String iphoneSetup = '/settings/auto-capture/iphone';

  /// The review inbox.
  static const String review = '/review';

  /// The Unparsed messages list.
  static const String unparsed = '/unparsed';

  /// Path pattern of Quick Add resolving an Unparsed message.
  static const String resolveUnparsedPattern = '/unparsed/:id';

  /// Quick Add resolving the Unparsed message [id].
  static String resolveUnparsed(String id) => '/unparsed/$id';

  /// Path pattern of the expense editor.
  static const String transactionPattern = '/transactions/:id';

  /// The editor for the transaction with [id].
  static String transaction(String id) => '/transactions/$id';
}
