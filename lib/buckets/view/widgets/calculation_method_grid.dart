import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/buckets/data/models/saving_goal_model.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class CalculationMethodGrid extends StatelessWidget {
  final ValueNotifier<SavingGoalMethod> selectedMethodNotifier;
  final Function(SavingGoalMethod) onMethodSelected;
  final Function(SavingGoalMethod) onHelp;

  const CalculationMethodGrid({
    super.key,
    required this.selectedMethodNotifier,
    required this.onMethodSelected,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SavingGoalMethod>(
      valueListenable: selectedMethodNotifier,
      builder: (context, selectedMethod, _) {
        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final method = SavingGoalMethod.values[index];
            return RepaintBoundary(
              child: _MethodCard(
                method: method,
                isSelected: selectedMethod == method,
                onTap: () => onMethodSelected(method),
                onHelp: () => onHelp(method),
              ),
            );
          }, childCount: SavingGoalMethod.values.length),
        );
      },
    );
  }
}

class _MethodCard extends StatelessWidget {
  final SavingGoalMethod method;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onHelp;

  const _MethodCard({
    required this.method,
    required this.isSelected,
    required this.onTap,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context) {
    String label = "";
    switch (method) {
      case SavingGoalMethod.defaultPattern:
        label = context.l10n.methodDefault;
        break;
      case SavingGoalMethod.constant:
        label = context.l10n.methodConstant;
        break;
      case SavingGoalMethod.doublePattern:
        label = context.l10n.methodDouble;
        break;
      case SavingGoalMethod.custom:
        label = context.l10n.methodCustom;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryAccent.withValues(alpha: 0.1)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primaryAccent : AppColors.borderColor,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onHelp,
                child: const Icon(
                  Icons.help_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
