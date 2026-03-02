import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/widgets/generic_icon_container.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AssetItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final bool isWarningEnabled;

  const AssetItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.isWarningEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isWarningEnabled
                  ? AppColors.danger.withValues(alpha: 0.6)
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
                    Text(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Text(
                amount,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
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
  }
}
