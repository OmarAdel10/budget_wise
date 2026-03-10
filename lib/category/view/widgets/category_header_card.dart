import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class CategoryHeaderCard extends StatelessWidget {
  final String title;
  final double totalSpending;
  final double? budgetAmount;
  final bool hasBudgetAmount;
  final IconData icon;
  final double? progress;

  const CategoryHeaderCard({
    super.key,
    required this.title,
    required this.totalSpending,
    this.budgetAmount,
    required this.hasBudgetAmount,
    required this.icon,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.totalSpent,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "\$${totalSpending.toInt()}",
                        style: AppTextStyles.heading2,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      if (hasBudgetAmount)
                        Text(
                          "/ \$${budgetAmount?.toInt() ?? 0}",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Icon(icon, size: 40),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Progress Bar with percentage
          if (progress != null) ...[
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress!.clamp(0.0, 1.0),
                      backgroundColor: AppColors.primaryBackground,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress! > 1.0 ? Colors.red : AppColors.primaryAccent,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${(progress! * 100).clamp(0, 999).toInt()}%',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: progress! > 1.0
                        ? Colors.red
                        : AppColors.primaryAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
