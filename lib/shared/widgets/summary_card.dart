import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../constants/spacing.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color? amountColor;
  final IconData? icon;
  final Color? iconColor;
  final bool isCompact;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    this.amountColor,
    this.icon,
    this.iconColor,
    this.isCompact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasFixedHeight = isCompact;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: hasFixedHeight
            ? MediaQuery.sizeOf(context).height * 0.11
            : null,
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: iconColor ?? AppColors.textSecondary),
              const SizedBox(height: AppSpacing.sm),
            ],
            AutoSizeText(
              title,
              maxLines: 1,
              minFontSize: AppTextStyles.bodySmall.fontSize!,
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
