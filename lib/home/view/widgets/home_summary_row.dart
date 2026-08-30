import 'package:budget_wise/transaction/view/widgets/all_transactions_bottom_sheet.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/widgets/summary_card.dart';
import 'package:flutter/material.dart';

class HomeSummaryRow extends StatelessWidget {
  final double totalIncome;
  final double totalExpenses;
  final String currencySymbol;
  final bool isCollapsed;

  const HomeSummaryRow({
    super.key,
    required this.totalIncome,
    required this.totalExpenses,
    required this.currencySymbol,
    required this.isCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SummaryCard(
            title: context.l10n.income,
            amount: totalIncome.toStringAsFixed(0),
            amountColor: AppColors.income,
            onTap: () {
              AllTransactionsBottomSheet.show(context, initialTab: 'income');
            },
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: SummaryCard(
            title: context.l10n.spent,
            amount: totalExpenses.toStringAsFixed(0),
            amountColor: AppColors.expense,
            onTap: () {
              AllTransactionsBottomSheet.show(context, initialTab: 'expense');
            },
          ),
        ),
      ],
    );
  }
}
