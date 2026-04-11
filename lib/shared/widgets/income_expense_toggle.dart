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
  final bool isForHome;

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
    this.isForHome = true,
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
            currentSelection ?? ToggleOption.income,
          );
  }

  Widget _buildSeparator() {
    return Text(
      '|',
      style: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.textSecondary.withValues(alpha: 0.5),
      ),
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
              enableExpanded: !isForHome,
            ),
            _buildSeparator(),
            _buildToggleItem(
              context,
              text: l10n.expenses,
              option: ToggleOption.expense,
              currentSelection: selection,
              enableExpanded: !isForHome,
            ),
            if (!isForHome) ...[
              _buildSeparator(),
              _buildToggleItem(
                context,
                text: l10n.navSavings,
                option: ToggleOption.savings,
                currentSelection: selection,
                enableExpanded: true,
              ),
              _buildSeparator(),
              _buildToggleItem(
                context,
                text: l10n.subscriptions,
                option: ToggleOption.subscription,
                currentSelection: selection,
                enableExpanded: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(
    BuildContext context, {
    int flex = 1,
    required String text,
    required ToggleOption option,
    required ToggleOption currentSelection,
    required bool enableExpanded,
  }) {
    final bool isSelected = currentSelection == option;
    final Color itemBackgroundColor = isSelected
        ? selectedColor!
        : unselectedColor!;
    final Color itemTextColor = isSelected
        ? selectedTextColor!
        : unselectedTextColor!;

    final content = GestureDetector(
      onTap: () {
        if (selectionNotifier != null) {
          selectionNotifier!.value = option;
        }
        onChanged?.call(option);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: itemBackgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmall.copyWith(
            color: itemTextColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );

    if (enableExpanded) {
      return Expanded(flex: flex, child: content);
    } else {
      return content;
    }
  }
}
