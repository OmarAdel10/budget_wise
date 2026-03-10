import 'package:budget_wise/accounts/data/models/card_formatters.dart';
import 'package:budget_wise/accounts/view/widgets/validation_icon.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccountExpiryDateField extends StatelessWidget {
  const AccountExpiryDateField({
    super.key,
    required this.l10n,
    required this.expiryController,
    required this.isExpiryValid,
    required this.onValidateExpiryDate,
    this.hasPadding = true,
  });

  final AppLocalizations l10n;
  final TextEditingController expiryController;
  final ValueNotifier<bool> isExpiryValid;
  final Function(String) onValidateExpiryDate;
  final bool hasPadding;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: hasPadding ? const EdgeInsets.all(AppSpacing.lg) : null,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.addAccountCardExpiryLabel,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            CustomTextField(
              bgColor: AppColors.inputBackground,
              controller: expiryController,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
                CardExpirationFormatter(),
              ],
              suffixIcon: ValueListenableBuilder<bool>(
                valueListenable: isExpiryValid,
                builder: (context, expiryValid, child) {
                  return ValidationIcon(
                    isValid: expiryValid,
                    text: expiryController.text,
                  );
                },
              ),
              hintText: 'MM/YY',
              keyboardType: TextInputType.number,
              onChanged: onValidateExpiryDate,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.expiryDateCantLeftEmpty;
                }
                if (isExpiryValid.value == false) {
                  return l10n.youShouldEnterAValidExpiryDate;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
