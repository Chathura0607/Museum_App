import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ArtSphere Guide'**
  String get appTitle;

  /// No description provided for @exhibits.
  ///
  /// In en, this message translates to:
  /// **'Exhibits'**
  String get exhibits;

  /// No description provided for @scanQR.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get scanQR;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search artifacts...'**
  String get searchHint;

  /// No description provided for @noArtifacts.
  ///
  /// In en, this message translates to:
  /// **'No artifacts in this section.'**
  String get noArtifacts;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No artifacts found.'**
  String get noResults;

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Start typing to search artifacts...'**
  String get searchPrompt;

  /// No description provided for @aboutArtifact.
  ///
  /// In en, this message translates to:
  /// **'About this Artifact'**
  String get aboutArtifact;

  /// No description provided for @listen.
  ///
  /// In en, this message translates to:
  /// **'Audio Guide'**
  String get listen;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop Audio'**
  String get stop;

  /// No description provided for @romanEmpire.
  ///
  /// In en, this message translates to:
  /// **'Roman Empire'**
  String get romanEmpire;

  /// No description provided for @ancientSriLanka.
  ///
  /// In en, this message translates to:
  /// **'Ancient Sri Lanka'**
  String get ancientSriLanka;

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Exhibit QR'**
  String get scanTitle;

  /// No description provided for @scanPrompt.
  ///
  /// In en, this message translates to:
  /// **'Point camera at artifact QR code'**
  String get scanPrompt;

  /// No description provided for @view3D.
  ///
  /// In en, this message translates to:
  /// **'Experience in 3D'**
  String get view3D;

  /// No description provided for @museumMap.
  ///
  /// In en, this message translates to:
  /// **'Museum Map'**
  String get museumMap;

  /// No description provided for @tapRoom.
  ///
  /// In en, this message translates to:
  /// **'Tap a room to see artifacts'**
  String get tapRoom;

  /// No description provided for @entrance.
  ///
  /// In en, this message translates to:
  /// **'ENTRANCE'**
  String get entrance;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'EXIT'**
  String get exit;

  /// No description provided for @curatorAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Curator'**
  String get curatorAssistant;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Saved Favorites'**
  String get favorites;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No saved favorites yet.'**
  String get noFavorites;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get removeFromFavorites;

  /// No description provided for @shareArtifact.
  ///
  /// In en, this message translates to:
  /// **'Share Exhibit'**
  String get shareArtifact;

  /// No description provided for @relatedExhibits.
  ///
  /// In en, this message translates to:
  /// **'Related Treasures'**
  String get relatedExhibits;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate Your Experience'**
  String get feedbackTitle;

  /// No description provided for @curatorPortal.
  ///
  /// In en, this message translates to:
  /// **'Curator Portal'**
  String get curatorPortal;

  /// No description provided for @ticketId.
  ///
  /// In en, this message translates to:
  /// **'Ticket Pass ID'**
  String get ticketId;

  /// No description provided for @nicNumber.
  ///
  /// In en, this message translates to:
  /// **'National ID (NIC)'**
  String get nicNumber;

  /// No description provided for @beginJourney.
  ///
  /// In en, this message translates to:
  /// **'BEGIN JOURNEY'**
  String get beginJourney;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Velvet Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Golden Sunlight Mode'**
  String get lightMode;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Exit Museum'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to end your museum session?'**
  String get logoutConfirm;
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
      <String>['en', 'si'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
