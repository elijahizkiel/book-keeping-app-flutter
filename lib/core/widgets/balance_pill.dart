import 'package:flutter/material.dart';
import 'package:bookkeeping_app/app/theme/app_colors.dart';
import 'package:bookkeeping_app/core/formatting/money_formatter.dart';

class BalancePill extends StatelessWidget {
  final int amountMinor;
  final bool isDebt;
  final bool isSettled;

  const BalancePill({
    super.key,
    required this.amountMinor,
    required this.isDebt,
    this.isSettled = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSettled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Settled',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      );
    }

    final color = isDebt ? AppColors.debt : AppColors.credit;
    final bgColor = isDebt ? AppColors.debtLight : AppColors.creditLight;
    final prefix = isDebt ? 'You owe ' : 'Owed ';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDebt ? Icons.arrow_downward : Icons.arrow_upward,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '$prefix${MoneyFormatter.format(amountMinor)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
