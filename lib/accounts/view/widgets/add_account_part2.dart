import 'package:budget_wise/accounts/data/models/card_brand.dart';
import 'package:budget_wise/accounts/view/widgets/account_bank_name_field.dart';
import 'package:budget_wise/accounts/view/widgets/account_card_holder_field.dart';
import 'package:budget_wise/accounts/view/widgets/account_card_number_field.dart';
import 'package:budget_wise/accounts/view/widgets/account_card_secure_note.dart';
import 'package:budget_wise/accounts/view/widgets/account_expiry_date_field.dart';
import 'package:budget_wise/accounts/view/widgets/account_initial_balance_display.dart';
import 'package:budget_wise/accounts/view/widgets/credit_card_preview.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';

import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:flutter/material.dart';

class AddAccountPart2 extends StatelessWidget {
  const AddAccountPart2({
    super.key,
    required this.formKey,
    required this.selectedCurrency,
    required this.balanceController,
    required this.authRepo,
    required this.selectedBankName,
    required this.onBankSelected,
    required this.cardHolderController,
    required this.cardNumberController,
    required this.expiryController,
    required this.selectedCardBrand,
    required this.isCardValid,
    required this.onValidateCardNumber,
    required this.isExpiryValid,
    required this.onValidateExpiryDate,
    required this.determineCardType,
  });

  final GlobalKey<FormState> formKey;
  final ValueNotifier<String?> selectedCurrency;
  final TextEditingController balanceController;
  final AuthRepository authRepo;
  final ValueNotifier<String?> selectedBankName;
  final Function(String bankName, List<String>? senderIds) onBankSelected;
  final TextEditingController cardHolderController;
  final TextEditingController cardNumberController;
  final TextEditingController expiryController;
  final ValueNotifier<CardBrand> selectedCardBrand;
  final ValueNotifier<bool> isCardValid;
  final Function(String) onValidateCardNumber;
  final ValueNotifier<bool> isExpiryValid;
  final Function(String) onValidateExpiryDate;
  final Function(String) determineCardType;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AccountInitialBalanceDisplay(
            selectedCurrency: selectedCurrency,
            balanceController: balanceController,
          ),
          const SizedBox(height: AppSpacing.lg),
          CreditCardPreview(
            bankNameNotifier: selectedBankName,
            cardNumberController: cardNumberController,
            cardHolderController: cardHolderController,
            expiryController: expiryController,
            cardTypeNotifier: selectedCardBrand,
            currentUserDisplayName: authRepo.currentUser?.displayName,
          ),
          const SizedBox(height: AppSpacing.lg),
          AccountBankNameField(
            selectedBankName: selectedBankName,
            onBankSelected: onBankSelected,
          ),
          const SizedBox(height: AppSpacing.md),
          if (authRepo.currentUser == null) ...[
            AccountCardHolderField(
              cardHolderController: cardHolderController,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          AccountCardNumberField(
            cardNumberController: cardNumberController,
            isCardValid: isCardValid,
            onValidateCardNumber: onValidateCardNumber,
            determineCardType: determineCardType,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              AccountExpiryDateField(
                expiryController: expiryController,
                isExpiryValid: isExpiryValid,
                onValidateExpiryDate: onValidateExpiryDate,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AccountCardSecureNote(),
        ],
      ),
    );
  }
}
