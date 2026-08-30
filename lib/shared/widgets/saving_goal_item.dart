import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../constants/spacing.dart';

class SavingGoalItem extends StatelessWidget {
  final String name;
  final double currentAmount;
  final double targetAmount;
  final String? imageUrl;
  final VoidCallback onTap;

  const SavingGoalItem({
    super.key,
    required this.name,
    required this.currentAmount,
    required this.targetAmount,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = (currentAmount / targetAmount).clamp(0.0, 1.0);
    final int percentageInt = (percentage * 100).toInt();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                image: imageUrl != null && imageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null || imageUrl!.isEmpty
                  ? Icon(
                      PhosphorIconsRegular.piggyBank,
                      color: AppColors.textSecondary,
                      size: 24,
                    )
                  : null,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${currentAmount.toStringAsFixed(0)} / \$${targetAmount.toStringAsFixed(0)}',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Row(
              children: [
                SizedBox(
                  width: 88,
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: AppColors.borderColor,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryAccent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '$percentageInt%',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
