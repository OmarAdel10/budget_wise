import 'package:budget_wise/transaction/view/screens/transaction_type_detail_screen.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
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
    final l10n = AppLocalizations.of(context)!;

    if (isCollapsed) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${l10n.income}: ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '$currencySymbol ${totalIncome.toStringAsFixed(0)}',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.primaryAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            '|',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            '${l10n.expenses}: ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '$currencySymbol ${totalExpenses.toStringAsFixed(0)}',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.danger,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: SummaryCard(
            title: l10n.income,
            amount: "$currencySymbol ${totalIncome.toStringAsFixed(0)}",
            amountColor: AppColors.primaryAccent,
            onTap: () {
              Navigator.of(context).pushNamed(
                TransactionTypeDetailScreen.routeName,
                arguments: {'type': 'income'},
              );
            },
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: SummaryCard(
            title: l10n.expenses,
            amount: "$currencySymbol ${totalExpenses.toStringAsFixed(0)}",
            amountColor: AppColors.danger,
            onTap: () {
              Navigator.of(context).pushNamed(
                TransactionTypeDetailScreen.routeName,
                arguments: {'type': 'outcome'},
              );
            },
          ),
        ),
      ],
    );
  }
}
