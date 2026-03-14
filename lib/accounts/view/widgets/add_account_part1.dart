import 'package:budget_wise/shared/widgets/balance_input_with_currency.dart';
import 'package:budget_wise/accounts/view/widgets/account_type_selection.dart';
import 'package:budget_wise/accounts/view/widgets/account_name_input.dart';
import 'package:budget_wise/accounts/view/widgets/account_identity_section.dart';
import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/shared/constants/spacing.dart';

class AddAccountPart1 extends StatelessWidget {
  const AddAccountPart1({
    super.key,
    required this.l10n,
    required this.formKey,
    required this.accountNameController,
    required this.balanceController,
    required this.selectedAccount,
    required this.onAccountTypeSelected,
    required this.selectedCurrency,
    required this.onCurrencySelected,
  });

  final AppLocalizations l10n;
  final GlobalKey<FormState> formKey;
  final TextEditingController accountNameController;
  final TextEditingController balanceController;
  final ValueNotifier<AccountType> selectedAccount;
  final ValueChanged<AccountType> onAccountTypeSelected;
  final ValueNotifier<String?> selectedCurrency;
  final ValueChanged<String> onCurrencySelected;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccountIdentitySection(l10n: l10n),

          //* Account Name
          AccountNameInput(
            l10n: l10n,
            accountNameController: accountNameController,
          ),

          const SizedBox(height: AppSpacing.lg),
          AccountTypeSelection(
            l10n: l10n,
            selectedAccount: selectedAccount,
            onAccountTypeSelected: onAccountTypeSelected,
          ),

          const SizedBox(height: AppSpacing.lg),
          //* Initial Balance
          BalanceInputWithCurrency(
            balanceController: balanceController,
            selectedCurrency: selectedCurrency,
          ),
        ],
      ),
    );
  }
}
