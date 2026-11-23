import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookkeeping_app/features/settings/settings_view.dart';
import 'package:bookkeeping_app/app/providers.dart';
import 'package:bookkeeping_app/domain/entities/user_preferences.dart';

import '../helpers/fake_preferences_repository.dart';

void main() {
  testWidgets(
    'SettingsView displays options and triggers theme preference update',
    (tester) async {
      final fakePrefs = FakePreferencesRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesRepositoryProvider.overrideWithValue(fakePrefs),
          ],
          child: const MaterialApp(home: SettingsView()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Appearance Theme'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
      expect(find.text('Help & FAQs'), findsOneWidget);
      expect(find.text('Reset All Data'), findsOneWidget);

      // Check initial preference
      final current = await fakePrefs.getPreferences();
      expect(current.themePreference, equals(AppThemePreference.system));
    },
  );
}
