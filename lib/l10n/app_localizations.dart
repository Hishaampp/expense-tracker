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

  /// No description provided for @navTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get navTransactions;

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

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpense;

  /// No description provided for @homeSpentLabel.
  ///
  /// In en, this message translates to:
  /// **'Spent this month'**
  String get homeSpentLabel;

  /// No description provided for @homeIncludesRooms.
  ///
  /// In en, this message translates to:
  /// **'includes {amount} in Rooms'**
  String homeIncludesRooms(String amount);

  /// No description provided for @homeSpentSemantics.
  ///
  /// In en, this message translates to:
  /// **'{amount} spent this month'**
  String homeSpentSemantics(String amount);

  /// No description provided for @homeMoneyIn.
  ///
  /// In en, this message translates to:
  /// **'Money in'**
  String get homeMoneyIn;

  /// No description provided for @homeMoneyInSemantics.
  ///
  /// In en, this message translates to:
  /// **'{amount} money in'**
  String homeMoneyInSemantics(String amount);

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
  /// **'Add your first expense to see this month\'s spending.'**
  String get homeEmptyBody;

  /// No description provided for @transactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsTitle;

  /// No description provided for @transactionsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing in {month}'**
  String transactionsEmptyTitle(String month);

  /// No description provided for @transactionsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Expenses you add for this month show up here.'**
  String get transactionsEmptyBody;

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

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get selected;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsMonthSection.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get settingsMonthSection;

  /// No description provided for @settingsMonthStart.
  ///
  /// In en, this message translates to:
  /// **'Month starts on'**
  String get settingsMonthStart;

  /// No description provided for @settingsMonthStartSemantics.
  ///
  /// In en, this message translates to:
  /// **'Month starts on day {day}'**
  String settingsMonthStartSemantics(int day);

  /// No description provided for @settingsMonthStartValue.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String settingsMonthStartValue(int day);

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

  /// No description provided for @notFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'This page doesn\'t exist'**
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
