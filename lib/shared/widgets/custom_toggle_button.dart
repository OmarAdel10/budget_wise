import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';

class CustomToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? activeColor;
  final bool hasPadding;
  final bool hasBottomMargin;

  const CustomToggleButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.activeColor,
    this.hasPadding = false,
    this.hasBottomMargin = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppColors.primaryAccent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        margin: hasBottomMargin ? EdgeInsets.only(bottom: AppSpacing.sm) : null,
        padding: hasPadding
            ? const EdgeInsets.symmetric(vertical: AppSpacing.md - 3)
            : null,
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: isSelected ? effectiveActiveColor : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected
                  ? AppColors.textInverse
                  : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
