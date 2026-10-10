import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Настройки приложения в SharedPreferences: тема и язык.
class SettingsLocalDataSource {
  SettingsLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const _themeKey = 'settings.theme';
  static const _languageKey = 'settings.language';

  ThemeMode get themeMode {
    final name = _prefs.getString(_themeKey);
    return ThemeMode.values.firstWhere(
      (m) => m.name == name,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeKey, mode.name);

  String get languageCode => _prefs.getString(_languageKey) ?? 'ru';

  Future<void> saveLanguageCode(String code) =>
      _prefs.setString(_languageKey, code);
}
