import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:budget_wise/savings/data/models/savings_model.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class SavingGoalCard extends StatelessWidget {
  final SavingsModel goal;
  final String formattedProgress;
  final String formattedAmount;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const SavingGoalCard({
    super.key,
    required this.goal,
    required this.formattedProgress,
    required this.formattedAmount,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (goal.currentAmount / goal.targetAmount).clamp(
      0.0,
      1.0,
    );

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Slidable(
            endActionPane: ActionPane(
              motion: const StretchMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (context) => onDelete(),
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                  icon: PhosphorIconsBold.trash,
                  borderRadius: BorderRadius.circular(
                    AppSpacing.radiusSm,
                  ),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(
                  AppSpacing.radiusMd,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        goal.name,
                        style: AppTextStyles.heading3,
                      ),
                      Text(
                        formattedProgress,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(
                        formattedAmount,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.primaryBackground,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(goal.colorValue),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
