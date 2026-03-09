import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../constants/spacing.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color? amountColor;
  final bool isCompact;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    this.amountColor,
    this.isCompact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isCompact ? AppSpacing.md : AppSpacing.lg),
        decoration: BoxDecoration(
          color: isCompact
              ? AppColors.cardBackground
              : AppColors.cardBackground.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(
            isCompact ? AppSpacing.radiusMd : AppSpacing.radiusSm,
          ),
          border: isCompact ? null : Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          mainAxisAlignment: isCompact
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isCompact
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
                fontWeight: isCompact ? FontWeight.normal : FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              amount,
              style:
                  (isCompact ? AppTextStyles.heading3 : AppTextStyles.heading2)
                      .copyWith(color: amountColor ?? AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
