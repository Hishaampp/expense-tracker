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
  String quickAddFromMessageSemantics(String payee, String details) {
    return 'Filled from a message: $payee, $details';
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

  @override
  String quickAddFromMessageDetails(String account) {
    return 'From a message, $account';
  }

  @override
  String settingsUnparsedCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString';
  }

  @override
  String get reviewTitle => 'Review';

  @override
  String reviewBadge(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString to review';
  }

  @override
  String reviewBadgeSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payments to review',
      one: '1 payment to review',
    );
    return '$_temp0';
  }

  @override
  String get reviewHint => 'Captured automatically. Tap a category to confirm.';

  @override
  String reviewConfirmAll(int count) {
    return 'Confirm all suggested ($count)';
  }

  @override
  String reviewConfirmedAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payments confirmed',
      one: '1 payment confirmed',
    );
    return '$_temp0';
  }

  @override
  String get reviewTransfer => 'It\'s a transfer';

  @override
  String get reviewSuggested => 'suggested';

  @override
  String reviewConfirmed(String category) {
    return 'Confirmed as $category';
  }

  @override
  String get reviewMarkedTransfer => 'Marked as a transfer';

  @override
  String get reviewEmptyTitle => 'All caught up';

  @override
  String get reviewEmptyBody =>
      'Payments captured from your messages wait here until you confirm them.';

  @override
  String reviewPickSemantics(String category) {
    return 'Confirm as $category';
  }

  @override
  String reviewPickSuggestedSemantics(String category) {
    return 'Confirm as $category, suggested';
  }

  @override
  String get reviewUnknownPayee => 'Payment';

  @override
  String get autoCaptureTitle => 'Auto-capture';

  @override
  String get autoCaptureRowOn => 'On';

  @override
  String get autoCaptureRowOff => 'Off';

  @override
  String autoCaptureRowSemantics(String state) {
    return 'Auto-capture, $state';
  }

  @override
  String get autoCaptureOnTitle => 'Auto-capture is on';

  @override
  String get autoCaptureOffTitle => 'Auto-capture is off';

  @override
  String autoCaptureLastCapture(String when) {
    return 'Last payment captured $when';
  }

  @override
  String get autoCaptureNever => 'No payments captured yet';

  @override
  String get autoCaptureDisclosureTitle => 'What the app reads';

  @override
  String get autoCaptureDisclosureBody =>
      'To record payments for you, the app reads new notifications from your SMS app and the UPI apps listed below. It keeps only messages that contain a rupee amount, and ignores everything else, including personal chats. Everything stays on this phone: nothing is uploaded or shared.';

  @override
  String get autoCaptureLimitations =>
      'Capture starts from the moment you turn it on. Notifications you swipe away while it is off, or that your phone\'s battery saver blocks, can be missed.';

  @override
  String get autoCaptureTurnOn => 'Turn on auto-capture';

  @override
  String get autoCaptureManage => 'Notification access settings';

  @override
  String get autoCaptureRestrictedTitle =>
      'If Android says the setting is restricted';

  @override
  String get autoCaptureRestrictedBody =>
      'Apps installed outside the Play Store need one extra step: open App info, tap the ⋮ menu, choose Allow restricted settings, then come back and turn auto-capture on.';

  @override
  String get autoCaptureOpenAppInfo => 'Open App info';

  @override
  String get autoCaptureBatteryTitle => 'Keep it running';

  @override
  String get autoCaptureBatteryOpen => 'Open battery settings';

  @override
  String get oemXiaomi =>
      'On Xiaomi, Redmi and POCO: App info → Autostart on, and Battery saver → No restrictions.';

  @override
  String get oemVivo =>
      'On Vivo and iQOO: Battery → Background power consumption → Allow, and turn on Auto-start.';

  @override
  String get oemOppo =>
      'On Oppo, Realme and OnePlus: App info → Battery usage → Allow background activity, and allow Auto launch.';

  @override
  String get oemSamsung =>
      'On Samsung: App info → Battery → Unrestricted, and keep the app out of Sleeping apps.';

  @override
  String get oemOther =>
      'Set the app\'s battery use to Unrestricted, so Android does not stop it in the background.';

  @override
  String get autoCaptureSourcesTitle => 'Apps it reads';

  @override
  String get autoCaptureYourSmsApp => 'Your SMS app';

  @override
  String autoCaptureSourceSemantics(String app, String state) {
    return '$app, $state';
  }

  @override
  String get autoCaptureSmsTitle => 'Read SMS directly';

  @override
  String get autoCaptureSmsBody =>
      'This build can read bank SMS itself, including past messages, as a backup to notifications.';

  @override
  String get autoCaptureSmsAllow => 'Allow SMS access';

  @override
  String get autoCaptureSmsAllowed => 'SMS access allowed';

  @override
  String get autoCaptureImport => 'Import past messages';

  @override
  String autoCaptureImportMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'Last $months months',
      one: 'Last month',
    );
    return '$_temp0';
  }

  @override
  String autoCaptureImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages imported',
      one: '1 message imported',
      zero: 'No bank messages found',
    );
    return '$_temp0';
  }

  @override
  String get autoCaptureIosTitle => 'Auto-capture on iPhone';

  @override
  String get autoCaptureUnavailable =>
      'Couldn\'t read the auto-capture status on this phone.';

  @override
  String get timeJustNow => 'just now';

  @override
  String timeMinutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: 'yesterday',
    );
    return '$_temp0';
  }

  @override
  String get on => 'on';

  @override
  String get off => 'off';

  @override
  String listPair(String first, String second) {
    return '$first, $second';
  }

  @override
  String reviewSpentSemantics(String amount, String payee, String details) {
    return '$amount spent, $payee, $details';
  }

  @override
  String reviewMoneyInSemantics(String amount, String payee, String details) {
    return '$amount money in, $payee, $details';
  }

  @override
  String get autoCaptureActionFailed =>
      'That didn\'t work on this phone. Try again.';

  @override
  String get iosSetupTitle => 'Set up on iPhone';

  @override
  String get iosSetupIntro =>
      'iPhone apps can\'t read SMS, so you make a small automation once. After that, bank messages are recorded without you opening the app.';

  @override
  String iosSetupStep(int number) {
    return 'Step $number';
  }

  @override
  String get iosStep1Title => 'Open Shortcuts';

  @override
  String get iosStep1Body =>
      'In the Shortcuts app, tap Automation, then the + button, and choose Message.';

  @override
  String get iosStep1Action => 'Open Shortcuts';

  @override
  String get iosStep2Title => 'Choose the messages';

  @override
  String get iosStep2Body =>
      'Under Message Contains, type debited. Choose Run Immediately, then tap Next.';

  @override
  String get iosStep3Title => 'Add this app\'s action';

  @override
  String get iosStep3Body =>
      'Search for Log Bank Message, from this app. Tap its Message field and choose Shortcut Input, then Content. Tap Done.';

  @override
  String get iosStep4Title => 'Repeat for spent and credited';

  @override
  String get iosStep4Body =>
      'Make two more automations the same way, with spent and with credited.';

  @override
  String get iosStep5Title => 'Test it';

  @override
  String get iosStep5Body =>
      'Paste a real bank SMS here to check the app can read it. Nothing is saved.';

  @override
  String get iosTestHint => 'Paste a bank SMS';

  @override
  String get iosTestCheck => 'Check';

  @override
  String iosTestParsed(String amount, String direction) {
    return 'Read as $amount $direction';
  }

  @override
  String get iosTestSpent => 'spent';

  @override
  String get iosTestReceived => 'received';

  @override
  String get iosTestRefund => 'refunded';

  @override
  String iosTestNotPayment(String reason) {
    return 'Not a payment, so it would be skipped: $reason.';
  }

  @override
  String get iosTestUnreadable =>
      'The app couldn\'t read this one. It would be kept under Unparsed messages, and the format can be added later.';

  @override
  String get iosTestNoAmount => 'There\'s no amount in this text.';

  @override
  String get iosSetupDone => 'I\'ve set it up';

  @override
  String get iosSetupSaved => 'Auto-capture is set up';

  @override
  String get iosLimitsTitle => 'Good to know';

  @override
  String get iosLimitsBody =>
      'Only new bank SMS are recorded: not past messages, and not UPI app notifications, which iPhone apps can\'t read. It relies on Apple keeping this automation working.';

  @override
  String get iosStatusOn => 'Set up';

  @override
  String get iosStatusOff => 'Not set up yet';

  @override
  String get iosOpenSetup => 'Set up auto-capture';

  @override
  String get iosReviewSetup => 'See setup steps';

  @override
  String get healthTitle => 'Auto-capture may be off';

  @override
  String get healthBody =>
      'No bank messages have arrived from Shortcuts in 5 days.';

  @override
  String get healthAction => 'Check setup';

  @override
  String iosTestParsedPayee(String amount, String direction, String payee) {
    return 'Read as $amount $direction, $payee';
  }
}
