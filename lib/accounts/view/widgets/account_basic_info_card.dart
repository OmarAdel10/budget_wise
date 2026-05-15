import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/view/widgets/account_bank_name_field.dart';
import 'package:budget_wise/accounts/view/widgets/account_card_number_field.dart';
import 'package:budget_wise/accounts/view/widgets/account_expiry_date_field.dart';
import 'package:budget_wise/accounts/view/widgets/account_name_input.dart';
import 'package:budget_wise/accounts/view/widgets/account_phone_number_field.dart';
import 'package:budget_wise/accounts/view/widgets/account_wallet_provider_field.dart';
import 'package:budget_wise/accounts/utils/card_validation_mixin.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:flutter/material.dart';

class AccountBasicInfoCard extends StatelessWidget {
  final AccountType accountType;
  final TextEditingController accountNameController;
  final TextEditingController cardNumberController;
  final TextEditingController expiryController;
  final TextEditingController? phoneNumberController;
  final ValueNotifier<String?> selectedBankNameNotifier;
  final ValueNotifier<List<String>?> selectedBankSenderIdsNotifier;
  final ValueNotifier<String?>? selectedWalletProviderNotifier;
  final CardValidationMixin cardValidationMixin;

  const AccountBasicInfoCard({
    super.key,
    required this.accountType,
    required this.accountNameController,
    required this.cardNumberController,
    required this.expiryController,
    required this.selectedBankNameNotifier,
    required this.selectedBankSenderIdsNotifier,
    required this.cardValidationMixin,
    this.phoneNumberController,
    this.selectedWalletProviderNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccountNameInput(
            l10n: l10n,
            accountNameController: accountNameController,
            hasPadding: false,
          ),
          if (accountType == AccountType.card) ...[
            const SizedBox(height: AppSpacing.md),
            AccountBankNameField(
              l10n: l10n,
              selectedBankName: selectedBankNameNotifier,
              onBankSelected: (bankName, senderIds) {
                selectedBankNameNotifier.value = bankName;
                selectedBankSenderIdsNotifier.value = senderIds;
              },
              hasPadding: false,
            ),
            const SizedBox(height: AppSpacing.md),
            AccountCardNumberField(
              l10n: l10n,
              cardNumberController: cardNumberController,
              isCardValid: cardValidationMixin.isCardValidNotifier,
              onValidateCardNumber: cardValidationMixin.validateCardNumber,
              determineCardType: cardValidationMixin.determineCardType,
              hasPadding: false,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                AccountExpiryDateField(
                  l10n: l10n,
                  expiryController: expiryController,
                  isExpiryValid: cardValidationMixin.isExpiryValidNotifier,
                  onValidateExpiryDate: cardValidationMixin.validateExpiryDate,
                  hasPadding: false,
                ),
              ],
            ),
          ] else if (accountType == AccountType.wallet) ...[
            const SizedBox(height: AppSpacing.md),
            AccountWalletProviderField(
              l10n: l10n,
              selectedProvider: selectedWalletProviderNotifier!,
              onProviderSelected: (providerName) {
                selectedWalletProviderNotifier!.value = providerName;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AccountPhoneNumberField(
              l10n: l10n,
              phoneNumberController: phoneNumberController!,
            ),
          ],
        ],
      ),
    );
  }
}
