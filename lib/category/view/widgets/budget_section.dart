import 'package:budget_wise/shared/utils/app_box_shadow.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/l10n/l10n_extension.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:budget_wise/shared/utils/thousands_formatter.dart';
import 'package:budget_wise/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class BudgetSection extends StatelessWidget {
  final ValueNotifier<TransactionType> selectedType;
  final ValueNotifier<bool> hasBudgetAmount;
  final TextEditingController budgetController;

  const BudgetSection({
    super.key,
    required this.selectedType,
    required this.hasBudgetAmount,
    required this.budgetController,
  });

  @override
  Widget build(BuildContext context) {
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
                color: AppColors.secondaryBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.borderColor, width: 0.5),
                boxShadow: [AppBoxShadow()],
              ),
              // decoration: BoxDecoration(
              //   color: AppColors.cardBackground,
              //   borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              // ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.setBudgetLimit,
                          style: AppTextStyles.bodyMedium,
                        ),
                        Text(
                          context.l10n.trackBudgetDesc,
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
                      return Transform.scale(
                        scale: 0.7,
                        child: Switch(
                          value: value,
                          onChanged: (newValue) {
                            hasBudgetAmount.value = newValue;
                            if (!newValue) {
                              budgetController.clear();
                            }
                          },
                          activeTrackColor: AppColors.primaryAccent.withValues(
                            alpha: 0.5,
                          ),
                          activeThumbColor: AppColors.primaryAccent,
                        ),
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
                    // Text(
                    //   context.l10n.monthlyBudget,
                    //   style: AppTextStyles.bodyMedium,
                    // ),
                    // const SizedBox(height: AppSpacing.sm),
                    // CustomTextField(
                    //   hintText: context.l10n.amount,
                    //   controller: budgetController,
                    //   keyboardType: TextInputType.number,
                    //   inputFormatters: [
                    //     FilteringTextInputFormatter.digitsOnly,
                    //     ThousandsSeparatorInputFormatter(),
                    //   ],
                    //   // activeColor: accentColor,
                    //   prefixIcon: Icon(
                    //     PhosphorIconsRegular.currencyDollar,
                    //     color: AppColors.textSecondary,
                    //   ),
                    // ),
                    CustomTextField(
                      label: context.l10n.monthlyBudget,
                      hintText: context.l10n.amount,
                      controller: budgetController,
                      shouldUnfocusOnTapOutside: true,
                      hasOriginalInputDecoration: false,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsSeparatorInputFormatter(),
                      ],
                      // activeColor: accentColor,
                      prefixIcon: Icon(
                        PhosphorIconsRegular.currencyDollar,
                        color: AppColors.textSecondary,
                      ),
                    ),
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
