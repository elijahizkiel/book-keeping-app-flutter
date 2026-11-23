import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookkeeping_app/features/friends/friends_view.dart';
import 'package:bookkeeping_app/app/providers.dart';
import 'package:bookkeeping_app/data/repositories/in_memory_friends_repository.dart';
import 'package:bookkeeping_app/data/repositories/in_memory_transactions_repository.dart';

import '../fixtures/sample_data.dart';
import '../helpers/fake_preferences_repository.dart';

void main() {
  testWidgets('FriendsView displays friends list and searches friend by name', (
    tester,
  ) async {
    final friendsRepo = InMemoryFriendsRepository(initial: SampleData.friends);
    final txRepo = InMemoryTransactionsRepository(
      initial: SampleData.transactions,
    );
    final fakePrefs = FakePreferencesRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          friendsRepositoryProvider.overrideWithValue(friendsRepo),
          transactionsRepositoryProvider.overrideWithValue(txRepo),
          preferencesRepositoryProvider.overrideWithValue(fakePrefs),
        ],
        child: const MaterialApp(home: FriendsView()),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & Friend entries
    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('Alice Johnson'), findsOneWidget);
    expect(find.text('Bob Smith'), findsOneWidget);
    expect(find.text('Charlie Brown'), findsOneWidget);

    // Search for 'Alice'
    await tester.enterText(find.byType(TextField), 'Alice');
    await tester.pumpAndSettle();

    expect(find.text('Alice Johnson'), findsOneWidget);
    expect(find.text('Bob Smith'), findsNothing);
  });
}
