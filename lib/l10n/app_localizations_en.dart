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

  @override
  String get roomsEmptyTitle => 'Keep a trip\'s spending together';

  @override
  String get roomsEmptyBody =>
      'A Room collects the spending for a trip or a wedding. It still counts in your month, but stays out of your monthly budget.';

  @override
  String get roomsStartTrip => 'Start a trip';

  @override
  String get roomsNew => 'New Room';

  @override
  String get roomsHistory => 'History';

  @override
  String get roomTypeTrip => 'Trip';

  @override
  String get roomTypeWedding => 'Wedding';

  @override
  String get roomTypeEvent => 'Event';

  @override
  String get roomTypeCustom => 'Other';

  @override
  String roomFrom(String date) {
    return 'From $date';
  }

  @override
  String roomRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String roomLeft(String amount, String budget) {
    return '$amount left of $budget';
  }

  @override
  String roomOver(String amount) {
    return 'Over by $amount';
  }

  @override
  String roomCardSemantics(String name, String details, String amount) {
    return '$name, $details, $amount spent';
  }

  @override
  String tripDefaultName(String date) {
    return 'Trip from $date';
  }

  @override
  String get roomNewTitle => 'New Room';

  @override
  String get roomEditTitle => 'Edit Room';

  @override
  String get roomNameLabel => 'Name';

  @override
  String get roomNameHint => 'Goa trip';

  @override
  String get roomNameRequired => 'Give the Room a name';

  @override
  String get roomTypeLabel => 'Type';

  @override
  String get roomEmojiLabel => 'Emoji';

  @override
  String get roomNoEmoji => 'None';

  @override
  String roomEmojiSemantics(String emoji) {
    return 'Emoji $emoji';
  }

  @override
  String get roomDatesLabel => 'Dates';

  @override
  String get roomStartLabel => 'Start';

  @override
  String get roomEndLabel => 'End';

  @override
  String get roomPickDate => 'Pick a date';

  @override
  String get roomNoEnd => 'Still going';

  @override
  String roomStartValue(String date) {
    return 'Start: $date';
  }

  @override
  String roomEndValue(String date) {
    return 'End: $date';
  }

  @override
  String get roomClearEnd => 'Clear the end date';

  @override
  String get roomStartRequired => 'A trip needs a start date';

  @override
  String get roomEndBeforeStart => 'The end can\'t be before the start';

  @override
  String get roomWindowNeedsStart =>
      'Set a start date to add every expense in the dates';

  @override
  String get roomBudgetLabel => 'Budget (optional)';

  @override
  String get roomBudgetHint => 'Amount in ₹';

  @override
  String get roomModeLabel => 'Adding expenses';

  @override
  String get roomModeDateWindow => 'Every expense in the dates';

  @override
  String get roomModeSuggest => 'Ask me each time';

  @override
  String get roomModeManual => 'Only when I add them';

  @override
  String get roomModeTripNote =>
      'Every expense between the dates goes into the trip.';

  @override
  String get roomModeWeddingNote =>
      'You\'ll be asked about each expense. Nothing is added on its own.';

  @override
  String get roomCountsInBudget => 'Count in my monthly budget';

  @override
  String get roomCountsInBudgetNote =>
      'When off, this Room\'s spending shows in your month but stays out of your monthly budget.';

  @override
  String roomHeroSpent(String amount, String name) {
    return 'You\'ve spent $amount on $name.';
  }

  @override
  String get roomPerDay => 'Per day';

  @override
  String get roomDays => 'Days';

  @override
  String get roomBudget => 'Budget';

  @override
  String get roomWhereItWent => 'Where it went';

  @override
  String get roomAddExpense => 'Add expense';

  @override
  String get roomEndTrip => 'End trip today';

  @override
  String get roomArchive => 'Move to history';

  @override
  String get roomRestore => 'Move back to active';

  @override
  String get roomEmptyTitle => 'Nothing here yet';

  @override
  String get roomEmptyBody => 'Expenses you add to this Room show up here.';

  @override
  String get roomMissing => 'This Room no longer exists.';

  @override
  String get roomEdit => 'Edit Room';

  @override
  String get roomArchived => 'Moved to history';

  @override
  String get roomRestored => 'Back in active Rooms';

  @override
  String get quickAddNoRoom => 'No Room';

  @override
  String quickAddRoomLabel(String name) {
    return 'Room: $name';
  }

  @override
  String get quickAddPickRoom => 'Add to a Room';

  @override
  String reviewAddToRoom(String name) {
    return 'Add to $name?';
  }

  @override
  String reviewInRoom(String name) {
    return 'In $name';
  }

  @override
  String reviewAddedToRoom(String name) {
    return 'Added to $name';
  }

  @override
  String get homeRoomsLabel => 'Active Rooms';

  @override
  String get homeStartTrip => 'Start trip';

  @override
  String get navStats => 'Stats';

  @override
  String get budgetsTitle => 'Budgets';

  @override
  String get budgetsMonthly => 'Monthly budget';

  @override
  String get budgetsNotSet => 'Not set';

  @override
  String get budgetsMonthlyHelp =>
      'Covers everyday spending. Rooms stay out unless you count them in.';

  @override
  String get budgetsSetMonthly => 'Set monthly budget';

  @override
  String get budgetsChange => 'Change';

  @override
  String get budgetsRemove => 'Remove budget';

  @override
  String get budgetsCategories => 'Category budgets';

  @override
  String get budgetsCategoriesHelp =>
      'Get a nudge when one category is used up.';

  @override
  String get budgetsAddCategory => 'Add category budget';

  @override
  String budgetsUsedOf(String spent, String budget) {
    return '$spent of $budget';
  }

  @override
  String budgetsCategorySemantics(String name, String spent, String budget) {
    return '$name: $spent spent of $budget. Change';
  }

  @override
  String budgetsCategoryTitle(String name) {
    return '$name budget';
  }

  @override
  String get budgetsAmountLabel => 'Amount in rupees';

  @override
  String get budgetsAmountInvalid => 'Enter an amount above zero';

  @override
  String get budgetsSave => 'Save';

  @override
  String get budgetsSaved => 'Budget saved';

  @override
  String get budgetsRemoved => 'Budget removed';

  @override
  String get budgetsPickCategory => 'Pick a category';

  @override
  String get budgetsAlerts => 'Alerts';

  @override
  String get budgetsWeeklyReview => 'Sunday weekly review';

  @override
  String get budgetsWeeklyReviewHelp =>
      'A look back at your week, every Sunday at 7 pm.';

  @override
  String get budgetsAlertsHelp =>
      'You get a notification at 80% and 100% of your monthly budget and of each Room budget, and when a category budget is used up.';

  @override
  String get budgetsNotificationsOff =>
      'Notifications are off, so alerts can\'t reach you. You can turn them on in your phone\'s Settings.';

  @override
  String get budgetsOpenWeek => 'See your week';

  @override
  String get homeBudgetSafe => 'Safe to spend today';

  @override
  String homeBudgetLeft(String left, String budget) {
    return '$left left of $budget';
  }

  @override
  String homeBudgetDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: 'Last day of the month',
    );
    return '$_temp0';
  }

  @override
  String homeBudgetSafeSemantics(
    String amount,
    String left,
    String budget,
    int count,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left.',
      one: 'Last day of the month.',
    );
    return 'Safe to spend today: $amount. $left left of $budget. $_temp0';
  }

  @override
  String homeBudgetOver(String amount) {
    return 'Over budget by $amount';
  }

  @override
  String homeBudgetOverBody(String spent, String budget) {
    return 'Spent $spent of $budget this month.';
  }

  @override
  String homeBudgetOverSemantics(String amount, String spent, String budget) {
    return 'Over budget by $amount. Spent $spent of $budget this month.';
  }

  @override
  String homeBudgetPercent(int percent) {
    return '$percent%';
  }

  @override
  String homeBudgetPercentSemantics(int percent) {
    return '$percent% of the monthly budget used';
  }

  @override
  String get homeBudgetSetTitle => 'Set a monthly budget';

  @override
  String get homeBudgetSetBody => 'See what\'s safe to spend each day.';

  @override
  String get homeBudgetSetAction => 'Set budget';

  @override
  String get homeBudgetOpen => 'Open budgets';

  @override
  String homeWatching(String name, String amount) {
    return 'Watching $name: $amount this week';
  }

  @override
  String get statsTitle => 'Stats';

  @override
  String statsDonutSemantics(String amount) {
    return 'Spending by category, $amount in all. The categories are listed below.';
  }

  @override
  String statsShare(int percent) {
    return '$percent%';
  }

  @override
  String statsCategorySemantics(String name, String amount, int percent) {
    return '$name: $amount, $percent% of spending';
  }

  @override
  String get statsByDay => 'Day by day';

  @override
  String statsHighestDay(String amount, String day) {
    return 'Highest: $amount on $day';
  }

  @override
  String statsDailyAverage(String amount) {
    return 'Average $amount a day';
  }

  @override
  String statsByDaySemantics(String amount, String day, String average) {
    return 'Daily spending chart. Highest $amount on $day. Average $average a day.';
  }

  @override
  String get statsByMonth => 'Last 6 months';

  @override
  String statsMonthAverage(String amount) {
    return 'Average $amount a month';
  }

  @override
  String statsMonthBar(String month, String amount) {
    return '$month: $amount';
  }

  @override
  String get statsEmptyTitle => 'Nothing to chart yet';

  @override
  String get statsEmptyBody =>
      'Add or capture a few expenses and your charts appear here.';

  @override
  String get statsWeekTitle => 'Your week';

  @override
  String get statsWeekBody =>
      'This week against last week, and who you paid most.';

  @override
  String get weeklyTitle => 'Your week';

  @override
  String weeklyRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String weeklySpent(String amount) {
    return 'You spent $amount this week.';
  }

  @override
  String weeklyMore(String amount) {
    return '$amount more than last week';
  }

  @override
  String weeklyLess(String amount) {
    return '$amount less than last week';
  }

  @override
  String get weeklySame => 'The same as last week';

  @override
  String weeklyLastWeek(String amount) {
    return 'Last week: $amount';
  }

  @override
  String get weeklyTopCategories => 'Top categories';

  @override
  String get weeklyTopPayees => 'Who you paid most';

  @override
  String weeklyPayeeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payments',
      one: '1 payment',
    );
    return '$_temp0';
  }

  @override
  String weeklyPayeeSemantics(String amount, String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payments',
      one: '1 payment',
    );
    return '$amount paid to $name, $_temp0';
  }

  @override
  String get weeklyEmpty => 'No spending this week.';

  @override
  String weeklyInbox(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payments are waiting in Review.',
      one: '1 payment is waiting in Review.',
      zero: 'Nothing is waiting in Review.',
    );
    return '$_temp0';
  }

  @override
  String get weeklyOpenReview => 'Open Review';

  @override
  String get weeklyWatchTitle => 'One thing to watch next week';

  @override
  String get weeklyWatchHelp =>
      'Pick a category. Home keeps an eye on it for you.';

  @override
  String get weeklyWatchNone => 'Nothing';

  @override
  String weeklyWatchSaved(String name) {
    return 'Watching $name next week';
  }

  @override
  String get weeklyWatchCleared => 'Not watching a category';

  @override
  String get notifyAlertsChannel => 'Budget alerts';

  @override
  String get notifyAlertsChannelInfo => 'When a budget is nearly or fully used';

  @override
  String get notifyWeeklyChannel => 'Weekly review';

  @override
  String get notifyWeeklyChannelInfo => 'Your week, every Sunday evening';

  @override
  String get notifyRoomChannel => 'Add to Room';

  @override
  String get notifyRoomChannelInfo => 'Payments that may belong to a Room';

  @override
  String get notifyAddToRoom => 'Add to Room';

  @override
  String notifyAddTo(String name) {
    return 'Add to $name';
  }

  @override
  String get notifyMonth80Title => '80% of your monthly budget used';

  @override
  String notifyMonth80Body(String left) {
    return '$left left for the rest of the month.';
  }

  @override
  String get notifyMonth100Title => 'Monthly budget used up';

  @override
  String notifySpentOf(String spent, String budget) {
    return 'You\'ve spent $spent of $budget.';
  }

  @override
  String notifyCategoryTitle(String name) {
    return '$name budget used up';
  }

  @override
  String notifyRoom80Title(String name) {
    return '80% of the $name budget used';
  }

  @override
  String notifyRoom100Title(String name) {
    return '$name budget used up';
  }

  @override
  String get notifyWeeklyTitle => 'Your week in money';

  @override
  String get notifyWeeklyBody =>
      'See how the week went, and pick one thing to watch.';

  @override
  String notifyRoomOfferTitle(String amount, String payee) {
    return '$amount at $payee';
  }

  @override
  String notifyRoomOfferTitleNoPayee(String amount) {
    return '$amount captured';
  }

  @override
  String notifyRoomOfferBody(String name) {
    return 'Add it to $name?';
  }

  @override
  String get notifyRoomOfferChoiceBody => 'Add it to a Room?';

  @override
  String get settingsBudgets => 'Budgets';

  @override
  String settingsBudgetsSemantics(String value) {
    return 'Budgets, $value';
  }

  @override
  String get noticesTitle => 'Notifications';

  @override
  String get noticesButton => 'Notifications';

  @override
  String noticesButtonUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Notifications, $count new',
      one: 'Notifications, 1 new',
    );
    return '$_temp0';
  }

  @override
  String get noticesEmptyTitle => 'No notifications yet';

  @override
  String get noticesEmptyBody =>
      'Budget alerts, your Sunday review and Room suggestions will appear here.';

  @override
  String get noticesNew => 'New';

  @override
  String noticesItemSemantics(String title, String body, String time) {
    return '$title. $body. $time';
  }

  @override
  String noticesItemUnreadSemantics(String title, String body, String time) {
    return 'New: $title. $body. $time';
  }

  @override
  String get noticesKeptFor => 'Kept for 60 days.';

  @override
  String reviewConfirmedLearned(String payee, String category) {
    return '$payee will always go to $category';
  }

  @override
  String reviewConfirmedLearnedMore(String payee, String category, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more payments',
      one: '1 more payment',
    );
    return '$payee will always go to $category. $_temp0 from them confirmed too.';
  }

  @override
  String reviewConfirmedMany(int count, String category) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payments',
      one: '1 payment',
    );
    return '$_temp0 confirmed as $category';
  }

  @override
  String reviewLearn(String payee) {
    return 'Always use this category for $payee';
  }

  @override
  String get reviewSelect => 'Select payments';

  @override
  String get reviewSelectStop => 'Stop selecting';

  @override
  String reviewSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
      zero: 'Tap payments to select them',
    );
    return '$_temp0';
  }

  @override
  String get reviewChooseCategory => 'Choose category';

  @override
  String get payeesTitle => 'Payees & rules';

  @override
  String get payeesHelp =>
      'Name a payee once and teach it a category or a Room. New payments from them follow it.';

  @override
  String get payeesEmptyTitle => 'No payees yet';

  @override
  String get payeesEmptyBody =>
      'Payees appear here once captured payments arrive.';

  @override
  String get payeesNoRule => 'No rule';

  @override
  String payeesRuleCategory(String category) {
    return 'Always $category';
  }

  @override
  String payeesRuleRoom(String room) {
    return 'Goes to $room';
  }

  @override
  String payeesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payments',
      one: '1 payment',
    );
    return '$_temp0';
  }

  @override
  String payeesRowSemantics(String name, String rule, String payments) {
    return '$name. $rule. $payments. Edit';
  }

  @override
  String get payeesNameLabel => 'Name';

  @override
  String get payeesNameHint => 'For example, Sharma Dairy';

  @override
  String get payeesCategory => 'Category';

  @override
  String get payeesAskEachTime => 'Ask each time';

  @override
  String get payeesRoom => 'Room';

  @override
  String get payeesNoRoom => 'No Room';

  @override
  String get payeesSave => 'Save';

  @override
  String get payeesForget => 'Forget this payee\'s rule';

  @override
  String payeesSaved(String name) {
    return 'Saved for $name';
  }

  @override
  String get payeesForgotten => 'Rule removed';

  @override
  String get payeesPickCategory => 'Always use';

  @override
  String get payeesPickRoom => 'Always add to';

  @override
  String get settingsPayees => 'Payees & rules';

  @override
  String get settingsPayeesSemantics => 'Payees and rules';

  @override
  String get activitySearchHint => 'Search payee, note or amount';

  @override
  String get activityClearSearch => 'Clear search';

  @override
  String get activityFilterCategory => 'Category';

  @override
  String get activityFilterRoom => 'Room';

  @override
  String get activityFilterAccount => 'Account';

  @override
  String get activityFilterKind => 'Type';

  @override
  String get activityFilterSource => 'Source';

  @override
  String get activityAny => 'Any';

  @override
  String activityFilterSemantics(String name, String value) {
    return '$name: $value';
  }

  @override
  String get kindSpent => 'Spent';

  @override
  String get kindMoneyIn => 'Money in';

  @override
  String get kindTransfer => 'Transfer';

  @override
  String get kindRefund => 'Refund';

  @override
  String get sourceManual => 'Typed in';

  @override
  String get sourceAuto => 'Captured';

  @override
  String get activityNoMatchTitle => 'Nothing matches';

  @override
  String get activityNoMatchBody => 'Try another word, or clear the filters.';

  @override
  String get activityClearFilters => 'Clear filters';

  @override
  String get activitySearchingAll => 'searching the last 12 months';

  @override
  String activityResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get onboardCaptureTitle => 'Every payment, written down for you';

  @override
  String get onboardCaptureBody =>
      'UPI, card and bank payments are read from your bank\'s messages and notifications. You just pick a category, or let the app learn it.';

  @override
  String get onboardRoomsTitle => 'Rooms for trips and weddings';

  @override
  String get onboardRoomsBody =>
      'Start a trip in one tap. A Goa weekend or a family wedding gets its own total, without wrecking your month.';

  @override
  String get onboardBudgetTitle => 'Know what\'s safe to spend';

  @override
  String get onboardBudgetBody =>
      'Set a monthly budget and see each day what you can still spend, with a nudge before you run out.';

  @override
  String get onboardPrivacyTitle => 'Your money stays on your phone';

  @override
  String get onboardPrivacyNoAccount => 'No account needed';

  @override
  String get onboardPrivacyNoInternet =>
      'Nothing leaves your phone unless you turn on sync, and then it\'s locked first';

  @override
  String get onboardPrivacyNoAds => 'No ads, and no one reads your messages';

  @override
  String get onboardSetupTitle => 'Turn on auto-capture';

  @override
  String get onboardSetupBody =>
      'Takes about two minutes. You can also do it later from Settings.';

  @override
  String get onboardSetupAction => 'Set up now';

  @override
  String get onboardMonthlyTitle => 'Set a monthly budget';

  @override
  String get onboardMonthlyBody => 'Optional. Rooms like trips stay out of it.';

  @override
  String get onboardNext => 'Next';

  @override
  String get onboardSkip => 'Skip';

  @override
  String get onboardStart => 'Start';

  @override
  String onboardStep(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String budgetsCategoryOverSemantics(
    String name,
    String spent,
    String budget,
    String over,
  ) {
    return '$name: $spent spent of $budget, over by $over. Change';
  }

  @override
  String get lockTitle => 'Locked';

  @override
  String get lockBody => 'Your expenses stay private until you unlock.';

  @override
  String get lockUnlock => 'Unlock';

  @override
  String get lockReason => 'Unlock to see your expenses';

  @override
  String get lockEnableReason => 'Confirm it\'s you to turn on the app lock';

  @override
  String get settingsSectionPrivacy => 'Privacy & data';

  @override
  String get settingsAppLock => 'Lock with Face ID, fingerprint or passcode';

  @override
  String get settingsAppLockUnavailable =>
      'Set a screen lock on your phone first.';

  @override
  String get settingsRetention => 'Keep message text';

  @override
  String settingsRetentionSemantics(String value) {
    return 'Keep message text, $value';
  }

  @override
  String get retentionNever => 'Don\'t keep';

  @override
  String get retentionDays30 => '30 days';

  @override
  String get retentionForever => 'Until I delete it';

  @override
  String get retentionHelp =>
      'The original bank message is kept so a payment can be read again if the app gets better at it. Amounts and payees stay either way.';

  @override
  String get settingsBackup => 'Backup & export';

  @override
  String get settingsBackupSemantics => 'Backup and export';

  @override
  String get failureBackupPassword =>
      'That password doesn\'t open this backup.';

  @override
  String get failureBackupNotBackup =>
      'This file isn\'t a backup from this app.';

  @override
  String get failureBackupTooNew =>
      'This backup is from a newer version of the app. Update the app, then try again.';

  @override
  String get failureBackupFile =>
      'The file couldn\'t be saved or read. Try again.';

  @override
  String get backupTitle => 'Backup & export';

  @override
  String get backupCardTitle => 'Encrypted backup';

  @override
  String get backupCardBody =>
      'Saves everything into one file locked with a password. Keep it in Files, Google Drive or iCloud. Without the password no one can open it, not even you, so write it down somewhere safe.';

  @override
  String get backupCreate => 'Create backup';

  @override
  String get backupRestoreTitle => 'Restore from a backup';

  @override
  String get backupRestoreBody =>
      'Replaces everything on this phone with what\'s in the backup file.';

  @override
  String get backupRestoreChoose => 'Choose backup file';

  @override
  String get backupCsvTitle => 'Export to a spreadsheet';

  @override
  String get backupCsvBody =>
      'A CSV file of every payment, for Excel or Google Sheets. It is not encrypted: anyone who gets the file can read it.';

  @override
  String get backupCsvExport => 'Export CSV';

  @override
  String get backupPasswordNew => 'Set a backup password';

  @override
  String get backupPasswordOpen => 'Backup password';

  @override
  String get backupPasswordLabel => 'Password';

  @override
  String get backupPasswordRepeat => 'Repeat password';

  @override
  String backupPasswordShort(int count) {
    return 'Use at least $count characters';
  }

  @override
  String get backupPasswordMismatch => 'The passwords don\'t match';

  @override
  String get backupContinue => 'Continue';

  @override
  String get backupWorking => 'Working on it…';

  @override
  String get backupReady => 'Backup created';

  @override
  String get backupNotShared => 'Backup not saved';

  @override
  String get backupConfirmTitle => 'Replace all data?';

  @override
  String get backupConfirmBody =>
      'Everything on this phone will be replaced by the backup. This can\'t be undone.';

  @override
  String get backupConfirmReplace => 'Replace';

  @override
  String backupRestored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Restored, with $count payments',
      one: 'Restored, with 1 payment',
    );
    return '$_temp0';
  }

  @override
  String get backupCsvReady => 'CSV exported';

  @override
  String get accountTitle => 'Account & sync';

  @override
  String get accountIntroTitle => 'Keep your data on every phone';

  @override
  String get accountIntroBody =>
      'Sign in to sync your expenses between phones and get them back on a new one. Everything is locked on this phone before it\'s sent, so no one else, not even us, can read it. Without an account the app works just the same.';

  @override
  String get accountEmailLabel => 'Email';

  @override
  String get accountSendCode => 'Send code';

  @override
  String accountCodeSent(String email) {
    return 'We sent an email to $email. On this phone, tap the link in it, or type the code from it here.';
  }

  @override
  String get accountCodeLabel => 'Code from the email';

  @override
  String get accountVerify => 'Sign in';

  @override
  String get accountChangeEmail => 'Use another email';

  @override
  String get accountEmailInvalid => 'Enter an email address';

  @override
  String get accountProblemCode =>
      'That code didn\'t work. Check it, or send a new one.';

  @override
  String get accountProblemTooMany =>
      'Too many tries. Wait a minute and try again.';

  @override
  String get accountProblemOffline =>
      'Can\'t reach the server. Check your internet and try again.';

  @override
  String get accountNewKeyTitle => 'Write down your recovery code';

  @override
  String get accountNewKeyBody =>
      'You\'ll need it to see your data on another phone. Keep it somewhere safe, like on paper. No one can recover it for you.';

  @override
  String get accountNewKeySaved => 'I\'ve written it down';

  @override
  String get accountNeedsCodeTitle => 'Enter your recovery code';

  @override
  String get accountNeedsCodeBody =>
      'This account already has data from another phone. Enter the recovery code you wrote down when you set up sync.';

  @override
  String get accountRecoveryLabel => 'Recovery code';

  @override
  String get accountRecoveryWrong =>
      'That code doesn\'t open this account\'s data. Check it and try again.';

  @override
  String get accountUnlock => 'Unlock my data';

  @override
  String accountSignedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String accountLastSynced(String time) {
    return 'Last synced $time';
  }

  @override
  String get accountNeverSynced => 'Not synced yet';

  @override
  String get accountOffline =>
      'Offline: changes will sync when you\'re back online.';

  @override
  String get accountSyncNow => 'Sync now';

  @override
  String get accountShowCode => 'Show recovery code';

  @override
  String get accountShowCodeReason =>
      'Confirm it\'s you to see the recovery code';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get accountSignedOut => 'Signed out. Your data stays on this phone.';

  @override
  String get accountDelete => 'Delete account';

  @override
  String get accountDeleteTitle => 'Delete your account?';

  @override
  String get accountDeleteBody =>
      'Your account and its cloud copy are deleted for good. The data on this phone stays.';

  @override
  String get accountDeleted =>
      'Account deleted. Your data stays on this phone.';

  @override
  String get accountCopy => 'Copy';

  @override
  String get accountCopied => 'Recovery code copied';

  @override
  String get settingsAccount => 'Account & sync';

  @override
  String get settingsAccountOff => 'Off';

  @override
  String settingsAccountSemantics(String value) {
    return 'Account and sync, $value';
  }

  @override
  String get accountContinueApple => 'Continue with Apple';

  @override
  String get accountContinueGoogle => 'Continue with Google';

  @override
  String get accountOrEmail => 'Or use your email';

  @override
  String get onboardPaydayTitle => 'When does your salary come in?';

  @override
  String get onboardPaydayBody =>
      'Your month will run from one salary to the next, so the numbers match your real month. You can change it later in Settings.';

  @override
  String get onboardPaydayFirst => '1st of the month';

  @override
  String get onboardPaydayOther => 'Another day';

  @override
  String get onboardSyncTitle => 'Keep your data safe if you change phones';

  @override
  String get onboardSyncBody =>
      'Optional. Sign in to sync between phones. Your data is locked on this phone before it\'s sent, so no one else can read it.';

  @override
  String get onboardSyncEmail => 'Use email instead';

  @override
  String heroLeftThisMonth(String amount) {
    return 'You have $amount left this month.';
  }

  @override
  String heroLeftSince(String amount, String date) {
    return 'You have $amount left since $date.';
  }

  @override
  String heroShortThisMonth(String amount) {
    return 'You\'ve spent $amount more than you had this month.';
  }

  @override
  String heroShortSince(String amount, String date) {
    return 'You\'ve spent $amount more than you had since $date.';
  }

  @override
  String heroSavedIn(String amount, String month) {
    return 'You saved $amount in $month.';
  }

  @override
  String heroOverspentIn(String amount, String month) {
    return 'You spent $amount more than came in during $month.';
  }

  @override
  String heroBalanceUsed(String spent, String available) {
    return '$spent spent of $available';
  }

  @override
  String get heroSpent => 'Spent';

  @override
  String heroSpentSemantics(String amount) {
    return '$amount spent';
  }

  @override
  String get heroCarried => 'Carried over';

  @override
  String heroCarriedSemantics(String amount) {
    return '$amount carried over from earlier months';
  }

  @override
  String get roomDelete => 'Delete Room';

  @override
  String roomDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get roomDeleteBody =>
      'Kept payments go back into your normal month. This can\'t be undone.';

  @override
  String get roomDeleteKeep => 'Delete the Room, keep its payments';

  @override
  String get roomDeleteAll => 'Delete the Room and its payments';

  @override
  String get roomDeleted => 'Room deleted';
}
