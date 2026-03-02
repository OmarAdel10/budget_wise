import 'package:budget_wise/accounts/view/widgets/account_balance_input.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:flutter/material.dart';

class AccountFinancialsCard extends StatelessWidget {
  final TextEditingController balanceController;
  final ValueNotifier<String?> selectedCurrencyNotifier;

  const AccountFinancialsCard({
    super.key,
    required this.balanceController,
    required this.selectedCurrencyNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccountBalanceInput(
            balanceController: balanceController,
            selectedCurrency: selectedCurrencyNotifier,
            hasPadding: false,
            isInitialBalanceField: false,
          ),
        ],
      ),
    );
  }
}
