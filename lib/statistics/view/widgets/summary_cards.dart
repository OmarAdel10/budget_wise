import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/home/view/screens/transaction_type_detail_screen.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class SummaryCards extends StatelessWidget {
  final double totalIncome;
  final double totalExpenses;
  final double totalSavings;
  final double totalSubscriptions;

  const SummaryCards({
    super.key,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalSavings,
    required this.totalSubscriptions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    TransactionTypeDetailScreen.routeName,
                    arguments: {'type': 'income'},
                  );
                },
                child: SummaryCard(
                  title: l10n.totalIncome,
                  amount: totalIncome,
                  amountColor: AppColors.income,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    TransactionTypeDetailScreen.routeName,
                    arguments: {'type': 'outcome'},
                  );
                },
                child: SummaryCard(
                  title: l10n.totalExpenses,
                  amount: totalExpenses,
                  amountColor: AppColors.expense,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: l10n.currentSavings,
                amount: totalSavings,
                amountColor: AppColors.savings,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: SummaryCard(
                title: l10n.totalSubscriptions,
                amount: totalSubscriptions,
                amountColor: AppColors.categoryPurple,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color amountColor;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "\$${amount.toStringAsFixed(0)}",
            style: AppTextStyles.heading3.copyWith(color: amountColor),
          ),
        ],
      ),
    );
  }
}
