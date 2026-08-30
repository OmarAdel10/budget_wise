import 'package:auto_size_text/auto_size_text.dart';
import 'package:budget_wise/shared/utils/app_box_shadow.dart';
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
  final bool hasFixedHeight;
  final bool _subscriptionScreen;
  final Widget? thirdWidget;
  final double biggerHeightBy;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    this.amountColor,
    this.icon,
    this.iconColor,
    this.isCompact = false,
    this.onTap,
    this.hasFixedHeight = false,
    this.biggerHeightBy = 0.0,
  }) : _subscriptionScreen = false,
       thirdWidget = null;

  const SummaryCard.subscriptions({
    super.key,
    required this.title,
    required this.amount,
    this.amountColor,
    this.icon,
    this.iconColor,
    this.isCompact = false,
    this.onTap,
    required this.thirdWidget,
  }) : _subscriptionScreen = true,
       hasFixedHeight = false,
       biggerHeightBy = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: hasFixedHeight
            ? MediaQuery.sizeOf(context).height * (0.11 + biggerHeightBy)
            : null,
        padding: EdgeInsets.all(isCompact ? AppSpacing.md : AppSpacing.lg),
        decoration: BoxDecoration(
          color: isCompact
              ? AppColors.cardBackground
              : AppColors.cardBackground.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: isCompact ? null : Border.all(color: AppColors.borderColor),
          boxShadow: [AppBoxShadow()]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: _subscriptionScreen
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
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
            AutoSizeText(
              amount,
              maxLines: 1,
              minFontSize: AppTextStyles.bodyLarge.fontSize!,
              style:
                  (isCompact ? AppTextStyles.heading3 : AppTextStyles.heading2)
                      .copyWith(color: amountColor ?? AppColors.textPrimary),
            ),
            if (_subscriptionScreen) ...[
              const SizedBox(height: AppSpacing.sm),
              thirdWidget!,
            ],
          ],
        ),
      ),
    );
  }
}
