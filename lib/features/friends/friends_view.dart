import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookkeeping_app/app/providers.dart';
import 'package:bookkeeping_app/app/theme/app_colors.dart';
import 'package:bookkeeping_app/core/widgets/app_card.dart';
import 'package:bookkeeping_app/core/widgets/avatar_badge.dart';
import 'package:bookkeeping_app/core/widgets/balance_pill.dart';
import 'package:bookkeeping_app/core/widgets/empty_state_view.dart';

class FriendsView extends ConsumerStatefulWidget {
  const FriendsView({super.key});

  @override
  ConsumerState<FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends ConsumerState<FriendsView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Friends',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person_add,
              color: AppColors.primary,
              size: 28,
            ),
            tooltip: 'Add Friend',
            onPressed: () => context.push('/friends/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Friends
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search friends by name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (val) =>
                  setState(() => _searchQuery = val.trim().toLowerCase()),
            ),
          ),

          // Friends List
          Expanded(
            child: friendsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) =>
                  Center(child: Text('Error loading friends: $err')),
              data: (friends) {
                final filtered = friends.where((f) {
                  if (_searchQuery.isEmpty) return true;
                  return f.name.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.people_outline,
                    title: _searchQuery.isEmpty
                        ? 'No Friends Added'
                        : 'No Friends Found',
                    message: _searchQuery.isEmpty
                        ? 'Add friends to start sharing expenses and tracking balances.'
                        : 'Try searching for a different name.',
                    actionLabel: _searchQuery.isEmpty ? 'Add Friend' : null,
                    onAction: _searchQuery.isEmpty
                        ? () => context.push('/friends/new')
                        : null,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final friend = filtered[index];
                    final balance = ref.watch(friendBalanceProvider(friend.id));

                    return AppCard(
                      onTap: () => context.push('/friends/detail/${friend.id}'),
                      child: Row(
                        children: [
                          AvatarBadge(initials: friend.initials, radius: 24),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  friend.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (friend.email != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    friend.email!,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          BalancePill(
                            amountMinor: balance.netBalanceMinor.abs(),
                            isDebt: balance.isNegative,
                            isSettled: balance.isZero,
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
}
