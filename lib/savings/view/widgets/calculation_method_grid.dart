import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/savings/data/models/savings_model.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class CalculationMethodGrid extends StatelessWidget {
  final ValueNotifier<SavingsMethod> selectedMethodNotifier;
  final Function(SavingsMethod) onMethodSelected;
  final Function(SavingsMethod) onHelp;

  const CalculationMethodGrid({
    super.key,
    required this.selectedMethodNotifier,
    required this.onMethodSelected,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SavingsMethod>(
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
            final method = SavingsMethod.values[index];
            return RepaintBoundary(
              child: _MethodCard(
                method: method,
                isSelected: selectedMethod == method,
                onTap: () => onMethodSelected(method),
                onHelp: () => onHelp(method),
              ),
            );
          }, childCount: SavingsMethod.values.length),
        );
      },
    );
  }
}

class _MethodCard extends StatelessWidget {
  final SavingsMethod method;
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
    final l10n = AppLocalizations.of(context)!;
    String label = "";
    switch (method) {
      case SavingsMethod.defaultPattern:
        label = l10n.methodDefault;
        break;
      case SavingsMethod.constant:
        label = l10n.methodConstant;
        break;
      case SavingsMethod.doublePattern:
        label = l10n.methodDouble;
        break;
      case SavingsMethod.custom:
        label = l10n.methodCustom;
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
