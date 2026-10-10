import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/app_user.dart';

/// Хранит вошедшего пользователя в SharedPreferences.
class AuthLocalDataSource {
  AuthLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const _nameKey = 'auth.name';
  static const _emailKey = 'auth.email';

  AppUser? get user {
    final name = _prefs.getString(_nameKey);
    final email = _prefs.getString(_emailKey);
    if (name == null || email == null) return null;
    return AppUser(name: name, email: email);
  }

  Future<void> saveUser(AppUser user) async {
    await _prefs.setString(_nameKey, user.name);
    await _prefs.setString(_emailKey, user.email);
  }

  Future<void> clear() async {
    await _prefs.remove(_nameKey);
    await _prefs.remove(_emailKey);
  }
}
