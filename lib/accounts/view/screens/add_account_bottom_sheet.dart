import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/utils/card_validation_mixin.dart';
import 'package:budget_wise/accounts/view/widgets/add_account_navigation_buttons.dart';
import 'package:budget_wise/accounts/view/widgets/add_account_part1.dart';
import 'package:budget_wise/accounts/view/widgets/add_account_part2.dart';
import 'package:budget_wise/accounts/view/widgets/add_account_part_wallet.dart';
import 'package:budget_wise/accounts/view_model/account_event.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/data/services/bottom_sheet_service.dart';
import 'package:budget_wise/shared/utils/string_cases.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

enum AddAccountStep { part1, cardDetails, walletDetails }

class AddAccountBottomSheet extends StatefulWidget {
  final ScrollController scrollController;
  const AddAccountBottomSheet({super.key, required this.scrollController});

  @override
  State<AddAccountBottomSheet> createState() => _AddAccountBottomSheetState();
}

class _AddAccountBottomSheetState extends State<AddAccountBottomSheet>
    with CardValidationMixin {
  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController cardHolderController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final GlobalKey<FormState> _formKeyScreen1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyScreen2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyScreenWallet = GlobalKey<FormState>();

  final ValueNotifier<AccountType> _selectedAccount = ValueNotifier(
    AccountType.cash,
  );
  final ValueNotifier<String?> _selectedCurrency = ValueNotifier(null);
  final ValueNotifier<String?> _selectedBankName = ValueNotifier(null);
  final ValueNotifier<List<String>?> _selectedBankSenderIds = ValueNotifier(
    null,
  );
  final ValueNotifier<String?> _selectedWalletProvider = ValueNotifier(null);
  final ValueNotifier<bool> _isPart2Enabled = ValueNotifier(false);
  final ValueNotifier<AddAccountStep> _currentStep = ValueNotifier(
    AddAccountStep.part1,
  );

  @override
  void initState() {
    super.initState();
    _selectedCurrency.value = context
        .read<SettingsBloc>()
        .state
        .model
        .defaultCurrency;
  }

  @override
  void dispose() {
    balanceController.dispose();
    accountNameController.dispose();
    cardHolderController.dispose();
    cardNumberController.dispose();
    expiryController.dispose();
    phoneNumberController.dispose();
    _selectedAccount.dispose();
    _selectedCurrency.dispose();
    _selectedBankName.dispose();
    _selectedBankSenderIds.dispose();
    _selectedWalletProvider.dispose();
    _isPart2Enabled.dispose();
    _currentStep.dispose();
    disposeCardValidationNotifiers();
    super.dispose();
  }

  void _onAddAccountTap() {
    if (_formKeyScreen1.currentState!.validate()) {
      if (_selectedAccount.value == AccountType.cash) {
        final newAccount = AccountModel(
          accountType: _selectedAccount.value,
          title: accountNameController.text.trim(),
          accountIcon: PhosphorIconsRegular.currencyCircleDollar,
          initialBalance:
              double.tryParse(balanceController.text.replaceAll(',', '')) ??
              0.0,
          balance:
              double.tryParse(balanceController.text.replaceAll(',', '')) ??
              0.0,
          currency: _selectedCurrency.value!,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        context.read<AccountBloc>().add(
          AccountEventCreateAccount(model: newAccount),
        );
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      } else if (_selectedAccount.value == AccountType.card) {
        _currentStep.value = AddAccountStep.cardDetails;
      } else if (_selectedAccount.value == AccountType.wallet) {
        _currentStep.value = AddAccountStep.walletDetails;
      }
    }
  }

  void _onSaveCard() {
    if (_selectedAccount.value == AccountType.card) {
      if (_formKeyScreen2.currentState!.validate()) {
        final newAccount = AccountModel(
          accountType: _selectedAccount.value,
          title: accountNameController.text.trim(),
          accountIcon: PhosphorIconsRegular.creditCard,
          initialBalance:
              double.tryParse(
                balanceController.text.replaceAll(',', '').trim(),
              ) ??
              0.0,
          balance:
              double.tryParse(
                balanceController.text.replaceAll(',', '').trim(),
              ) ??
              0.0,
          currency: _selectedCurrency.value!,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          cardBankName: _selectedBankName.value?.toTitleCase().trim(),
          cardHolderName: cardHolderController.text.toTitleCase().trim(),
          cardNumber: cardNumberController.text.replaceAll(' ', '').trim(),
          cardExpiryDate: expiryController.text.trim(),
          cardBrand: selectedCardBrandNotifier.value,
          smsSenderIds: _selectedBankSenderIds.value,
          smsIdentifier:
              cardNumberController.text.replaceAll(' ', '').length >= 4
              ? cardNumberController.text
                    .replaceAll(' ', '')
                    .substring(
                      cardNumberController.text.replaceAll(' ', '').length - 4,
                    )
              : null,
        );
        context.read<AccountBloc>().add(
          AccountEventCreateAccount(model: newAccount),
        );
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  void _onSaveWallet() {
    if (_selectedAccount.value == AccountType.wallet) {
      if (_formKeyScreenWallet.currentState!.validate()) {
        final newAccount = AccountModel(
          accountType: _selectedAccount.value,
          title: accountNameController.text.trim(),
          accountIcon: PhosphorIconsRegular.deviceMobile,
          initialBalance:
              double.tryParse(
                balanceController.text.replaceAll(',', '').trim(),
              ) ??
              0.0,
          balance:
              double.tryParse(
                balanceController.text.replaceAll(',', '').trim(),
              ) ??
              0.0,
          currency: _selectedCurrency.value!,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          phoneNumber: phoneNumberController.text.trim(),
          walletProvider: _selectedWalletProvider.value,
        );
        context.read<AccountBloc>().add(
          AccountEventCreateAccount(model: newAccount),
        );
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.lg),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // const DragHandle(),
          // Text(context.l10n.addAccountTitle, style: AppTextStyles.heading2),
          BottomSheetService.header(title: context.l10n.addAccountTitle),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ValueListenableBuilder<AddAccountStep>(
                    valueListenable: _currentStep,
                    builder: (context, currentStep, _) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _buildStepContent(currentStep),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ValueListenableBuilder<AddAccountStep>(
                    valueListenable: _currentStep,
                    builder: (context, currentStep, _) {
                      return AddAccountNavigationButtons(
                        showCardEntry: ValueNotifier(
                          currentStep != AddAccountStep.part1,
                        ),
                        isPart2Enabled: _isPart2Enabled,
                        onSaveCard: currentStep == AddAccountStep.cardDetails
                            ? _onSaveCard
                            : _onSaveWallet,
                        onAddAccountTap: _onAddAccountTap,
                        onBack: () => _currentStep.value = AddAccountStep.part1,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(AddAccountStep step) {
    switch (step) {
      case AddAccountStep.part1:
        return AddAccountPart1(
          formKey: _formKeyScreen1,
          accountNameController: accountNameController,
          balanceController: balanceController,
          selectedAccount: _selectedAccount,
          onAccountTypeSelected: (type) {
            _selectedAccount.value = type;
            _isPart2Enabled.value = type != AccountType.cash;
          },
          selectedCurrency: _selectedCurrency,
          onCurrencySelected: (currency) {
            _selectedCurrency.value = currency;
          },
        );
      case AddAccountStep.cardDetails:
        return AddAccountPart2(
          formKey: _formKeyScreen2,
          selectedCurrency: _selectedCurrency,
          balanceController: balanceController,
          authRepo: context.read<AuthRepository>(),
          selectedBankName: _selectedBankName,
          onBankSelected: (bankName, senderIds) {
            _selectedBankName.value = bankName;
            _selectedBankSenderIds.value = senderIds;
          },
          cardHolderController: cardHolderController,
          cardNumberController: cardNumberController,
          expiryController: expiryController,
          selectedCardBrand: selectedCardBrandNotifier,
          isCardValid: isCardValidNotifier,
          onValidateCardNumber: validateCardNumber,
          isExpiryValid: isExpiryValidNotifier,
          onValidateExpiryDate: validateExpiryDate,
          determineCardType: (brand) => determineCardType(brand),
        );
      case AddAccountStep.walletDetails:
        return AddAccountPartWallet(
          formKey: _formKeyScreenWallet,
          selectedCurrency: _selectedCurrency,
          balanceController: balanceController,
          phoneNumberController: phoneNumberController,
          selectedProvider: _selectedWalletProvider,
          onProviderSelected: (providerName) {
            _selectedWalletProvider.value = providerName;
          },
        );
    }
  }
}
