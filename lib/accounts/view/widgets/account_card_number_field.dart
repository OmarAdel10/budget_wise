import 'package:budget_wise/accounts/data/models/card_formatters.dart';
import 'package:budget_wise/accounts/view/widgets/validation_icon.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';

import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccountCardNumberField extends StatelessWidget {
  const AccountCardNumberField({
    super.key,
    required this.cardNumberController,
    required this.isCardValid,
    required this.onValidateCardNumber,
    required this.determineCardType,
    this.hasPadding = true,
  });

  final TextEditingController cardNumberController;
  final ValueNotifier<bool> isCardValid;
  final Function(String) onValidateCardNumber;
  final Function(String) determineCardType;
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
            context.l10n.addAccountCardNumberLabel,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          CustomTextField(
            bgColor: AppColors.inputBackground,
            controller: cardNumberController,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              CardNumberFormatter(),
            ],
            suffixIcon: ValueListenableBuilder<bool>(
              valueListenable: isCardValid,
              builder: (context, cardValid, child) {
                return ValidationIcon(
                  isValid: cardValid,
                  text: cardNumberController.text,
                );
              },
            ),
            hintText: '0000 0000 0000 0000',
            keyboardType: TextInputType.number,
            onChanged: (value) {
              determineCardType(value.replaceAll(' ', ''));
              onValidateCardNumber(value);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l10n.cardNumberCantLeftEmpty;
              }
              if (isCardValid.value == false) {
                return context.l10n.youShouldEnterAValidCardNumber;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
