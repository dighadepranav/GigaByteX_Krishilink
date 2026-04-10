import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class AppLocalizations {
  final Locale locale;
  final Map<String, String> _localizedStrings;

  AppLocalizations(this.locale, this._localizedStrings);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'mr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    String jsonString = await rootBundle
        .loadString('assets/translations/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    Map<String, String> localizedStrings =
        jsonMap.map((key, value) => MapEntry(key, value.toString()));
    return AppLocalizations(locale, localizedStrings);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => true;
}
