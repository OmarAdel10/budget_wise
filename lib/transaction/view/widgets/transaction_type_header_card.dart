import 'package:flutter/material.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class TransactionTypeHeaderCard extends StatelessWidget {
  final String label;
  final String amount;
  final String currencySymbol;
  final bool isIncome;

  const TransactionTypeHeaderCard({
    super.key,
    required this.label,
    required this.amount,
    required this.currencySymbol,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "$currencySymbol $amount",
            style: AppTextStyles.heading1.copyWith(
              color: isIncome ? AppColors.primaryAccent : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}
