import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class AccountCardHolderField extends StatelessWidget {
  const AccountCardHolderField({
    super.key,
    required this.l10n,
    required this.cardHolderController,
  });

  final AppLocalizations l10n;
  final TextEditingController cardHolderController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.addAccountCardHolderLabel,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          CustomTextField(
            bgColor: AppColors.inputBackground,
            controller: cardHolderController,
            hintText: l10n.addAccountCardHolderPlaceholder,
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.cardHolderCantLeftEmpty;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
