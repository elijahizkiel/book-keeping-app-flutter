import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookkeeping_app/features/onboarding/onboarding_view.dart';
import 'package:bookkeeping_app/app/providers.dart';

import '../helpers/fake_preferences_repository.dart';

void main() {
  testWidgets('OnboardingView renders slides and allows navigation', (
    tester,
  ) async {
    final fakePrefs = FakePreferencesRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [preferencesRepositoryProvider.overrideWithValue(fakePrefs)],
        child: const MaterialApp(home: OnboardingView()),
      ),
    );

    // Initial slide
    expect(find.text('Track Shared Expenses'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // Tap Continue to advance to slide 2
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Know Where You Stand'), findsOneWidget);

    // Tap Continue to advance to slide 3
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Offline-First & Private'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
