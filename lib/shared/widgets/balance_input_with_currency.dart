import 'package:budget_wise/shared/widgets/currency_prefix.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/utils/thousands_formatter.dart';
import 'package:budget_wise/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class BalanceInputWithCurrency extends StatelessWidget {
  final TextEditingController balanceController;
  final ValueNotifier<String?>? selectedCurrency;
  final bool hasPadding;
  final bool hasDecoration;
  final bool hasCurrencyPrefix;
  final bool hasClearSuffix;
  final String? hint;
  final bool hasTitle;
  final Color backgroundColor;
  final String? fieldCustomTitle;
  final String? Function(String?)? validator;
  final bool isInitialBalanceField;
  final bool isLowBalanceField;
  final bool isReminderBalanceField;
  final bool isSavingBalanceField;

  const BalanceInputWithCurrency({
    super.key,
    required this.balanceController,
    this.selectedCurrency,
    this.hasPadding = true,
    this.hasDecoration = true,
    this.hasCurrencyPrefix = true,
    this.hasClearSuffix = false,
    this.hint,
    this.hasTitle = true,
    this.fieldCustomTitle,
    this.backgroundColor = AppColors.inputBackground,
    this.validator,
  }) : isInitialBalanceField = false,
       isLowBalanceField = false,
       isReminderBalanceField = false,
       isSavingBalanceField = false;

  const BalanceInputWithCurrency.initialBalance({
    super.key,
    required this.balanceController,
    this.selectedCurrency,
    this.hasPadding = true,
    this.hasDecoration = true,
    this.hasClearSuffix = false,
    this.hint,
    this.hasTitle = true,
    this.backgroundColor = AppColors.inputBackground,
    this.fieldCustomTitle,
    this.validator,
  }) : hasCurrencyPrefix = false,
       isInitialBalanceField = true,
       isLowBalanceField = false,
       isReminderBalanceField = false,
       isSavingBalanceField = false;

  const BalanceInputWithCurrency.lowBalance({
    super.key,
    required this.balanceController,
    this.selectedCurrency,
    this.hasPadding = true,
    this.hasDecoration = true,
    this.hasClearSuffix = false,
    this.hint,
    this.hasTitle = true,
    this.backgroundColor = AppColors.inputBackground,
    this.fieldCustomTitle,
    this.validator,
  }) : hasCurrencyPrefix = false,
       isInitialBalanceField = false,
       isLowBalanceField = true,
       isReminderBalanceField = false,
       isSavingBalanceField = false;

  const BalanceInputWithCurrency.reminderBalance({
    super.key,
    required this.balanceController,
    this.selectedCurrency,
    this.hasPadding = true,
    this.hasDecoration = true,
    this.hasClearSuffix = false,
    this.hint,
    this.hasTitle = true,
    this.backgroundColor = AppColors.inputBackground,
    this.fieldCustomTitle,
    this.validator,
  }) : hasCurrencyPrefix = false,
       isInitialBalanceField = false,
       isLowBalanceField = false,
       isReminderBalanceField = true,
       isSavingBalanceField = false;

  const BalanceInputWithCurrency.savingBalance({
    super.key,
    required this.balanceController,
    this.selectedCurrency,
    this.hasClearSuffix = false,
    this.hint,
    this.hasTitle = true,
    this.backgroundColor = AppColors.inputBackground,
    this.fieldCustomTitle,
    this.validator,
    this.hasCurrencyPrefix = true,
  }) : hasDecoration = false,
       hasPadding = false,
       isInitialBalanceField = false,
       isLowBalanceField = false,
       isReminderBalanceField = false,
       isSavingBalanceField = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasTitle) ...[
          Text(
            fieldCustomTitle != null && fieldCustomTitle!.isNotEmpty
                ? fieldCustomTitle!
                : isSavingBalanceField
                ? l10n.targetAmount
                : isReminderBalanceField
                ? l10n.reminderBeforeDays
                : isInitialBalanceField
                ? isLowBalanceField
                      ? l10n.lowBalanceAlertAmount
                      : l10n.addAccountInitialBalanceLabel
                : l10n.currentBalance,
            style: isSavingBalanceField ? AppTextStyles.bodyMedium : AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.sm + 1),
        CustomTextField(
          bgColor: backgroundColor,
          controller: balanceController,
          hintText: hint ?? l10n.addAccountInitialBalancePlaceholder,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
            ThousandsSeparatorInputFormatter(),
          ],
          prefixIcon: hasCurrencyPrefix
              ? CurrencyPrefix(selectedCurrencyNotifier: selectedCurrency!)
              : null,
          suffixIcon: hasClearSuffix
              ? IconButton(
                  onPressed: () => balanceController.clear(),
                  icon: Icon(
                    PhosphorIconsBold.x,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                )
              : null,
          validator: validator,
        ),
      ],
    );

    if (!hasDecoration) {
      return Padding(
        padding: hasPadding
            ? const EdgeInsets.all(AppSpacing.lg)
            : EdgeInsets.zero,
        child: content,
      );
    }

    return Container(
      padding: hasPadding ? const EdgeInsets.all(AppSpacing.lg) : null,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: content,
    );
  }
}
