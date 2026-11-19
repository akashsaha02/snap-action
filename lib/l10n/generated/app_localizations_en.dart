// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Mindtiq';

  @override
  String get tagline =>
      'Screenshot anything. Find everything. Turn it into action.';

  @override
  String get navHome => 'Home';

  @override
  String get navCollections => 'Collections';

  @override
  String get navSearch => 'Search';

  @override
  String get navReminders => 'Reminders';

  @override
  String get navSettings => 'Settings';

  @override
  String get importScreenshots => 'Import screenshots';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboarding1Title => 'Stop losing important screenshots';

  @override
  String get onboarding1Body =>
      'Mindtiq turns a cluttered camera roll into tidy, smart collections, from receipts to recipes.';

  @override
  String get onboarding2Title => 'Searchable. And private.';

  @override
  String get onboarding2Body =>
      'Text inside every screenshot is read on your phone and never uploaded, so you can find a price, a date or a name in seconds.';

  @override
  String get onboarding3Title => 'Turn information into action';

  @override
  String get onboarding3Body =>
      'Deadlines become reminders, events become calendar entries, and products land in your wishlist.';

  @override
  String get onboardingPrivacy =>
      'Your screenshots stay on this device. Text recognition and organisation run offline.';

  @override
  String get splashLoadError => 'Mindtiq could not open its local database.';

  @override
  String get retry => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get searchHint => 'Search text, amounts, dates, tags...';

  @override
  String get emptyLibraryTitle => 'No screenshots yet';

  @override
  String get emptyLibraryBody =>
      'Import screenshots from your gallery or share them to Mindtiq from any app.';

  @override
  String get emptyCollectionsTitle => 'No collections yet';

  @override
  String get emptyCollectionsBody =>
      'Collections fill up automatically as screenshots are categorised. You can also create your own.';

  @override
  String get emptyRemindersTitle => 'No reminders';

  @override
  String get emptyRemindersBody =>
      'Create reminders from deadlines and events found in your screenshots.';

  @override
  String get emptySearchTitle => 'Search your screenshots';

  @override
  String get emptySearchBody =>
      'Everything you import becomes searchable, including the text inside images.';
}
