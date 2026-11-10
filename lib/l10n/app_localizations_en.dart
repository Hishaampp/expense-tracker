// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navSettings => 'Settings';

  @override
  String get loading => 'Loading';

  @override
  String get tryAgain => 'Try again';

  @override
  String get undo => 'Undo';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get delete => 'Delete';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get addExpense => 'Add expense';

  @override
  String get homeSpentLabel => 'Spent this month';

  @override
  String homeIncludesRooms(String amount) {
    return 'includes $amount in Rooms';
  }

  @override
  String homeSpentSemantics(String amount) {
    return '$amount spent this month';
  }

  @override
  String get homeMoneyIn => 'Money in';

  @override
  String homeMoneyInSemantics(String amount) {
    return '$amount money in';
  }

  @override
  String get homeTopCategories => 'Top categories';

  @override
  String get homeRecent => 'Recent';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeEmptyTitle => 'No expenses yet';

  @override
  String get homeEmptyBody =>
      'Add your first expense to see this month\'s spending.';

  @override
  String get transactionsTitle => 'Transactions';

  @override
  String transactionsEmptyTitle(String month) {
    return 'Nothing in $month';
  }

  @override
  String get transactionsEmptyBody =>
      'Expenses you add for this month show up here.';

  @override
  String daySpent(String amount) {
    return '$amount spent';
  }

  @override
  String get uncategorised => 'Uncategorised';

  @override
  String get moneyIn => 'Money in';

  @override
  String get transfer => 'Transfer';

  @override
  String get refund => 'Refund';

  @override
  String rowSpentSemantics(String amount, String what) {
    return '$amount spent, $what';
  }

  @override
  String rowMoneyInSemantics(String amount, String what) {
    return '$amount money in, $what';
  }

  @override
  String rowTransferSemantics(String amount, String what) {
    return '$amount transfer, $what';
  }

  @override
  String rowRefundSemantics(String amount, String what) {
    return '$amount refund, $what';
  }

  @override
  String categorySpentSemantics(String amount, String category) {
    return '$amount spent on $category';
  }

  @override
  String get quickAddTitle => 'Add expense';

  @override
  String get quickAddEditTitle => 'Edit expense';

  @override
  String get quickAddAmountHint => 'Enter an amount';

  @override
  String get quickAddPickCategory => 'Tap a category to save';

  @override
  String quickAddAmountSemantics(String amount) {
    return 'Amount $amount';
  }

  @override
  String get quickAddToday => 'Today';

  @override
  String quickAddDateLabel(String date) {
    return 'Date: $date';
  }

  @override
  String get quickAddNote => 'Note';

  @override
  String quickAddNoteLabel(String note) {
    return 'Note: $note';
  }

  @override
  String get quickAddNoteHint => 'Chai with Ravi';

  @override
  String quickAddSaved(String amount) {
    return '$amount added';
  }

  @override
  String get quickAddUpdated => 'Expense updated';

  @override
  String get quickAddDeleted => 'Expense deleted';

  @override
  String get quickAddMissing => 'This expense no longer exists.';

  @override
  String get quickAddBack => 'Go back';

  @override
  String get keypadBackspace => 'Backspace';

  @override
  String get keypadPoint => 'Decimal point';

  @override
  String get selected => 'selected';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsMonthSection => 'Month';

  @override
  String get settingsMonthStart => 'Month starts on';

  @override
  String settingsMonthStartSemantics(int day) {
    return 'Month starts on day $day';
  }

  @override
  String settingsMonthStartValue(int day) {
    return 'Day $day';
  }

  @override
  String get settingsMonthStartHelp =>
      'Pick your salary day to make each month run from one salary to the next.';

  @override
  String settingsMonthStartSaved(int day) {
    return 'Month now starts on day $day';
  }

  @override
  String get notFoundTitle => 'This page doesn\'t exist';

  @override
  String get notFoundAction => 'Go to Home';

  @override
  String get failureStoreWrite => 'Couldn\'t save. Try again.';

  @override
  String get failureStoreMissing => 'This record no longer exists.';

  @override
  String get failureLoad => 'Couldn\'t load this. Try again.';
}
