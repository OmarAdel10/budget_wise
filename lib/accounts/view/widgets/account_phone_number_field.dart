import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AccountPhoneNumberField extends StatelessWidget {
  const AccountPhoneNumberField({
    super.key,
    required this.l10n,
    required this.phoneNumberController,
  });

  final AppLocalizations l10n;
  final TextEditingController phoneNumberController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.addAccountPhoneNumberLabel,
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
            hintText: l10n.addAccountPhoneNumberPlaceholder,
            prefixIcon: Icon(
              PhosphorIcons.phone(PhosphorIconsStyle.regular),
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.phoneNumberCantLeftEmpty;
            }
            if (value.length < 11) {
              return l10n.youShouldEnterAValidPhoneNumber;
            }
            return null;
          },
        ),
      ],
    );
  }
}
