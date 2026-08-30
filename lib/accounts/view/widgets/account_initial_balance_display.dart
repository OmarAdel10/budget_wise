import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccountInitialBalanceDisplay extends StatelessWidget {
  const AccountInitialBalanceDisplay({
    super.key,
    required this.selectedCurrency,
    required this.balanceController,
  });

  final ValueNotifier<String?> selectedCurrency;
  final TextEditingController balanceController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Text(
            context.l10n.addAccountInitialBalanceLabel,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ListenableBuilder(
          listenable: Listenable.merge([selectedCurrency, balanceController]),
          builder: (context, _) {
            final currency = selectedCurrency.value;
            final balanceText = balanceController.text;
            return Center(
              child: Text(
                '${NumberFormat.simpleCurrency(name: currency).currencyName}${balanceText.isEmpty ? '0.00' : balanceText}',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.primaryAccent,
                  fontSize: 36,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
