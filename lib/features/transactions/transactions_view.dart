import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookkeeping_app/app/providers.dart';
import 'package:bookkeeping_app/app/theme/app_colors.dart';
import 'package:bookkeeping_app/core/formatting/date_formatter.dart';
import 'package:bookkeeping_app/core/widgets/app_card.dart';
import 'package:bookkeeping_app/core/widgets/avatar_badge.dart';
import 'package:bookkeeping_app/core/widgets/balance_pill.dart';
import 'package:bookkeeping_app/core/widgets/empty_state_view.dart';
import 'package:bookkeeping_app/domain/entities/filter_criteria.dart';

class TransactionsView extends ConsumerStatefulWidget {
  const TransactionsView({super.key});

  @override
  ConsumerState<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends ConsumerState<TransactionsView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsListProvider);
    final friendsAsync = ref.watch(friendsListProvider);
    final filter = ref.watch(transactionFilterProvider);

    final friendsMap = friendsAsync.maybeWhen(
      data: (list) => {for (var f in list) f.id: f.name},
      orElse: () => <String, String>{},
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle,
              color: AppColors.primary,
              size: 28,
            ),
            tooltip: 'Add Transaction',
            onPressed: () => context.push('/transactions/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search description or category...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(transactionFilterProvider.notifier)
                              .setSearchQuery('');
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                ref
                    .read(transactionFilterProvider.notifier)
                    .setSearchQuery(val);
              },
            ),
          ),

          // Filter Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterChip(
                  'All',
                  DirectionFilter.all,
                  filter.directionFilter,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Owed to me',
                  DirectionFilter.owedToUser,
                  filter.directionFilter,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'I owe',
                  DirectionFilter.owes,
                  filter.directionFilter,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Settled',
                  DirectionFilter.settled,
                  filter.directionFilter,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Transactions List
          Expanded(
            child: transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (txs) {
                if (txs.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.search_off_rounded,
                    title: 'No Matching Transactions',
                    message:
                        'Try clearing your search or change the filter tab.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: txs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final tx = txs[index];
                    final friendName = friendsMap[tx.friendId] ?? 'Friend';

                    return AppCard(
                      onTap: () =>
                          context.push('/transactions/detail/${tx.id}'),
                      child: Row(
                        children: [
                          AvatarBadge(
                            initials: friendName.isNotEmpty
                                ? friendName[0]
                                : '?',
                            radius: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx.description,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$friendName • ${DateFormatter.formatFull(tx.date)}',
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
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    DirectionFilter value,
    DirectionFilter current,
  ) {
    final isSelected = value == current;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        ref.read(transactionFilterProvider.notifier).setDirectionFilter(value);
      },
    );
  }
}
