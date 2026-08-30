import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class AccountPhoneNumberField extends StatelessWidget {
  const AccountPhoneNumberField({
    super.key,
    required this.phoneNumberController,
  });

  final TextEditingController phoneNumberController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.addAccountPhoneNumberLabel,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: phoneNumberController,
          keyboardType: TextInputType.phone,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: context.l10n.addAccountPhoneNumberPlaceholder,
            prefixIcon: Icon(
              PhosphorIconsRegular.phone,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.l10n.phoneNumberCantLeftEmpty;
            }
            if (value.length < 11) {
              return context.l10n.youShouldEnterAValidPhoneNumber;
            }
            return null;
          },
        ),
      ],
    );
  }
}
