import 'dart:async';

import 'package:bookkeeping_app/domain/entities/user_preferences.dart';
import 'package:bookkeeping_app/domain/repositories/preferences_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalPreferencesRepository implements PreferencesRepository {
  static const _keyOnboarding = 'pref_onboarding_completed';
  static const _keyTheme = 'pref_theme_mode';
  static const _keyCurrencyCode = 'pref_currency_code';
  static const _keyCurrencySymbol = 'pref_currency_symbol';
  static const _keyUserName = 'pref_user_name';

  final SharedPreferences _prefs;
  final _controller = StreamController<UserPreferences>.broadcast();

  LocalPreferencesRepository(this._prefs);

  UserPreferences _current() {
    final onboarding = _prefs.getBool(_keyOnboarding) ?? false;
    final themeIndex = _prefs.getInt(_keyTheme) ?? 0;
    final theme = AppThemePreference.values[themeIndex.clamp(0, 2)];
    final code = _prefs.getString(_keyCurrencyCode) ?? 'USD';
    final symbol = _prefs.getString(_keyCurrencySymbol) ?? '\$';
    final name = _prefs.getString(_keyUserName) ?? 'User';

    return UserPreferences(
      hasCompletedOnboarding: onboarding,
      themePreference: theme,
      currencyCode: code,
      currencySymbol: symbol,
      userName: name,
    );
  }

  void _notify() {
    _controller.add(_current());
  }

  @override
  Future<UserPreferences> getPreferences() async {
    return _current();
  }

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    await _prefs.setBool(_keyOnboarding, preferences.hasCompletedOnboarding);
    await _prefs.setInt(_keyTheme, preferences.themePreference.index);
    await _prefs.setString(_keyCurrencyCode, preferences.currencyCode);
    await _prefs.setString(_keyCurrencySymbol, preferences.currencySymbol);
    await _prefs.setString(_keyUserName, preferences.userName);
    _notify();
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(_keyOnboarding, completed);
    _notify();
  }

  @override
  Future<void> setThemePreference(AppThemePreference theme) async {
    await _prefs.setInt(_keyTheme, theme.index);
    _notify();
  }

  @override
  Future<void> setCurrency(String code, String symbol) async {
    await _prefs.setString(_keyCurrencyCode, code);
    await _prefs.setString(_keyCurrencySymbol, symbol);
    _notify();
  }

  @override
  Future<void> clearAllData() async {
    await _prefs.clear();
    _notify();
  }

  @override
  Stream<UserPreferences> watchPreferences() {
    return _controller.stream;
  }
}
