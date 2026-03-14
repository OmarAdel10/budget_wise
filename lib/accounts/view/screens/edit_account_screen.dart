import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/data/models/card_brand.dart';
import 'package:budget_wise/accounts/view/widgets/account_basic_info_card.dart';
import 'package:budget_wise/accounts/view/widgets/account_delete_card.dart';
import 'package:budget_wise/accounts/view_model/account_event.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_wise/accounts/view/widgets/section_header.dart';
import 'package:budget_wise/accounts/view/widgets/edit_account_bottom_nav_bar.dart';
import 'package:budget_wise/shared/widgets/alert_setting_card.dart';
import 'package:budget_wise/accounts/view/widgets/account_financials_card.dart';
import 'package:budget_wise/accounts/utils/card_validation_mixin.dart';

class EditAccountScreen extends StatefulWidget {
  static const String routeName = '/editAccount';
  final AccountModel account;

  const EditAccountScreen({super.key, required this.account});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen>
    with CardValidationMixin {
  late TextEditingController accountNameController;
  late TextEditingController balanceController;
  late TextEditingController lowBalanceAlertAmountController;
  late TextEditingController cardNumberController;
  late TextEditingController expiryController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final ValueNotifier<String> selectedCurrencyNotifier = ValueNotifier<String>(
    '',
  );
  final ValueNotifier<bool> lowBalanceAlertEnabledNotifier =
      ValueNotifier<bool>(false);
  final ValueNotifier<String?> selectedBankNameNotifier =
      ValueNotifier<String?>(null);
  final ValueNotifier<List<String>?> selectedBankSenderIdsNotifier =
      ValueNotifier<List<String>?>(null);

  @override
  void initState() {
    super.initState();
    accountNameController = TextEditingController(text: widget.account.title);
    balanceController = TextEditingController(
      text: widget.account.balance.toStringAsFixed(1),
    );

    lowBalanceAlertAmountController = TextEditingController(
      text: widget.account.lowBalanceAlertAmount.toStringAsFixed(1),
    );
    cardNumberController = TextEditingController(
      text: widget.account.cardNumber,
    );
    expiryController = TextEditingController(
      text: widget.account.cardExpiryDate,
    );

    selectedCurrencyNotifier.value = widget.account.currency;
    lowBalanceAlertEnabledNotifier.value =
        widget.account.lowBalanceAlertEnabled;
    selectedBankNameNotifier.value = widget.account.cardBankName;
    selectedBankSenderIdsNotifier.value = widget.account.smsSenderIds;

    if (widget.account.accountType == AccountType.card) {
      selectedCardBrandNotifier.value =
          widget.account.cardBrand ?? CardBrand.visa;
      validateCardNumber(cardNumberController.text);
      validateExpiryDate(expiryController.text);
    }
  }

  @override
  void dispose() {
    accountNameController.dispose();
    balanceController.dispose();
    cardNumberController.dispose();
    expiryController.dispose();
    selectedCurrencyNotifier.dispose();
    lowBalanceAlertEnabledNotifier.dispose();
    selectedBankNameNotifier.dispose();
    selectedBankSenderIdsNotifier.dispose();
    disposeCardValidationNotifiers();
    super.dispose();
  }

  void _onSave() {
    bool isCard = widget.account.accountType == AccountType.card;
    if (_formKey.currentState!.validate()) {
      final updatedAccount = widget.account.copyWith(
        title: accountNameController.text.trim(),
        balance:
            double.tryParse(
              balanceController.text.replaceAll(',', '').trim(),
            ) ??
            0.0,
        currency: selectedCurrencyNotifier.value,
        cardBankName: isCard
            ? selectedBankNameNotifier.value?.toUpperCase().trim()
            : null,
        cardNumber: isCard ? cardNumberController.text.trim() : null,
        cardExpiryDate: isCard ? expiryController.text.trim() : null,
        cardBrand: isCard ? selectedCardBrandNotifier.value : null,
        lowBalanceAlertEnabled: lowBalanceAlertEnabledNotifier.value,
        lowBalanceAlertAmount:
            double.tryParse(
              lowBalanceAlertAmountController.text.replaceAll(',', '').trim(),
            ) ??
            0.0,
        smsSenderIds: selectedBankSenderIdsNotifier.value,
        smsIdentifier: cardNumberController.text.replaceAll(' ', '').length >= 4
            ? cardNumberController.text
                  .replaceAll(' ', '')
                  .substring(
                    cardNumberController.text.replaceAll(' ', '').length - 4,
                  )
            : null,
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      context.read<AccountBloc>().add(
        AccountEventEditAccount(model: updatedAccount),
      );
      Navigator.of(context).pop(updatedAccount);
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
        title: Text(l10n.editAccount, style: AppTextStyles.heading2),
        leading: IconButton(
          icon: const Icon(Icons.close),
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
                SectionHeader(title: l10n.basicInformation),
                AccountBasicInfoCard(
                  accountType: widget.account.accountType,
                  accountNameController: accountNameController,
                  cardNumberController: cardNumberController,
                  expiryController: expiryController,
                  selectedBankNameNotifier: selectedBankNameNotifier,
                  selectedBankSenderIdsNotifier: selectedBankSenderIdsNotifier,
                  cardValidationMixin: this,
                ),
                const SizedBox(height: AppSpacing.lg),

                //* Financials Section
                SectionHeader(title: l10n.financials),
                AccountFinancialsCard(
                  balanceController: balanceController,
                  selectedCurrencyNotifier: selectedCurrencyNotifier,
                ),

                const SizedBox(height: AppSpacing.lg),

                //* Settings Section
                SectionHeader(title: l10n.navSettings),
                AlertSettingCard(
                  enabledNotifier: lowBalanceAlertEnabledNotifier,
                  alertAmountController: lowBalanceAlertAmountController,
                ),

                const SizedBox(height: AppSpacing.lg),

                //* Delete Action
                AccountDeleteCard(accountId: widget.account.id),

                const SizedBox(height: AppSpacing.xxl * 2),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: EditAccountBottomNavBar(onSave: _onSave),
    );
  }
}
