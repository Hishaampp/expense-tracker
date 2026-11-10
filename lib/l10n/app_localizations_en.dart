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
  String get navActivity => 'Activity';

  @override
  String get navRooms => 'Rooms';

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
  String get addExpense => 'Add expense';

  @override
  String get selected => 'selected';

  @override
  String changeMonth(String month) {
    return 'Change month, $month';
  }

  @override
  String get pickMonthTitle => 'Choose a month';

  @override
  String get heroGreeting => 'Hi!';

  @override
  String heroSpentThisMonth(String amount) {
    return 'You\'ve spent $amount this month.';
  }

  @override
  String heroSpentSince(String amount, String date) {
    return 'You\'ve spent $amount since $date.';
  }

  @override
  String heroSpentIn(String amount, String month) {
    return 'You spent $amount in $month.';
  }

  @override
  String get heroMoneyIn => 'Money in';

  @override
  String get heroDailyAverage => 'Daily average';

  @override
  String get heroInRooms => 'In Rooms';

  @override
  String get heroPayments => 'Payments';

  @override
  String heroPaymentsValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payments',
      one: '1 payment',
      zero: 'None yet',
    );
    return '$_temp0';
  }

  @override
  String heroMoneyInSemantics(String amount) {
    return '$amount money in';
  }

  @override
  String heroDailyAverageSemantics(String amount) {
    return 'Daily average $amount';
  }

  @override
  String heroInRoomsSemantics(String amount) {
    return '$amount spent in Rooms';
  }

  @override
  String get seeAllActivity => 'See all activity';

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
      'Add your first expense and this month comes to life.';

  @override
  String get activityTitle => 'Activity';

  @override
  String activityEmptyTitle(String month) {
    return 'Nothing in $month';
  }

  @override
  String get activityEmptyBody =>
      'Expenses you add for this month show up here.';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

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
  String get roomsTitle => 'Rooms';

  @override
  String get roomsComingTitle => 'Trips and events, together';

  @override
  String get roomsComingBody =>
      'Rooms arrive in a coming update. A Room keeps a trip\'s or a wedding\'s spending together, and it still counts in your month.';

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
  String get quickAddCash => 'Cash';

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
  String get quickAddMore => 'More';

  @override
  String get quickAddAllCategories => 'All categories';

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
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionMonth => 'Your month';

  @override
  String get settingsSectionLook => 'Look';

  @override
  String get settingsMonthStart => 'Month starts on';

  @override
  String settingsMonthStartValue(int day) {
    return 'Day $day';
  }

  @override
  String settingsMonthStartSemantics(int day) {
    return 'Month starts on day $day';
  }

  @override
  String get settingsMonthStartHelp =>
      'Pick your salary day to make each month run from one salary to the next.';

  @override
  String settingsMonthStartSaved(int day) {
    return 'Month now starts on day $day';
  }

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String settingsAppearanceSemantics(String mode) {
    return 'Appearance, $mode';
  }

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get notFoundTitle => 'This page doesn\'t exist.';

  @override
  String get notFoundAction => 'Go to Home';

  @override
  String get failureStoreWrite => 'Couldn\'t save. Try again.';

  @override
  String get failureStoreMissing => 'This record no longer exists.';

  @override
  String get failureLoad => 'Couldn\'t load this. Try again.';

  @override
  String get quickAddPaste => 'Paste a payment message';

  @override
  String get quickAddIncomeTitle => 'Add money in';

  @override
  String get quickAddRefundTitle => 'Add refund';

  @override
  String get quickAddFromMessage => 'From a message';

  @override
  String quickAddFromMessageSemantics(String details) {
    return 'Filled from a message: $details';
  }

  @override
  String get quickAddPaymentFallback => 'Payment';

  @override
  String get noticeClipboardEmpty =>
      'Copy a bank or UPI message first, then tap Paste.';

  @override
  String get noticeNoAmount => 'There\'s no amount in the copied text.';

  @override
  String get noticeDuplicate => 'That payment is already added.';

  @override
  String get noticeUnparsed =>
      'Couldn\'t read that message. It\'s saved under Unparsed messages in Settings.';

  @override
  String noticeNotPayment(String reason) {
    return 'That isn\'t a payment: $reason.';
  }

  @override
  String get reasonOtp => 'it\'s a one-time password';

  @override
  String get reasonPromo => 'it\'s an offer';

  @override
  String get reasonUpcoming => 'it\'s a reminder of a future payment';

  @override
  String get reasonCollect => 'it\'s a request for money';

  @override
  String get reasonBalance => 'it\'s a balance update';

  @override
  String get reasonCardBill => 'it\'s a card bill reminder';

  @override
  String get reasonStatement => 'it\'s a statement notice';

  @override
  String get reasonFailed => 'the payment failed';

  @override
  String get reasonOther => 'nothing was paid';

  @override
  String get unparsedTitle => 'Unparsed messages';

  @override
  String unparsedRowSemantics(int count) {
    return 'Unparsed messages, $count';
  }

  @override
  String get unparsedEmptyTitle => 'Nothing to sort out';

  @override
  String get unparsedEmptyBody =>
      'Messages with an amount the app couldn\'t read appear here, so nothing is lost.';

  @override
  String get unparsedHint => 'Tap a message to add it yourself.';

  @override
  String unparsedItemSemantics(String date, String text) {
    return 'Message received $date: $text';
  }

  @override
  String get settingsSectionMessages => 'Messages';

  @override
  String get back => 'Back';
}
