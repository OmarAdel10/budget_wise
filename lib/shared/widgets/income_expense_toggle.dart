import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/utils/toggle_option_enum.dart';
import 'package:flutter/material.dart';

class IncomeExpenseToggle extends StatelessWidget {
  final ValueNotifier<ToggleOption>? selectionNotifier;
  final ToggleOption? currentSelection;
  final Function(ToggleOption)? onChanged;
  final TextStyle? incomeTextStyle;
  final TextStyle? expenseTextStyle;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final bool isSavingsEnabled;

  const IncomeExpenseToggle({
    super.key,
    this.selectionNotifier,
    this.currentSelection,
    this.onChanged,
    this.incomeTextStyle,
    this.expenseTextStyle,
    this.selectedColor = AppColors.cardBackground,
    this.unselectedColor = Colors.transparent,
    this.selectedTextColor = AppColors.textPrimary,
    this.unselectedTextColor = AppColors.textSecondary,
    this.isSavingsEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return selectionNotifier != null
        ? ValueListenableBuilder<ToggleOption>(
            valueListenable: selectionNotifier!,
            builder: (context, selection, child) {
              return _buildToggleBody(context, l10n, selection);
            },
          )
        : _buildToggleBody(
            context,
            l10n,
            currentSelection ?? ToggleOption.expense,
          );
  }

  Widget _buildToggleBody(
    BuildContext context,
    AppLocalizations l10n,
    ToggleOption selection,
  ) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToggleItem(
              context,
              text: l10n.income,
              option: ToggleOption.income,
              currentSelection: selection,
              defaultColor: AppColors.income,
              defaultTextStyle:
                  incomeTextStyle ??
                  AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text('|', style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary
            ),),
            _buildToggleItem(
              context,
              text: l10n.expenses,
              option: ToggleOption.expense,
              currentSelection: selection,
              defaultColor: AppColors.expense,
              defaultTextStyle:
                  expenseTextStyle ??
                  AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (isSavingsEnabled) ...[
              Text(
                '|',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              _buildToggleItem(
                context,
                text: l10n.navSavings,
                option: ToggleOption.savings,
                currentSelection: selection,
                defaultColor: AppColors.savings,
                defaultTextStyle: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(
    BuildContext context, {
    required String text,
    required ToggleOption option,
    required ToggleOption currentSelection,
    required Color defaultColor,
    required TextStyle defaultTextStyle,
  }) {
    final bool isSelected = currentSelection == option;
    final Color itemBackgroundColor = isSelected
        ? selectedColor!
        : unselectedColor!;
    final Color itemTextColor = isSelected
        ? selectedTextColor!
        : unselectedTextColor!;

    return GestureDetector(
      onTap: () {
        if (selectionNotifier != null) {
          selectionNotifier!.value = option;
        }
        onChanged?.call(option);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: itemBackgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Text(
          text,
          style: defaultTextStyle.copyWith(color: itemTextColor),
        ),
      ),
    );
  }
}
