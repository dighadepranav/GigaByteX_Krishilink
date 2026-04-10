import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale;

  LocaleProvider(this._locale);

  Locale get locale => _locale;

  Future<void> setLocale(String languageCode) async {
    final newLocale = Locale(languageCode, '');
    if (_locale == newLocale) return;
    _locale = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    notifyListeners();
  }
}
