import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/savings/data/models/savings_model.dart';
import 'package:budget_wise/savings/view/screens/saving_goal_detail_screen.dart';
import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:budget_wise/subscriptions/view/screens/subscription_details_screen.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/shared/data/models/financial_breakdown_item.dart';
import 'package:budget_wise/shared/utils/toggle_option_enum.dart';
import 'package:budget_wise/shared/widgets/generic_icon_container.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_wise/category/view/screens/category_detail_screen.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/spacing.dart';
import '../../../shared/constants/text_styles.dart';

class CategoryListItem extends StatelessWidget {
  final FinancialBreakdownItem item;
  final ToggleOption currentSelection;

  const CategoryListItem({
    super.key,
    required this.item,
    required this.currentSelection,
  });

  @override
  Widget build(BuildContext context) {
    final source = item.source;
    final Color color;
    final String symbol;

    switch (currentSelection) {
      case ToggleOption.income:
        color = AppColors.income;
        symbol = "+";
        break;
      case ToggleOption.expense:
        color = AppColors.expense;
        symbol = "-";
        break;
      case ToggleOption.savings:
        color = AppColors.savings;
        symbol = "+";
        break;
      case ToggleOption.subscription:
        color = AppColors.subscription;
        symbol = "-";
        break;
    }

    final percentage = item.percentage;

    return GestureDetector(
      onTap: () {
        if (source is SavingsModel) {
          Navigator.of(context).pushNamed(
            SavingGoalDetailScreen.routeName,
            arguments: {'savingGoal': source},
          );
        } else if (source is CategoryModel) {
          Navigator.of(context).pushNamed(
            CategoryDetailScreen.routeName,
            arguments: {'categoryId': source.id},
          );
        } else if (source is SubscriptionModel) {
          Navigator.of(context).pushNamed(
            SubscriptionDetailsScreen.routeName,
            arguments: source.id,
          );
        }
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
              icon: source.financialIcon,
              color: source.financialColor ?? color,
              size: 40,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                source.financialTitle,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$symbol${NumberFormat.currency(name: context.read<SettingsBloc>().state.model.defaultCurrency).currencySymbol}${item.amount.toInt()}',
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
