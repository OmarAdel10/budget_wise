import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/utils/toggle_option_enum.dart';
import 'package:budget_wise/shared/widgets/generic_icon_container.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_wise/home/data/models/home_model.dart';
import 'package:budget_wise/category/view/screens/category_detail_screen.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class CategoryListItem extends StatelessWidget {
  final CategoriesWithSpending item;
  final ToggleOption currentSelection;

  const CategoryListItem({
    super.key,
    required this.item,
    required this.currentSelection,
  });

  @override
  Widget build(BuildContext context) {
    final category = item.category;
    final isIncome = currentSelection == ToggleOption.income;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final percentage = item.percentage;
    final symbol = isIncome ? "+" : "-";

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
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
            GenericIconContainer(
              icon: category.categoryIcon,
              color: isIncome ? AppColors.income : AppColors.expense,
              size: 40,
            ),
            const SizedBox(width: AppSpacing.sm),
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
              '$symbol${NumberFormat.currency(name: context.read<SettingsBloc>().state.model.defaultCurrency).currencySymbol}${item.totalSpending.toInt()}',
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
  }
}
