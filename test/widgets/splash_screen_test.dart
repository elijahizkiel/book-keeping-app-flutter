import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookkeeping_app/features/splash/splash_view.dart';
import 'package:bookkeeping_app/app/providers.dart';

import '../helpers/fake_preferences_repository.dart';

void main() {
  testWidgets('SplashView displays app branding and redirects correctly', (
    tester,
  ) async {
    final fakePrefs = FakePreferencesRepository();

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashView()),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) =>
              const Scaffold(body: Text('Onboarding Page')),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) =>
              const Scaffold(body: Text('Dashboard Page')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [preferencesRepositoryProvider.overrideWithValue(fakePrefs)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    expect(find.text('BookKeeping'), findsOneWidget);
    expect(find.text('Track debts & split expenses easily'), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);

    // Let the 300ms redirect timer tick
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    // Verify redirected to onboarding for new user
    expect(find.text('Onboarding Page'), findsOneWidget);
  });
}
