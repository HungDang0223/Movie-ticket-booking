import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class AppLocalizations {
  static String translate(BuildContext context, String key) {
    return key.i18n();
  }

  static Locale? localeResolutionCallback(
      Locale? locale, Iterable<Locale> supportedLocales) {
    if (locale == null) {
      return supportedLocales.first;
    }

    for (Locale supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return supportedLocale;
      }
    }

    return supportedLocales.first;
  }
}
