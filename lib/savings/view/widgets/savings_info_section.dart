import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class SavingsInfoSection extends StatelessWidget {
  final ValueNotifier<bool> isByAmountNotifier;

  const SavingsInfoSection({super.key, required this.isByAmountNotifier});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                  isByAmount ? l10n.infoEnterAmount : l10n.infoEnterDays,
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
