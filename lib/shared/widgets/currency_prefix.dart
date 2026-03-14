import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/widgets/currency_picker_bottom_sheet.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CurrencyPrefix extends StatelessWidget {
  final ValueNotifier<String?> selectedCurrencyNotifier;
  final bool isSettingsTile;

  const CurrencyPrefix({super.key, required this.selectedCurrencyNotifier})
    : isSettingsTile = false;

  const CurrencyPrefix.settings({
    super.key,
    required this.selectedCurrencyNotifier,
  }) : isSettingsTile = true;

  @override
  Widget build(BuildContext context) {
    final defaultCurrency = context.select<SettingsBloc, String>(
      (bloc) => bloc.state.currencySymbol,
    );
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => CurrencyPickerBottomSheet(
            selectedCurrency: selectedCurrencyNotifier.value ?? defaultCurrency,
            onCurrencySelected: (currency) {
              selectedCurrencyNotifier.value = currency;
              if (isSettingsTile) {
                context.read<SettingsBloc>().add(
                  SettingsEventUpdateDefaultCurrency(
                    newDefaultCurrency: selectedCurrencyNotifier.value!,
                  ),
                );
              }
            },
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: isSettingsTile ? const EdgeInsets.symmetric(vertical: AppSpacing.sm) : null,
        width: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: ValueListenableBuilder<String?>(
          valueListenable: selectedCurrencyNotifier,
          builder: (context, selectedCurrency, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  selectedCurrency!,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  PhosphorIconsBold.caretDown,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
