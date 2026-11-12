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

  /// No description provided for @iosSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up on iPhone'**
  String get iosSetupTitle;

  /// No description provided for @iosSetupIntro.
  ///
  /// In en, this message translates to:
  /// **'iPhone apps can\'t read SMS, so you make a small automation once. After that, bank messages are recorded without you opening the app.'**
  String get iosSetupIntro;

  /// No description provided for @iosSetupStep.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String iosSetupStep(int number);

  /// No description provided for @iosStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Open Shortcuts'**
  String get iosStep1Title;

  /// No description provided for @iosStep1Body.
  ///
  /// In en, this message translates to:
  /// **'In the Shortcuts app, tap Automation, then the + button, and choose Message.'**
  String get iosStep1Body;

  /// No description provided for @iosStep1Action.
  ///
  /// In en, this message translates to:
  /// **'Open Shortcuts'**
  String get iosStep1Action;

  /// No description provided for @iosStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Choose the messages'**
  String get iosStep2Title;

  /// No description provided for @iosStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Under Message Contains, type debited. Choose Run Immediately, then tap Next.'**
  String get iosStep2Body;

  /// No description provided for @iosStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Add this app\'s action'**
  String get iosStep3Title;

  /// No description provided for @iosStep3Body.
  ///
  /// In en, this message translates to:
  /// **'Search for Log Bank Message, from this app. Tap its Message field and choose Shortcut Input, then Content. Tap Done.'**
  String get iosStep3Body;

  /// No description provided for @iosStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Repeat for spent and credited'**
  String get iosStep4Title;

  /// No description provided for @iosStep4Body.
  ///
  /// In en, this message translates to:
  /// **'Make two more automations the same way, with spent and with credited.'**
  String get iosStep4Body;

  /// No description provided for @iosStep5Title.
  ///
  /// In en, this message translates to:
  /// **'Test it'**
  String get iosStep5Title;

  /// No description provided for @iosStep5Body.
  ///
  /// In en, this message translates to:
  /// **'Paste a real bank SMS here to check the app can read it. Nothing is saved.'**
  String get iosStep5Body;

  /// No description provided for @iosTestHint.
  ///
  /// In en, this message translates to:
  /// **'Paste a bank SMS'**
  String get iosTestHint;

  /// No description provided for @iosTestCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get iosTestCheck;

  /// No description provided for @iosTestParsed.
  ///
  /// In en, this message translates to:
  /// **'Read as {amount} {direction}'**
  String iosTestParsed(String amount, String direction);

  /// No description provided for @iosTestSpent.
  ///
  /// In en, this message translates to:
  /// **'spent'**
  String get iosTestSpent;

  /// No description provided for @iosTestReceived.
  ///
  /// In en, this message translates to:
  /// **'received'**
  String get iosTestReceived;

  /// No description provided for @iosTestRefund.
  ///
  /// In en, this message translates to:
  /// **'refunded'**
  String get iosTestRefund;

  /// No description provided for @iosTestNotPayment.
  ///
  /// In en, this message translates to:
  /// **'Not a payment, so it would be skipped: {reason}.'**
  String iosTestNotPayment(String reason);

  /// No description provided for @iosTestUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The app couldn\'t read this one. It would be kept under Unparsed messages, and the format can be added later.'**
  String get iosTestUnreadable;

  /// No description provided for @iosTestNoAmount.
  ///
  /// In en, this message translates to:
  /// **'There\'s no amount in this text.'**
  String get iosTestNoAmount;

  /// No description provided for @iosSetupDone.
  ///
  /// In en, this message translates to:
  /// **'I\'ve set it up'**
  String get iosSetupDone;

  /// No description provided for @iosSetupSaved.
  ///
  /// In en, this message translates to:
  /// **'Auto-capture is set up'**
  String get iosSetupSaved;

  /// No description provided for @iosLimitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Good to know'**
  String get iosLimitsTitle;

  /// No description provided for @iosLimitsBody.
  ///
  /// In en, this message translates to:
  /// **'Only new bank SMS are recorded: not past messages, and not UPI app notifications, which iPhone apps can\'t read. It relies on Apple keeping this automation working.'**
  String get iosLimitsBody;

  /// No description provided for @iosStatusOn.
  ///
  /// In en, this message translates to:
  /// **'Set up'**
  String get iosStatusOn;

  /// No description provided for @iosStatusOff.
  ///
  /// In en, this message translates to:
  /// **'Not set up yet'**
  String get iosStatusOff;

  /// No description provided for @iosOpenSetup.
  ///
  /// In en, this message translates to:
  /// **'Set up auto-capture'**
  String get iosOpenSetup;

  /// No description provided for @iosReviewSetup.
  ///
  /// In en, this message translates to:
  /// **'See setup steps'**
  String get iosReviewSetup;

  /// No description provided for @healthTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-capture may be off'**
  String get healthTitle;

  /// No description provided for @healthBody.
  ///
  /// In en, this message translates to:
  /// **'No bank messages have arrived from Shortcuts in 5 days.'**
  String get healthBody;

  /// No description provided for @healthAction.
  ///
  /// In en, this message translates to:
  /// **'Check setup'**
  String get healthAction;

  /// No description provided for @iosTestParsedPayee.
  ///
  /// In en, this message translates to:
  /// **'Read as {amount} {direction}, {payee}'**
  String iosTestParsedPayee(String amount, String direction, String payee);

  /// No description provided for @roomsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep a trip\'s spending together'**
  String get roomsEmptyTitle;

  /// No description provided for @roomsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'A Room collects the spending for a trip or a wedding. It still counts in your month, but stays out of your monthly budget.'**
  String get roomsEmptyBody;

  /// No description provided for @roomsStartTrip.
  ///
  /// In en, this message translates to:
  /// **'Start a trip'**
  String get roomsStartTrip;

  /// No description provided for @roomsNew.
  ///
  /// In en, this message translates to:
  /// **'New Room'**
  String get roomsNew;

  /// No description provided for @roomsHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get roomsHistory;

  /// No description provided for @roomTypeTrip.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get roomTypeTrip;

  /// No description provided for @roomTypeWedding.
  ///
  /// In en, this message translates to:
  /// **'Wedding'**
  String get roomTypeWedding;

  /// No description provided for @roomTypeEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get roomTypeEvent;

  /// No description provided for @roomTypeCustom.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get roomTypeCustom;

  /// No description provided for @roomFrom.
  ///
  /// In en, this message translates to:
  /// **'From {date}'**
  String roomFrom(String date);

  /// No description provided for @roomRange.
  ///
  /// In en, this message translates to:
  /// **'{from} – {to}'**
  String roomRange(String from, String to);

  /// No description provided for @roomLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left of {budget}'**
  String roomLeft(String amount, String budget);

  /// No description provided for @roomOver.
  ///
  /// In en, this message translates to:
  /// **'Over by {amount}'**
  String roomOver(String amount);

  /// No description provided for @roomCardSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}, {details}, {amount} spent'**
  String roomCardSemantics(String name, String details, String amount);

  /// No description provided for @tripDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Trip from {date}'**
  String tripDefaultName(String date);

  /// No description provided for @roomNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Room'**
  String get roomNewTitle;

  /// No description provided for @roomEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Room'**
  String get roomEditTitle;

  /// No description provided for @roomNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get roomNameLabel;

  /// No description provided for @roomNameHint.
  ///
  /// In en, this message translates to:
  /// **'Goa trip'**
  String get roomNameHint;

  /// No description provided for @roomNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give the Room a name'**
  String get roomNameRequired;

  /// No description provided for @roomTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get roomTypeLabel;

  /// No description provided for @roomEmojiLabel.
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get roomEmojiLabel;

  /// No description provided for @roomNoEmoji.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get roomNoEmoji;

  /// No description provided for @roomEmojiSemantics.
  ///
  /// In en, this message translates to:
  /// **'Emoji {emoji}'**
  String roomEmojiSemantics(String emoji);

  /// No description provided for @roomDatesLabel.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get roomDatesLabel;

  /// No description provided for @roomStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get roomStartLabel;

  /// No description provided for @roomEndLabel.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get roomEndLabel;

  /// No description provided for @roomPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get roomPickDate;

  /// No description provided for @roomNoEnd.
  ///
  /// In en, this message translates to:
  /// **'Still going'**
  String get roomNoEnd;

  /// No description provided for @roomStartValue.
  ///
  /// In en, this message translates to:
  /// **'Start: {date}'**
  String roomStartValue(String date);

  /// No description provided for @roomEndValue.
  ///
  /// In en, this message translates to:
  /// **'End: {date}'**
  String roomEndValue(String date);

  /// No description provided for @roomClearEnd.
  ///
  /// In en, this message translates to:
  /// **'Clear the end date'**
  String get roomClearEnd;

  /// No description provided for @roomStartRequired.
  ///
  /// In en, this message translates to:
  /// **'A trip needs a start date'**
  String get roomStartRequired;

  /// No description provided for @roomEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'The end can\'t be before the start'**
  String get roomEndBeforeStart;

  /// No description provided for @roomWindowNeedsStart.
  ///
  /// In en, this message translates to:
  /// **'Set a start date to add every expense in the dates'**
  String get roomWindowNeedsStart;

  /// No description provided for @roomBudgetLabel.
  ///
  /// In en, this message translates to:
  /// **'Budget (optional)'**
  String get roomBudgetLabel;

  /// No description provided for @roomBudgetHint.
  ///
  /// In en, this message translates to:
  /// **'Amount in ₹'**
  String get roomBudgetHint;

  /// No description provided for @roomModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Adding expenses'**
  String get roomModeLabel;

  /// No description provided for @roomModeDateWindow.
  ///
  /// In en, this message translates to:
  /// **'Every expense in the dates'**
  String get roomModeDateWindow;

  /// No description provided for @roomModeSuggest.
  ///
  /// In en, this message translates to:
  /// **'Ask me each time'**
  String get roomModeSuggest;

  /// No description provided for @roomModeManual.
  ///
  /// In en, this message translates to:
  /// **'Only when I add them'**
  String get roomModeManual;

  /// No description provided for @roomModeTripNote.
  ///
  /// In en, this message translates to:
  /// **'Every expense between the dates goes into the trip.'**
  String get roomModeTripNote;

  /// No description provided for @roomModeWeddingNote.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be asked about each expense. Nothing is added on its own.'**
  String get roomModeWeddingNote;

  /// No description provided for @roomCountsInBudget.
  ///
  /// In en, this message translates to:
  /// **'Count in my monthly budget'**
  String get roomCountsInBudget;

  /// No description provided for @roomCountsInBudgetNote.
  ///
  /// In en, this message translates to:
  /// **'When off, this Room\'s spending shows in your month but stays out of your monthly budget.'**
  String get roomCountsInBudgetNote;

  /// No description provided for @roomHeroSpent.
  ///
  /// In en, this message translates to:
  /// **'You\'ve spent {amount} on {name}.'**
  String roomHeroSpent(String amount, String name);

  /// No description provided for @roomPerDay.
  ///
  /// In en, this message translates to:
  /// **'Per day'**
  String get roomPerDay;

  /// No description provided for @roomDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get roomDays;

  /// No description provided for @roomBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get roomBudget;

  /// No description provided for @roomWhereItWent.
  ///
  /// In en, this message translates to:
  /// **'Where it went'**
  String get roomWhereItWent;

  /// No description provided for @roomAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get roomAddExpense;

  /// No description provided for @roomEndTrip.
  ///
  /// In en, this message translates to:
  /// **'End trip today'**
  String get roomEndTrip;

  /// No description provided for @roomArchive.
  ///
  /// In en, this message translates to:
  /// **'Move to history'**
  String get roomArchive;

  /// No description provided for @roomRestore.
  ///
  /// In en, this message translates to:
  /// **'Move back to active'**
  String get roomRestore;

  /// No description provided for @roomEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get roomEmptyTitle;

  /// No description provided for @roomEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Expenses you add to this Room show up here.'**
  String get roomEmptyBody;

  /// No description provided for @roomMissing.
  ///
  /// In en, this message translates to:
  /// **'This Room no longer exists.'**
  String get roomMissing;

  /// No description provided for @roomEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Room'**
  String get roomEdit;

  /// No description provided for @roomArchived.
  ///
  /// In en, this message translates to:
  /// **'Moved to history'**
  String get roomArchived;

  /// No description provided for @roomRestored.
  ///
  /// In en, this message translates to:
  /// **'Back in active Rooms'**
  String get roomRestored;

  /// No description provided for @quickAddNoRoom.
  ///
  /// In en, this message translates to:
  /// **'No Room'**
  String get quickAddNoRoom;

  /// No description provided for @quickAddRoomLabel.
  ///
  /// In en, this message translates to:
  /// **'Room: {name}'**
  String quickAddRoomLabel(String name);

  /// No description provided for @quickAddPickRoom.
  ///
  /// In en, this message translates to:
  /// **'Add to a Room'**
  String get quickAddPickRoom;

  /// No description provided for @reviewAddToRoom.
  ///
  /// In en, this message translates to:
  /// **'Add to {name}?'**
  String reviewAddToRoom(String name);

  /// No description provided for @reviewInRoom.
  ///
  /// In en, this message translates to:
  /// **'In {name}'**
  String reviewInRoom(String name);

  /// No description provided for @reviewAddedToRoom.
  ///
  /// In en, this message translates to:
  /// **'Added to {name}'**
  String reviewAddedToRoom(String name);

  /// No description provided for @homeRoomsLabel.
  ///
  /// In en, this message translates to:
  /// **'Active Rooms'**
  String get homeRoomsLabel;

  /// No description provided for @homeStartTrip.
  ///
  /// In en, this message translates to:
  /// **'Start trip'**
  String get homeStartTrip;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @budgetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgetsTitle;

  /// No description provided for @budgetsMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get budgetsMonthly;

  /// No description provided for @budgetsNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get budgetsNotSet;

  /// No description provided for @budgetsMonthlyHelp.
  ///
  /// In en, this message translates to:
  /// **'Covers everyday spending. Rooms stay out unless you count them in.'**
  String get budgetsMonthlyHelp;

  /// No description provided for @budgetsSetMonthly.
  ///
  /// In en, this message translates to:
  /// **'Set monthly budget'**
  String get budgetsSetMonthly;

  /// No description provided for @budgetsChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get budgetsChange;

  /// No description provided for @budgetsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove budget'**
  String get budgetsRemove;

  /// No description provided for @budgetsCategories.
  ///
  /// In en, this message translates to:
  /// **'Category budgets'**
  String get budgetsCategories;

  /// No description provided for @budgetsCategoriesHelp.
  ///
  /// In en, this message translates to:
  /// **'Get a nudge when one category is used up.'**
  String get budgetsCategoriesHelp;

  /// No description provided for @budgetsAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category budget'**
  String get budgetsAddCategory;

  /// No description provided for @budgetsUsedOf.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {budget}'**
  String budgetsUsedOf(String spent, String budget);

  /// No description provided for @budgetsCategorySemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}: {spent} spent of {budget}. Change'**
  String budgetsCategorySemantics(String name, String spent, String budget);

  /// No description provided for @budgetsCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} budget'**
  String budgetsCategoryTitle(String name);

  /// No description provided for @budgetsAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount in rupees'**
  String get budgetsAmountLabel;

  /// No description provided for @budgetsAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above zero'**
  String get budgetsAmountInvalid;

  /// No description provided for @budgetsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get budgetsSave;

  /// No description provided for @budgetsSaved.
  ///
  /// In en, this message translates to:
  /// **'Budget saved'**
  String get budgetsSaved;

  /// No description provided for @budgetsRemoved.
  ///
  /// In en, this message translates to:
  /// **'Budget removed'**
  String get budgetsRemoved;

  /// No description provided for @budgetsPickCategory.
  ///
  /// In en, this message translates to:
  /// **'Pick a category'**
  String get budgetsPickCategory;

  /// No description provided for @budgetsAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get budgetsAlerts;

  /// No description provided for @budgetsWeeklyReview.
  ///
  /// In en, this message translates to:
  /// **'Sunday weekly review'**
  String get budgetsWeeklyReview;

  /// No description provided for @budgetsWeeklyReviewHelp.
  ///
  /// In en, this message translates to:
  /// **'A look back at your week, every Sunday at 7 pm.'**
  String get budgetsWeeklyReviewHelp;

  /// No description provided for @budgetsAlertsHelp.
  ///
  /// In en, this message translates to:
  /// **'You get a notification at 80% and 100% of your monthly budget and of each Room budget, and when a category budget is used up.'**
  String get budgetsAlertsHelp;

  /// No description provided for @budgetsNotificationsOff.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off, so alerts can\'t reach you. You can turn them on in your phone\'s Settings.'**
  String get budgetsNotificationsOff;

  /// No description provided for @budgetsOpenWeek.
  ///
  /// In en, this message translates to:
  /// **'See your week'**
  String get budgetsOpenWeek;

  /// No description provided for @homeBudgetSafe.
  ///
  /// In en, this message translates to:
  /// **'Safe to spend today'**
  String get homeBudgetSafe;

  /// No description provided for @homeBudgetLeft.
  ///
  /// In en, this message translates to:
  /// **'{left} left of {budget}'**
  String homeBudgetLeft(String left, String budget);

  /// No description provided for @homeBudgetDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Last day of the month} other{{count} days left}}'**
  String homeBudgetDays(int count);

  /// No description provided for @homeBudgetSafeSemantics.
  ///
  /// In en, this message translates to:
  /// **'Safe to spend today: {amount}. {left} left of {budget}. {count, plural, =1{Last day of the month.} other{{count} days left.}}'**
  String homeBudgetSafeSemantics(
    String amount,
    String left,
    String budget,
    int count,
  );

  /// No description provided for @homeBudgetOver.
  ///
  /// In en, this message translates to:
  /// **'Over budget by {amount}'**
  String homeBudgetOver(String amount);

  /// No description provided for @homeBudgetOverBody.
  ///
  /// In en, this message translates to:
  /// **'Spent {spent} of {budget} this month.'**
  String homeBudgetOverBody(String spent, String budget);

  /// No description provided for @homeBudgetOverSemantics.
  ///
  /// In en, this message translates to:
  /// **'Over budget by {amount}. Spent {spent} of {budget} this month.'**
  String homeBudgetOverSemantics(String amount, String spent, String budget);

  /// No description provided for @homeBudgetPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String homeBudgetPercent(int percent);

  /// No description provided for @homeBudgetPercentSemantics.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of the monthly budget used'**
  String homeBudgetPercentSemantics(int percent);

  /// No description provided for @homeBudgetSetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly budget'**
  String get homeBudgetSetTitle;

  /// No description provided for @homeBudgetSetBody.
  ///
  /// In en, this message translates to:
  /// **'See what\'s safe to spend each day.'**
  String get homeBudgetSetBody;

  /// No description provided for @homeBudgetSetAction.
  ///
  /// In en, this message translates to:
  /// **'Set budget'**
  String get homeBudgetSetAction;

  /// No description provided for @homeBudgetOpen.
  ///
  /// In en, this message translates to:
  /// **'Open budgets'**
  String get homeBudgetOpen;

  /// No description provided for @homeWatching.
  ///
  /// In en, this message translates to:
  /// **'Watching {name}: {amount} this week'**
  String homeWatching(String name, String amount);

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsTitle;

  /// No description provided for @statsDonutSemantics.
  ///
  /// In en, this message translates to:
  /// **'Spending by category, {amount} in all. The categories are listed below.'**
  String statsDonutSemantics(String amount);

  /// No description provided for @statsShare.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String statsShare(int percent);

  /// No description provided for @statsCategorySemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}: {amount}, {percent}% of spending'**
  String statsCategorySemantics(String name, String amount, int percent);

  /// No description provided for @statsByDay.
  ///
  /// In en, this message translates to:
  /// **'Day by day'**
  String get statsByDay;

  /// No description provided for @statsHighestDay.
  ///
  /// In en, this message translates to:
  /// **'Highest: {amount} on {day}'**
  String statsHighestDay(String amount, String day);

  /// No description provided for @statsDailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Average {amount} a day'**
  String statsDailyAverage(String amount);

  /// No description provided for @statsByDaySemantics.
  ///
  /// In en, this message translates to:
  /// **'Daily spending chart. Highest {amount} on {day}. Average {average} a day.'**
  String statsByDaySemantics(String amount, String day, String average);

  /// No description provided for @statsByMonth.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get statsByMonth;

  /// No description provided for @statsMonthAverage.
  ///
  /// In en, this message translates to:
  /// **'Average {amount} a month'**
  String statsMonthAverage(String amount);

  /// No description provided for @statsMonthBar.
  ///
  /// In en, this message translates to:
  /// **'{month}: {amount}'**
  String statsMonthBar(String month, String amount);

  /// No description provided for @statsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to chart yet'**
  String get statsEmptyTitle;

  /// No description provided for @statsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add or capture a few expenses and your charts appear here.'**
  String get statsEmptyBody;

  /// No description provided for @statsWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'Your week'**
  String get statsWeekTitle;

  /// No description provided for @statsWeekBody.
  ///
  /// In en, this message translates to:
  /// **'This week against last week, and who you paid most.'**
  String get statsWeekBody;

  /// No description provided for @weeklyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your week'**
  String get weeklyTitle;

  /// No description provided for @weeklyRange.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String weeklyRange(String start, String end);

  /// No description provided for @weeklySpent.
  ///
  /// In en, this message translates to:
  /// **'You spent {amount} this week.'**
  String weeklySpent(String amount);

  /// No description provided for @weeklyMore.
  ///
  /// In en, this message translates to:
  /// **'{amount} more than last week'**
  String weeklyMore(String amount);

  /// No description provided for @weeklyLess.
  ///
  /// In en, this message translates to:
  /// **'{amount} less than last week'**
  String weeklyLess(String amount);

  /// No description provided for @weeklySame.
  ///
  /// In en, this message translates to:
  /// **'The same as last week'**
  String get weeklySame;

  /// No description provided for @weeklyLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week: {amount}'**
  String weeklyLastWeek(String amount);

  /// No description provided for @weeklyTopCategories.
  ///
  /// In en, this message translates to:
  /// **'Top categories'**
  String get weeklyTopCategories;

  /// No description provided for @weeklyTopPayees.
  ///
  /// In en, this message translates to:
  /// **'Who you paid most'**
  String get weeklyTopPayees;

  /// No description provided for @weeklyPayeeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 payment} other{{count} payments}}'**
  String weeklyPayeeCount(int count);

  /// No description provided for @weeklyPayeeSemantics.
  ///
  /// In en, this message translates to:
  /// **'{amount} paid to {name}, {count, plural, =1{1 payment} other{{count} payments}}'**
  String weeklyPayeeSemantics(String amount, String name, int count);

  /// No description provided for @weeklyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No spending this week.'**
  String get weeklyEmpty;

  /// No description provided for @weeklyInbox.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing is waiting in Review.} =1{1 payment is waiting in Review.} other{{count} payments are waiting in Review.}}'**
  String weeklyInbox(int count);

  /// No description provided for @weeklyOpenReview.
  ///
  /// In en, this message translates to:
  /// **'Open Review'**
  String get weeklyOpenReview;

  /// No description provided for @weeklyWatchTitle.
  ///
  /// In en, this message translates to:
  /// **'One thing to watch next week'**
  String get weeklyWatchTitle;

  /// No description provided for @weeklyWatchHelp.
  ///
  /// In en, this message translates to:
  /// **'Pick a category. Home keeps an eye on it for you.'**
  String get weeklyWatchHelp;

  /// No description provided for @weeklyWatchNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing'**
  String get weeklyWatchNone;

  /// No description provided for @weeklyWatchSaved.
  ///
  /// In en, this message translates to:
  /// **'Watching {name} next week'**
  String weeklyWatchSaved(String name);

  /// No description provided for @weeklyWatchCleared.
  ///
  /// In en, this message translates to:
  /// **'Not watching a category'**
  String get weeklyWatchCleared;

  /// No description provided for @notifyAlertsChannel.
  ///
  /// In en, this message translates to:
  /// **'Budget alerts'**
  String get notifyAlertsChannel;

  /// No description provided for @notifyAlertsChannelInfo.
  ///
  /// In en, this message translates to:
  /// **'When a budget is nearly or fully used'**
  String get notifyAlertsChannelInfo;

  /// No description provided for @notifyWeeklyChannel.
  ///
  /// In en, this message translates to:
  /// **'Weekly review'**
  String get notifyWeeklyChannel;

  /// No description provided for @notifyWeeklyChannelInfo.
  ///
  /// In en, this message translates to:
  /// **'Your week, every Sunday evening'**
  String get notifyWeeklyChannelInfo;

  /// No description provided for @notifyRoomChannel.
  ///
  /// In en, this message translates to:
  /// **'Add to Room'**
  String get notifyRoomChannel;

  /// No description provided for @notifyRoomChannelInfo.
  ///
  /// In en, this message translates to:
  /// **'Payments that may belong to a Room'**
  String get notifyRoomChannelInfo;

  /// No description provided for @notifyAddToRoom.
  ///
  /// In en, this message translates to:
  /// **'Add to Room'**
  String get notifyAddToRoom;

  /// No description provided for @notifyAddTo.
  ///
  /// In en, this message translates to:
  /// **'Add to {name}'**
  String notifyAddTo(String name);

  /// No description provided for @notifyMonth80Title.
  ///
  /// In en, this message translates to:
  /// **'80% of your monthly budget used'**
  String get notifyMonth80Title;

  /// No description provided for @notifyMonth80Body.
  ///
  /// In en, this message translates to:
  /// **'{left} left for the rest of the month.'**
  String notifyMonth80Body(String left);

  /// No description provided for @notifyMonth100Title.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget used up'**
  String get notifyMonth100Title;

  /// No description provided for @notifySpentOf.
  ///
  /// In en, this message translates to:
  /// **'You\'ve spent {spent} of {budget}.'**
  String notifySpentOf(String spent, String budget);

  /// No description provided for @notifyCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} budget used up'**
  String notifyCategoryTitle(String name);

  /// No description provided for @notifyRoom80Title.
  ///
  /// In en, this message translates to:
  /// **'80% of the {name} budget used'**
  String notifyRoom80Title(String name);

  /// No description provided for @notifyRoom100Title.
  ///
  /// In en, this message translates to:
  /// **'{name} budget used up'**
  String notifyRoom100Title(String name);

  /// No description provided for @notifyWeeklyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your week in money'**
  String get notifyWeeklyTitle;

  /// No description provided for @notifyWeeklyBody.
  ///
  /// In en, this message translates to:
  /// **'See how the week went, and pick one thing to watch.'**
  String get notifyWeeklyBody;

  /// No description provided for @notifyRoomOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'{amount} at {payee}'**
  String notifyRoomOfferTitle(String amount, String payee);

  /// No description provided for @notifyRoomOfferTitleNoPayee.
  ///
  /// In en, this message translates to:
  /// **'{amount} captured'**
  String notifyRoomOfferTitleNoPayee(String amount);

  /// No description provided for @notifyRoomOfferBody.
  ///
  /// In en, this message translates to:
  /// **'Add it to {name}?'**
  String notifyRoomOfferBody(String name);

  /// No description provided for @notifyRoomOfferChoiceBody.
  ///
  /// In en, this message translates to:
  /// **'Add it to a Room?'**
  String get notifyRoomOfferChoiceBody;

  /// No description provided for @settingsBudgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get settingsBudgets;

  /// No description provided for @settingsBudgetsSemantics.
  ///
  /// In en, this message translates to:
  /// **'Budgets, {value}'**
  String settingsBudgetsSemantics(String value);

  /// No description provided for @noticesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get noticesTitle;

  /// No description provided for @noticesButton.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get noticesButton;

  /// No description provided for @noticesButtonUnread.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Notifications, 1 new} other{Notifications, {count} new}}'**
  String noticesButtonUnread(int count);

  /// No description provided for @noticesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noticesEmptyTitle;

  /// No description provided for @noticesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Budget alerts, your Sunday review and Room suggestions will appear here.'**
  String get noticesEmptyBody;

  /// No description provided for @noticesNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get noticesNew;

  /// No description provided for @noticesItemSemantics.
  ///
  /// In en, this message translates to:
  /// **'{title}. {body}. {time}'**
  String noticesItemSemantics(String title, String body, String time);

  /// No description provided for @noticesItemUnreadSemantics.
  ///
  /// In en, this message translates to:
  /// **'New: {title}. {body}. {time}'**
  String noticesItemUnreadSemantics(String title, String body, String time);

  /// No description provided for @noticesKeptFor.
  ///
  /// In en, this message translates to:
  /// **'Kept for 60 days.'**
  String get noticesKeptFor;

  /// No description provided for @reviewConfirmedLearned.
  ///
  /// In en, this message translates to:
  /// **'{payee} will always go to {category}'**
  String reviewConfirmedLearned(String payee, String category);

  /// No description provided for @reviewConfirmedLearnedMore.
  ///
  /// In en, this message translates to:
  /// **'{payee} will always go to {category}. {count, plural, =1{1 more payment} other{{count} more payments}} from them confirmed too.'**
  String reviewConfirmedLearnedMore(String payee, String category, int count);

  /// No description provided for @reviewConfirmedMany.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 payment} other{{count} payments}} confirmed as {category}'**
  String reviewConfirmedMany(int count, String category);

  /// No description provided for @reviewLearn.
  ///
  /// In en, this message translates to:
  /// **'Always use this category for {payee}'**
  String reviewLearn(String payee);

  /// No description provided for @reviewSelect.
  ///
  /// In en, this message translates to:
  /// **'Select payments'**
  String get reviewSelect;

  /// No description provided for @reviewSelectStop.
  ///
  /// In en, this message translates to:
  /// **'Stop selecting'**
  String get reviewSelectStop;

  /// No description provided for @reviewSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Tap payments to select them} =1{1 selected} other{{count} selected}}'**
  String reviewSelectedCount(int count);

  /// No description provided for @reviewChooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose category'**
  String get reviewChooseCategory;

  /// No description provided for @payeesTitle.
  ///
  /// In en, this message translates to:
  /// **'Payees & rules'**
  String get payeesTitle;

  /// No description provided for @payeesHelp.
  ///
  /// In en, this message translates to:
  /// **'Name a payee once and teach it a category or a Room. New payments from them follow it.'**
  String get payeesHelp;

  /// No description provided for @payeesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No payees yet'**
  String get payeesEmptyTitle;

  /// No description provided for @payeesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Payees appear here once captured payments arrive.'**
  String get payeesEmptyBody;

  /// No description provided for @payeesNoRule.
  ///
  /// In en, this message translates to:
  /// **'No rule'**
  String get payeesNoRule;

  /// No description provided for @payeesRuleCategory.
  ///
  /// In en, this message translates to:
  /// **'Always {category}'**
  String payeesRuleCategory(String category);

  /// No description provided for @payeesRuleRoom.
  ///
  /// In en, this message translates to:
  /// **'Goes to {room}'**
  String payeesRuleRoom(String room);

  /// No description provided for @payeesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 payment} other{{count} payments}}'**
  String payeesCount(int count);

  /// No description provided for @payeesRowSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}. {rule}. {payments}. Edit'**
  String payeesRowSemantics(String name, String rule, String payments);

  /// No description provided for @payeesNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get payeesNameLabel;

  /// No description provided for @payeesNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example, Sharma Dairy'**
  String get payeesNameHint;

  /// No description provided for @payeesCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get payeesCategory;

  /// No description provided for @payeesAskEachTime.
  ///
  /// In en, this message translates to:
  /// **'Ask each time'**
  String get payeesAskEachTime;

  /// No description provided for @payeesRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get payeesRoom;

  /// No description provided for @payeesNoRoom.
  ///
  /// In en, this message translates to:
  /// **'No Room'**
  String get payeesNoRoom;

  /// No description provided for @payeesSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get payeesSave;

  /// No description provided for @payeesForget.
  ///
  /// In en, this message translates to:
  /// **'Forget this payee\'s rule'**
  String get payeesForget;

  /// No description provided for @payeesSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved for {name}'**
  String payeesSaved(String name);

  /// No description provided for @payeesForgotten.
  ///
  /// In en, this message translates to:
  /// **'Rule removed'**
  String get payeesForgotten;

  /// No description provided for @payeesPickCategory.
  ///
  /// In en, this message translates to:
  /// **'Always use'**
  String get payeesPickCategory;

  /// No description provided for @payeesPickRoom.
  ///
  /// In en, this message translates to:
  /// **'Always add to'**
  String get payeesPickRoom;

  /// No description provided for @settingsPayees.
  ///
  /// In en, this message translates to:
  /// **'Payees & rules'**
  String get settingsPayees;

  /// No description provided for @settingsPayeesSemantics.
  ///
  /// In en, this message translates to:
  /// **'Payees and rules'**
  String get settingsPayeesSemantics;

  /// No description provided for @activitySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search payee, note or amount'**
  String get activitySearchHint;

  /// No description provided for @activityClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get activityClearSearch;

  /// No description provided for @activityFilterCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get activityFilterCategory;

  /// No description provided for @activityFilterRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get activityFilterRoom;

  /// No description provided for @activityFilterAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get activityFilterAccount;

  /// No description provided for @activityFilterKind.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get activityFilterKind;

  /// No description provided for @activityFilterSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get activityFilterSource;

  /// No description provided for @activityAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get activityAny;

  /// No description provided for @activityFilterSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}: {value}'**
  String activityFilterSemantics(String name, String value);

  /// No description provided for @kindSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get kindSpent;

  /// No description provided for @kindMoneyIn.
  ///
  /// In en, this message translates to:
  /// **'Money in'**
  String get kindMoneyIn;

  /// No description provided for @kindTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get kindTransfer;

  /// No description provided for @kindRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get kindRefund;

  /// No description provided for @sourceManual.
  ///
  /// In en, this message translates to:
  /// **'Typed in'**
  String get sourceManual;

  /// No description provided for @sourceAuto.
  ///
  /// In en, this message translates to:
  /// **'Captured'**
  String get sourceAuto;

  /// No description provided for @activityNoMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches'**
  String get activityNoMatchTitle;

  /// No description provided for @activityNoMatchBody.
  ///
  /// In en, this message translates to:
  /// **'Try another word, or clear the filters.'**
  String get activityNoMatchBody;

  /// No description provided for @activityClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get activityClearFilters;

  /// No description provided for @activitySearchingAll.
  ///
  /// In en, this message translates to:
  /// **'searching the last 12 months'**
  String get activitySearchingAll;

  /// No description provided for @activityResults.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String activityResults(int count);

  /// No description provided for @onboardCaptureTitle.
  ///
  /// In en, this message translates to:
  /// **'Every payment, written down for you'**
  String get onboardCaptureTitle;

  /// No description provided for @onboardCaptureBody.
  ///
  /// In en, this message translates to:
  /// **'UPI, card and bank payments are read from your bank\'s messages and notifications. You just pick a category, or let the app learn it.'**
  String get onboardCaptureBody;

  /// No description provided for @onboardRoomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rooms for trips and weddings'**
  String get onboardRoomsTitle;

  /// No description provided for @onboardRoomsBody.
  ///
  /// In en, this message translates to:
  /// **'Start a trip in one tap. A Goa weekend or a family wedding gets its own total, without wrecking your month.'**
  String get onboardRoomsBody;

  /// No description provided for @onboardBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Know what\'s safe to spend'**
  String get onboardBudgetTitle;

  /// No description provided for @onboardBudgetBody.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly budget and see each day what you can still spend, with a nudge before you run out.'**
  String get onboardBudgetBody;

  /// No description provided for @onboardPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your money stays on your phone'**
  String get onboardPrivacyTitle;

  /// No description provided for @onboardPrivacyNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account needed'**
  String get onboardPrivacyNoAccount;

  /// No description provided for @onboardPrivacyNoInternet.
  ///
  /// In en, this message translates to:
  /// **'Nothing leaves your phone unless you turn on sync, and then it\'s locked first'**
  String get onboardPrivacyNoInternet;

  /// No description provided for @onboardPrivacyNoAds.
  ///
  /// In en, this message translates to:
  /// **'No ads, and no one reads your messages'**
  String get onboardPrivacyNoAds;

  /// No description provided for @onboardSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on auto-capture'**
  String get onboardSetupTitle;

  /// No description provided for @onboardSetupBody.
  ///
  /// In en, this message translates to:
  /// **'Takes about two minutes. You can also do it later from Settings.'**
  String get onboardSetupBody;

  /// No description provided for @onboardSetupAction.
  ///
  /// In en, this message translates to:
  /// **'Set up now'**
  String get onboardSetupAction;

  /// No description provided for @onboardMonthlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly budget'**
  String get onboardMonthlyTitle;

  /// No description provided for @onboardMonthlyBody.
  ///
  /// In en, this message translates to:
  /// **'Optional. Rooms like trips stay out of it.'**
  String get onboardMonthlyBody;

  /// No description provided for @onboardNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardNext;

  /// No description provided for @onboardSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardSkip;

  /// No description provided for @onboardStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardStart;

  /// No description provided for @onboardStep.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String onboardStep(int step, int total);

  /// No description provided for @budgetsCategoryOverSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}: {spent} spent of {budget}, over by {over}. Change'**
  String budgetsCategoryOverSemantics(
    String name,
    String spent,
    String budget,
    String over,
  );

  /// No description provided for @lockTitle.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get lockTitle;

  /// No description provided for @lockBody.
  ///
  /// In en, this message translates to:
  /// **'Your expenses stay private until you unlock.'**
  String get lockBody;

  /// No description provided for @lockUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get lockUnlock;

  /// No description provided for @lockReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock to see your expenses'**
  String get lockReason;

  /// No description provided for @lockEnableReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm it\'s you to turn on the app lock'**
  String get lockEnableReason;

  /// No description provided for @settingsSectionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & data'**
  String get settingsSectionPrivacy;

  /// No description provided for @settingsAppLock.
  ///
  /// In en, this message translates to:
  /// **'Lock with Face ID, fingerprint or passcode'**
  String get settingsAppLock;

  /// No description provided for @settingsAppLockUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Set a screen lock on your phone first.'**
  String get settingsAppLockUnavailable;

  /// No description provided for @settingsRetention.
  ///
  /// In en, this message translates to:
  /// **'Keep message text'**
  String get settingsRetention;

  /// No description provided for @settingsRetentionSemantics.
  ///
  /// In en, this message translates to:
  /// **'Keep message text, {value}'**
  String settingsRetentionSemantics(String value);

  /// No description provided for @retentionNever.
  ///
  /// In en, this message translates to:
  /// **'Don\'t keep'**
  String get retentionNever;

  /// No description provided for @retentionDays30.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get retentionDays30;

  /// No description provided for @retentionForever.
  ///
  /// In en, this message translates to:
  /// **'Until I delete it'**
  String get retentionForever;

  /// No description provided for @retentionHelp.
  ///
  /// In en, this message translates to:
  /// **'The original bank message is kept so a payment can be read again if the app gets better at it. Amounts and payees stay either way.'**
  String get retentionHelp;

  /// No description provided for @settingsBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup & export'**
  String get settingsBackup;

  /// No description provided for @settingsBackupSemantics.
  ///
  /// In en, this message translates to:
  /// **'Backup and export'**
  String get settingsBackupSemantics;

  /// No description provided for @failureBackupPassword.
  ///
  /// In en, this message translates to:
  /// **'That password doesn\'t open this backup.'**
  String get failureBackupPassword;

  /// No description provided for @failureBackupNotBackup.
  ///
  /// In en, this message translates to:
  /// **'This file isn\'t a backup from this app.'**
  String get failureBackupNotBackup;

  /// No description provided for @failureBackupTooNew.
  ///
  /// In en, this message translates to:
  /// **'This backup is from a newer version of the app. Update the app, then try again.'**
  String get failureBackupTooNew;

  /// No description provided for @failureBackupFile.
  ///
  /// In en, this message translates to:
  /// **'The file couldn\'t be saved or read. Try again.'**
  String get failureBackupFile;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & export'**
  String get backupTitle;

  /// No description provided for @backupCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backup'**
  String get backupCardTitle;

  /// No description provided for @backupCardBody.
  ///
  /// In en, this message translates to:
  /// **'Saves everything into one file locked with a password. Keep it in Files, Google Drive or iCloud. Without the password no one can open it, not even you, so write it down somewhere safe.'**
  String get backupCardBody;

  /// No description provided for @backupCreate.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get backupCreate;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from a backup'**
  String get backupRestoreTitle;

  /// No description provided for @backupRestoreBody.
  ///
  /// In en, this message translates to:
  /// **'Replaces everything on this phone with what\'s in the backup file.'**
  String get backupRestoreBody;

  /// No description provided for @backupRestoreChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose backup file'**
  String get backupRestoreChoose;

  /// No description provided for @backupCsvTitle.
  ///
  /// In en, this message translates to:
  /// **'Export to a spreadsheet'**
  String get backupCsvTitle;

  /// No description provided for @backupCsvBody.
  ///
  /// In en, this message translates to:
  /// **'A CSV file of every payment, for Excel or Google Sheets. It is not encrypted: anyone who gets the file can read it.'**
  String get backupCsvBody;

  /// No description provided for @backupCsvExport.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get backupCsvExport;

  /// No description provided for @backupPasswordNew.
  ///
  /// In en, this message translates to:
  /// **'Set a backup password'**
  String get backupPasswordNew;

  /// No description provided for @backupPasswordOpen.
  ///
  /// In en, this message translates to:
  /// **'Backup password'**
  String get backupPasswordOpen;

  /// No description provided for @backupPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get backupPasswordLabel;

  /// No description provided for @backupPasswordRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get backupPasswordRepeat;

  /// No description provided for @backupPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least {count} characters'**
  String backupPasswordShort(int count);

  /// No description provided for @backupPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'The passwords don\'t match'**
  String get backupPasswordMismatch;

  /// No description provided for @backupContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get backupContinue;

  /// No description provided for @backupWorking.
  ///
  /// In en, this message translates to:
  /// **'Working on it…'**
  String get backupWorking;

  /// No description provided for @backupReady.
  ///
  /// In en, this message translates to:
  /// **'Backup created'**
  String get backupReady;

  /// No description provided for @backupNotShared.
  ///
  /// In en, this message translates to:
  /// **'Backup not saved'**
  String get backupNotShared;

  /// No description provided for @backupConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace all data?'**
  String get backupConfirmTitle;

  /// No description provided for @backupConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Everything on this phone will be replaced by the backup. This can\'t be undone.'**
  String get backupConfirmBody;

  /// No description provided for @backupConfirmReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get backupConfirmReplace;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Restored, with 1 payment} other{Restored, with {count} payments}}'**
  String backupRestored(int count);

  /// No description provided for @backupCsvReady.
  ///
  /// In en, this message translates to:
  /// **'CSV exported'**
  String get backupCsvReady;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account & sync'**
  String get accountTitle;

  /// No description provided for @accountIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your data on every phone'**
  String get accountIntroTitle;

  /// No description provided for @accountIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your expenses between phones and get them back on a new one. Everything is locked on this phone before it\'s sent, so no one else, not even us, can read it. Without an account the app works just the same.'**
  String get accountIntroBody;

  /// No description provided for @accountEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get accountEmailLabel;

  /// No description provided for @accountSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get accountSendCode;

  /// No description provided for @accountCodeSent.
  ///
  /// In en, this message translates to:
  /// **'We sent an email to {email}. On this phone, tap the link in it, or type the code from it here.'**
  String accountCodeSent(String email);

  /// No description provided for @accountCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code from the email'**
  String get accountCodeLabel;

  /// No description provided for @accountVerify.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get accountVerify;

  /// No description provided for @accountChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Use another email'**
  String get accountChangeEmail;

  /// No description provided for @accountEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an email address'**
  String get accountEmailInvalid;

  /// No description provided for @accountProblemCode.
  ///
  /// In en, this message translates to:
  /// **'That code didn\'t work. Check it, or send a new one.'**
  String get accountProblemCode;

  /// No description provided for @accountProblemTooMany.
  ///
  /// In en, this message translates to:
  /// **'Too many tries. Wait a minute and try again.'**
  String get accountProblemTooMany;

  /// No description provided for @accountProblemOffline.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Check your internet and try again.'**
  String get accountProblemOffline;

  /// No description provided for @accountNewKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Write down your recovery code'**
  String get accountNewKeyTitle;

  /// No description provided for @accountNewKeyBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need it to see your data on another phone. Keep it somewhere safe, like on paper. No one can recover it for you.'**
  String get accountNewKeyBody;

  /// No description provided for @accountNewKeySaved.
  ///
  /// In en, this message translates to:
  /// **'I\'ve written it down'**
  String get accountNewKeySaved;

  /// No description provided for @accountNeedsCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your recovery code'**
  String get accountNeedsCodeTitle;

  /// No description provided for @accountNeedsCodeBody.
  ///
  /// In en, this message translates to:
  /// **'This account already has data from another phone. Enter the recovery code you wrote down when you set up sync.'**
  String get accountNeedsCodeBody;

  /// No description provided for @accountRecoveryLabel.
  ///
  /// In en, this message translates to:
  /// **'Recovery code'**
  String get accountRecoveryLabel;

  /// No description provided for @accountRecoveryWrong.
  ///
  /// In en, this message translates to:
  /// **'That code doesn\'t open this account\'s data. Check it and try again.'**
  String get accountRecoveryWrong;

  /// No description provided for @accountUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock my data'**
  String get accountUnlock;

  /// No description provided for @accountSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String accountSignedInAs(String email);

  /// No description provided for @accountLastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last synced {time}'**
  String accountLastSynced(String time);

  /// No description provided for @accountNeverSynced.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get accountNeverSynced;

  /// No description provided for @accountOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline: changes will sync when you\'re back online.'**
  String get accountOffline;

  /// No description provided for @accountSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get accountSyncNow;

  /// No description provided for @accountShowCode.
  ///
  /// In en, this message translates to:
  /// **'Show recovery code'**
  String get accountShowCode;

  /// No description provided for @accountShowCodeReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm it\'s you to see the recovery code'**
  String get accountShowCodeReason;

  /// No description provided for @accountSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get accountSignOut;

  /// No description provided for @accountSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out. Your data stays on this phone.'**
  String get accountSignedOut;

  /// No description provided for @accountDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountDelete;

  /// No description provided for @accountDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get accountDeleteTitle;

  /// No description provided for @accountDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Your account and its cloud copy are deleted for good. The data on this phone stays.'**
  String get accountDeleteBody;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted. Your data stays on this phone.'**
  String get accountDeleted;

  /// No description provided for @accountCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get accountCopy;

  /// No description provided for @accountCopied.
  ///
  /// In en, this message translates to:
  /// **'Recovery code copied'**
  String get accountCopied;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account & sync'**
  String get settingsAccount;

  /// No description provided for @settingsAccountOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsAccountOff;

  /// No description provided for @settingsAccountSemantics.
  ///
  /// In en, this message translates to:
  /// **'Account and sync, {value}'**
  String settingsAccountSemantics(String value);

  /// No description provided for @accountContinueApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get accountContinueApple;

  /// No description provided for @accountContinueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get accountContinueGoogle;

  /// No description provided for @accountOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Or use your email'**
  String get accountOrEmail;

  /// No description provided for @onboardPaydayTitle.
  ///
  /// In en, this message translates to:
  /// **'When does your salary come in?'**
  String get onboardPaydayTitle;

  /// No description provided for @onboardPaydayBody.
  ///
  /// In en, this message translates to:
  /// **'Your month will run from one salary to the next, so the numbers match your real month. You can change it later in Settings.'**
  String get onboardPaydayBody;

  /// No description provided for @onboardPaydayFirst.
  ///
  /// In en, this message translates to:
  /// **'1st of the month'**
  String get onboardPaydayFirst;

  /// No description provided for @onboardPaydayOther.
  ///
  /// In en, this message translates to:
  /// **'Another day'**
  String get onboardPaydayOther;

  /// No description provided for @onboardSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your data safe if you change phones'**
  String get onboardSyncTitle;

  /// No description provided for @onboardSyncBody.
  ///
  /// In en, this message translates to:
  /// **'Optional. Sign in to sync between phones. Your data is locked on this phone before it\'s sent, so no one else can read it.'**
  String get onboardSyncBody;

  /// No description provided for @onboardSyncEmail.
  ///
  /// In en, this message translates to:
  /// **'Use email instead'**
  String get onboardSyncEmail;

  /// No description provided for @heroLeftThisMonth.
  ///
  /// In en, this message translates to:
  /// **'You have {amount} left this month.'**
  String heroLeftThisMonth(String amount);

  /// No description provided for @heroLeftSince.
  ///
  /// In en, this message translates to:
  /// **'You have {amount} left since {date}.'**
  String heroLeftSince(String amount, String date);

  /// No description provided for @heroShortThisMonth.
  ///
  /// In en, this message translates to:
  /// **'You\'ve spent {amount} more than you had this month.'**
  String heroShortThisMonth(String amount);

  /// No description provided for @heroShortSince.
  ///
  /// In en, this message translates to:
  /// **'You\'ve spent {amount} more than you had since {date}.'**
  String heroShortSince(String amount, String date);

  /// No description provided for @heroSavedIn.
  ///
  /// In en, this message translates to:
  /// **'You saved {amount} in {month}.'**
  String heroSavedIn(String amount, String month);

  /// No description provided for @heroOverspentIn.
  ///
  /// In en, this message translates to:
  /// **'You spent {amount} more than came in during {month}.'**
  String heroOverspentIn(String amount, String month);

  /// No description provided for @heroBalanceUsed.
  ///
  /// In en, this message translates to:
  /// **'{spent} spent of {available}'**
  String heroBalanceUsed(String spent, String available);

  /// No description provided for @heroSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get heroSpent;

  /// No description provided for @heroSpentSemantics.
  ///
  /// In en, this message translates to:
  /// **'{amount} spent'**
  String heroSpentSemantics(String amount);

  /// No description provided for @heroCarried.
  ///
  /// In en, this message translates to:
  /// **'Carried over'**
  String get heroCarried;

  /// No description provided for @heroCarriedSemantics.
  ///
  /// In en, this message translates to:
  /// **'{amount} carried over from earlier months'**
  String heroCarriedSemantics(String amount);

  /// No description provided for @roomDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Room'**
  String get roomDelete;

  /// No description provided for @roomDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String roomDeleteTitle(String name);

  /// No description provided for @roomDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Kept payments go back into your normal month. This can\'t be undone.'**
  String get roomDeleteBody;

  /// No description provided for @roomDeleteKeep.
  ///
  /// In en, this message translates to:
  /// **'Delete the Room, keep its payments'**
  String get roomDeleteKeep;

  /// No description provided for @roomDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete the Room and its payments'**
  String get roomDeleteAll;

  /// No description provided for @roomDeleted.
  ///
  /// In en, this message translates to:
  /// **'Room deleted'**
  String get roomDeleted;

  /// No description provided for @scanPay.
  ///
  /// In en, this message translates to:
  /// **'Scan & Pay'**
  String get scanPay;

  /// No description provided for @scanHint.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at a UPI QR code'**
  String get scanHint;

  /// No description provided for @scanNotUpi.
  ///
  /// In en, this message translates to:
  /// **'This isn\'t a UPI payment QR. Try another one.'**
  String get scanNotUpi;

  /// No description provided for @scanCameraOff.
  ///
  /// In en, this message translates to:
  /// **'The camera isn\'t available. Allow camera access in Settings to scan.'**
  String get scanCameraOff;

  /// No description provided for @scanPayTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get scanPayTitle;

  /// No description provided for @scanPayTo.
  ///
  /// In en, this message translates to:
  /// **'Paying'**
  String get scanPayTo;

  /// No description provided for @scanPayFixedAmount.
  ///
  /// In en, this message translates to:
  /// **'This QR sets the amount.'**
  String get scanPayFixedAmount;

  /// No description provided for @scanPayCheck.
  ///
  /// In en, this message translates to:
  /// **'Check the name before you pay. Your UPI PIN is only ever entered in your UPI app.'**
  String get scanPayCheck;

  /// No description provided for @scanPayAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get scanPayAmountLabel;

  /// No description provided for @scanPayAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the amount you\'re paying'**
  String get scanPayAmountInvalid;

  /// No description provided for @scanPayFor.
  ///
  /// In en, this message translates to:
  /// **'For'**
  String get scanPayFor;

  /// No description provided for @scanPayButton.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String scanPayButton(String amount);

  /// No description provided for @scanPayWith.
  ///
  /// In en, this message translates to:
  /// **'Pay with'**
  String get scanPayWith;

  /// No description provided for @scanPayNoApps.
  ///
  /// In en, this message translates to:
  /// **'No UPI app found on this phone. Install Google Pay, PhonePe, Paytm or BHIM to pay.'**
  String get scanPayNoApps;

  /// No description provided for @scanPayNotOpened.
  ///
  /// In en, this message translates to:
  /// **'{app} couldn\'t be opened. Try another app.'**
  String scanPayNotOpened(String app);

  /// No description provided for @scanPayAskTitle.
  ///
  /// In en, this message translates to:
  /// **'Did the payment go through?'**
  String get scanPayAskTitle;

  /// No description provided for @scanPayAskBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} to {name}'**
  String scanPayAskBody(String amount, String name);

  /// No description provided for @scanPayAskYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, it went through'**
  String get scanPayAskYes;

  /// No description provided for @scanPayAskNo.
  ///
  /// In en, this message translates to:
  /// **'No, it failed'**
  String get scanPayAskNo;

  /// No description provided for @scanPayAskOther.
  ///
  /// In en, this message translates to:
  /// **'It was a different amount'**
  String get scanPayAskOther;

  /// No description provided for @scanPayOtherTitle.
  ///
  /// In en, this message translates to:
  /// **'How much did you pay?'**
  String get scanPayOtherTitle;

  /// No description provided for @scanPaySave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get scanPaySave;

  /// No description provided for @scanPaySaved.
  ///
  /// In en, this message translates to:
  /// **'{amount} to {name} saved'**
  String scanPaySaved(String amount, String name);

  /// No description provided for @scanPayFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Nothing was saved.'**
  String get scanPayFailed;

  /// No description provided for @scanPayPending.
  ///
  /// In en, this message translates to:
  /// **'Payment pending. It\'s in Review until you confirm it.'**
  String get scanPayPending;

  /// No description provided for @scanPayToReview.
  ///
  /// In en, this message translates to:
  /// **'Saved to Review. Confirm it there once you know it went through.'**
  String get scanPayToReview;
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
