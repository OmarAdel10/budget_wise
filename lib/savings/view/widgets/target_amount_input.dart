import 'package:budget_wise/shared/widgets/balance_input_with_currency.dart';
import 'package:flutter/material.dart';
import 'package:budget_wise/savings/data/models/savings_model.dart';

class TargetAmountInput extends StatelessWidget {
  final ValueNotifier<bool> isByAmountNotifier;
  final ValueNotifier<SavingsMethod> selectedMethodNotifier;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueNotifier<String?> selectedCurrencyNotifier;
  final VoidCallback onChanged;

  const TargetAmountInput({
    super.key,
    required this.isByAmountNotifier,
    required this.selectedMethodNotifier,
    required this.controller,
    required this.focusNode,
    required this.selectedCurrencyNotifier,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        isByAmountNotifier,
        selectedMethodNotifier,
      ]),
      builder: (context, _) {
        final isByAmount = isByAmountNotifier.value;
        final selectedMethod = selectedMethodNotifier.value;
        final isInteractive =
            isByAmount || selectedMethod == SavingsMethod.custom;

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isInteractive ? 1.0 : 0.6,
          child: BalanceInputWithCurrency.savingBalance(
            balanceController: controller,
            selectedCurrency: selectedCurrencyNotifier,
          ),
        );
      },
    );
  }
}
