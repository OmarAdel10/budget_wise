import 'package:budget_wise/accounts/data/data_source/account_constants.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CurrencyPickerBottomSheet extends StatelessWidget {
  final String selectedCurrency;
  final ValueChanged<String> onCurrencySelected;

  const CurrencyPickerBottomSheet({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencySelected,
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
          Text("Select Currency", style: AppTextStyles.heading3),
          const SizedBox(height: AppSpacing.md),

          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: AccountConstants.supportedCurrencies.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: AppColors.borderColor, height: 1),
              itemBuilder: (context, index) {
                final code = AccountConstants.supportedCurrencies.keys
                    .elementAt(index);
                final name = AccountConstants.supportedCurrencies.values
                    .elementAt(index);
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
                                ? AppColors.primaryAccent.withValues(alpha: 0.1)
                                : AppColors.inputBackground,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                            border: isSelected
                                ? Border.all(color: AppColors.primaryAccent)
                                : null,
                          ),
                          child: Text(
                            code,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.primaryAccent
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            name,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isSelected
                                  ? AppColors.primaryAccent
                                  : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                            color: AppColors.primaryAccent,
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
