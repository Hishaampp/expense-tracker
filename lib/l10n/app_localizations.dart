import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get navActivity;

  /// No description provided for @navRooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get navRooms;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpense;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get selected;

  /// No description provided for @changeMonth.
  ///
  /// In en, this message translates to:
  /// **'Change month, {month}'**
  String changeMonth(String month);

  /// No description provided for @pickMonthTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a month'**
  String get pickMonthTitle;

  /// No description provided for @heroGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi!'**
  String get heroGreeting;

  /// No description provided for @heroSpentThisMonth.
  ///
  /// In en, this message translates to:
  /// **'You\'ve spent {amount} this month.'**
  String heroSpentThisMonth(String amount);

  /// No description provided for @heroSpentSince.
  ///
  /// In en, this message translates to:
  /// **'You\'ve spent {amount} since {date}.'**
  String heroSpentSince(String amount, String date);

  /// No description provided for @heroSpentIn.
  ///
  /// In en, this message translates to:
  /// **'You spent {amount} in {month}.'**
  String heroSpentIn(String amount, String month);

  /// No description provided for @heroMoneyIn.
  ///
  /// In en, this message translates to:
  /// **'Money in'**
  String get heroMoneyIn;

  /// No description provided for @heroDailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily average'**
  String get heroDailyAverage;

  /// No description provided for @heroInRooms.
  ///
  /// In en, this message translates to:
  /// **'In Rooms'**
  String get heroInRooms;

  /// No description provided for @heroPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get heroPayments;

  /// No description provided for @heroPaymentsValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{None yet} =1{1 payment} other{{count} payments}}'**
  String heroPaymentsValue(int count);

  /// No description provided for @heroMoneyInSemantics.
  ///
  /// In en, this message translates to:
  /// **'{amount} money in'**
  String heroMoneyInSemantics(String amount);

  /// No description provided for @heroDailyAverageSemantics.
  ///
  /// In en, this message translates to:
  /// **'Daily average {amount}'**
  String heroDailyAverageSemantics(String amount);

  /// No description provided for @heroInRoomsSemantics.
  ///
  /// In en, this message translates to:
  /// **'{amount} spent in Rooms'**
  String heroInRoomsSemantics(String amount);

  /// No description provided for @seeAllActivity.
  ///
  /// In en, this message translates to:
  /// **'See all activity'**
  String get seeAllActivity;

  /// No description provided for @homeTopCategories.
  ///
  /// In en, this message translates to:
  /// **'Top categories'**
  String get homeTopCategories;

  /// No description provided for @homeRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get homeRecent;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first expense and this month comes to life.'**
  String get homeEmptyBody;

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityTitle;

  /// No description provided for @activityEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing in {month}'**
  String activityEmptyTitle(String month);

  /// No description provided for @activityEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Expenses you add for this month show up here.'**
  String get activityEmptyBody;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daySpent.
  ///
  /// In en, this message translates to:
  /// **'{amount} spent'**
  String daySpent(String amount);

  /// No description provided for @uncategorised.
  ///
  /// In en, this message translates to:
  /// **'Uncategorised'**
  String get uncategorised;

  /// No description provided for @moneyIn.
  ///
  /// In en, this message translates to:
  /// **'Money in'**
  String get moneyIn;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @refund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get refund;

  /// No description provided for @rowSpentSemantics.
  ///
  /// In en, this message translates to:
  /// **'{amount} spent, {what}'**
  String rowSpentSemantics(String amount, String what);

  /// No description provided for @rowMoneyInSemantics.
  ///
  /// In en, this message translates to:
  /// **'{amount} money in, {what}'**
  String rowMoneyInSemantics(String amount, String what);

  /// No description provided for @rowTransferSemantics.
  ///
  /// In en, this message translates to:
  /// **'{amount} transfer, {what}'**
  String rowTransferSemantics(String amount, String what);

  /// No description provided for @rowRefundSemantics.
  ///
  /// In en, this message translates to:
  /// **'{amount} refund, {what}'**
  String rowRefundSemantics(String amount, String what);

  /// No description provided for @categorySpentSemantics.
  ///
  /// In en, this message translates to:
  /// **'{amount} spent on {category}'**
  String categorySpentSemantics(String amount, String category);

  /// No description provided for @roomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get roomsTitle;

  /// No description provided for @roomsComingTitle.
  ///
  /// In en, this message translates to:
  /// **'Trips and events, together'**
  String get roomsComingTitle;

  /// No description provided for @roomsComingBody.
  ///
  /// In en, this message translates to:
  /// **'Rooms arrive in a coming update. A Room keeps a trip\'s or a wedding\'s spending together, and it still counts in your month.'**
  String get roomsComingBody;

  /// No description provided for @quickAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get quickAddTitle;

  /// No description provided for @quickAddEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get quickAddEditTitle;

  /// No description provided for @quickAddAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get quickAddAmountHint;

  /// No description provided for @quickAddPickCategory.
  ///
  /// In en, this message translates to:
  /// **'Tap a category to save'**
  String get quickAddPickCategory;

  /// No description provided for @quickAddAmountSemantics.
  ///
  /// In en, this message translates to:
  /// **'Amount {amount}'**
  String quickAddAmountSemantics(String amount);

  /// No description provided for @quickAddCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get quickAddCash;

  /// No description provided for @quickAddToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get quickAddToday;

  /// No description provided for @quickAddDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String quickAddDateLabel(String date);

  /// No description provided for @quickAddNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get quickAddNote;

  /// No description provided for @quickAddNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note: {note}'**
  String quickAddNoteLabel(String note);

  /// No description provided for @quickAddNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Chai with Ravi'**
  String get quickAddNoteHint;

  /// No description provided for @quickAddMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get quickAddMore;

  /// No description provided for @quickAddAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get quickAddAllCategories;

  /// No description provided for @quickAddSaved.
  ///
  /// In en, this message translates to:
  /// **'{amount} added'**
  String quickAddSaved(String amount);

  /// No description provided for @quickAddUpdated.
  ///
  /// In en, this message translates to:
  /// **'Expense updated'**
  String get quickAddUpdated;

  /// No description provided for @quickAddDeleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted'**
  String get quickAddDeleted;

  /// No description provided for @quickAddMissing.
  ///
  /// In en, this message translates to:
  /// **'This expense no longer exists.'**
  String get quickAddMissing;

  /// No description provided for @quickAddBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get quickAddBack;

  /// No description provided for @keypadBackspace.
  ///
  /// In en, this message translates to:
  /// **'Backspace'**
  String get keypadBackspace;

  /// No description provided for @keypadPoint.
  ///
  /// In en, this message translates to:
  /// **'Decimal point'**
  String get keypadPoint;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionMonth.
  ///
  /// In en, this message translates to:
  /// **'Your month'**
  String get settingsSectionMonth;

  /// No description provided for @settingsSectionLook.
  ///
  /// In en, this message translates to:
  /// **'Look'**
  String get settingsSectionLook;

  /// No description provided for @settingsMonthStart.
  ///
  /// In en, this message translates to:
  /// **'Month starts on'**
  String get settingsMonthStart;

  /// No description provided for @settingsMonthStartValue.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String settingsMonthStartValue(int day);

  /// No description provided for @settingsMonthStartSemantics.
  ///
  /// In en, this message translates to:
  /// **'Month starts on day {day}'**
  String settingsMonthStartSemantics(int day);

  /// No description provided for @settingsMonthStartHelp.
  ///
  /// In en, this message translates to:
  /// **'Pick your salary day to make each month run from one salary to the next.'**
  String get settingsMonthStartHelp;

  /// No description provided for @settingsMonthStartSaved.
  ///
  /// In en, this message translates to:
  /// **'Month now starts on day {day}'**
  String settingsMonthStartSaved(int day);

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsAppearanceSemantics.
  ///
  /// In en, this message translates to:
  /// **'Appearance, {mode}'**
  String settingsAppearanceSemantics(String mode);

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @notFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'This page doesn\'t exist.'**
  String get notFoundTitle;

  /// No description provided for @notFoundAction.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get notFoundAction;

  /// No description provided for @failureStoreWrite.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Try again.'**
  String get failureStoreWrite;

  /// No description provided for @failureStoreMissing.
  ///
  /// In en, this message translates to:
  /// **'This record no longer exists.'**
  String get failureStoreMissing;

  /// No description provided for @failureLoad.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this. Try again.'**
  String get failureLoad;

  /// No description provided for @quickAddPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste a payment message'**
  String get quickAddPaste;

  /// No description provided for @quickAddIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Add money in'**
  String get quickAddIncomeTitle;

  /// No description provided for @quickAddRefundTitle.
  ///
  /// In en, this message translates to:
  /// **'Add refund'**
  String get quickAddRefundTitle;

  /// No description provided for @quickAddFromMessage.
  ///
  /// In en, this message translates to:
  /// **'From a message'**
  String get quickAddFromMessage;

  /// No description provided for @quickAddFromMessageSemantics.
  ///
  /// In en, this message translates to:
  /// **'Filled from a message: {payee}, {details}'**
  String quickAddFromMessageSemantics(String payee, String details);

  /// No description provided for @quickAddPaymentFallback.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get quickAddPaymentFallback;

  /// No description provided for @noticeClipboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Copy a bank or UPI message first, then tap Paste.'**
  String get noticeClipboardEmpty;

  /// No description provided for @noticeNoAmount.
  ///
  /// In en, this message translates to:
  /// **'There\'s no amount in the copied text.'**
  String get noticeNoAmount;

  /// No description provided for @noticeDuplicate.
  ///
  /// In en, this message translates to:
  /// **'That payment is already added.'**
  String get noticeDuplicate;

  /// No description provided for @noticeUnparsed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read that message. It\'s saved under Unparsed messages in Settings.'**
  String get noticeUnparsed;

  /// No description provided for @noticeNotPayment.
  ///
  /// In en, this message translates to:
  /// **'That isn\'t a payment: {reason}.'**
  String noticeNotPayment(String reason);

  /// No description provided for @reasonOtp.
  ///
  /// In en, this message translates to:
  /// **'it\'s a one-time password'**
  String get reasonOtp;

  /// No description provided for @reasonPromo.
  ///
  /// In en, this message translates to:
  /// **'it\'s an offer'**
  String get reasonPromo;

  /// No description provided for @reasonUpcoming.
  ///
  /// In en, this message translates to:
  /// **'it\'s a reminder of a future payment'**
  String get reasonUpcoming;

  /// No description provided for @reasonCollect.
  ///
  /// In en, this message translates to:
  /// **'it\'s a request for money'**
  String get reasonCollect;

  /// No description provided for @reasonBalance.
  ///
  /// In en, this message translates to:
  /// **'it\'s a balance update'**
  String get reasonBalance;

  /// No description provided for @reasonCardBill.
  ///
  /// In en, this message translates to:
  /// **'it\'s a card bill reminder'**
  String get reasonCardBill;

  /// No description provided for @reasonStatement.
  ///
  /// In en, this message translates to:
  /// **'it\'s a statement notice'**
  String get reasonStatement;

  /// No description provided for @reasonFailed.
  ///
  /// In en, this message translates to:
  /// **'the payment failed'**
  String get reasonFailed;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'nothing was paid'**
  String get reasonOther;

  /// No description provided for @unparsedTitle.
  ///
  /// In en, this message translates to:
  /// **'Unparsed messages'**
  String get unparsedTitle;

  /// No description provided for @unparsedRowSemantics.
  ///
  /// In en, this message translates to:
  /// **'Unparsed messages, {count}'**
  String unparsedRowSemantics(int count);

  /// No description provided for @unparsedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to sort out'**
  String get unparsedEmptyTitle;

  /// No description provided for @unparsedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Messages with an amount the app couldn\'t read appear here, so nothing is lost.'**
  String get unparsedEmptyBody;

  /// No description provided for @unparsedHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a message to add it yourself.'**
  String get unparsedHint;

  /// No description provided for @unparsedItemSemantics.
  ///
  /// In en, this message translates to:
  /// **'Message received {date}: {text}'**
  String unparsedItemSemantics(String date, String text);

  /// No description provided for @settingsSectionMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get settingsSectionMessages;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @quickAddFromMessageDetails.
  ///
  /// In en, this message translates to:
  /// **'From a message, {account}'**
  String quickAddFromMessageDetails(String account);

  /// No description provided for @settingsUnparsedCount.
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String settingsUnparsedCount(int count);

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewTitle;

  /// No description provided for @reviewBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} to review'**
  String reviewBadge(int count);

  /// No description provided for @reviewBadgeSemantics.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 payment to review} other{{count} payments to review}}'**
  String reviewBadgeSemantics(int count);

  /// No description provided for @reviewHint.
  ///
  /// In en, this message translates to:
  /// **'Captured automatically. Tap a category to confirm.'**
  String get reviewHint;

  /// No description provided for @reviewConfirmAll.
  ///
  /// In en, this message translates to:
  /// **'Confirm all suggested ({count})'**
  String reviewConfirmAll(int count);

  /// No description provided for @reviewConfirmedAll.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 payment confirmed} other{{count} payments confirmed}}'**
  String reviewConfirmedAll(int count);

  /// No description provided for @reviewTransfer.
  ///
  /// In en, this message translates to:
  /// **'It\'s a transfer'**
  String get reviewTransfer;

  /// No description provided for @reviewSuggested.
  ///
  /// In en, this message translates to:
  /// **'suggested'**
  String get reviewSuggested;

  /// No description provided for @reviewConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed as {category}'**
  String reviewConfirmed(String category);

  /// No description provided for @reviewMarkedTransfer.
  ///
  /// In en, this message translates to:
  /// **'Marked as a transfer'**
  String get reviewMarkedTransfer;

  /// No description provided for @reviewEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get reviewEmptyTitle;

  /// No description provided for @reviewEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Payments captured from your messages wait here until you confirm them.'**
  String get reviewEmptyBody;

  /// No description provided for @reviewPickSemantics.
  ///
  /// In en, this message translates to:
  /// **'Confirm as {category}'**
  String reviewPickSemantics(String category);

  /// No description provided for @reviewPickSuggestedSemantics.
  ///
  /// In en, this message translates to:
  /// **'Confirm as {category}, suggested'**
  String reviewPickSuggestedSemantics(String category);

  /// No description provided for @reviewUnknownPayee.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get reviewUnknownPayee;

  /// No description provided for @autoCaptureTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-capture'**
  String get autoCaptureTitle;

  /// No description provided for @autoCaptureRowOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get autoCaptureRowOn;

  /// No description provided for @autoCaptureRowOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get autoCaptureRowOff;

  /// No description provided for @autoCaptureRowSemantics.
  ///
  /// In en, this message translates to:
  /// **'Auto-capture, {state}'**
  String autoCaptureRowSemantics(String state);

  /// No description provided for @autoCaptureOnTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-capture is on'**
  String get autoCaptureOnTitle;

  /// No description provided for @autoCaptureOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-capture is off'**
  String get autoCaptureOffTitle;

  /// No description provided for @autoCaptureLastCapture.
  ///
  /// In en, this message translates to:
  /// **'Last payment captured {when}'**
  String autoCaptureLastCapture(String when);

  /// No description provided for @autoCaptureNever.
  ///
  /// In en, this message translates to:
  /// **'No payments captured yet'**
  String get autoCaptureNever;

  /// No description provided for @autoCaptureDisclosureTitle.
  ///
  /// In en, this message translates to:
  /// **'What the app reads'**
  String get autoCaptureDisclosureTitle;

  /// No description provided for @autoCaptureDisclosureBody.
  ///
  /// In en, this message translates to:
  /// **'To record payments for you, the app reads new notifications from your SMS app and the UPI apps listed below. It keeps only messages that contain a rupee amount, and ignores everything else, including personal chats. Everything stays on this phone: nothing is uploaded or shared.'**
  String get autoCaptureDisclosureBody;

  /// No description provided for @autoCaptureLimitations.
  ///
  /// In en, this message translates to:
  /// **'Capture starts from the moment you turn it on. Notifications you swipe away while it is off, or that your phone\'s battery saver blocks, can be missed.'**
  String get autoCaptureLimitations;

  /// No description provided for @autoCaptureTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on auto-capture'**
  String get autoCaptureTurnOn;

  /// No description provided for @autoCaptureManage.
  ///
  /// In en, this message translates to:
  /// **'Notification access settings'**
  String get autoCaptureManage;

  /// No description provided for @autoCaptureRestrictedTitle.
  ///
  /// In en, this message translates to:
  /// **'If Android says the setting is restricted'**
  String get autoCaptureRestrictedTitle;

  /// No description provided for @autoCaptureRestrictedBody.
  ///
  /// In en, this message translates to:
  /// **'Apps installed outside the Play Store need one extra step: open App info, tap the ⋮ menu, choose Allow restricted settings, then come back and turn auto-capture on.'**
  String get autoCaptureRestrictedBody;

  /// No description provided for @autoCaptureOpenAppInfo.
  ///
  /// In en, this message translates to:
  /// **'Open App info'**
  String get autoCaptureOpenAppInfo;

  /// No description provided for @autoCaptureBatteryTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep it running'**
  String get autoCaptureBatteryTitle;

  /// No description provided for @autoCaptureBatteryOpen.
  ///
  /// In en, this message translates to:
  /// **'Open battery settings'**
  String get autoCaptureBatteryOpen;

  /// No description provided for @oemXiaomi.
  ///
  /// In en, this message translates to:
  /// **'On Xiaomi, Redmi and POCO: App info → Autostart on, and Battery saver → No restrictions.'**
  String get oemXiaomi;

  /// No description provided for @oemVivo.
  ///
  /// In en, this message translates to:
  /// **'On Vivo and iQOO: Battery → Background power consumption → Allow, and turn on Auto-start.'**
  String get oemVivo;

  /// No description provided for @oemOppo.
  ///
  /// In en, this message translates to:
  /// **'On Oppo, Realme and OnePlus: App info → Battery usage → Allow background activity, and allow Auto launch.'**
  String get oemOppo;

  /// No description provided for @oemSamsung.
  ///
  /// In en, this message translates to:
  /// **'On Samsung: App info → Battery → Unrestricted, and keep the app out of Sleeping apps.'**
  String get oemSamsung;

  /// No description provided for @oemOther.
  ///
  /// In en, this message translates to:
  /// **'Set the app\'s battery use to Unrestricted, so Android does not stop it in the background.'**
  String get oemOther;

  /// No description provided for @autoCaptureSourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Apps it reads'**
  String get autoCaptureSourcesTitle;

  /// No description provided for @autoCaptureYourSmsApp.
  ///
  /// In en, this message translates to:
  /// **'Your SMS app'**
  String get autoCaptureYourSmsApp;

  /// No description provided for @autoCaptureSourceSemantics.
  ///
  /// In en, this message translates to:
  /// **'{app}, {state}'**
  String autoCaptureSourceSemantics(String app, String state);

  /// No description provided for @autoCaptureSmsTitle.
  ///
  /// In en, this message translates to:
  /// **'Read SMS directly'**
  String get autoCaptureSmsTitle;

  /// No description provided for @autoCaptureSmsBody.
  ///
  /// In en, this message translates to:
  /// **'This build can read bank SMS itself, including past messages, as a backup to notifications.'**
  String get autoCaptureSmsBody;

  /// No description provided for @autoCaptureSmsAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow SMS access'**
  String get autoCaptureSmsAllow;

  /// No description provided for @autoCaptureSmsAllowed.
  ///
  /// In en, this message translates to:
  /// **'SMS access allowed'**
  String get autoCaptureSmsAllowed;

  /// No description provided for @autoCaptureImport.
  ///
  /// In en, this message translates to:
  /// **'Import past messages'**
  String get autoCaptureImport;

  /// No description provided for @autoCaptureImportMonths.
  ///
  /// In en, this message translates to:
  /// **'{months, plural, =1{Last month} other{Last {months} months}}'**
  String autoCaptureImportMonths(int months);

  /// No description provided for @autoCaptureImported.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No bank messages found} =1{1 message imported} other{{count} messages imported}}'**
  String autoCaptureImported(int count);

  /// No description provided for @autoCaptureIosTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-capture on iPhone'**
  String get autoCaptureIosTitle;

  /// No description provided for @autoCaptureIosBody.
  ///
  /// In en, this message translates to:
  /// **'iPhone apps can\'t read SMS. Setup with a Shortcuts automation arrives in a coming update; until then, share or paste bank messages into the app.'**
  String get autoCaptureIosBody;

  /// No description provided for @autoCaptureUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read the auto-capture status on this phone.'**
  String get autoCaptureUnavailable;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{1 minute ago} other{{minutes} minutes ago}}'**
  String timeMinutesAgo(int minutes);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =1{1 hour ago} other{{hours} hours ago}}'**
  String timeHoursAgo(int hours);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{yesterday} other{{days} days ago}}'**
  String timeDaysAgo(int days);

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'off'**
  String get off;

  /// Two short parts of one line, joined by the locale's separator.
  ///
  /// In en, this message translates to:
  /// **'{first}, {second}'**
  String listPair(String first, String second);

  /// No description provided for @reviewSpentSemantics.
  ///
  /// In en, this message translates to:
  /// **'{amount} spent, {payee}, {details}'**
  String reviewSpentSemantics(String amount, String payee, String details);

  /// No description provided for @reviewMoneyInSemantics.
  ///
  /// In en, this message translates to:
  /// **'{amount} money in, {payee}, {details}'**
  String reviewMoneyInSemantics(String amount, String payee, String details);

  /// No description provided for @autoCaptureActionFailed.
  ///
  /// In en, this message translates to:
  /// **'That didn\'t work on this phone. Try again.'**
  String get autoCaptureActionFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
