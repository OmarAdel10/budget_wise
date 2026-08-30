import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class SavingGoalInfoSection extends StatelessWidget {
  final ValueNotifier<bool> isByAmountNotifier;

  const SavingGoalInfoSection({super.key, required this.isByAmountNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isByAmountNotifier,
      builder: (context, isByAmount, _) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  isByAmount
                      ? context.l10n.infoEnterAmount
                      : context.l10n.infoEnterDays,
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
