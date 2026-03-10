import 'package:flutter/material.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class TransactionTypeToggle extends StatelessWidget {
  final ValueNotifier<TransactionType> selectedType;
  final String incomeLabel;
  final String expenseLabel;
  final Color accentColor;

  const TransactionTypeToggle({
    super.key,
    required this.selectedType,
    required this.incomeLabel,
    required this.expenseLabel,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: accentColor),
      ),
      padding: const EdgeInsets.all(4),
      child: ValueListenableBuilder<TransactionType>(
        valueListenable: selectedType,
        builder: (context, type, _) {
          final isIncome = type == TransactionType.income;
          return Row(
            children: [
              Expanded(
                child: _ToggleButton(
                  label: incomeLabel,
                  isSelected: isIncome,
                  activeColor: AppColors.primaryAccent,
                  onTap: () => selectedType.value = TransactionType.income,
                ),
              ),
              Expanded(
                child: _ToggleButton(
                  label: expenseLabel,
                  isSelected: !isIncome,
                  activeColor: AppColors.expense,
                  onTap: () => selectedType.value = TransactionType.expense,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? Colors.black : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
