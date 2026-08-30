import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class AccountNameInput extends StatelessWidget {
  const AccountNameInput({
    super.key,
    required this.accountNameController,
    this.hasPadding = true,
  });

  final TextEditingController accountNameController;
  final bool hasPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: hasPadding ? const EdgeInsets.all(AppSpacing.lg) : null,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.addAccountAccountNameLabel,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          CustomTextField(
            activeColor: AppColors.primaryAccent,
            bgColor: AppColors.inputBackground,
            keyboardType: TextInputType.name,
            controller: accountNameController,
            hintText: context.l10n.addAccountAccountNamePlaceholder,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l10n.accountNameCantLeftEmpty;
              }

              if (value.length < 3) {
                return context.l10n.youShouldEnterMoreThan3Characters;
              }

              return null;
            },
          ),
        ],
      ),
    );
  }
}
