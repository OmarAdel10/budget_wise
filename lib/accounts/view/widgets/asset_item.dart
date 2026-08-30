import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/widgets/generic_icon_container.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class AssetItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String amount;
  final bool isWarningEnabled;
  final bool? isSelected;
  final bool isSelectable;

  const AssetItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.amount,
    this.isWarningEnabled = false,
  }) : isSelected = null,
       isSelectable = false;

  const AssetItem.selectable({
    super.key,
    required this.icon,
    required this.title,
    required this.amount,
    this.isWarningEnabled = false,
    required this.isSelected,
  }) : subtitle = null,
       isSelectable = true;

  @override
  Widget build(BuildContext context) {
    Widget widget = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isWarningEnabled
                  ? AppColors.danger.withValues(alpha: 0.6)
                  : isSelected != null && isSelected!
                  ? AppColors.primaryAccent.withValues(alpha: 0.6)
                  : AppColors.borderColor.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            children: [
              GenericIconContainer(
                icon: icon,
                color: AppColors.textSecondary,
                borderRadius: 10,
                backgroundOpacity: 0.12,
                size: 34,
                iconSize: 22,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    subtitle != null
                        ? Text(subtitle!, style: AppTextStyles.bodySmall)
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
              Text(
                amount,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected != null && isSelected!
                      ? AppColors.primaryAccent
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        if (isWarningEnabled) ...[
          Positioned(
            right: -10,
            top: -10,
            child: const Icon(
              PhosphorIconsBold.warning,
              color: AppColors.danger,
            ),
          ),
        ],
      ],
    );

    if (isSelectable) {
      return Column(
        children: [
          widget,
          const SizedBox(height: AppSpacing.md),
        ],
      );
    }

    return widget;
  }
}
