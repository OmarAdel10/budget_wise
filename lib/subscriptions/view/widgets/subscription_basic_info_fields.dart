import 'package:budget_wise/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        CustomTextField(
          hintText: l10n.subscriptionNameHint,
          controller: nameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.subNameCantLeftEmpty;
            }

            if (value.length < 3) {
              return l10n.youShouldEnterMoreThan3Characters;
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
          hint: l10n.amount,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.amountCantLeftEmpty;
            }

            if (value.isEmpty) {
              return l10n.amountGreaterThan1;
            }

            return null;
          },
        ),
      ],
    );
  }
}
