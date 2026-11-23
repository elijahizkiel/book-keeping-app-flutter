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

class TransactionDetailView extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailView({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsListProvider);
    final friendsAsync = ref.watch(friendsListProvider);
    final prefs = ref.watch(preferencesStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Transaction',
            onPressed: () => context.push('/transactions/edit/$transactionId'),
          ),
        ],
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (txs) {
          final tx = txs.cast().firstWhere(
            (t) => t.id == transactionId,
            orElse: () => null,
          );

          if (tx == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Transaction not found',
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

          final friend = friendsAsync.maybeWhen(
            data: (list) => list.cast().firstWhere(
              (f) => f.id == tx.friendId,
              orElse: () => null,
            ),
            orElse: () => null,
          );

          final friendName = friend?.name ?? 'Friend';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Amount Hero Display
              Center(
                child: Column(
                  children: [
                    AvatarBadge(
                      initials: friendName.isNotEmpty ? friendName[0] : '?',
                      radius: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      friendName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      MoneyFormatter.format(
                        tx.amountMinor,
                        currencyCode: prefs.currencyCode,
                        symbol: prefs.currencySymbol,
                      ),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: tx.isDebt ? AppColors.debt : AppColors.credit,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tx.isSettled
                          ? 'Settled'
                          : (tx.isDebt
                                ? 'You owe $friendName'
                                : '$friendName owes you'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: tx.isSettled
                            ? Colors.grey
                            : (tx.isDebt ? AppColors.debt : AppColors.credit),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Detail Details Card
              AppCard(
                child: Column(
                  children: [
                    _buildRow('Description', tx.description),
                    const Divider(),
                    _buildRow('Category', tx.category),
                    const Divider(),
                    _buildRow('Date', DateFormatter.formatFull(tx.date)),
                    if (tx.notes != null) ...[
                      const Divider(),
                      _buildRow('Notes', tx.notes!),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Actions: Settle / Delete
              if (!tx.isSettled) ...[
                AppButton(
                  label: 'Mark as Settled',
                  icon: Icons.check_circle_outline,
                  onPressed: () async {
                    await ref
                        .read(transactionsListProvider.notifier)
                        .settleTransaction(tx.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transaction marked as settled'),
                        ),
                      );
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
              AppButton(
                label: 'Delete Transaction',
                icon: Icons.delete_outline,
                variant: AppButtonVariant.danger,
                onPressed: () async {
                  await ref
                      .read(transactionsListProvider.notifier)
                      .deleteTransaction(tx.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transaction deleted')),
                    );
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
