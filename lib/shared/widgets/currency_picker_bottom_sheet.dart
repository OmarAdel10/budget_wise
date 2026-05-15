import 'package:budget_wise/accounts/data/data_source/account_constants.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CurrencyPickerBottomSheet extends StatelessWidget {
  final String selectedCurrency;
  final ValueChanged<String> onCurrencySelected;
  final Color selectionColor;

  const CurrencyPickerBottomSheet({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencySelected,
    this.selectionColor = AppColors.primaryAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Indicator
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            AppLocalizations.of(context)!.selectCurrency,
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.md),

          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: AccountConstants.supportedCurrencies.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: AppColors.borderColor, height: 1),
              itemBuilder: (context, index) {
                final flag = AccountConstants.supportedCurrencies.keys
                    .elementAt(index);
                final code = AccountConstants.supportedCurrencies.entries
                    .map((entry) {
                      return entry.value.keys;
                    })
                    .expand((i) => i)
                    .elementAt(index);
                final name = AccountConstants.supportedCurrencies.entries
                    .map((entry) {
                      return entry.value.values;
                    })
                    .expand((i) => i)
                    .elementAt(index);
                // final code = AccountConstants.supportedCurrencies.values.
                // .elementAt(index);
                // final name = AccountConstants.supportedCurrencies.values
                //     .elementAt(index);
                final isSelected = code == selectedCurrency;

                return InkWell(
                  onTap: () {
                    onCurrencySelected(code);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                      horizontal: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? selectionColor.withValues(alpha: 0.1)
                                : AppColors.inputBackground,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                            border: isSelected
                                ? Border.all(color: selectionColor)
                                : null,
                          ),
                          child: Text(
                            flag,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? selectionColor
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isSelected
                                      ? selectionColor
                                      : AppColors.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              Text(
                                code,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isSelected
                                      ? selectionColor.withValues(alpha: 0.6)
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w100,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                            color: selectionColor,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
