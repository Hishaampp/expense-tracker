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

  /// Path pattern of the expense editor.
  static const String transactionPattern = '/transactions/:id';

  /// The editor for the transaction with [id].
  static String transaction(String id) => '/transactions/$id';
}
