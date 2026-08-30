import 'package:flutter/material.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import '../../data/models/saving_goal_model.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';

class SavingProgressHeader extends StatelessWidget {
  final SavingGoalModel goal;
  final double progress;
  final int percentage;

  const SavingProgressHeader({
    super.key,
    required this.goal,
    required this.progress,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
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
                Text(
                  context.l10n.overallProgress,
                  style: AppTextStyles.bodyMedium,
                ),
                Text(
                  "$percentage%",
                  style: AppTextStyles.heading3.copyWith(
                    color: Color(goal.colorValue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${goal.currency}${goal.currentAmount.toInt()}",
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  "/ ${goal.currency}${goal.targetAmount.toInt()}",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.primaryBackground,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(goal.colorValue),
                ),
                minHeight: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
