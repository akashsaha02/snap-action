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
/// import 'generated/app_localizations.dart';
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

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'SnapAction'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Screenshot anything. Find everything. Turn it into action.'**
  String get tagline;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCollections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get navCollections;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get navReminders;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @importScreenshots.
  ///
  /// In en, this message translates to:
  /// **'Import screenshots'**
  String get importScreenshots;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Stop losing important screenshots'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Body.
  ///
  /// In en, this message translates to:
  /// **'SnapAction turns a cluttered camera roll into tidy, smart collections, from receipts to recipes.'**
  String get onboarding1Body;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Your screenshots are searchable'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Body.
  ///
  /// In en, this message translates to:
  /// **'Text inside every screenshot is read on your device, so you can find a price, a date or a name in seconds.'**
  String get onboarding2Body;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Turn information into action'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Body.
  ///
  /// In en, this message translates to:
  /// **'Deadlines become reminders, events become calendar entries, and products land in your wishlist.'**
  String get onboarding3Body;

  /// No description provided for @onboardingPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your screenshots stay on this device. Text recognition and organisation run offline.'**
  String get onboardingPrivacy;

  /// No description provided for @splashLoadError.
  ///
  /// In en, this message translates to:
  /// **'SnapAction could not open its local database.'**
  String get splashLoadError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search text, amounts, dates, tags...'**
  String get searchHint;

  /// No description provided for @emptyLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'No screenshots yet'**
  String get emptyLibraryTitle;

  /// No description provided for @emptyLibraryBody.
  ///
  /// In en, this message translates to:
  /// **'Import screenshots from your gallery or share them to SnapAction from any app.'**
  String get emptyLibraryBody;

  /// No description provided for @emptyCollectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No collections yet'**
  String get emptyCollectionsTitle;

  /// No description provided for @emptyCollectionsBody.
  ///
  /// In en, this message translates to:
  /// **'Collections fill up automatically as screenshots are categorised. You can also create your own.'**
  String get emptyCollectionsBody;

  /// No description provided for @emptyRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'No reminders'**
  String get emptyRemindersTitle;

  /// No description provided for @emptyRemindersBody.
  ///
  /// In en, this message translates to:
  /// **'Create reminders from deadlines and events found in your screenshots.'**
  String get emptyRemindersBody;

  /// No description provided for @emptySearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search your screenshots'**
  String get emptySearchTitle;

  /// No description provided for @emptySearchBody.
  ///
  /// In en, this message translates to:
  /// **'Everything you import becomes searchable, including the text inside images.'**
  String get emptySearchBody;
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
