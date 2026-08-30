import 'package:flutter/material.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';

class SavingGoalModeToggle extends StatelessWidget {
  final ValueNotifier<bool> isByAmountNotifier;
  final FocusNode amountFocusNode;
  final FocusNode daysFocusNode;

  const SavingGoalModeToggle({
    super.key,
    required this.isByAmountNotifier,
    required this.amountFocusNode,
    required this.daysFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isByAmountNotifier,
      builder: (context, isByAmount, _) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: [
              Expanded(
                child: _ToggleButton(
                  text: context.l10n.setByAmount,
                  isSelected: isByAmount,
                  onTap: () {
                    isByAmountNotifier.value = true;
                    amountFocusNode.requestFocus();
                  },
                ),
              ),
              Expanded(
                child: _ToggleButton(
                  text: context.l10n.setByDays,
                  isSelected: !isByAmount,
                  onTap: () {
                    isByAmountNotifier.value = false;
                    daysFocusNode.requestFocus();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.black : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
