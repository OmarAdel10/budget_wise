import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LowBalanceBanner extends StatelessWidget {
  const LowBalanceBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final warningText = AppLocalizations.of(
      context,
    )!.yourAccountBalanceIsBelowTheSpecifiedLowBalanceAmount;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            offset: const Offset(2, 4),
            color: AppColors.danger.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            PhosphorIconsBold.warning,
            color: AppColors.danger,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              warningText,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
