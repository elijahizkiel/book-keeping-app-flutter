import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookkeeping_app/app/providers.dart';
import 'package:bookkeeping_app/app/theme/app_colors.dart';
import 'package:bookkeeping_app/core/formatting/money_formatter.dart';
import 'package:bookkeeping_app/core/formatting/date_formatter.dart';
import 'package:bookkeeping_app/core/widgets/app_button.dart';
import 'package:bookkeeping_app/core/widgets/app_card.dart';
import 'package:bookkeeping_app/core/widgets/avatar_badge.dart';
import 'package:bookkeeping_app/core/widgets/balance_pill.dart';
import 'package:bookkeeping_app/core/widgets/empty_state_view.dart';

class FriendDetailView extends ConsumerWidget {
  final String friendId;

  const FriendDetailView({super.key, required this.friendId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsListProvider);
    final transactionsAsync = ref.watch(transactionsListProvider);
    final balance = ref.watch(friendBalanceProvider(friendId));
    final prefs = ref.watch(preferencesStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Friend Profile')),
      body: friendsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (friends) {
          final friend = friends.cast().firstWhere(
            (f) => f.id == friendId,
            orElse: () => null,
          );

          if (friend == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Friend not found',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final friendTxs = transactionsAsync.maybeWhen(
            data: (txs) => txs.where((t) => t.friendId == friendId).toList(),
            orElse: () => [],
          );

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Friend Header Profile Card
              Center(
                child: Column(
                  children: [
                    AvatarBadge(initials: friend.initials, radius: 36),
                    const SizedBox(height: 12),
                    Text(
                      friend.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (friend.email != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        friend.email!,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Per-Friend Net Balance Card
                    AppCard(
                      backgroundColor: balance.isZero
                          ? Colors.grey.shade100
                          : (balance.isNegative
                                ? AppColors.debtLight
                                : AppColors.creditLight),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Column(
                        children: [
                          Text(
                            balance.isZero
                                ? 'All Settled Up'
                                : (balance.isNegative
                                      ? 'You owe ${friend.name}'
                                      : '${friend.name} owes you'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: balance.isZero
                                  ? Colors.grey.shade700
                                  : (balance.isNegative
                                        ? AppColors.debt
                                        : AppColors.credit),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            MoneyFormatter.format(
                              balance.netBalanceMinor.abs(),
                              currencyCode: prefs.currencyCode,
                              symbol: prefs.currencySymbol,
                            ),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: balance.isZero
                                  ? Colors.grey.shade800
                                  : (balance.isNegative
                                        ? AppColors.debt
                                        : AppColors.credit),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Add Expense',
                      icon: Icons.add,
                      onPressed: () => context.push(
                        '/transactions/new?friendId=${friend.id}',
                      ),
                    ),
                  ),
                  if (!balance.isZero) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: 'Settle All',
                        variant: AppButtonVariant.secondary,
                        icon: Icons.done_all,
                        onPressed: () async {
                          await ref
                              .read(transactionsListProvider.notifier)
                              .settleAllForFriend(friend.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'All balances with ${friend.name} settled',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 32),

              // Transaction History Ledger
              const Text(
                'Transaction History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (friendTxs.isEmpty)
                const EmptyStateView(
                  icon: Icons.receipt_long,
                  title: 'No Shared Transactions',
                  message: 'No transactions logged with this friend yet.',
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: friendTxs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final tx = friendTxs[index];
                    return AppCard(
                      onTap: () =>
                          context.push('/transactions/detail/${tx.id}'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx.description,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormatter.formatFull(tx.date),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          BalancePill(
                            amountMinor: tx.amountMinor,
                            isDebt: tx.isDebt,
                            isSettled: tx.isSettled,
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
