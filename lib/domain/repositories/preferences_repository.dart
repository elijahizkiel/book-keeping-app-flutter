import 'package:bookkeeping_app/domain/entities/user_preferences.dart';

abstract class PreferencesRepository {
  Future<UserPreferences> getPreferences();
  Future<void> savePreferences(UserPreferences preferences);
  Future<void> setOnboardingCompleted(bool completed);
  Future<void> setThemePreference(AppThemePreference theme);
  Future<void> setCurrency(String code, String symbol);
  Future<void> clearAllData();
  Stream<UserPreferences> watchPreferences();
}
