import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/home/data/models/home_model.dart';
import 'package:budget_wise/home/data/models/transaction_model.dart';
import 'package:budget_wise/home/view/screens/category_detail_screen.dart';
import 'package:budget_wise/statistics/data/models/statistics_model.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class CategoryListSection extends StatelessWidget {
  final List<CategoriesWithSpending> incomeBreakdown;
  final List<CategoriesWithSpending> expenseBreakdown;
  final ValueNotifier<bool> showIncomeNotifier;
  final double totalIncome;
  final double totalExpenses;
  final StatisticsSorting currentSorting;
  final Function(StatisticsSorting) onSortChanged;

  const CategoryListSection({
    super.key,
    required this.incomeBreakdown,
    required this.expenseBreakdown,
    required this.showIncomeNotifier,
    required this.totalIncome,
    required this.totalExpenses,
    required this.currentSorting,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Header with Filter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: showIncomeNotifier,
                builder: (context, showIncomeValue, child) {
                  return Text(
                    showIncomeValue
                        ? l10n.earningsByCategory
                        : l10n.spendingByCategory,
                    style: AppTextStyles.heading3,
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            PopupMenuButton<StatisticsSorting>(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              popUpAnimationStyle: AnimationStyle(
                curve: Curves.easeIn,
                reverseCurve: Curves.easeOut,
                duration: const Duration(milliseconds: 400),
                reverseDuration: const Duration(milliseconds: 400),
              ),
              color: AppColors.cardBackground,
              initialValue: currentSorting,
              icon: const Icon(Icons.sort, color: AppColors.textSecondary),
              onSelected: onSortChanged,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: StatisticsSorting.highestAmount,
                  child: Text(l10n.sortHighest),
                ),
                PopupMenuItem(
                  value: StatisticsSorting.lowestAmount,
                  child: Text(l10n.sortLowest),
                ),
                PopupMenuItem(
                  value: StatisticsSorting.alphabetical,
                  child: Text(l10n.sortAZ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Category Headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.category,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                l10n.amount,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        ValueListenableBuilder<bool>(
          valueListenable: showIncomeNotifier,
          builder: (context, showIncomeValue, child) {
            final breakdown = showIncomeValue
                ? incomeBreakdown
                : expenseBreakdown;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: breakdown.length,
              itemBuilder: (context, index) {
                final item = breakdown[index];
                final category = item.category;
                final color = showIncomeValue
                    ? AppColors.income
                    : AppColors.expense;
                final total = showIncomeValue ? totalIncome : totalExpenses;
                final percentage = total > 0
                    ? (item.totalSpending / total) * 100
                    : 0.0;
                final isIncome = category.type == TransactionType.income;

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      CategoryDetailScreen.routeName,
                      arguments: {'categoryId': category.id},
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            "${percentage.toStringAsFixed(0)}%",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isIncome
                                ? AppColors.income.withValues(alpha: 0.1)
                                : AppColors.expense.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                            border: Border.all(
                              color: isIncome
                                  ? AppColors.income.withValues(alpha: 0.2)
                                  : AppColors.expense.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Icon(
                            category.categoryIcon,
                            color: color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            category.categoryTitle,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${showIncomeValue ? "+" : "-"}\$${item.totalSpending.toInt()}',
                          style: AppTextStyles.bodyLarge.copyWith(color: color),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
