import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookkeeping_app/domain/entities/balance_summary.dart';
import 'package:bookkeeping_app/domain/entities/filter_criteria.dart';
import 'package:bookkeeping_app/domain/entities/friend.dart';
import 'package:bookkeeping_app/domain/entities/transaction.dart';
import 'package:bookkeeping_app/domain/entities/user_preferences.dart';
import 'package:bookkeeping_app/domain/repositories/friends_repository.dart';
import 'package:bookkeeping_app/domain/repositories/preferences_repository.dart';
import 'package:bookkeeping_app/domain/repositories/transactions_repository.dart';
import 'package:bookkeeping_app/data/repositories/in_memory_friends_repository.dart';
import 'package:bookkeeping_app/data/repositories/in_memory_transactions_repository.dart';

// Repository Providers
final friendsRepositoryProvider = Provider<FriendsRepository>((ref) {
  return InMemoryFriendsRepository();
});

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return InMemoryTransactionsRepository();
});

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  throw UnimplementedError(
    'Initialize preferencesRepositoryProvider in bootstrap',
  );
});

// App State Providers
final preferencesStateProvider =
    NotifierProvider<PreferencesNotifier, UserPreferences>(
      PreferencesNotifier.new,
    );

class PreferencesNotifier extends Notifier<UserPreferences> {
  @override
  UserPreferences build() {
    final repo = ref.watch(preferencesRepositoryProvider);
    // Initialize state synchronously with defaults, then load asynchronously
    repo.getPreferences().then((loaded) {
      state = loaded;
    });
    return const UserPreferences();
  }

  Future<void> completeOnboarding() async {
    final repo = ref.read(preferencesRepositoryProvider);
    await repo.setOnboardingCompleted(true);
    state = state.copyWith(hasCompletedOnboarding: true);
  }

  Future<void> setTheme(AppThemePreference theme) async {
    final repo = ref.read(preferencesRepositoryProvider);
    await repo.setThemePreference(theme);
    state = state.copyWith(themePreference: theme);
  }

  Future<void> setCurrency(String code, String symbol) async {
    final repo = ref.read(preferencesRepositoryProvider);
    await repo.setCurrency(code, symbol);
    state = state.copyWith(currencyCode: code, currencySymbol: symbol);
  }

  Future<void> resetAll() async {
    final repo = ref.read(preferencesRepositoryProvider);
    await repo.clearAllData();
    state = const UserPreferences();
  }
}

// Friends List Provider
final friendsListProvider =
    AsyncNotifierProvider<FriendsListNotifier, List<Friend>>(
      FriendsListNotifier.new,
    );

class FriendsListNotifier extends AsyncNotifier<List<Friend>> {
  @override
  Future<List<Friend>> build() async {
    return ref.watch(friendsRepositoryProvider).getFriends();
  }

  Future<void> addFriend(Friend friend) async {
    await ref.read(friendsRepositoryProvider).addFriend(friend);
    ref.invalidateSelf();
  }

  Future<void> updateFriend(Friend friend) async {
    await ref.read(friendsRepositoryProvider).updateFriend(friend);
    ref.invalidateSelf();
  }

  Future<void> deleteFriend(String id) async {
    await ref.read(friendsRepositoryProvider).deleteFriend(id);
    ref.invalidateSelf();
  }
}

// Transactions Filter Provider
final transactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, FilterCriteria>(
      TransactionFilterNotifier.new,
    );

class TransactionFilterNotifier extends Notifier<FilterCriteria> {
  @override
  FilterCriteria build() => const FilterCriteria();

  void update(FilterCriteria filter) {
    state = filter;
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setDirectionFilter(DirectionFilter direction) {
    state = state.copyWith(directionFilter: direction);
  }

  void setDateRangeFilter(DateRangeFilter dateRange) {
    state = state.copyWith(dateRangeFilter: dateRange);
  }
}

// Transactions List Provider
final transactionsListProvider =
    AsyncNotifierProvider<TransactionsListNotifier, List<Transaction>>(
      TransactionsListNotifier.new,
    );

class TransactionsListNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    final filter = ref.watch(transactionFilterProvider);
    return ref.watch(transactionsRepositoryProvider).getTransactions(filter);
  }

  Future<void> addTransaction(Transaction tx) async {
    await ref.read(transactionsRepositoryProvider).addTransaction(tx);
    ref.invalidateSelf();
  }

  Future<void> updateTransaction(Transaction tx) async {
    await ref.read(transactionsRepositoryProvider).updateTransaction(tx);
    ref.invalidateSelf();
  }

  Future<void> deleteTransaction(String id) async {
    await ref.read(transactionsRepositoryProvider).deleteTransaction(id);
    ref.invalidateSelf();
  }

  Future<void> settleTransaction(String id) async {
    await ref.read(transactionsRepositoryProvider).settleTransaction(id);
    ref.invalidateSelf();
  }

  Future<void> settleAllForFriend(String friendId) async {
    await ref.read(transactionsRepositoryProvider).settleAllForFriend(friendId);
    ref.invalidateSelf();
  }
}

// Balance Summary Provider (Calculated strictly from pending transactions)
final balanceSummaryProvider = Provider<BalanceSummary>((ref) {
  final transactionsAsync = ref.watch(transactionsListProvider);
  return transactionsAsync.maybeWhen(
    data: (txs) => BalanceSummary.fromTransactions(txs),
    orElse: () => BalanceSummary.zero,
  );
});

// Per-Friend Balance Provider
final friendBalanceProvider = Provider.family<BalanceSummary, String>((
  ref,
  friendId,
) {
  final transactionsAsync = ref.watch(transactionsListProvider);
  return transactionsAsync.maybeWhen(
    data: (txs) {
      final friendTxs = txs.where((t) => t.friendId == friendId);
      return BalanceSummary.fromTransactions(friendTxs);
    },
    orElse: () => BalanceSummary.zero,
  );
});
