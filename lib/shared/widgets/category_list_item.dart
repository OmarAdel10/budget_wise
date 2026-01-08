import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../constants/spacing.dart';

class CategoryListItem extends StatelessWidget {
  final String name;
  final String amount;
  final String totalBudget;
  final IconData icon;
  final VoidCallback onTap;
  final bool hasBudgetAmount;

  const CategoryListItem({
    super.key,
    required this.name,
    required this.amount,
    required this.totalBudget,
    required this.icon,
    required this.onTap,
    this.progress,
    this.hasBudgetAmount = false,
  });

  final double? progress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        color: Colors.transparent, // Ensures tap target
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(icon, color: AppColors.textPrimary, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  hasBudgetAmount
                      ? Text(
                          '\$$amount Spent / \$$totalBudget Total Budget',
                          style: AppTextStyles.bodyMedium,
                        )
                      : Text('Has No Budget', style: AppTextStyles.bodyMedium),
                  if (progress != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      child: LinearProgressIndicator(
                        value: progress!.clamp(0.0, 1.0),
                        backgroundColor: AppColors.cardBackground,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress! > 1.0
                              ? Colors.red
                              : AppColors.primaryAccent,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
