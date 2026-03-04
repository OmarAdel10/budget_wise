import 'package:budget_wise/transaction/data/model/transaction_model.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/utils/thousands_formatter.dart';
import 'package:budget_wise/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class BudgetSection extends StatelessWidget {
  final ValueNotifier<TransactionType> selectedType;
  final ValueNotifier<bool> hasBudgetAmount;
  final TextEditingController budgetController;
  final Color accentColor;

  const BudgetSection({
    super.key,
    required this.selectedType,
    required this.hasBudgetAmount,
    required this.budgetController,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<TransactionType>(
      valueListenable: selectedType,
      builder: (context, type, _) {
        if (type != TransactionType.expense) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.setBudgetLimit,
                          style: AppTextStyles.bodyMedium,
                        ),
                        Text(
                          l10n.trackBudgetDesc,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ValueListenableBuilder<bool>(
                    valueListenable: hasBudgetAmount,
                    builder: (context, value, _) {
                      return Switch(
                        value: value,
                        onChanged: (newValue) {
                          hasBudgetAmount.value = newValue;
                          if (!newValue) {
                            budgetController.clear();
                          }
                        },
                        activeTrackColor: accentColor.withValues(alpha: 0.5),
                        activeThumbColor: accentColor,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ValueListenableBuilder<bool>(
              valueListenable: hasBudgetAmount,
              builder: (context, value, _) {
                if (!value) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.monthlyBudget, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.sm),
                    CustomTextField(
                      hintText: l10n.amount,
                      controller: budgetController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsSeparatorInputFormatter(),
                      ],
                      activeColor: accentColor,
                      prefixIcon: Icon(
                        PhosphorIcons.currencyDollar(
                          PhosphorIconsStyle.regular,
                        ),
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
