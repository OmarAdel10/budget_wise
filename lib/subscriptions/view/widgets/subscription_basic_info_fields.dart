import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/widgets/balance_input_with_currency.dart';
import 'package:budget_wise/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class SubscriptionBasicInfoFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController amountController;
  final ValueNotifier<String?>? selectedCurrency;

  const SubscriptionBasicInfoFields({
    super.key,
    required this.nameController,
    required this.amountController,
    required this.selectedCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          hintText: context.l10n.subscriptionNameHint,
          controller: nameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.l10n.subNameCantLeftEmpty;
            }

            if (value.length < 3) {
              return context.l10n.youShouldEnterMoreThan3Characters;
            }

            return null;
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        BalanceInputWithCurrency(
          balanceController: amountController,
          hasCurrencyPrefix: true,
          selectedCurrency: selectedCurrency,
          hasTitle: false,
          hasDecoration: false,
          hasPadding: false,
          hint: context.l10n.amount,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.l10n.amountCantLeftEmpty;
            }

            if (value.isEmpty) {
              return context.l10n.amountGreaterThan1;
            }

            return null;
          },
        ),
      ],
    );
  }
}
