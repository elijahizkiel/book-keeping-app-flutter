import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookkeeping_app/app/providers.dart';
import 'package:bookkeeping_app/domain/entities/transaction.dart';
import 'package:bookkeeping_app/data/repositories/in_memory_friends_repository.dart';
import 'package:bookkeeping_app/data/repositories/in_memory_transactions_repository.dart';

import '../helpers/fake_preferences_repository.dart';
import '../fixtures/sample_data.dart';

void main() {
  late ProviderContainer container;
  late InMemoryFriendsRepository friendsRepo;
  late InMemoryTransactionsRepository txRepo;
  late FakePreferencesRepository prefRepo;

  setUp(() {
    friendsRepo = InMemoryFriendsRepository(initial: SampleData.friends);
    txRepo = InMemoryTransactionsRepository(initial: SampleData.transactions);
    prefRepo = FakePreferencesRepository();

    container = ProviderContainer(
      overrides: [
        friendsRepositoryProvider.overrideWithValue(friendsRepo),
        transactionsRepositoryProvider.overrideWithValue(txRepo),
        preferencesRepositoryProvider.overrideWithValue(prefRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Riverpod State Notifiers and Providers Tests', () {
    test(
      'balanceSummaryProvider aggregates dynamically from transactions',
      () async {
        // Trigger initial read
        await container.read(transactionsListProvider.future);

        final balance = container.read(balanceSummaryProvider);
        expect(balance.owedToUserMinor, equals(5000));
        expect(balance.owedByUserMinor, equals(3500));
        expect(balance.netBalanceMinor, equals(1500));

        // Add another owedToUser transaction
        final newTx = Transaction(
          id: 'tx_p1',
          friendId: 'f3',
          description: 'Book lending',
          amountMinor: 2500,
          direction: TransactionDirection.owedToUser,
          date: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await container
            .read(transactionsListProvider.notifier)
            .addTransaction(newTx);
        await container.read(transactionsListProvider.future);

        final updatedBalance = container.read(balanceSummaryProvider);
        expect(updatedBalance.owedToUserMinor, equals(7500));
        expect(updatedBalance.netBalanceMinor, equals(4000));
      },
    );

    test('friendBalanceProvider aggregates per-friend balances', () async {
      await container.read(transactionsListProvider.future);

      final aliceBalance = container.read(friendBalanceProvider('f1'));
      expect(aliceBalance.netBalanceMinor, equals(3500)); // +$35.00

      final bobBalance = container.read(friendBalanceProvider('f2'));
      expect(
        bobBalance.netBalanceMinor,
        equals(-2000),
      ); // -$20.00 (user owes Bob)
    });

    test(
      'preferencesStateProvider updates onboarding and theme state',
      () async {
        expect(
          container.read(preferencesStateProvider).hasCompletedOnboarding,
          isFalse,
        );

        await container
            .read(preferencesStateProvider.notifier)
            .completeOnboarding();
        expect(
          container.read(preferencesStateProvider).hasCompletedOnboarding,
          isTrue,
        );
      },
    );
  });
}
