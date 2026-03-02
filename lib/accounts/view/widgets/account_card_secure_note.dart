import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';

class AccountCardSecureNote extends StatelessWidget {
  const AccountCardSecureNote({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      alignment: AlignmentGeometry.center,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.addAccountCardSecureNote,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            l10n.disclaimer,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
