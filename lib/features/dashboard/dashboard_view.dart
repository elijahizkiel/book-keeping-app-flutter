import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookkeeping_app/app/providers.dart';
import 'package:bookkeeping_app/app/theme/app_colors.dart';
import 'package:bookkeeping_app/core/formatting/money_formatter.dart';
import 'package:bookkeeping_app/core/formatting/date_formatter.dart';
import 'package:bookkeeping_app/core/widgets/app_card.dart';
import 'package:bookkeeping_app/core/widgets/avatar_badge.dart';
import 'package:bookkeeping_app/core/widgets/balance_pill.dart';
import 'package:bookkeeping_app/core/widgets/empty_state_view.dart';
import 'package:bookkeeping_app/domain/entities/filter_criteria.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(balanceSummaryProvider);
    final transactionsAsync = ref.watch(transactionsListProvider);
    final friendsAsync = ref.watch(friendsListProvider);
    final prefs = ref.watch(preferencesStateProvider);
    final filter = ref.watch(transactionFilterProvider);

    final friendsMap = friendsAsync.maybeWhen(
      data: (list) => {for (var f in list) f.id: f.name},
      orElse: () => <String, String>{},
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${prefs.userName}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Text(
              'Financial Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Help & FAQs',
            onPressed: () => context.push('/help'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(transactionsListProvider);
          ref.invalidate(friendsListProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Net Balance Hero Card
            AppCard(
              backgroundColor: balance.isNegative
                  ? AppColors.debt
                  : AppColors.primary,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Net Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          balance.isNegative
                              ? 'You Owe Net'
                              : (balance.isPositive
                                    ? 'You Are Owed Net'
                                    : 'Settled Up'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    MoneyFormatter.format(
                      balance.netBalanceMinor,
                      currencyCode: prefs.currencyCode,
                      symbol: prefs.currencySymbol,
                      showSign: true,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Owed to You & You Owe Row
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.arrow_upward,
                              size: 16,
                              color: AppColors.credit,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Owed to you',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          MoneyFormatter.format(
                            balance.owedToUserMinor,
                            currencyCode: prefs.currencyCode,
                            symbol: prefs.currencySymbol,
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.credit,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.arrow_downward,
                              size: 16,
                              color: AppColors.debt,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'You owe',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          MoneyFormatter.format(
                            balance.owedByUserMinor,
                            currencyCode: prefs.currencyCode,
                            symbol: prefs.currencySymbol,
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.debt,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => context.push('/transactions/new'),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add Expense'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    onPressed: () => context.push('/friends/new'),
                    icon: const Icon(
                      Icons.person_add_alt_1,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    label: const Text(
                      'Add Friend',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Date Range Filters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                DropdownButton<DateRangeFilter>(
                  value: filter.dateRangeFilter,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: DateRangeFilter.allTime,
                      child: Text('All Time'),
                    ),
                    DropdownMenuItem(
                      value: DateRangeFilter.thisMonth,
                      child: Text('This Month'),
                    ),
                    DropdownMenuItem(
                      value: DateRangeFilter.last30Days,
                      child: Text('Last 30 Days'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      ref
                          .read(transactionFilterProvider.notifier)
                          .setDateRangeFilter(val);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Recent Transactions List
            transactionsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) =>
                  Center(child: Text('Error loading activity: $e')),
              data: (txs) {
                if (txs.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.receipt_long_outlined,
                    title: 'No Transactions Yet',
                    message: 'Add your first transaction with a friend to get started.',
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: txs.length.clamp(0, 10),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final tx = txs[index];
                    final friendName =
                        friendsMap[tx.friendId] ?? 'Unknown Friend';

                    return AppCard(
                      onTap: () =>
                          context.push('/transactions/detail/${tx.id}'),
                      child: Row(
                        children: [
                          AvatarBadge(
                            initials: friendName.isNotEmpty
                                ? friendName[0]
                                : '?',
                            radius: 20,
                          ),
                          const SizedBox(width: 12),
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
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$friendName • ${DateFormatter.formatRelative(tx.date)}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          BalancePill(
                            amountMinor: tx.amountMinor,
                            isDebt: tx.isDebt,
                            isSettled: tx.isSettled,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
