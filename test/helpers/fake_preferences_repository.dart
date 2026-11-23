import 'dart:async';

import 'package:bookkeeping_app/domain/entities/user_preferences.dart';
import 'package:bookkeeping_app/domain/repositories/preferences_repository.dart';

class FakePreferencesRepository implements PreferencesRepository {
  UserPreferences _preferences;
  final _controller = StreamController<UserPreferences>.broadcast();

  FakePreferencesRepository([this._preferences = const UserPreferences()]);

  @override
  Future<UserPreferences> getPreferences() async => _preferences;

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    _preferences = preferences;
    _controller.add(_preferences);
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    _preferences = _preferences.copyWith(hasCompletedOnboarding: completed);
    _controller.add(_preferences);
  }

  @override
  Future<void> setThemePreference(AppThemePreference theme) async {
    _preferences = _preferences.copyWith(themePreference: theme);
    _controller.add(_preferences);
  }

  @override
  Future<void> setCurrency(String code, String symbol) async {
    _preferences = _preferences.copyWith(
      currencyCode: code,
      currencySymbol: symbol,
    );
    _controller.add(_preferences);
  }

  @override
  Future<void> clearAllData() async {
    _preferences = const UserPreferences();
    _controller.add(_preferences);
  }

  @override
  Stream<UserPreferences> watchPreferences() => _controller.stream;

  void dispose() {
    _controller.close();
  }
}
