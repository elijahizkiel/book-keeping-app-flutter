enum AppThemePreference { system, light, dark }

class UserPreferences {
  final bool hasCompletedOnboarding;
  final AppThemePreference themePreference;
  final String currencyCode;
  final String currencySymbol;
  final String userName;

  const UserPreferences({
    this.hasCompletedOnboarding = false,
    this.themePreference = AppThemePreference.system,
    this.currencyCode = 'USD',
    this.currencySymbol = '\$',
    this.userName = 'User',
  });

  UserPreferences copyWith({
    bool? hasCompletedOnboarding,
    AppThemePreference? themePreference,
    String? currencyCode,
    String? currencySymbol,
    String? userName,
  }) {
    return UserPreferences(
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      themePreference: themePreference ?? this.themePreference,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      userName: userName ?? this.userName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferences &&
          runtimeType == other.runtimeType &&
          hasCompletedOnboarding == other.hasCompletedOnboarding &&
          themePreference == other.themePreference &&
          currencyCode == other.currencyCode &&
          currencySymbol == other.currencySymbol &&
          userName == other.userName;

  @override
  int get hashCode =>
      hasCompletedOnboarding.hashCode ^
      themePreference.hashCode ^
      currencyCode.hashCode ^
      currencySymbol.hashCode ^
      userName.hashCode;
}
