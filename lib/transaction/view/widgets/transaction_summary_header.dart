import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';

class TransactionSummaryHeader extends StatelessWidget {
  final double income;
  final double expenses;
  final String currencySymbol;

  const TransactionSummaryHeader({
    super.key,
    required this.income,
    required this.expenses,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
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
            '$currencySymbol ${income.toStringAsFixed(1)}',
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
            '$currencySymbol ${expenses.toStringAsFixed(1)}',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.danger,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
