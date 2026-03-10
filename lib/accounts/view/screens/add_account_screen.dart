import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/view_model/account_event.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/accounts/view/widgets/add_account_part1.dart';
import 'package:budget_wise/accounts/view/widgets/add_account_part2.dart';
import 'package:budget_wise/accounts/view/widgets/add_account_navigation_buttons.dart'; // Import the new navigation buttons widget
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/utils/string_cases.dart';
import 'package:flutter/material.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:budget_wise/accounts/utils/card_validation_mixin.dart';

class AddAccountScreen extends StatefulWidget {
  static const String routeName = '/addAccount';
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen>
    with CardValidationMixin {
  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController cardHolderController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final GlobalKey<FormState> _formKeyScreen1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyScreen2 = GlobalKey<FormState>();

  final ValueNotifier<AccountType> _selectedAccount = ValueNotifier(
    AccountType.cash,
  );
  final ValueNotifier<String?> _selectedCurrency = ValueNotifier(null);
  final ValueNotifier<String?> _selectedBankName = ValueNotifier(null);
  final ValueNotifier<List<String>?> _selectedBankSenderIds = ValueNotifier(
    null,
  );
  final ValueNotifier<bool> _isPart2Enabled = ValueNotifier(false);
  final ValueNotifier<bool> _showCardEntry = ValueNotifier<bool>(false);

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
    _selectedAccount.dispose();
    _selectedCurrency.dispose();
    _selectedBankName.dispose();
    _selectedBankSenderIds.dispose();
    _isPart2Enabled.dispose();
    _showCardEntry.dispose();
    disposeCardValidationNotifiers();
    super.dispose();
  }

  void _onAddAccountTap() {
    if (_selectedAccount.value == AccountType.cash) {
      if (_formKeyScreen1.currentState!.validate()) {
        final newAccount = AccountModel(
          accountType: _selectedAccount.value,
          title: accountNameController.text.trim(),
          accountIcon: _selectedAccount.value == AccountType.cash
              ? PhosphorIcons.currencyCircleDollar(PhosphorIconsStyle.regular)
              : PhosphorIcons.creditCard(PhosphorIconsStyle.regular),
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
      }
      return;
    }

    _showCardEntry.value = true;
  }

  void _onSaveCard() {
    if (_selectedAccount.value == AccountType.card) {
      if (_formKeyScreen2.currentState!.validate()) {
        final newAccount = AccountModel(
          accountType: _selectedAccount.value,
          title: accountNameController.text.trim(),
          accountIcon: _selectedAccount.value == AccountType.cash
              ? PhosphorIcons.currencyCircleDollar(PhosphorIconsStyle.regular)
              : PhosphorIcons.creditCard(PhosphorIconsStyle.regular),
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
          cardNumber: cardNumberController.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        centerTitle: true,
        title: Text(l10n.addAccountTitle, style: AppTextStyles.heading2),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _showCardEntry,
                  builder: (context, showCardEntry, _) {
                    return AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      firstChild: AddAccountPart1(
                        l10n: l10n,
                        formKey: _formKeyScreen1,
                        accountNameController: accountNameController,
                        balanceController: balanceController,
                        selectedAccount: _selectedAccount,
                        onAccountTypeSelected: (type) {
                          _selectedAccount.value = type;
                          if (type == AccountType.cash) {
                            _showCardEntry.value = false;
                          }
                          _isPart2Enabled.value = type != AccountType.cash;
                        },
                        selectedCurrency: _selectedCurrency,
                        onCurrencySelected: (currency) {
                          _selectedCurrency.value = currency;
                        },
                      ),
                      secondChild: AddAccountPart2(
                        l10n: l10n,
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
                      ),
                      crossFadeState: showCardEntry
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    AddAccountNavigationButtons(
                      showCardEntry: _showCardEntry,
                      isPart2Enabled: _isPart2Enabled,
                      onSaveCard: _onSaveCard,
                      onAddAccountTap: _onAddAccountTap,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
