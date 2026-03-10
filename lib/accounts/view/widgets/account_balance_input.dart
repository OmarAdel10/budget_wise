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

class AccountBalanceInput extends StatelessWidget {
  const AccountBalanceInput({
    super.key,
    required this.balanceController,
    this.selectedCurrency,
    this.hasPadding = true,
    this.hasDecoration = true,
    this.isInitialBalanceField = true,
    this.hasCurrencyField = true,
    this.hasClearSuffix = false,
    this.isLowBalanceField = false,
  });

  final TextEditingController balanceController;
  final ValueNotifier<String?>? selectedCurrency;
  final bool hasPadding;
  final bool hasDecoration;
  final bool isInitialBalanceField;
  final bool hasCurrencyField;
  final bool hasClearSuffix;
  final bool isLowBalanceField;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isInitialBalanceField
              ? isLowBalanceField
                    ? l10n.lowBalanceAlertAmount
                    : l10n.addAccountInitialBalanceLabel
              : l10n.currentBalance,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm + 1),
        CustomTextField(
          bgColor: AppColors.inputBackground,
          controller: balanceController,
          hintText: l10n.addAccountInitialBalancePlaceholder,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
            ThousandsSeparatorInputFormatter(),
          ],
          prefixIcon: hasCurrencyField
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
