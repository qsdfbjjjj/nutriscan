import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../data/datasources/local/settings_local_data_source.dart';

/// Настройки через Provider (ChangeNotifier) — простой сценарий:
/// два значения, без сложной логики и асинхронных состояний.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._storage)
      : _themeMode = _storage.themeMode,
        _languageCode = _storage.languageCode;

  final SettingsLocalDataSource _storage;

  ThemeMode _themeMode;
  String _languageCode;

  ThemeMode get themeMode => _themeMode;
  String get languageCode => _languageCode;
  AppStrings get strings => AppStrings(_languageCode);

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners(); // перерисовать подписчиков (MaterialApp)
    await _storage.saveThemeMode(mode);
  }

  Future<void> setLanguage(String code) async {
    if (code == _languageCode) return;
    _languageCode = code;
    notifyListeners();
    await _storage.saveLanguageCode(code);
  }
}
