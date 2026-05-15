import 'package:budget_wise/accounts/view/widgets/account_initial_balance_display.dart';
import 'package:budget_wise/accounts/view/widgets/account_phone_number_field.dart';
import 'package:budget_wise/accounts/view/widgets/account_wallet_provider_field.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:flutter/material.dart';

class AddAccountPartWallet extends StatelessWidget {
  const AddAccountPartWallet({
    super.key,
    required this.l10n,
    required this.formKey,
    required this.selectedCurrency,
    required this.balanceController,
    required this.phoneNumberController,
    required this.selectedProvider,
    required this.onProviderSelected,
  });

  final AppLocalizations l10n;
  final GlobalKey<FormState> formKey;
  final ValueNotifier<String?> selectedCurrency;
  final TextEditingController balanceController;
  final TextEditingController phoneNumberController;
  final ValueNotifier<String?> selectedProvider;
  final Function(String providerName) onProviderSelected;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AccountInitialBalanceDisplay(
            l10n: l10n,
            selectedCurrency: selectedCurrency,
            balanceController: balanceController,
          ),
          const SizedBox(height: AppSpacing.lg),
          AccountWalletProviderField(
            l10n: l10n,
            selectedProvider: selectedProvider,
            onProviderSelected: onProviderSelected,
          ),
          const SizedBox(height: AppSpacing.md),
          AccountPhoneNumberField(
            l10n: l10n,
            phoneNumberController: phoneNumberController,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
