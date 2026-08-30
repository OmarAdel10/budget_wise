import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/category/view_model/category_state.dart';
import 'package:budget_wise/shared/constants/colors.dart';
import 'package:budget_wise/shared/constants/spacing.dart';
import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class BudgetsListScreen extends StatelessWidget {
  static const String routeName = '/budgets-list';
  const BudgetsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        title: Text(
          "Budgeting",
          style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            final budgetCategories = state.categoriesList
                .where((c) => c.hasBudgetAmount)
                .toList();

            if (budgetCategories.isEmpty) {
              return Center(
                child: Text(
                  "No budgets set yet",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: budgetCategories.length,
              separatorBuilder: (ctx, i) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final category = budgetCategories[index];
                return _BudgetCategoryItem(category: category);
              },
            );
          },
        ),
      ),
    );
  }
}

class _BudgetCategoryItem extends StatelessWidget {
  final CategoryModel category;

  const _BudgetCategoryItem({required this.category});

  @override
  Widget build(BuildContext context) {
    // Mock spending - in production this would be calculated from transactions
    final double spent = 0.0;
    final double limit = category.budgetAmount ?? 0.0;
    final double progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(category.categoryIcon),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.categoryTitle,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${spent.toStringAsFixed(0)} / ${limit.toStringAsFixed(0)} EGP",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // TO DO: Quick Edit Budget
                },
                icon: const Icon(
                  PhosphorIconsBold.pencilSimple,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.primaryBackground,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.9 ? Colors.redAccent : AppColors.primaryAccent,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
