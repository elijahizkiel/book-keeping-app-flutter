import 'package:bookkeeping_app/domain/entities/transaction.dart';

class BalanceSummary {
  /// Total amount other people owe you (credit, positive)
  final int owedToUserMinor;

  /// Total amount you owe other people (debt, positive representation of debt sum)
  final int owedByUserMinor;

  const BalanceSummary({
    required this.owedToUserMinor,
    required this.owedByUserMinor,
  });

  static const BalanceSummary zero = BalanceSummary(
    owedToUserMinor: 0,
    owedByUserMinor: 0,
  );

  /// Net balance in cents.
  /// Positive: user is owed money overall.
  /// Negative: user owes money overall.
  int get netBalanceMinor => owedToUserMinor - owedByUserMinor;

  bool get isPositive => netBalanceMinor > 0;
  bool get isNegative => netBalanceMinor < 0;
  bool get isZero => netBalanceMinor == 0;

  /// Aggregate balance summary strictly from a list of transactions.
  /// Only pending transactions contribute to current balance.
  factory BalanceSummary.fromTransactions(Iterable<Transaction> transactions) {
    int owedToUser = 0;
    int owedByUser = 0;

    for (final tx in transactions) {
      if (tx.isSettled) continue;
      if (tx.direction == TransactionDirection.owedToUser) {
        owedToUser += tx.amountMinor;
      } else {
        owedByUser += tx.amountMinor;
      }
    }

    return BalanceSummary(
      owedToUserMinor: owedToUser,
      owedByUserMinor: owedByUser,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BalanceSummary &&
          runtimeType == other.runtimeType &&
          owedToUserMinor == other.owedToUserMinor &&
          owedByUserMinor == other.owedByUserMinor;

  @override
  int get hashCode => owedToUserMinor.hashCode ^ owedByUserMinor.hashCode;
}
