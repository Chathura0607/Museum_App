import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';

// ignore_for_file: type=lint

abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
  ];

  String get appTitle;
  String get exhibits;
  String get scanQR;
  String get map;
  String get searchHint;
  String get noArtifacts;
  String get noResults;
  String get searchPrompt;
  String get aboutArtifact;
  String get listen;
  String get stop;
  String get romanEmpire;
  String get ancientSriLanka;
  String get scanTitle;
  String get scanPrompt;
  String get view3D;
  String get museumMap;
  String get tapRoom;
  String get entrance;
  String get exit;
  String get curatorAssistant;
  String get favorites;
  String get noFavorites;
  String get addToFavorites;
  String get removeFromFavorites;
  String get shareArtifact;
  String get relatedExhibits;
  String get feedbackTitle;
  String get curatorPortal;
  String get ticketId;
  String get nicNumber;
  String get beginJourney;
  String get settings;
  String get language;
  String get appearance;
  String get darkMode;
  String get lightMode;
  String get logout;
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
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale".',
  );
}
