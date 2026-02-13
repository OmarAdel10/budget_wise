import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/data/models/card_brand.dart';
import 'package:budget_wise/accounts/data/models/card_formatters.dart';
import 'package:budget_wise/accounts/view/widgets/account_type_tile.dart';
import 'package:budget_wise/accounts/view/widgets/credit_card_preview.dart';
import 'package:budget_wise/accounts/view/widgets/currency_picker_bottom_sheet.dart';
import 'package:budget_wise/accounts/view_model/account_event.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/accounts/view/widgets/bank_picker_bottom_sheet.dart';
import 'package:budget_wise/shared/utils/stringCases.dart';
import 'package:flutter/material.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/utils/thousands_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AddAccountScreen extends StatefulWidget {
  static const String routeName = '/addAccount';
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController cardHolderController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final GlobalKey<FormState> _formKeyScreen1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyScreen2 = GlobalKey<FormState>();
  AccountType selectedAccount = AccountType.cash;
  String selectedCurrency = 'EGP';
  String? selectedBankName;
  List<String>? selectedBankSenderIds;

  bool _showCardEntry = false;
  bool _isPart2Enabled = false;

  CardBrand selectedCardBrand = CardBrand.visa;
  bool isCardValid = false;
  bool isExpiryValid = false;

  void _determineCardType(String cleanedCardNumber) {
    if (cleanedCardNumber.isNotEmpty) {
      if (cleanedCardNumber.startsWith('4')) {
        selectedCardBrand = CardBrand.visa;
      } else if (RegExp(r'^5[1-5]').hasMatch(cleanedCardNumber) ||
          RegExp(
            r'^2(22[1-9]|2[3-9][0-9]|[3-6][0-9]{2}|7[01][0-9]|720)',
          ).hasMatch(cleanedCardNumber)) {
        selectedCardBrand = CardBrand.mastercard;
      } else if (cleanedCardNumber.startsWith('5078') ||
          cleanedCardNumber.startsWith('9828')) {
        selectedCardBrand = CardBrand.mezza;
      }
    }
  }

  void _validateCardNumber(String cardNumber) {
    final cleanedNumber = cardNumber.replaceAll(' ', '');

    bool isValid = true;
    if (cleanedNumber.length != 16) isValid = false;

    int sum = 0;
    for (int i = 0; i < cleanedNumber.length; i++) {
      int digit = int.parse(cleanedNumber[i]);

      if (i % 2 == 0) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
    }
    if (sum % 10 != 0) isValid = false;

    setState(() {
      _determineCardType(cardNumber);
      isCardValid = isValid;
    });
  }

  void _validateExpiryDate(String input) {
    bool isValid = true;
    if (input.length != 5) isValid = false;

    final parts = input.split('/');
    if (isValid && parts.length != 2) isValid = false;

    if (isValid) {
      final int? month = int.tryParse(parts[0]);
      final int? year = int.tryParse(parts[1]);

      if (month == null || year == null) {
        isValid = false;
      } else if (month < 1 || month > 12) {
        isValid = false;
      } else {
        final now = DateTime.now();
        final int currentYear = now.year % 100;
        final int currentMonth = now.month;

        if (year < currentYear) {
          isValid = false;
        } else if (year == currentYear && month < currentMonth) {
          isValid = false;
        }
      }
    }

    setState(() {
      isExpiryValid = isValid;
    });
  }

  @override
  void dispose() {
    balanceController.dispose();
    accountNameController.dispose();
    cardHolderController.dispose();
    cardNumberController.dispose();
    expiryController.dispose();
    super.dispose();
  }

  void _onAddAccountTap() {
    if (selectedAccount == AccountType.cash) {
      if (_formKeyScreen1.currentState!.validate()) {
        final newAccount = AccountModel(
          accountType: selectedAccount,
          title: accountNameController.text.trim(),
          accountIcon: selectedAccount == AccountType.cash
              ? PhosphorIcons.currencyCircleDollar(PhosphorIconsStyle.regular)
              : PhosphorIcons.creditCard(PhosphorIconsStyle.regular),
          initialBalance:
              double.tryParse(balanceController.text.replaceAll(',', '')) ??
              0.0,
          balance:
              double.tryParse(balanceController.text.replaceAll(',', '')) ??
              0.0,
          currency: selectedCurrency,
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

    setState(() => _showCardEntry = true);
  }

  void _onSaveCard() {
    if (selectedAccount == AccountType.card) {
      if (_formKeyScreen2.currentState!.validate()) {
        final newAccount = AccountModel(
          accountType: selectedAccount,
          title: accountNameController.text.trim(),
          accountIcon: selectedAccount == AccountType.cash
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
          currency: selectedCurrency,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          cardBankName: selectedBankName?.toTitleCase().trim(),
          cardHolderName: cardHolderController.text.toTitleCase().trim(),
          cardNumber: cardNumberController.text.trim(),
          cardExpiryDate: expiryController.text.trim(),
          cardBrand: selectedCardBrand,
          smsSenderIds: selectedBankSenderIds,
          smsIdentifier: cardNumberController.text.replaceAll(' ', '').length >= 4
              ? cardNumberController.text.replaceAll(' ', '').substring(
                  cardNumberController.text.replaceAll(' ', '').length - 4)
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
    selectedAccount != AccountType.cash
        ? _isPart2Enabled = true
        : _isPart2Enabled = false;
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                firstChild: _buildPart1(l10n),
                secondChild: _buildPart2(l10n),
                crossFadeState: _showCardEntry
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
              ),
              const SizedBox(height: AppSpacing.xxl),
              //* Naviagation Button
              Row(
                children: [
                  if (_showCardEntry) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() {
                          _showCardEntry = false;
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.borderColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLg,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold),
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.back,
                              style: AppTextStyles.button.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _showCardEntry
                          ? _onSaveCard
                          : _onAddAccountTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _showCardEntry
                                ? (l10n.addAccountButtonSaveCard)
                                : _isPart2Enabled
                                ? (l10n.continueWord)
                                : (l10n.addAccountButtonAddAccount),
                            style: AppTextStyles.button.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _showCardEntry
                                ? PhosphorIcons.checkCircle(
                                    PhosphorIconsStyle.fill,
                                  )
                                : _isPart2Enabled
                                ? PhosphorIcons.arrowCircleRight(
                                    PhosphorIconsStyle.fill,
                                  )
                                : PhosphorIcons.plusCircle(
                                    PhosphorIconsStyle.fill,
                                  ),
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPart1(AppLocalizations l10n) {
    return Form(
      key: _formKeyScreen1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.addAccountIdentityHeader,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(l10n.addAccountSetupTitle, style: AppTextStyles.heading2),
          const SizedBox(height: 6),
          Text(
            l10n.addAccountSetupSubtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          //* Account Name
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.addAccountAccountNameLabel,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  onTapOutside: (event) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  controller: accountNameController,
                  decoration: InputDecoration(
                    hintText: l10n.addAccountAccountNamePlaceholder,
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.accountNameCantLeftEmpty;
                    }

                    if (value.length < 3) {
                      return l10n.youShouldEnterMoreThan3Characters;
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.addAccountTypeHeader,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          //* Account Type
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: AccountTypeTile(
                      label: l10n.addAccountTypeCash,
                      icon: PhosphorIcons.currencyCircleDollar(
                        PhosphorIconsStyle.regular,
                      ),
                      selected: selectedAccount == AccountType.cash,
                      onTap: () =>
                          setState(() => selectedAccount = AccountType.cash),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AccountTypeTile(
                      label: l10n.addAccountTypeCard,
                      icon: PhosphorIcons.creditCard(
                        PhosphorIconsStyle.regular,
                      ),
                      selected: selectedAccount == AccountType.card,
                      onTap: () =>
                          setState(() => selectedAccount = AccountType.card),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),
          //* Initial Balance
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.addAccountInitialBalanceLabel,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm + 1),
                TextFormField(
                  onTapOutside: (event) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  controller: balanceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                    ThousandsSeparatorInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    prefixIcon: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (context) => CurrencyPickerBottomSheet(
                            selectedCurrency: selectedCurrency,
                            onCurrencySelected: (currency) {
                              setState(() => selectedCurrency = currency);
                            },
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        width: 80,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              selectedCurrency,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
                              size: 14,
                              color: AppColors.textPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    hintText: l10n.addAccountInitialBalancePlaceholder,
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return l10n.initialBalanceCantLeftEmpty;
                  //   }

                  //   final cleanValue = value.replaceAll(',', '');
                  //   if (double.tryParse(cleanValue) == null ||
                  //       double.tryParse(cleanValue)! < 0) {
                  //     return l10n.youShouldEnterAValidBalance;
                  //   }

                  //   return null;
                  // },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPart2(AppLocalizations l10n) {
    final authRepo = context.read<AuthRepository>();
    return Form(
      key: _formKeyScreen2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              l10n.addAccountInitialBalanceLabel,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${NumberFormat.simpleCurrency(name: selectedCurrency).currencyName}${balanceController.text.isEmpty ? '0.00' : balanceController.text}',
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.primaryAccent,
                fontSize: 36,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          CreditCardPreview(
            bankName: selectedBankName?.trim().toTitleCase() ?? '',
            cardNumber: cardNumberController.text,
            cardHolderName:
                authRepo.currentUser?.displayName ??
                cardHolderController.text.trim().toTitleCase(),
            expiryDate: expiryController.text,
            cardType: selectedCardBrand,
          ),

          const SizedBox(height: AppSpacing.lg),
          //* Bank Name
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.addAccountBankNameLabel,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                FormField<String>(
                  initialValue: selectedBankName,
                  validator: (selectedBankName) {
                    if (selectedBankName == null || selectedBankName.isEmpty) {
                      return l10n.bankNameCantLeftEmpty;
                    }

                    return null;
                  },
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              builder: (context) => BankPickerBottomSheet(
                                onBankSelected: (bankName, senderIds) {
                                  setState(() {
                                    selectedBankName = bankName;
                                    selectedBankSenderIds = senderIds;
                                  });
                                  state.didChange(selectedBankName);
                                },
                              ),
                            );
                          },
                          child: Container(
                            height: MediaQuery.sizeOf(context).height * .05,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              border: state.hasError
                                  ? Border.all(color: AppColors.danger)
                                  : null,
                              color: AppColors.inputBackground,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedBankName ??
                                      l10n.addAccountBankNamePlaceholder,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: selectedBankName == null
                                        ? AppColors.textSecondary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                Icon(
                                  PhosphorIcons.caretDown(
                                    PhosphorIconsStyle.bold,
                                  ),
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              left: 12.0,
                            ),
                            child: Text(
                              l10n.bankNameCantLeftEmpty,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.danger,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          //* Card Holder
          if (authRepo.currentUser == null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.addAccountCardHolderLabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    onTapOutside: (event) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    controller: cardHolderController,
                    decoration: InputDecoration(
                      hintText: l10n.addAccountCardHolderPlaceholder,
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.cardHolderCantLeftEmpty;
                      }

                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          //* Card number
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.addAccountCardNumberLabel,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  onTapOutside: (event) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  controller: cardNumberController,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    CardNumberFormatter(),
                  ],
                  decoration: InputDecoration(
                    suffixIcon: cardNumberController.text.isNotEmpty
                        ? Icon(
                            isCardValid
                                ? PhosphorIcons.checkCircle(
                                    PhosphorIconsStyle.fill,
                                  )
                                : PhosphorIcons.xCircle(
                                    PhosphorIconsStyle.fill,
                                  ),
                            color: isCardValid
                                ? AppColors.primaryAccent
                                : AppColors.danger,
                          )
                        : null,
                    hintText: '0000 0000 0000 0000',
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) =>
                      _validateCardNumber(cardNumberController.text),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.cardNumberCantLeftEmpty;
                    }

                    if (isCardValid == false) {
                      return l10n.youShouldEnterAValidCardNumber;
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          //* Card Expiry Date
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.addAccountCardExpiryLabel,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        onTapOutside: (event) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        controller: expiryController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                          CardExpirationFormatter(),
                        ],
                        decoration: InputDecoration(
                          suffixIcon: expiryController.text.isNotEmpty
                              ? Icon(
                                  isExpiryValid
                                      ? PhosphorIcons.checkCircle(
                                          PhosphorIconsStyle.fill,
                                        )
                                      : PhosphorIcons.xCircle(
                                          PhosphorIconsStyle.fill,
                                        ),
                                  color: isExpiryValid
                                      ? AppColors.primaryAccent
                                      : AppColors.danger,
                                )
                              : null,
                          hintText: 'MM/YY',
                          filled: true,
                          fillColor: AppColors.inputBackground,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) =>
                            _validateExpiryDate(expiryController.text),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.expiryDateCantLeftEmpty;
                          }

                          if (isExpiryValid == false) {
                            return l10n.youShouldEnterAValidExpiryDate;
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.addAccountCardSecureNote,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  l10n.disclaimer,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.danger,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
