import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/data/models/card_brand.dart';
import 'package:budget_wise/accounts/data/models/card_formatters.dart';
import 'package:budget_wise/accounts/view/widgets/currency_picker_bottom_sheet.dart';
import 'package:budget_wise/accounts/view_model/account_event.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/accounts/data/data_source/account_constants.dart';
import 'package:flutter/material.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:string_similarity/string_similarity.dart';

class EditAccountScreen extends StatefulWidget {
  static const String routeName = '/editAccount';
  final AccountModel account;

  const EditAccountScreen({super.key, required this.account});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  late TextEditingController accountNameController;
  late TextEditingController balanceController;
  late TextEditingController bankNameController;
  late TextEditingController cardNumberController;
  late TextEditingController expiryController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String selectedCurrency;
  late CardBrand selectedCardBrand;
  late bool lowBalanceAlertEnabled;

  bool isBankValid = true;
  String? hintText;
  bool isCardValid = true;
  bool isExpiryValid = true;

  final Set<String> egyptBankWhiteListNames =
      AccountConstants.egyptBankWhiteListNames;

  @override
  void initState() {
    super.initState();
    accountNameController = TextEditingController(text: widget.account.title);
    balanceController = TextEditingController(
      text: widget.account.balance.toString(),
    );
    bankNameController = TextEditingController(
      text: widget.account.cardBankName,
    );
    cardNumberController = TextEditingController(
      text: widget.account.cardNumber,
    );
    expiryController = TextEditingController(
      text: widget.account.cardExpiryDate,
    );
    selectedCurrency = widget.account.currency;
    selectedCardBrand = widget.account.cardBrand ?? CardBrand.visa;
    lowBalanceAlertEnabled = widget.account.lowBalanceAlertEnabled;

    if (widget.account.accountType == AccountType.card) {
      _validateBankName(bankNameController.text);
      _validateCardNumber(cardNumberController.text);
      _validateExpiryDate(expiryController.text);
    }
  }

  void _validateBankName(String input) {
    final cleanedInput = input.toLowerCase().trim();
    if (cleanedInput.isEmpty) {
      setState(() {
        isBankValid = false;
        hintText = null;
      });
      return;
    }

    if (egyptBankWhiteListNames.contains(cleanedInput)) {
      setState(() {
        isBankValid = true;
        hintText = null;
      });
    } else {
      final bestMatch = cleanedInput.bestMatch(
        egyptBankWhiteListNames.toList(),
      );
      setState(() {
        isBankValid = false;
        if (input.length > 2 && bestMatch.bestMatch.rating! > 0.4) {
          hintText = bestMatch.bestMatch.target;
        } else {
          hintText = null;
        }
      });
    }
  }

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
      if (month == null || year == null || month < 1 || month > 12) {
        isValid = false;
      } else {
        final now = DateTime.now();
        final int currentYear = now.year % 100;
        final int currentMonth = now.month;
        if (year < currentYear ||
            (year == currentYear && month < currentMonth)) {
          isValid = false;
        }
      }
    }
    setState(() => isExpiryValid = isValid);
  }

  @override
  void dispose() {
    accountNameController.dispose();
    balanceController.dispose();
    bankNameController.dispose();
    cardNumberController.dispose();
    expiryController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final updatedAccount = widget.account.copyWith(
        title: accountNameController.text.trim(),
        balance: double.tryParse(balanceController.text.trim()) ?? 0.0,
        currency: selectedCurrency,
        cardBankName: widget.account.accountType == AccountType.card
            ? bankNameController.text.toUpperCase().trim()
            : null,
        cardNumber: widget.account.accountType == AccountType.card
            ? cardNumberController.text.trim()
            : null,
        cardExpiryDate: widget.account.accountType == AccountType.card
            ? expiryController.text.trim()
            : null,
        cardBrand: widget.account.accountType == AccountType.card
            ? selectedCardBrand
            : null,
        lowBalanceAlertEnabled: lowBalanceAlertEnabled,
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      context.read<AccountBloc>().add(
        AccountEventEditAccount(model: updatedAccount),
      );
      Navigator.of(context).pop(updatedAccount);
    }
  }

  void _onUnlink() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccount, style: AppTextStyles.heading3),
        content: Text(l10n.deleteAccountConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.back,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<AccountBloc>().add(
                AccountEventDeleteAccount(accountId: widget.account.id),
              );
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: Text(
              l10n.deleteAccount,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
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
        title: Text(l10n.editAccount, style: AppTextStyles.heading2),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primaryAccent),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //* Basic Information Section
                _buildSectionHeader(l10n.basicInformation),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(
                      color: AppColors.borderColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextFieldLabel(l10n.addAccountAccountNameLabel),
                      TextFormField(
                        controller: accountNameController,
                        decoration: _getInputDecoration(
                          l10n.addAccountAccountNamePlaceholder,
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? l10n.accountNameCantLeftEmpty
                            : null,
                      ),
                      if (widget.account.accountType == AccountType.card) ...[
                        const SizedBox(height: AppSpacing.md),
                        _buildTextFieldLabel(l10n.addAccountCardNumberLabel),
                        TextFormField(
                          controller: cardNumberController,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(16),
                            CardNumberFormatter(),
                          ],
                          decoration: _getInputDecoration(
                            '**** **** **** ****',
                            suffixIcon: _getValidationIcon(
                              isCardValid,
                              cardNumberController.text,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) =>
                              _validateCardNumber(cardNumberController.text),
                          validator: (value) =>
                              (value == null || value.isEmpty || !isCardValid)
                              ? l10n.youShouldEnterAValidCardNumber
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildTextFieldLabel(l10n.addAccountCardExpiryLabel),
                        TextFormField(
                          controller: expiryController,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                            CardExpirationFormatter(),
                          ],
                          decoration: _getInputDecoration(
                            'MM/YY',
                            suffixIcon: _getValidationIcon(
                              isExpiryValid,
                              expiryController.text,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) =>
                              _validateExpiryDate(expiryController.text),
                          validator: (value) =>
                              (value == null || value.isEmpty || !isExpiryValid)
                              ? l10n.youShouldEnterAValidExpiryDate
                              : null,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                //* Financials Section
                _buildSectionHeader(l10n.financials),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(
                      color: AppColors.borderColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextFieldLabel(l10n.currentBalance),
                      TextFormField(
                        controller: balanceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                        ],
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: _getInputDecoration(
                          l10n.addAccountInitialBalancePlaceholder,
                          prefixIcon: _buildCurrencyPrefix(context),
                        ),
                        validator: (value) =>
                            (value == null ||
                                value.isEmpty ||
                                double.tryParse(value) == null)
                            ? l10n.youShouldEnterAValidBalance
                            : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                //* Settings Section
                _buildSectionHeader(l10n.navSettings),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(
                      color: AppColors.borderColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: lowBalanceAlertEnabled,
                        onChanged: (value) =>
                            setState(() => lowBalanceAlertEnabled = value),
                        title: Text(
                          l10n.alertOnLowBalance,
                          style: AppTextStyles.bodyMedium,
                        ),
                        secondary: const Icon(
                          Icons.notifications_none,
                          color: AppColors.textSecondary,
                        ),
                        activeThumbColor: AppColors.primaryAccent,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                //* Unlink/Delete Action
                Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(
                      color: AppColors.borderColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: TextButton.icon(
                    onPressed: _onUnlink,
                    icon: const Icon(
                      Icons.delete_forever,
                      color: AppColors.danger,
                    ),
                    label: Text(
                      l10n.deleteAccount,
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl * 2),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ElevatedButton(
          onPressed: _onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAccent,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            elevation: 8,
            shadowColor: AppColors.primaryAccent.withValues(alpha: 0.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.save, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                l10n.saveChanges,
                style: AppTextStyles.button.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTextFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  InputDecoration _getInputDecoration(
    String hint, {
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.inputBackground,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget? _getValidationIcon(bool isValid, String text) {
    if (text.isEmpty) return null;
    return Icon(
      isValid ? Icons.check_circle : Icons.error,
      color: isValid ? AppColors.primaryAccent : AppColors.danger,
    );
  }

  Widget _buildCurrencyPrefix(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => CurrencyPickerBottomSheet(
            selectedCurrency: selectedCurrency,
            onCurrencySelected: (currency) =>
                setState(() => selectedCurrency = currency),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
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
            const Icon(Icons.keyboard_arrow_down, size: 14),
          ],
        ),
      ),
    );
  }
}
