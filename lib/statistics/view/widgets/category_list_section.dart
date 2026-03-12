import 'package:budget_wise/shared/data/models/financial_breakdown_item.dart';
import 'package:budget_wise/shared/utils/toggle_option_enum.dart';
import 'package:flutter/material.dart';
import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/statistics/data/models/statistics_model.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';
import 'category_list_item.dart';

class CategoryListHeader extends StatelessWidget {
  final ToggleOption toggleType;
  final StatisticsSorting currentSorting;
  final Function(StatisticsSorting) onSortChanged;

  const CategoryListHeader({
    super.key,
    required this.toggleType,
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
              child: Text(
                toggleType == ToggleOption.income
                    ? l10n.earningsByCategory
                    : toggleType == ToggleOption.expense
                    ? l10n.spendingByCategory
                    : toggleType == ToggleOption.savings
                    ? l10n.savingsByCategory
                    : l10n.totalSubscriptions,
                style: AppTextStyles.heading3,
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
      ],
    );
  }
}

class CategoryListSliver extends StatelessWidget {
  final List<FinancialBreakdownItem> breakdown;
  final ToggleOption toggleType;

  const CategoryListSliver({
    super.key,
    required this.breakdown,
    required this.toggleType,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return CategoryListItem(
          item: breakdown[index],
          currentSelection: toggleType,
        );
      }, childCount: breakdown.length),
    );
  }
}
